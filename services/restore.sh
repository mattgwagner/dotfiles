#!/usr/bin/env bash
# Restore wagner-server Plausible + listmonk backups into omarchy's ~/services stacks.
# Usage: restore.sh <backup-dir>. Wipes the omarchy volumes first. Apps are left STOPPED.
set -euo pipefail
B=$(realpath "${1:?backup dir}"); S=~/services
cd $S/listmonk
docker compose -p listmonk down -v --remove-orphans 2>/dev/null || true
docker compose -p listmonk up -d --wait db
docker compose -p listmonk exec -T db pg_restore -U listmonk -d listmonk --no-owner --exit-on-error < "$B/listmonk.pgdump"
echo "listmonk subscribers: $(docker compose -p listmonk exec -T db psql -U listmonk -tAc 'select count(*) from subscribers')"

cd $S/plausible
docker compose -p plausible-analytics down -v --remove-orphans 2>/dev/null || true
docker compose -p plausible-analytics up -d --wait plausible_db plausible_events_db
docker compose -p plausible-analytics exec -T plausible_db createdb -U postgres plausible_db
docker compose -p plausible-analytics exec -T plausible_db pg_restore -U postgres -d plausible_db --no-owner --exit-on-error < "$B/plausible_db.pgdump"
echo "plausible sites: $(docker compose -p plausible-analytics exec -T plausible_db psql -U postgres -d plausible_db -tAc 'select count(*) from sites')"
docker compose -p plausible-analytics run --rm --no-deps plausible sh -c "/entrypoint.sh db createdb && /entrypoint.sh db migrate" 2>&1 | tail -3
CH="docker compose -p plausible-analytics exec -T plausible_events_db clickhouse-client -d plausible_events_db"
for t in events_v2 sessions_v2 ingest_counters location_data; do
  $CH -q "TRUNCATE TABLE $t"
  $CH -q "INSERT INTO $t FORMAT Native" < "$B/clickhouse/$t.native"
  echo "$t: $($CH -q "SELECT count() FROM $t")"
done
echo RESTORE-OK
