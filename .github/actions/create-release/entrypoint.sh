#!/usr/bin/env bash

set -e
cd /github/workspace

apt-get update
apt-get install -y git python3-semver curl

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

# Tag latest commit
git tag "v$INPUT_NEW_VERSION"
git push origin "v$INPUT_NEW_VERSION"

# Create GitHub release
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2026-03-10" \
  https://api.github.com/repos/$GITHUB_ACTION_REPOSITORY/releases \
  -d '{"tag_name":"'"$INPUT_NEW_VERSION"'"}' || exit 1
