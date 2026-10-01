-- ============================================================
-- Maji Ndogo SQL Analysis - Part 4
-- Phase 17: Provincial & Municipal Infrastructure Pivots
-- Script: 17_provincial_and_town_pivots.sql
-- ============================================================
-- Business Context:
--   To deploy limited resources effectively, we must break down water access
--   by geography (provinces and towns). This reveals which communities suffer
--   from specific infrastructure failures (e.g. river reliance vs broken pipes).
--
-- Analytical Workflow:
--   1. Construct a Provincial Access Pivot Table using CTEs and conditional aggregation.
--   2. Address duplicate town names across provinces (e.g. Harare, Amina).
--   3. Materialize a Temporary Table (`town_aggregated_water_access`) for rapid query performance.
--   4. Calculate infrastructure failure ratios to uncover acute municipal disparities.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Provincial Water Source Access Pivot Table
-- Why: Calculates what percentage of each province's population relies
--      on each of the 5 water source types.
-- ------------------------------------------------------------
WITH province_totals AS (
    SELECT
        province_name,
        SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name
)
SELECT
    ct.province_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table AS ct
JOIN province_totals AS pt
    ON ct.province_name = pt.province_name
GROUP BY ct.province_name
ORDER BY ct.province_name;

-- ------------------------------------------------------------
-- Step 2: Town-Level Access Pivot & Temporary Table
-- Why: Duplicate town names exist (Harare in Akatsi & Kilimani; Amina in Amanzi & Hawassa).
--      We must group and join on the composite key (province_name, town_name).
--      We persist the result into a TEMPORARY TABLE for fast subsequent queries.
-- ------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS town_aggregated_water_access;

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (
    SELECT
        province_name,
        town_name,
        SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name, town_name
)
SELECT
    ct.province_name,
    ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM combined_analysis_table AS ct
JOIN town_totals AS tt
    ON ct.province_name = tt.province_name
   AND ct.town_name = tt.town_name
GROUP BY
    ct.province_name,
    ct.town_name
ORDER BY ct.town_name;

-- Inspect the materialized temporary table
SELECT *
FROM town_aggregated_water_access
LIMIT 15;

-- ------------------------------------------------------------
-- Step 3: Deep-Dive Analysis — River Dependence Ranking
-- Why: Identifies communities forced to drink untreated surface river water.
-- Finding: Sokoto has the highest river reliance, particularly rural communities and Bahari.
-- ------------------------------------------------------------
SELECT
    province_name,
    town_name,
    river,
    shared_tap,
    tap_in_home,
    tap_in_home_broken,
    well
FROM town_aggregated_water_access
ORDER BY river DESC
LIMIT 10;

-- ------------------------------------------------------------
-- Step 4: Deep-Dive Analysis — Broken Tap Ratio Disparity
-- Why: Measures the percentage of installed piped home connections that are non-functional.
-- Formula: (tap_in_home_broken / (tap_in_home_broken + tap_in_home)) * 100
-- Findings:
--   - Amina (Amanzi): ~95% of installed taps are broken (56% broken vs 3% working).
--   - Dahabu (Amanzi - Capital): ~98% of taps work (55% working vs 1% broken).
--   - Dramatic infrastructure disparity highlighting where past governments invested.
-- ------------------------------------------------------------
SELECT
    province_name,
    town_name,
    tap_in_home,
    tap_in_home_broken,
    ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100, 0) AS Pct_broken_taps
FROM town_aggregated_water_access
WHERE (tap_in_home_broken + tap_in_home) > 0
ORDER BY Pct_broken_taps DESC;
