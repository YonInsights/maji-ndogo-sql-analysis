-- ============================================================
-- Maji Ndogo SQL Analysis
-- Phase 4: Water Quality & Survey Integrity Check
-- Script: 04_water_quality.sql
-- ============================================================
-- Business Context:
--   Field surveyors rated water sources from 1 (terrible) to 10 (perfect).
--   A score of 10 was strictly reserved for clean taps in homes (tap_in_home).
--   Headquarters instructed surveyors to visit home taps ONLY ONCE (visit_count = 1).
--   Re-visits (visit_count = 2) were ONLY permitted for shared taps to monitor queue times.
--
-- The Anomaly / Hypothesis:
--   Therefore, records with subjective_quality_score = 10 AND visit_count = 2
--   are logically impossible under standard operating procedures.
--   Finding such records points to either surveyor data entry errors
--   or falsified survey submissions.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Quantify the impossible records
-- Why: Check how many records violate the survey protocol.
-- Expected Result: 218 suspicious records.
-- ------------------------------------------------------------
SELECT COUNT(*) AS suspicious_quality_records
FROM water_quality
WHERE subjective_quality_score = 10
  AND visit_count = 2;

-- ------------------------------------------------------------
-- Step 2: Inspect the suspicious records
-- Why: Examine the specific record_id values flagged for auditing.
-- ------------------------------------------------------------
SELECT
    record_id,
    subjective_quality_score,
    visit_count
FROM water_quality
WHERE subjective_quality_score = 10
  AND visit_count = 2
ORDER BY record_id ASC;

-- ------------------------------------------------------------
-- Step 3: Analytical Conclusion / Recommendation
-- ------------------------------------------------------------
-- Exactly 218 records show score = 10 with visit_count = 2.
-- This indicates systematic reporting irregularities by field personnel.
-- Recommendation: Appoint an independent auditor to cross-examine
-- these 218 visit logs and interview the assigned surveyors.