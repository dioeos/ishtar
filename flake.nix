{
  description = "Ishtar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, colmena, disko, ...}:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    vars = import ./vars.nix;

    mkNixOSConfig = hostConfig:
      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs vars; };
        modules = [ 
          hostConfig
          disko.nixosModules.disko
        ];
      };

    ishtar1path = ./machines/ishtar1/configuration.nix;
  in
  {
    devShells.${system}.default = 
      import ./shell.nix { 
        inherit pkgs; 
        colmena = colmena.packages.${system}.colmena;
      };

    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = pkgs;
        specialArgs = { inherit inputs vars; };
      };

      ishtar1 = {
        imports = [
          ishtar1path
          disko.nixosModules.disko
        ];
      };
    };

    nixosConfigurations = {
      ishtar1 = mkNixOSConfig ishtar1path;
      iso1ishtar = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs vars; };
        modules = [
          ./iso/config.nix
        ];
      };
    };
  };
}
