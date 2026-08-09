#!/usr/bin/env sh

set -e
cd /github/workspace

# Mounting messes up permissions
git config --global --add safe.directory /github/workspace

# Commit as webredax
git config user.name webredax
git config user.email 309066399+webredax@users.noreply.github.com

# Add any changes made by the job so far
git add .

# Commit regardless of if there were any changes or not
git commit --allow-empty -m "Bump version to $INPUT_NEW_VERSION"

# Tag and push
git tag "v$INPUT_NEW_VERSION"
git push origin main
git push origin "v$INPUT_NEW_VERSION"
