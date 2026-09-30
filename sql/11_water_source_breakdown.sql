-- ============================================================
-- Maji Ndogo SQL Analysis - Part 2
-- Phase 11: Water Source Breakdown & Population Impact
-- Script: 11_water_source_breakdown.sql
-- ============================================================
-- Business Context:
--   To size budget allocations and engineering interventions,
--   leadership requires precise population impact figures:
--     1. Total citizens surveyed.
--     2. Average load/capacity per water source type.
--     3. Total population and percentage dependent on each source.
--
-- Objectives:
--   - Compute national totals and averages.
--   - Analyze the shared tap crisis (43% of citizens).
--   - Analyze broken piped infrastructure (45% of home taps broken).
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Total population surveyed across all water sources
-- Expected: ~27.6 million citizens (27,628,140)
-- ------------------------------------------------------------
SELECT SUM(number_of_people_served) AS total_people_surveyed
FROM water_source;

-- ------------------------------------------------------------
-- Step 2: Number of sources per category
-- ------------------------------------------------------------
SELECT
    type_of_water_source,
    COUNT(*) AS number_of_sources
FROM water_source
GROUP BY type_of_water_source
ORDER BY number_of_sources DESC;

-- ------------------------------------------------------------
-- Step 3: Average number of people served per water source
-- Why: Understand typical capacity/load per installation.
-- Note: Shared taps average > 2,000 people per tap!
-- ------------------------------------------------------------
SELECT
    type_of_water_source,
    ROUND(AVG(number_of_people_served), 0) AS avg_people_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY avg_people_per_source DESC;

-- ------------------------------------------------------------
-- Step 4: Total population served and percentage breakdown
-- Why: Measure national proportion dependent on each source.
-- ------------------------------------------------------------
SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS population_served,
    ROUND(
        SUM(number_of_people_served) * 100.0 / 
        (SELECT SUM(number_of_people_served) FROM water_source),
        0
    ) AS percentage_people_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY population_served DESC;
