#!/bin/bash

. version-functions.sh

mode=$1
if [ -z "$mode" ]; then
  mode=patch
fi

version_file=version.txt
version_rb=lib/menuizer/version.rb
current_version=$(cat $version_file)

git fetch --tags
current_tag=$(git tag | tail -1)

if [ "v$current_version" != "$current_tag" ]; then
  read -p "file: '$current_version', tag: '$current_tag'. continue? [Y/n] " confirm
  case $confirm in
    Y*|y*)
      ;;
    *)
      exit 1
      ;;
  esac
fi

version_build_next "$mode" $(cat $version_file)

read -p "dump version: $version. OK? [Y/n] " confirm
case $confirm in
  Y*|y*)
    echo $version > $version_file
    sed -i 's/VERSION.*/VERSION = "'$version'"/' $version_rb
    git add $version_file $version_rb && git commit -m "version dump: $version"
    ;;
  *)
    exit 1
    ;;
esac
