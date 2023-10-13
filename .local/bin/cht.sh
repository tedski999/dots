#!/bin/sh

export PATH=$(echo "$PATH" | tr ":" "\n" | grep -v "$(dirname -- "$0")" | tr "\n" ":")

hash cht.sh 2>/dev/null && exec cht.sh $@

opt="$HOME/.local/opt/cht.sh"
bin="$opt/cht.sh"
src="cht.sh/:cht.sh"

[ -d "$opt" ] || { mkdir -p "$opt" && curl -fL "$src" > "$bin" && chmod +x "$bin"; } || { rm -r "$opt"; exit 1; }

exec "$bin" $@
