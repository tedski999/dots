#!/usr/bin/env sh

hash sudo || {
	2>&1 echo "Error: Please install sudo first."
	exit 1
}

echo "
/*
!/.config
!/.gnupg
!/.ssh

/.config/*
!/.config/fish
!/.config/git
!/.config/nvim

/.gnupg/*
!/.gnupg/gpg-agent.conf
!/.gnupg/sshcontrol

/.ssh/*
!/.ssh/authorized_keys
" > $HOME/.local/dots/info/exclude

sudo apt-get update
sudo apt-get install fish exa neovim rsync
chsh -s /usr/bin/fish
