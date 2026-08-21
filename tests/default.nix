{ pkgs }:

{
  fast-note-sync-waits-for-tailscale =
    import ./fast-note-sync-service.nix {
      inherit pkgs;
    };
}
