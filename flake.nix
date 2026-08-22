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

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      colmena,
      disko,
      arion,
      sops-nix,
      ...
    }:
    let
      workstation_system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = workstation_system;
        config = {
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "terraform"
          ];
        };
      };

      vars = import ./vars.nix;

      mkNixOSConfig =
        {
          hostConfig,
          hostPlatform ? "x86_64-linux",
          extraModules ? [ ],
          extraOverlays ? [ ]
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs vars; };

          modules = [
            {
              nixpkgs.hostPlatform = hostPlatform;
              nixpkgs.overlays = extraOverlays;
            }
            hostConfig
            sops-nix.nixosModules.sops
          ]
          ++ extraModules;
        };

      ishtar1path = ./machines/ishtar1/configuration.nix;
    in
    {
      devShells.${workstation_system}.default = import ./shell.nix {
        inherit pkgs;
        colmena = colmena.packages.${workstation_system}.colmena;
      };

      checks.${workstation_system} = import ./tests { inherit pkgs; };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = pkgs;
          specialArgs = { inherit inputs vars; };
        };

        ishtar1 = {
          imports = [
            ishtar1path
            disko.nixosModules.disko
            arion.nixosModules.arion
            sops-nix.nixosModules.sops
          ];

          deployment = {
            targetHost = "192.168.1.51";
            targetUser = "root";
            sshOptions = [
              "-i"
              "/home/dio/.ssh/ishtar"
              "-o"
              "IdentitiesOnly=yes"
            ];
          };
        };
      };

      nixosConfigurations = {
        ishtar1 = mkNixOSConfig {
          hostConfig = ./machines/ishtar1/configuration.nix;
          hostPlatform = "x86_64-linux";

          extraModules = [
            disko.nixosModules.disko
            arion.nixosModules.arion
          ];
        };

        ishtar-edge = mkNixOSConfig {
          hostConfig = ./machines/ishtar-edge/configuration.nix;
          hostPlatform = "aarch64-linux";

          extraModules = [
            disko.nixosModules.disko
          ];
        };

        iso1ishtar = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs vars; };
          modules = [
            ./iso/config.nix
          ];
        };
      };

      packages.aarch64-linux.oracle-vps-image =
        self.nixosConfigurations.ishtar-edge.config.system.build.OCIImage;

    };
}
