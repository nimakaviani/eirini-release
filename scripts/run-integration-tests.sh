#! /bin/bash

set -ex

export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH

export GOPATH=/eirini-release
export PATH=$PWD/bin:$PATH

go install github.com/onsi/ginkgo/ginkgo

pushd src/code.cloudfoundry.org/eirini/integration/recipe
  ginkgo .
popd
