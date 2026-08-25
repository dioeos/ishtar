{ ... }: {

  imports = [
    ./container.nix
    ./mc-secrets.nix
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/podman-captain/minecraft-server 0750 podman-captain podman-captain -"
    "d /var/lib/podman-captain/minecraft-server/data 0750 podman-captain podman-captain -"
    "d /var/lib/podman-captain/minecraft-server/data/config 0750 podman-captain podman-captain -"
  ];

}
