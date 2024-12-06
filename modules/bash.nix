{ ... }:
{
  # Bash aliases.
  programs.bash.shellAliases = {
    # Update.
    ud = "sudo nix flake update --flake ~/.config/flake";

    # Rebuild.
    rb = "sudo nixos-rebuild switch --flake ~/.config/flake";

    # Edit config, hardware config, and modules.
    ec = "hx ~/.config/flake/hosts/$(hostname)/configuration.nix";
    ehc = "hx ~/.config/flake/hosts/$(hostname)/hardware-configuration.nix";
    ep = "hx ~/.config/flake/modules/packages.nix";
    eb = "hx ~/.config/flake/modules/bash.nix";
    en = "hx ~/.config/flake/modules/nixos.nix";

    # Python.
    py = "python";

    # Activate python venv.
    venv = "source .venv/bin/activate";

    # Nix commands.
    ns = "nix-shell";
    ni = "nix-index";
    nl = "nix-locate";

    # Zellij.
    zj = "zellij";

    # Lazygit.
    lg = "lazygit";

    # Fastfetch.
    ff = "fastfetch";

    # Pipes.
    pipes = "pipes.sh -t 0 -c 1 -c 2 -c 3 -c 4 -c 5 -c 6 -c";
  };

  programs.bash.promptInit = ''
    # Set editor to Helix.
    EDITOR=hx

    if [ "$EUID" -ne 0 ]
    then
      # Root, red prompt
      PS1='\[\e[1;32m\]\u \w € \[\e[0;0m\]'
    else
      # Normal user, green prompt
      PS1='\[\e[1;31m\]\u \w £ \[\e[0;0m\]'
    fi

    # Enable directory navigation with Yazi.
    function y() {
    	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    	yazi "$@" --cwd-file="$tmp"
    	if cwd="$(command cat -- "$tmp")" &&\
        [ -n "$cwd" ] &&\
        [ "$cwd" != "$PWD" ]
      then
    		builtin cd -- "$cwd"
    	fi
    	rm -f -- "$tmp"
     }
  '';
}
