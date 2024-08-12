# vim but better
{ pkgs, lib, ... }: {
  home.sessionVariables.VISUAL = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
  home.sessionVariables.MANWIDTH = 80;
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
  programs.neovim.extraLuaConfig = builtins.readFile ./neovim.lua;
  programs.neovim.plugins = with pkgs.vimPlugins; [
    fzf-lua
    lualine-nvim
    mini-nvim
    neogit
    nightfox-nvim
    nvim-osc52
    nvim-surround
    satellite-nvim
    vim-rsi
    vim-signify
  ];
  programs.zsh.shellAliases.v = "nvim ";
}
