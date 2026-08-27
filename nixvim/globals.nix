{ self, pkgs, ... }:
{
  opts = {
    number = true;

    termguicolors = true;

    clipboard = {
      register = "unnamedplus";
      provider = "wl-copy";
    };

    undofile = true;
    swapfile = true;
    backup = false;
    autoread = true;
    tabstop = 4;
    shiftwidth = 4;
    softtabstop = 4;
    expandtab = true;
  };

  autoCmd = [
    {
      event = "FileType";
      pattern = "javascript";
      command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2";
    }
    {
      event = "FileType";
      pattern = "html";
      command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2";
    }
  ];
}
