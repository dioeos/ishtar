{
  modulesPath,
  pkgs,
  vars,
  config,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

      ../../modules/services/cowsay.nix

    ./disko.nix
  ];

  environment.systemPackages = with pkgs; [
    gitMinimal
    vim
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };

  nixpkgs = {
    config.allowUnfree = true;
  };

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

  programs.zsh.enable = true;
  time.timeZone = vars.timeZone;
  system.stateVersion = "26.05";

  sops = {
    defaultSopsFile = ../../secrets/ishtar-secrets.yaml;
    age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets.dio-password = {
      neededForUsers = true;
    };
  };

  users.mutableUsers = false;
  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        vars.sshPublicKeyOracleVps
      ];
    };
    ${vars.userName} = {
      isNormalUser = true;
      description = vars.userName;
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        vars.sshPublicKeyOracleVpsUser
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
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };
    fstrim.enable = true;
  };

  networking = {
    hostName = "ishtar-edge";
    useDHCP = true;
  };
}
