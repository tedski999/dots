# rm but better
{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "del" ''
      IFS=$'\n'
      trash="${config.xdg.dataHome}/trash"
      format="trashed-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]Z[0-9][0-9]:[0-9][0-9]:[0-9][0-9]"

      case "$1" in "-u") shift; mode=u;; "-f") shift; mode=f;; *) mode=n;; esac
      [ -n "$1" ] || exit 1

      for file in $@; do
        case $mode in
          u) [ -n "$(find "$trash$(readlink -m -- "$file")" -maxdepth 1 -name "$format" 2>/dev/null)" ] \
            || { echo "'$file' not in trash" >&2; exit 1; };;
          *) [ -e "$file" ] \
            || { echo "'$file' does not exist" >&2; exit 1; };;
        esac
      done

      for file in $@; do
        dir="$trash$(readlink -m -- "$file")"
        case $mode in
          u)
            trashed="$(find "$dir" -maxdepth 1 -name "$format" -printf %f\\n)"
            [ "$(echo "$trashed" | wc -l)" -gt 1 ] && {
              echo "Multiple trashed files '$file'"
              echo "$trashed" | awk '{ printf "%d: %s\n", NR, $0 }'
              read -p "Choice: " i
              trashed="$(echo "$trashed" | awk "NR == $i { print; exit }")"
              [ -n "$trashed" ] || exit 1
            }
            mv -i -- "$dir/$trashed" "$file" || exit 1;;
          f) rm -rf "$file" || exit 1;;
          n) mkdir -p "$dir" && mv -i -- "$file" "$dir/$(date --utc +trashed-%FZ%T)" || exit 1;;
        esac
      done
    '')
  ];
}
