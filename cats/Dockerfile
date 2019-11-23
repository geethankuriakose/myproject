FROM ruby:2.5
RUN mkdir /app
WORKDIR /app
ADD . /app
RUN gem install bundler
RUN gem install sinatra
RUN bundle install
RUN apt-get install curl
#RUN bundle exec puma
ENV RACK_ENV=production
ENV PORT=8000
EXPOSE 8000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"
