-- ============================================================
-- Maji Ndogo SQL Analysis - Part 3
-- Phase 15: Uncovering Data Tampering & The Corruption Probe
-- Script: 15_investigating_corruption.sql
-- ============================================================
-- Business Context:
--   The audit revealed 102 tampered water quality scores.
--   We must determine whether these were innocent human errors
--   or deliberate fraud/corruption.
--
-- Investigation Plan:
--   1. Create a persistent VIEW: `Incorrect_records` linking audit scores,
--      employee scores, and citizen interview statements.
--   2. Calculate error counts per employee.
--   3. Filter employees with above-average error rates (the suspect list).
--   4. Query interview statements for incriminating keywords (e.g., 'cash', 'bribe').
--   5. Prove whether bribery allegations are isolated exclusively to the 4 suspects.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Create or Replace VIEW `Incorrect_records`
-- Why: Reusable virtual table joining 4 tables to expose score differences.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW Incorrect_records AS (
    SELECT
        ar.location_id,
        v.record_id,
        e.employee_name,
        ar.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS employee_score,
        ar.statements AS statements
    FROM auditor_report AS ar
    JOIN visits AS v
        ON ar.location_id = v.location_id
    JOIN water_quality AS wq
        ON v.record_id = wq.record_id
    JOIN employee AS e
        ON e.assigned_employee_id = v.assigned_employee_id
    WHERE v.visit_count = 1
      AND ar.true_water_source_score != wq.subjective_quality_score
);

-- Test the view
SELECT *
FROM Incorrect_records
LIMIT 10;

-- ------------------------------------------------------------
-- Step 2: Count mistakes per employee
-- Why: Distinguish random human error (1-2 mistakes) from systematic tampering.
-- ------------------------------------------------------------
SELECT
    employee_name,
    COUNT(*) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes DESC;

-- ------------------------------------------------------------
-- Step 3: Identify Suspects with Above-Average Mistakes
-- Why: Uses a CTE to dynamically filter employees exceeding average mistake volume.
-- Expected Suspects: Bello Azibo (26), Malachi Mavuso (21), Zuriel Matembo (17), Lalitha Kaburi (7).
-- ------------------------------------------------------------
WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT
        employee_name,
        number_of_mistakes
    FROM error_count
    WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT *
FROM suspect_list
ORDER BY number_of_mistakes DESC;

-- ------------------------------------------------------------
-- Step 4: Gather Bribery Evidence ("cash" statements)
-- Why: Cross-reference suspect records with citizen statements mentioning 'cash'.
-- ------------------------------------------------------------
WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT employee_name
    FROM error_count
    WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list)
  AND statements LIKE '%cash%';

-- ------------------------------------------------------------
-- Step 5: Verification — Did ANY other employee take cash?
-- Why: Ensure no other employees are implicated in bribery allegations.
-- Expected Result: 0 rows returned (Empty Set).
-- ------------------------------------------------------------
WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT employee_name
    FROM error_count
    WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name NOT IN (SELECT employee_name FROM suspect_list)
  AND statements LIKE '%cash%';
