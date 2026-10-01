-- ============================================================
-- Maji Ndogo SQL Analysis - Part 4
-- Phase 18: Engineering Action Plan & Implementation
-- Script: 18_project_progress_action_plan.sql
-- ============================================================
-- Business Context:
--   Having analyzed water access, water quality, and infrastructure failures,
--   President Naledi needs an operational database table (`Project_progress`)
--   to dispatch engineering crews, assign specific improvements, and track
--   repair progress across Maji Ndogo.
--
-- Prescriptive Improvement Rules:
--   1. Rivers -> "Drill well"
--   2. Chemically Contaminated Wells -> "Install RO filter"
--   3. Biologically Contaminated Wells -> "Install UV and RO filter"
--   4. Congested Shared Taps (Queue >= 30 min) ->
--      "Install X taps nearby" where X = FLOOR(time_in_queue / 30)
--   5. Broken Home Taps -> "Diagnose local infrastructure"
--
-- Target Population:
--   Excludes functional taps and clean wells, resulting in exactly
--   25,398 actionable infrastructure projects.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Create the `Project_progress` Table
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Project_progress (
    Project_id SERIAL PRIMARY KEY,
    source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
    Address VARCHAR(50),
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50),
    Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    Date_of_completion DATE,
    Comments TEXT
);

-- ------------------------------------------------------------
-- Step 2: Verification Query — Target Filter & Improvement Mapping
-- Why: Test the query logic before inserting records into Project_progress.
-- Expected Row Count: Exactly 25,398 rows with 0 NULL improvements.
-- ------------------------------------------------------------
SELECT
    water_source.source_id,
    location.address,
    location.town_name,
    location.province_name,
    water_source.type_of_water_source,
    CASE
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN type_of_water_source = 'river' THEN 'Drill well'
        WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30
            THEN CONCAT('Install ', FLOOR(visits.time_in_queue / 30), ' taps nearby')
        WHEN type_of_water_source = 'tap_in_home_broken'
            THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvement
FROM water_source
LEFT JOIN well_pollution
    ON water_source.source_id = well_pollution.source_id
INNER JOIN visits
    ON water_source.source_id = visits.source_id
INNER JOIN location
    ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
  AND (
      well_pollution.results != 'Clean'
      OR type_of_water_source IN ('tap_in_home_broken', 'river')
      OR (type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
  )
LIMIT 10;

-- ------------------------------------------------------------
-- Step 3: Populate `Project_progress`
-- Why: Loads all 25,398 actionable improvement tasks into the live tracking table.
-- ------------------------------------------------------------
INSERT INTO Project_progress (source_id, Address, Town, Province, Source_type, Improvement)
SELECT
    water_source.source_id,
    location.address,
    location.town_name,
    location.province_name,
    water_source.type_of_water_source,
    CASE
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN type_of_water_source = 'river' THEN 'Drill well'
        WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30
            THEN CONCAT('Install ', FLOOR(visits.time_in_queue / 30), ' taps nearby')
        WHEN type_of_water_source = 'tap_in_home_broken'
            THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvement
FROM water_source
LEFT JOIN well_pollution
    ON water_source.source_id = well_pollution.source_id
INNER JOIN visits
    ON water_source.source_id = visits.source_id
INNER JOIN location
    ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
  AND (
      well_pollution.results != 'Clean'
      OR type_of_water_source IN ('tap_in_home_broken', 'river')
      OR (type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
  );

-- ------------------------------------------------------------
-- Step 4: Executive Validation & Progress Metrics
-- ------------------------------------------------------------

-- Total projects loaded (should equal 25,398)
SELECT COUNT(*) AS total_projects_in_backlog
FROM Project_progress;

-- Breakdown of actionable projects by improvement type
SELECT
    Improvement,
    COUNT(*) AS total_tasks,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Project_progress), 1) AS pct_of_backlog
FROM Project_progress
GROUP BY Improvement
ORDER BY total_tasks DESC;

-- Breakdown of projects by province
SELECT
    Province,
    COUNT(*) AS total_projects,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Project_progress), 1) AS pct_of_total
FROM Project_progress
GROUP BY Province
ORDER BY total_projects DESC;

-- Sample Dispatch Job Cards for Field Engineers
SELECT
    Project_id,
    source_id,
    Address,
    Town,
    Province,
    Source_type,
    Improvement,
    Source_status
FROM Project_progress
ORDER BY Project_id ASC
LIMIT 10;
