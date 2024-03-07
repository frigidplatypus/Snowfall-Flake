{ lib, config, pkgs, ... }:
with lib;
with lib.frgd;
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.cli-apps.taskwarrior;
in {
  options.frgd.cli-apps.taskwarrior = {
    enable = mkEnableOption "Taskwarrior";
  };

  config = mkIf cfg.enable {

    programs.taskwarrior = {
      enable = true;
      config = {
        confirmation = false;
        report.minimal.filter = "status:pending";
        report.active.columns =
          [ "id" "start" "entry.age" "priority" "project" "due" "description" ];
        report.active.labels =
          [ "ID" "Started" "Age" "Priority" "Project" "Due" "Description" ];
        urgency.uda.priority.L.coefficient = -1.8;
        context.western.read = "project:Western or project:Inbox";
        context.western.write = "project:Western";
        context.home.read = "project.not:Western";
        context.home.write = "project.not:Western";
        taskd = mkIf cfg.enable (mkMerge [
          {
            server = "tasks.frgd.us:53589";
            credentials = "frgd/justin/6d45587b-6254-449c-a6c9-6f8d7989dc19";
            trust = "strict";
          }
          (mkIf (pkgs.stdenv.isLinux) {
            certificate = "/run/secrets/taskwarrior_public_cert";
            key = "/run/secrets/taskwarrior_private_key";
            ca = "/run/secrets/taskwarrior_ca_cert";
          })

          (mkIf (pkgs.stdenv.isDarwin) {
            certificate = "~/.task/keys/public.cert";
            key = "~/.task/keys/private.key";
            ca = "~/.task/keys/ca.cert";
          })
        ]);
      };
    };

    services.taskwarrior-sync.enable =
      if pkgs.stdenv.isLinux then true else false;

    home.packages = if pkgs.stdenv.isLinux then [
      pkgs.taskopen
      pkgs.taskwarrior-tui
      pkgs.tasksh
      pkgs.vit
      (pkgs.python3.withPackages
        (python-pkgs: [ python-pkgs.tasklib python-pkgs.bugwarrior ]))
    ] else [
      pkgs.taskwarrior-tui
      pkgs.tasksh
      pkgs.vit
      (pkgs.python3.withPackages
        (python-pkgs: [ python-pkgs.tasklib python-pkgs.bugwarrior ]))
    ];
  };
}
