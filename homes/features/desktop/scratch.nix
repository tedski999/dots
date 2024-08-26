# toggleable scratchpads
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "scratch" ''
      id="$1"
      shift
      swaymsg -t get_tree | jq -re "recurse(.nodes[]?, .floating_nodes[]?) | select(.focused == true).app_id == \"$id\"" \
        && swaymsg "move scratchpad" \
        || swaymsg "[app_id=\"^$id$\"] focus" \
        || alacritty --class "$id" --command $@
    '')
  ];
}
