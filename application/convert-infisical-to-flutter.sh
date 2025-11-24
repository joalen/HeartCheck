#!/usr/bin/env bash

jq 'map({ (.key): .value }) | add' secrets-raw.json > secrets.json
echo "Converted secrets to Flutter format!"
