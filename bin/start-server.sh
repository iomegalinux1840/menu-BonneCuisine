#!/bin/bash
# Start Rails server with PORT from environment variable
exec bundle exec rails server -b 0.0.0.0 -p "$PORT"
