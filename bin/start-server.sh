#!/bin/bash
# Start Rails server with PORT from environment variable

echo "Starting Rails server..."
echo "PORT environment variable: $PORT"

# Default to port 3000 if PORT is not set
if [ -z "$PORT" ]; then
  echo "PORT not set, using default 3000"
  PORT=3000
fi

# Run migrations and seed if in production
if [ "$RAILS_ENV" = "production" ]; then
  echo "Running database migrations..."
  bundle exec rails db:migrate
  echo "Migrations complete"

  echo "Seeding database..."
  bundle exec rails db:seed
  echo "Database seeding complete"
fi

echo "Starting server on port $PORT"
exec bundle exec rails server -b 0.0.0.0 -p $PORT
