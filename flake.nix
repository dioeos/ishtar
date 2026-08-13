{
  description = "Ishtar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, colmena, ...}:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    vars = import ./vars.nix;

    mkNixOSConfig = path:
      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs vars; };
        modules = [ path ];
      };
  in
  {
    devShells.${system}.default = 
      import ./shell.nix { inherit pkgs; };

    colmenaHive = colmena.lib.makeHive {
      meta.nixpkgs = pkgs;
    };

    iso1ishtar = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs vars; };
      modules = [
        ./iso/config.nix
      ];
    };
  };
}
