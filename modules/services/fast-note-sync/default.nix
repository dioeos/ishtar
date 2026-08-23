{ pkgs, inputs, ... }:

let
  waitForTailscale = import ./wait-for-tailscale.nix { inherit pkgs; };
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/podman-captain/fast-note-sync 0750 podman-captain podman-captain -"
    "d /var/lib/podman-captain/fast-note-sync/storage 0750 podman-captain podman-captain -"
    "d /var/lib/podman-captain/fast-note-sync/config 0750 podman-captain podman-captain -"
  ];
  home-manager.users.podman-captain = {
    imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

    virtualisation.quadlet.containers.fast-note-sync = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";

        ExecStartPre = [
          "${waitForTailscale}/bin/wait-for-tailscale"
        ];
      };
      containerConfig = {
        image = "haierkeys/fast-note-sync-service:latest";
        publishPorts = [ "100.78.3.78:9000:9000" ];
        userns = "keep-id";

        volumes = [
          "/var/lib/podman-captain/fast-note-sync/storage:/fast-note-sync/storage"
          "/var/lib/podman-captain/fast-note-sync/config:/fast-note-sync/config"
        ];
      };
    };
  };
}
