#!/bin/bash
# LOCAL_WORKSPACE_FOLDER is only set inside the dev container
if [ -z "${LOCAL_WORKSPACE_FOLDER:-}" ]; then
  echo "Run this from a terminal in the dev container" >&2
  exit 1
fi

compose_dir="docker/compose/simulation"
compose_files=(-f "${compose_dir}/docker-compose.yml")
# Stops Gazebo too, whichever of `just sim-start` and `just sim-gazebo-start` started the simulation
if [ -f "${compose_dir}/docker-compose.gazebo.yml" ]; then
  compose_files+=(-f "${compose_dir}/docker-compose.gazebo.yml")
fi

docker compose "${compose_files[@]}" kill
docker compose "${compose_files[@]}" rm -f
tmux kill-session -t simulation
