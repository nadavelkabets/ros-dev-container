#!/bin/bash

docker-compose -f docker/compose/simulation/docker-compose.yml kill
docker container prune -f
tmux kill-session -t simulation
