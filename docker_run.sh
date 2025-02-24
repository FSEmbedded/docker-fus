#!/bin/bash

# Abbort script on command failure
set -e
VERSION=1.0

YOCTO_MANIFEST="fs-release-manifest.xml"
HOST_BUILD_DIR="./docker_build"
DOCKER_COMMAND="bash"
INTERACTIVE="-it"
WORKDIR="/home/${USER}"
FUS_DOCKER_GIT="$(dirname "$0")"

export myUID=$(id -u)
export myGID=$(id -g)

if [ -f .docker_params ]; then
	source .docker_params
fi

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                help
            ;;
            -i|--dockerimage)
                DOCKER_CONTAINER="$2"
                shift # past argument
                shift # past value
            ;;
            -w|--workdir)
                WORKDIR="$2"
                shift # past argument
                shift # past value
            ;;
            -m|--manifest)
                YOCTO_MANIFEST="$2"
                shift # past argument
                shift # past value
            ;;
            -d|--hostdir)
                HOST_BUILD_DIR="$2"
                shift # past argument
                shift # past value
            ;;
            --dockergit)
                FUS_DOCKER_GIT="$2"
                shift # past argument
                shift # past value
            ;;
            -c|--command)
                DOCKER_COMMAND="$2"
                shift # past argument
                shift # past value
            ;;
            -v|--volumes)
                NEW_VOL="$2"
                if [ "$NEW_VOL" != "" ]; then
                	DOCKER_VOLUMES="${DOCKER_VOLUMES} --volume=${NEW_VOL}"
                fi
                shift # past argument
                shift # past value
            ;;
            -p|--parameters)
                DOCKER_PARAMS="${DOCKER_PARAMS} $(eval "echo $2")"
                shift # past argument
                shift # past value
            ;;
            --headless)
                INTERACTIVE=
                shift # past value
            ;;
            *)    # unknown option
                echo "Unknown option: $1"
                help
            ;;
        esac
    done
}

parse_arguments "$@"

if [ -z ${DOCKER_CONTAINER} ]; then
	DOCKER_CONTAINER=$(grep '<docker' "${YOCTO_MANIFEST}"| grep -Po 'version="\K.*?(?=")')
fi

mkdir -p ${HOST_BUILD_DIR}/
cd $HOST_BUILD_DIR

if ! docker images | grep -q "${DOCKER_CONTAINER}"; then
     docker build -t "${DOCKER_CONTAINER}" -f ${FUS_DOCKER_GIT}/Dockerfile_${DOCKER_CONTAINER} ${FUS_DOCKER_GIT}
fi

docker run ${INTERACTIVE} --rm \
				--user ${myUID}:${myGID} \
				--volume="${PWD}:/home/${USER}/" \
				--volume="/etc/group:/etc/group:ro" \
				--volume="/etc/passwd:/etc/passwd:ro" \
				--volume="/etc/shadow:/etc/shadow:ro" \
				${DOCKER_VOLUMES} \
				${DOCKER_PARAMS} \
				--workdir="${WORKDIR}/" \
				${DOCKER_CONTAINER} \
				bash -c "${DOCKER_COMMAND}"

