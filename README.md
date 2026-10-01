# Maji Ndogo SQL Analysis

> Exploring water access, service challenges, data quality, and pollution using SQL.

[![SQL](https://img.shields.io/badge/SQL-MySQL-blue)](https://www.mysql.com/)
[![Data Analysis](https://img.shields.io/badge/Focus-Data%20Analysis-orange)](#project-overview)
[![ALX](https://img.shields.io/badge/Program-ALX%20Data%20Science-red)](#learning-context)

---

## Project Overview

Maji Ndogo is a real-world data analysis project from the ALX Data Science learning journey.

The project uses a relational database containing approximately 60,000 records collected from water-related surveys.

The objective is to investigate the data using SQL and understand what it tells us about:

* Water sources
* Water access
* Queue times
* Water quality
* Biological contamination
* Chemical pollution
* Data-quality problems

This project is not just about writing SQL queries.

It follows a complete analytical process:

```text
Problem
   ↓
Understand the Data
   ↓
Explore the Database
   ↓
Ask Questions
   ↓
Investigate
   ↓
Find Patterns
   ↓
Detect Data Quality Issues
   ↓
Clean the Data
   ↓
Validate the Solution
```

---

## The Problem

Imagine being given thousands of water-service records collected across Maji Ndogo.

You are told:

> "Use the data to help us understand the water situation."

The problem is not immediately knowing which SQL query to write.

The real challenge is to determine:

* What information is available?
* What does each table represent?
* How are the tables connected?
* Which water sources create access problems?
* Where are people experiencing long queues?
* Is the water quality information reliable?
* Are there inconsistencies in the pollution data?
* How can incorrect records be corrected without damaging the database?

This project approaches the problem as a data analyst rather than simply as a SQL exercise.

---

# Project Goals

The analysis is structured across 18 distinct analytical phases spanning four parts:

### Part 1: Exploration, Anomaly Detection & Safe Data Cleaning
1. **Understand the Database:** Explore available tables, columns, schema structure, and relationships.
2. **Explore Water Sources:** Categorize source types and measure communities served.
3. **Investigate Access Bottlenecks:** Analyze survey visits to discover extreme wait times (>8 hours).
4. **Audit Water Quality Data:** Detect survey protocol anomalies (e.g. 218 duplicate home visits).
5. **Investigate Well Pollution:** Detect false-clean labels and biological/chemical contamination conflicts.
6. **Safe Data Cleaning:** Build isolated sandbox copy table and apply targeted corrections.
7. **Validation:** Re-run error queries to prove zero data-quality defects remain.

### Part 2: Advanced Aggregation, Window Functions & Temporal Analysis
8. **Standardize Employee Records:** Synthesize corporate email addresses and trim malformed phone numbers.
9. **Evaluate Workforce Performance:** Map employee geographic distribution and honour top field surveyors.
10. **Analyze Geographic Distribution:** Evaluate provincial and municipal source density (60% rural breakdown).
11. **Assess National Population Impact:** Calculate exact population shares and infrastructure failure rates (45% broken home taps).
12. **Formulate Data-Driven Priority Queues:** Use SQL Window Functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`) to rank repair targets.
13. **Analyze Temporal Queue Patterns:** Construct an executive SQL Pivot Table breaking down wait times by hour across all 7 days.

### Part 3: Auditor Verification & Corruption Investigation
14. **Audit Data Integration & Score Comparison:** Join independent audit records (`auditor_report`, `visits`, `water_quality`) and isolate 102 tampered quality scores.
15. **Corruption Probe & Bribery Statement Analysis:** Create persistent VIEW (`Incorrect_records`), isolate suspect employees via CTEs, and analyze citizen statements citing `"cash"` bribery.

### Part 4: Integrated Provincial Analysis & Engineering Action Plan
16. **Assembling the Unified Data View:** Connect 4 tables via `LEFT JOIN` and construct the `combined_analysis_table` VIEW.
17. **Provincial & Municipal Infrastructure Pivots:** Aggregate population access shares, resolve cross-provincial town naming duplicates, and expose rural disparities.
18. **Operational Engineering Action Plan:** Architect the `Project_progress` table, filter the 25,398 project backlog, and map prescriptive engineering solutions.

---

# Dataset

The database contains several related tables:

```text
data_dictionary
employee
global_water_access
location
water_quality
visits
water_source
well_pollution
auditor_report
Project_progress
```

Each table represents a different part of the water-services system.

The tables can be connected through identifiers such as:

```text
location_id
source_id
employee_id
```

A simplified relationship looks like this:

```text
                 ┌──────────────┐
                 │   location   │
                 └──────┬───────┘
                        │
                   location_id
                        │
                        ▼
                 ┌──────────────┐
                 │    visits    │
                 └──────┬───────┘
                        │
                    source_id
                        │
                        ▼
                 ┌──────────────┐
                 │ water_source │
                 └──────┬───────┘
                        │
                    source_id
                        │
                        ▼
                 ┌──────────────┐
                 │well_pollution│
                 └──────────────┘
```

Understanding these relationships is essential because useful insights often require information from multiple tables.

---

# Analytical Approach

The project is divided into stages.

Each phase follows a consistent analytical framework:

```text
Problem
   ↓
Expected Solution
   ↓
Implementation Strategy
```

This makes the investigation reproducible, logical, and easy to review.

---

## Phase 1: Database Exploration

### The Problem

We are handed a relational database with over 60,000 records across multiple tables, but we do not yet know the schema, primary/foreign key connections, or what information each table holds.

### The Expected Solution

A complete structural map of the database, understanding what each table represents, and identifying foreign key relationships such as how `visits` links to `location` and `water_source`.

### Implementation Strategy

Run structural database queries like `SHOW TABLES;` to list everything, then use limited `SELECT` statements to inspect column names, data types, and values.

Example:

```sql
SHOW TABLES;
```

Then I inspect individual tables:

```sql
SELECT *
FROM location
LIMIT 5;
```

The purpose is to understand:

* What tables exist?
* What columns are available?
* What does each row represent?
* Which columns identify records?
* Which tables are related?

---

## Phase 2: Water Source Exploration

### The Problem

Communities in Maji Ndogo obtain water from diverse infrastructure categories, but raw records do not immediately summarize these types or their community footprint.

### The Expected Solution

A clear inventory of all unique water source types and an understanding of how they function, their infrastructure risks, and their scale of impact.

### Implementation Strategy

Query the `water_source` table using distinct grouping to categorize every type of infrastructure and map its characteristics.

The `water_source` table contains information about the different sources people use to obtain water.

The project identifies five main source types:

```text
tap_in_home
tap_in_home_broken
well
shared_tap
river
```

To identify the unique source types:

```sql
SELECT DISTINCT type_of_water_source
FROM water_source;
```

This is one of the first examples of turning raw database records into an understandable picture of the situation.

---

## Phase 3: Investigating Long Queues

### The Problem

Water access is bottlenecked by severe waiting times, with some records showing extreme queue times exceeding 500 minutes, which is over 8 hours. We need to know where and why this happens.

### The Expected Solution

Identifying the specific types of water sources and locations responsible for these extreme access bottlenecks so leadership can target infrastructure upgrades.

### Implementation Strategy

Filter the `visits` table using threshold conditions, then use relational joins to connect records back to the `water_source` table via `source_id`.

One of the questions explored is:

> Which water sources are associated with extremely long waiting times?

The `visits` table contains a `time_in_queue` field.

I investigate unusually large values using:

```sql
SELECT *
FROM visits
WHERE time_in_queue > 500;
```

This identifies records where people waited more than 500 minutes.

Some records show queue times of more than eight hours.

The next question is more important:

> What type of water source is associated with these long queues?

This requires connecting the `visits` table with the `water_source` table using `source_id`.

This changes the analysis from:

```text
"We found long queues."
```

to:

```text
"We found long queues at specific types of water sources."
```

That second question provides much more useful information.

---

## Phase 4: Investigating Water Quality

### The Problem

Field surveyors assigned subjective quality scores ranging from 1 to 10, but real-world data collection is prone to human error, meaning we cannot blindly trust that every recorded score or second-visit pattern is correct.

### The Expected Solution

Testing the logical integrity of the data, for example verifying whether high-quality scores appear unexpectedly where they should not, such as second visits to home taps that should not require multiple visits.

### Implementation Strategy

Write structured conditional queries combining score filters, source type constraints, and visit count metrics to flag logical anomalies.

The project also investigates the `water_quality` table.

Water quality scores range from:

```text
1 → Poor quality
10 → Good quality
```

The analysis does not assume that every record is correct.

Instead, it checks whether the records make sense according to the survey process.

This leads to another important data-science principle:

> Data should be validated, not blindly trusted.

---

## Phase 5: Investigating Pollution

### The Problem

A critical data-quality breakdown exists in the `well_pollution` table. Due to data-entry personnel misinterpreting scientist text notes, such as descriptions beginning with `"Clean Bacteria: E. coli"`, wells with dangerous biological contamination levels where `biological > 0.01` CFU/mL have been incorrectly classified as `Clean` in the `results` column.

### The Expected Solution

Clean, trustworthy pollution records where text descriptions are standardized and contamination statuses accurately reflect actual laboratory measurements, ensuring public safety.

### Implementation Strategy

1. Identify erroneous records using string pattern matching and logical operators.
2. Isolate changes safely by creating a temporary copy table.
3. Execute targeted `UPDATE` statements to fix descriptions and correct misclassifications.
4. Validate results by re-running checking queries on the copy table before updating production data.

The `well_pollution` table contains information about contamination.

Important fields include:

```text
source_id
date
description
pollutant_ppm
biological
results
```

The `biological` field measures biological contamination.

The project uses:

```text
biological > 0.01
```

as the condition indicating biological contamination.

This creates an opportunity to compare the numerical measurement with the text classification.

---

# The Data Quality Problem

During the investigation, an important inconsistency appears.

Some records contain:

```text
biological > 0.01
```

but are classified as:

```text
results = "Clean"
```

For example:

```text
biological = 35.0068
results = Clean
```

The measurement and classification disagree.

This is a classic data-quality problem.

---

# Incorrect Descriptions

Another issue appears in the `description` column.

Some records contain:

```text
Clean Bacteria: E. coli
```

or:

```text
Clean Bacteria: Giardia Lamblia
```

These descriptions contain contradictory information.

The project identifies 38 descriptions affected by this issue.

The intended corrections are:

```text
Clean Bacteria: E. coli
            ↓
Bacteria: E. coli
```

and:

```text
Clean Bacteria: Giardia Lamblia
            ↓
Bacteria: Giardia Lamblia
```

---

# Data Cleaning Strategy

Changing a database directly can be dangerous.

Instead of immediately modifying the original table, I create a copy for testing:

```sql
CREATE TABLE md_water_services.well_pollution_copy AS
(
    SELECT *
    FROM md_water_services.well_pollution
);
```

The cleaning process becomes:

```text
Original Data
     │
     ▼
Create Test Copy
     │
     ▼
Apply Corrections
     │
     ▼
Run Validation Queries
     │
     ▼
Confirm Results
```

This allows the cleaning logic to be tested without immediately changing the original dataset.

---

# Data Cleaning

## Correction 1: E. coli descriptions

```sql
UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';
```

## Correction 2: Giardia descriptions

```sql
UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';
```

## Correction 3: Incorrect biological classifications

```sql
UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
  AND results = 'Clean';
```

The third query is important because it uses the actual biological measurement to identify records that conflict with the existing classification.

---

# Validation

After making changes, I do not assume that the problem has been solved.

I run another query to search for the same errors:

```sql
SELECT *
FROM well_pollution_copy
WHERE description LIKE 'Clean\_%'
   OR (results = 'Clean' AND biological > 0.01);
```

The purpose is simple:

> Find any remaining records that still violate the conditions we identified.

This creates a complete cleaning workflow:

```text
Identify
   ↓
Investigate
   ↓
Correct
   ↓
Validate
```

---

# SQL Skills Demonstrated

This project demonstrates practical use of:

| SQL Category | Functions / Keywords | Practical Application in Project |
| :--- | :--- | :--- |
| **Data Retrieval & Filtering** | `SELECT`, `FROM`, `WHERE`, `DISTINCT`, `LIMIT` | Exploring tables, sampling records, and filtering anomalous conditions |
| **Relational Connections** | `JOIN`, `ON`, Foreign Keys | Linking visits to water sources and employees |
| **Aggregation & Grouping** | `COUNT()`, `SUM()`, `AVG()`, `ROUND()`, `GROUP BY`, `ORDER BY` | Sizing population impact, municipal source density, and queue metrics |
| **String Operations** | `LOWER()`, `REPLACE()`, `CONCAT()`, `TRIM()`, `LENGTH()`, `LIKE` | Synthesizing employee corporate emails and stripping corrupt trailing phone spaces |
| **Date & Time Manipulation** | `DATEDIFF()`, `DAYNAME()`, `TIME_FORMAT()`, `TIME()` | Measuring survey duration (924 days) and identifying Saturday queue peaks |
| **Window Functions** | `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `OVER (PARTITION BY ...)` | Multi-level engineering priority rankings by water source type |
| **Conditional Logic & Pivoting** | `CASE WHEN ... THEN ... ELSE NULL END`, `NULLIF()`, `IF()` | Building an executive hourly Pivot Table across all 7 days of the week |
| **Data Cleaning & DDL** | `CREATE TABLE ... AS`, `DROP TABLE`, `UPDATE ... SET` | Creating isolated sandbox backup tables to test updates safely |
| **Database Views** | `CREATE VIEW ... AS` | Centralizing multi-table audit joins into reusable virtual tables (`Incorrect_records`, `combined_analysis_table`) |
| **Common Table Expressions (CTEs)** | `WITH ... AS (...)` | Constructing modular query pipelines to isolate suspect surveyors and calculate provincial totals |
| **Temporary Tables** | `CREATE TEMPORARY TABLE ...` | Materializing complex multi-key municipal aggregations (`town_aggregated_water_access`) for fast analysis |
| **Prescriptive Logic & Math** | `CASE WHEN ...`, `CONCAT()`, `FLOOR()` | Generating dynamic engineering improvements and calculating required relief taps ($\lfloor\text{queue}/30\rfloor$) |

---

# Data Analysis Skills Demonstrated

Beyond SQL syntax, this project demonstrates:

* Problem definition
* Database exploration
* Relational data understanding
* Data investigation
* Pattern identification
* Data-quality validation
* Data cleaning
* Safe database modification
* Result verification
* Analytical reasoning
* Technical documentation

---

# Project Workflow

The complete project workflow is:

```text
                    MAJI NDOGO
                        │
                        ▼
                Understand Problem
                        │
                        ▼
                Explore Database
                        │
                        ▼
               Understand Tables
                        │
                        ▼
                 Explore Sources
                        │
                        ▼
               Investigate Visits
                        │
                        ▼
             Investigate Water Quality
                        │
                        ▼
               Investigate Pollution
                        │
                        ▼
             Identify Data Problems
                        │
                        ▼
               Create Safe Copy
                        │
                        ▼
                 Clean the Data
                        │
                        ▼
                 Validate Results
                        │
                        ▼
                Document Findings
```

---

# Repository Structure

The repository is organized to separate exploration, analysis, cleaning, and validation.

```text
maji-ndogo-sql-analysis/
│
├── README.md
│
├── sql/
│   ├── README.md
│   ├── 01_database_exploration.sql
│   ├── 02_water_sources.sql
│   ├── 03_water_source_visits.sql
│   ├── 04_water_quality.sql
│   ├── 05_pollution_analysis.sql
│   ├── 06_data_cleaning.sql
│   ├── 07_validation.sql
│   ├── 08_employee_data_cleaning.sql
│   ├── 09_honouring_workers.sql
│   ├── 10_location_analysis.sql
│   ├── 11_water_source_breakdown.sql
│   ├── 12_priority_ranking.sql
│   ├── 13_queue_pivot_analysis.sql
│   ├── 14_auditor_comparison.sql
│   ├── 15_investigating_corruption.sql
│   ├── 16_combined_analysis_table.sql
│   ├── 17_provincial_and_town_pivots.sql
│   └── 18_project_progress_action_plan.sql
│
├── data/
│   ├── README.md
│   ├── Auditor_report.csv
│   └── md_water_services.sql
│
├── results/
│   └── README.md
│
└── docs/
    └── analysis_notes.md
```

As the project develops, additional folders can be added for:

```text
visualizations/
notebooks/
reports/
```

Only when they are actually needed.

---

# Tools & Technologies

### Database

* MySQL

### Query Language

* SQL

### Development & Collaboration Tools

* MySQL Workbench
* Git
* GitHub
* **AI Agentic Assistant (DeepMind Antigravity)** — utilized for interactive pair programming, technical query optimization, test-driven validation, and documentation generation.

### Learning Context

* ALX Data Science (in partnership with ExploreAI)

---

# Key Questions

The project is driven by questions rather than by SQL commands.

### Water Access

* What types of water sources exist?
* How many people depend on each source?
* Which sources serve large communities?

### Water Services

* Which sources have long queues?
* What type of source is associated with long waiting times?
* How can these patterns help us understand access problems?

### Water Quality

* What does the water-quality data tell us?
* Are there records that do not make sense?
* Can different fields be compared to validate the data?

### Data Quality

* Are pollution descriptions consistent?
* Are biological measurements consistent with their classifications?
* Can the incorrect records be identified programmatically?

### Data Cleaning

* How can the errors be corrected?
* How can the changes be tested safely?
* How can we verify that the errors were removed?

---

# Key Lessons

### Data tells a story

Thousands of database records can look meaningless until you start asking specific questions.

### SQL is a thinking tool

SQL is not just about syntax.

It helps turn questions into evidence.

### Data can be wrong

A database can contain contradictory values, incorrect classifications, and data-entry errors.

### Numbers can validate text

A numerical measurement can be used to check whether a text classification makes sense.

### Safe data modification matters

Before changing important data, test the logic on a copy.

### Validation is part of cleaning

Cleaning is not finished when an `UPDATE` statement runs.

It is finished when the result has been checked.

---

# What I Learned

This project helped me move from simply writing SQL queries toward thinking like a data analyst.

The most important workflow I learned was:

```text
Question
   ↓
Explore
   ↓
Investigate
   ↓
Find Evidence
   ↓
Solve
   ↓
Validate
```

The project also showed me why understanding the business problem is just as important as knowing SQL syntax.

---

# Future Improvements

As the project develops, I plan to extend the analysis with:

* More detailed SQL analysis
* Additional data-quality checks
* Aggregated statistics
* Visualizations
* Deeper investigation of water access patterns
* More structured analytical reports
* Reproducible analysis workflows

---

# Learning Context & Acknowledgements

This project was developed as part of the **ALX Data Science Program** (in partnership with **ExploreAI**).

Special gratitude and appreciation to **ALX Africa** for delivering an exceptional, future-facing curriculum that aligns with modern industry standards. Rather than focusing merely on isolated SQL syntax, the course equips learners to confront complex, messy real-world scenarios—from uncovering corruption to planning nationwide infrastructure budgets—and encourages **AI-assisted problem solving**, reflecting how forward-thinking data scientists work in today's technology ecosystem.

```text
Understand Real-World Business Problem
                  ↓
       Relational Database Exploration
                  ↓
   Data Quality Auditing & Anomaly Detection
                  ↓
     Safe Sandbox Data Cleaning & Validation
                  ↓
    Advanced Aggregation & Window Functions
                  ↓
   Multi-Table Relational Joining & Views
                  ↓
   AI-Augmented Optimization & Documentation
                  ↓
 Operational Decision-Making & Engineering Action Plan
```

### AI-Augmented Data Science Methodology

This portfolio project was completed using an **AI pair programming workflow**:

* **Human Leadership & Domain Knowledge:** Defining analytical objectives, evaluating hypothesis validity, executing queries in MySQL Workbench, and making informed engineering and public-policy decisions.
* **AI Copilot & Technical Partnership:** Assisting with query optimization, test-driven validation scripts, automated cross-table verification, and publication-ready documentation.
* **Modern Industry Practice:** Demonstrating how combining human analytical judgment with the speed and rigor of AI tools produces robust, transparent, and reproducible data science deliverables.

---

# Author

**Yonatan Abrham**

Highway Engineer | Data Science Learner

Interested in:

* Data Analysis
* SQL
* Python
* Machine Learning
* Data Science
* Engineering Applications of Data

---

## Project Status

✅ **All 4 Parts Fully Completed (Phases 1 through 18)**

- **Part 1:** Database Exploration, Anomaly Detection & Safe Data Cleaning (`sql/01` - `07`)
- **Part 2:** Advanced Aggregation, Window Functions & Temporal Queue Analysis (`sql/08` - `13`)
- **Part 3:** Independent Auditor Verification & Corruption Investigation (`sql/14` - `15`)
- **Part 4:** Unified Data Integration, Provincial Pivots & Operational Action Plan (`sql/16` - `18`)
- **Detailed Findings:** Comprehensive results log documented in [`results/README.md`](results/README.md).
- **Executive Insights:** Strategic recommendations documented in [`docs/analysis_notes.md`](docs/analysis_notes.md).

---

## Final Project Goal

The final goal is to turn the Maji Ndogo dataset into a complete, well-documented data-analysis project that demonstrates both technical SQL ability and analytical thinking.

The final repository should allow a reviewer to understand:

```text
What was the problem?
        ↓
What data was available?
        ↓
How was the data investigated?
        ↓
What problems were discovered?
        ↓
How were they solved?
        ↓
How was the solution validated?
        ↓
What was learned?
```

---

## License

This repository was created for educational and portfolio purposes as part of my data science learning journey.
