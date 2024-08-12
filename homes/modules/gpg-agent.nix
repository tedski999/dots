{ pkgs, ... }: {
  services.gpg-agent.enable = true;
  services.gpg-agent.defaultCacheTtl = 86400;
  services.gpg-agent.defaultCacheTtlSsh = 86400;
  services.gpg-agent.maxCacheTtl = 2592000;
  services.gpg-agent.maxCacheTtlSsh = 2592000;
  services.gpg-agent.pinentryPackage = pkgs.pinentry-curses;
}
