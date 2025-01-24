{ unstable, pkgs, ... }:
{
  # Enable git.
  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    # Compiler stuff.
    gnumake
    # rustup
    unstable.gcc14
    pkg-config
    unstable.glibc.dev

    # Language servers and co.
    rust-analyzer
    clang-tools
    lldb
    nil
    bash-language-server
    tinymist

    # Software development tools.
    man-pages
    man-pages-posix
    valgrind
    steam-run
    libtree

    # Python and its packages, relevant tools.
    uv
    (python312.withPackages (ps: with ps; [
      pyyaml
      python-lsp-ruff
      requests
    ]))

    # Github authenticator.
    gh

    # GPU Tooling
    vulkan-tools
  ];

  # Bash aliases.
  programs.bash.shellAliases = {
    # Python.
    py = "python";

    # Activate python venv.
    venv = "source .venv/bin/activate";
  };
}
