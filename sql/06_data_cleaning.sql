-- ============================================================
-- Maji Ndogo SQL Analysis
-- Phase 6: Safe Data Cleaning Workflow
-- Script: 06_data_cleaning.sql
-- ============================================================
-- Best Practice Standard:
--   Never run UPDATE statements directly on production tables.
--   Always create a backup/sandbox copy, test modifications,
--   verify the result, and only then apply changes to the live table.
--
-- Corrections to Perform:
--   1. Case 1a: Change 'Clean Bacteria: E. coli' -> 'Bacteria: E. coli'
--   2. Case 1b: Change 'Clean Bacteria: Giardia Lamblia' -> 'Bacteria: Giardia Lamblia'
--   3. Case 2:  Change results from 'Clean' -> 'Contaminated: Biological'
--               where biological contamination > 0.01
-- ============================================================

USE md_water_services;

-- Disable MySQL Workbench safe-update mode for batch updates
SET SQL_SAFE_UPDATES = 0;

-- ------------------------------------------------------------
-- Step 1: Create a safety sandbox copy table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS md_water_services.well_pollution_copy;

CREATE TABLE md_water_services.well_pollution_copy AS (
    SELECT *
    FROM md_water_services.well_pollution
);

-- ------------------------------------------------------------
-- Step 2: Apply corrections to the sandbox copy table
-- ------------------------------------------------------------

-- Fix Case 1a: Typo in E. coli descriptions
UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

-- Fix Case 1b: Typo in Giardia descriptions
UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Fix Case 2: Update falsely classified clean wells to Contaminated: Biological
UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
  AND results = 'Clean';

-- ------------------------------------------------------------
-- Step 3: Verify the sandbox copy table
-- Why: Ensure 0 error rows remain before touching production.
-- Expected Result: 0 rows returned.
-- ------------------------------------------------------------
SELECT *
FROM well_pollution_copy
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);

-- ------------------------------------------------------------
-- Step 4: Apply verified corrections to the PRODUCTION table
-- ------------------------------------------------------------
UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
  AND results = 'Clean';

-- ------------------------------------------------------------
-- Step 5: Clean up temporary copy table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS md_water_services.well_pollution_copy;
