FROM ruby:3.3.8

WORKDIR /app

# Install PostgreSQL client
RUN apt-get update -qq && \
    apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Set Rails environment
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    SECRET_KEY_BASE=8f54091563fcf1f33d8cfcc2baf2a9061f6163df0971b2a58c97317ed2ab4d5d1dbc2ab31c7eb1c4382a74f093742f5f84c5da7268069701a9d69582665c7c3a

# Copy and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.7.0 && \
    bundle config set --local without 'development test' && \
    bundle install

# Copy application
COPY . .

# Create required directories
RUN mkdir -p tmp/pids tmp/cache tmp/sockets log public/assets

# Precompile assets
RUN bundle exec rails assets:precompile || true

# Make port configurable
EXPOSE 3000

# Start script that handles database and runs server
CMD sh -c "rm -f tmp/pids/server.pid && \
           if [ -n \"$DATABASE_URL\" ]; then \
             echo 'Setting up database...' && \
             bundle exec rails db:create 2>/dev/null || true && \
             bundle exec rails db:migrate && \
             bundle exec rails db:seed 2>/dev/null || true; \
           fi && \
           echo 'Starting Rails server on port '${PORT:-3000} && \
           bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"