{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nur, home-manager, nixgl, ...  }@inputs:
  let
    lib = nixpkgs.lib // home-manager.lib;
  in {

    # `nix --extra-experimental-features 'nix-command flakes' develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#<name>` shell to bootstap any system
    devShells = lib.genAttrs [ "aarch64-linux" "x86_64-linux" ] (system: let
      pkgs = (import nixpkgs) { inherit system; };
    in {
      default = pkgs.mkShell {
        NIX_CONFIG = "extra-experimental-features = nix-command flakes\nuse-xdg-base-directories = true";
        buildInputs = [ pkgs.home-manager ];
      };
    });

    # `home-manager switch --flake .#<name>` for declarative home management
    homeConfigurations = {
      "ski@msung" = lib.homeManagerConfiguration {
        modules = [ ./homes/ski_msung.nix ];
        pkgs = (import nixpkgs) { system = "x86_64-linux"; };
      };
      "tedj@tedj" = lib.homeManagerConfiguration {
        modules = [ ./homes/tedj_work.nix ];
        pkgs = (import nixpkgs) { system = "x86_64-linux"; overlays = [ nur.overlay nixgl.overlay ]; };
      };
      "tedj@tedj-home-xrxhs" = lib.homeManagerConfiguration {
        modules = [ ./homes/tedj_homebus.nix ];
        pkgs = (import nixpkgs) { system = "x86_64-linux"; };
      };
    };

  };
}
