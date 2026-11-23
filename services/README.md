# Home services (thinkstation)

Plausible (`analytics.redleg.dev`), listmonk (`listmonk.redleg.dev`) and the
home Cloudflare tunnel run on the ThinkStation (Omarchy) as plain
`docker compose` projects, no Portainer. Layout on the host:

```
~/services/plausible/    Plausible/docker-compose.yml + compose.override.yml + clickhouse/ + .env
~/services/listmonk/     listmonk/docker-compose.yml + compose.override.yml
~/services/cloudflared/  Cloudflared/docker-compose.yml + compose.override.yml + .env
```

Project names (keep them, the volumes are keyed on them):
`plausible-analytics`, `listmonk`, `cloudflared`. Example:
`cd ~/services/plausible && docker compose -p plausible-analytics up -d`.

`.env` files hold secrets (`SECRET_KEY_BASE`, Google OAuth, `TUNNEL_TOKEN`)
and are never committed. Mode 600.

## Moving the services to another host
1. Copy `~/services` (with `.env`) to the new host and `docker compose pull`.
2. Rehearse: `dump.sh <dir>` on the old host, copy `<dir>`, `restore.sh <dir>` on the new one.
3. Cutover: stop `plausible` and listmonk `app` on the old host, `dump.sh`,
   copy, `restore.sh`, start the apps on the new host, then stop the old
   tunnel **before** starting the new one (two replicas = random split).
   Every tunnel route targets `127.0.0.1:<port>` with host networking, so no
   dashboard change is needed.

Don't tar a live ClickHouse volume (merges delete parts mid-read); `dump.sh`
exports the Plausible tables natively.

`clickhouse/*.xml` are from plausible/community-edition v2.1.4. Without them
the bind mounts become empty directories and ClickHouse's system logs grow
without limit (24 GB on the old wagner-server).
