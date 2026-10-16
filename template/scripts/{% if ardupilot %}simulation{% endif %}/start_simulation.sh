#!/bin/bash
# usage: start_simulation.sh [gazebo]
# Starts the simulation containers, then follows each one's logs in a tmux session. With "gazebo", SITL flies in Gazebo
# (docker-compose.gazebo.yml layered on docker-compose.yml) instead of with its built-in physics.
set -e

# LOCAL_WORKSPACE_FOLDER is only set inside the dev container
if [ -z "${LOCAL_WORKSPACE_FOLDER:-}" ]; then
  echo "Run this from a terminal in the dev container" >&2
  exit 1
fi

compose_dir="docker/compose/simulation"
compose_files=(-f "${compose_dir}/docker-compose.yml")
if [ "$1" = "gazebo" ]; then
  compose_files+=(-f "${compose_dir}/docker-compose.gazebo.yml")
fi

# allow the simulation containers to open windows on the host display
xhost +local:

# Starts the services in dependency order (building their images the first time)
docker compose "${compose_files[@]}" up -d

# A session left from an earlier run is replaced, so the windows match the services started now
tmux kill-session -t simulation 2>/dev/null || true
tmux new-session -d -s simulation '/bin/bash'
tmux source-file ./.tmux.conf

tmux_window() {
  local win_name="$1"
  shift
  tmux new-window -n "${win_name}"
  tmux select-window -t "${win_name}"
  tmux send-keys "$*" KPENTER
}

for service in $(docker compose "${compose_files[@]}" config --services); do
  tmux_window "${service}" "docker compose ${compose_files[*]} logs -f ${service}"
done
# tmux can't attach from inside another tmux session, but it can switch to this one
if [ -n "${TMUX:-}" ]; then
  tmux switch-client -t simulation
else
  tmux attach-session -t simulation
fi
