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
        context.western.read = "project:Western";
        context.western.write = "project:Western";
        context.home.read = "project.not:Western";
        context.home.write = "project.not:Western";
        taskd = mkIf cfg.enable (mkMerge [

          {

            server = "tasks.frgd.us:53589";
            credentials = "frgd/justin/7c358284-adbb-4c7d-baaf-4c470fb1f2d2";
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
    ] else [
      pkgs.taskwarrior-tui
      pkgs.tasksh
      pkgs.vit
    ];
  };
}
