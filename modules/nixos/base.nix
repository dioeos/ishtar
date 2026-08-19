{ pkgs, vars, ... }: 

{
  environment.systemPackages = with pkgs; [
    git
    ghostty.terminfo
    vim
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
    timeout = 10;
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = [ "root" "dio" ];
    };
  };

  users.mutableUsers = false;
  users.users.${vars.userName} = {
    isNormalUser = true;
    description = vars.userName;
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      vars.sshPublicKeyIshtarUser
    ];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = false;

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };
    fstrim.enable = true;
  };

  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
  };

  programs.zsh.enable = true;
  time.timeZone = vars.timeZone;
  system.stateVersion = "26.05";
}
