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

      if [ "$EUID" -ne 0 ]; then
        echo "Error: this installer must be run as root."
        echo
        echo "Run:"
        echo "  sudo ishtar-install $TARGET_HOST"
      fi

      echo "=========================================="
      echo "Starting Ishtar custom ISO installation..."
      echo "=========================================="
      echo "Hostname target: $TARGET_HOST"

      REPO_DIR="/tmp/ishtar"

      rm -rf "$REPO_DIR"

      echo "Cloning Ishtar configuration..."

      git clone \
        https://github.com/dioeos/ishtar \
        "$REPO_DIR"

      cd "$REPO_DIR"

      echo "Repository successfully cloned, continuing..."

      HOST_DIR="./hosts/$TARGET_HOST"
      DISKO_CONFIG="$HOST_DIR/disko.nix"

      if [ ! -d "$HOST_DIR" ]; then
        echo "Error: host does not exist:"
        echo "  $HOST_DIR"
        exit 1
      fi

      if [ ! -d "$HOST_DIR" ]; then
        echo "Error: Disko configuration does not exist:"
        echo "  $DISKO_CONFIG"
        exit 1
      fi

      echo "Using Disko configuration:"
      echo "  $DISKO_CONFIG"
      echo

      echo "Detected block devices:"
      echo

      lsblk

      echo
      echo "WARNING:"
      echo "Disko is about to destroy and recreate the disk layout"
      echo "specified by:"
      echo
      echo "  $DISKO_CONFIG"
      echo
      echo -r -p "Continue? [y/N] " response

      case "$response" in
        y|Y||yes|YES)
          ;;
        *)
          echo "Installation cancelled."
          exit 1
          ;;
      esac

      echo "Running Disko..."

      disko \
        --mode destroy,format,mount \
        "$DISKO_CONFIG"

      echo "Disko configuration complete."

      echo "=========================================="
      echo "Installing the selected NixOS configuration
      echo "=========================================="

      nixos-install \
        --flake ".#$TARGET_HOST" \
        --no-root-passwd

      echo "=========================================="
      echo "Installation complete..."
      echo "You can now reboot:"
      echo "  reboot"
      echo "=========================================="
    '')
  ];
}
