#!/bin/bash
git up && git tag v$(cat version.txt) && git push origin --tags
