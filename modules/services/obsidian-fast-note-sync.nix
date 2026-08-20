{ ... }:

{
  virtualisation.arion.projects.fast-note-sync-service.settings = {
    project.name = "fast-note-sync";

    services.fast-note-sync.service = {
      image = "haierkeys/fast-note-sync-service:latest";
      container_name = "fast-note-sync-service";
      restart = "unless-stopped";
      ports = [
        "100.78.3.78:9000:9000"
      ];
      volumes = [
        "/var/lib/fast-note-sync/storage:/fast-note-sync/storage"
        "/var/lib/fast-note-sync/config:/fast-note-sync/config"
      ];
    };
  };
}
