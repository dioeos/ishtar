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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix = {
      url = "github:SEIAROTg/quadlet-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      colmena,
      disko,
      sops-nix,
      quadlet-nix,
      home-manager,
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
            disko.nixosModules.disko
          ]
          ++ extraModules;
        };

        tests = import ./tests { inherit pkgs inputs; };

      ishtar1path = ./machines/ishtar1/configuration.nix;
    in
    {
      devShells.${workstation_system}.default = import ./shell.nix {
        inherit pkgs;
        colmena = colmena.packages.${workstation_system}.colmena;
      };

      checks.${workstation_system} = tests;

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = pkgs;
          specialArgs = { inherit inputs vars; };
        };

        ishtar1 = {
          nixpkgs.hostPlatform = "x86_64-linux";
          imports = [
            ishtar1path
            disko.nixosModules.disko
            quadlet-nix.nixosModules.quadlet
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ];

          deployment = {
            targetHost = "192.168.1.51";
            targetUser = "root";
          };
        };

        ishtar-edge = {
          nixpkgs.hostPlatform = "aarch64-linux";
          imports = [
            ./machines/ishtar-edge/configuration.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
          ];

          deployment = {
            targetHost = "150.136.10.248";
            targetUser = "root";
          };
        };
      };

      nixosConfigurations = {
        ishtar1 = mkNixOSConfig {
          hostConfig = ./machines/ishtar1/configuration.nix;
          hostPlatform = "x86_64-linux";

          extraModules = [
            quadlet-nix.nixosModules.quadlet
            home-manager.nixosModules.home-manager
          ];
        };

        ishtar-edge = mkNixOSConfig {
          hostConfig = ./machines/ishtar-edge/configuration.nix;
          hostPlatform = "aarch64-linux";
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

      packages.${workstation_system}.tests = pkgs.runCommand "tests" {
        buildInputs = builtins.attrValues tests;
      } ''
        mkdir -p $out
      '';
    };
}
