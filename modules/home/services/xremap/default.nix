{
  services.xremap.config.modmap = [
    {
      name = "Global";
      remap = {
        "CapsLock" = "Esc";
      }; # globally remap CapsLock to Esc
    }
  ];

  # Keymap for key combo rebinds
  services.xremap.config.keymap = [
    {
      name = "Example ctrl-u > pageup rebind";
      remap = {
        "C-u" = "PAGEUP";
      };
    }
  ];
}
