FROM artemqaapplitools/chrome_ruby:latest

RUN cd home/project \
    && git clone https://github.com/applitools/tutorial-selenium-ruby-ultrafastgrid.git \
    && cd tutorial-selenium-ruby-ultrafastgrid \
    && bundle install

COPY ./tutorials/gems/. gems/

RUN cd gems \
    && gem install eyes_core \
    && gem install eyes_selenium

COPY ./tutorials/selenium_ufg/start.sh /
CMD ["/start.sh"]