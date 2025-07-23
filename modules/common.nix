{ pkgs, ... }: 

{
  # Generally useful packages.
  environment.systemPackages = with pkgs; [
    # Common utilities.
    file
    binutils
    ripgrep
    
    # Zipping.
    zip
    unzip

    # Etc.
    keyd
    wget
    curl
    speedtest-cli
  ];
}
