# python2 but better
{ pkgs, config, ... }: {
  home.packages = with pkgs; [ python39 ];
  home.sessionVariables.PYTHONSTARTUP = "${config.xdg.configHome}/python/pythonrc";
  xdg.configFile."python/pythonrc".text = ''
    import atexit, readline

    try:
        readline.read_history_file("${config.xdg.dataHome}/python_history")
    except OSError as e:
        pass
    if readline.get_current_history_length() == 0:
        readline.add_history("# history created")

    def write_history(path):
        try:
            import os, readline
            os.makedirs(os.path.dirname(path), mode=0o700, exist_ok=True)

            readline.write_history_file(path)
        except OSError:
            pass

    atexit.register(write_history, "${config.xdg.dataHome}/python_history")
    del (atexit, readline, write_history)
  '';
  programs.zsh.shellAliases.p = "python3 ";
}
