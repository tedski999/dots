# vim but better
{ pkgs, config, ... }: {
  home.sessionVariables.VISUAL = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
  home.sessionVariables.MANWIDTH = 80;
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
  # TODO(later): neogit/vim-fugitive
  programs.neovim.plugins = with pkgs.vimPlugins; [ fzf-lua lualine-nvim nightfox-nvim nvim-surround mini-nvim satellite-nvim vim-rsi vim-signify ];
  programs.neovim.extraLuaConfig = builtins.readFile ./neovim.lua;
}
