#!/bin/bash
set -e
compose_file="docker/compose/simulation/docker-compose.yml"

# allow the simulation containers to open windows on the host display
xhost +local:

# Starts the services in dependency order (building their images the first time), then follows each one's logs
docker compose -f "${compose_file}" up -d

tmux new-session -d -s simulation '/bin/bash'
tmux source-file ./.tmux.conf

tmux_window() {
  local win_name="$1"
  shift
  tmux new-window -n "${win_name}"
  tmux select-window -t "${win_name}"
  tmux send-keys "$*" KPENTER
}

for service in $(docker compose -f "${compose_file}" config --services); do
  tmux_window "${service}" "docker compose -f ${compose_file} logs -f ${service}"
done
tmux attach-session -t simulation
