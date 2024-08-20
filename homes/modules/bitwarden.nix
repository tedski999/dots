# bitwarden cli through bemenu
{ pkgs, ... }: {
  home.packages = with pkgs; [
    bitwarden-cli
    libnotify
    (writeShellScriptBin "bmbwd" ''
      # TODO(later): extend to allow creation of items and choosing to copy other fields
      # bw get template item | jq ".name=\"My Login Item\" | .login=$(bw get template item.login | jq '.username="jdoe" | .password="myp@ssword123"')" | bw encode | bw create item

      show() {
        [ -z "$BW_SESSION" ] \
          && export BW_SESSION="$(: | bemenu --password indicator --list 0 --prompt 'Bitwarden Password:' | tr -d '\n' | base64 | bw unlock --raw)" \
          && [ -z "$BW_SESSION" ] \
          && notify-send -i lock -u critical "Bitwarden Failed" "Wrong password?" \
          && return 1

        [ -z "$items" ] \
          && notify-send -i lock "Bitwarden" "Updating items..." \
          && items="$(bw list items)"

        #echo "$items" | jq -r 'range(length) as $i | .[$i] | select(.type==1) | ($i | tostring)+" "+.name+" <"+.login.username+">"' | bemenu | cut -d' ' -f1
        echo "$items" | jq -r '.[] | select(.type==1) | .name+" <"+.login.username+"> "+.login.password' | bemenu | rev | cut -d' ' -f1 | rev | wl-copy --trim-newline
      }

      trap "show" USR1
      trap "unset items && show" USR2
      trap "unset items BW_SESSION && show" TERM
      while true; do sleep infinity & wait; done
    '')
  ];
}
