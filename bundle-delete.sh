#!/bin/bash
set -e

# Set environment
PROJECT_ROOT="$( cd "$( dirname "$0" )/.." && pwd )"
DELETE_GLOB="$1"

# Exit for missing environment
if [ -z "${DELETE_GLOB}" ]; then
  echo >&2 "You must supply a bundle glob with the DELETE_GLOB environment variable or the first argument."
  exit 1
fi
if [ -z "${BUNDLE_PATH}" ]; then
  echo >&2 "You must supply the BUNDLE_PATH environment variable where bundler gems are stored."
  exit 1
fi

# Delete bundler files for the specified glob
find "${BUNDLE_PATH}" -maxdepth 4 -type d -iname "${DELETE_GLOB}" -exec bash -c 'echo `basename "{}"` && rm -rf "{}"' \;
find "${BUNDLE_PATH}" -maxdepth 4 -type f -iname "${DELETE_GLOB}" -exec bash -c 'echo `basename "{}"` && rm -f "{}"' \;
