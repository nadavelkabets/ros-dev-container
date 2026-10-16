#!/bin/bash
# Entrypoint of the SITL container: loads the ArduPilot environment, then runs the given command
set -e

# shellcheck source=/dev/null
source "${HOME}/.ardupilot_env"
exec "$@"
