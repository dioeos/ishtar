{
  pkgs,
  vars,
  config,
  ...
}:

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
    };
  };

  users.mutableUsers = false;
  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        vars.sshPublicKeyIshtar
      ];
    };
    ${vars.userName} = {
      isNormalUser = true;
      description = vars.userName;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        vars.sshPublicKeyIshtarUser
      ];
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets.dio-password.path;
    };
  };

  security.sudo.wheelNeedsPassword = true;

  services = {

    openssh = {
      enable = true;
      settings = {
        #root can only use ssh key
        PermitRootLogin = "prohibit-password";
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
