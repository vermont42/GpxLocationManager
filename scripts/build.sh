#!/bin/sh
set -e

scheme=$1

if [ -z "$scheme" ]; then
  echo "Scheme not specified. Please Specify a scheme <scheme (Demo, GpxLocationManager)>."
  exit 1
fi

echo "Building scheme $scheme..."
xcodebuild -scheme $scheme -quiet -destination 'platform=iOS Simulator,name=iPhone 8,OS=latest' build
echo "Building scheme $scheme succeeded!"
