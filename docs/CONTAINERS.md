# systemd-nspawn Container Reference

How to run a **systemd-spawned NixOS container on the tailnet** in this flake.
Reference implementation: the `hermes` guest (a `systemd-nspawn` container on
`p5810` that runs Tailscale and serves a dashboard directly to the tailnet).

A container here is two cooperating pieces:

1. **Host side** — one `containers.<name>` entry on a real host (here `p5810`),
   plus two oneshot helper units (`<name>-nat`, `<name>-guest-build`). This owns
   the veth, NAT, and the guest toplevel build.
2. **Guest side** — an auto-discovered host under `systems/<arch>/<name>/`
   (here `systems/x86_64-linux/hermes/`) built with the `lxc` archetype. This
   owns the container OS: Tailscale autoconnect, SOPS, SSH, the workload.

The tailnet is the **only** control plane. The guest's `tailscale0` is a trusted
firewall interface, so tailnet clients reach the guest's tailnet IP directly —
no host port-forwarding, no public exposure. The veth is only for the guest's
outbound internet (NAT).

## Topology

```
p5810 (host, real NixOS)                      tailnet (fluffy-rooster.ts.net)
┌───────────────────────────────┐
│ containers.hermes             │
│  veth: ve-hermes              │
│   host  10.0.3.1   ◄──────────┐│
│  hermes-nat  MASQUERADE ──────┼┼──────────► internet
│  hermes-guest-build (oneshot) ││
└──────────────┬────────────────┘│
               │ nspawn veth     │
        ┌──────▼──────┐          │
        │ hermes guest │          │
        │ eth0 10.0.3.2 (uplink) │
        │ tailscale0 100.115.2.61├──────────► tailnet peers
        │  └─ trusted fw iface   │
        │  dashboard :9119 (0.0.0.0)
        └─────────────┘          │
                                 │
   tailnet peers ────────────────┘  (reach 100.115.2.61:9119 directly)
```

## How the flake wires it together

### Guest = an auto-discovered host

`lib.mkFlake` (Snowfall) auto-discovers every directory under
`systems/<arch>/` as a `nixosConfigurations.<host>` entry. So creating
`systems/x86_64-linux/hermes/default.nix` gives you:

- `.#nixosConfigurations.hermes` — the guest configuration, and
- `.#nixosConfigurations.hermes.config.system.build.toplevel` — the
  bootable toplevel the container runs.

The guest is a **real NixOS config**, not a `docker`-style image. The full flake
module set (frgd, sops-nix, your service modules) is available inside it for
free — which is exactly what the inline `containers.<name>.config` path cannot
do (that path evaluates against bare nixpkgs with `system = null`, so frgd is
unavailable).

### Host side: `containers.<name>`

The NixOS `virtualisation.nixos-containers` module turns a top-level
`containers.<name>` attrset into a `container@<name>.service` (a
`systemd-nspawn` unit). `boot.enableContainers` auto-enables when the set is
non-empty. Key options (all from that module):

| Option | Purpose |
|---|---|
| `autoStart` | Wanted by `machines.target`; container boots with the host. |
| `flake = "/path/to/flake#<host>"` | Build the guest from a flake attr rather than a static path. |
| `privateNetwork = true` | `--private-network`; only the veth (no host networking). |
| `hostAddress` / `localAddress` | The veth pair IPs: host end / guest end. Must be a /32 point-to-point. |
| `enableTun = true` | Expose `/dev/net/tun` — required for the guest's Tailscale. |
| `timeoutStartSec` | Boot grace before systemd kills a not-yet-`READY` container. |
| `extraFlags` | Raw `systemd-nspawn` flags (e.g. `--bind`). |

Two facts about the module that drive the two helper units below:

- **The `flake = "…#attr"` form is read from the conf file and its `#attr` is
  not split out** (only a CLI `--flake` splits it), so the built-in auto-update
  builds a double-`#` attr and fails. Root also cannot fetch a local git flake
  owned by another user (libgit2 error 7). → solved by the `<name>-guest-build`
  oneshot, which pre-sets the profile so the start script skips auto-update.
- **The module sets no NAT for `--private-network`.** Without MASQUERADE the
  guest has no outbound internet. → solved by the `<name>-nat` oneshot.

The module builds the guest toplevel and points the container at
`/nix/var/nix/profiles/per-container/<name>/system`. That profile is the thing
the helper units manage.

### `<name>-nat` — outbound internet for the guest

`--private-network` gives the guest a veth but no route to the world. The
module does not add MASQUERADE, so the guest cannot reach the internet. A small
idempotent oneshot (idempotent via `iptables -C` before `-A`) adds the NAT rule
after the veth is up:

```nix
systemd.services."<name>-nat" = {
  description = "MASQUERADE NAT for the <name> container veth";
  after = [ "network.target" "container@<name>.service" ];
  wantedBy = [ "multi-user.target" ];
  path = with pkgs; [ iptables ];
  script = ''
    # <localAddress>/32 = the guest end of the veth; ! -o the veth so traffic
    # already on the veth is not re-marked.
    iptables -t nat -C POSTROUTING -s <localAddress>/32 ! -o ve-<name> -j MASQUERADE \
      || iptables -t nat -A POSTROUTING -s <localAddress>/32 ! -o ve-<name> -j MASQUERADE
  '';
  serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
};
```

`ve-<name>` is the host-end veth interface name the module names from the
container name.

### `<name>-guest-build` — build the toplevel as the repo owner

The `flake = "…#attr"` conf form cannot auto-update (see above) and root cannot
fetch a local git flake owned by another user. So a `RemainAfterExit` oneshot
builds the guest toplevel **as the repo owner** via `runuser`, then root points
the container profile at the result. Ordered `before = container@<name>`: the
start script finds the profile present and skips the broken auto-update. It
rebuilds each boot, so guest flake edits apply on the next reboot.

```nix
systemd.services."<name>-guest-build" = {
  description = "Build the <name> nspawn guest toplevel from the flake";
  wantedBy = [ "machines.target" ];
  after = [ "nix-daemon.service" ];
  before = [ "container@<name>.service" ];
  path = with pkgs; [ bash coreutils git nix util-linux ];  # git: nix fetches git inputs
  script = ''
    set -euo pipefail
    out=$(runuser -u justin -- nix build --print-out-paths \
      '/home/justin/flake#nixosConfigurations."<name>".config.system.build.toplevel')
    mkdir -p /nix/var/nix/profiles/per-container/<name>
    nix-env -p /nix/var/nix/profiles/per-container/<name>/system --set "$out"
  '';
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    WorkingDirectory = "/home/justin";  # nix drops a `result` symlink in CWD
  };
};
```

> **The two oneshots are `RemainAfterExit`.** A plain host `switch` restarts
> `container@<name>` (config changed) but does **not** re-run a `RemainAfterExit`
> oneshot whose unit file is unchanged. So after editing the guest flake, the
> container relaunches off the **stale** profile until you re-run the build:
> `doas systemctl restart <name>-guest-build && doas systemctl restart container@<name>`.
> This is the single most common "why is my change not live" — see [Operations](#operations).

### The guest: `systems/<arch>/<name>/default.nix`

The guest is a normal flake host. The `lxc` archetype
(`frgd.archetypes.lxc`) bundles everything a tailnet container needs:

- `boot.isContainer = true`
- `frgd.nix` (a Nix daemon in the guest), `frgd.security.sops`, `frgd.security.doas`
- `frgd.services.tailscale` **with `autoconnect`** — the thing that puts it on
  the tailnet at boot
- `frgd.services.openssh`, `frgd.services.beszel-agent`, `frgd.cli-apps.nh`
- getty autologin (`justin`), node-exporter collectors, locale/time/xkb

The one hand-written bit is the **uplink**: the host's `container-init` assigns
the guest `eth0` the `localAddress` at boot stage 1, so the guest only pins the
same static address and disables DHCP (no DHCP on a bridge-less veth):

```nix
{
  lib, pkgs, config, ...
}:
with lib;
with lib.frgd;
{
  # Required by nixos-container on nixpkgs 25.11+ for the `flake` option path
  # (the inline `config` path gets this injected; the flake path does not).
  boot.isNspawnContainer = true;

  networking.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    { address = "<localAddress>"; prefixLength = 32; }
  ];

  # lxc archetype: isContainer, nix, sops, tailscale autoconnect, openssh, ...
  frgd.archetypes.lxc = enabled;

  # nixos-firewall is on by default; openssh opens 22. Open your workload port
  # so tailnet clients (tailscale0 = trusted interface) reach it.
  networking.firewall.allowedTCPPorts = [ 9119 ];

  # ... your workload module(s) + sops.secrets here ...
}
```

The `lxc` archetype already enables Tailscale, but it reads the auth key from a
SOPS secret (`config.sops.secrets.tailscale_api_key` — see below), so you only
need the secret declared; the module wires `authKeyFile` and the
`tailscale-autoconnect` oneshot itself.

### How the guest joins the tailnet

`frgd.services.tailscale` (autoconnect) configures, for any host where it is on:

- `services.tailscale.enable = true`, `authKeyFile = …/tailscale_api_key`
- `extraUpFlags = --ssh, --accept-dns, --accept-routes=false`
- `networking.firewall.trustedInterfaces = [ tailscale0 ]` and
  `checkReversePath = "loose"` (strict RPF breaks exit-node / subnet routing)
- a `tailscale-autoconnect` oneshot: if `tailscale status` BackendState is not
  `Running`, it runs `tailscale up -authkey "$(cat …/tailscale_api_key)"`.

So at every boot the guest re-authenticates with its SOPS key and appears on the
tailnet. Because `tailscale0` is a trusted firewall interface, the guest's
tailnet IP (e.g. `100.115.2.61`) is reachable from any tailnet peer on any port
the guest's firewall allows — no host forwarding, no public address. This is why
the host `containers.<name>` block sets **no `--port`**: the veth exists only so
the guest has outbound NAT.

> To reach a port not already in `allowedTCPPorts`, add it to
> `networking.firewall.allowedTCPPorts` in the guest — the firewall is the only
> gate on the tailnet side.

### SOPS: decrypting inside the container

The guest decrypts its own SOPS secrets at activation time. The host exposes its
age keyfile read-only so the guest can decrypt: set `containers.<name>.extraFlags`
to `--bind=/sops:/sops`. The sops module (`frgd.security.sops`) sets
`sops.age.keyFile = "/sops/keys.txt"` (age-only; `sshKeyPaths = []`) and declares
the shared secrets, including `tailscale_api_key` (owner `root`, group `tailscale`,
`0640`):

```nix
# shared: modules/nixos/security/sops/default.nix (loaded by the lxc archetype)
sops.age.keyFile = "/sops/keys.txt";
sops.age.sshKeyPaths = [ ];        # age-only; no SSH host-key decrypt
sops.secrets.tailscale_api_key = { owner = "root"; group = "tailscale"; mode = "0640"; };
```

Per-container secrets (e.g. a dashboard auth env file) are declared in the guest
and referenced via `config.sops.secrets.<name>.path`:

```nix
sops.secrets.my_thing = { owner = "myuser"; group = "myuser"; mode = "0440"; };
services.myworkload.environmentFiles = [ config.sops.secrets.my_thing.path ];
```
## Full host-side block (the `hermes` reference)

Everything on the host, verbatim from `systems/x86_64-linux/p5810/default.nix`:

```nix
containers.hermes = {
  autoStart = true;
  flake = "/home/justin/flake#hermes";
  privateNetwork = true;
  hostAddress = "10.0.3.1";
  localAddress = "10.0.3.2";
  # No --port forward: the dashboard is reached tailnet-direct (the guest's
  # tailscale0 is a trusted firewall interface, so tailnet clients reach 9119
  # directly). The veth stays for the guest's outbound NAT only.
  enableTun = true;                 # /dev/net/tun for the guest's tailscaled
  timeoutStartSec = "5min";         # slow-boot gateways exceed the 1min default
  extraFlags = [ "--bind=/sops:/sops" ];  # age keyfile for guest sops decrypt
};

# Slow shutdown exceeds the 90s default; a stop timeout SIGKILLs nspawn before it
# cleans up the unix-export mount, so the next spawn refuses ("exists already").
# The nixos-containers module only exposes timeoutStartSec, so override the stop
# timeout directly on the templated unit instance.
systemd.services."container@hermes".serviceConfig.TimeoutStopSec = "5min";

systemd.services."hermes-nat" = { /* <name>-nat, see above */ };
systemd.services."hermes-guest-build" = { /* <name>-guest-build, see above */ };
```

Pick a **unique /32 point-to-point subnet per container** (hermes uses
`10.0.3.1`/`10.0.3.2`); the `hostAddress`/`localAddress` must match the guest's
`eth0` static address exactly, and `<name>-nat` must use the same `localAddress`
and `ve-<name>`.

## Deploy exclusion

A guest is **not a deploy target** — it is built into a container on the host,
never activated on real hardware. Add its name to the `excludedHosts` list in
`lib/deploy/default.nix` (alongside `p5810`, `t480`):

```nix
excludedHosts = [ "p5810" "t480" "hermes" ];  # hermes: nspawn guest on p5810
```

## Operations

### Build (never deploy the guest)

```sh
# guest toplevel (this is what the container runs)
nix build .#nixosConfigurations.<name>.config.system.build.toplevel --print-out-paths
# host (builds the container units + helper oneshots)
nix build .#nixosConfigurations.p5810.config.system.build.toplevel
```

### Deploy the host, then bring the guest up

Deploying is yours to run (AGENTS.md). On `p5810`:

```sh
nixos-rebuild switch --flake .#p5810
systemctl restart container@<name>          # picks up the new guest profile
systemctl status  container@<name>
```

### Why the guest goes stale after a guest edit (the big gotcha)

`<name>-guest-build` is `RemainAfterExit`. A host `switch` restarts
`container@<name>` (its unit config changed) but does **not** re-run an unchanged
`RemainAfterExit` oneshot. So the container relaunches off the **old** profile —
your guest flake edit is not live. Fix:

```sh
doas systemctl restart <name>-guest-build     # rebuild profile to the new toplevel
doas systemctl restart container@<name>
```

The guest-build rebuilds on every *reboot* (it is `WantedBy=machines.target`
and `Before=container@<name>`), so a plain reboot is the other way to apply a
guest flake edit.

### Verify it is on the tailnet

```sh
tailscale status | grep <name>              # expect: <tailnet-ip>  <name>  ...
tailscale status --json | jq -r '.Peer | to_entries[] | select(.value.DNSName|test("<name>")) | "\(.key) online=\(.value.Online)"'
curl -s -o /dev/null -w '%{http_code}\n' http://<tailnet-ip>:<port>/   # from any tailnet peer
```

(Verify against the **plain HTTP** port the workload actually serves — the
hermes dashboard is plain `http`, not `https`.)

## Checklist: add a new tailnet container

1. `systems/x86_64-linux/<name>/default.nix` — `boot.isNspawnContainer = true`,
   `frgd.archetypes.lxc = enabled`, pin `eth0` to the chosen `localAddress`,
   open workload port in `networking.firewall.allowedTCPPorts`, declare
   `sops.secrets`.
2. On the host: `containers.<name> = { autoStart, flake, privateNetwork,
   hostAddress, localAddress, enableTun, timeoutStartSec,
   extraFlags = [ "--bind=/sops:/sops" ]; }`.
3. On the host: `<name>-nat` (MASQUERADE for `localAddress/32` → `ve-<name>`) and
   `<name>-guest-build` (build as repo owner, set the per-container profile), both
   `RemainAfterExit`.
4. Bump `TimeoutStopSec` on `container@<name>` if the guest shuts down slowly.
5. Add `<name>` to `excludedHosts` in `lib/deploy/default.nix`.
6. Pick a fresh /32 point-to-point subnet; keep host/guest/NAT in sync.
7. Build guest + host toplevels; `nixos-rebuild switch` the host; restart the
   container; confirm `tailscale status` shows the node `online`.
