#!/bin/bash
# Runs inside the dev container when it's created, before VS Code connects (devcontainer.json onCreateCommand),
# so the environment VS Code captures from ~/.bashrc already includes the workspace overlay
set -eo pipefail

cd /home/user/workspace
# shellcheck source=/dev/null
source "/opt/ros/${ROS_DISTRO}/setup.bash"

if [ -f pyproject.toml ]; then
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
