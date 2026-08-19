{ pkgs, vars, ... }:

{
  imports = [
    ../../modules/nixos/base.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "ishtar1";
}
