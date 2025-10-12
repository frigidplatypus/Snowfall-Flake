# GitHub Access Token with SOPS-nix

This guide explains how to configure a GitHub access token for Nix using SOPS encryption, based on [NixOS/nix#6536](https://github.com/NixOS/nix/issues/6536).

## Overview

The GitHub access token allows Nix to:
- Access private repositories during builds
- Increase GitHub API rate limits for fetching public repositories
- Clone repositories using authenticated HTTPS

## Configuration

### 1. Generate GitHub Personal Access Token

1. Go to [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select scopes based on your needs:
   - `repo` - for private repository access
   - `public_repo` - for public repository access only
4. Copy the generated token

### 2. Add Token to SOPS File

Add your GitHub token to your SOPS secrets file:

```yaml
github_access_token: "ghp_your_token_here"
```

Encrypt the file using SOPS:
```bash
sops -e -i /path/to/your/secrets.yaml
```

### 3. Enable in NixOS Configuration

Add to your system configuration:

```nix
{
  frgd = {
    nix = {
      enable = true;
      github-access-token.enable = true;
    };
    
    # Alternative: Enable via SOPS security module  
    security.sops = {
      enable = true;
      github_access_token.enable = true;
    };
  };
}
```

**Example for a specific system:**
```nix
# In systems/x86_64-linux/hostname/default.nix
{ lib, ... }:
with lib.frgd;
{
  frgd = {
    nix.github-access-token = enabled;
    # ... other configuration
  };
}
```

### 4. Rebuild System

Apply the configuration:
```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

## How It Works

The configuration uses SOPS templates and the `!include` directive in `nix.extraOptions`:

1. **SOPS Secret**: Stores the encrypted GitHub token
2. **SOPS Template**: Creates a file containing `access-tokens = github.com=<token>`
3. **Nix Include**: Uses `!include` to include the template file in `nix.conf`

```nix
# The generated template file contains:
access-tokens = github.com=ghp_your_actual_token_here

# nix.conf includes it via:
!include /run/secrets/github-access-tokens
```

This approach follows the solution from [NixOS/nix#6536](https://github.com/NixOS/nix/issues/6536) where `@jlesquembre` demonstrated using `!include` with SOPS-nix.

## Usage Examples

### In Flake Inputs

```nix
{
  inputs = {
    # Private repository
    my-private-repo = {
      url = "github:username/private-repo";
      flake = false;
    };
    
    # Public repository (benefits from higher rate limits)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
}
```

### In Derivations

```nix
pkgs.fetchFromGitHub {
  owner = "username";
  repo = "private-repo";
  rev = "commit-hash";
  sha256 = "sha256-hash";
}
```

## Security Notes

- The token file is created with mode `0400` (read-only for owner)
- Only the configured user can read the token file  
- The token is automatically available to all Nix operations system-wide
- Consider using fine-grained personal access tokens for better security

## Troubleshooting

### Verify Token Configuration
```bash
# Check if template file exists and contains token
sudo cat /run/secrets/github-access-tokens

# Verify nix configuration includes the file
nix show-config | grep -A5 -B5 access-tokens

# Test access to a private repo
nix flake show github:username/private-repo
```

### Common Issues

1. **Permission denied**: Ensure the token has appropriate scopes
2. **File not found**: Verify SOPS decryption is working
3. **Rate limiting**: Token should increase limits; check token validity

## Multiple Tokens

For multiple Git hosting services, you can extend the SOPS template:

```nix
sops.templates.access_tokens = {
  content = ''
    access-tokens = github.com=${config.sops.placeholder.github_access_token} gitlab.com=${config.sops.placeholder.gitlab_access_token}
  '';
  mode = "0440"; 
  group = config.users.groups.keys.name;
};
```

Or use separate include files and multiple `!include` statements in `nix.extraOptions`.