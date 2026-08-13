{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "ishtar-install" ''
      set -euo pipefail

      if [ "$#" -ne 1 ]; then
        echo "Usage: ishtar-install <hostname>"
        exit 1
      fi

      TARGET_HOST="$1"

      echo "Starting Ishtar custom ISO installation..."
      echo "Hostname target: $TARGET_HOST"

      git clone https://github.com/dioeos/ishtar /tmp/ishtar
      cd /tmp/ishtar

      echo "Repository successfully cloned, continuing..."

      # CALL DISKO CLI COMMAND FOR HOST MACHINE DISKO FILE
    '')
  ];
}
