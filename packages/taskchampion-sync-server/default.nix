{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "taskchampion-sync-server";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "GothenburgBitFactory";
    repo = "taskchampion-sync-server";
    rev = "main";
    fetchSubmodules = false;
    hash = "sha256-tOkM+xXtCbEZ0FhO4eDrIFJuCcsPxxwCnTJ6oI92vhQ=";
    # hash = "sha256-oXgOvvRoZpueEeWnD3jsc6y5RIAzkXzLeEe7BSErBpw=";
  };

  cargoHash = "sha256-X04kmqvulHhGNZGpTPsKt0DRzmDqpK+SQUASPVsChsI=";
  # cargoHash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";
  # cargo tests fail when checkType="release" (default)
  checkType = "debug";

  meta = {
    description = "Sync server for Taskwarrior 3";
    license = lib.licenses.mit;
    homepage = "https://github.com/GothenburgBitFactory/taskchampion-sync-server";
    maintainers = with lib.maintainers; [ mlaradji ];
    mainProgram = "taskchampion-sync-server";
  };
}
