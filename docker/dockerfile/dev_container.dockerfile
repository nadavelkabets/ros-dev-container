FROM ros:humble-ros-base

SHELL ["bash", "-c"]

ARG USERNAME=user
ARG USER_UID=1000
RUN groupadd --gid $USER_UID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_UID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
ENV PATH="/home/$USERNAME/.local/bin:$PATH"
RUN sudo apt-get update && apt-get dist-upgrade -y && sudo apt-get install -y \
    python3-pip \
    curl \
    vim \
    ssh \
    less \
    git \
    ros-dev-tools \
    tmux \
    htop \
    rsync \
    iputils-ping \
    docker.io \
    bash-completion

COPY scripts/dev_container/* /tmp/scripts/
RUN /tmp/scripts/install_patched_vscode_server.sh 0ee08df0cf4527e40edc9aa28f4b5bd38bbff2b2
RUN echo ". /opt/ros/humble/setup.bash" >> ~/.bashrc \
    && echo "if [ -f /workspace/install/setup.bash ]; then . /workspace/install/setup.bash; fi" >> ~/.bashrc \
    && echo ". /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
