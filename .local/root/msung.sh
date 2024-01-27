#!/bin/sh

# Assuming minimal Debian 12 install, MSUNG_{BOOT,SWAP,ROOT} with btrfs root /@ subvolume

# TODO

sudo apt install curl git xz-utils
sh -c "$(curl https://dots.h8c.de)" -- init msung
sudo apt purge curl git xz-utils
