{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.aerc;
in
{
  options.frgd.cli-apps.aerc = with types; {
    enable = mkBoolOpt false "aerc";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      w3m
      # bat # Uncomment if you want to use bat for syntax highlighting
    ];
    sops.secrets.jk_app_password = { };
    accounts.email.accounts.jk = {
      realName = "Justin Martin";
      address = "justin@justinandkathryn.com";
      flavor = "gmail.com";
      aerc = enabled;
      primary = true;
      passwordCommand = "cat ${config.sops.secrets.jk_app_password.path}";
    };
    accounts.email.accounts.gmail = {
      realName = "Justin Martin";
      address = "jus10mar10@gmail.com";
      flavor = "gmail.com";
      aerc = enabled;
      primary = false;
      passwordCommand = "cat ${config.sops.secrets.gmail_app_password.path}";
    };
    programs.aerc = {
      enable = true;

      # Allow aerc config in the nix store
      extraConfig = {
        filters = {
          "text/html" = "w3m -T text/html -o display_link_number=1";
          "text/plain" = "colorize"; # Or "colorize" if you prefer built-in
          # "text/*" = "bat -fP"; # Fallback for other text types
        };
        general = {
          "unsafe-accounts-conf" = true;
          "default-save-path" = "~/Downloads";
          "log-file" = "~/.local/share/aerc/aerc.log";
          "use-terminal-pinentry" = true;
        };
        ui = {
          "folders-sort" = "INBOX,Archive,*";
          "index-format" = "%f %t %-20.20s %?C?(%C) ?%S";
          "timestamp-format" = "%Y-%m-%d %H:%M";
          "this-year-time-format" = "%m-%d %H:%M";
        };
        compose = {
          "editor" = "nvim";
        };
      };
    };
  };
}
