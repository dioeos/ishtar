{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.services.homeassistant;
  waitForTailscale = import ../../../utils/wait-for-tailscale.nix { inherit pkgs; };
in
{
  options.services.homeassistant = {

    enable = lib.mkEnableOption "homeassistant";
    image = lib.mkOption {
      type = lib.types.str;
      default = "homeassistant/home-assistant:stable";
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/podman-captain/homeassistant 0750 podman-captain podman-captain -"
    ];

    home-manager.users.podman-captain = {
      imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

      virtualisation.quadlet.containers.homeassistant = {
        autoStart = cfg.autoStart;
        serviceConfig = {
          RestartSec = "10";
          Restart = "always";

          ExecStartPre = [ "${waitForTailscale}/bin/wait-for-tailscale" ];
        };

        containerConfig = {
          image = cfg.image;
          #@NOTE: On initial setup, reverse proxy must be set up within the UI.
          #       First load the initial server and then imperatively change it via UI.
          publishPorts = [ "127.0.0.1:8123:8123" ];
          userns = "keep-id";

          volumes = [
            "/var/lib/podman-captain/homeassistant:/config"
          ];
        };
      };
    };
  };
}
