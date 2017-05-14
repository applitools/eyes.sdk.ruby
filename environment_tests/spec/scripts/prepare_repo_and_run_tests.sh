#! /bin/sh

tar -xzf /source_dir/pkg/repo.tar.gz
git init
git add .
cd ./ext/eyes_core
ruby ./extconf.rb
make
make install
cd ../..
bundle install
bundle exec rake