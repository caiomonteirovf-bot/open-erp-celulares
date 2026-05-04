#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

export RAILS_ENV=${CONFIG:-development}

if [ "$DEPLOY_DATABASE" = "true" ]; then
    bundle exec rails db:create db:migrate
fi

if [ "$PERFORM_TESTS" = "true" ]; then
    bundle exec rspec
fi

if [ "$START_APP" = "true" ]; then
    bundle exec rails server -b 0.0.0.0
fi
