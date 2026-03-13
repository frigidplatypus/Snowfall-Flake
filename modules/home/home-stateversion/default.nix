# Ensure `home.stateVersion` has a safe default for all Home Manager configs.
{ lib, ... }:
with lib;
{
  config = {
    home.stateVersion = mkDefault "24.05";
  };
}
