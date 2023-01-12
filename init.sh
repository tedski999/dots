#!/usr/bin/env sh

# TODO: n/vim settings
# TODO: backups, and timeshift?

set -e

hash apt-get sudo

[ "$USER" = "root" ] && { >&2 echo "Run as non-root user"; exit 1; }

# GPG key import dots cloning
hash gpg git &>/dev/null || sudo apt-get install --yes gpg git
[ -n "$1" ] && gpg --import "$1"
git --git-dir $HOME/.local/dots init &>/dev/null || {
	git clone --bare git@h8c.de:dots.git $HOME/.local/dots
	git --git-dir $HOME/.local/dots --work-tree $HOME checkout --force msung
}

# Packages installation
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt-get update --yes
sudo apt-get upgrade --yes
sudo apt-get install --yes \
	alacritty fish neovim exa btop calc ranger \
	polybar dmenu mpd mpc borgbackup jq libnotify-bin xautolock \
	fonts-terminus fonts-terminus-otb \
	brave-browser discord mpv sxiv \
	ubuntu-restricted-extras

# Clipmenu installation
sudo apt-get install --yes libx11-dev libxfixes-dev
clipnotify=$(mktemp -d)
git clone https://github.com/cdown/clipnotify $clipnotify
sudo make --directory $clipnotify install
clipmenu=$(mktemp -d)
git clone https://github.com/cdown/clipmenu $clipmenu
sudo make --directory $clipmenu install

# Slock installation
sudo apt-get install --yes libimlib2-dev libxrandr-dev
slock=$(mktemp -d)
git clone https://src.h8c.de/slock $slock
sudo make --directory $slock install

# Just Perfection installation
sudo apt-get install --yes gettext
justperfection=$(mktemp -d)
git clone https://gitlab.gnome.org/jrahmatzadeh/just-perfection.git $justperfection
$justperfection/scripts/build.sh
sudo cp $HOME/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml /usr/share/glib-2.0/schemas
sudo glib-compile-schemas /usr/share/glib-2.0/schemas

# Hostname
sudo hostnamectl hostname msung

# Login shell
sudo chsh ski -s /usr/bin/fish

# Sudo
sudo mkdir -p /etc/sudoers.d
>/etc/sudoers.ds/remove_admin_flag echo "Defaults !admin_flag"

# Plymouth
# TODO: Install custom plymouth theme 'min'
sudo kernelstub --add-options "systemd.show_status=false rd.udev.log_level=0"
sudo ln -sf /usr/share/plymouth/themes/tribar/tribar.plymouth /etc/alternatives/default.plymouth
sudo update-initramfs -u -k all

# Update bin permissions
chmod +x .local/bin/*

# Settings
gsettings set org.gnome.desktop.background picture-options "none"
gsettings set org.gnome.desktop.background primary-color "#1a1a1a"
gsettings set org.gnome.desktop.screensaver picture-options "none"
gsettings set org.gnome.desktop.screensaver primary-color "#000000"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30
gsettings set org.gnome.desktop.peripherals.keyboard delay 250
gsettings set org.gnome.desktop.peripherals.touchpad click-method "fingers"
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'ie')]"
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.shell disable-user-extensions false
gsettings set org.gnome.shell disabled-extensions "['cosmic-dock@system76.com', 'ubuntu-appindicators@ubuntu.com']"
gsettings set org.gnome.shell enabled-extensions "['ding@rastersoft.com', 'pop-shell@system76.com', 'system76-power@system76.com', 'cosmic-workspaces@system76.com', 'popx11gestures@system76.com', 'pop-cosmic@system76.com', 'just-perfection-desktop@just-perfection']"
gsettings set org.gnome.shell favorite-apps "[]"
gsettings set org.gnome.mutter dynamic-workspaces true
gsettings set org.gnome.mutter edge-tiling false
gsettings set org.gnome.mutter overlay-key "Super_R"
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature "uint32 3021"
gsettings set org.gnome.settings-daemon.plugins.power power-button-action "suspend"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "suspend"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "suspend"
gsettings set org.gnome.nautilus.preferences click-policy "single"
gsettings set org.gnome.system.location enabled false
gsettings set org.gnome.shell.extensions.pop-shell active-hint false
gsettings set org.gnome.shell.extensions.pop-shell active-hint-border-radius "uint32 1"
gsettings set org.gnome.shell.extensions.pop-shell gap-inner "uint32 2"
gsettings set org.gnome.shell.extensions.pop-shell gap-outer "uint32 2"
gsettings set org.gnome.shell.extensions.pop-shell hint-color-rgba "rgba(255,255,255,0.25)"
gsettings set org.gnome.shell.extensions.pop-shell mouse-cursor-follows-active-window false
gsettings set org.gnome.shell.extensions.pop-shell show-title false
gsettings set org.gnome.shell.extensions.pop-shell smart-gaps false
gsettings set org.gnome.shell.extensions.pop-shell tile-by-default true
gsettings set org.gnome.shell.extensions.just-perfection animation 3
gsettings set org.gnome.shell.extensions.just-perfection panel false
gsettings set org.gnome.shell.extensions.just-perfection panel-in-overview false
gsettings set org.gnome.shell.extensions.just-perfection panel-size 1
gsettings set org.gnome.shell.extensions.just-perfection startup-status 0
gsettings set org.gnome.shell.extensions.just-perfection theme true
gsettings set org.gnome.shell.extensions.just-perfection window-menu-take-screenshot-button false
gsettings set org.gnome.shell.extensions.just-perfection workspace false
gsettings set org.gnome.shell.extensions.just-perfection workspace-popup false
gsettings set org.gnome.shell.extensions.just-perfection workspace-switcher-should-show true
gsettings set org.gnome.shell.extensions.pop-shell focus-down "['<Super>j']"
gsettings set org.gnome.shell.extensions.pop-shell focus-left "['<Super>h']"
gsettings set org.gnome.shell.extensions.pop-shell focus-right "['<Super>l']"
gsettings set org.gnome.shell.extensions.pop-shell focus-up "['<Super>k']"
gsettings set org.gnome.shell.extensions.pop-shell pop-monitor-left "['<Primary><Super>h']"
gsettings set org.gnome.shell.extensions.pop-shell pop-monitor-right "['<Primary><Super>l']"
gsettings set org.gnome.shell.extensions.pop-shell pop-monitor-up "[]"
gsettings set org.gnome.shell.extensions.pop-shell pop-workspace-down "['<Shift><Super>j']"
gsettings set org.gnome.shell.extensions.pop-shell pop-workspace-up "['<Shift><Super>k']"
gsettings set org.gnome.shell.extensions.pop-shell tile-accept "['Return']"
gsettings set org.gnome.shell.extensions.pop-shell tile-by-default false
gsettings set org.gnome.shell.extensions.pop-shell tile-enter "['<Super>Return']"
gsettings set org.gnome.shell.extensions.pop-shell tile-move-down "['j']"
gsettings set org.gnome.shell.extensions.pop-shell tile-move-left "['h']"
gsettings set org.gnome.shell.extensions.pop-shell tile-move-right "['l']"
gsettings set org.gnome.shell.extensions.pop-shell tile-move-right-global "[]"
gsettings set org.gnome.shell.extensions.pop-shell tile-move-up "['k']"
gsettings set org.gnome.shell.extensions.pop-shell tile-orientation "[]"
gsettings set org.gnome.shell.extensions.pop-shell tile-resize-down "['<Shift>j']"
gsettings set org.gnome.shell.extensions.pop-shell tile-resize-left "['<Shift>h']"
gsettings set org.gnome.shell.extensions.pop-shell tile-resize-right "['<Shift>l']"
gsettings set org.gnome.shell.extensions.pop-shell tile-resize-up "['<Shift>k']"
gsettings set org.gnome.shell.extensions.pop-shell tile-swap-down "['<Primary>j']"
gsettings set org.gnome.shell.extensions.pop-shell tile-swap-left "['<Primary>h']"
gsettings set org.gnome.shell.extensions.pop-shell tile-swap-right "['<Primary>l']"
gsettings set org.gnome.shell.extensions.pop-shell tile-swap-up "['<Primary>k']"
gsettings set org.gnome.shell.extensions.pop-shell toggle-floating "[]"
gsettings set org.gnome.shell.extensions.pop-shell toggle-stacking "[]"
gsettings set org.gnome.shell.extensions.pop-shell toggle-stacking-global "[]"
gsettings set org.gnome.shell.extensions.pop-shell toggle-tiling "[]"
gsettings set org.gnome.shell.keybindings focus-active-notification "[]"
gsettings set org.gnome.shell.keybindings screenshot "[]"
gsettings set org.gnome.shell.keybindings screenshot-window "[]"
gsettings set org.gnome.shell.keybindings show-screen-recording-ui "[]"
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Primary><Super>space']"
gsettings set org.gnome.shell.keybindings toggle-message-tray "[]"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Shift><Super>space']"
gsettings set org.gnome.desktop.wm.keybindings begin-move "[]"
gsettings set org.gnome.desktop.wm.keybindings begin-resize "[]"
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"
gsettings set org.gnome.desktop.wm.keybindings cycle-group "[]"
gsettings set org.gnome.desktop.wm.keybindings cycle-group-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings cycle-panels "[]"
gsettings set org.gnome.desktop.wm.keybindings cycle-panels-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings cycle-windows "[]"
gsettings set org.gnome.desktop.wm.keybindings cycle-windows-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings panel-run-dialog "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-panels "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-panels-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Primary><Super>j']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Primary><Super>k']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Primary><Super>j']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Shift><Super>exclam']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Shift><Super>quotedbl']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Shift><Super>sterling']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Shift><Super>dollar']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-last "[]"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "[]"
gsettings set org.gnome.desktop.wm.keybindings toggle-on-all-workspaces "['<Super>period']"
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Shift><Super>h']"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Shift><Super>l']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom0 binding "<Super>t"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom0 command "alacritty"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom0 name "Terminal"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom1 binding "<Super>w"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom1 command "brave-browser"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom1 name "Browser"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom2 binding "<Super>space"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom2 command "launcher"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom2 name "Launcher"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom3 binding "<Super>Escape"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom3 command "powerctl"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom3 name "Power Menu"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom4 binding "<Shift><Super>Escape"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom4 command "powerctl lock"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom4 name "Power Menu - Lock"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom5 binding "<Primary><Super>Escape"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom5 command "powerctl suspend"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom5 name "Power Menu - Suspend"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom6 binding "<Super>d"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom6 command "discord"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom6 name "Discord"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom7 binding "<Super>a"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom7 command "musicctl"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom7 name "Music"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom8 binding "<Super>s"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom8 command "gnome-control-center"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom8 name "Settings"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom9 binding "<Super>e"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom9 command "gnome-extensions-app"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom9 name "Extensions"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom10 binding "<Super>v"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom10 command "clipboard"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom10 name "Clipboard"

# Dots gitignore
mkdir -p $HOME/.local/dots/info
>$HOME/.local/dots/info/exclude echo "\
/*
!/.config
!/.gnupg
!/.local

/.config/*
!/.config/alacritty
!/.config/environment.d
!/.config/fish
!/.config/git
!/.config/mpd
!/.config/npm
!/.config/nvim
!/.config/polybar
!/.config/python
!/.config/ranger
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
!/.local/bin/clipboard
!/.local/bin/launcher
!/.local/bin/musicctl
!/.local/bin/powerctl
!/.local/bin/startup
!/.local/bin/superhudd"

echo "Dots successfully installed. Reboot now."
