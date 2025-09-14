# Use Ruby 3.3.8 slim image for smaller size
FROM ruby:3.3.8-slim

# Install essential Linux packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_DEPLOYMENT="1"

# Install bundler
RUN gem install bundler -v 2.7.0

# Copy Gemfile first for better caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Create and migrate database
RUN bundle exec rails db:create db:migrate db:seed || true

# Expose port
EXPOSE 3000

# Start server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]