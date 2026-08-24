{ pkgs }:

let
  tailscaleAddress = "100.78.3.78";
  waitForTailscale = import ../utils/wait-for-tailscale.nix {
    inherit pkgs;
  };
in

pkgs.testers.runNixOSTest {
  name = "fast-note-sync-waits-for-tailscale-test";

  nodes.machine = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.iproute2
    ];

    systemd.services.fast-note-sync-service-test = {
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStartPre = "${waitForTailscale}/bin/wait-for-tailscale";
        ExecStart = "${pkgs.coreutils}/bin/touch /tmp/fast-note-sync-service-started";
      };
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed(
      "systemctl start --no-block fast-note-sync-service-test.service"
    )
    machine.fail("test -e /tmp/fast-note-sync-service-started")
    machine.succeed("ip link add tailscale0 type dummy")
    machine.succeed("ip link set tailscale0 up")
    machine.fail("test -e /tmp/fast-note-sync-service-started")
    machine.succeed("ip addr add ${tailscaleAddress}/32 dev tailscale0")
    machine.wait_until_succeeds(
      "test -e /tmp/fast-note-sync-service-started",
      timeout=10
    )
    machine.wait_for_unit("fast-note-sync-service-test.service")
  '';
}
