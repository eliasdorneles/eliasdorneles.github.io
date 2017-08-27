#!/bin/bash

set -e

make clean compile

ghp-import -m "Update site" output

git push deploy gh-pages:master --force
