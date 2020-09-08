#!/bin/bash
set -e
docker run -e APPLITOOLS_API_KEY ruby_selenium_basic
docker run -e APPLITOOLS_API_KEY ruby_selenium_ufg
# There should be separate runs for the capybara and watir tutorials alongside with the separate tests runs
#docker run -e APPLITOOLS_API_KEY ruby_capybara
#docker run -e APPLITOOLS_API_KEY ruby_watir

bash ./report.sh
