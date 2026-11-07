{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thedb = {
    isNormalUser = true;
    description = "thedb";
    extraGroups = [
      "networkmanager"
      "wheel"
      "keyd"
      "realtime"
      "audio"
      "video"
      "libvirtd"
      "qemu-libvirtd"
      "nix"
    ];
  };
}
