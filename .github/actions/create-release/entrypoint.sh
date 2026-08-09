#!/usr/bin/env sh

set -e
cd /github/workspace
git config --global --add safe.directory /github/workspace
git -C /github/workspace rev-parse --show-toplevel
ls -A
git config user.name webredax
git config user.email 309066399+webredax@users.noreply.github.com
git add .
git commit --allow-empty -m "Bump version to $INPUT_NEW_VERSION"
git tag "v$INPUT_NEW_VERSION"
git push origin main
git push origin "v$INPUT_NEW_VERSION"
