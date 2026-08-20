{ pkgs, vars, ... }:

{
  imports = [
    ../../modules/nixos/base.nix

    ../../modules/services/containers.nix
    ../../modules/services/tailscale.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "ishtar1";

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;

    age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets.tailscale-auth-key = {};
  };
}
