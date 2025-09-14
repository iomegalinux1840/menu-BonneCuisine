FROM ruby:3.3.8

WORKDIR /app

# Set Rails environment
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# Copy Gemfile
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy app
COPY . .

# Create required directories and files
RUN mkdir -p tmp/pids log public/assets && \
    touch log/production.log

# Precompile assets with dummy secret key
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Create entrypoint script
RUN echo '#!/bin/sh\n\
set -e\n\
\n\
# Remove server.pid if it exists\n\
rm -f /app/tmp/pids/server.pid\n\
\n\
# Run database migrations if DATABASE_URL is set\n\
if [ -n "$DATABASE_URL" ]; then\n\
  echo "Running database migrations..."\n\
  bundle exec rails db:migrate || echo "Migration failed, continuing..."\n\
fi\n\
\n\
# Start Rails server\n\
exec bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}\n\
' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Use entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]