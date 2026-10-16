FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y wget zip mono-complete && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN wget -q https://github.com/ArduPilot/MissionPlanner/releases/download/MissionPlanner1.3.80/MissionPlanner-1.3.80.zip -O /tmp/MissionPlanner.zip \
    && mkdir /mission_planner \
    && unzip /tmp/MissionPlanner.zip -d /mission_planner \
    && rm /tmp/MissionPlanner.zip
COPY ["resources/simulation/mission_planner_config.xml", "/root/.local/share/Mission Planner/config.xml"]

WORKDIR /mission_planner
ENTRYPOINT ["mono", "MissionPlanner.exe"]
