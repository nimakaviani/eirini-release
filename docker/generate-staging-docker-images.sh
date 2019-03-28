#!/bin/bash

set -ex

BASEDIR="$(cd $(dirname $0)/.. && pwd)"
RECIPEDIR="$BASEDIR/src/code.cloudfoundry.org/eirini/recipe"
DOCKERDIR="$RECIPEDIR/image"
TAG=${1?"latest"}

main(){
    echo "Creating Eirini Staging docker images..."

    build_image downloader
    create_docker_image downloader


    build_image executor
    create_docker_image executor

    build_image uploader
    create_docker_image uploader

    echo "All images created successfully"
}

build_image(){
    GOPATH="$BASEDIR"
    GOOS=linux CGO_ENABLED=0 go build -a -o $DOCKERDIR/bin/$1 code.cloudfoundry.org/eirini/recipe/cmd/$1
    verify_exit_code $? "Failed to build eirini"
}

create_docker_image() {
  create_image "$DOCKERDIR/Dockerfile-$1" "nimak/$1"
}

create_image() {
  local dockerfile="$1"
  local image_name="$2"

  echo "Creating $image_name docker image..."
  pushd $DOCKERDIR || exit
    docker build . -t "${image_name}:$TAG" -f $dockerfile
    verify_exit_code $? "Failed to create $image_name docker image"
  popd || exit
  echo "$image_name docker image created!"
}

verify_exit_code() {
    local exit_code=$1
    local error_msg=$2
    if [ "$exit_code" -ne 0 ]; then
        echo "$error_msg"
        exit 1
    fi
}

main
