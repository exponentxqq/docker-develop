#!/usr/bin/env bash
set -euo pipefail

# MySQL database snapshot (physical file copy)
# Usage: db-snapshot.sh <database_name>

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$DOCKER_DIR/mysql/data"

DB="${1:?Usage: db-snapshot.sh <database_name>}"
DB_DIR="$DATA_DIR/$DB"
SNAPSHOT="$DATA_DIR/${DB}.snapshot.tar"

if ! docker run --rm -v "$DATA_DIR":/var/lib/mysql busybox test -d "/var/lib/mysql/$DB"; then
  echo "ERROR: database directory not found: $DB"
  exit 1
fi

echo "==> Snapshotting database: $DB"

cd "$DOCKER_DIR"
docker compose stop mysql

echo "==> Creating snapshot..."
docker run --rm -v "$DATA_DIR":/var/lib/mysql -v "$DATA_DIR":/backup busybox \
  tar -cf "/backup/${DB}.snapshot.tar" -C /var/lib/mysql "$DB"

docker compose start mysql

SNAPSHOT_SIZE=$(docker run --rm -v "$DATA_DIR":/backup busybox du -sh "/backup/${DB}.snapshot.tar" | cut -f1)
TABLE_COUNT=$(docker run --rm -v "$DATA_DIR":/var/lib/mysql busybox find "/var/lib/mysql/$DB" -name '*.frm' | wc -l)
echo "==> Done: $SNAPSHOT ($SNAPSHOT_SIZE, $TABLE_COUNT tables)"
