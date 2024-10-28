
## Installation notes

Instructions for setting up environments on various non-NixOS devices.

### Work Laptop - Ubuntu 22.04

Assuming fresh laptop provisioned with IT security tools.

Import agenix key:
```sh
cp /mnt/tedj@work.agenix.key ~/.ssh/
```

Install nix:
```sh
export NIX_CONFIG=$'use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes'
sh <(curl -L https://nixos.org/nix/install) --daemon
echo 'trusted-users = tedj' | sudo tee --append /etc/nix/nix.conf
sudo systemctl restart nix-daemon
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#tedj@work
unset NIX_CONFIG
```

Disable `sudo` password for tedj, admin_flag, env_reset and secure_path:
```sh
printf 'Defaults !admin_flag\ntedj ALL=(ALL) NOPASSWD: ALL\n' | sudo tee /etc/sudoers.d/qol
printf 'Defaults !env_reset\nDefaults !secure_path\n' | sudo tee /etc/sudoers.d/keep_env
```

Install IT security tools (give helpdesk@ a head-up): https://intranet.arista.com/it/ubuntu-22-04lts-security-tools-help Note google-chrome is pushed once enrolled into WS1, you can sign into the browser with Arista credentials.

xdg-desktop-portal-wlr on 22.04 is broken but we still need the package installed to get the entry in `/usr/share/xdg-desktop-portal/portals`:
```sh
sudo apt install xdg-desktop-portal-wlr
```

swaylock must be installed systemd-wide for PAM integration:
```sh
sudo apt install swaylock
```

Import GPG subkeys:
```sh
gpg --import $XDG_RUNTIME_DIR/agenix/ski@h8c.de.gpg
```

Login to Bitwarden:
```sh
bw login
```

Connect to corporate Wi-Fi:
```sh
nmcli connection add type wifi con-name ARISTA-Corp ssid ARISTA-Corp -- \
    wifi-sec.key-mgmt wpa-eap 802-1x.eap tls 802-1x.identity tedj \
    802-1x.client-cert $XDG_RUNTIME_DIR/agenix/tedj@arista.com.cer \
    802-1x.private-key $XDG_RUNTIME_DIR/agenix/tedj@arista.com.pem \
    802-1x.private-key-password <...>
```

Install arista-ssh-agent: https://docs.google.com/document/d/12-lH_pGsDEyKQnIMy2eERjbW--biAkBGr2cnkeHOMg4/edit#heading=h.gppl0c9scge6 You should also comment out `GSSAPIAuthentication yes` in `/etc/ssh/ssh_config`.

Disable some unneeded software:
```sh
sudo snap remove --purge firefox
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge gnome-42-2204
sudo snap remove --purge snapd-desktop-integration
sudo snap remove --purge snap-store
sudo snap remove --purge core22
sudo snap remove --purge bare
sudo snap remove --purge snapd
sudo systemctl stop snapd
sudo systemctl stop snapd.socket
sudo apt purge snapd -y
sudo apt-mark hold snapd
sudo apt-get purge --auto-remove 'gnome*'
del ~/snap
sudo systemctl disable gdm
printf 'blacklist nouveau\noptions nouveau modeset=0\n' | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
printf '
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
' | sudo tee /etc/udev/rules.d/00-remove-nvidia.rules
```

`sudo apt-get update && sudo apt-get update` and reboot

### Work Server - AlmaLinux 9.3

Assuming fresh homebus instance.

Import agenix key:
```sh
cp /mnt/tedj@wbus.agenix.key ~/.ssh/
```

Install nix:
```sh
export NIX_CONFIG=$'use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes'
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. $HOME/.local/state/nix/profile/etc/profile.d/nix.sh
nix develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#tedj@wbus
unset NIX_CONFIG
```

Disable `sudo` env_reset:
```sh
printf 'Defaults !env_reset\nDefaults !secure_path\n' | sudo tee /etc/sudoers.d/keep_env
```

After you create a new container or if you want to update your home-manager profile, as the homebus+a4c nix stores are all managed separately to avoid NFS, you should use `ahome` within homebus to install/update all nix store instances at once to keep them consistent with the NFS home:
```sh
ahome
```

### Home Desktop - Windows 11 IoT Enterprise LTSC

Assuming fresh install using custom unattend.xml and activated using appropriate key.

Connect to Internet. This will likely initiate installations of drivers in the background and require rebooting at a later stage.

Grab this README.md if you don't want to bother with Microsoft Edge:
```ps
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tedski999/dots/refs/heads/main/README.md" -OutFile "..."
```

Configure BitLocker with gpedit.msc
- `Computer Configuration\Administrative Templates\Windows Components\BitLocker Drive Encryption\Operating System Drives\Require additional authentication at startup`:
  - Enabled
  - Allow BitLocker without a compatible TPM: True
  - Configure TPM startup: Do not allow TPM
  - Configure TPM startup PIN: Require startup PIN with TPM
  - Configure TPM startup key: Do not allow startup key with TPM
  - Configure TPM startup key and PIN: Do not allow startup key and PIN with TPM
- `Computer Configuration\Administrative Templates\Windows Components\BitLocker Drive Encryption\Operating System Drives\Allow enhanced PINs for startup`:
  - Enabled

Enable BitLocker with Control Panel:
- `System and Security\BitLocker Drive Encryption\Turn on BitLocker`
  - Enter a PIN
  - Save encryption key to file
  - Encrypt used disk space only
  - New encryption mode
  - System check
  - Restart now

Settings:
```
System\Display\DISPLAY 1\Use HDR: True
System\Display\DISPLAY 1\Advanced display\Choose a refresh rate: 144 Hz
System\Display\DISPLAY 2\Display orientation: Portrait
System\Power\Power mode: Best Performance
System\Multitasking\Snap windows\When I snap a window, suggest what I can snap next to it: True
System\Multitasking\Snap windows\Show snap layouts when I hover over a window's maximize button: False
System\Multitasking\Snap windows\Show snap layouts when I drag a window to the top of my screen: False
System\Multitasking\Snap windows\Show my snapped windows when I hover over taskbar apps, in Task View, and when I press ALt+Tab: False
System\Multitasking\Snap windows\When I drag a window, let me snap it without dragging all the way to the screen edge: False
System\Multitasking\Show tabs from apps when snapping or pressing Alt+Tab: Don't show tabs
System\For developers\File Explorer\*: True
System\Clipboard\Clipboard history: True
System\About\Rename this PC: SkiC
Personalization\Background\Personalize your background: Solid color\Custom colors\More\#1c1c1c
Personalization\Colors\Choose your mode: Dark
Personalization\Colors\Accent color: Manual\Navy Blue
Personalization\Lock screen\Show the lock screen background picture on the sign-in screen: False
Personalization\Start\Show recently added apps: False
Personalization\Start\Show recommended files in Start, recent files in File Explorer, and items in Jump Lists: False
Personalization\Start\Show recommendations for tips, shortcuts, new apps, and more: False
Personalization\Start\Show account-related notifications: False
Personalization\Start\Folders\Settings: True
Personalization\Start\Folders\File Explorer: True
Personalization\Taskbar\Taskbar items\Search: Hide
Personalization\Taskbar\Taskbar items\Task view: False
Personalization\Taskbar\Taskbar behaviours\Taskbar alignment: Left
Personalization\Taskbar\Taskbar behaviours\When using multiple displays, show my taskbar apps on: Taskbar where window is open
Personalization\Taskbar\Taskbar behaviours\Combine taskbar buttons and hide labels: Never
Personalization\Taskbar\Taskbar behaviours\Combine taskbar buttons and hide labels on other taskbars: Never
Apps\Installed apps\Paint: Uninstall
Apps\Installed apps\Remote Desktop Connection: Uninstall
Apps\Installed apps\Snipping Tool: Uninstall
Apps\Startup\Microsoft Edge: False
Gaming\Game Bar\Allow your controller to open Game Bar: False
Accessibility\Magnifier\Magnifier: False
Accessibility\Keyboard\Sticky keys\Keyboard shortcut for Sticky keys: False
Accessibility\Keyboard\Filter keys\Keyboard shortcut for Filter keys: False
Privacy & security\General\Let websites show me locally relevant content by accessing my language list: False
Privacy & security\General\Let Windows improve Start and search results by tracking app launches: False
Privacy & security\Activity history\Activity History\Store my activity history on this device: False
Privacy & security\Search permissions\SafeSearch: Off
Windows Update\Advanced options\Active hours: Manually
```

Import agenix key:
```ps
Copy-Item "D:\ski@skic.agenix.key" -Destination "$env:LOCALAPPDATA"
```

Download dots:
```ps
New-Item -ItemType Directory -Force -Path "$((gi $env:temp).fullname)\dots"
New-Item -ItemType Directory -Force -Path "$($env:LOCALAPPDATA)\Programs"
Invoke-WebRequest -Uri "https://github.com/tedski999/dots/archive/refs/heads/main.zip" -OutFile "$((gi $env:temp).fullname)\dots\dots.zip"
Expand-Archive -Path "$((gi $env:temp).fullname)\dots\dots.zip" -DestinationPath "$((gi $env:temp).fullname)\dots"
```

Install age:
```ps
Invoke-WebRequest -Uri "https://github.com/FiloSottile/age/releases/download/v1.2.0/age-v1.2.0-windows-amd64.zip" -OutFile "$((gi $env:temp).fullname)\dots\age.zip"
Expand-Archive -Path "$((gi $env:temp).fullname)\dots\age.zip" -DestinationPath "$((gi $env:temp).fullname)\dots"
Copy-Item "$((gi $env:temp).fullname)\dots\age\age.exe" -Destination "$($env:LOCALAPPDATA)\Programs"
Copy-Item "$((gi $env:temp).fullname)\dots\age\age-keygen.exe" -Destination "$($env:LOCALAPPDATA)\Programs"
```

Install, configure and autostart syncthing:
```ps
Invoke-WebRequest -Uri "https://github.com/syncthing/syncthing/releases/download/v1.27.12/syncthing-windows-amd64-v1.27.12.zip" -OutFile "$((gi $env:temp).fullname)\dots\syncthing.zip"
Expand-Archive -Path "$((gi $env:temp).fullname)\dots\syncthing.zip" -DestinationPath "$((gi $env:temp).fullname)\dots"
Copy-Item "$((gi $env:temp).fullname)\dots\syncthing-windows-amd64-v1.27.12\syncthing.exe" -Destination "$($env:LOCALAPPDATA)\Programs"
New-Item -ItemType Directory -Force -Path "$($env:LOCALAPPDATA)\Syncthing"
& "$($env:LOCALAPPDATA)\Programs\age.exe" --decrypt --identity "$($env:LOCALAPPDATA)\ski@skic.agenix.key" --output "$($env:LOCALAPPDATA)\Syncthing\cert.pem" "$((gi $env:temp).fullname)\dots\dots-main\secrets\syncthing\ski_skic\cert.pem.age"
& "$($env:LOCALAPPDATA)\Programs\age.exe" --decrypt --identity "$($env:LOCALAPPDATA)\ski@skic.agenix.key" --output "$($env:LOCALAPPDATA)\Syncthing\config.xml" "$((gi $env:temp).fullname)\dots\dots-main\secrets\syncthing\ski_skic\config.xml.age"
& "$($env:LOCALAPPDATA)\Programs\age.exe" --decrypt --identity "$($env:LOCALAPPDATA)\ski@skic.agenix.key" --output "$($env:LOCALAPPDATA)\Syncthing\https-cert.pem" "$((gi $env:temp).fullname)\dots\dots-main\secrets\syncthing\ski_skic\https-cert.pem.age"
& "$($env:LOCALAPPDATA)\Programs\age.exe" --decrypt --identity "$($env:LOCALAPPDATA)\ski@skic.agenix.key" --output "$($env:LOCALAPPDATA)\Syncthing\https-key.pem" "$((gi $env:temp).fullname)\dots\dots-main\secrets\syncthing\ski_skic\https-key.pem.age"
& "$($env:LOCALAPPDATA)\Programs\age.exe" --decrypt --identity "$($env:LOCALAPPDATA)\ski@skic.agenix.key" --output "$($env:LOCALAPPDATA)\Syncthing\key.pem" "$((gi $env:temp).fullname)\dots\dots-main\secrets\syncthing\ski_skic\key.pem.age"
$SyncthingLnk = (New-Object -comObject WScript.Shell).CreateShortcut("$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs\Startup\syncthing.lnk")
$SyncthingLnk.TargetPath = "$($env:LOCALAPPDATA)\Programs\syncthing.exe"
$SyncthingLnk.Arguments = "serve --no-console --no-browser --no-default-folder"
$SyncthingLnk.Save()
```

Configure File Explorer after starting Syncthing:
- Unpin everything
- Pin `C:\Users\ski`
- Pin `C:\Users\ski\Documents\Documents`
- Pin `C:\Users\ski\Music\Music`
- Pin `C:\Users\ski\Pictures\Pictures`
- Pin `C:\Users\ski\Videos\Videos`
- Pin `C:\Users\ski\Work`

Install Firefox:
```ps
Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US" -OutFile "$((gi $env:temp).fullname)\dots\firefox-installer.exe"
& "$((gi $env:temp).fullname)\dots\firefox-installer.exe"
```

Install Steam:
```ps
Invoke-WebRequest -Uri "https://cdn.fastly.steamstatic.com/client/installer/SteamSetup.exe" -OutFile "$((gi $env:temp).fullname)\dots\steam-installer.exe"
& "$((gi $env:temp).fullname)\dots\steam-installer.exe"
```

Install Discord:
```ps
Invoke-WebRequest -Uri "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x64" -OutFile "$((gi $env:temp).fullname)\dots\discord-installer.exe"
& "$((gi $env:temp).fullname)\dots\discord-installer.exe"
```

Install Prism:
```ps
Invoke-WebRequest -Uri "https://github.com/PrismLauncher/PrismLauncher/releases/download/9.1/PrismLauncher-Windows-MSVC-Setup-9.1.exe" -OutFile "$((gi $env:temp).fullname)\dots\prism-installer.exe"
& "$((gi $env:temp).fullname)\dots\prism-installer.exe"
```

Install ckan (requires [.NET 4.8](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48) or later):
```ps
Invoke-WebRequest -Uri "https://github.com/KSP-CKAN/CKAN/releases/download/v1.35.2/ckan.exe" -OutFile "$($env:LOCALAPPDATA)\Programs\ckan.exe"
$CkanLnk = (New-Object -comObject WScript.Shell).CreateShortcut("$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs\ckan.lnk")
$CkanLnk.TargetPath = "$($env:LOCALAPPDATA)\Programs\ckan.exe"
$CkanLnk.Save()
```

Install OpenTTD jgrpp:
```ps
Invoke-WebRequest -Uri "https://github.com/JGRennison/OpenTTD-patches/releases/download/jgrpp-0.62.0/openttd-jgrpp-0.62.0-windows-win64.zip" -OutFile "$((gi $env:temp).fullname)\dots\openttd.zip"
Expand-Archive -Path "$((gi $env:temp).fullname)\dots\openttd.zip" -DestinationPath "$((gi $env:temp).fullname)\dots"
Copy-Item -Recurse "$((gi $env:temp).fullname)\dots\openttd-jgrpp-0.62.0-windows-win64" -Destination "$($env:LOCALAPPDATA)\Programs\openttd"
$OttdLnk = (New-Object -comObject WScript.Shell).CreateShortcut("$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs\OpenTTD.lnk")
$OttdLnk.TargetPath = "$($env:LOCALAPPDATA)\Programs\openttd\openttd.exe"
$OttdLnk.Save()
```

## Configuration notes

Running `a git setup` and co won't work with `.config/git/config` being readonly (lots of atools are very particular about it) so need to manually install this. Plus atools override git anyway so whatever. There's a hack in `homes/tedj_wbus.nix` to get this working.

I haven't been able to get git commit signing within a4c to work yet. There is some problem related to GPG agent forwarding from `homebus:${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.extra` to `a4c:${HOME}/.gnupg/S.gpg-agent` but it's probably related to the NFS home or some more arcane restriction with a4c/Docker.
