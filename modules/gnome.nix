{ lib, ... }:

let 
  gnomeSettings = [{
    settings = {
      "org/gnome/desktop/peripherals/keyboard" = {
        repeat-interval = lib.gvariant.mkUint32 30;
        delay = lib.gvariant.mkUint32 250;
      };
      "org/gnome/desktop/interface" = {
        enable-hot-corners = false;
        gtk-enable-primary-paste = false;
        gtk-theme = "adw-gtk3-dark";
        color-scheme = "prefer-dark";
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
      };
      "org/gnome/settings/daemon/plugins/color" = {
        night-light-enable = true;
      };
      "org/gnome/desktop/peripherals/mouse" = {
        speed = lib.gvariant.mkDouble "-1.0";
      };
      "org/gnome/desktop/background" = {
        primary-color = "#000000";
      };
    };
  }];
in
{
  # Enable GNOME, GDM.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Use GNOME settings.
  programs.dconf.profiles.user.databases = gnomeSettings;
  programs.dconf.profiles.gdm.databases = gnomeSettings;
  environment.variables = {
    GNOME_SHELL_SLOWDOWN_FACTOR = "0.75";
  };
}
