{ inputs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/podman-captain/minecraft-server 0750 podman-captain podman-captain -"
    "d /var/lib/podman-captain/minecraft-server/data 0750 podman-captain podman-captain -"
  ];
  home-manager.users.podman-captain = {
    imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

    virtualisation.quadlet.containers.minecraft-server = {
      autoStart = true;
      containerConfig = {
        image = "docker.io/itzg/minecraft-server:latest";
        publishPorts = [ "25565:25565" ];
        userns = "keep-id";

        environments = {
          EULA = "TRUE";
          TYPE = "PAPER";
          VERSION = "LATEST";
          MEMORY = "4G";
        };

        volumes = [
          "/var/lib/podman-captain/minecraft-server/data:/data"
        ];
      };
    };
  };
}
