#!/bin/bash

set -e

# Function to display usage information
usage() {
	echo "Generate .repos file with list of SpaceROS repositories to clone"
    echo "Usage: $0 --packages PACKAGES --outfile OUTFILE [--excluded-packages EXCLUDED_PACKAGES] [--repos REPOS] [--rosdistro ROSDISTRO] [--upstream UPSTREAM] [--exclude-installed EXCLUDE_INSTALLED]"
    echo "  --outfile                   The output file"
    echo "  --packages             		List of ROS packages to include"
    echo "  --repos						Use it as alternative to 'packages'. rosinstall can generate .repos file from list of repos instead of list of packages"
    echo "  --excluded-packages         Packages to exclude (optional)"
    echo "  --rosdistro                 ROS2 distribution (default: humble)"
    echo "  --upstream                  Specify whether to use version tags of upstream repositories (default: true)"
    echo "  --exclude-installed         Whether to exclude already installed packages from .repos file. Installed workspaces must be sourced to make it work (default: true)"
    exit 1
}

# Initialize variables with default values
rosdistro="humble"
packages=""
outfile=""
excluded_packages=""
repos=""
upstream="true"
exclude_installed="true"
ARGS=$(getopt -o '' -l packages:,outfile:,exclude-packages:,repos:,rosdistro:,upstream:,exclude-installed: -n "$0" -- "$@")
eval set -- "$ARGS"
# Parse command-line arguments
while true; do
    case "$1" in
        --packages )
			# change newlines to whitespaces
            packages=$(echo $2 | tr "\n" " ")
            shift 2
            ;;
        --outfile )
            outfile=$2
            shift 2
            ;;
        --exclude-packages )
			# change newlines to whitespaces
            excluded_packages=$(echo $2 | tr "\n" " ")
            shift 2
            ;;
        --repos-file )
			# change newlines to whitespaces
            repos=$(echo $2 | tr "\n" " ")
            shift 2
            ;;
        --rosdistro )
            rosdistro=$2
            shift 2
            ;;
        --upstream )
            upstream=$2
            shift 2
            ;;
        --exclude-installed )
            exclude_installed=$2
            shift 2
            ;;
        -- )
            shift
            break
            ;;
        * )
            exit 1
            ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$packages" ] && [ -z "$repos" ]; then
    echo "Error: Either packages or repos (or both) have to be specified"
    usage
fi

if [ -z "$outfile" ]; then
    echo "Error: Required argument outfile missing"
    usage
fi

# Define the command for generating rosinstall
GENERATE_CMD=rosinstall_generator
# Use the repos file format rather than rosinstall format.
GENERATE_CMD="$GENERATE_CMD --format repos"
# Set rosdistro.
GENERATE_CMD="$GENERATE_CMD --rosdistro $rosdistro"
# Include all dependencies
GENERATE_CMD="$GENERATE_CMD --deps"

# Use version tags of upstream repositories
if [ "$upstream" = "true" ]; then
    GENERATE_CMD="$GENERATE_CMD --upstream"
fi

# Exclude packages which we don't incorporate into Space ROS
if [ "$exclude_installed" = "true" ]; then
    # paths to packages are stored in AMENT_PREFIX_PATH,
    # however rosinstall_generator expects ROS_PACKAGE_PATH variable to be set
    export ROS_PACKAGE_PATH=$AMENT_PREFIX_PATH
    GENERATE_CMD="$GENERATE_CMD --exclude $excluded_packages RPP"
else
    GENERATE_CMD="$GENERATE_CMD --exclude $excluded_packages"
fi

# include additional repos along specified packages
GENERATE_CMD="$GENERATE_CMD --repos $repos"

GENERATE_CMD="$GENERATE_CMD -- $packages"

echo "Generating .repos file with command: '$GENERATE_CMD'"

# Generate rosinstall file
$GENERATE_CMD >$outfile

echo "rosinstall file generated: $outfile"
