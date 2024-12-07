{ pkgs, ... }:

{
  programs.git.enable = true;
  programs.lazygit.enable = true;

  environment.systemPackages = with pkgs; [
    # Compiler stuff.
    gnumake
    rustup
    gcc
    pkg-config
    glibc.dev

    # Language servers and co.
    rust-analyzer
    clang-tools
    lldb
    nil
    bash-language-server

    # Software development tools.
    man-pages
    man-pages-posix
    valgrind
    steam-run

    # Python and its packages, relevant tools.
    uv
    (python312.withPackages (ps: with ps; [
      pyyaml
      python-lsp-ruff
    ]))

    # Github authenticator.
    gh
  ];

  # Bash aliases.
  programs.bash.shellAliases = {
    # Python.
    py = "python";

    # Activate python venv.
    venv = "source .venv/bin/activate";
  };
}
