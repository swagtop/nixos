{
  lib,
  pkgs,
  self,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    self.packages.${pkgs.stdenv.hostPlatform.system}.bitwig-studio
    yabridge
    yabridgectl
    libsndfile
    desktop-file-utils
  ];

  environment.variables = {
    CLAP_PATH = "${lib.makeSearchPath "lib/clap" [
      pkgs.vital
      # pkgs.chow-tape-model
      self.packages.${pkgs.stdenv.hostPlatform.system}.locd
    ]}";
  };

  security.rtkit.enable = lib.mkForce false;
  systemd.services.rtkit = {
    enable = false;
    unitConfig = {
      RefuseManualStart = true;
      RefuseManualStop = true;
    };
  };

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "soft";
      value = "99999";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "99999";
    }
  ];

  services.udev.extraRules = ''
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';
}
