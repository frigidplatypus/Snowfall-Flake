{ pkgs, fetchFromGitHub, ... }:

pkgs.buildGoModule {
  pname = "lsq";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "jrswab";
    repo = "lsq";
    rev = "55cd0b26395a91d90c54d154ecae41947e89c519";
    hash = "sha256-sgCYjkV39dG40v4KuX1BOCr5FIrB66l2oueBzHeoNwI=";
  };

  vendorHash = "sha256-ZSyfmwhc0FhQ+lLNBVNvJZB/OfR2zwGR6j1ddpY3QxQ=";

  buildInputs = [ pkgs.git ];

  meta = {
    description = "A Logseq command-line interface";
    homepage = "https://github.com/jrswab/lsq";
    mainProgram = "lsq";
  };
}
