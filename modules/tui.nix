{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    zellij
    helix

    lazygit

    pipes
    btop

    caligula
  ];

  # Bash aliases.
  programs.bash.shellAliases = {
    # Zellij.
    zj = "zellij";

    # Lazygit.
    lg = "lazygit";

    # Fastfetch.
    ff = "fastfetch";

    # Pipes.
    pipes = "pipes.sh -t 0 -c 1 -c 2 -c 3 -c 4 -c 5 -c 6 -c";
  };

  # Green, red prompts for users and root.
  programs.bash.promptInit = ''
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

  environment.variables = {
    EDITOR = "hx";
  };
}
