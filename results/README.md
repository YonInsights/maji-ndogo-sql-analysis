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



\### Next step

Phase 2 — identify the unique types of water sources.

