export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
# Programs
export PATH="$HOME/.local/bin:$PATH:/sbin:/usr/sbin"
export EDITOR="nvim"
export VISUAL="nvim"
export DIFFPROG="delta"
# TODO: nvim as merger
export MANPAGER="nvim +Man!"
export MANWIDTH="80"
export TERMINAL="alacritty"
export BROWSER="firefox"
# Clean $HOME
export HISTFILE="$XDG_DATA_HOME/history"
export ANDROID_HOME="$XDG_DATA_HOME/android"
export CARGO_HOME="$XDG_CONFIG_HOME/cargo"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GOPATH="$XDG_DATA_HOME/go"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export RUSTUP_HOME="$XDG_CONFIG_HOME/rustup"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export npm_config_userconfig="$XDG_CONFIG_HOME/npm/npmrc"
export skip_global_compinit=1
# TODO: .cert .googleearth
