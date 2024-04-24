#!/bin/bash

# path to bundle executable
BUNDLE=${BUNDLE:-bundle}

ROOT=$(realpath $(dirname ${BASH_SOURCE[0]}))

which $BUNDLE 2>&1 > /dev/null
if [ $? -eq 1 ]; then
  >&2 echo "No bundle executable found. Either install it, or set the BUNDLE environment variable to the executable path"
  exit 1
fi

if [ ! -d .bundle ]; then
  $BUNDLE config set --local path .bundle/gems
fi

if [ ! -d .bundle/gems ]; then
  echo "Installing gems"
  $BUNDLE install
fi

bundle check 2>&1 > /dev/null
if [ $? -eq 1 ]; then
  echo "Installing new gems"
  $BUNDLE install
fi

# pass everything to ruby
bundle exec ruby "$ROOT"/bin/do.rb -f "$ROOT"/bin/do.rake "$@"