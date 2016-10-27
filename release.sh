#!/bin/bash

release_version_prefix="version dump: "
current_version=$(git log --format="%s" --grep="$release_version_prefix" | head -1)
current_version=${current_version#$release_version_prefix}

read -p "release: '$current_version'. continue? [Y/n] " confirm
case $confirm in
  Y*|y*)
    ;;
  *)
    exit 1
    ;;
esac

git up && git tag v$current_version && git push origin --tags
