{ config, inputs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/podman-captain/minecraft-server 0750 podman-captain podman-captain -"
    "d /var/lib/podman-captain/minecraft-server/data 0750 podman-captain podman-captain -"
  ];
  sops.secrets.minecraft-whitelist = {};
  sops.templates."minecraft-env-whitelist" = {
    owner = "podman-captain";
    group = "podman-captain";
    mode = "0400";

    content = ''
      WHITELIST=${config.sops.placeholder.minecraft-whitelist}
    '';
  };

  sops.secrets.dmcc-token = {};
  sops.secrets.discord-channel-id = {};
  sops.templates."discord-mc-chat.json" = {
    owner = "podman-captain";
    group = "podman-captain";
    mode = "0400";

    content = ''
      {
        "generic": {
          "language": "en_us",
          "botToken": "${config.sops.placeholder.dmcc-token}",
          "showServerStatusInBotStatus": true,
          "botPlayingActivity": "Minecraft (%onlinePlayerCount%)",
          "useWebhook": true,
          "channelId": "${config.sops.placeholder.discord-channel-id}",
          "broadcastChatMessages": false,
          "broadcastPlayerCommandExecution": false,
          "broadcastSlashCommandExecution": false,
          "announceDeathMessages": false,
          "announceAdvancements": false
        }
      }
    '';
  };

  home-manager.users.podman-captain = {
    imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

    virtualisation.quadlet.containers.minecraft-server = {
      autoStart = true;
      containerConfig = {
        image = "docker.io/itzg/minecraft-server:latest";
        publishPorts = [ "25565:25565" ];
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

          MODRINTH_PROJECTS = ''
            fabric-api
            lithium
            mods-command
            adventure-platform-mod
            discord-mc-chat
          '';
        };

        environmentFiles = [
          config.sops.templates."minecraft-env-whitelist".path
        ];

        volumes = [
          "/var/lib/podman-captain/minecraft-server/data:/data"
          "${config.sops.templates."discord-mc-chat.json".path}:/data/config/discord-mc-chat.json:ro"
        ];
      };
    };
  };
}
