#!/bin/bash
# Runs inside the dev container when it's created, before VS Code connects (devcontainer.json onCreateCommand).
# VS Code captures its environment from ~/.bashrc before this runs, so its extensions only see the venv and the build
# after a window reload.
set -eo pipefail

cd /home/user/workspace

# apt in the container: package names tab-complete, and installs work without an update first. The image leaves the
# package lists out and keeps Docker's apt config, which turns off the cache that completion reads. That config also
# deleted downloaded packages after each install, which apt-get otherwise keeps, so installs are set to delete them.
sudo rm -f /etc/apt/apt.conf.d/docker-clean
echo 'APT::Keep-Downloaded-Packages "false";' | sudo tee /etc/apt/apt.conf.d/no-keep-downloads >/dev/null
sudo apt-get update || echo "Fetching the apt package lists failed: run 'sudo apt-get update' before installing packages"

# shellcheck source=/dev/null
source "/opt/ros/${ROS_DISTRO}/setup.bash"

# uv manages the Python dependencies when pyproject.toml has a [project] table
if grep -qs '^\[project\]' pyproject.toml; then
  # --system-site-packages keeps the ROS Python packages importable from the venv
  uv venv --system-site-packages --python /usr/bin/python3 --allow-existing .venv
  touch .venv/COLCON_IGNORE
  uv sync
fi

if [ ! -f install/setup.bash ] && [ -n "$(find src -name package.xml -print -quit)" ]; then
  just build || echo "The workspace build failed: fix it, run 'just build', then reload the window"
fi

if git rev-parse --git-dir >/dev/null 2>&1; then
  pre-commit install
else
  echo "Not a git repository yet, run 'pre-commit install' after 'git init'"
fi
