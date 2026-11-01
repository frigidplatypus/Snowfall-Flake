# systems/x86_64-linux/hermes/default.nix
# NixOS guest for the hermes-agent nspawn container on p5810.
#
# Built by the p5810 host via `containers.hermes.flake = "#hermes"` — the
# full flake module set (frgd, hermes-agent, sops-nix) loads for free, which
# the inline `containers.<name>.config` path cannot do (it evaluates against
# bare nixpkgs with system=null, so frgd is unavailable).
#
# `frgd.archetypes.lxc` gives boot.isContainer, frgd.nix, sops, tailscale
# autoconnect, openssh, beszel, and getty autologin.
#
# The host-side container-init script assigns eth0 the private-network
# address + default route at stage 1, so this module only pins the same
# static address and disables DHCP to keep the guest from tearing it down.

{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  # Required by nixos-container on nixpkgs 25.11+ when built via the `flake`
  # option (the inline config path gets this injected by the nspawn module;
  # the flake path does not).
  boot.isNspawnContainer = true;

  # Private network (veth to p5810): match the address container-init
  # assigns at stage 1; no DHCP on the bridge-less link.
  networking.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "10.0.3.2";
      prefixLength = 32;
    }
  ];

  # The dashboard binds the guest tailnet IP (0.0.0.0); a non-loopback bind
  # engages hermes's dashboard auth gate, which requires a provider. The
  # basic_auth env secret (justin + password) satisfies it. The nixos-firewall
  # (from archetypes.lxc) drops everything except SSH, so allow the backend
  # port for tailnet clients.
  networking.firewall.allowedTCPPorts = [ 9119 ];
  # Container archetype: boot.isContainer, frgd.nix, frgd.security.sops,
  # frgd.services.tailscale (autoconnect), frgd.services.openssh,
  # frgd.services.beszel-agent, frgd.cli-apps.nh, getty autologin.
  frgd.archetypes.lxc = enabled;

  # Dashboard auth (justin + password), cat'd into $HERMES_HOME/.env by the
  # hermes activation; the basic provider hashes the password in memory.
  # Reuse the existing hermes agent env secret for testing.
  sops.secrets = {
    monty_env = {
      owner = "hermes";
      group = "hermes";
      mode = "0440";
    };
    hermes_dashboard_auth = {
      owner = "hermes";
      group = "hermes";
      mode = "0440";
    };
  };

  services.hermes-agent = {
    enable = true;
    # Expose the hermes CLI on system PATH (/run/current-system/sw/bin) and
    # export HERMES_HOME system-wide, so the `hermes` user (and any interactive
    # shell) can invoke the CLI and share state with the gateway service.
    # Without this, only the systemd unit's private PATH sees the binary.
    addToSystemPackages = true;
    extraDependencyGroups = [
      "firecrawl"
      "messaging"
      "web"
    ];
    extraPackages = with pkgs; [
      chromium
      curl
      dejavu_fonts
      ffmpeg
      forgejo-cli
      gh
      git
      jq
      nix
      nodejs
      openssh
      ripgrep
      uv
    ];
    # Global default model for every surface (web / TUI / CLI / mattermost) —
    # they all fall back to model.default, so a bare model with no provider
    # resolves through the auth pool (openrouter) and a web "chat window"
    # spawns an empty-model TUI session that restore_policy rejects as
    # storage_unavailable. Yolo-Auto is wired as a custom OpenAI-compatible
    # provider; the key comes from monty_env (YOLO_AUTO_API_KEY) at runtime, so
    # no secret is committed here.
    settings.model = {
      provider = "custom";
      base_url = "https://yolo-auto.com/v1";
      default = "qwen3.8-27b";
      api_key_env = "YOLO_AUTO_API_KEY";
      context_length = 131072;
    };
    environmentFiles = [
      config.sops.secrets.monty_env.path
      config.sops.secrets.hermes_dashboard_auth.path
    ];
    backend = {
      mode = "dashboard";
      # 0.0.0.0 + the auth gate: the tailnet is the only network control
      # (guest is not LAN-reachable), so any Host is accepted.
      host = "0.0.0.0";
      port = 9119;
    };
  };
}
