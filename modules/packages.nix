{ pkgs, ... }: 

{
  # Global packages.
  environment.systemPackages = with pkgs; [
    # Nix env stuff.
    nix-search-cli
    nix-index

    # Dev env stuff.
    alacritty
    zellij
    helix
    yazi
    lazygit
    vscode
    git
    gh
    valgrind

    # Language servers and co.
    rust-analyzer
    clang-tools
    lldb
    nil
    bash-language-server

    # Compiler stuff.
    gnumake
    rustup
    gcc
    pkg-config
    steam-run
    man-pages
    man-pages-posix
    glibc.dev

    # Python and its packages, relevant tools.
    uv
    (python312.withPackages (ps: with ps; [
      pyyaml
      python-lsp-ruff
    ]))

    # System tools.
    keyd
    wget
    zip
    unzip
    fastfetch
    btop
    caligula
    pipes

    # Gnome stuff.
    gparted
    flatpak
    adw-gtk3
    wayland
    xwayland
    wayland-protocols
    linux-firmware
  ];

  # Extra fonts.
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];
}
