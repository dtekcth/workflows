#!/usr/bin/env bash

set -e
cd /github/workspace

apt update
apt install -y git python3-semver

# Mounting messes up permissions
git config --global --add safe.directory /github/workspace

case "$INPUT_NEW_VERSION" in
    patch)
        bump_function="bump_patch"
        ;;
    minor)
        bump_function="bump_minor"
        ;;
    major)
        bump_function="bump_major"
        ;;
esac

# Bump version based on previous git tag
if [[ ! -z "$bump_function" ]]; then
    ver="$(git describe --tags --abbrev=0 | sed 's/^v//')"
    INPUT_NEW_VERSION="$(python3 -c "import semver;print(semver.Version.parse('$ver').$bump_function())")"
fi

# Save version for output
echo "new_version=$INPUT_NEW_VERSION" >>"$GITHUB_OUTPUT"

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
