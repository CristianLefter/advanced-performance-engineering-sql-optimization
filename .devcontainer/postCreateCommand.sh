#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for containers to become healthy..."
# Wait for postgres
until pg_isready -h localhost -U postgres -d perf_lab >/dev/null 2>&1; do
  sleep 2
done
echo "Postgres is ready."

# Wait for SQL Server
until /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong!Passw0rd" -Q "SELECT 1" >/dev/null 2>&1; do
  sleep 2
done
echo "SQL Server is ready."

echo "Tip: run setup scripts:"
echo "  - scripts/postgres/00_setup.sql"
echo "  - scripts/sqlserver/00_setup.sql"
