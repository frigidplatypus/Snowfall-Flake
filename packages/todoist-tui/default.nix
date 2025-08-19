{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "todoist-tui";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "drewzemke";
    repo = "todoist-tui";
    rev = "main"; # or specify a specific commit/tag
    sha256 = lib.fakeSha256; # Replace with actual hash after first build attempt
  };

  cargoHash = lib.fakeSha256; # Replace with actual hash after first build attempt

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = with lib; {
    description = "A terminal user interface for Todoist";
    homepage = "https://github.com/drewzemke/todoist-tui";
    license = licenses.mit; # Verify the actual license from the repository
    maintainers = [ ]; # Add your maintainer info if desired
    platforms = platforms.unix;
  };
}
