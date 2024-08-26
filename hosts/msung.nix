# TODO(nixos): msung
{ config, lib, nixpkgs, ... }: {
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.initrd.luks.devices."enc".device = "/dev/disk/by-label/MSUNG_ROOT";
  fileSystems."/" = { device = "/dev/disk/by-label/MSUNG_LVM_ROOT"; fsType = "btrfs"; options = [ "subvol=root" "compress=zstd" "noatime" ]; };
  fileSystems."/home" = { device = "/dev/disk/by-label/MSUNG_LVM_ROOT"; fsType = "btrfs"; options = [ "subvol=home" "compress=zstd" "noatime" ]; };
  fileSystems."/nix" = { device = "/dev/disk/by-label/MSUNG_LVM_ROOT"; fsType = "btrfs"; options = [ "subvol=nix" "compress=zstd" "noatime" ]; };
  fileSystems."/var/log" = { device = "/dev/disk/by-label/MSUNG_LVM_ROOT"; fsType = "btrfs"; options = [ "subvol=log" "compress=zstd" "noatime" ]; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/MSUNG_BOOT"; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };
  swapDevices = [ { device = "/dev/disk/by-label/MSUNG_LVM_SWAP"; } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking.hostName = "msung";
  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Dublin";

  #i18n.defaulLlocale = "en_IE.UTF-8";
  #console.keymap = "ie";

  users."users"."ski".isNormalUser = true;
  users."users"."ski".extraGroups = [ "wheel" ];

  system.copySystemConfiguration = true;
  system.stateVersion = "24.05";
}
