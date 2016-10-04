#!/bin/bash

. version-functions.sh

mode=$1
if [ -z "$mode" ]; then
  mode=patch
fi

version_file=version.txt
version_build_next "$mode" $(cat $version_file)

read -p "dump version: $version. OK? [Y/n] " confirm
case $confirm in
  Y*|y*)
    echo $version > $version_file
    ;;
  *)
    exit 1
    ;;
esac
