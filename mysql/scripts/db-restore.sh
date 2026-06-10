#!/usr/bin/env bash
set -euo pipefail

# Restore MySQL database from snapshot
# Usage: db-restore.sh <database_name>

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$DOCKER_DIR/mysql/data"

DB="${1:?Usage: db-restore.sh <database_name>}"
SNAPSHOT="$DATA_DIR/${DB}.snapshot.tar"

if ! docker run --rm -v "$DATA_DIR":/backup busybox test -f "/backup/${DB}.snapshot.tar"; then
  echo "ERROR: snapshot not found: ${DB}.snapshot.tar"
  echo "Run db-snapshot.sh $DB first."
  exit 1
fi

echo "==> Restoring database: $DB from snapshot"

cd "$DOCKER_DIR"
docker compose stop mysql

echo "==> Removing current data..."
docker run --rm -v "$DATA_DIR":/var/lib/mysql busybox rm -rf "/var/lib/mysql/$DB"

echo "==> Extracting snapshot..."
docker run --rm -v "$DATA_DIR":/var/lib/mysql busybox \
  tar -xf "/var/lib/mysql/${DB}.snapshot.tar" -C /var/lib/mysql

echo "==> Fixing ownership..."
docker run --rm -v "$DATA_DIR":/var/lib/mysql busybox chown -R 999:999 "/var/lib/mysql/$DB"

docker compose start mysql

sleep 3
TABLE_COUNT=$(docker run --rm -v "$DATA_DIR":/var/lib/mysql busybox find "/var/lib/mysql/$DB" -name '*.frm' 2>/dev/null | wc -l || true)
echo "==> Done: $DB restored ($TABLE_COUNT tables)"
