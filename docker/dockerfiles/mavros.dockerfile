FROM ros:humble-ros-base

RUN apt update && apt install -y ros-humble-mavros && apt clean && rm -rf /var/lib/apt/lists/*
RUN /ros_entrypoint.sh ros2 run mavros install_geographiclib_datasets.sh

Entrypoint ["/ros_entrypoint.sh", "ros2", "run", "mavros", "mavros_node"]