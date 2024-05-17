{ lib, ... }:
with lib;
with lib.frgd; {
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };
  };
}
