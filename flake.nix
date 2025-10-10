# TODO(later): beets
# TODO(nixos): live+instal iso
{
  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    home-manager = { url = "github:nix-community/home-manager/master"; inputs = { nixpkgs.follows = "nixpkgs"; }; };
    agenix = { url = "github:ryantm/agenix"; inputs = { nixpkgs.follows = "nixpkgs"; darwin.follows = ""; }; };
    nixgl = { url = "github:nix-community/nixGL"; inputs = { nixpkgs.follows = "nixpkgs"; }; };
    nur = { url = "github:nix-community/NUR"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs: let
    pkgs = inputs.nixpkgs.legacyPackages;
    lib = inputs.nixpkgs.lib // inputs.home-manager.lib;
    nur = inputs.nur.legacyPackages;
    msung = 0; septs = 1; work = 2; wbus = 3;
  in {
    #nixosConfigurations."msung" = lib.nixosSystem { modules = [ ./host.nix ]; };
    #nixosConfigurations."septs" = lib.nixosSystem { modules = [ ./host.nix ]; };
    homeConfigurations."ski@msung" = lib.homeManagerConfiguration { modules = [ ./home.nix ]; pkgs = pkgs.x86_64-linux; extraSpecialArgs = { home = msung; nur = nur.x86_64-linux; inherit inputs; }; };
    homeConfigurations."ski@septs" = lib.homeManagerConfiguration { modules = [ ./home.nix ]; pkgs = pkgs.x86_64-linux; extraSpecialArgs = { home = septs; nur = nur.x86_64-linux; inherit inputs; }; };
    homeConfigurations."tedj@work" = lib.homeManagerConfiguration { modules = [ ./home.nix ]; pkgs = pkgs.x86_64-linux; extraSpecialArgs = { home = work;  nur = nur.x86_64-linux; inherit inputs; }; };
    homeConfigurations."tedj@wbus" = lib.homeManagerConfiguration { modules = [ ./home.nix ]; pkgs = pkgs.x86_64-linux; extraSpecialArgs = { home = wbus;  nur = nur.x86_64-linux; inherit inputs; }; };
  };
}
