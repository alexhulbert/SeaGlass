{
  description = "Seaglass home manager configuration";

  inputs = {
    coloreader = {
      url = "github:alexhulbert/coloreader";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wayhud = {
      url = "github:alexhulbert/wayhud";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    users = lib.filterAttrs
      (name: kind: kind == "directory" && builtins.pathExists (./users + "/${name}/default.nix"))
      (builtins.readDir ./users);
  in {
    homeConfigurations = lib.mapAttrs (name: _: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [ (./users + "/${name}/default.nix") ];
    }) users;
    checks.${system} = lib.mapAttrs (_: home: home.activationPackage) self.homeConfigurations;
  };
}
