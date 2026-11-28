#!/usr/bin/env bash
# Publishes a test build of 18 Down to GitHub Pages (https://kadejc.github.io/18-down-test/).
# Usage: ./deploy.sh [path to an 18-down checkout] [git ref to build]
#   defaults: ../18-down-gameplay, its current checkout
# It builds 18-down.html there with `node build.js`, wraps it with the tags a phone needs, and pushes index.html here.
set -euo pipefail
SRC="${1:-../18-down-gameplay}"
HERE="$(cd "$(dirname "$0")" && pwd)"
(cd "$SRC" && node build.js >/dev/null)
REF="$(git -C "$SRC" rev-parse --short HEAD)"
BRANCH="$(git -C "$SRC" rev-parse --abbrev-ref HEAD)"
{
  printf '<!doctype html>\n<meta charset="utf-8">\n'
  printf '<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n'
  printf '<meta name="robots" content="noindex,nofollow">\n'
  printf '<!-- 18 Down test build: branch %s, commit %s -->\n' "$BRANCH" "$REF"
  # test-guard.js: no writes to the live database, and a one-time progress reset (see the file)
  printf '<script>\n'; cat "$HERE/test-guard.js"; printf '</script>\n'
  cat "$SRC/18-down.html"
} > "$HERE/index.html"
cd "$HERE"
git add index.html
if git diff --cached --quiet; then echo "No changes to publish."; exit 0; fi
git commit -q -m "Test build from $BRANCH @ $REF"
git push -q origin HEAD:main
echo "Published $BRANCH @ $REF. GitHub Pages updates in about a minute."
