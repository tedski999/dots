function dmenu --wraps=dmenu --description "dmenu wrapper to apply customisations"
	command dmenu -fn "Terminus (TTF):size=13" -nb "#000" -sb "#181818" -m (bspc query --monitors --monitor focused --names) $argv
end
