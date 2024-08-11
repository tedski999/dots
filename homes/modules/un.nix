# decompression utility
# TODO(later): gzip gunzip instead? 7zip, unrar, etc... maybe just use ouch?
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "un" ''
      ft="$(file -b "$1" | tr "[:upper:]" "[:lower:]" || exit 1)"
      mkdir -p "''${2:-.}" || exit 1
      case "$ft" in
        "zip archive"*) unzip -d "''${2:-.}" "$1";;
        "gzip compressed"*) tar -xvzf "$1" -C "''${2:-.}";;
        "bzip2 compressed"*) tar -xvjf "$1" -C "''${2:-.}";;
        "posix tar archive"*) tar -xvf "$1" -C "''${2:-.}";;
        "xz compressed data"*) tar -xvJf "$1" -C "''${2:-.}";;
        #"rar archive"*) unrar x "$1" "''${2:-.}";;
        #"7-zip archive"*) p7zip x "$1" "-o''${2:-.}";;
        *) echo "Unable to un: $ft"; exit 1;;
      esac
    '')
  ];
}
