{
  pkgs,
  self,
  ...
}:

let
  inherit (builtins) mapAttrs;
  inherit (pkgs.stdenv.hostPlatform) system;

  # ANSI escape codes for changing colors of terminal text.
  # https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124
  colors = mapAttrs (name: value: ''\[\x1b[${value}m\]'') {
    red = "1;31";
    green = "1;32";
    cyan = "1;36";
    orange = "1;33";
  };

  # Unicode escape sequences for symbols for proper character width when printed.
  symbols = {
    "€" = ''\U000020AC'';
    "£" = ''\U000000A3'';
  };

  mkPS1 =
    color: symbol:
    let
      # Adds name of Nix shell to PS1, if in one.
      devShell = "\${name:+${colors.cyan}[$name]${color} }";

      # Adds name of hostname if connected through SSH.
      hostname = "\${SSH_CONNECTION:+${colors.orange}@$HOSTNAME${color}}";

      # Don't end with '\]', or color messes up on line-wrap.
      # This only occurs with unicode characters longer than 1 byte. I have no
      # idea why this happens, but really we don't need to indicate an ending
      # here, as there are no more printed characters in the PS1.
      resetColor = ''\[\x1b[0m'';
    in
    # Expand unicode characters by using a $'' string.
    "$'${color}\\u${hostname} ${devShell}\\w ${symbol} ${resetColor}'";

  promptInit = ''
    # Set red prompt only for root.
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
