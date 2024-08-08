# bunch of necessary cli tools
{ pkgs, ... }: {
  home.packages = with pkgs; [
    coreutils
    findutils
    diffutils
    procps
    gnused
    file
    curl
    gawk
    gnutar
    zip unzip
    #rar unrar
    #p7zip
    jq
  ];
}
