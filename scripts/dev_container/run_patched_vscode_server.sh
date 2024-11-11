#!/usr/bin/env sh

. /opt/ros/humble/setup.sh
workspace_dir="/home/user/workspace"
workspace_setup_script="${workspace_dir}/install/setup.sh"

if [ ! -f ${workspace_setup_script} ] && [ "$(find $workspace_dir -name package.xml)" != "" ]; then
  cd $workspace_dir
  echo "Building with colcon"
  colcon build --symlink-install
  cd -
fi

if [ -f $workspace_setup_script ]; then
  . $workspace_setup_script
fi

exec $(dirname $0)/real-code-server $@
