#!/usr/bin/env sh

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
metadata_expire=604800\""

# Packages installation
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo dnf install --assumeyes https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install --assumeyes https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install --assumeyes \
	@standard @hardware-support @multimedia @printing @fonts \
	akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs \
	@"C Development Tools And Libraries" @"Development Tools" \
	@base-x xset xsetroot hsetroot xkbset xinput xsel xdotool xrandr xautolock \
	terminus-fonts materia-gtk-theme breeze-icon-theme papirus-icon-theme \
	bspwm sxhkd picom polybar dmenu dunst \
	alacritty fish neovim exa btop calc ranger \
	NetworkManager-wifi acpi borgbackup light socat jq \
	@LibreOffice brave-browser discord mpv

# Clipmenu installation
sudo dnf install --assumeyes libX11-devel libXfixes-devel
clipnotify=$(mktemp -d)
git clone https://github.com/cdown/clipnotify $clipnotify
sudo make --directory $clipnotify install
clipmenu=$(mktemp -d)
git clone https://github.com/cdown/clipmenu $clipmenu
sudo make --directory $clipmenu install

# Slock installation
sudo dnf install --assumeyes imlib2-devel
slock=$(mktemp -d)
git clone https://src.h8c.de/slock $slock
sudo make --directory $slock install

# Grub configuration
sudo mkdir -p /etc/default
sudo sh -c ">/etc/default/grub echo \"\
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_GFXMODE=1920x1080x32,auto
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_CMDLINE_LINUX='rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 rd.plymouth=0 plymouth.enable=0 loglevel=3'
GRUB_ENABLE_BLSCFG=true\""
sudo mkdir -p /boot/grub2
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Dracut configuration - Fixes i915 resolution changes at boot affecting LUKS password prompt
sudo mkdir -p /etc/dracut.conf.d
sudo sh -c ">/etc/dracut.conf.d/early_kms.conf echo \"force_drivers+=' i915 '\""
sudo dracut --force --regenerate-all

# Power control
sudo mkdir -p /etc/systemd
sudo sh -c ">/etc/systemd/logind.conf echo \"\
[Login]
HandlePowerKey=suspend
HandleRebootKey=suspend
HandleSuspendKey=suspend
HandleHibernateKey=suspend
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore\""

# Autologin
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo sh -c ">/etc/systemd/system/getty@tty1.service.d/autologin.conf echo \"\
[Service]
Type=simple
ExecStart=
ExecStart=-/sbin/agetty --skip-login --nonewline --noissue --noclear --autologin $USER %I \$TERM
Environment=XDG_SESSION_TYPE=x11\""

# Xorg configuration
sudo sh -c ">/etc/X11/xorg.conf echo \"\
Section \\\"Device\\\"
	Identifier \\\"intel\\\"
	Driver \\\"intel\\\"
	Option \\\"TearFree\\\" \\\"true\\\"
EndSection
Section \\\"Device\\\"
	Identifier \\\"nvidia\\\"
	Driver \\\"nvidia\\\"
EndSection\""

# Hostname
sudo hostnamectl hostname msung

# Login shell
sudo chsh ski -s /usr/bin/fish

# fstab
sudo sh -c ">>/etc/fstab echo \"UUID=69da1754-4437-4d78-8007-c33692be8348 /home/ski/Extern ext4 rw,relatime 0 0\""

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
!/.config/mimeapps.list
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
