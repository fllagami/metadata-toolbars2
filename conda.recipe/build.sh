#!/bin/bash

set -e
set -x

BLD_DIR=`pwd`

SRC_DIR=$RECIPE_DIR/..
pushd $SRC_DIR

version=`$PYTHON scripts/get_bump_version.py`

if [ -e "__travis_job_id__.txt" ]; then
    travis_job_id=$(cat __travis_job_id__.txt)
    if [[ "$travis_job_id" == "release" || "$travis_job_id" == "devel" ]]; then
        # for releases and devel builds we just need the tag
        echo $version > __conda_version__.txt
    else
        # for the testing machinery we also need the travis_job__id
        echo $version.$travis_job_id > __conda_version__.txt
    fi
else
    # for local building we don't have the travis_job__id
    echo $version > __conda_version__.txt
fi

cp __conda_version__.txt $BLD_DIR

pushd bokehjs
echo "npm version $(npm -v)"
echo "node version $(node -v)"
npm install
popd

$PYTHON setup.py --quiet install nightly --build_js --single-version-externally-managed --record=record.txt

mkdir $PREFIX/Examples
cp -r examples $PREFIX/Examples/bokeh

popd

cd $PREFIX
echo $PREFIX

