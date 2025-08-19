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
      sha256 = ""; # Set empty initially to get the correct hash from build error
    };
    
    vendorHash = ""; # Set empty initially to get the correct hash from build error
  });
}
