#!/bin/bash

set -e

ghp-import -m "Update site" output

git push deploy gh-pages:master --force
