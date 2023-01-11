FROM artemqaapplitools/chrome_ruby:latest

RUN cd home/project \
    && git clone https://github.com/applitools/tutorial-selenium-ruby-basic.git \
    && cd tutorial-selenium-ruby-basic \
    && bundle install

COPY ./tutorials/gems/. gems/

RUN cd gems \
    && gem install eyes_core \
    && gem install eyes_selenium

COPY ./tutorials/selenium_basic/start.sh /
CMD ["/start.sh"]