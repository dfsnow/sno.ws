#!/usr/bin/env bash
# Cloudflare Pages build. Hugo's Dart Sass transpiler needs the `sass`
# binary on PATH, which the Pages build image doesn't include.
set -euo pipefail

DART_SASS_VERSION="1.106.1"

mkdir -p "${HOME}/.local"
curl -sSfL "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz" \
  | tar -xz -C "${HOME}/.local"
export PATH="${HOME}/.local/dart-sass:${PATH}"

hugo
