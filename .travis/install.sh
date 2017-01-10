#!/usr/bin/env bash

set -e

# install swiftenv
git clone --depth 1 https://github.com/kylef/swiftenv.git ~/.swiftenv
export SWIFTENV_ROOT="$HOME/.swiftenv"
export PATH="$SWIFTENV_ROOT/bin:$SWIFTENV_ROOT/shims:$PATH"

# install swift using swiftenv
if [ -f ".swift-version" ] || [ -n "$SWIFT_VERSION" ]; then
  swiftenv install
else
  swiftenv rehash
fi
