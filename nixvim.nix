{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nixvim = {
    enable = true;
    extraPackages = with pkgs; [
      qt6.qtdeclarative
    ];
    globals.mapleader = " ";
    imports = [
      ./nixvim/lsp.nix
      ./nixvim/globals.nix
    ];
    waylandSupport = true;
    # colorscheme
    colorschemes.onedark.enable = true;
    plugins = {

      # fuzzy file finder
      telescope = {
        enable = true;
        settings = {
          defaults = {
            file_ignore_patterns = [
              # NOTE this uses lua pattern matching, not regex
              "^.git/"
              "*.tscn$"
              "*.gd.uid$"
              "^target/"
            ];
          };
          pickers = {
            find_files = {
              hidden = true;
            };
          };

        };

        keymaps = {
          "<leader><leader>" = "find_files";

        };
      };
      # auto format
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            lsp_fallback = true;
            timeout_ms = 500;
          };
          formatters_by_ft = {
            qml = [ "qmlformat" ];
          };
        };
      };
      # treesitter does stuff
      treesitter.enable = true;
      # shows git changes
      gitsigns.enable = true;
      # autoclose brackets and tags
      ts-autotag.enable = true;
      # status bar and tab bar
      bufferline.enable = true;
      lualine.enable = true;
      # errors
      trouble.enable = true;
      # autocomplete
      blink-cmp = {
        enable = true;
        settings = {
          keymap = {
            "<Tab>" = [
              "select_next"
              "fallback"
            ];
            "<S-Tab>" = [
              "select_prev"
              "fallback"
            ];
            "<Enter>" = [
              "accept"
              "fallback"
            ];
            "<Up>" = [ "fallback" ];
            "<Down>" = [ "fallback" ];
          };
        };
      };

      highlight-colors.enable = true;

      transparent = {
        enable = true;
        settings = {
          extra_groups = [
            "BufferLineTabClose"
            "BufferLineBufferSelected"
            "BufferLineFill"
            "BufferLineBackground"
            "BufferLineSeparator"
            "BufferLineIndicatorSelected"
          ];
        };
      };
      wakatime.enable = true;
      godot.enable = true;
    };
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "ultimate-autopair";
        src = pkgs.fetchFromGitHub {
          owner = "altermo";
          repo = "ultimate-autopair.nvim";
          rev = "6b58234de921437836efe27714b2026ed2ee235a";
          hash = "sha256-JEL6ansTFn4930gz6i7zUyvCaSxHJImz8hdwoQmX7qM=";
        };
      })
    ];
    extraConfigLua = ''
      	require('ultimate-autopair').setup({

      	})
        vim.lsp.config('gdscript', {
            cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
            root_markers = {'project.godot', '.git'},
        })

        vim.lsp.enable('gdscript')
    '';

    diagnostic.settings = {
      virtual_lines = {
        current_line = true;
      };
      update_in_insert = false;
    };

    nixpkgs.config = {
      allowUnfree = true;
    };

  };
}
