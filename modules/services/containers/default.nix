{ ... }:

{
  virtualisation.quadlet.enable = true;

  users.groups.podman-captain = {};

  users.users.podman-captain = {
    isNormalUser = true;
    group = "podman-captain";
    home = "/home/podman-captain";
    createHome = true;

    linger = true;
    autoSubUidGidRange = true;
  };

  home-manager.users.podman-captain = {
    home = {
      username = "podman-captain";
      homeDirectory = "/home/podman-captain";
      stateVersion = "26.05";
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/podman-captain 0750 podman-captain podman-captain -"
  ];
}
