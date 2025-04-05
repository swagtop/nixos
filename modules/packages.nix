{ pkgs, ... }: 

{
  # Generally useful packages.
  environment.systemPackages = with pkgs; [
    # Zipping.
    zip
    unzip

    # Etc.
    keyd
    wget
    curl
    speedtest-cli
    file
  ];
}
