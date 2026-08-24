{ pkgs, inputs }:

pkgs.testers.runNixOSTest {
  name = "containers-module-test";

  nodes.machine = { ... }: {
    _module.args = { inherit inputs; };

    imports = [
      inputs.home-manager.nixosModules.home-manager
      inputs.quadlet-nix.nixosModules.quadlet
      ../modules/services/containers
    ];
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    machine.succeed("id podman-captain")
    machine.succeed("getent group podman-captain")

    machine.succeed("test -d /home/podman-captain")
    machine.succeed("test -d /var/lib/podman-captain")

    machine.wait_for_unit("user@$(id -u podman-captain).service")

    machine.succeed(
      "loginctl show-user podman-captain -p Linger --value | grep -q yes"
    )
  '';
}
