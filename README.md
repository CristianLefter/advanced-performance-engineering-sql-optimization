# Advanced Performance Engineering and SQL Optimization (Labs)

This repository is the hands-on companion for the **Advanced Performance Engineering and SQL Optimization** course.

**Goal:** practice a repeatable optimization workflow across **SQL Server** and **PostgreSQL**:

> capture evidence → read the plan → compare estimates vs actuals → identify the real bottleneck → apply the right fix → re-measure → document

## Quick start (GitHub Codespaces)

1. Open this repo in **GitHub Codespaces**.
2. The dev container starts **SQL Server** and **PostgreSQL** automatically.
3. Run the setup scripts to create schema + seed data:
   - SQL Server: `scripts/sqlserver/00_setup.sql`
   - Postgres: `scripts/postgres/00_setup.sql`

Then start with:
- `labs/lab-00-codespaces-connect.md`
- `labs/lab-01-evidence-pack-baseline.md`

## Connecting from VS Code

### In Codespaces (recommended)
Your VS Code runs inside the **workspace** container. Connect using the **service names**:

#### SQL Server
- Host: `mssql`
- Port: `1433`
- User: `sa`
- Password: `YourStrong!Passw0rd`
- Database: `perf_lab`

#### PostgreSQL
- Host: `postgres`
- Port: `5432`
- User: `postgres`
- Password: `postgres`
- Database: `perf_lab`

### From your local machine (optional richer UI)
Use the forwarded ports shown in the **Ports** tab:

#### SQL Server
- Host: `localhost`
- Port: `1433`

#### PostgreSQL
- Host: `localhost`
- Port: `5432`


## Repository map

- `.devcontainer/` – Codespaces config (containers + ports + extensions)
- `datasets/` – schema notes + data dictionary
- `scripts/` – setup + “bad → better” queries per engine
- `labs/` – step-by-step labs aligned to the course
- `evidence-pack/` – templates + collection helpers

## Evidence Pack convention

For every change you make, create a folder:

```
evidence-pack/<lab-id>/<change-id>/
  before/
  after/
  notes.md
```

Each `before/` and `after/` includes:
- plan output
- runtime metrics (time / CPU / reads/buffers)
- a short narrative of what changed and why

## License
MIT (see `LICENSE`).
