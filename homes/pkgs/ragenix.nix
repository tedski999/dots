{ pkgs, inputs, config, ... }: {

  imports = [ inputs.ragenix.homeManagerModules.default ];

  home.packages = [ inputs.ragenix.packages.${pkgs.system}.default ];

}
