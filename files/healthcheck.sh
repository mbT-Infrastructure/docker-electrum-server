#!/usr/bin/env bash
set -e -o pipefail

curl --fail http://localhost:4224/ || exit 1
