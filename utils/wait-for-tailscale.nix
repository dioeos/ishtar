{ pkgs }:

pkgs.writeShellApplication {
  name = "wait-for-tailscale";

  runtimeInputs = [
    pkgs.iproute2
    pkgs.gnugrep
    pkgs.coreutils
  ];

  text = ''
    until ip -4 addr show tailscale0 2>/dev/null \
      | grep -q 'inet '; do
      sleep 1
    done
  '';
}
