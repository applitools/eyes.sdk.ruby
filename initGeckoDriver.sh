#!/usr/bin/env bash
wget -N https://github.com/mozilla/geckodriver/releases/download/v0.29.1/geckodriver-v0.29.1-linux64.tar.gz -P ~/
tar -xzf ~/geckodriver-v0.29.1-linux64.tar.gz -C ~/
rm ~/geckodriver-v0.29.1-linux64.tar.gz
sudo mv -f ~/geckodriver /home/travis/bin/
sudo chmod +x /home/travis/bin/geckodriver