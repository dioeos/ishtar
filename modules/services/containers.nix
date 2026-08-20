{ inputs, ... }:

{
  imports = [
    inputs.arion.nixosModules.arion
  ];

  virtualisation = {
    docker.enable = true;
    arion = {
      backend = "docker";
    };
  };
}
