{
  config,
  lib,
  pkgs,
  ...
}:

{
  plugins.lsp = {
    enable = true;
    servers = {
      # Nix language server
      nil_ls.enable = true;
      # Markdown language server
      marksman.enable = true;
      # shell script language server (sh, bash, zsh)
      bashls = {
        enable = true;
        filetypes = [
          "sh"
          "bash"
          "zsh"
        ];
      };
      # TypeScript / JavaScript language server
      ts_ls.enable = true;
      # R language server
      # package = null: relies on R (with languageserver) provided by the project's R flake
      r_language_server = {
        enable = true;
        package = null;
      };
      # OCaml language server
      ocamllsp.enable = true;
      # Haskell language server
      hls = {
        enable = true;
        installGhc = true;
      };
      # Typst language server
      tinymist.enable = true;
      # C language server
      clangd.enable = true;
      # Python language server
      basedpyright.enable = true;
      # HTML language server
      html.enable = true;
      # CSS language server
      cssls.enable = true;
      # Java language server
      jdtls.enable = true;
      # Julia language server
      # package = null: relies on LanguageServer.jl installed in the Julia environment
      julials = {
        enable = true;
        package = null;
      };
      # Go language server
      gopls.enable = true;
      # TOML language server
      taplo.enable = true;
      # JSON language server (included in vscode-langservers-extracted, same as html/cssls)
      jsonls.enable = true;
      # YAML language server
      yamlls = {
        enable = true;
        settings.yaml.schemas = {
          # GitHub Actions workflow schema
          "https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.{yml,yaml}";
        };
      };
      # Elm language server
      elmls.enable = true;
      # Astro language server
      astro.enable = true;
      # Dockerfile language server
      dockerls.enable = true;
      # Docker Compose language server
      docker_compose_language_service.enable = true;
      # Makefile language server
      autotools_ls.enable = true;

      # LaTeX language server
      texlab.enable = true;
      # Assembly (NASM/GAS) language server
      asm_lsp.enable = true;
      # Graphviz DOT language server
      dotls.enable = true;
      # Rust language server
      rust_analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
      qmlls = {
        enable = true;
        filetypes = [
          "qml"
        ];
      };
      lua_ls.enable = true;
    };
  };
}
