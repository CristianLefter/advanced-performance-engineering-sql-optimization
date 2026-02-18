# Lab 00 – Open Codespaces + Connect to SQL Server + Postgres

## Goal
We verify the environment and make sure we can execute queries in both engines.

## 1) Confirm containers are running
In the VS Code terminal:

- PostgreSQL should answer:
  - `pg_isready -h localhost -U postgres -d perf_lab`
- SQL Server should answer:
  - `/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong!Passw0rd" -Q "SELECT @@VERSION"`

## 2) Connect from VS Code extensions

### SQL Server (MSSQL extension)
Create a connection with:
- Server: `localhost,1433`
- Authentication: SQL Login
- User: `sa`
- Password: `YourStrong!Passw0rd`
- Database: `master` (we'll create `perf_lab` in the setup script)

### PostgreSQL (PostgreSQL extension)
Create a connection with:
- Host: `localhost`
- Port: `5432`
- User: `postgres`
- Password: `postgres`
- Database: `perf_lab`

## 3) Run setup scripts
- SQL Server: `scripts/sqlserver/00_setup.sql`
- Postgres: `scripts/postgres/00_setup.sql`

> After setup, both engines will contain the same logical schema and data theme (Orders).

## 4) Quick sanity query (both engines)
Run:

- Count customers
- Count orders
- Count order items

You should see non-trivial row counts (tens of thousands).
