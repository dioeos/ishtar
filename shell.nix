{ pkgs ? import <nixpkgs> }:

pkgs.mkShell {
  packages = with pkgs; [
    nixd
    nixfmt
  ];

  shellHook = ''
    echo "Entered Ishtar Shell..."
  '';
}
