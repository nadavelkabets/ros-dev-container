# ArduPilot SITL, following ArduPilot's Dockerfile at Copter-4.5.5
# (github.com/ArduPilot/ardupilot/blob/Copter-4.5.5/Dockerfile). The differences: the ArduPilot repository and version,
# and the Ubuntu release (TAG), come from the compose file's build args, the source is cloned instead of copied in, SITL
# is built into the image, apt is cleaned up in the steps that install packages (as their current Dockerfile does),
# since a separate cleanup step leaves the files in the earlier layers, and downloads and ccache use BuildKit caches.
ARG BASE_IMAGE="ubuntu"
ARG TAG="22.04"
FROM ${BASE_IMAGE}:${TAG}
WORKDIR /ardupilot

ARG DEBIAN_FRONTEND=noninteractive
ARG USER_NAME=ardupilot
ARG USER_UID=1000
ARG USER_GID=1000
ARG SKIP_AP_EXT_ENV=1
ARG SKIP_AP_GRAPHIC_ENV=0
ARG SKIP_AP_COV_ENV=1
ARG SKIP_AP_GIT_CHECK=1

# Ubuntu 24.04+ base images ship an "ubuntu" user that already owns UID and GID 1000
RUN if id ubuntu >/dev/null 2>&1; then userdel --remove ubuntu; fi \
    && groupadd ${USER_NAME} --gid ${USER_GID}\
    && useradd -l -m ${USER_NAME} -u ${USER_UID} -g ${USER_GID} -s /bin/bash

# git and ca-certificates for the clone below
RUN apt-get update && apt-get install --no-install-recommends -y \
    lsb-release \
    sudo \
    tzdata \
    git \
    ca-certificates \
    bash-completion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create non root user for pip
ENV USER=${USER_NAME}

RUN echo "ardupilot ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME}
RUN chmod 0440 /etc/sudoers.d/${USER_NAME}

RUN chown -R ${USER_NAME}:${USER_NAME} /${USER_NAME}

USER ${USER_NAME}

# Set in the compose file. --recurse-submodules does what `git submodule update --init --recursive` would after a plain
# clone.
ARG ARDUPILOT_REPO
ARG ARDUPILOT_VERSION
RUN git clone --depth 1 --branch "$ARDUPILOT_VERSION" --recurse-submodules --shallow-submodules \
    "$ARDUPILOT_REPO" .

ENV SKIP_AP_EXT_ENV=$SKIP_AP_EXT_ENV SKIP_AP_GRAPHIC_ENV=$SKIP_AP_GRAPHIC_ENV SKIP_AP_COV_ENV=$SKIP_AP_COV_ENV SKIP_AP_GIT_CHECK=$SKIP_AP_GIT_CHECK
# Downloaded packages, package lists and pip's downloads go to BuildKit caches (the --mount options), so rebuilds don't
# download them again and they stay out of the image. docker-clean would delete the downloads, so it's set aside for
# this step.
# hadolint ignore=DL3004
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/home/${USER_NAME}/.cache/pip,uid=${USER_UID},gid=${USER_GID} \
    sudo mv /etc/apt/apt.conf.d/docker-clean /etc/apt/docker-clean \
    && Tools/environment_install/install-prereqs-ubuntu.sh -y \
    && sudo mv /etc/apt/docker-clean /etc/apt/apt.conf.d/docker-clean \
    && sudo rm -rf /tmp/* /var/tmp/*

# add waf alias to ardupilot waf to .ardupilot_env
RUN echo "alias waf=\"/${USER_NAME}/waf\"" >> ~/.ardupilot_env

# Check that local/bin are in PATH for pip --user installed package
# hadolint ignore=SC2028
RUN echo "if [ -d \"\$HOME/.local/bin\" ] ; then\nPATH=\"\$HOME/.local/bin:\$PATH\"\nfi" >> ~/.ardupilot_env

# Create entrypoint as docker cannot do shell substitution correctly
# hadolint ignore=DL3004
RUN export ARDUPILOT_ENTRYPOINT="/home/${USER_NAME}/ardupilot_entrypoint.sh" \
    && echo "#!/bin/bash" > $ARDUPILOT_ENTRYPOINT \
    && echo "set -e" >> $ARDUPILOT_ENTRYPOINT \
    && echo "source /home/${USER_NAME}/.ardupilot_env" >> $ARDUPILOT_ENTRYPOINT \
    && echo 'exec "$@"' >> $ARDUPILOT_ENTRYPOINT \
    && chmod +x $ARDUPILOT_ENTRYPOINT \
    && sudo mv $ARDUPILOT_ENTRYPOINT /ardupilot_entrypoint.sh

# Through the entrypoint, which loads ArduPilot's environment in bash (it uses `source`, which /bin/sh doesn't have).
# waf compiles through ccache, whose cache is a BuildKit cache, so a rebuild only recompiles what changed.
RUN --mount=type=cache,target=/home/${USER_NAME}/.ccache,uid=${USER_UID},gid=${USER_GID} \
    export CCACHE_DIR=/home/${USER_NAME}/.ccache \
    && /ardupilot_entrypoint.sh ./waf configure --board sitl \
    && /ardupilot_entrypoint.sh ./waf copter

# Set the buildlogs directory into /tmp as other directory aren't accessible
ENV BUILDLOGS=/tmp/buildlogs

ENV CCACHE_MAXSIZE=1G
ENTRYPOINT ["/ardupilot_entrypoint.sh"]
CMD ["bash"]
