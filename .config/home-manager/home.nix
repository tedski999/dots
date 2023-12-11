{ config, pkgs, ... }:
{
	home.username = "ski";
	home.homeDirectory = "/home/ski";
	home.stateVersion = "23.11";
	home.packages = [
		pkgs.hello
		(pkgs.writeShellScriptBin "my-hello" ''
			echo "Hello, ${config.home.username}!"
		'')
	];
	programs.home-manager.enable = true;
}
