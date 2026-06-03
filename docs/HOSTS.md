# Host Reference

All 24 NixOS hosts + 1 provisioning template. Hosts are organized under `systems/x86_64-linux/`.

## Archetypes

Every host assigns an archetype that bundles common configuration:

| Archetype | File | What it enables |
|-----------|------|-----------------|
| `workstation` | `archetypes/workstation/` | `common` + `desktop` + `development` suites, appimage-run |
| `server` | `archetypes/server/` | `common-slim` suite only |
| `lxc` | `archetypes/lxc/` | Container-optimized: `boot.isContainer`, Prometheus node exporter, beszel-agent, tailscale autoconnect, no boot/systemd-units |
| `vm` | `archetypes/vm/` | QEMU guest agent, auto-login root, boot config |
| `gaming` | `archetypes/gaming/` | (defined but not currently assigned) |

## Workstations (Bare Metal)

### p5810 — Main Desktop
- **Role:** Primary workstation — Nvidia GPU, ZFS, Docker rootless
- **Hardware notes:** Precision 5810 workstation
- **Key services:** Ollama, Open WebUI (port 8888), n8n, Docker rootless, libvirtd, ZFS replication (sanoid + syncoid), Samba (ROMS share)
- **ZFS pools:** `zroot` (system), `storage` (extra media/ROMs pool), `zhome` (home directory)
- **Disko:** Yes
- **deploy-rs:** ❌ Excluded (local rebuild only)
- **Tailnet:** `fluffy-rooster.ts.net`

### surface — Microsoft Surface
- **Role:** Secondary mobile workstation
- **Hardware notes:** Microsoft Surface common (nixos-hardware module), fingerprint sensor
- **Key services:** Hyprland desktop, flatpak, bluetooth, auto-cpufreq, power management
- **ZFS:** Yes
- **Disko:** Yes
- **Archetype:** `workstation` + `desktop/hyprland` suite
- **Determinate:** ✅

### t480 — ThinkPad T480
- **Role:** Mobile workstation (laptop)
- **Hardware notes:** Lenovo ThinkPad T480 (nixos-hardware module), fingerprint sensor
- **Key services:** niri compositor, flatpak, bluetooth, auto-cpufreq, fwupd, ZFS replication
- **ZFS:** Yes (sends notes/development/home to p5810 via syncoid)
- **Disko:** Yes
- **Archetype:** `workstation` + `desktop/niri` suite
- **Determinate:** ✅

### kitchenixos — Kitchen Display
- **Role:** Kitchen computer
- **Hardware notes:** Dell OptiPlex 7010 SFF
- **Key services:** GNOME desktop, flatpak, bluetooth, pipewire
- **Archetype:** `workstation` + `desktop/gnome` suite

### klipper — 3D Printer Controller
- **Role:** 3D printer host (Klipper firmware + Moonraker API)
- **Hardware notes:** x86_64 with serial device for printer MCU
- **Key services:** Klipper, Moonraker, Syncthing, serial device binding
- **Archetype:** `server`
- **ZFS:** Yes
- **Disko:** Yes

## Hybrid (Server + Hermes Agent)

### monty — Hermes Agent / Mattermost
- **Role:** AI agent host running Hermes Agent + Mattermost chat
- **Key services:** Hermes Agent (with firecrawl, messaging, web deps), Mattermost (chat.fluffy-rooster.ts.net), hermes-desktop (headless Xvfb + fluxbox + x11vnc + noVNC), hermes-dashboard, Caddy reverse proxy
- **ZFS:** No
- **Hardware:** hardware.nix
- **Archetype:** `server`

### ai — AI / Hermes Agent (LXC)
- **Role:** AI inference + Hermes Agent in LXC
- **Key services:** Hermes Agent (messaging + web), Hermes Dashboard, Guacamole (remote desktop to AI VNC), x11vnc, Caddy reverse proxy (ai.fluffy-rooster.ts.net)
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

## Infrastructure

### dns — DNS Server
- **Role:** DNS + short link + identity provider
- **Key services:** AdGuard Home (DNS, DHCP), golink (Tailscale short links), tsidp (Tailscale identity provider)
- **Caddy hosts:** dns.fluffy-rooster.ts.net, imessage.frgd.us, chores.frgd.us
- **Container:** Proxmox LXC
- **Archetype:** `lxc`
- **ACME:** ✅ (wildcard *.frgd.us)

### jump — Lightweight Jump Box
- **Role:** Minimal SSH jump host
- **Key services:** SSH server, Nix
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### unifi — UniFi Controller
- **Role:** UniFi network management
- **Key services:** UniFi controller (unifi.fluffy-rooster.ts.net, reverse-proxied via Caddy to 127.0.0.1:8443)
- **Disko:** Yes (currently commented out in config)
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### omada — Omada Controller
- **Role:** TP-Link Omada SDN controller
- **Key services:** Omada controller (omada.fluffy-rooster.ts.net, reverse-proxied via Caddy to 127.0.0.1:8043), Docker
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

## Storage

### nasnix — NAS
- **Role:** Network-attached storage, media server
- **Key services:** Jellyfin, NFS server, Samba (ROMS, media shares), nix-serve (binary cache), netdata, Docker, libvirtd, ZFS snapshots/autoscrub
- **Caddy hosts:** nasnix.fluffy-rooster.ts.net (port 8000), romm.wc-12.com
- **ZFS:** Yes (includes `storage` pool)
- **Disko:** Yes
- **Archetype:** `server`

## Content & Productivity

### notes — Notes / Silverbullet
- **Role:** Note-taking (Silverbullet)
- **Key services:** Silverbullet (notes.fluffy-rooster.ts.net), Caddy reverse proxy
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### documents — Document Management
- **Role:** Paperless-ngx document management
- **Key services:** Paperless-ngx (documents.fluffy-rooster.ts.net), Stirling PDF, Silverbullet, BorgBase backup, Samba (consume folder), OIDC auth via Tailscale IDP
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### logseq — Logseq / Obsidian
- **Role:** Knowledge graph / note-taking with headless desktop
- **Key services:** Guacamole (VNC to Xvfb+Openbox+Logseq+Obsidian), Syncthing, Caddy (logseq.fluffy-rooster.ts.net)
- **Includes:** `logseq-bible-query` CLI script for Bible reference queries
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### books — Calibre-Web
- **Role:** E-book library management
- **Key services:** Calibre-Web (books.fluffy-rooster.ts.net, Tailscale auth), Docker
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### audiobooks — Audiobookshelf
- **Role:** Audiobook and podcast server
- **Key services:** Audiobookshelf (audiobooks.fluffy-rooster.ts.net), Syncthing
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### recipes — Mealie
- **Role:** Recipe management
- **Key services:** Mealie (recipes.fluffy-rooster.ts.net, OIDC auth), Caddy reverse proxy
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

## Notifications & Task Management

### ntfy — Notification Server
- **Role:** Push notification server (self-hosted ntfy.sh alternative)
- **Key services:** ntfy-sh (ntfy.fluffy-rooster.ts.net), Prometheus + node-exporter monitoring, Caddy reverse proxy
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### reader — RSS Reader
- **Role:** RSS feed reader (Miniflux) + email-to-RSS bridge
- **Key services:** Miniflux (reader.fluffy-rooster.ts.net, OIDC auth), email-to-miniflux (Gmail IMAP bridge)
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### hoarder — Bookmark Manager
- **Role:** Bookmark/URL hoarding (Karakeep) + pastebin (tclip)
- **Key services:** Karakeep (hoarder.fluffy-rooster.ts.net, OIDC auth), tclip paste service (paste.fluffy-rooster.ts.net)
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### tasks — Task Management
- **Role:** Task management (Vikunja)
- **Key services:** Vikunja task server (tasks.fluffy-rooster.ts.net, reverse-proxied via Caddy to port 10222)
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

### actual — Budgeting
- **Role:** Personal finance (Actual Budget)
- **Key services:** Actual Budget (actual.fluffy-rooster.ts.net)
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

## External / VPS

### racknerd — RackNerd VPS
- **Role:** Public-facing VPS — hosts Forgejo (git), Beszel monitoring hub, Silverbullet, Caddy (public domains)
- **Key services:** Forgejo (git.fluffy-rooster.ts.net), Beszel monitoring hub, Silverbullet, BorgBase backup (Forgejo data), Caddy reverse proxy (audiobooks.frgd.us, recipes.frgd.us, recipes.mar10s.cloud)
- **Archetype:** `server`

### brp — Bible Reading Plan
- **Role:** Bible reading plan web app
- **Key services:** Bible Reading Plan (brp.fluffy-rooster.ts.net)
- **Note:** Currently blocked (`default.nix.block` instead of `default.nix`)
- **Container:** Proxmox LXC
- **Archetype:** `lxc`

## Template

### nixos-anywhere — Provisioning Template
- **Role:** Template for provisioning new machines via nixos-anywhere
- **Archetype:** `vm`
- **Contains:** hardware.nix, disko.nix, default.nix.template
