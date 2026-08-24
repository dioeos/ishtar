{ pkgs, inputs }:

{
  containers-module-test = import ./containers-module-test.nix { inherit pkgs inputs; };
  containers-reboot-test = import ./containers-reboot-test.nix { inherit pkgs inputs; };
}
