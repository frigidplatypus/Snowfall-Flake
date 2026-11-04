{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  nixpkgs.config.problems.handlers."gtk+".broken = "warn";
  nixpkgs.overlays = [
    (final: prev: {
      python3Packages = prev.python3Packages.overrideScope (
        pyfinal: pyprev: {
          patool = pyprev.patool.overridePythonAttrs (_: {
            doCheck = false;
          });
        }
      );
      patool = final.python3Packages.patool;
    })
  ];

  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # The nixos-hardware Surface kernel (microsoft-surface-common) is pinned to
  # 6.19.8, which has a Rust target-spec bug (emits `rustc-abi: x86-softfloat`
  # that rustc 1.99.0 rejects) breaking the from-source build. Override with
  # the 6.18.60 Surface-patched kernel. The linux-surface 6.18 patch set at
  # rev 668a0208 targets v6.18.60, so it applies cleanly. nixos-hardware's
  # 6.18/patches.nix is stale relative to the linux-surface rev it pins
  # (references 0017-powercap.patch, which that rev lacks), so the patch list
  # is maintained inline here against the current linux-surface 6.18 set.
  # `mkForce` wins over the hardware module's plain `boot.kernelPackages`.
  boot.kernelPackages = lib.mkForce (
    let
      nhw = inputs.nixos-hardware.outPath;
      lp = pkgs.callPackage (nhw + "/microsoft/surface/common/kernel/linux-package.nix") { };
      linux-surface = pkgs.fetchFromGitHub {
        owner = "linux-surface";
        repo = "linux-surface";
        rev = "668a0208b4a713641f7f04a73631008b1f522257";
        hash = "sha256-RnlQMpIPTE+QbFlMMwq5Qj95tlVkyRkR8WqaPlivMXM=";
      };
      version = "6.18.60";
      patchSrc = linux-surface + "/patches/6.18";
      # Patch list matching linux-surface 668a0208 patches/6.18 (16 patches).
      # structuredExtraConfig copied from nixos-hardware 6.18/patches.nix.
      p = n: {
        name = "ms-surface/${n}";
        patch = patchSrc + "/${n}.patch";
      };
      kernelPatches = [
        {
          name = "microsoft-surface-patches-linux-${version}";
          patch = null;
          structuredExtraConfig = with lib.kernel; {
            CONFIG_SURFACE_AGGREGATOR = module;
            CONFIG_SURFACE_AGGREGATOR_BUS = yes;
            CONFIG_SURFACE_AGGREGATOR_CDEV = module;
            CONFIG_SURFACE_AGGREGATOR_HUB = module;
            CONFIG_SURFACE_AGGREGATOR_REGISTRY = module;
            CONFIG_SURFACE_AGGREGATOR_TABLET_SWITCH = module;
            CONFIG_SURFACE_ACPI_NOTIFY = module;
            CONFIG_SURFACE_DTX = module;
            CONFIG_SURFACE_PLATFORM_PROFILE = module;
            CONFIG_SURFACE_HID = module;
            CONFIG_SURFACE_KBD = module;
            CONFIG_BATTERY_SURFACE = module;
            CONFIG_CHARGER_SURFACE = module;
            CONFIG_SENSORS_SURFACE_TEMP = module;
            CONFIG_SENSORS_SURFACE_FAN = module;
            CONFIG_RTC_DRV_SURFACE = module;
            CONFIG_SURFACE_HOTPLUG = module;
            CONFIG_HID_IPTS = module;
            CONFIG_HID_ITHC = module;
            CONFIG_INTEL_THC_HID = module;
            CONFIG_INTEL_QUICKSPI = module;
            CONFIG_VIDEO_DW9719 = module;
            CONFIG_VIDEO_IPU3_IMGU = module;
            CONFIG_VIDEO_IPU3_CIO2 = module;
            CONFIG_IPU_BRIDGE = module;
            CONFIG_INTEL_SKL_INT3472 = module;
            CONFIG_REGULATOR_TPS68470 = module;
            CONFIG_COMMON_CLK_TPS68470 = module;
            CONFIG_LEDS_TPS68470 = module;
            CONFIG_VIDEO_OV5693 = module;
            CONFIG_VIDEO_OV7251 = module;
            CONFIG_VIDEO_OV8865 = module;
            CONFIG_APDS9960 = module;
            CONFIG_SCSI_UFSHCD = module;
            CONFIG_SCSI_UFSHCD_PCI = module;
            CONFIG_INPUT_SOC_BUTTON_ARRAY = module;
            CONFIG_SURFACE_3_POWER_OPREGION = module;
            CONFIG_SURFACE_PRO3_BUTTON = module;
            CONFIG_SURFACE_GPE = module;
            CONFIG_SURFACE_BOOK1_DGPU_SWITCH = module;
            CONFIG_HID_SURFACE = module;
          };
        }
        (p "0001-secureboot")
        (p "0002-surface3")
        (p "0003-mwifiex")
        (p "0004-ath10k")
        (p "0005-ipts")
        (p "0006-ithc")
        (p "0007-surface-sam")
        (p "0008-surface-sam-over-hid")
        (p "0009-surface-button")
        (p "0010-surface-typecover")
        (p "0011-surface-shutdown")
        (p "0012-surface-gpe")
        (p "0013-cameras")
        (p "0014-amd-gpio")
        (p "0015-rtc")
        (p "0016-hid-surface")
      ];
    in
    lp.linuxPackage {
      inherit kernelPatches version;
      src = pkgs.linux_6_18.src;
      ignoreConfigErrors = true;
    }
  );

  # Enable fingerprint reader.
  services.blueman.enable = true;
  hardware.keyboard.qmk.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.zram-generator = enabled;
  hardware.xpadneo = enabled;

  # Grant the user read-write access to the iPod (05ac:1261) so QEMU's
  # usb-host passthrough (iPod Clickwheel Games Preservation Project) can
  # grab it without a setuid helper or per-run sudo.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="1261", MODE="0660", GROUP="users"
  '';
  boot.zfs.forceImportRoot = true;
  fonts.fontconfig.enable = true;
  services.upower = enabled;
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  powerManagement = {
    powertop.enable = true;
    # Noctalia v5 does not handle PrepareForSleep(true); lock via logind before sleep.
    powerDownCommands = "${pkgs.systemd}/bin/loginctl lock-sessions";
  };

  programs.mango = enabled;

  environment.systemPackages = with pkgs; [
    openscad
    # cura-appimage
    popsicle
    # ventoy-full
    inkscape-with-extensions
    devenv
    gh
    rclone
    nil
    mcp-nixos
    wtfutil
    acpi
    powertop
    mattermost-desktop
    remmina
    just
    pnpm
    surface-control
    nautilus
    lutris
    gamescope
    heroic
    gamemode
  ];

  frgd = {
    # Remote desktop — p5810 has no SSH access. Build locally, pull the
    # config from the result symlink.
    nr.command = "build";
    # apps.logseq = enabled;
    nix = {
      enable = true;
      github-access-token = enabled;
      extra-substituters = {
        "https://frgd-surface-kernel.cachix.org" = {
          key = "frgd-surface-kernel.cachix.org-1:pY13n7rTq2oCbPfrE3c45+2Uqfjo9tCQ+eY3NC9k0vo=";
        };
      };
    };
    system = {
      boot = {
        enable = true;
        efi = true;
      };
      zramSwap = enabled;
      zfs = enabled;
      fonts = {
        enable = true;
        fontpreview = true;
      };
    };
    apps = {
      signal = enabled;
      steam = enabled;
    };

    services = {
      zfs-replication = {
        enable = true;
        sanoid = {
          templates = {
            default = {
              hourly = 24;
              daily = 7;
              monthly = 12;
              yearly = 1;
              autosnap = true;
              autoprune = true;
            };
          };
          datasets = {
            "zroot/home_justin" = "default";
          };
        };
        syncoid = {
          enable = true;
          commands = {
            home_justin = {
              source = "zroot/home_justin";
              target = "root@nasnix.fluffy-rooster.ts.net:storage/backups/surface/home_justin";
            };
          };
        };
      };
    };
    security = {
      sops = {
        enable = true;
      };
    };
    archetypes = {
      workstation = enabled;
    };
    # virtualization = {
    #   libvirtd = {
    #     enable = true;
    #     virt-manager = enabled;
    #   };
    #   docker = enabled;
    # };
    suites = {
      desktop = {
        enable = true;
        niri = true;
      };
    };
    tools = {
      mdpdf = enabled;
      misc = enabled;
    };
  };

}
