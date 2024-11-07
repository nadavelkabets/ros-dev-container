#!/bin/bash
set -e

if [ $EUID == 0]; then
  echo "You must run this script without sudo permissions"
  exit 1
fi

sudo apt install docker.io
# enable user to access docker without sudo
sudo usermod -aG docker $USER
wget https://update.code.visualstudio.com/commit:0ee08df0cf4527e40edc9aa28f4b5bd38bbff2b2/linux-x64/stable -O ~/Downloads/vscode.tar.gz
mkdir -p ~/.code
tar --strip 1 -zxvf ~/Downloads/vscode.tar.gz -C ~/.code
sudo ln -s ~/.code/bin/code /usr/bin/code
rm ~/Downloads/vscode.tar.gz

echo "Reboot for docker to work correctly"