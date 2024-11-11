#!/bin/bash

sudo groupadd -g "$(stat -c '%g' /var/run/docker.sock)" docker_host
sudo usermod -aG docker_host user

eval "$@"
