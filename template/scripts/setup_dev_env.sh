#!/bin/bash
# Prepares an Ubuntu host: docker, docker compose v2, VS Code and its Dev Containers extension
set -euo pipefail

if [ "${EUID}" -eq 0 ]; then
  echo "You must run this script without sudo permissions"
  exit 1
fi

sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2 docker-buildx
# enable user to access docker without sudo
sudo usermod -aG docker "${USER}"

if ! command -v code >/dev/null; then
  case "$(uname -m)" in
    aarch64)
      arch=arm64
      ;;
    x86_64)
      arch=x64
      ;;
    *)
      echo "unknown arch: $(uname -m)"
      exit 1
      ;;
  esac

  vscode_deb="$(mktemp --suffix .deb)"
  chmod a+r "${vscode_deb}"
  wget -q "https://update.code.visualstudio.com/latest/linux-deb-${arch}/stable" -O "${vscode_deb}"
  sudo apt-get install -y "${vscode_deb}"
  rm "${vscode_deb}"
fi
code --install-extension ms-vscode-remote.remote-containers

echo "Reboot for docker to work correctly"
