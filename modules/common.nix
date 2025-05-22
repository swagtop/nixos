{ pkgs, ... }: 

{
  # Generally useful packages.
  environment.systemPackages = with pkgs; [
    # Common utilities.
    file
    binutils
    
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
