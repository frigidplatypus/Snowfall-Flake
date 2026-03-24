{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.git;
  user = config.frgd.user;
in
{
  options.frgd.tools.git = with types; {
    enable = mkBoolOpt false "Whether or not to enable Git.";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
    internalGitKey = mkBoolOpt false "Install SSH key for internal git server.";
  };

  config =
    mkIf cfg.enable {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = cfg.userName;
            email = cfg.userEmail;
          };
          init = {
            defaultBranch = "main";
          };
          pull = {
            rebase = true;
          };
          push = {
            autoSetupRemote = true;
          };
          core = {
            whitespace = "trailing-space,space-before-tab";
          };
        };
        lfs = enabled;
      };
      home.packages = with pkgs; [
        git
        lazygit
      ];
    }
    // mkIf cfg.internalGitKey {
      programs.ssh.enable = true;
      sops.secrets.git_server_ssh_key = { };
      programs.ssh.matchBlocks."git.${tailnet}" = {
        hostname = "git.${tailnet}";
        user = "git";
        identityFile = config.sops.secrets.git_server_ssh_key.path;
        addKeysToAgent = "yes";
      };
    };
}
