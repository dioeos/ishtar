{ pkgs, vars, ... }:

{
  imports = [
    ../../modules/nixos/base.nix

    ../../modules/services/cowsay.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "ishtar1";

  deployment = {
    targetHost = "192.168.1.51";
    targetUser = "dio";
    sshOptions = [
      "-i"
      "/home/dio/.ssh/ishtar_user"
      "-o"
      "IdentitiesOnly=yes"
    ];
  };
}
