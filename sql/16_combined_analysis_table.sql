-- ============================================================
-- Maji Ndogo SQL Analysis - Part 4
-- Phase 16: Assembling the Unified Data View
-- Script: 16_combined_analysis_table.sql
-- ============================================================
-- Business Context:
--   To formulate actionable engineering interventions for President Naledi,
--   we need to combine disparate data dimensions across geographic locations,
--   water source types, queue wait times, and laboratory pollution tests.
--
-- Technical Strategy:
--   1. Connect `visits` as the central transaction table.
--   2. Join `location` on `location_id` to get province, town, and location type.
--   3. Join `water_source` on `source_id` to retrieve source type and population served.
--   4. Use a `LEFT JOIN` on `well_pollution` (since only wells have pollution records;
--      non-wells will naturally yield NULL values).
--   5. Filter `visits.visit_count = 1` to eliminate duplicate re-survey rows.
--   6. Encapsulate into a persistent VIEW (`combined_analysis_table`) for downstream
--      provincial and municipal pivot analyses.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Step-by-Step Join Exploration
-- ------------------------------------------------------------

-- Connect location to visits
SELECT
    location.province_name,
    location.town_name,
    visits.visit_count,
    visits.location_id
FROM visits
INNER JOIN location
    ON visits.location_id = location.location_id
LIMIT 5;

-- Connect water_source to visits and location
SELECT
    location.province_name,
    location.town_name,
    visits.visit_count,
    visits.location_id,
    water_source.type_of_water_source,
    water_source.number_of_people_served
FROM visits
INNER JOIN location
    ON visits.location_id = location.location_id
INNER JOIN water_source
    ON visits.source_id = water_source.source_id
LIMIT 5;

-- ------------------------------------------------------------
-- Step 2: Filter for Baseline Surveys (visit_count = 1)
-- Why: Prevent duplicate counting from surveyor revisits (e.g. AkHa00103 visited 8 times).
-- ------------------------------------------------------------
SELECT
    location.province_name,
    location.town_name,
    water_source.type_of_water_source,
    location.location_type,
    water_source.number_of_people_served,
    visits.time_in_queue
FROM visits
INNER JOIN location
    ON location.location_id = visits.location_id
INNER JOIN water_source
    ON water_source.source_id = visits.source_id
WHERE visits.visit_count = 1
LIMIT 10;

-- ------------------------------------------------------------
-- Step 3: Add well_pollution via LEFT JOIN
-- Why: An INNER JOIN would drop all non-well sources (rivers, taps).
--      LEFT JOIN preserves all sources and assigns NULL to pollution for non-wells.
-- ------------------------------------------------------------
SELECT
    water_source.type_of_water_source,
    location.town_name,
    location.province_name,
    location.location_type,
    water_source.number_of_people_served,
    visits.time_in_queue,
    well_pollution.results
FROM visits
LEFT JOIN well_pollution
    ON well_pollution.source_id = visits.source_id
INNER JOIN location
    ON location.location_id = visits.location_id
INNER JOIN water_source
    ON water_source.source_id = visits.source_id
WHERE visits.visit_count = 1
LIMIT 10;

-- ------------------------------------------------------------
-- Step 4: Create Persistent VIEW `combined_analysis_table`
-- Why: Pre-compiles the 4-table join into a reusable virtual table,
--      simplifying queries for provincial summaries and engineering plans.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW combined_analysis_table AS
SELECT
    water_source.type_of_water_source AS source_type,
    location.town_name,
    location.province_name,
    location.location_type,
    water_source.number_of_people_served AS people_served,
    visits.time_in_queue,
    well_pollution.results
FROM visits
LEFT JOIN well_pollution
    ON well_pollution.source_id = visits.source_id
INNER JOIN location
    ON location.location_id = visits.location_id
INNER JOIN water_source
    ON water_source.source_id = visits.source_id
WHERE visits.visit_count = 1;

-- ------------------------------------------------------------
-- Step 5: Validate VIEW Creation
-- ------------------------------------------------------------
SELECT *
FROM combined_analysis_table
LIMIT 10;
