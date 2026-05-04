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
- `evidence-pack/` – Evidence Pack template, lab-specific proof files, raw before/after artifacts, and collection helpers

## Evidence Pack convention

The Evidence Pack is the proof record for each lab.

Use one main Markdown file per lab:

```text
evidence-pack/<lab-id>/<evidence-pack-name>.md
```

That Markdown file is the primary record. It contains the workload contract, baseline query, capture commands, raw runtime metrics, plan observations, bottleneck notes, before/after comparisons, and the final decision.

Each lab also has optional raw artifact folders:

```text
evidence-pack/<lab-id>/before/
evidence-pack/<lab-id>/after/
```

Use `before/` for raw artifacts captured before a tuning change, such as SQL Server XML plans, copied message output, PostgreSQL EXPLAIN output, or screenshots.

Use `after/` for raw artifacts captured after exactly one tuning change.

The Markdown file tells the story. The `before/` and `after/` folders hold the raw proof.

## License
MIT (see `LICENSE`).
