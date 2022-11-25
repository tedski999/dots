#!/usr/bin/env sh

# TODO: logind.conf
# TODO: xorg, nvidia and steam fun

set -e

hash rpm dnf sudo

[ $UID -eq 0 ] && { >&2 echo "Run as non-root user"; exit 1; }

# GPG key import dots cloning
hash gpg git &>/dev/null || sudo dnf install --assumeyes gpg git
[ -n "$1" ] && gpg --import "$1"
git --git-dir $HOME/.local/dots init &>/dev/null || {
	git clone --bare git@h8c.de:dots.git $HOME/.local/dots
	git --git-dir $HOME/.local/dots --work-tree $HOME checkout --force msung
}

# DNF configuration
sudo mkdir -p /etc/dnf
sudo sh -c ">/etc/dnf/dnf.conf echo \"\
[main]
gpgcheck=True
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
defaultyes=True
max_parallel_downloads=20
minrate=512K
metadata_expire=604800\""

# Packages installation
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo dnf install --assumeyes https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install --assumeyes https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install --assumeyes \
	@standard @hardware-support @multimedia @printing @fonts \
	@"C Development Tools And Libraries" @"Development Tools" \
	@base-x xset xsetroot hsetroot xkbset xinput xsel xdotool xrandr xautolock \
	terminus-fonts materia-gtk-theme breeze-icon-theme papirus-icon-theme \
	bspwm sxhkd picom polybar dmenu dunst \
	alacritty fish neovim exa bat btop calc ranger \
	acpi borgbackup light socat jq \
	@LibreOffice brave-browser discord mpv

# Clipmenu installation
sudo dnf install --assumeyes libX11-devel libXfixes-devel
git clone https://github.com/cdown/clipnotify /tmp/clipnotify
git clone https://github.com/cdown/clipmenu /tmp/clipmenu
trap 'rm -rf /tmp/clipnotify /tmp/clipmenu' EXIT
sudo make --directory /tmp/clipnotify install
sudo make --directory /tmp/clipmenu install

# Grub configuration
luks=$(sudo blkid --label "fedora_fedora" | sed 's/.*\///')
while [ -z "$luks" ]; do
	printf "luks partition uuid: "
	read luks
done
sudo mkdir -p /etc/default
sudo sh -c ">/etc/default/grub echo \"\
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_CMDLINE_LINUX='rd.luks.uuid=$luks rd.plymouth=0 plymouth.enable=0 loglevel=3'
GRUB_ENABLE_BLSCFG=true\""
sudo mkdir -p /boot/grub2
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Autologin
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo sh -c ">/etc/systemd/system/getty@tty1.service.d/autologin.conf echo \"\
[Service]
Type=simple
ExecStart=
ExecStart=-/sbin/agetty --skip-login --nonewline --noissue --noclear --autologin $USER %I \$TERM
Environment=XDG_SESSION_TYPE=x11\""

# Hostname
sudo hostnamectl hostname msung

# Login shell
sudo chsh ski -s /usr/bin/fish

# Dots gitignore
mkdir -p $HOME/.local/dots/info
>$HOME/.local/dots/info/exclude echo "\
/*
!/.config
!/.gnupg
!/.local
!/.xinitrc

/.config/*
!/.config/alacritty
!/.config/bspwm
!/.config/dunst
!/.config/fish
!/.config/git
!/.config/gtk-3.0
!/.config/gtk-4.0
!/.config/npm
!/.config/nvim
!/.config/picom
!/.config/polybar
!/.config/python
!/.config/ranger
!/.config/sxhkd
!/.config/wget
!/.config/user-dirs.dirs
!/.config/user-dirs.locale

/.gnupg/*
!/.gnupg/gpg-agent.conf
!/.gnupg/sshcontrol

/.local/*
!/.local/bin
/.local/bin/*
!/.local/bin/backupd
!/.local/bin/choose
!/.local/bin/choose
!/.local/bin/hdmictl
!/.local/bin/lock
!/.local/bin/musicctl
!/.local/bin/powerctl
!/.local/bin/powerd
!/.local/bin/progress
!/.local/bin/scratch
!/.local/bin/screenshot
!/.local/bin/superhudd
!/.local/bin/wifictl"

echo "Dots successfully installed. Reboot now."
