#!/bin/bash
set -e

if [ $EUID == 0]; then
  echo "You must run this script without sudo permissions"
  exit 1
fi

sudo apt install docker.io
# enable user to access docker without sudo
sudo usermod -aG docker $USER
curl -o ~/Downloads/vscode.tar.gz https://update.code.visualstudio.com/commit:0ee08df0cf4527e40edc9aa28f4b5bd38bbff2b2/linux-x64/stable
