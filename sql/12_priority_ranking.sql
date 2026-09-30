-- ============================================================
-- Maji Ndogo SQL Analysis - Part 2
-- Phase 12: Priority Ranking Using Window Functions
-- Script: 12_priority_ranking.sql
-- ============================================================
-- Business Context:
--   The government has limited budget and repair crews.
--   We must create a data-driven repair priority queue:
--     1. Which water source types should be tackled first?
--     2. Within each source type, which specific physical sources
--        must be repaired first?
--
-- Logic & Rules:
--   - 'tap_in_home' is already clean and functional. We EXCLUDE it
--     from repair queues because it cannot be improved further.
--   - Higher population served = higher repair priority.
--   - Use Window Functions (RANK, DENSE_RANK, ROW_NUMBER) to partition
--     and rank sources without collapsing individual records.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Overall Priority by Source Type
-- Why: Determine which category to invest in first.
-- ------------------------------------------------------------
SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS population_served,
    RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS rank_by_population
FROM water_source
WHERE type_of_water_source != 'tap_in_home'
GROUP BY type_of_water_source;

-- ------------------------------------------------------------
-- Step 2: Ranking individual sources within each type using RANK()
-- Why: Teams can prioritize highest-impact repairs first.
-- ------------------------------------------------------------
SELECT
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS priority_rank
FROM water_source
WHERE type_of_water_source != 'tap_in_home'
ORDER BY type_of_water_source, priority_rank
LIMIT 20;

-- ------------------------------------------------------------
-- Step 3: Compare Ranking Functions (RANK vs. DENSE_RANK vs. ROW_NUMBER)
-- Why:
--   - RANK(): Ties get same rank, but subsequent ranks are skipped (e.g., 1, 1, 3).
--   - DENSE_RANK(): Ties get same rank, subsequent ranks not skipped (e.g., 1, 1, 2).
--   - ROW_NUMBER(): Assigns strict unique sequential integer (e.g., 1, 2, 3).
-- ------------------------------------------------------------
SELECT
    source_id,
    type_of_water_source,
    number_of_people_served,
    ROW_NUMBER() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS row_num_rank,
    RANK() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS standard_rank,
    DENSE_RANK() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS dense_rank_priority
FROM water_source
WHERE type_of_water_source != 'tap_in_home'
ORDER BY type_of_water_source, number_of_people_served DESC
LIMIT 20;
