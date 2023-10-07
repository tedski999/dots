export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
# Programs
export PATH="$HOME/.local/bin:$PATH:/sbin:/usr/sbin"
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="nvim +Man!"
export MANWIDTH="80"
export TERMINAL="alacritty"
export BROWSER="firefox"
# Clean $HOME
export HISTFILE="$XDG_DATA_HOME/history"
export ANDROID_HOME="$XDG_DATA_HOME/android"
export CARGO_HOME="$HOME/.local/opt/cargo"
export PATH="$CARGO_HOME/bin:$PATH"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GOPATH="$XDG_DATA_HOME/go"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export RUSTUP_HOME="$HOME/.local/opt/rustup"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export ZSH_DATA="$XDG_DATA_HOME/zsh"
export npm_config_userconfig="$XDG_CONFIG_HOME/npm/npmrc"
export skip_global_compinit=1
# TODO: .cert
# Settings
export MOZ_ENABLE_WAYLAND=1
export GAMEMODERUNEXEC="env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only"
