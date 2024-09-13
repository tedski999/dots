{ pkgs, inputs, ... }: {

  home.packages = [ inputs.nixgl.packages.${pkgs.system}.nixGLIntel ];

}
