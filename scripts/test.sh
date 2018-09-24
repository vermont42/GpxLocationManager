#!/bin/sh
set -e

scheme=$1

if [ -z "$scheme" ]; then
  echo "Scheme not specified. Please Specify a testing scheme <scheme (GpxLocationManagerTests)>."
  exit 1
fi

echo "Testing $scheme..."
xcodebuild -scheme GpxLocationManagerTests -quiet -destination 'platform=iOS Simulator,name=iPhone 8,OS=latest' test |
    xcpretty -s --color --report junit --output build/reports/$scheme-"$(date +%d-%m-%Y-%M-%S)".xml

if [ ${PIPESTATUS[0]} -ne 0 ] ; then
    RED='\033[0;31m'
    echo "${RED}Test $scheme Failed"
    exit 1
fi

echo "Testing $scheme Succeeded!"