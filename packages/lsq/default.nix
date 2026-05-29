{ pkgs, fetchFromGitHub, ... }:

pkgs.buildGoModule {
  pname = "lsq";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "jrswab";
    repo = "lsq";
    rev = "55c3f5476af4b075e5100187a69485ef90905f19";
    hash = "0072w443rw3adsmr8xclnz05plgips7y1pb8scg46yyjcrx4qjf2";
  };

  vendorHash = "sha256-ZSyfmwhc0FhQ+lLNBVNvJZB/OfR2zwGR6j1ddpY3QxQ=";

  buildInputs = [ pkgs.git ];

  meta = {
    description = "A Logseq command-line interface";
    homepage = "https://github.com/jrswab/lsq";
    mainProgram = "lsq";
  };
}
