# shellcheck shell=bash
# Sourced from ~/.bashrc inside the dev container

workspace_dir="/home/user/workspace"

# shellcheck source=/dev/null
. "/opt/ros/${ROS_DISTRO}/setup.bash"
# shellcheck source=/dev/null
. /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash

if [ -f "${workspace_dir}/.venv/bin/activate" ]; then
  # shellcheck source=/dev/null
  . "${workspace_dir}/.venv/bin/activate"
  # Builds with the venv's Python, as `just build` does, so nodes can import the venv's packages
  colcon() { python -m colcon "$@"; }
fi

if [ -f "${workspace_dir}/install/setup.bash" ]; then
  # shellcheck source=/dev/null
  . "${workspace_dir}/install/setup.bash"
fi

eval "$(just --completions bash)"
