#!/bin/bash

ls
cp -a ../pkg/gems/. ./gems
docker build -t ruby_selenium_basic -f selenium_basic/Dockerfile .
docker build -t ruby_selenium_ufg -f selenium_ufg/Dockerfile .
docker build -t ruby_capybara -f capybara/Dockerfile .
docker build -t ruby_watir -f watir/Dockerfile .
rm -r gems
