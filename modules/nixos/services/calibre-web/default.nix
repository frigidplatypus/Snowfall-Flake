{ lib, ... }:
with lib;
{
  # Note: This module was intentionally moved into
  # `systems/x86_64-linux/books/default.nix` and is now a noop stub.
  # If you want a central module for calibre-web again, move the
  # `services.calibre-web` block from the system file back here.
  options = { };
  config = { };
}
