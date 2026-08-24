{ pkgs, inputs }:

{
  containers-module-test = import ./containers-module-test.nix { inherit pkgs inputs; };
}
