{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
}:

let
  # Python environment with required runtime dependency
  pythonEnv = python3.withPackages (ps: [ ps.tasklib ]);
in
stdenvNoCC.mkDerivation {
  pname = "taskpirate";
  # Upstream uses branch master and provides simple scripts; pin a rev and update as needed
  version = "unstable-2024-12-05";

  src = fetchFromGitHub {
    owner = "tbabej";
    repo = "taskpirate";
    rev = "master";
    sha256 = "sha256-HBf6ofhhsAbY0y0x+lb2PYEWhbpJFyJKOS0E/mzz9us=";
  };

  nativeBuildInputs = [ ];

  # No build system; just install the two hook scripts
  installPhase = ''
    		runHook preInstall
    		install -d $out/bin
    		install -m0755 on-add-pirate $out/bin/on-add-pirate
    		install -m0755 on-modify-pirate $out/bin/on-modify-pirate

    			# Ensure scripts use our Python with tasklib available
    			substituteInPlace $out/bin/on-add-pirate \
    				--replace "#!/usr/bin/env python3" "#!${pythonEnv}/bin/python3"
    			substituteInPlace $out/bin/on-modify-pirate \
    				--replace "#!/usr/bin/env python3" "#!${pythonEnv}/bin/python3"

    		runHook postInstall
    	'';

  meta = with lib; {
    description = "Pluggable system for tasklib-based Taskwarrior hooks";
    homepage = "https://github.com/tbabej/taskpirate";
    # Upstream LICENCE is MIT
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
