{ config, pkgs, ... }:

let
  shellAliases = {
    # Python.
    py = "python";

    # Activate python venv.
    venv = "source .venv/bin/activate";
  };
in
{
  # Enable git.
  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    # Compiler stuff.
    gnumake
    pkg-config

    # Language servers and co.
    clang-tools
    lldb
    nil
    bash-language-server
    tinymist
    vscode-langservers-extracted
    typescript-language-server

    # Software development tools.
    man-pages
    man-pages-posix
    valgrind
    steam-run
    libtree
    ungoogled-chromium

    # Python and its packages, relevant tools.
    uv
    (python312.withPackages (
      ps: with ps; [
        pyyaml
        python-lsp-ruff
        requests
      ]
    ))

    # Github authenticator.
    gh

    # GPU Tooling
    vulkan-tools

    # GPU Tooling
    config.boot.kernelPackages.perf
  ];

  # Bash aliases.
  programs.bash.shellAliases = shellAliases;
}
