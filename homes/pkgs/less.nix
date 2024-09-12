# more but less
{ ... }: {

  home.sessionVariables.LESS = "--incsearch --ignore-case --tabs=4 --chop-long-lines --LONG-PROMPT --RAW-CONTROL-CHARS";

  programs.less.enable = true;
  programs.less.keys = "h left-scroll\nl right-scroll";

}
