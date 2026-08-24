{ pkgs, inputs }:

{
  fast-note-sync-service-test = import ./fast-note-sync-service.nix { inherit pkgs inputs; }; 
}
