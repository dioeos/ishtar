{ pkgs, vars, ... }:

{
  imports = [
    ../../modules/nixos/base.nix

    ./disko.nix
  ];

  networking.hostName = "ishtar1";
}
