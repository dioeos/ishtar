{ pkgs, vars, ... }:

{
  imports = [
    ../../modules/nixos/base.nix

    ../../modules/services/cowsay.nix

    ../../modules/services/containers.nix
    ../../modules/services/tailscale.nix

    ../../modules/services/fast-note-sync

    ./disko.nix
    ./hardware-configuration.nix
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
}
