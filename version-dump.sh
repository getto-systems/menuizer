#!/bin/bash

. version-functions.sh

mode=$1
if [ -z "$mode" ]; then
  mode=patch
fi

version_rb=lib/labelizer/version.rb

release_version_prefix="version dump: "
current_version=$(git log --format="%s" --grep="$release_version_prefix" | head -1)
current_version=${current_version#$release_version_prefix}

git fetch --tags
current_tag=$(git tag | tail -1)

if [ "v$current_version" != "$current_tag" ]; then
  read -p "curent: '$current_version', tag: '$current_tag'. continue? [Y/n] " confirm
  case $confirm in
    Y*|y*)
      ;;
    *)
      exit 1
      ;;
  esac
fi

version_build_next "$mode" $current_version

read -p "dump version: $version. OK? [Y/n] " confirm
case $confirm in
  Y*|y*)
    sed -i 's/VERSION.*/VERSION = "'$version'"/' $version_rb
    git add $version_rb && git commit -m "version dump: $version"
    ;;
  *)
    exit 1
    ;;
esac
