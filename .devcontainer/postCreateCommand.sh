#!/usr/bin/env bash
set -euo pipefail

echo "==> Devcontainer ready."

echo "==> Waiting for Postgres on postgres:5432..."
for i in {1..120}; do
  if bash -lc 'cat < /dev/null > /dev/tcp/postgres/5432' 2>/dev/null; then
    echo "✅ Postgres reachable."
    break
  fi
  sleep 2
done

echo "==> Waiting for SQL Server on mssql:1433..."
for i in {1..120}; do
  if bash -lc 'cat < /dev/null > /dev/tcp/mssql/1433' 2>/dev/null; then
    echo "✅ SQL Server reachable."
    break
  fi
  sleep 2
done

echo "==> Initializing Postgres (perf_lab)..."
PGPASSWORD=postgres psql -h postgres -U postgres -d perf_lab < scripts/postgres/00_setup.sql


echo "==> Initializing SQL Server (perf_lab)..."
sqlcmd -C -S mssql -U sa -P 'YourStrong!Passw0rd' -i scripts/sqlserver/00_setup.sql

echo "✅ Lab environment ready (both engines initialized)."
