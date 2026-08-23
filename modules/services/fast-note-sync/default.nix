{ pkgs, ... }:

let
  waitForTailscale = import ./wait-for-tailscale.nix { inherit pkgs; };
in
{
  virtualisation.arion.projects.fast-note-sync-service.settings = {
    project.name = "fast-note-sync";

    services.fast-note-sync.service = {
      image = "haierkeys/fast-note-sync-service:latest";
      container_name = "fast-note-sync-service";
      restart = "unless-stopped";

      dns = [
        "100.100.100.100"
      ];

      ports = [
        "100.78.3.78:9000:9000"
      ];
      volumes = [
        "/var/lib/fast-note-sync/storage:/fast-note-sync/storage"
        "/var/lib/fast-note-sync/config:/fast-note-sync/config"
      ];
    };
  };

  systemd.services.fast-note-sync-service = {
    after = [
      "tailscaled.service"
      "network-online.target"
    ];

    requires = [
      "tailscaled.service"
      "network-online.target"
    ];

    serviceConfig.ExecStartPre = "${waitForTailscale}/bin/wait-for-tailscale";
  };
}
