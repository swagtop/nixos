{ pkgs, lib, ... }:
let
  nativeStdenv = (pkgs.stdenvAdapters.impureUseNativeOptimizations pkgs.stdenv);
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Compile all packages locally.
  # nix.settings.substitute = false;

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set hostname. 
  networking.hostName = "gamebeast";
  
  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;  
    
  # Kernel.
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.linuxPackages_latest.kernel.override (old: {
      stdenv = nativeStdenv;
    })
  );

  nixpkgs.overlays = [
    # Building GNOME stuff with native optimizations.
    (final: prev:
    let
      gtk4 = prev.gtk4.override {
        stdenv = nativeStdenv;
      };
    in {
      gnome-desktop = prev.gnome-desktop.override {
        stdenv = nativeStdenv;
      };
      gnome-session = prev.gnome-session.override {
        inherit (final) gnome-desktop;
        stdenv = nativeStdenv;
      };
      mutter = prev.mutter.override {
        inherit gtk4;
        inherit (final) gnome-desktop;
        stdenv = nativeStdenv;
      };
      gnome-shell = prev.gnome-shell.override {
        inherit gtk4;
        inherit (final) mutter gnome-desktop;
        stdenv = nativeStdenv;
        gjs = prev.gjs.override {
          stdenv = nativeStdenv;
        };
      };
    })
  ];
  
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [
      "amdgpu"
      "modesetting"
    ];
  };
  services.libinput.enable = true;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
      amdvlk
      libvdpau-va-gl
      intel-media-driver
    ];
    enable32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-vaapi-driver
    ];
  };
  hardware.amdgpu = {
    legacySupport.enable = true;
    amdvlk = {
      enable = true;
      package = pkgs.amdvlk;
      support32Bit.enable = true;
      settings = {
        AllowVkPipelineCachingToDisk = 1;
        EnableVmAlwaysValid = 1;
        IFH = 0;
        IdleAfterSubmitGpuMask = 1;
        ShaderCacheMode = 1;
      };
    };
  };

  environment.variables = {
    # AMD stuff
    AMD_VULKAN_ICD = "RADV";
    VK_ICD_FILENAMES = "${pkgs.mesa}/share/vulkan/icd.d/radeon_icd.x86_64.json";
    ROC_ENABLE_PRE_VEGA = "1";

    # Intel stuff
    LIBVA_DRIVER_NAME = "iHD";
  };
  services.udev.enable = true;

  environment.systemPackages = with pkgs; [
    libvirt
    rocmPackages.rocm-smi # AMD GPU Monitoring
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };
  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    # pulse.enable = true;

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  programs.dconf.enable = true;

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
    packages = with pkgs; [
      spotify
      transmission_4-gtk
    ];
  };


  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings = {
        # dns = [ "10.10.10.1" ];
        registry-mirrors = [ "https://mirror.gcr.io" ];
      };
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Some programs need SUID wrappers, can be configured further or are started 
  # in user sessions. 
  # programs.mtr.enable = true; 
  # programs.gnupg.agent = { 
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.steam = {
    localNetworkGameTransfers.openFirewall = true;
  };

  # List services that you want to enable:
  programs.virt-manager = {
    enable = true;
    package = pkgs.virt-manager;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
      swtpm.enable = true;
      runAsRoot = false;
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.dbus.enable = true;
  services.geoclue2.enable = false;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
      	ids = ["*"];
      	settings = {
          main = { capslock = "esc"; };
        };
      };
    };
  };

  services.mullvad-vpn.enable = true;

  # Flatpak and flathub, and adw-gtk3 theme for flatpaks.
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    # script = ''
    #   flatpak remote-add --if-not-exists \
    #   flathub https://flathub.org/repo/flathub.flatpakrepo
    # '';
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 
    8000 
    # 16261
    # 16262
  ];
  networking.firewall.allowedUDPPorts = [ 
    # 16261
    # 16262
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.04"; # Did you read the comment?
}
