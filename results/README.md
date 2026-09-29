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

### Next step
Phase 3 — investigate the extreme queue times (>500 minutes) and identify which source types cause them.
