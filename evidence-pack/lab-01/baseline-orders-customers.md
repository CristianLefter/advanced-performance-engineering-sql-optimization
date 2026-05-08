# Evidence Pack — Query Performance Baseline

> Purpose: capture the evidence before and after a query change so the result is measurable, comparable, and defensible.
>
> Use the same query, same parameters, same database, and same environment when comparing Before and After states. Change one thing at a time.

---

## 1. Scenario

| Field | Value |
|---|---|
| Evidence Pack ID | `m01-c03-baseline-orders-customers` |
| Module / clip | The Performance Engineering Workflow / Creating the Evidence Pack |
| Query / workload name | Orders and customers filtered by order date |
| Engine(s) | SQL Server / PostgreSQL |
| Environment | GitHub Codespaces |
| Database | `perf_lab` |
| Date captured | `<YYYY-MM-DD>` |
| Captured by | Cristian Lefter |
| Goal | Establish a baseline before any tuning change |

---

## 2. Workload Contract

Record the exact workload rules. Do not silently change them after capturing metrics.

| Field | Value |
|---|---|
| SQL Server query file | `scripts/sqlserver/10_baseline_query.sql` |
| PostgreSQL query file | `scripts/postgres/10_baseline_query.sql` |
| Parameters / literals | Date filter: `'2023-01-01'` |
| Expected result shape | `order_id`, `order_date`, `customer_name`; ordering not required unless specified by the query |
| Cache state note | Not controlled |
| Number of runs | `1` |
| Result set preserved after change? | Not tested yet |

> Note: For this first baseline capture, we are not applying a tuning change yet. The After State sections remain empty until a later comparison.

---

## 3. Baseline Query

Paste the exact logical query used for this capture. Do not rewrite it after recording the metrics.

```sql
-- Baseline Query
```

---

# SQL Server Evidence

## 4. SQL Server — Before State

### 4.1 Capture commands

```sql
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
SET STATISTICS XML ON;

SELECT
    o.order_id,
    o.order_date,
    c.customer_name
FROM dbo.orders o
JOIN dbo.customers c
    ON o.customer_id = c.customer_id
WHERE o.order_date >= '2023-01-01';
```

> Note: for estimation analysis in later clips, compare Estimated Rows vs. Actual Rows in the Actual Execution Plan XML properties. Do not add extra commands unless the demo specifically asks for them.

### 4.2 Execution plan artifact

| Field | Value |
|---|---|
| Actual plan file | `orders_baseline_before.xml` |
| Plan type | Actual execution plan |
| Capture method | `SET STATISTICS XML ON` in Codespaces / VS Code mssql extension |
| Plan viewer used | VS Code mssql extension / Azure Data Studio / other |

### 4.3 Raw runtime metrics

Paste the relevant output from the **Messages** tab.

```text
-- Paste SQL Server STATISTICS TIME and STATISTICS IO output here
```

### 4.4 Metric summary

| Metric | Estimated | Actual / observed | Gap or change | Notes |
|---|---:|---:|---:|---|
| Rows returned | — | `<value>` | — | From result grid |
| Key operator estimated / actual rows | `<value>` | `<value>` | — | From Actual plan XML properties, not from Messages tab. Use the actual/estimated ratio in Section 5.4 when comparing Before and After. |
| Elapsed time | — | `<value> ms` | — | From `SQL Server Execution Times` |
| CPU time | — | `<value> ms` | — | From `SQL Server Execution Times` |
| Logical reads — `orders` | — | `<value>` | — | From `Table 'orders'` |
| Logical reads — `customers` | — | `<value>` | — | From `Table 'customers'` |
| Total logical reads | — | `<value>` | — | Optional manual total |

### 4.5 Plan observations and red flags

| Observation | Evidence |
|---|---|
| Access pattern on `orders` | Scan / seek / other |
| Access pattern on `customers` | Scan / seek / other |
| Join operator | Nested loops / hash match / merge join |
| Sort operator present? | Yes / No |
| Implicit conversion warning? | Covered in Decoding Execution Plans: Finding the Signal in the Noise — leave as Not checked for this clip |
| Spill warning? | Covered in Decoding Execution Plans: Finding the Signal in the Noise — leave as Not checked for this clip |
| Lookup pattern? | Key lookup / RID lookup / none / not checked |
| Highest-work area | `<operator or table>` |

### 4.6 Constraint classification

| Category | Value |
|---|---|
| Primary constraint candidate | CPU / I/O / Memory / Cardinality estimation / Not clear yet |
| Evidence | `<CPU high, reads high, spill warning, estimate gap, etc.>` |
| Wait evidence, if captured | `<optional; not captured in this clip>` |

> For this clip, it is acceptable to leave wait evidence as `not captured`. Later clips may add Query Store, DMV, or plan-level wait evidence when the lab requires it.

### 4.7 Bottleneck note

Write one or two plain-language sentences. Do not propose the fix yet.

> Example: Both `orders` and `customers` are scanned, but most of the logical reads are concentrated on `orders`, making it the first area to investigate.

---

## 5. SQL Server — After State

Use this section only after applying one tuning change.

### 5.1 Change applied

| Field | Value |
|---|---|
| Change type | Index / query rewrite / statistics update / parameterization / other |
| Change description | `<what changed>` |
| Only one change? | Yes — required for a valid comparison |
| Script / migration file | `<filename>` |

### 5.2 Execution plan artifact

| Field | Value |
|---|---|
| Actual plan file | `orders_baseline_after.xml` |
| Plan type | Actual execution plan |
| Capture method | `SET STATISTICS XML ON` in Codespaces / VS Code mssql extension |

### 5.3 Raw runtime metrics

```text
-- Paste after-state SQL Server STATISTICS TIME and STATISTICS IO output here
```

### 5.4 Metric comparison

| Metric | Before | After | Change | Keep? |
|---|---:|---:|---:|---|
| Rows returned | `<value>` | `<value>` | Should match | Yes / No |
| Elapsed time | `<value> ms` | `<value> ms` | `<%>` | Yes / No |
| CPU time | `<value> ms` | `<value> ms` | `<%>` | Yes / No |
| Logical reads — `orders` | `<value>` | `<value>` | `<%>` | Yes / No |
| Logical reads — `customers` | `<value>` | `<value>` | `<%>` | Yes / No |
| Total logical reads | `<value>` | `<value>` | `<%>` | Yes / No |
| Key estimate ratio | `<actual/estimated>` | `<actual/estimated>` | Better / worse | Yes / No |

### 5.5 After-state bottleneck note

> `<Did the original bottleneck disappear, reduce, or move somewhere else?>`

---

# PostgreSQL Evidence

## 6. PostgreSQL — Before State

### 6.1 Capture command

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    o.order_id,
    o.order_date,
    c.customer_name
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_date >= DATE '2023-01-01';
```

### 6.2 Plan output

Paste the full `EXPLAIN ANALYZE` output.

```text
-- Paste PostgreSQL EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) output here
```

### 6.3 Metric summary

| Metric | Estimated | Actual / observed | Gap or change | Notes |
|---|---:|---:|---:|---|
| Rows returned | — | `<value>` | — | From final actual rows or result query |
| Key node estimated / actual rows | `<value>` | `<value>` | — | From `rows=` and `actual rows=`. Use the actual/estimated ratio in Section 7.3 when comparing Before and After. |
| Planning time | — | `<value> ms` | — | From bottom of plan output |
| Execution time | — | `<value> ms` | — | From bottom of plan output |
| Shared buffers hit | — | `<value>` | — | From `Buffers:` lines |
| Shared buffers read | — | `<value>` | — | From `Buffers:` lines |
| Temp blocks read | — | `<value>` | — | Indicates spill / memory pressure if present |
| Temp blocks written | — | `<value>` | — | Indicates spill / memory pressure if present |

### 6.4 Plan observations and red flags

| Observation | Evidence |
|---|---|
| Access pattern on `orders` | Seq Scan / Index Scan / Bitmap Heap Scan / other |
| Access pattern on `customers` | Seq Scan / Index Scan / Bitmap Heap Scan / other |
| Join operator | Hash Join / Nested Loop / Merge Join |
| Sort operator present? | Yes / No |
| Large estimate gap? | Covered in Decoding Execution Plans: Finding the Signal in the Noise — leave as Not checked for this clip |
| Temp read/write present? | Covered in Decoding Execution Plans: Finding the Signal in the Noise — leave as Not checked for this clip |
| High planning time relative to execution? | Covered in Stability and Scalability: Parameters and Parsing — leave as Not checked for this clip |
| Highest-work area | `<operator or table>` |

### 6.5 Constraint classification

| Category | Value |
|---|---|
| Primary constraint candidate | CPU / I/O / Memory / Cardinality estimation / Not clear yet |
| Evidence | `<buffers read high, temp read/write, estimate gap, CPU-heavy operator, etc.>` |
| Wait evidence, if captured | `<optional; not captured in this clip>` |

> For this clip, it is acceptable to leave wait evidence as `not captured`. Later clips may add PostgreSQL activity or statement-level evidence when the lab requires it.

### 6.6 Bottleneck note

Write one or two plain-language sentences. Do not propose the fix yet.

> Example: The plan scans the `orders` table and most of the buffer activity is concentrated there, making it the first area to investigate.

---

## 7. PostgreSQL — After State

Use this section only after applying one tuning change.

### 7.1 Change applied

| Field | Value |
|---|---|
| Change type | Index / query rewrite / statistics update / parameterization / other |
| Change description | `<what changed>` |
| Only one change? | Yes — required for a valid comparison |
| Script / migration file | `<filename>` |

### 7.2 Plan output

```text
-- Paste after-state PostgreSQL EXPLAIN output here
```

### 7.3 Metric comparison

| Metric | Before | After | Change | Keep? |
|---|---:|---:|---:|---|
| Rows returned | `<value>` | `<value>` | Should match | Yes / No |
| Planning time | `<value> ms` | `<value> ms` | `<%>` | Yes / No |
| Execution time | `<value> ms` | `<value> ms` | `<%>` | Yes / No |
| Shared buffers hit | `<value>` | `<value>` | `<%>` | Yes / No |
| Shared buffers read | `<value>` | `<value>` | `<%>` | Yes / No |
| Temp blocks read | `<value>` | `<value>` | `<%>` | Yes / No |
| Temp blocks written | `<value>` | `<value>` | `<%>` | Yes / No |
| Key estimate ratio | `<actual/estimated>` | `<actual/estimated>` | Better / worse | Yes / No |

### 7.4 After-state bottleneck note

> `<Did the original bottleneck disappear, reduce, or move somewhere else?>`

---

# 8. Cross-Engine Comparison

Use this when the same logical workload is tested in both engines.

| Metric category | SQL Server | PostgreSQL | Notes |
|---|---|---|---|
| Plan shape | `<scan/seek/join/sort>` | `<scan/index/join/sort>` | Do not expect identical plans |
| Time | CPU: `<ms>` / elapsed: `<ms>` | planning: `<ms>` / execution: `<ms>` | Not perfectly equivalent |
| Work done | logical reads: `<value>` | buffers hit/read: `<value>` | Compare directionally, not as identical units |
| Estimate quality | `<actual/estimated>` | `<actual/estimated>` | Useful for Decoding Execution Plans: Finding the Signal in the Noise |
| Primary constraint candidate | `<CPU/I/O/memory/etc.>` | `<CPU/I/O/memory/etc.>` | Based on captured evidence |
| Main bottleneck note | `<sentence>` | `<sentence>` | Plain-language diagnosis |

---

# 9. Lab-Specific Addendum

Use only the rows relevant to the current lab. Leave the others blank.

| Course area | Extra evidence to capture |
|---|---|
| The Performance Engineering Workflow — Creating the Evidence Pack | Baseline query, plan artifact, runtime metrics, reads/buffers, first bottleneck note |
| Decoding Execution Plans: Finding the Signal in the Noise — Plan reading | Key operators, row flow, estimated vs. actual rows |
| Decoding Execution Plans: Finding the Signal in the Noise — Red flags | Scans, join explosion, sort/hash spill, implicit conversion |
| Decoding Execution Plans: Finding the Signal in the Noise — Constraint classification | CPU / I/O / memory evidence, optional waits if captured |
| Strategic Indexing: From Basic B-Trees to Advanced Models — Indexing | Index definition, seek/scan change, lookup/fetch reduction, write trade-off note |
| Strategic Indexing: From Basic B-Trees to Advanced Models — Covering indexes | SQL Server key lookup removal; PostgreSQL heap fetch reduction / index-only scan evidence |
| Strategic Indexing: From Basic B-Trees to Advanced Models — Over-indexing | Redundant indexes found, storage/write impact, read performance preserved |
| Query Refactoring: Reducing the Workload — Projection / filtering | Column list change, rows filtered earlier, reads/buffers/network payload direction |
| Query Refactoring: Reducing the Workload — Join refactoring | Row counts before/after join, join operator change, row-flow reduction |
| Query Refactoring: Reducing the Workload — CTE vs. temp table | Estimate stability, plan stability, temp object cost, runtime trade-off |
| Stability and Scalability: Parameters and Parsing — Parsing / parameterization | Literal vs. parameterized form, planning/compile signal, plan reuse signal |
| Stability and Scalability: Parameters and Parsing — Regression guardrail | Baseline file, after file, comparison result, pass/fail threshold |
| Capstone: The End-to-End Optimization Challenge | Final diagnosis, chosen fix, measured result, communication summary |

> Note: If course module titles change during production, update this table to keep the template aligned with the final outline.

---

# 10. Final Decision

| Question | Answer |
|---|---|
| Did the result set stay the same? | Yes / No |
| Did the main cost decrease? | Yes / No |
| Did the plan shape improve? | Yes / No / Mixed |
| Did the bottleneck disappear or move? | Disappeared / Reduced / Moved / Not clear |
| Is the change worth keeping? | Yes / No / Needs more testing |
| What should be monitored next? | `<stats, index usage, writes, regressions, etc.>` |

## Final conclusion

Write two or three sentences suitable for a pull request, review meeting, or production change note.

> `<Example: The change reduced the main read cost on orders while preserving the same result set. The plan shape moved from scan-heavy access to a more targeted strategy. Based on the before/after evidence, this is a defensible improvement worth keeping.>`

---

# 11. Files and Artifacts

| Artifact | File / Location |
|---|---|
| SQL Server before plan | `evidence-pack/lab-01/before/orders_baseline_before.xml` |
| SQL Server after plan | `evidence-pack/lab-01/after/orders_baseline_after.xml` |
| PostgreSQL before output | Embedded in this file, Section 6.2 |
| PostgreSQL after output | Embedded in this file, Section 7.2 |
| SQL Server supporting script | `scripts/sqlserver/10_baseline_query.sql` |
| PostgreSQL supporting script | `scripts/postgres/10_baseline_query.sql` |
| Change script | `<script filename>` |
| Notes / screenshots | `<optional>` |

---

# 12. Recording Notes

For the **Creating the Evidence Pack** demo, fill only the **Before State** sections and the first bottleneck notes. The After State, comparison, and lab-specific sections exist so the same template can be reused throughout the course.

For the first recording pass, the learner should see that the Evidence Pack is just a simple Markdown document with a disciplined structure: query, plan, metrics, and diagnosis.
