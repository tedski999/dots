#!/usr/bin/env sh

hash sudo || {
	2>&1 echo "Error: Please install sudo first."
	exit 1
}

echo "
/*
!/.config
/.config/*
!/.config/fish
!/.config/git
!/.config/nvim
!/.config/wget
" >> $HOME/.local/dots/info/exclude

sudo apt-get install --needed fish exa neovim borg rsync
chsh -s /usr/bin/fish
