{
  pkgs,
  self,
  ...
}:

let
  inherit (builtins) mapAttrs;
  inherit (pkgs.stdenv.hostPlatform) system;

  # ANSI escape codes for changing colors of terminal text.
  colors = mapAttrs (name: value: ''\[${value}\]'') {
    green = ''\e[1;32m'';
    red = ''\e[1;31m'';
    cyan = ''\e[1;36m'';
    orange = ''\e[1;33m'';
    reset = ''\e[0m'';
  };

  # Unicode escape sequences for symbols for proper character width when printed.
  symbols = {
    "€" = ''\U000020AC'';
    "£" = ''\U000000A3'';
  };

  # Adds name of Nix shell to PS1, if in one.
  devShell = "\${name:+${colors.cyan}[$name] }";

  # Adds name of hostname if connected through SSH.
  ssh = "\${SSH_CONNECTION:+${colors.orange}@$HOSTNAME}";

  mkPS1 =
    color: symbol:
    let
      PS1 = ''${color}\u${ssh} ${devShell}${color}\w ${symbol}${colors.reset} '';
    in
    # Make sure unicode characters are expanded properly.
    "$'${PS1}'";

  # First, green, red prompts for users and root.
  # Second, bash function enabling filesystem navigation with yazi.
  promptInit = ''
    case "$EUID" in
      0) PS1=${mkPS1 colors.red symbols."£"};;
      *) PS1=${mkPS1 colors.green symbols."€"};;
    esac

    function y() {
    	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    	command yazi "$@" --cwd-file="$tmp"
    	IFS= read -r -d "" cwd < "$tmp"
    	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    	command rm -f -- "$tmp"
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
  programs.yazi.enable = true;

  environment.systemPackages = with pkgs; [
    # Pseudo-ide combo.
    self.packages.${system}.zellij
    self.packages.${system}.helix

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
