#!/bin/bash

# -----------------------------------------------------------------------------
# FLAKE8-CHECK.SH
# -----------------------------------------------------------------------------
# Check the application Python scripts for PEP8.
#
# It's needed the Python flake8 package to run. Install it via PIP.
#
#     pip3 install --upgrade flake8
#
# Usage:
#     bash check-flake8.sh
# -----------------------------------------------------------------------------
BASEDIR=$(dirname $0)

for f in $(find $BASEDIR/../ -name '*.py')
do
    echo $f
    flake8 $f
done
