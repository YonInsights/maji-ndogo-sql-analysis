-- ============================================================
-- Maji Ndogo SQL Analysis
-- Phase 7: Post-Cleaning Validation & Quality Assurance
-- Script: 07_validation.sql
-- ============================================================
-- Purpose:
--   Independently verify that the well_pollution table is completely
--   clean, consistent, and ready for reporting to decision makers.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Validation 1: Check for any remaining corrupted descriptions or false-clean results
-- Expected: 0 rows returned.
-- ------------------------------------------------------------
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);

-- ------------------------------------------------------------
-- Validation 2: Ensure all biologically contaminated wells (> 0.01)
-- are classified correctly as 'Contaminated: Biological'
-- Expected: 0 rows returned.
-- ------------------------------------------------------------
SELECT COUNT(*) AS unclassified_biological_contamination
FROM well_pollution
WHERE biological > 0.01
  AND results != 'Contaminated: Biological';

-- ------------------------------------------------------------
-- Validation 3: Inspect final pollution status breakdown across all tested wells
-- Why: Provide clean summary statistics for public health leadership.
-- ------------------------------------------------------------
SELECT
    results,
    COUNT(*) AS total_wells,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM well_pollution), 2) AS percentage
FROM well_pollution
GROUP BY results
ORDER BY total_wells DESC;
