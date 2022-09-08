## Huzzah, dotfiles

My personal Linux scripts and configs, all in one place.
Each branch is dedicated to a different device.

```
git clone --bare git://src.h8c.de/dots .local/dots
git --git-dir .local/dots --work-tree . checkout <DEVICE>
sh init.sh
```
