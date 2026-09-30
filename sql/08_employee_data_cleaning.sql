-- ============================================================
-- Maji Ndogo SQL Analysis - Part 2
-- Phase 8: Cleaning Employee Data
-- Script: 08_employee_data_cleaning.sql
-- ============================================================
-- Business Context:
--   The team needs to send survey reports, performance figures,
--   and communications to field employees.
--   Currently:
--     1. The email column is completely NULL.
--     2. Phone numbers have a hidden trailing space causing SMS errors.
--
-- Objective:
--   1. Generate official emails: first_name.last_name@ndogowater.gov
--      using LOWER(), REPLACE(), and CONCAT().
--   2. Clean phone numbers using TRIM() to ensure valid 12-character format.
-- ============================================================

USE md_water_services;

-- Disable safe updates for batch data cleaning
SET SQL_SAFE_UPDATES = 0;

-- ------------------------------------------------------------
-- Step 1: Test email address generation with SELECT
-- Why: Always test string operations before updating the table.
-- ------------------------------------------------------------
SELECT
    employee_name,
    CONCAT(
        LOWER(REPLACE(employee_name, ' ', '.')),
        '@ndogowater.gov'
    ) AS generated_email
FROM employee
LIMIT 5;

-- ------------------------------------------------------------
-- Step 2: Update the employee table with generated email addresses
-- ------------------------------------------------------------
UPDATE employee
SET email = CONCAT(
    LOWER(REPLACE(employee_name, ' ', '.')),
    '@ndogowater.gov'
);

-- ------------------------------------------------------------
-- Step 3: Investigate phone numbers length
-- Why: Valid format (+99 followed by 10 digits) should be 12 characters.
--      Extra characters cause automated SMS alerts to fail.
-- ------------------------------------------------------------
SELECT
    employee_name,
    phone_number,
    LENGTH(phone_number) AS phone_len
FROM employee
LIMIT 5;

-- ------------------------------------------------------------
-- Step 4: Clean phone numbers by removing trailing spaces using TRIM()
-- ------------------------------------------------------------
UPDATE employee
SET phone_number = TRIM(phone_number);

-- ------------------------------------------------------------
-- Step 5: Verification check
-- Why: Confirm email is populated and all phone numbers are exactly 12 characters.
-- ------------------------------------------------------------
SELECT
    employee_name,
    email,
    phone_number,
    LENGTH(phone_number) AS phone_len
FROM employee
LIMIT 10;
