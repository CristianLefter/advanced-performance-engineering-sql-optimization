# Lab 06 – Stability: Parameterization + Regression Guardrails

## Goal
We make performance stable over time by understanding:
- how parameterization can produce different plans (great for one value, awful for another)
- how to add guardrails so a good plan does not silently regress after data changes, stats updates, or deployments

We cover:
- SQL Server: parameter sensitivity + mitigations + Query Store guardrails (optional)
- Postgres: generic vs custom plans for prepared statements + practical monitoring guardrails

## What we measure (evidence)

### SQL Server
- SET STATISTICS IO, TIME ON
- Actual execution plan for:
  - two different parameter values
  - before/after mitigation
- Optional: Query Store evidence (forced plan)

### Postgres
- EXPLAIN (ANALYZE, BUFFERS) for:
  - two different parameter values
  - custom vs generic plan mode
- Notes: plan shape changes, rows, buffers, total time

## Setup
This lab uses lab-only tables created by the scripts.

Scripts we will create/use:
- Postgres:
  - scripts/postgres/60_generic_vs_custom.sql
  - scripts/postgres/61_guardrails.sql
- SQL Server:
  - scripts/sqlserver/60_parameter_sensitivity.sql
  - scripts/sqlserver/61_regression_guardrails.sql

## Part 1 — SQL Server: Parameter sensitivity

### 1) Baseline: same query, two values, different reality
Run:

sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/60_parameter_sensitivity.sql

Capture:
- STATISTICS IO/TIME output for both executions
- Actual execution plan (if possible)

What to look for:
- One plan choice that is fine for a small tenant but painful for a huge tenant (or the reverse)
- Large changes in logical reads, CPU, or elapsed time

### 2) Mitigation + regression guardrail
Run:

sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/61_regression_guardrails.sql

Capture:
- IO/TIME improvements using mitigation options
- Optional: Query Store output showing a forced plan (if enabled)

## Part 2 — Postgres: Generic plan vs custom plan

### 1) Baseline: prepared statement with skewed values
Run:

psql -h postgres -U postgres -d perf_lab -f scripts/postgres/60_generic_vs_custom.sql

Capture:
- EXPLAIN (ANALYZE, BUFFERS) output for both values
- Repeat in force_generic_plan mode and capture again

What to look for:
- A generic plan that is acceptable overall but not optimal for extremes
- Custom planning that adapts to the parameter value (often better for skew), but can add planning overhead

### 2) Guardrails / monitoring basics
Run:

psql -h postgres -U postgres -d perf_lab -f scripts/postgres/61_guardrails.sql

Capture:
- output from the script
- short notes about what is available in this environment

## What we learned
- Parameterization is good until data skew makes "typical" values not typical.
- Stability usually requires two layers:
  1) mitigation patterns (RECOMPILE, optimize for typical, query rewrite)
  2) regression guardrails (baseline metrics, plan monitoring, plan forcing where available)

## Cleanup (optional)
Lab tables are isolated:
- Postgres: public.lab06_skew (created by the Postgres scripts in this lab)
- SQL Server: dbo.Lab06Skew (created by the SQL Server scripts in this lab)
