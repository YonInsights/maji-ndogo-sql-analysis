# Results Log

This document records the SQL analysis results phase by phase.

Each phase includes:

* Analysis objective
* SQL script used
* Queries performed
* Findings
* Key insights
* Next steps where applicable

---

## Analysis Progress

| Phase   | Topic                       | Status         |
| ------- | --------------------------- | -------------- |
| Phase 1 | Database Exploration        | ✅ Complete     |
| Phase 2 | Water Source Exploration    | ✅ Complete     |
| Phase 3 | Long Queue Investigation    | ✅ Complete     |
| Phase 4 | Water Quality Investigation | 🔄 In Progress |

---

# Phase 1: Database Exploration

**Date:** 2026-09-29
**Script:** `sql/01_database_exploration.sql`

## Objective

Understand the database structure, table sizes, and relationships between the main datasets before starting detailed analysis.

## SQL Analysis Performed

* `SHOW TABLES;`
* `SELECT * FROM <table> LIMIT 5;` for all 8 tables
* `SELECT COUNT(*)` for `visits`, `water_source`, and `location`

## Findings

| Table          | Records | Meaning                             |
| -------------- | ------: | ----------------------------------- |
| `visits`       |  60,146 | Field visits made during the survey |
| `water_source` |  39,650 | Unique water sources in the country |
| `location`     |  39,650 | Unique geographic locations         |

### Key Insights

**1. One water source per location**

`water_source` and `location` have the same row count, meaning **each location has exactly one water source**.

**2. Some water sources were visited multiple times**

`visits` contains 60,146 records compared with 39,650 water sources.

This means some sources were visited multiple times, likely those flagged as problematic, such as long queues or contamination.

---

# Phase 2: Water Source Exploration

**Date:** 2026-09-29
**Script:** `sql/02_water_sources.sql`

## Objective

Understand the distribution of water sources and measure how many people each source type serves.

## SQL Analysis Performed

* `SELECT DISTINCT type_of_water_source` to identify unique categories
* `GROUP BY type_of_water_source` with `COUNT(*)` to count sources per category
* `SUM(number_of_people_served)` per category to measure impact

## Findings

There are **5 unique source types**.

| Type                 |  # Sources |  People Served | Avg / Source |
| -------------------- | ---------: | -------------: | -----------: |
| `shared_tap`         |      5,767 |     11,945,272 |       ~2,071 |
| `well`               |     17,383 |      4,841,724 |         ~278 |
| `tap_in_home`        |      7,265 |      4,678,880 |         ~644 |
| `tap_in_home_broken` |      5,856 |      3,799,720 |         ~649 |
| `river`              |      3,379 |      2,362,544 |         ~699 |
| **TOTAL**            | **39,650** | **27,628,140** |            — |

## Key Insights

### 1. Shared taps are the critical bottleneck

Shared taps serve **11.9M people from only 5,767 sources**, with an average of approximately **2,071 people per tap**.

This is where queue-time problems will concentrate.

### 2. Broken home taps affect millions of people

There are **5,856 broken home taps serving 3.8M people**.

This represents millions of people with installed infrastructure that does not work.

### 3. Rivers have high contamination risk

Rivers serve **2.36M people** and have the highest contamination risk of any source type because they are open water sources with no protection.

### 4. Wells are the most numerous source

Wells account for **17,383 sources**, making them the most numerous source type.

They serve fewer people per source, with an average of approximately **278 people per well**.

### 5. Data consistency cross-check

Total source count:

**39,650**

This matches Phase 1's `water_source` row count, confirming that the data is complete and consistent.

---

# Phase 3: Investigating Long Queues

**Date:** 2026-09-29
**Script:** `sql/03_water_source_visits.sql`

## Objective

Identify extreme queue times and determine which water source types are responsible for long waiting times.

## SQL Analysis Performed

* Filtered `visits` for `time_in_queue > 500`
* Sorted the longest queues first using `ORDER BY time_in_queue DESC`
* Joined `visits` with `water_source` using `source_id`
* Used `COUNT(DISTINCT source_id)` to measure how widely the problem was distributed

## Findings

| Metric                      |                          Value |
| --------------------------- | -----------------------------: |
| Visits with queue > 500 min |                        **105** |
| Distinct sources affected   |                        **105** |
| Source type responsible     |          **shared_tap (100%)** |
| Average queue time          | **519.2 minutes (~8.7 hours)** |
| Queue-time range of top 20  |            **534–539 minutes** |

## Key Insights

### 1. Every extreme queue occurred at a shared tap

All extreme queues were recorded at **shared taps**.

No well, river, or home tap produced an 8-hour wait.

This confirms Phase 2's prediction that shared taps are the overloaded source type.

### 2. The problem affects different sources

There were:

* **105 extreme queue visits**
* **105 distinct affected sources**

This means the result is not one broken tap being repeatedly visited.

It shows a nationwide systemic pattern.

### 3. Queue times are unusually concentrated

The top 20 queue times range from **534 to 539 minutes**.

This tight range is consistent with physically consistent overload, where approximately **2,071 people per tap** corresponds to approximately **8.7 hours** of waiting, rather than random bad days.

### 4. Actionable conclusion

The analysis indicates that policy intervention should target **shared taps directly**, either by:

* Building more shared taps
* Repairing existing infrastructure
* Expanding existing capacity

---

# Phase 4: Investigating Water Quality

**Status:** 🔄 **IN PROGRESS**

**Date:** 2026-09-29
**Script:** `sql/04_water_quality.sql`

## Objective

Explore water quality measurements, identify data-quality issues, and investigate records that may represent "impossible" home tap conditions.

## SQL Analysis Performed

* Explored the `water_quality` structure and scale
* Listed distinct quality scores
* Counted perfect scores where `score = 10`
* Counted records where `visit_count = 2`
* Attempted a 3-table JOIN to identify "impossible" home taps

## Findings

| Metric                               |                             Value |
| ------------------------------------ | --------------------------------: |
| Total records in `water_quality`     |                        **60,146** |
| Distinct scores                      | **0, 1, 2, 3, 4, 5, 6, 7, 9, 10** |
| Records with score = 10              |                        **10,942** |
| Records with visit_count = 2         |                         **2,928** |
| "Impossible" home taps (JOIN result) |                     **0 rows** ⚠️ |

## Data Anomalies Identified

### 1. Score of `0`

A score of **0** exists even though the documented score range is **1–10**.

### 2. Score of `8` is missing

The distinct score list jumps from:

`7 → 9`

No records currently appear with a score of **8**.

### 3. NULL values

`NULL` values appear in:

* `record_id`
* `visit_count`
* `subjective_quality_score`

These values require further investigation before drawing conclusions from the water-quality analysis.

---

## Open Question

The 3-table JOIN returned **0 rows**, but the course slides suggest approximately **218 rows** should match.

The current query therefore requires further investigation.

### Possible Causes

* The correct join key might not be `record_id` alone
* The `visit_count` filter might need to apply to `water_quality.visit_count` rather than `visits.visit_count`
* Another relationship between the tables may need to be included

Diagnostic queries **D5, D6, and D7** are already prepared in the SQL file and will help identify the issue.

---

## Next Session Plan

1. Run diagnostic queries **D5, D6, and D7**
2. Identify why the JOIN returns 0 rows
3. Fix the JOIN/query logic
4. Confirm the true count of "impossible" records
5. Document the final Phase 4 findings

---

# Current Analysis Status

The project has completed the initial database, water-source, and queue investigations.

The current evidence shows:

* **39,650** unique water sources
* **27,628,140** people served across the five source types
* **105** extreme queue visits
* **105** distinct sources affected by those extreme queues
* **100%** of extreme queues occurred at shared taps
* **60,146** water-quality records
* **10,942** records with a perfect quality score of 10

Phase 4 remains open until the JOIN issue is resolved and the final water-quality findings are confirmed.
