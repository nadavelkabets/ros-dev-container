FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y zip mono-complete && apt clean && rm -rf /var/lib/apt/lists/*
ADD https://github.com/ArduPilot/MissionPlanner/releases/download/MissionPlanner1.3.80/MissionPlanner-1.3.80.zip /tmp/MissionPlanner.zip
RUN mkdir /mission_planner && unzip /tmp/MissionPlanner.zip -d /mission_planner && rm /tmp/MissionPlanner.zip
WORKDIR /mission_planner

ENTRYPOINT ["mono", "MissionPlanner.exe"]
