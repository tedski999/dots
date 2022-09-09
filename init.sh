#!/usr/bin/env sh

hash sudo yay || {
	2>&1 echo "Error: Please install sudo and yay first."
	exit 1
}

echo "
/*
!/.config
!/.gnupg
!/.local
!/.xinitrc

/.config/*
!/.config/bspwm
!/.config/dunst
!/.config/fish
!/.config/git
!/.config/kitty
!/.config/neofetch
!/.config/npm
!/.config/nvim
!/.config/picom
!/.config/polybar
!/.config/python
!/.config/rofi
!/.config/sxhkd
!/.config/wget
!/.config/wget
!/.config/zathura
!/.config/user-dirs.dirs
!/.config/user-dirs.locale

/.gnupg/*
!/.gnupg/gpg-agent.conf
!/.gnupg/sshcontrol

/.local/*
!/.local/bin
!/.local/root
" >> $HOME/.local/dots/info/exclude

yay -Syu fish exa
# TODO:
# acpi bat betterdiscord-installer borg brave-bin bspwm
# btop calc clipmenu didyoumean-bin discord dunst efibootmgr exa
# fish hsetroot jq kitty lf light mpv neofetch neovim networkmanager
# noto-fonts noto-fonts-cjk noto-fonts-emoji nvidia nvtop otf-latin-modern
# pacman-contrib picom pipewire pipewire-alsa pipewire-jack pipewire-pulse
# polybar pulsemixer rofi rsync socat steam sxhkd terminus-font-ttf
# ttf-nerd-fonts-symbols-2048-em wireplumber xautolock xclip xorg-xinit
# xorg-xinput xorg-xset xorg-xsetroot zathura zathura-pdf-mupdf zip

# TODO: symlink root configs

chsh -s /usr/bin/fish
