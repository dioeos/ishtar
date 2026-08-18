{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    vim

    efibootmgr
    gptfdisk
    ghostty.terminfo
    parted
    util-linux

    curl
    wget
  ];
}
