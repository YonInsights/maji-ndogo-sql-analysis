-- ============================================================
-- Maji Ndogo SQL Analysis - Part 3
-- Phase 14: Integrating the Auditor's Report & Score Verification
-- Script: 14_auditor_comparison.sql
-- ============================================================
-- Business Context:
--   Independent Chief Auditor Tendai Mubarak re-visited 1,620 sites
--   to verify survey data integrity.
--
-- Objective:
--   1. Create and structure the auditor_report table.
--   2. Join auditor_report, visits, and water_quality.
--   3. Handle multiple visit duplicates by filtering visits.visit_count = 1.
--   4. Calculate matching accuracy (1,518 / 1,620 = 94%).
--   5. Isolate the 102 tampered/mismatched records (!=).
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Table definition for auditor_report
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `auditor_report`;

CREATE TABLE `auditor_report` (
    `location_id` VARCHAR(32),
    `type_of_water_source` VARCHAR(64),
    `true_water_source_score` INT DEFAULT NULL,
    `statements` VARCHAR(255)
);

-- ------------------------------------------------------------
-- Step 2: 3-Table JOIN linking Auditor Scores to Employee Scores
-- Why: auditor_report has location_id, water_quality has record_id.
--      The visits table bridges them together.
-- Filter: visits.visit_count = 1 eliminates duplicate re-visits.
-- ------------------------------------------------------------
SELECT
    ar.location_id,
    v.record_id,
    ar.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS employee_score
FROM auditor_report AS ar
JOIN visits AS v
    ON ar.location_id = v.location_id
JOIN water_quality AS wq
    ON v.record_id = wq.record_id
WHERE v.visit_count = 1
LIMIT 10;

-- ------------------------------------------------------------
-- Step 3: Measure Honest Records (Auditor score == Employee score)
-- Expected Result: Exactly 1,518 matching records (94% accuracy).
-- ------------------------------------------------------------
SELECT COUNT(*) AS matching_records_count
FROM auditor_report AS ar
JOIN visits AS v
    ON ar.location_id = v.location_id
JOIN water_quality AS wq
    ON v.record_id = wq.record_id
WHERE v.visit_count = 1
  AND ar.true_water_source_score = wq.subjective_quality_score;

-- ------------------------------------------------------------
-- Step 4: Isolate Tampered Records (Auditor score != Employee score)
-- Expected Result: Exactly 102 corrupted/tampered records.
-- ------------------------------------------------------------
SELECT
    ar.location_id,
    v.record_id,
    ar.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS employee_score
FROM auditor_report AS ar
JOIN visits AS v
    ON ar.location_id = v.location_id
JOIN water_quality AS wq
    ON v.record_id = wq.record_id
WHERE v.visit_count = 1
  AND ar.true_water_source_score != wq.subjective_quality_score;
