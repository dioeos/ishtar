{ config, ... }: {
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

  sops.secrets.client-id-config = {
    owner = "podman-captain";
    group = "podman-captain";
    mode = "0400";
    sopsFile = ../../../secrets/client-id-config.json;
    format = "json";
    key = "";
  };
}
