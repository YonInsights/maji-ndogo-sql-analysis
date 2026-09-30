-- ============================================================
-- Maji Ndogo SQL Analysis - Part 2
-- Phase 10: Location Analysis (Geographic Distribution)
-- Script: 10_location_analysis.sql
-- ============================================================
-- Business Context:
--   To deploy engineering teams and supplies effectively, leadership
--   must understand the geographic spread of water sources across
--   provinces, towns, and rural vs. urban territories.
--
-- Objectives:
--   1. Count water sources per town.
--   2. Count water sources per province.
--   3. Create a detailed multi-level breakdown: sources per town within each province.
--   4. Calculate the proportion of rural vs. urban water sources (the 60% rural insight).
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Water sources per town
-- ------------------------------------------------------------
SELECT
    town_name,
    COUNT(*) AS records_per_town
FROM location
GROUP BY town_name
ORDER BY records_per_town DESC;

-- ------------------------------------------------------------
-- Step 2: Water sources per province
-- ------------------------------------------------------------
SELECT
    province_name,
    COUNT(*) AS records_per_province
FROM location
GROUP BY province_name
ORDER BY records_per_province DESC;

-- ------------------------------------------------------------
-- Step 3: Multi-level breakdown: Province and Town
-- Why: Groups by province, then sorts towns within each province by source count.
-- ------------------------------------------------------------
SELECT
    province_name,
    town_name,
    COUNT(*) AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name ASC, records_per_town DESC;

-- ------------------------------------------------------------
-- Step 4: Breakdown by Location Type (Rural vs. Urban)
-- ------------------------------------------------------------
SELECT
    location_type,
    COUNT(*) AS num_sources,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM location), 0) AS percentage
FROM location
GROUP BY location_type;
