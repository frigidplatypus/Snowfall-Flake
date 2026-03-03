{ options
, config
, lib
, pkgs
, ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.virtualization.containers;
in
{
  options.frgd.virtualization.containers = with types; {
    enable = mkBoolOpt false "Whether to enable native NixOS containers (systemd-nspawn).";

    bridge = {
      name = mkOpt str "nixosbr0" "Name of the bridge interface for container networking.";
      address = mkOpt str "10.55.0.1/24" "IP address and prefix length for the bridge (CIDR).";
      subnet = mkOpt str "10.55.0.0/24" "Subnet for NAT masquerade rules.";
    };

    # Map container names to their static IPs
    containers =
      mkOpt
        (attrsOf (submodule {
          options = {
            ip = mkOpt str "" "Static IPv4 address for this container (e.g., '10.55.0.10').";
            autoStart = mkBoolOpt true "Whether to start this container automatically at boot.";
          };
        }))
        { }
        "Declarative containers to create. Each container's config is defined elsewhere (e.g., in systems/).";
  };

  config = mkIf cfg.enable {

    # IP forwarding required for container networking
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
    };

    # Create bridge for container networking
    networking.bridges.${cfg.bridge.name} = {
      interfaces = [ ];
    };
    networking.interfaces.${cfg.bridge.name} = {
      ipv4.addresses = [
        {
          address = head (lib.splitString "/" cfg.bridge.address);
          prefixLength = lib.toInt (lib.elemAt (lib.splitString "/" cfg.bridge.address) 1);
        }
      ];
    };

    # NAT and forwarding firewall rules for the container bridge subnet
    networking.firewall.extraCommands = ''
      # Allow traffic from NixOS containers on the bridge
      iptables -A INPUT -i ${cfg.bridge.name} -j ACCEPT
      iptables -A FORWARD -i ${cfg.bridge.name} -j ACCEPT
      iptables -A FORWARD -o ${cfg.bridge.name} -j ACCEPT
      # NAT outbound traffic from containers
      iptables -t nat -A POSTROUTING -s ${cfg.bridge.subnet} ! -d ${cfg.bridge.subnet} -j MASQUERADE
    '';

    # Clean up rules on firewall stop
    networking.firewall.extraStopCommands = ''
      iptables -D INPUT -i ${cfg.bridge.name} -j ACCEPT 2>/dev/null || true
      iptables -D FORWARD -i ${cfg.bridge.name} -j ACCEPT 2>/dev/null || true
      iptables -D FORWARD -o ${cfg.bridge.name} -j ACCEPT 2>/dev/null || true
      iptables -t nat -D POSTROUTING -s ${cfg.bridge.subnet} ! -d ${cfg.bridge.subnet} -j MASQUERADE 2>/dev/null || true
    '';
  };
}
