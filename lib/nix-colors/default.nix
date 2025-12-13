{
  inputs,
  snowfall-inputs,
  lib,
  ...
}:
let
  # Prefer a `stylix` input when available, but fall back to the
  # existing `nix-colors` input so this module remains compatible.
  useStylix = builtins.hasAttr "stylix" inputs;
  colors = if useStylix then inputs.stylix else inputs.nix-colors;
  # Helper: convert a hex RRGGBB string (without '#') into an rgba(R,G,B,A)
  # string. Alpha is a floating value between 0.0 and 1.0.
  hexDigit =
    d:
    if d == "0" then
      0
    else if d == "1" then
      1
    else if d == "2" then
      2
    else if d == "3" then
      3
    else if d == "4" then
      4
    else if d == "5" then
      5
    else if d == "6" then
      6
    else if d == "7" then
      7
    else if d == "8" then
      8
    else if d == "9" then
      9
    else if d == "a" || d == "A" then
      10
    else if d == "b" || d == "B" then
      11
    else if d == "c" || d == "C" then
      12
    else if d == "d" || d == "D" then
      13
    else if d == "e" || d == "E" then
      14
    else if d == "f" || d == "F" then
      15
    else
      0;
  hexPairToDec = p: (hexDigit (builtins.substring 0 1 p)) * 16 + hexDigit (builtins.substring 1 1 p);
  _hexToRgba =
    hex: alpha:
    let
      r = hexPairToDec (builtins.substring 0 2 hex);
      g = hexPairToDec (builtins.substring 2 2 hex);
      b = hexPairToDec (builtins.substring 4 2 hex);
    in
    "rgba(${toString r},${toString g},${toString b},${toString alpha})";
in
{
  # Try to select a gruvbox-like scheme from stylix if present, falling
  # back to the old nix-colors scheme. The exact attribute names for
  # stylix vary between implementations, so check common shapes.
  colorScheme =
    if useStylix then
      if builtins.hasAttr "colorSchemes" inputs.stylix then
        inputs.stylix.colorSchemes.gruvbox-dark-medium or inputs.stylix.colorSchemes.gruvbox
      else if builtins.hasAttr "schemes" inputs.stylix then
        inputs.stylix.schemes.gruvbox-dark-medium or inputs.stylix.schemes.gruvbox
      else
        # Unknown stylix shape — fall back to nix-colors if present
        (
          if builtins.hasAttr "nix-colors" inputs then
            inputs.nix-colors.colorSchemes.gruvbox-dark-medium
          else
            null
        )
    else
      inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

  # Export the existing helper for other modules
  hexToRgba = _hexToRgba;
}
