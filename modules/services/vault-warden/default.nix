{ pkgs, inputs, ... }:

let
  waitForTailscale = import ../../../utils/wait-for-tailscale.nix { inherit pkgs; };
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/podman-captain/vw 0750 podman-captain podman-captain -"
    "d /var/lib/podman-captain/vw/data 0750 podman-captain podman-captain -"
  ];
  home-manager.users.podman-captain = {
    imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

    virtualisation.quadlet.containers.vault-warden = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";

        ExecStartPre = [
          "${waitForTailscale}/bin/wait-for-tailscale"
        ];
      };
      containerConfig = {
        image = "vaultwarden/server:latest";
        publishPorts = [ "127.0.0.1:8000:8080" ];
        userns = "keep-id";

        environments = {
          ROCKET_PORT = "8080";
          EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "ssh-key-vault-item ssh-agent";
        };

        volumes = [
          "/var/lib/podman-captain/vw/data:/data"
        ];
      };
    };
  };
}
