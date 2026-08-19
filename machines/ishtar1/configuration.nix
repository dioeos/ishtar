{ pkgs, vars, ... }:

{
  imports = [
    ../../modules/nixos/base.nix

    ../../modules/services/cowsay.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "ishtar1";
}
