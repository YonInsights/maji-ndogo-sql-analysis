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
| Phase 8 | Employee Data Standardization | ✅ Complete |
| Phase 9 | Honouring Field Workers     | ✅ Complete |
| Phase 10 | Location & Rural Analysis   | ✅ Complete |
| Phase 11 | Population Impact & Percentages | ✅ Complete |
| Phase 12 | Priority Ranking (Window Functions) | ✅ Complete |
| Phase 13 | Queue Pivot Table Analysis  | ✅ Complete |
| Phase 14 | Auditor Report Integration & Score Verification | ✅ Complete |
| Phase 15 | Corruption Probe & Bribery Statement Analysis | ✅ Complete |

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

---

# Phase 8: Employee Data Standardization

**Status:** ✅ **COMPLETE**  
**Script:** `sql/08_employee_data_cleaning.sql`

## Objectives & Solutions
1. **Corporate Email Generation:** Built standard government emails (`first.last@ndogowater.gov`) using `CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov')`.
2. **Phone Number Trimming:** Fixed 13-character phone numbers by trimming hidden trailing spaces with `TRIM(phone_number)`, restoring valid 12-character format for automated SMS dispatch.

---

# Phase 9: Honouring Field Workers

**Status:** ✅ **COMPLETE**  
**Script:** `sql/09_honouring_workers.sql`

## Key Findings
- **Workforce Geography:** 29 out of our workforce live in `Rural` communities, placing surveyors close to the frontline.
- **Top 3 Field Surveyors:**
  1. **Bello Azibo** (`assigned_employee_id = 1`): **3,708 visits**
  2. **Pili Zola** (`assigned_employee_id = 30`): **3,676 visits**
  3. **Rudo Imani** (`assigned_employee_id = 34`): **3,539 visits**

---

# Phase 10: Geographic Location Analysis

**Status:** ✅ **COMPLETE**  
**Script:** `sql/10_location_analysis.sql`

## Geographic Distribution
- **Rural Water Sources:** **23,740 sources (60%)**
- **Urban Water Sources:** **15,910 sources (40%)**

### Strategic Insight
With 60% of water points located in remote rural communities, engineering logistics, supply chains, and drilling equipment must be structured for rural deployment where infrastructure access is toughest.

---

# Phase 11: Water Source Breakdown & Population Proportions

**Status:** ✅ **COMPLETE**  
**Script:** `sql/11_water_source_breakdown.sql`

## National Population Statistics
- **Total Population Surveyed:** **27,628,140 citizens** (~27.6 million).

| Water Source Type | Number of Sources | Population Served | % of Population | Avg People / Source |
| :--- | ---: | ---: | ---: | ---: |
| **`shared_tap`** | 5,767 | 11,945,272 | **43%** | **~2,071** |
| **`well`** | 17,383 | 4,841,724 | **18%** | ~278 |
| **`tap_in_home`** | 7,265 | 4,678,880 | **17%** | ~644 (~100 homes) |
| **`tap_in_home_broken`** | 5,856 | 3,799,720 | **14%** | ~649 (~100 homes) |
| **`river`** | 3,379 | 2,362,544 | **9%** | ~699 |

### Critical Takeaways
1. **The Piped Infrastructure Deficit:** 31% of the population has home piping installed, but **45% (3.8M people) have broken connections**. Repairing municipal pumps and pipes restores water immediately.
2. **The Shared Tap Dependency:** 43% rely on shared taps, causing systemic queue congestion.

---

# Phase 12: Priority Ranking Using Window Functions

**Status:** ✅ **COMPLETE**  
**Script:** `sql/12_priority_ranking.sql`

## Technical Methodology
- Excluded functional `tap_in_home` to focus strictly on improvable sources.
- Applied `RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC)` to generate ranked repair queues.
- Demonstrated differences between `RANK()` (gap ranks), `DENSE_RANK()` (consecutive ranks), and `ROW_NUMBER()` (unique sequential dispatch).

---

# Phase 13: Queue Time Analysis & Executive SQL Pivot Table

**Status:** ✅ **COMPLETE**  
**Script:** `sql/13_queue_pivot_analysis.sql`

## Findings
- **Survey Duration:** **924 days** (~2.5 years of continuous field operations).
- **True Average Queue Time:** **123 minutes (~2.0 hours)** when excluding instant-access home taps via `NULLIF(time_in_queue, 0)`.
- **Weekly Queue Heatmap:**
  - **Saturday:** **246 minutes (>4.1 hours)** nationwide average wait time.
  - **Monday:** **137 minutes** (rush to replenish after weekend).
  - **Sunday:** **82 minutes** (lowest wait time; family & religious observance).

## Executive Hourly Pivot Heatmap

```text
Hour    Sun   Mon   Tue   Wed   Thu   Fri   Sat
06:00    79   190   134   112   134   153   247
07:00    82   186   128   111   139   156   247
08:00    86   183   130   119   129   153   247
09:00    84   127   105    94    99   107   252
10:00    83   119    99    89    95   112   259
11:00    78   115   102    86    99   104   236
12:00    78   115    97    88    96   109   239
13:00    81   122    97    98   101   115   242
14:00    83   127   104    92    96   110   244
15:00    83   126   104    88    92   110   248
16:00    83   127    99    90    99   109   251
17:00    79   181   135   121   129   151   251
18:00    80   174   122   113   132   158   240
19:00   127   159   145   176   137   103   282
```

---

# Strategic Solutions for President Naledi

1. **Shared Taps (UN 30-Minute Standard):**
   - Immediate dispatch of mobile water tankers on **Saturdays** and **weekday rush hours (06:00-08:00, 17:00-19:00)** based on our Pivot Table.
   - Install additional shared taps in high-density areas to bring queue times below the UN threshold of 30 minutes.
2. **Broken Home Taps (High ROI Intervention):**
   - Repair central treatment facilities, reservoirs, and primary pipe mains to immediately restore access for 3.8M citizens.
3. **Wells Purification:**
   - Install UV filters on biologically contaminated wells to kill bacteria and parasites.
   - Install reverse osmosis on chemically polluted wells.
4. **Rivers:**
   - Temporary tanker supply while drilling permanent deep community boreholes.

---

# Phase 14: Integrating the Auditor's Report & Score Verification

**Status:** ✅ **COMPLETE**  
**Script:** `sql/14_auditor_comparison.sql`

## Objective

Integrate the independent audit data collected by Chief Auditor Tendai Mubarak (1,620 re-visited water sources) and compare auditor quality scores against the internal survey scores.

## Technical Methodology
- Joined `auditor_report`, `visits`, and `water_quality` using a 3-table join (`auditor_report.location_id = visits.location_id` and `visits.record_id = water_quality.record_id`).
- Filtered `visits.visit_count = 1` to eliminate duplicate re-visits and isolate baseline assessments.

## Findings

| Metric | Count | Proportion | Interpretation |
| :--- | ---: | ---: | :--- |
| **Total Audited Sites** | **1,620** | 100% | Independent ground sample |
| **Matching Scores** | **1,518** | **93.7% (~94%)** | Survey data verified accurate and honest |
| **Mismatched / Tampered Scores** | **102** | **6.3%** | Falsified records requiring investigation |

### Key Finding
- In 102 instances, field surveyors recorded perfect scores of **`10`**, whereas the independent auditor tested the water and recorded true scores of **`0`, `1`, `2`, or `3`**.
- Cross-referencing `type_of_water_source` revealed that source types were **not changed**. Only subjective quality ratings were falsified.

---

# Phase 15: Uncovering Data Tampering & The Corruption Probe

**Status:** ✅ **COMPLETE**  
**Script:** `sql/15_investigating_corruption.sql`

## Objective

Identify the specific field workers responsible for the 102 falsified records, evaluate whether errors were random or systematic, and cross-reference records with citizen interview statements.

## Technical Workflow
1. **Created VIEW `Incorrect_records`:** Centralized 4-table join including citizen statements.
2. **Error Aggregation:** Grouped mistakes by `employee_name`.
3. **Dynamic CTE Filtering (`suspect_list`):** Isolated employees exceeding the cohort average (~6 mistakes).
4. **Statement Pattern Matching:** Queried citizen statements for allegations of cash bribery.

## Suspect Identification Breakdown

| Rank | Employee Name | Number of Tampered Records | Status |
| :---: | :--- | ---: | :--- |
| 1 | **Bello Azibo** | **26** | **Primary Suspect** |
| 2 | **Malachi Mavuso** | **21** | **Primary Suspect** |
| 3 | **Zuriel Matembo** | **17** | **Primary Suspect** |
| 4 | **Lalitha Kaburi** | **7** | **Primary Suspect** |
| 5-17 | 13 Other Surveyors | 1 – 5 each (Total: 31) | Expected Human Error Range |

## Bribery & Evidence Findings
- Filtering citizen statements with `statements LIKE '%cash%'` revealed multiple eyewitness accounts of officials accepting cash bribes to log favorable scores.
- **Integrity Check:** Querying for cash allegations among employees **NOT** in the suspect list returned **0 rows (Empty Set)**.
- **Conclusion:** Allegations of bribery are confined strictly and exclusively to the **4 identified suspects** (Bello Azibo, Malachi Mavuso, Zuriel Matembo, and Lalitha Kaburi). Evidence has been compiled for President Naledi's anti-corruption commission.

---

# Phase 16: Assembling the Unified Data View

**Status:** ✅ **COMPLETE**  
**Script:** `sql/16_combined_analysis_table.sql`

## Objective
Unify disparate database tables (`visits`, `location`, `water_source`, and `well_pollution`) into a single consolidated analytical view (`combined_analysis_table`) to facilitate provincial, municipal, and engineering dispatch calculations.

## Technical Methodology
- **Anchor Table:** Queried from `visits` to preserve relational connections.
- **Relational Joins:** Inner-joined `location` on `location_id` and `water_source` on `source_id`.
- **Preserving Non-Well Sources:** Executed a `LEFT JOIN` on `well_pollution`. An `INNER JOIN` would have discarded 57% of sources (shared taps, home taps, rivers) because only wells undergo chemical/biological pollution lab tests.
- **Deduplication:** Filtered `visits.visit_count = 1` to ensure multi-visit survey records (e.g. `AkHa00103` visited 8 times) do not distort population calculations.
- **Virtual View:** Created `CREATE OR REPLACE VIEW combined_analysis_table AS ...` to provide a modular foundation for subsequent analyses.

---

# Phase 17: Provincial & Municipal Infrastructure Pivots

**Status:** ✅ **COMPLETE**  
**Script:** `sql/17_provincial_and_town_pivots.sql`

## Objective
Identify specific provinces and municipalities suffering from acute infrastructure vulnerabilities by aggregating population shares using dynamic SQL Pivot Tables and temporary tables.

## 1. Provincial Infrastructure Distribution

Using CTE `province_totals` joined to `combined_analysis_table`:

| Province | River (%) | Shared Tap (%) | Tap in Home (%) | Tap in Home Broken (%) | Well (%) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Akatsi** | 3% | 46% | 14% | 12% | 25% |
| **Amanzi** | 3% | 38% | 28% | 28% | 3% |
| **Hawassa** | 4% | 42% | 15% | 15% | 24% |
| **Kilimani** | 12% | 48% | 13% | 12% | 15% |
| **Sokoto** | **21%** | 39% | 16% | 10% | 14% |

### Strategic Provincial Takeaways:
1. **The Sokoto River Crisis:** **21% of Sokoto's population** drinks from raw rivers. Well-drilling rigs must be dispatched to Sokoto first.
2. **The Amanzi Piped System Breakdown:** In Amanzi, **half of all piped home taps are broken** (28% broken vs 28% functional). Fixing central infrastructure here restores running water to hundreds of thousands immediately.

## 2. Municipal (Town) Aggregated Water Access

To overcome duplicate town names across provinces (e.g., `Harare` in Akatsi vs Kilimani, `Amina` in Amanzi vs Hawassa), we grouped and joined on the composite key `(province_name, town_name)` and materialized a `TEMPORARY TABLE town_aggregated_water_access`.

### Acute Municipal Disparities:
Filtering by infrastructure failure ratio:
$$\text{Pct\_broken\_taps} = \frac{\text{tap\_in\_home\_broken}}{\text{tap\_in\_home\_broken} + \text{tap\_in\_home}} \times 100$$

* **Amina (Amanzi):** **95% Failure Rate** (56% broken vs 3% functional taps). Infrastructure was installed but completely neglected.
* **Dahabu (Amanzi - Capital):** **98% Functioning Rate** (55% functional vs 1% broken taps). Demonstrates severe historical resource allocation bias toward the political center.

---

# Phase 18: Engineering Action Plan & Implementation

**Status:** ✅ **COMPLETE**  
**Script:** `sql/18_project_progress_action_plan.sql`

## Objective
Translate all analytical findings into a concrete, operational database table (`Project_progress`) with prescriptive engineering improvements and lifecycle tracking for field crews.

## Action Plan Formulation Rules

| Water Source Type | Condition | Assigned Engineering Improvement |
| :--- | :--- | :--- |
| **`river`** | All rivers | **`Drill well`** |
| **`well`** | `Contaminated: Chemical` | **`Install RO filter`** (Reverse Osmosis) |
| **`well`** | `Contaminated: Biological` | **`Install UV and RO filter`** (Ultraviolet + RO) |
| **`shared_tap`** | Queue $\ge 30\text{ min}$ | **`Install X taps nearby`** where $X = \lfloor\frac{\text{time\_in\_queue}}{30}\rfloor$ |
| **`tap_in_home_broken`** | All broken taps | **`Diagnose local infrastructure`** |
| **Clean Wells / Short Queues** | Queue $< 30\text{ min}$ / Clean Wells | Excluded from backlog (no immediate action needed) |

## Implementation Results

- **Table DDL:** Created `Project_progress` with `SERIAL PRIMARY KEY`, foreign keys to `water_source`, and `CHECK (Source_status IN ('Backlog', 'In progress', 'Complete'))`.
- **Target Population:** Exactly **25,398 water sources** require immediate engineering intervention.
- **Data Integrity:** **0 NULL values** in the `Improvement` column after inserting the filtered cohort.

### Final Engineering Backlog Breakdown

| Rank | Improvement Intervention | Total Sites | % of Backlog | Strategic Impact |
| :---: | :--- | ---: | ---: | :--- |
| 1 | **Install UV and RO filter** | **11,894** | **46.8%** | Eradicates pathogenic bacteria in contaminated wells |
| 2 | **Diagnose local infrastructure** | **5,856** | **23.1%** | Restores running water to 3.8M citizens with home piping |
| 3 | **Install X taps nearby** | **3,388** | **13.3%** | Relieves queue congestion down to the UN 30-min standard |
| 4 | **Drill well** | **3,379** | **13.3%** | Replaces untreated river water with clean underground wells |
| 5 | **Install RO filter** | **881** | **3.5%** | Purifies chemical toxins and heavy metals in wells |
| **Total** | **All Actionable Projects** | **25,398** | **100.0%** | Full nationwide coverage for President Naledi |

