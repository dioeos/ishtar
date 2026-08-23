{ pkgs ? import <nixpkgs> {}, colmena }:

pkgs.mkShell {
  packages = with pkgs; [
    nixd
    nixfmt
    colmena

    (terraform.withPlugins (p: [
      p.null
      p.external
      p.oci
    ]))

    jq
    just
    sops
  ];

  shellHook = ''
    echo "Entered Ishtar Shell..."
  '';
}
