-- ============================================================
-- Maji Ndogo SQL Analysis
-- Phase 5: Well Pollution Investigation
-- Script: 05_pollution_analysis.sql
-- ============================================================
-- Business Context:
--   Wells provide drinking water to over 4.8 million people.
--   Field scientists tested wells for chemical pollutants (PPM)
--   and biological contaminants (CFU/mL).
--   A biological score > 0.01 indicates dangerous bacteria (e.g., E. coli).
--
-- Objective:
--   1. Explore the well_pollution table structure.
--   2. Discover inconsistencies between laboratory biological values
--      and the qualitative 'results' column.
--   3. Identify specific data entry typos using pattern matching.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Preview well pollution test records
-- Why: Inspect columns, data types, and initial test classifications.
-- ------------------------------------------------------------
SELECT *
FROM well_pollution
LIMIT 10;

-- ------------------------------------------------------------
-- Step 2: Check for false-clean records
-- Why: Find contaminated wells (biological > 0.01) mistakenly classified as 'Clean'.
-- Expected Result: Multiple records showing active bacteria mislabeled as Clean.
-- ------------------------------------------------------------
SELECT
    source_id,
    date,
    description,
    pollutant_ppm,
    biological,
    results
FROM well_pollution
WHERE results = 'Clean'
  AND biological > 0.01;

-- ------------------------------------------------------------
-- Step 3: Identify description errors using pattern matching (LIKE)
-- Why: Determine if typos such as "Clean Bacteria..." caused the misclassification.
-- Note: 'Clean_%' matches descriptions starting with 'Clean ' plus extra text,
--       ignoring properly labeled 'Clean' wells.
-- Expected Result: Exactly 38 corrupted description records.
-- ------------------------------------------------------------
SELECT
    source_id,
    date,
    description,
    pollutant_ppm,
    biological,
    results
FROM well_pollution
WHERE description LIKE 'Clean_%';

-- ------------------------------------------------------------
-- Step 4: Count the distinct typos needing correction
-- Why: Catalog the exact strings to be corrected during data cleaning.
-- ------------------------------------------------------------
SELECT
    description,
    COUNT(*) AS occurrence_count
FROM well_pollution
WHERE description LIKE 'Clean_%'
GROUP BY description;
