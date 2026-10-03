# bibletime 3.1.1 fails against Qt 6.11 (C++20): key-class comparison
# helpers return bool but the tuple three-way comparison leaks
# std::strong_ordering. Backport the upstream header fix
# (bibletime@378c83d1), minus its cmake cxx_std bump — Qt already
# forces >=C++20. Drop when nixpkgs merges NixOS/nixpkgs#569398
# (bibletime 3.2.0) and the pinned nixpkgs includes it.
{ ... }:
final: prev:
{
  bibletime = prev.bibletime.overrideAttrs (
    finalAttrs: previousAttrs: {
      patches = (previousAttrs.patches or [ ]) ++ [
        ./cxx20-fix.patch
      ];
    }
  );
}
