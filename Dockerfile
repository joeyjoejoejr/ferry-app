FROM ruby:2.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client
RUN mkdir /ferry-app
WORKDIR /ferry-app
ADD Gemfile /ferry-app/Gemfile
ADD Gemfile.lock /ferry-app/Gemfile.lock
RUN bundle install
ADD . /ferry-app
