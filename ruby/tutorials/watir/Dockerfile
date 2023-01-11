FROM artemqaapplitools/chrome_ruby:latest

RUN cd home/project \
    && git clone https://github.com/applitools/tutorial-watir-ruby-basic.git \
    && cd tutorial-watir-ruby-basic \
    && bundle install

COPY ./gems/. gems/

RUN cd gems \
    && gem install eyes_core \
    && gem install eyes_selenium

COPY ./watir/start.sh /
CMD ["/start.sh"]