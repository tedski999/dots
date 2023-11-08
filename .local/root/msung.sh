#!/bin/sh

# partition disk
boot="/dev/xxxx"
swap="/dev/yyyy"
crypt="/dev/zzzz"

# format partitions
mkfs.fat "$boot" -F 32 -n BOOT
mkswap "$swap" --label SWAP
cryptsetup luksFormat "$crypt" --label CRYPT
cryptsetup open /dev/disk/by-label/CRYPT root
mkfs.btrfs /dev/mapper/root --label ROOT
mount /dev/disk/by-label/ROOT /mnt
btrfs subvolume create /mnt/@
btrfs subvolume set-default /mnt/@
umount /mnt

# install system
mount /dev/disk/by-label/ROOT /mnt
mount --mkdir /dev/disk/by-label/BOOT /mnt/boot
swapon /dev/disk/by-label/SWAP
pacstrap -K /mnt base linux linux-firmware sudo git grub efibootmgr
genfstab -L /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# configure system
grub-install --target x86_64-efi --efi-directory /boot --bootloader-id GRUB
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
useradd --create-home --skel "" --password '$1$$GCmgHODhlL0mzJDj68xxD/' --groups wheel video ski
su ski -c "$(curl https://dots.h8c.de)" -- init msung
