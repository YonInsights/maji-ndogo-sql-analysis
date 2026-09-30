-- ============================================================
-- Maji Ndogo SQL Analysis - Part 2
-- Phase 9: Honouring the Workers (Field Surveyor Performance)
-- Script: 09_honouring_workers.sql
-- ============================================================
-- Business Context:
--   President Naledi wants to recognize and congratulate the top field
--   surveyors who collected the most data during the national water survey.
--   We also want to understand where our workforce resides across Maji Ndogo.
--
-- Objectives:
--   1. Count how many employees reside in each town.
--   2. Identify the top 3 field surveyors with the highest visit counts.
--   3. Retrieve their contact information (name, email, phone) to send congratulations.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Count employees living in each town
-- Why: Understand workforce geographic distribution.
-- ------------------------------------------------------------
SELECT
    town_name,
    COUNT(*) AS num_employees
FROM employee
GROUP BY town_name
ORDER BY num_employees DESC;

-- ------------------------------------------------------------
-- Step 2: Identify the top 3 field surveyors with the most visits
-- Why: Measure surveyor productivity from the visits logbook.
-- ------------------------------------------------------------
SELECT
    assigned_employee_id,
    COUNT(*) AS number_of_visits
FROM visits
GROUP BY assigned_employee_id
ORDER BY number_of_visits DESC
LIMIT 3;

-- ------------------------------------------------------------
-- Step 3: Retrieve contact details for the top 3 surveyors
-- Why: Look up their names, clean emails, and trimmed phone numbers.
-- Note: Replace employee IDs below with the top 3 IDs from Step 2.
-- ------------------------------------------------------------
SELECT
    assigned_employee_id,
    employee_name,
    email,
    phone_number
FROM employee
WHERE assigned_employee_id IN (1, 30, 34);
