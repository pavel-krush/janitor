#!/bin/bash
set -e

NAME=$(python3 -c "import json; d=json.load(open('info.json')); print(d['name'])")
VERSION=$(python3 -c "import json; d=json.load(open('info.json')); print(d['version'])")
FOLDER="${NAME}_${VERSION}"
ARCHIVE="${FOLDER}.zip"

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

rsync -a \
  --exclude='.git' \
  --exclude='*.zip' \
  --exclude='build.sh' \
  --exclude='CLAUDE.md' \
  --exclude='.gitignore' \
  --exclude='.claude' \
  . "$TMP/$FOLDER/"

(cd "$TMP" && zip -r - "$FOLDER") > "$ARCHIVE"

echo "Built: $ARCHIVE"
