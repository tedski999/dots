# lf but better
{ ... }: {
  # TODO: use del / replace del with an actual trash cli
  # TODO: z/F fzf
  # TODO(later): DDS for multiclient usage
  programs.yazi.enable = true;
  programs.yazi.enableZshIntegration = true;
  programs.yazi.shellWrapperName = "y";
  programs.yazi.settings = {
    manager = {
      show_hidden = true;
    };
    preview = {
      max_width = 1000;
      max_height = 1000;
    };
  };
}
