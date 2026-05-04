# Lab 01 — Evidence Pack Baseline

## Goal

Create the first Evidence Pack for the baseline `orders` and `customers` workload.

In this lab, you will capture the before-state evidence for the same logical query in SQL Server and PostgreSQL. You will not tune the query yet. The purpose is to establish a clean baseline that can be used later for comparison.

By the end of this lab, you should have:

- The baseline query recorded in the Evidence Pack
- SQL Server runtime metrics captured from `SET STATISTICS TIME` and `SET STATISTICS IO`
- A SQL Server actual execution plan saved as XML
- PostgreSQL plan, timing, and buffer evidence captured with `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)`
- A short bottleneck note for each engine

---

## Files used in this lab

| Purpose | File |
|---|---|
| Reusable Evidence Pack template | `evidence-pack/evidence-pack-template.md` |
| Lab-specific Evidence Pack | `evidence-pack/lab-01/baseline-orders-customers.md` |
| SQL Server baseline query | `scripts/sqlserver/10_baseline_query.sql` |
| PostgreSQL baseline query | `scripts/postgres/10_baseline_query.sql` |
| SQL Server before-state artifacts | `evidence-pack/lab-01/before/` |
| Future after-state artifacts | `evidence-pack/lab-01/after/` |

> For this lab, use the pre-created file `evidence-pack/lab-01/baseline-orders-customers.md`. The generic template exists so you can create new Evidence Packs later.

---

## Evidence Pack convention

The Markdown file is the main record. It contains the workload contract, the query, the metric summaries, the plan observations, and the bottleneck notes.

The `before/` and `after/` folders are for raw supporting artifacts.

For this lab, use:

```text
evidence-pack/lab-01/baseline-orders-customers.md
evidence-pack/lab-01/before/
evidence-pack/lab-01/after/
```

Use the `before/` folder for files captured before any tuning change, such as:

```text
evidence-pack/lab-01/before/orders_baseline_before.xml
evidence-pack/lab-01/before/sqlserver_messages_before.txt
evidence-pack/lab-01/before/postgres_explain_before.txt
```

The `after/` folder stays empty for now. It will be used later when a lab applies one tuning change and captures the after-state evidence.

---

## Step 1 — Open the lab-specific Evidence Pack

Open:

```text
evidence-pack/lab-01/baseline-orders-customers.md
```

Review the first sections:

- Scenario
- Workload Contract
- Baseline Query
- SQL Server Before State
- PostgreSQL Before State

For this lab, fill only the before-state sections and the first bottleneck notes. Do not fill the after-state comparison yet.

---

## Step 2 — Open the SQL Server baseline query

Open:

```text
scripts/sqlserver/10_baseline_query.sql
```

Use the clean logical query as the workload. The query should select the baseline `orders` and `customers` data filtered by order date.

Copy the bare `SELECT` statement into Section 3 of the Evidence Pack.

Do not include the statistics commands in Section 3. Section 3 represents the logical workload, not the capture procedure.

---

## Step 3 — Capture SQL Server runtime metrics and plan XML

In the SQL Server query editor, run the baseline query with:

```sql
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
SET STATISTICS XML ON;

-- Paste or run the baseline SELECT statement here
```

After the query completes:

1. Open the **Messages** output.
2. Copy the `STATISTICS TIME` and `STATISTICS IO` output.
3. Paste it into Section 4.3 of the Evidence Pack.
4. Record the key values in Section 4.4:
   - Rows returned
   - Elapsed time
   - CPU time
   - Logical reads for `orders`
   - Logical reads for `customers`
   - Total logical reads, if useful

Then open the XML plan result and save it as:

```text
evidence-pack/lab-01/before/orders_baseline_before.xml
```

Update Section 4.2 of the Evidence Pack to point to this file.

---

## Step 4 — Write the SQL Server bottleneck note

Review the read counts and the plan shape.

In Section 4.7, write one or two plain-language sentences describing where the work is concentrated.

Example:

> Both `orders` and `customers` are scanned, but most of the logical reads are concentrated on `orders`, making it the first area to investigate.

Do not propose a fix yet. This lab is about baseline capture, not tuning.

---

## Step 5 — Open the PostgreSQL baseline query

Open:

```text
scripts/postgres/10_baseline_query.sql
```

Use the PostgreSQL version of the same logical workload.

Make sure the query represents the same scenario as the SQL Server query:

- Same workload idea
- Same date filter
- Same expected result shape
- Same before-state goal

---

## Step 6 — Capture PostgreSQL plan, timing, and buffers

Run the PostgreSQL query with:

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
-- Paste or run the baseline SELECT statement here
```

After the query completes:

1. Copy the full `EXPLAIN ANALYZE` output.
2. Paste it into Section 6.2 of the Evidence Pack.
3. Record the key values in Section 6.3:
   - Rows returned or actual rows for the key node
   - Planning time
   - Execution time
   - Shared buffers hit
   - Shared buffers read
   - Temp blocks read or written, if present

Optionally, you may also save the raw output as:

```text
evidence-pack/lab-01/before/postgres_explain_before.txt
```

If you do, reference that file in Section 11.

---

## Step 7 — Write the PostgreSQL bottleneck note

Review the PostgreSQL plan tree and buffer evidence.

In Section 6.6, write one or two plain-language sentences describing where the work is concentrated.

Example:

> The plan scans the `orders` table and most of the buffer activity is concentrated there, making it the first area to investigate.

Again, do not propose the fix yet.

---

## Step 8 — Review the Evidence Pack

Before finishing the lab, check that the Evidence Pack contains:

- Scenario and workload contract
- Baseline query
- SQL Server before-state metrics
- SQL Server actual plan file reference
- SQL Server bottleneck note
- PostgreSQL `EXPLAIN ANALYZE` output
- PostgreSQL metric summary
- PostgreSQL bottleneck note

Leave the after-state and final decision sections empty for now.

---

## Completion criteria

You are done when:

- `evidence-pack/lab-01/baseline-orders-customers.md` contains both SQL Server and PostgreSQL before-state evidence
- `evidence-pack/lab-01/before/orders_baseline_before.xml` exists, if you captured the SQL Server XML plan as a file
- The bottleneck notes identify where the work is concentrated without proposing a fix

This gives you the first reusable baseline for the course.

