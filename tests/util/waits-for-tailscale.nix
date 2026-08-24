{ pkgs }:

let
  tailscaleAddress = "100.78.3.78";
  waitForTailscale = import ../../utils/wait-for-tailscale.nix { inherit pkgs; };
in

pkgs.testers.runNixOSTest {
  name = "waits-for-tailscale-util-test";

  nodes.machine = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.iproute2
    ];
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # start wait script in background
    machine.succeed(
      "systemd-run --unit=wait-for-tailscale-test ${waitForTailscale}/bin/wait-for-tailscale"
    )

    # tailscale0 not up yet, so wait script should be waiting still
    machine.succeed(
      "systemctl is-active --quiet wait-for-tailscale-test.service"
    )

    # starts tailscale0 but with no address
    machine.succeed("ip link add tailscale0 type dummy")
    machine.succeed("ip link set tailscale0 up")

    machine.succeed(
      "systemctl is-active --quiet wait-for-tailscale-test.service"
    )

    machine.succeed(
      "ip addr add ${tailscaleAddress}/32 dev tailscale0"
    )

    machine.wait_until_succeeds(
      "! systemctl is-active --quiet wait-for-tailscale-test.service || "
      "! systemctl is-active --quiet wait-for-tailscale-test.service >/dev/null"
    )

    machine.wait_until_succeeds(
      "systemctl show wait-for-tailscale-test.service -p Result --value | grep -q success"
    )
  '';
}
