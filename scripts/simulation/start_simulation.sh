#!/bin/bash
xhost +
set +e

# multicast support for cyclonedds
sudo ip link set lo multicast on
tmux new-session -d -s simulation '/bin/bash'
tmux source-file ./.tmux.conf

tmux_window() {
    win_name=$1
    shift
    command=$*
    tmux new-window -n $win_name
    tmux select-window -t $win_name
    tmux send-keys "$command" KPENTER
}

tmux_window "mission_planner" "docker-compose -f docker/compose/simulation/docker-compose.yml up mission_planner"
tmux_window "sitl" "docker-compose -f docker/compose/simulation/docker-compose.yml up sitl"
tmux attach-session -t simulation
