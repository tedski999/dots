# bitwarden cli through bemenu
{ pkgs, ... }: {

  imports = [ ./bitwarden-cli.nix ./coreutils.nix ./jq.nix ./libnotify.nix ./procps.nix ];

  home.packages = with pkgs; [
    (writeShellScriptBin "bmbwd" ''
      # TODO(later): extend to allow creation of items and choosing to copy other fields
      # bw get template item | jq ".name=\"My Login Item\" | .login=$(bw get template item.login | jq '.username="jdoe" | .password="myp@ssword123"')" | bw encode | bw create item

      bmbw() {
        [ -z "$BW_SESSION" ] \
        && export BW_SESSION="$(: | bemenu -x indicator -l 0 -p 'Bitwarden Password:' | tr -d '\n' | base64 | bw unlock --raw)" \
        && [ -z "$BW_SESSION" ] \
        && notify-send -i lock -u critical "Bitwarden Failed" "Wrong password?" \
        && return 1

        [ -z "$items" ] \
        && notify-send -i lock "Bitwarden" "Updating items..." \
        && items="$(bw list items)"

        #echo "$items" | jq -r 'range(length) as $i | .[$i] | select(.type==1) | ($i | tostring)+" "+.name+" <"+.login.username+">"' | bemenu | cut -d' ' -f1
        echo "$items" | jq -r '.[] | select(.type==1) | .name+" <"+.login.username+"> "+.login.password' | bemenu -p 'Bitwarden' | rev | cut -d' ' -f1 | rev | wl-copy --trim-newline
      }

      trap "bmbw" USR1
      # TODO(later): doesnt work sometimes
      trap "unset items && bmbw" USR2
      trap "unset items BW_SESSION && bmbw" TERM
      while true; do sleep infinity & wait; done
    '')
  ];

  wayland.windowManager.sway.config.startup = [ { command = "pidof -x bmbwd || bmbwd"; always = true; } ];
  wayland.windowManager.sway.config.keybindings."Mod4+b"         = "exec pkill -USR1 bmbwd";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+b"   = "exec pkill -USR2 bmbwd";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+b" = "exec pkill -TERM bmbwd";

}
