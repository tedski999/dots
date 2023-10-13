#!/bin/sh

export PATH=$(echo "$PATH" | tr ":" "\n" | grep -v "$(dirname -- "$0")" | tr "\n" ":")

hash cht.sh 2>/dev/null && exec cht.sh $@

opt="$HOME/.local/opt/cht.sh"
src="cht.sh/:cht.sh"

[ -d "$opt" ] || { mkdir -p "$opt" && curl -fsSL "$src" > "$opt/cht.sh" && chmod +x "$opt/cht.sh"; } || { rm -r "$opt"; exit 1; }

exec "$opt/cht.sh" $@
