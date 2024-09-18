#!/bin/bash

# Abort script on command failure
set -e
VERSION=1.0
YOCTO_MANIFEST="fs-release-manifest.xml"

# host build directory, default full path to current dir
HOST_BUILD_DIR="${1:-$(realpath .)}"
RELEASE_DIR="$PWD"
DOCKER_COMMAND="${2:-bash}"
DOCKER_CONFIG_PATH="${3:-$(realpath .)}"

if [ "$DOCKER_COMMAND" == "" ]
then
	interactive=""
else
	interactive="-it"
fi

DOCKER_CONTAINER=$(grep '<docker' "${YOCTO_MANIFEST}"| grep -Po 'version="\K.*?(?=")')
DOCKER_CONTAINER=${DOCKER_CONTAINER:-"fus-ubuntu-2022.04"}

export myUID=$(id -u)
export myGID=$(id -g)

if ! git config --global user.name
then
	read -p "Please enter the user name that should be used for git: " username
	git config --global user.name "$username"
fi

if ! git config --global user.email
then
	read -p "Please enter the email that should be used for git: " email
	git config --global user.email "$email"
	# set additional colorized mode
	git config --global color.ui auto
fi

mkdir -p "${HOST_BUILD_DIR}"/releases

# build image if not available
if ! docker image inspect "$DOCKER_CONTAINER" >/dev/null 2>&1; then
	echo "Build image $DOCKER_CONTAINER"
	docker build -t "$DOCKER_CONTAINER" "$DOCKER_CONFIG_PATH"
fi

cd "$HOST_BUILD_DIR"
docker run ${interactive} --name "${DOCKER_CONTAINER,,}" --rm \
				--user "${myUID}":"${myGID}" \
				--volume="${PWD}:/home/${USER}/" \
				--volume="/etc/group:/etc/group:ro" \
				--volume="/etc/passwd:/etc/passwd:ro" \
				--volume="/etc/shadow:/etc/shadow:ro" \
				--volume="/home/${USER}/.gitconfig:/home/${USER}/.gitconfig:ro" \
				"${DOCKER_CONTAINER}" \
				bash -c "$DOCKER_COMMAND"
