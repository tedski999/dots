#!/usr/bin/env sh

echo "
/*
!/.config
!/.gnupg

/.config/*
!/.config/fish
!/.config/git
!/.config/nvim

/.gnupg/*
!/.gnupg/gpg-agent.conf
!/.gnupg/sshcontrol
" > $HOME/.local/dots/info/exclude

apt-get update
apt-get install fish exa gnupg neovim borgbackup rsync
chsh -s fish
