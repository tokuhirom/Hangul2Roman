#!/bin/sh
BASEDIR=$(dirname $(readlink -f $0))
perl -Mlib::core::only "-Mlib=$BASEDIR/extlib/lib/perl5/" "$@"
