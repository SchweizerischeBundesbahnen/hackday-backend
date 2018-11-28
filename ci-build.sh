#!/usr/bin/env bash

# Abort on error
set -e

if [ -n "${TAG_NAME}" ]; then
    export BRANCH_NAME=${TAG_NAME}
fi

export PROJECT_NAME="ssp-wzu-backend"
export PROJECT="code.sbb.ch/KD_WZU/${PROJECT_NAME}"

#export GOROOT="/opt/go"
export GOPATH="${WORKSPACE}/go"
export PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
export GIT_URL="$(git config --get remote.origin.url)"
export BRANCH="$(git rev-parse HEAD)"

echo "Building go project: ${PROJECT_NAME}"
echo "GO-Path: ${GOPATH}"
echo "GIT commit: ${BRANCH}"
echo "GIT URL: ${GIT_URL}"
echo "--------------"

echo "Removing GOPATH, if exists..."
rm -rf ${GOPATH}

echo "Creating GOPATH..."
mkdir -p ${GOPATH}/bin
mkdir -p ${GOPATH}/src/${PROJECT}
cd ${GOPATH}/src/${PROJECT}

echo "Download repository..."
git init
git remote add origin ${GIT_URL}
git fetch origin ${BRANCH}
git reset --hard FETCH_HEAD

echo "Getting dependencies..."
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
dep ensure

echo "Building go binary...."
go build main.go

export VERSION=${BRANCH_NAME}
if [ "${BRANCH_NAME}" == "master" ]; then
    export VERSION="latest"
fi

export VERSION=${VERSION/\//_}

echo "Pushing go binary to artifactory..."
curl -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASS} -T ./main "https://bin.sbb.ch/artifactory/wzu.generic/${PROJECT_NAME}/${VERSION}/main"
