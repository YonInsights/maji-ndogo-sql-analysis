\# Results Log



\## Phase 1 — Database Exploration



\*\*Date:\*\* 2026-09-29

\*\*Script:\*\* `sql/01\_database\_exploration.sql`



\### What I ran

\- `SHOW TABLES;`

\- `SELECT \* FROM <table> LIMIT 5;` for all 8 tables

\- `SELECT COUNT(\*)` for visits, water\_source, and location



\### What I found



| Table | Records | Meaning |

|---|---|---|

| `visits` | 60,146 | Field visits made during the survey |

| `water\_source` | 39,650 | Unique water sources in the country |

| `location` | 39,650 | Unique geographic locations |



\*\*Key insight:\*\* `water\_source` and `location` have the same row count, meaning \*\*each location has exactly one water source\*\*.



\*\*Second insight:\*\* `visits` (60,146) is greater than `water\_source` (39,650). Some sources were visited multiple times — likely those flagged as problematic (long queues or contamination).



---

## Phase 2 — Water Source Exploration

**Date:** 2026-09-29
**Script:** `sql/02_water_sources.sql`

### What I ran
- `SELECT DISTINCT type_of_water_source` — identify unique categories
- `GROUP BY type_of_water_source` with `COUNT(*)` — count sources per category
- `SUM(number_of_people_served)` per category — measure impact

### What I found

**5 unique source types** exist, with these totals:

| Type | # Sources | People Served | Avg / Source |
|---|---|---|---|
| shared_tap | 5,767 | 11,945,272 | ~2,071 |
| well | 17,383 | 4,841,724 | ~278 |
| tap_in_home | 7,265 | 4,678,880 | ~644 |
| tap_in_home_broken | 5,856 | 3,799,720 | ~649 |
| river | 3,379 | 2,362,544 | ~699 |
| **TOTAL** | **39,650** | **27,628,140** | — |

### Key insights

1. **Shared taps are the critical bottleneck.** They serve 11.9M people from only 5,767 sources — an average of ~2,071 people per tap. This is where queue-time problems will concentrate.

2. **5,856 broken home taps serve 3.8M people.** That's millions of people with installed infrastructure that doesn't work — a "silent" crisis.

3. **Rivers serve 2.36M people with the highest contamination risk** of any source type (open water, no protection).

4. **Wells are the most numerous** (17,383) but serve fewer people each — they're smaller, community-level sources.

5. **Cross-check:** Total source count = 39,650 ✅ matches Phase 1's `water_source` row count, confirming the data is complete and consistent.

---

## Phase 3 — Investigating Long Queues

**Date:** 2026-09-29
**Script:** `sql/03_water_source_visits.sql`

### What I ran
- Filtered `visits` for `time_in_queue > 500`
- Sorted worst queues first with `ORDER BY time_in_queue DESC`
- **JOINed** `visits` with `water_source` on `source_id` to identify which source types cause long queues
- Cross-checked with `COUNT(DISTINCT source_id)` to measure spread

### What I found

| Metric | Value |
|---|---|
| Visits with queue > 500 min | **105** |
| Distinct sources affected | **105** |
| Source type responsible | **shared_tap (100%)** |
| Average queue time | **519.2 minutes (~8.7 hours)** |
| Queue-time range of top 20 | 534–539 minutes (very tight) |

### Key insights

1. **Every extreme queue was at a shared tap.** No well, river, or home tap produced an 8-hour wait. This confirms Phase 2's prediction that shared taps are the overloaded source type.

2. **105 visits = 105 different sources.** This is *not* one broken tap being revisited — it's a nationwide systemic pattern.

3. **The queue-time range is suspiciously tight (534–539 min).** This is consistent with *physically consistent overload* (2,071 people per tap ≈ 8.7 hours) rather than random bad days.

4. **Actionable conclusion:** Policy intervention should target shared taps directly — either by building more of them, or repairing and expanding existing ones.

---

## Phase 4 — Investigating Water Quality (IN PROGRESS)

**Date:** 2026-09-29
**Script:** `sql/04_water_quality.sql`

### What I ran
- Explored `water_quality` structure and scale
- Listed distinct quality scores
- Counted perfect scores (score = 10)
- Counted records with `visit_count = 2`
- Attempted a 3-table JOIN to find "impossible" home taps

### What I found

| Metric | Value |
|---|---|
| Total records in `water_quality` | 60,146 |
| Distinct scores | 0, 1, 2, 3, 4, 5, 6, 7, 9, 10 |
| Records with score = 10 | 10,942 |
| Records with visit_count = 2 | 2,928 |
| "Impossible" home taps (JOIN result) | **0 rows** ⚠️ |

### Data anomalies already spotted

1. **A score of `0` exists** — outside the documented 1–10 range.
2. **Score `8` is completely missing** — the distinct list jumps 7 → 9.
3. **NULL values** appear in `record_id`, `visit_count`, and `subjective_quality_score`.

### Open question (to resolve next session)

The 3-table JOIN returned **0 rows**, but the course slides suggest ~218 rows should match.

Possible causes to investigate:
- The correct join key might not be `record_id` alone
- The `visit_count` filter should apply to `water_quality.visit_count` vs `visits.visit_count`
- Diagnostic queries (D5, D6, D7) are ready to run and will pinpoint the issue

### Next session plan
1. Run diagnostics D5, D6, D7 (already written in the SQL file)
2. Identify why the JOIN returns 0
3. Fix the query and confirm the true count of "impossible" records
4. Document final Phase 4 findings