# Copyright 2021 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
VERSION 0.8


GENERATE_REPOS_FILE:
  FUNCTION
  # String with list of whitespace-separated ROS packages to include
  # This list should stay small, rosinstall_generator will resolve dependencies.
  ARG packages
 # String with list of whitespace-separated ROS packages to exclude
  # Used to exclude packages which we don't incorporate into Space ROS
  ARG excluded_packages
  # Set rosdistro
  ARG rosdistro="humble"
  ARG outfile="ros2.repos"

  RUN sudo apt-get update && sudo apt-get install -y software-properties-common
  RUN sudo add-apt-repository universe
  RUN sudo apt-get update && sudo apt-get install -y curl gnupg lsb-release
  RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
  RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

  # Install repos file generator script requirements.
  RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-rosinstall-generator
  RUN --no-cache rosinstall_generator \ 
        --format repos \ # Use the repos file format rather than rosinstall format.
        --rosdistro $rosdistro \ # Set rosdistro
        --deps \ # Include all dependencies
        --upstream \ # Use version tags of upstream repositories
        --exclude $excluded_packages  \ # Exclude packages which we don't incorporate into Space ROS
        -- $packages > $outfile

repos-file:
  FROM ubuntu:jammy
  # Disable prompting during package installation
  ARG DEBIAN_FRONTEND=noninteractive
  WORKDIR /root

  COPY excluded-pkgs.txt ./
  COPY spaceros-pkgs.txt ./
  COPY spaceros.repos ./

  RUN apt-get update && apt-get install -y curl sudo
  # yq is required for merging file generated by rosinstall with `spaceros.repos` file
  RUN curl -sSL https://github.com/mikefarah/yq/releases/download/v4.43.1/yq_linux_386 \
    -o /usr/bin/yq && \
    chmod +x /usr/bin/yq

  DO +GENERATE_REPOS_FILE \
    --packages=$(cat spaceros-pkgs.txt) \
    --excluded_packages=$(cat excluded-pkgs.txt) \
    --outfile="ros2.repos"

  # merge ros2.repos generated by rosinstall with `spaceros.repos` and sort keys
  RUN yq -i '. *= load("spaceros.repos") | .repositories | sort_keys(.)' ros2.repos 

  SAVE ARTIFACT ros2.repos AS LOCAL ros2.repos
