#!/bin/sh

TARGET=setup.py
PYTHON=python

OPT=$1

if [ ${OPT} = "--install" ]; then
    $PYTHON $TARGET build_ext --inplace
elif [ ${OPT} = "--clean" ]; then
    rm -rf *.so *.c build
fi
