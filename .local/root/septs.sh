#!/bin/sh

# partition disk
boot="/dev/xxxx"
swap="/dev/yyyy"
root0="/dev/aaaa"
root1="/dev/bbbb"
root2="/dev/cccc"
root3="/dev/dddd"

# format partitions
mkfs.fat "$boot" -F 32 -n SEPTS_BOOT
mkswap "$swap" --label SEPTS_SWAP
mkfs.btrfs "$root0" "$root1" "$root2" "$root3" --data raid1 --label SEPTS_ROOT
mount /dev/disk/by-label/SEPTS_ROOT /mnt
btrfs subvolume create /mnt/@
btrfs subvolume set-default /mnt/@
umount /mnt

# install system TODO: copy partitions from some .img
mount /dev/disk/by-label/SEPTS_ROOT -o ssd,compress=zstd:1 /mnt
rsync --archive --verbose --hard-links --whole-file p2/ /mnt/
mount /dev/disk/by-label/SEPTS_BOOT /mnt/boot/firmware
rsync --archive --verbose --hard-links --whole-file p1/ /mnt/boot/firmware/

# configure system for first boot
echo '' > /mnt/boot/firmware/ssh.txt
echo 'ski:$6$rpfb7X6RPS1KorIp$nsdCV7lgLllYgmGREA.3q1t7/KCSs7b4o4Ve.vCD1KOYFs/YoJFRFmsNj1XYtrHCbEyXulrnIuSEp6VoTMg80/' > /mnt/boot/firmware/userconf.txt
echo 'console=serial0,115200 console=tty1 root=LABEL=SEPTS_ROOT rootfstype=btrfs rootflags=device=/dev/sda3,device=/dev/sdb1,device=/dev/sdc1,device=/dev/sdd1 rootwait fsck.repair=no' > /mnt/boot/firmware/cmdline.txt
echo 'proc /proc proc defaults 0 0
LABEL=SEPTS_ROOT / btrfs defaults,noatime,ssd,compress=zstd:1,autodefrag,subvol=/@ 0 0
LABEL=SEPTS_ROOT /media/btrfs btrfs defaults,noatime,ssd,compress=zstd:1,autodefrag,subvol=/ 0 0
LABEL=SEPTS_BOOT /boot/firmware vfat defaults 0 1
LABEL=SEPTS_SWAP none swap defaults 0 0' > /mnt/etc/fstab
umount --recursive /mnt

# configure system after first boot
sh -c "$(curl https://dots.h8c.de)" -- init septs
