-- ============================================================
-- Phase 1: Database Exploration
-- Project: Maji Ndogo SQL Analysis
-- Script: 01_database_exploration.sql
-- Description: Explores database tables, sample records, and schema.
-- ============================================================

-- Ensure we are using the correct database schema
USE md_water_services;

-- ------------------------------------------------------------
-- 1. List all tables in the md_water_services database
-- ------------------------------------------------------------
SHOW TABLES;

-- ------------------------------------------------------------
-- 2. Inspect sample records from each table to understand columns and data structure
-- ------------------------------------------------------------

-- Inspect employee table (surveyors and staff information)
SELECT *
FROM employee
LIMIT 5;

-- Inspect global_water_access table (national/regional water access statistics)
SELECT *
FROM global_water_access
LIMIT 5;

-- Inspect location table (addresses, towns, provinces, and location types)
SELECT *
FROM location
LIMIT 5;

-- Inspect visits table (survey records, queue times, and relationships)
SELECT *
FROM visits
LIMIT 5;

-- Inspect water_quality table (subjective quality scores per visit)
SELECT *
FROM water_quality
LIMIT 5;

-- Inspect water_source table (water source types and number of people served)
SELECT *
FROM water_source
LIMIT 5;

-- Inspect well_pollution table (water test metrics: PPM, biological contamination, results)
SELECT *
FROM well_pollution
LIMIT 5;

-- ------------------------------------------------------------
-- 3. Query the embedded data dictionary table for column documentation
-- ------------------------------------------------------------
SELECT *
FROM data_dictionary;
