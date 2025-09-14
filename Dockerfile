FROM ruby:3.3.8

WORKDIR /app

# Copy Gemfile
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy app
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile

# Run server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]