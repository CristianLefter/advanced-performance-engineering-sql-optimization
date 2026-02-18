#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE="$ROOT/.devcontainer/docker-compose.yml"

echo "==> Starting services"
docker compose -f "$COMPOSE" up -d

echo "==> Waiting for PostgreSQL..."
until docker exec perf-postgres pg_isready -U postgres -d perf_lab >/dev/null 2>&1; do
  sleep 2
done
echo "PostgreSQL is ready."

echo "==> Waiting for SQL Server..."
until docker logs perf-mssql 2>/dev/null | grep -q "SQL Server is now ready for client connections"; do
  sleep 2
done
echo "SQL Server is ready."

echo "==> Running PostgreSQL setup"
docker exec -i perf-postgres psql -U postgres -d perf_lab < "$ROOT/scripts/postgres/00_setup.sql"

echo "==> Running SQL Server setup"
# sqlcmd path differs across images; detect it
SQLCMD_PATH="$(docker exec perf-mssql bash -lc 'command -v sqlcmd || find / -name sqlcmd 2>/dev/null | head -n 1')"
if [[ -z "$SQLCMD_PATH" ]]; then
  echo "ERROR: sqlcmd not found inside perf-mssql container."
  exit 1
fi

# Copy script into the container (sqlcmd reads inside-container files reliably)
docker cp "$ROOT/scripts/sqlserver/00_setup.sql" perf-mssql:/tmp/00_setup.sql
docker exec -i perf-mssql "$SQLCMD_PATH" -C -S localhost -U sa -P 'YourStrong!Passw0rd' -i /tmp/00_setup.sql

echo "==> Done. Both engines are initialized."
