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
" > $HOME/.local/dots/info/exclude

sudo apt-get update
sudo apt-get install fish exa neovim borgbackup rsync
chsh -s /usr/bin/fish
