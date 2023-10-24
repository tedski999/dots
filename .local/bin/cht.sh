#!/bin/sh

for bin in $(realpath $(which -a cht.sh)); do
	[ "$(realpath $0)" != "$bin" ] && [ -x "$bin" ] && exec "$bin" "$@"
done

opt="$HOME/.local/opt/cht.sh"
bin="$opt/cht.sh"
src="cht.sh/:cht.sh"

[ -d "$opt" ] || { mkdir -p "$opt" && curl -fL "$src" > "$bin" && chmod +x "$bin"; } || { rm -r "$opt"; exit 1; }

exec "$bin" "$@"
