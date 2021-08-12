#!/usr/bin/env bash
chromeVersion=`google-chrome --product-version | sed 's/\..*//'`
latestChromeDriverURL=$(wget http://chromedriver.storage.googleapis.com/LATEST_RELEASE_$chromeVersion -q -O -)
echo $latestChromeDriverURL
wget "http://chromedriver.storage.googleapis.com/${latestChromeDriverURL}/chromedriver_linux64.zip"
unzip chromedriver_linux64.zip -d /home/travis/bin/
chmod +x /home/travis/bin/chromedriver
/home/travis/bin/chromedriver --version