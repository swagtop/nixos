{ self, pkgs, ... }:

let
  # Adds name of Nix shell to PS1, if in one.
  devShell = "\${name:+[$name] }";
  # Adds name of hostname if connected through SSH.
  ssh = "\${SSH_CONNECTION:+@$HOSTNAME}";
  # ANSI escape codes for changing colors of terminal text.
  reset = ''\[\e[0;0m\]'';
  green = ''\[\e[1;32m\]'';
  red = ''\[\e[1;31m\]'';
  cyan = ''\[\e[1;36m\]'';
  orange = ''\[\e[1;33m\]'';

  # First, green, red prompts for users and root.
  # Second, bash function enabling filesystem navigation with yazi.
  promptInit = ''
    if [ "$EUID" -ne 0 ]
    then
      # Normal user, green prompt
      PS1='${green}\u${orange}${ssh} ${cyan}${devShell}${green}\w € ${reset}'
    else
      # Root, red prompt
      PS1='${red}\u${orange}${ssh} ${cyan}${devShell}${red}\w £ ${reset}'
    fi

    y() {
      tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
      cwd=""
      yazi "$@" --cwd-file="$tmp"

      # Read the content of the temporary file into cwd
      cwd="$(command cat -- "$tmp")"

      # If cwd is non-empty and different from $PWD, change directory
      if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
      fi

      # Remove the temporary file
      rm -f -- "$tmp"
    }

  '';

  # Quick shortcuts.
  shellAliases = {
    # Zellij.
    zj = "zellij";

    # Lazygit.
    lg = "lazygit";

    # Fastfetch.
    ff = "fastfetch";

    # Pipes.
    pipes = "pipes.sh -t 0 -c 1 -c 2 -c 3 -c 4 -c 5 -c 6 -c";

    # Search nixpkgs with television and nix-search-tv.
    nixpkgs = "tv nixpkgs";
  };
in
{
  # TUI file manager / filesystem navigator.
  programs.yazi = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Pseudo-ide combo.
    zellij
    helix

    # TUI git manager.
    lazygit

    # TUI nix-search interface.
    television
    nix-search-tv

    # ISO image burner.
    caligula

    # Fluff.
    fastfetch
    pipes
    btop
  ];

  # Add shell aliases.
  programs.bash = {
    promptInit = promptInit;
    shellAliases = shellAliases;
  };

  # Set Helix as default editor.
  environment.variables = {
    EDITOR = "hx";
  };
}
