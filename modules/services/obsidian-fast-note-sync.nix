{ ... }:

{
  virtualisation.arion.projects.fast-note-sync-service.settings = {
    project.name = "fast-note-sync";

    services.fast-note-sync.service = {
      image = "haierkeys/fast-note-sync-service:latest";
      container_name = "fast-note-sync-service";
      restart = "unless-stopped";
    };
  };
}
