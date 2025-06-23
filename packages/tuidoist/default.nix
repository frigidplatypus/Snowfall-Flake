{
  pkgs,
  fetchFromGitHub,
  ...
}:
let

  repo = fetchFromGitHub {
    owner = "frigidplatypus";
    repo = "tuidoist";
    rev = "main";
    sha256 = "sha256-+p+gExVLpsIvIXZO50uE8b10ffy6yfJA+XaB5jARXxg=";
  };
in

pkgs.python3Packages.buildPythonApplication {
  pname = "tuidoist";
  version = "0.7.0";
  format = "pyproject";
  src = repo;
  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
  ];
  propagatedBuildInputs = with pkgs.python3Packages; [
    textual
    (pkgs.python3Packages.todoist-api-python.overridePythonAttrs (oldAttrs: {
      version = "3.1.0";
      src = pkgs.fetchPypi {
        pname = "todoist_api_python";
        version = "3.1.0";
        hash = "sha256-fK1zL1ikvfvRwHOhqL4cG04TrgyL4hC7eED7ugbrmHw=";
      };
      nativeBuildInputs = with pkgs.python3Packages; [ hatchling ];
      propagatedBuildInputs = with pkgs.python3Packages; [
        annotated-types
        dataclass-wizard
      ];
      doCheck = false;
    }))
  ];
  meta = with pkgs.lib; {
    description = "A modal TUI for viewing Todoist tasks using Textual";
    homepage = "https://github.com/frigidplatypus/tuidoist";
    license = licenses.mit;
    maintainers = [ ];
  };
}
