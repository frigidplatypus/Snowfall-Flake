{ channels, ... }:

final: prev:

let
  # Update this commit hash periodically to get latest changes
  # Latest as of 2025-05-08: add Dockerfile and GitHub action for building image
  caddy-tailscale-rev = "642f61fea3ccc6b04caf381e2f3bc945aa6af9cc";
in
{
  caddy = prev.caddy.overrideAttrs (old: {
    pname = "caddy-tailscale";

    src = prev.fetchFromGitHub {
      owner = "tailscale";
      repo = "caddy-tailscale";
      rev = caddy-tailscale-rev;
      sha256 = "sha256-oVywoZH7+FcBPP1l+kKjh+deiI6+H/N//phAuiSC4tc="; # Set empty initially to get the correct hash from build error
    };

    vendorHash = "sha256-eed3AuRhRO66xFg+447xLv7otAHbzAUuhxMcNugZMOA="; # Set empty initially to get the correct hash from build error
  });
}
