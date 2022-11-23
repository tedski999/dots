#!/usr/bin/env sh

# sudo dnf install git
# git clone --bare https://src.h8c.de/dots .local/dots
# git --git-dir .local/dots --work-tree . checkout msung
# sh init.sh

set -e

hash sudo rpm dnf gpg git

>$HOME/.local/dots/info/exclude echo "\
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
!/.config/npm
!/.config/nvim
!/.config/picom
!/.config/polybar
!/.config/python
!/.config/sxhkd
!/.config/wget
!/.config/user-dirs.dirs
!/.config/user-dirs.locale

/.gnupg/*
!/.gnupg/gpg-agent.conf
!/.gnupg/sshcontrol

/.local/*
!/.local/bin
!/.local/root"

# TODO: clean boot + bootloader stuff
# TODO: xclip needed?
sudo sh << EOF
set -e

>/etc/dnf/dnf.conf echo "\
max_parallel_downloads=8
fastestmirror=True"

dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install \
	@standard @hardware-support @multimedia @printing @fonts \
	@"C Development Tools And Libraries" @"Development Tools" \
	@base-x xset xsetroot hsetroot xkbset xinput xdotool xrandr xautolock \
	bspwm sxhkd picom polybar dmenu dunst terminus-fonts \
	kitty fish kitty-fish-integration \
	neovim exa bat btop calc ranger \
	acpi borg clipmenu light socat jq \
	@LibreOffice brave-browser discord mpv

>/etc/systemd/system/getty@tty1.service.d/autologin.conf echo "\
[Service]
Type=simple
ExecStart=
ExecStart=-/sbin/agetty --skip-login --nonewline --noissue --noclear --autologin $(whoami) %I \$TERM
Environment=XDG_SESSION_TYPE=x11"

hostnamectl hostname msung
chsh ski -s /usr/bin/fish

EOF

keyfile="key.asc"
while [ -n "$keyfile" -a ! -r "$keyfile" ]; do
	printf "GPG keyfile: %s/" $(pwd)
	read keyfile
done

if [ -r "$keyfile" ] && gpg --import "$keyfile"; then
	dots remote set-url origin git@h8c.de:dots.git
fi
