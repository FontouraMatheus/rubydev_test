#!/bin/bash
set -e

echo "Waiting bd..."
until pg_isready -h db -p 5432 -U postgres; do
  sleep 1
done

echo "Doing migrations..."
bundle exec rails db:prepare

echo "starting server..."
exec bundle exec rails server -b 0.0.0.0
