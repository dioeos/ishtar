{ pkgs }:

{
  waits-for-tailscale = import ./waits-for-tailscale.nix { inherit pkgs; };
}
