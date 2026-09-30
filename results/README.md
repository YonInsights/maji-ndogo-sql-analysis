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

| Phase   | Topic                       | Status      |
| ------- | --------------------------- | ----------- |
| Phase 1 | Database Exploration        | ✅ Complete |
| Phase 2 | Water Source Exploration    | ✅ Complete |
| Phase 3 | Long Queue Investigation    | ✅ Complete |
| Phase 4 | Water Quality Investigation | ✅ Complete |
| Phase 5 | Well Pollution Analysis     | ✅ Complete |
| Phase 6 | Safe Data Cleaning          | ✅ Complete |
| Phase 7 | Post-Cleaning Validation    | ✅ Complete |

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

# Phase 4: Investigating Water Quality & Survey Integrity

**Status:** ✅ **COMPLETE**  
**Script:** `sql/04_water_quality.sql`

## Objective

Investigate water quality ratings, examine data collection integrity, and verify whether surveyors followed protocol regarding home tap inspections.

## Survey Protocol Context
- Quality scores range from 1 (terrible) to 10 (clean, private home tap).
- Surveyors were instructed to visit home taps (`score = 10`) **only once** (`visit_count = 1`).
- Re-visits (`visit_count = 2`) were strictly reserved for public shared taps to monitor queue times.

## SQL Analysis Performed

```sql
SELECT COUNT(*) AS suspicious_quality_records
FROM water_quality
WHERE subjective_quality_score = 10
  AND visit_count = 2;
```

## Findings

| Metric | Value | Meaning |
| :--- | ---: | :--- |
| **Total `water_quality` records** | **60,146** | Full survey evaluation records |
| **Records with score = 10** | **10,942** | High-quality private/home tap ratings |
| **Impossible combinations (score = 10 & visit_count = 2)** | **218** | Direct survey protocol violation |

### Key Insight: The Auditor Mandate
- Because both `subjective_quality_score` and `visit_count` reside directly within `water_quality`, querying these two columns directly reveals **exactly 218 suspicious records** without requiring an external JOIN.
- Finding 218 duplicate visits to perfect home taps points to either surveyor data-entry errors or falsified visit logs.
- **Actionable Decision:** Appoint an independent Auditor to cross-reference these 218 logs against field staff records.

---

# Phase 5: Well Pollution Investigation

**Status:** ✅ **COMPLETE**  
**Script:** `sql/05_pollution_analysis.sql`

## Objective

Examine laboratory test results for underground wells, check for dangerous biological/chemical contamination, and detect inconsistencies between laboratory metrics and text classifications.

## Safety Standards
- `biological = 0`: Safe drinking water.
- `biological > 0.01`: Contaminated with pathogenic bacteria (*E. coli*, *Giardia Lamblia*). High risk of waterborne illness.

## SQL Analysis Performed
1. Filtered for false-clean wells: `WHERE results = 'Clean' AND biological > 0.01`
2. Pattern matching for description typos: `WHERE description LIKE 'Clean_%'`

## Findings

| Metric | Count | Observation |
| :--- | ---: | :--- |
| **Contaminated wells marked 'Clean'** | **40** | Lab results show live bacteria, but result column is stamped 'Clean' |
| **Descriptions with 'Clean ' typo** | **38** | Typo text: `Clean Bacteria: E. coli` and `Clean Bacteria: Giardia Lamblia` |

### Root Cause Analysis
Data entry personnel mistakenly prepended `"Clean "` to bacterial descriptions from scientist field notes. Subsequent personnel evaluated only the first word ("Clean") of the description rather than laboratory PPM/CFU values, incorrectly stamping the entire water source as safe to drink.

---

# Phase 6: Safe Data Cleaning Pipeline

**Status:** ✅ **COMPLETE**  
**Script:** `sql/06_data_cleaning.sql`

## Objective

Safely correct erroneous pollution descriptions and results without risking data loss or corruption on the live database.

## Industry Best-Practice Protocol
1. **Sandbox Creation:** Create `well_pollution_copy` using `CREATE TABLE ... AS (SELECT * FROM ...)`.
2. **Staging Updates:** Apply corrections to `well_pollution_copy`.
3. **Verification:** Query `well_pollution_copy` to confirm 0 errors remain.
4. **Production Application:** Execute verified updates on live `well_pollution` table.
5. **Clean Up:** Drop temporary sandbox copy `well_pollution_copy`.

## SQL Corrections Applied

```sql
-- Typo Correction 1: E. coli
UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

-- Typo Correction 2: Giardia Lamblia
UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Result Reclassification: Contaminated Wells
UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
  AND results = 'Clean';
```

---

# Phase 7: Post-Cleaning Validation & Quality Assurance

**Status:** ✅ **COMPLETE**  
**Script:** `sql/07_validation.sql`

## Objective

Independently verify that 100% of data errors have been eliminated and produce validated summary statistics for leadership.

## Verification Query

```sql
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);
```
**Result: 0 rows returned.** (Clean pass).

---

# Final Part 1 Project Summary

| Focus Area | Core Finding | Strategic Impact |
| :--- | :--- | :--- |
| **Water Infrastructure** | Shared taps serve 11.9M citizens across only 5,767 taps (~2,071 people per tap). | Explains severe community bottlenecks and 8+ hour queues. |
| **Queue Crisis** | 100% of queues > 500 min (average 8.7 hrs) occurred exclusively at shared taps. | Direct priority to expand shared tap density and home piping. |
| **Data Integrity** | 218 impossible survey logs identified (`score = 10` & `visit_count = 2`). | Justifies an independent internal audit of surveyor records. |
| **Public Health** | 40 biologically contaminated wells were falsely classified as Clean. | Prevented public health crisis by correctly reclassifying contaminated wells. |
