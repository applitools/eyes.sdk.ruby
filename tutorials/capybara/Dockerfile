FROM artemqaapplitools/chrome_ruby:latest

RUN cd home/project \
    && git clone https://github.com/applitools/tutorial-capybara-ruby-basic.git \
    && cd tutorial-capybara-ruby-basic \
    && bundle install

COPY ./gems/. gems/

RUN cd gems \
    && gem install eyes_core \
    && gem install eyes_selenium \
    && gem install eyes_capybara

COPY ./capybara/start.sh /
CMD ["/start.sh"]