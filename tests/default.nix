{ pkgs, inputs }:

let
  containerTests = import ./containers { inherit pkgs inputs; };
  utilTests = import ./util { inherit pkgs; };
  serviceTests = import ./services { inherit pkgs inputs; };
in
containerTests
// utilTests
// serviceTests
