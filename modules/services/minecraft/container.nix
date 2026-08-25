{ config, inputs, ... }: {
  home-manager.users.podman-captain = {
    imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

    virtualisation.quadlet.containers.minecraft-server = {
      autoStart = true;
      containerConfig = {
        image = "docker.io/itzg/minecraft-server:latest";
        publishPorts = [
          "25565:25565"
          "10.100.0.2:24454:24454/udp"
        ];
        userns = "keep-id";

        environments = {
          EULA = "TRUE";
          TYPE = "FABRIC";
          VERSION = "26.2";
          MEMORY = "4G";

          MOTD = "Ishtar";
          GAMEMODE = "survival";
          DIFFICULTY = "hard";

          VIEW_DISTANCE = "10";
          SIMULATION_DISTANCE = "8";

          ONLINE_MODE = "TRUE";
          ENABLE_WHITELIST = "TRUE";

          PVP = "TRUE";

          MODRINTH_ALLOWED_VERSION_TYPE = "beta";

          MODRINTH_PROJECTS = ''
            fabric-api
            lithium
            mods-command
            adventure-platform-mod
            discord-mc-chat:2.7.1-compat.2
            simple-voice-chat
            client-id
            sound-physics-remastered:beta
            cloth-config
            distanthorizons:beta
            dynamic-lights-creepermeyt
            no-enderman-grief

            yacl
            useless-reptile

            tectonic
            lithostitched
            terralith:2.6.4

            combatlog

            origins-legacy
            origins-legacy-classes
          '';
        };

        environmentFiles = [
          config.sops.templates."minecraft-env-whitelist".path
        ];

        volumes = [
          "/var/lib/podman-captain/minecraft-server/data:/data"
          "${config.sops.templates."discord-mc-chat.json".path}:/data/config/discord-mc-chat.json:ro"
          "${config.sops.secrets."client-id-config".path}:/data/config/clientid.json:ro"
        ];
      };
    };
  };
}
