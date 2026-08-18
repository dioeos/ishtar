{ pkgs, vars, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./packages.nix
    ./install-script.nix
  ];

  nixpkgs.hostPlatform = { system = "x86_64-linux"; };

  users.users.ishtar = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      vars.sshPublicKeyIshtar
    ];
  };

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.motd = ''
    Welcome to the Ishtar ISO installer...

    Run:
     
      sudo ishtar-install
  '';
}
