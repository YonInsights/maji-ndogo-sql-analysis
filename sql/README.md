# SQL Scripts

Each script in this folder corresponds to one phase of the Maji Ndogo analysis.
Run them in numbered order in MySQL Workbench.

| File | Phase | Purpose |
|---|---|---|
| `01_database_exploration.sql` | 1 | Explore the database structure and tables |
| `02_water_sources.sql` | 2 | Identify unique water source types |
| `03_water_source_visits.sql` | 3 | Analyze visit patterns and queue times |
| `04_water_quality.sql` | 4 | Assess water quality scores and survey integrity (218 records) |
| `05_pollution_analysis.sql` | 5 | Investigate well pollution records and string typos |
| `06_data_cleaning.sql` | 6 | Safely correct erroneous pollution data using a sandbox copy |
| `07_validation.sql` | 7 | Verify that all data-quality issues are resolved |
| `08_employee_data_cleaning.sql` | 8 | Standardize corporate emails and trim phone numbers |
| `09_honouring_workers.sql` | 9 | Employee town distribution and top 3 field surveyors |
| `10_location_analysis.sql` | 10 | Geographic distribution and 60% rural breakdown |
| `11_water_source_breakdown.sql` | 11 | Population impact, averages, and source percentages |
| `12_priority_ranking.sql` | 12 | Window functions (RANK, DENSE_RANK, ROW_NUMBER) for repair priorities |
| `13_queue_pivot_analysis.sql` | 13 | DateTime metrics and hour x day SQL Pivot Table |
| `14_auditor_comparison.sql` | 14 | Integrate auditor report, 3-table JOIN, and score comparison |
| `15_investigating_corruption.sql` | 15 | Create VIEW, CTE suspect list, and bribery statement analysis |

## Prerequisites

1. MySQL Server installed and running
2. MySQL Workbench installed
3. Database `md_water_services` loaded

## How to Run

1. Open MySQL Workbench.
2. Connect to your local MySQL server.
3. Open each `.sql` file (File → Open SQL Script).
4. Execute in numerical order.

## Conventions Used

- Every query block is preceded by a comment explaining what it does.
- Comments explain why the query is needed (business context).
- Results are documented in `../results/README.md`.
