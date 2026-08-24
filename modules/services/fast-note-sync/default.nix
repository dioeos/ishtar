{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.services.fast-note-sync;
  waitForTailscale = import ../../../utils/wait-for-tailscale.nix { inherit pkgs; };
in
{
  options.services.fast-note-sync = {
    enable = lib.mkEnableOption "fast-note-sync";
    image = lib.mkOption {
      type = lib.types.str;
      default = "haierkeys/fast-note-sync-service:latest";
    };
  };

  config = lib.mkIf cfg.enable {
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

          ExecStartPre = [ "${waitForTailscale}/bin/wait-for-tailscale" ];
        };

        containerConfig = {
          image = cfg.image;
          publishPorts = [ "127.0.0.1:9000:9000" ];
          userns = "keep-id";

          volumes = [
            "/var/lib/podman-captain/fast-note-sync/storage:/fast-note-sync/storage"
            "/var/lib/podman-captain/fast-note-sync/config:/fast-note-sync/config"
          ];
        };
      };
    };
  };
}
