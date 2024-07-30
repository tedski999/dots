{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nur, home-manager, nixgl, ...  } @ inputs:
  let
    lib = nixpkgs.lib // home-manager.lib;
    systems = [ "aarch64-linux" "x86_64-linux" ];
    forEachSystem = lib.genAttrs systems;
  in {

    # inherit lib;
    # overlays = import ./overlays { inherit inputs; };
    # packages = forEachSystem (system: import ./pkgs nixpkgs.legacyPackages.${system});
    #(import nixgl { inherit pkgs; }).auto.nixGLDefault

    # `nix --extra-experimental-features 'nix-command flakes' develop github:tedski999/dots --command home-manager switch --flake .config/nix#<name>` shell to bootstap any system
    devShell = forEachSystem (system: let
      pkgs = (import nixpkgs) { inherit system; };
    in pkgs.mkShell {
      NIX_CONFIG = "extra-experimental-features = nix-command flakes\nuse-xdg-base-directories = true";
      buildInputs = [ pkgs.home-manager ];
    });

    # `home-manager switch --flake .#<name>` for declaritive home management
    homeConfigurations = {
      "ski@msung" = lib.homeManagerConfiguration {
        modules = [ ./homes/ski_msung.nix ];
        pkgs = (import nixpkgs) { system = "x86_64-linux"; };
      };
      "tedj@tedj" = lib.homeManagerConfiguration {
        modules = [ ./homes/tedj_tedj.nix ];
        pkgs = (import nixpkgs) { system = "x86_64-linux"; overlays = [ nur.overlay nixgl.overlay ]; };
      };
      "tedj@us256" = lib.homeManagerConfiguration {
        modules = [ ./homes/tedj_us256.nix ];
        pkgs = (import nixpkgs) { system = "aarch64-linux"; };
      };
    };

  };
}
