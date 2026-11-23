#!/usr/bin/env bash
# Dump this host's Plausible + listmonk compose stacks into <out-dir> (format restore.sh reads).
set -euo pipefail
B=${1:?out dir}; mkdir -p "$B/clickhouse"; S=~/services
cd $S/listmonk && docker compose -p listmonk exec -T db pg_dump -U listmonk -Fc listmonk > "$B/listmonk.pgdump"
cd $S/plausible && docker compose -p plausible-analytics exec -T plausible_db pg_dump -U postgres -Fc plausible_db > "$B/plausible_db.pgdump"
for t in events_v2 sessions_v2 ingest_counters location_data; do
  docker compose -p plausible-analytics exec -T plausible_events_db clickhouse-client -q "SELECT * FROM plausible_events_db.$t FORMAT Native" > "$B/clickhouse/$t.native"
  echo "$t src=$(docker compose -p plausible-analytics exec -T plausible_events_db clickhouse-client -q "SELECT count() FROM plausible_events_db.$t")"
done
(cd "$B" && sha256sum *.pgdump clickhouse/* > SHA256SUMS)
