{ pkgs ? import <nixpkgs> }:

pkgs.mkShell {
  packages = with pkgs; [
    nixd
    nixfmt
    colmena
  ];

  shellHook = ''
    echo "Entered Ishtar Shell..."
  '';
}
