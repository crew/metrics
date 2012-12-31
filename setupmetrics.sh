#!/bin/bash

# Path to the virtualenv executable
VENV=$(which virtualenv)
SCRATCH_DIR=/tmp/$USER
ENVDIR_NAME=metricsenv
ENVDIR=$SCRATCH_DIR/$ENVDIR_NAME

mkdir metrics

pushd metrics
git clone git://github.com/crew/metrics.git .
git submodule init
git submodule update
popd

# if the env directory does not exist, virtualenv it.
if [ ! -d $ENVDIR ] ; then
    $VENV $ENVDIR
fi

# Setup symlinks to the virtualenv directory.
echo "Setting up symlinks"
for x in api frontend backend aggregator; do
    pushd metrics/$x
    ln -s $ENVDIR env
    popd
done

echo "Enabling virtualenv"
source $ENVDIR/bin/activate || exit 1

echo "Setting up."
# Install pip, because the requirements files need this.
easy_install pip
easy_install pytz

echo "Installing api."
pushd metrics/api; python setup.py install; popd

echo "Installing frontend dependencies"
pushd metrics/frontend; pip install -r requirements.txt; popd

echo "Installing backend dependencies"
pushd metrics/backend
pip install -r requirements.txt
echo "Installing backend."
python setup.py install
popd

echo
echo "*** REMINDER: run the following. ***"
echo "source $ENVDIR/bin/env/activate"
