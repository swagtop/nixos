{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh = {
    enable = true;
    extraConfig = ''
      AcceptEnv COLORTERM
    '';
  };
}
