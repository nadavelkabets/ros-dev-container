#!/bin/bash
set -e

vscode_commit="$1"
install_dir=/home/$USERNAME/.vscode-server/bin/$vscode_commit

wget -q --no-check-certificate https://update.code.visualstudio.com/commit:$vscode_commit/server-linux-x64/stable -O /tmp/vscode_server.tar.gz
mkdir -p $install_dir
tar --strip 1 -zxvf /tmp/vscode_server.tar.gz -C $install_dir
touch $install_dir/0
rm /tmp/vscode_server.tar.gz

mv $install_dir/bin/code-server $install_dir/bin/real-code-server
cp /tmp/scripts/run_patched_vscode_server.sh $install_dir/bin/code-server
chmod a+x $install_dir/bin/code-server