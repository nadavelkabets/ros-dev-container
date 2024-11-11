SHELL=/bin/bash

.PHONY: full_simulation
full_simulation:
	xhost +
	./scripts/simulation/start_simulation.sh

.PHONY: kill_simulation
kill_simulation:
	./scripts/simulation/kill_simulation.sh
