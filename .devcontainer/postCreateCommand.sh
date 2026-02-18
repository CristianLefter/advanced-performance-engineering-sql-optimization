#!/usr/bin/env bash
set -euo pipefail

echo "==> Devcontainer ready."

echo "==> Checking that database ports are listening (services started by docker-compose)..."
for i in {1..60}; do
  if (nc -z localhost 5432 >/dev/null 2>&1) && (nc -z localhost 1433 >/dev/null 2>&1); then
    echo "✅ Ports 5432 (Postgres) and 1433 (SQL Server) are reachable."
    break
  fi
  sleep 2
done

echo ""
echo "Next steps (run via VS Code extensions):"
echo "  - scripts/postgres/00_setup.sql"
echo "  - scripts/sqlserver/00_setup.sql"
echo ""
echo "Connection info:"
echo "  Postgres: localhost:5432 db=perf_lab user=postgres pass=postgres"
echo "  SQL Server: localhost,1433 db=master user=sa pass=YourStrong!Passw0rd"
