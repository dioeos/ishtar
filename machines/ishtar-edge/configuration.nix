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

    ./disko.nix
  ];

  environment.systemPackages = with pkgs; [
    gitMinimal
    vim
    wireguard-tools
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
    secrets.tailscale-auth-key = {};
    secrets.wireguard-ishtar-edge-private-key = {};
  };

  users.mutableUsers = false;
  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        vars.sshPublicKeyIshtarEdgeRoot
      ];
    };
    ${vars.userName} = {
      isNormalUser = true;
      description = vars.userName;
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        vars.sshPublicKeyIshtarEdgeUser
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
      # openFirewall = true;
      openFirewall = false;
    };
    fstrim.enable = true;

    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    };
  };

  networking = {
    hostName = "ishtar-edge";
    useDHCP = true;

    firewall = {
      enable = true;

      # allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 51820 ];
      allowedTCPPorts = [ 25565 ];
      interfaces.tailscale0.allowedTCPPorts = [ 22 ];
    };

    nat = {
      enable = true;
      externalInterface = "enp0s6";
      internalInterfaces = [ "wg-edge0" ];
    };

    wireguard.interfaces = {
      wg-edge0 = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;

        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING \
            -i enp0s6 \
            -p tcp \
            --dport 25565 \
            -j DNAT --to-destination 10.100.0.2:25565

          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING \
            -o wg-edge0 \
            -p tcp \
            -d 10.100.0.2 \
            --dport 25565 \
            -j MASQUERADE
        '';

        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING \
            -i enp0s6
            -p tcp \
            -dport 25565 \
            -j DNAT --to-destination 10.100.0.2:25565

          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING \
            -o wg-edge0 \
            -p tcp \
            -d 10.100.0.2 \
            --dport 25565 \
            -j MASQUERADE
        '';

        privateKeyFile = config.sops.secrets.wireguard-ishtar-edge-private-key.path;

        peers = [
          {
            publicKey = vars.wireGuardPublicKeyIshtar1;
            allowedIPs = [ "10.100.0.2/32" ];
          }
        ];
      };
    };
  };
}
