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

# Expose port
EXPOSE 3000

# Create entrypoint script
RUN echo '#!/bin/sh\n\
set -e\n\
\n\
# Run database migrations if DATABASE_URL is set\n\
if [ -n "$DATABASE_URL" ]; then\n\
  echo "Running database migrations..."\n\
  bundle exec rails db:migrate || true\n\
  \n\
  # Only seed if SEED_DATABASE is set to true\n\
  if [ "$SEED_DATABASE" = "true" ]; then\n\
    echo "Seeding database..."\n\
    bundle exec rails db:seed || true\n\
  fi\n\
fi\n\
\n\
# Start the Rails server\n\
exec bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}\n\
' > /rails/entrypoint.sh && chmod +x /rails/entrypoint.sh

# Start server
CMD ["/rails/entrypoint.sh"]