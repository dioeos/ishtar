{ inputs, ... }:

{
  imports = [
    inputs.arion.nixosModules.arion
  ];

  virtualisation = {
    podman.enable = true;
    arion.backend = "podman-socket";
  };
}
