{ self, pkgs, lib, ... }:

# Define preferred GNOME settings.
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
      "org/gnome/desktop/applications/terminal" = {
        exec = "alacritty";
        exec-arg = "--";
      };
      "org/gnome/desktop/default-applications/terminal" = {
        exec = "alacritty";
        exec-arg = "--";
      };
    };
  }];

  shellAliases = {
    # Open nautilus in current directory.
    naut = "nautilus .";
  };
in
{
  nixpkgs.config.allowUnfree = true;

  # Enable GNOME, GDM.
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.xserver.desktopManager.gnome = {
    enable = true;
  };
  programs.xwayland.enable = true;

  programs.sway.enable = true;

  # Use preferred GNOME settings.
  programs.dconf.profiles.user.databases = gnomeSettings;
  programs.dconf.profiles.gdm.databases = gnomeSettings;
  environment.variables = {
    GNOME_SHELL_SLOWDOWN_FACTOR = "0.75";
    COLORTERM = "truecolor";
  };

  programs.ssh.extraConfig = ''
    SendEnv COLORTERM
  '';

  # Enable web browser.
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    # Terminal emulator, wrapping in shell script for config.
    (pkgs.writeShellScriptBin "alacritty" ''
      exec ${pkgs.unstable.alacritty}/bin/alacritty \
      --config-file ${self}/configs/alacritty/alacritty.toml "$@"
    '' )
    unstable.alacritty # For the .desktop entry.

    # Graphics.
    unstable.blender-hip
    inkscape
    typst

    # Disk utility.
    gparted

    # Libadwaita theme for legacy GTK-3 applications.
    adw-gtk3

    # Media.
    vlc

    # Wayland and other useful packages.
    wayland
    xwayland
    wayland-protocols
    linux-firmware
  ];

  programs.bash.shellAliases = shellAliases;

  # Extra fonts.
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    nerd-fonts.recursive-mono
    nerd-fonts._0xproto
    texlivePackages.latex-fonts
  ];
}
