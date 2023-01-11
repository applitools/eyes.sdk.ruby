FROM artemqaapplitools/chrome-docker:latest

RUN gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN \curl -sSL https://get.rvm.io | bash -s stable --ruby
RUN /bin/bash -c ". /etc/profile.d/rvm.sh"
RUN apt-get update && apt-get install unzip

ENTRYPOINT ["/bin/bash", "-l", "-c"]
SHELL ["/bin/bash", "-l", "-c"]