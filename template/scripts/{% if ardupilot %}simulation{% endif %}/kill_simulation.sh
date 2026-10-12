#!/bin/bash
compose_file="docker/compose/simulation/docker-compose.yml"

docker compose -f "${compose_file}" kill
docker compose -f "${compose_file}" rm -f
tmux kill-session -t simulation
