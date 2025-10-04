# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "servtop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thedb = {
    isNormalUser = true;
    description = "thedb";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    steamcmd
    zulu
    conspy
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    postgresql
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  networking.firewall.allowedUDPPorts =
    [ 53 80 443 16261 16262 ] ++ [ 25565 19132 ];
  networking.firewall.allowedTCPPorts =
    [ 53 80 443 14341 8096 8920 ] ++ [ 7777 ] ++ [ 25565 19132 ];
  # networking.interfaces.enp1s0 = {
  #   ipv4.addresses = [{
  #     address = "10.10.11.2";
  #     prefixLength = 24;
  #   }];
  #   useDHCP = false;
  # };
  # networking.defaultGateway = "10.10.11.1";
  # networking.nameservers = [
  #   "1.1.1.1"
  # ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    zulu
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "servtop";
        "netbios name" = "servtop";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "10.10.10. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "Bad User";
      };
      "delemappppe" = {
        "path" = "/home/thedb/delemappe";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0666";
        "directory mask" = "0777";
        "force user" = "thedb";
        "force group" = "nogroup";
      };
      "jellyfin-music" = {
        "path" = "/srv/data/media/music";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0666";
        "directory mask" = "0777";
        "force user" = "thedb";
        "force group" = "nogroup";
      };
      "jellyfin-movies" = {
        "path" = "/srv/data/media/movies";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0666";
        "directory mask" = "0777";
        "force user" = "thedb";
        "force group" = "nogroup";
      };
      "jellyfin-shows" = {
        "path" = "/srv/data/media/shows";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0666";
        "directory mask" = "0777";
        "force user" = "thedb";
        "force group" = "nogroup";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  services.jellyfin = {
    dataDir = "/srv/data/media";
    user = "thedb";
    enable = true;
    # openFirewall = true;
  };

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # services.seafile = {
  #   enable = true;

  #   adminEmail = "thedb11@gmail.com";
  #   initialAdminPassword = "change this later!";

  #   ccnetSettings.General.SERVICE_URL = "https://mb.spirre.vip";

  #   seafileSettings = {
  #     fileserver = {
  #       host = "unix:/run/seafile/server.sock";
  #     };
  #   };
  # };

  security.acme = {
    acceptTerms = true;
    defaults.email = "thedb11@gmail.com";
  };

  services.minecraft-server = {
    enable = true;
    eula = true;
    package = pkgs.papermc;
    openFirewall = true;
    declarative = false;
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "jf.spirre.vip" = {
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;
          };
        };
        forceSSL = true;
        enableACME = true;
      };
      "mus.spirre.vip" = {
        root = "/var/www/mus.spirre.vip";

        extraConfig = ''
          error_page 403 /403.html;
          error_page 404 /404.html;
        '';

        locations."/403.webp".root= "/var/www/errors/";
        locations."/403.html" = {
          root = "/var/www/errors/";
          extraConfig = ''
            internal;
          '';
        };
        locations."/404.webp".root= "/var/www/errors/";
        locations."/404.html" = {
          root = "/var/www/errors/";
          extraConfig = ''
            internal;
          '';
        };

        locations."/" = {
          index = "index.html";
          extraConfig = ''
            allow 10.10.10.0/24;
            deny all;
          '';
        };

        forceSSL = true;
        enableACME = true;
      };
      "cache.spirre.vip" = {
        locations."/".proxyPass =
          "http://${config.services.nix-serve.bindAddress}:"
            + "${toString config.services.nix-serve.port}";

        forceSSL = true;
        enableACME = true;
      };
    };
  };
}
