#!/bin/bash

bash ./chrome_setup.sh > /dev/null 2>&1
bash ./bootstrap.sh > /dev/null 2>&1
cd home/project/tutorial-watir-ruby-basic
bundle exec ruby simple_test_script.rb


