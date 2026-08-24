{ pkgs, vars, ... }:

{
  imports = [
    ../../modules/nixos/base.nix

    ../../modules/services/tailscale.nix

    ../../modules/services/vault-warden
    ../../modules/services/minecraft

    ../../modules/services/containers

    ./disko.nix
    ./hardware-configuration.nix

    # === SERVICE MODULES ===
    ../../modules/services/fast-note-sync
  ];

  networking.hostName = "ishtar1";

  sops = {
    defaultSopsFile = ../../secrets/ishtar-secrets.yaml;
    age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets.dio-password = {
      neededForUsers = true;
    };
  };

  services = {
    fast-note-sync.enable = true;
  };
}
