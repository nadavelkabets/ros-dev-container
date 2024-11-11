#!/bin/bash
set -e

if [ $EUID == 0]; then
  echo "You must run this script without sudo permissions"
  exit 1
fi

sudo apt install -y docker.io docker-compose
# enable user to access docker without sudo
sudo usermod -aG docker $USER

case $(uname -m) in

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

wget https://update.code.visualstudio.com/commit:0ee08df0cf4527e40edc9aa28f4b5bd38bbff2b2/linux-deb-${arch}/stable -O ~/Downloads/vscode.deb
sudo apt install ~/Downloads/vscode.deb

echo "Reboot for docker to work correctly"