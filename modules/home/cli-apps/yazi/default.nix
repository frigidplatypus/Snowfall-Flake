{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.yazi;
in
{
  options.frgd.cli-apps.yazi = {
    enable = mkEnableOption "yazi";
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      extraPackages = with pkgs; [
        fzf
        ripgrep
        bat
        fd
        jq
        coreutils
        findutils
        gawk
        git
        util-linux
        diffutils
        piper
        ouch
      ];
      plugins = with pkgs.yaziPlugins; {
        git = git;
        sudo = sudo;
        mount = mount;
        diff = diff;
        piper = piper;
        ouch = ouch;
      };

      # yaziPlugins = {
      #   enable = true;
      #   plugins = {
      #     glow.enable = true;
      #     ouch.enable = true;
      #     smart-filter.enable = true;
      #     system-clipboard.enable = true;
      #     starship.enable = true;
      #     jump-to-char = {
      #       enable = true;
      #       keys.toggle.on = [ "F" ];
      #     };
      #     relative-motions = {
      #       enable = true;
      #       show_numbers = "relative_absolute";
      #       show_motion = true;
      #     };
      #   };
      # };
      settings = { };
    };
  };
}
