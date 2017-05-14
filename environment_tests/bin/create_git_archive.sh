#!/usr/bin/env bash

cd ..
BRANCH=`git branch | grep \\* | cut -d ' ' -f2`
mkdir -p pkg
git archive $BRANCH -o pkg/repo.tar.gz
cd ./environment_tests

