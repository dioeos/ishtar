{
  pkgs,
  inputs,
}:

let
  tailscaleAddress = "100.78.3.78";
  testImage = pkgs.dockerTools.buildImage {
    name = "localhost/fast-note-sync-test";
    tag = "latest";

    config.Cmd = [
      "${pkgs.coreutils}/bin/sleep"
      "infinity"
    ];
  };
in

pkgs.testers.runNixOSTest {
  name = "fast-note-sync-service-test";

  nodes.machine = { pkgs, ... }: {
    _module.args = { inherit inputs; };
    environment.systemPackages = [
      pkgs.iproute2
      pkgs.podman
    ];

    imports = [
      inputs.home-manager.nixosModules.home-manager
      inputs.quadlet-nix.nixosModules.quadlet
      ../../modules/services/fast-note-sync
      ../../modules/services/containers
    ];

    home-manager.extraSpecialArgs = { inherit inputs; };
    services.fast-note-sync = {
      enable = true;
      image = "fast-note-sync-test:latest";
      autoStart = false;
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    podman_cap_uid = machine.succeed(
      "id -u podman-captain"
    ).strip()
    machine.succeed(
      f"systemctl start user@{podman_cap_uid}.service"
    )

    machine.succeed(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "systemctl --user cat fast-note-sync.service"
    )

    machine.succeed(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "systemctl --user cat fast-note-sync.service "
      "| grep wait-for-tailscale"
    )

    machine.succeed(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "systemctl --user start --no-block fast-note-sync.service"
    )

    machine.sleep(1)

    machine.fail(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "systemctl --user is-active --quiet fast-note-sync.service"
    )

    machine.succeed("ip link add tailscale0 type dummy")
    machine.succeed("ip link set tailscale0 up")

    machine.sleep(1)

    machine.fail(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "systemctl --user is-active --quiet fast-note-sync.service"
    )

    machine.succeed(
      "ip addr add ${tailscaleAddress}/32 dev tailscale0"
    )

    # check that service has moved out of start pre phase
    machine.wait_until_succeeds(
      "sudo -u podman-captain "
      f"XDG_RUNTIME_DIR=/run/user/{podman_cap_uid} "
      "systemctl --user show fast-note-sync.service "
      "--property=SubState --value "
      "| grep -v '^start-pre$'",
      timeout=10
    )
  '';
}
