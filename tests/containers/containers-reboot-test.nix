{ pkgs, inputs }:

let
  testImage = pkgs.dockerTools.buildImage {
    name = "localhost/quadlet-test-server";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "quadlet-test-root";
      paths = [
        pkgs.busybox
      ];
      pathsToLink = [ "/bin" ];
    };

    config.Cmd = [
      "/bin/httpd"
      "-f"
      "-p"
      "8080"
    ];
  };
in
pkgs.testers.runNixOSTest {
  name = "containers-reboot-test";

  nodes.machine = { ... }: {
    _module.args = { inherit inputs; };

    imports = [
      inputs.home-manager.nixosModules.home-manager
      inputs.quadlet-nix.nixosModules.quadlet
      ../../modules/services/containers
    ];

    home-manager.users.podman-captain = {
      imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

      # mimics core logic for existing containers
      virtualisation.quadlet.containers.test-container = {
        autoStart = true;
        serviceConfig = {
          RestartSec = "10";
          Restart = "always";
        };

        containerConfig = {
          image = "localhost/quadlet-test-server:latest";
          publishPorts = [ "127.0.0.1:8080:8080" ];
          userns = "keep-id";
        };
      };
    };
  };

  testScript = ''
    # =================
    # FIRST BOOT
    # =================
    machine.wait_for_unit("multi-user.target")
    machine.succeed("systemctl start network-online.target")

    podman_cap_uid = machine.succeed(
      "id -u podman-captain"
    ).strip()

    machine.succeed(
      f"systemctl start user@{podman_cap_uid}.service"
    )
    machine.succeed(
      "test \"$(loginctl show-user podman-captain -p Linger --value)\" = yes"
    )

    machine.succeed(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "podman load -i ${testImage}"
    )

    machine.succeed(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "podman image exists localhost/quadlet-test-server:latest"
    )

    machine.succeed(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "systemctl --user restart test-container.service"
    )

    machine.succeed(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "systemctl --user cat test-container.service"
    )

    # =================
    # REBOOT
    # =================

    machine.succeed("systemctl reboot --no-block")
    machine.wait_for_shutdown()
    machine.start()

    machine.wait_for_unit("multi-user.target")
    machine.succeed("systemctl start network-online.target")

    machine.succeed(
      "test \"$(loginctl show-user podman-captain -p Linger --value)\" = yes"
    )

    machine.wait_until_succeeds(
      f'systemctl is-active "user@{podman_cap_uid}.service"'
    )

    machine.succeed(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      'systemctl --user cat test-container.service'
    )

    machine.wait_until_succeeds(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      'systemctl --user is-active test-container.service'
    )
  '';
}
