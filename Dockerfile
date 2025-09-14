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
    SECRET_KEY_BASE=dummy

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
             bundle exec rails db:migrate 2>/dev/null || true; \
           fi && \
           bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"