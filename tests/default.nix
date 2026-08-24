{ pkgs, inputs }:

{
  waits-for-tailscale = import ./waits-for-tailscale.nix { inherit pkgs; };
  fast-note-sync-service = import ./fast-note-sync-service.nix { inherit pkgs inputs; };
  containers = import ./containers.nix { inherit pkgs inputs; };
}
