-- ============================================================
-- Maji Ndogo SQL Analysis
-- Phase 3: Investigating Long Queues
-- Script: 03_water_source_visits.sql
-- ============================================================
-- Purpose:
--   Find water sources associated with extreme queue times
--   (>500 minutes / 8+ hours).
--
-- Why:
--   Long queues are the clearest symptom of a failing water
--   system. They point to sources that are overloaded, broken,
--   or badly located — the highest-priority targets for
--   intervention.
-- ============================================================

USE md_water_services;

-- Step 1: How many visits had queue times over 500 minutes?
-- Why: Quantify the scale of the extreme-queue problem.
SELECT COUNT(*) AS extreme_queue_visits
FROM visits
WHERE time_in_queue > 500;

-- Step 2: See the actual records with extreme queues
-- Why: Inspect the raw rows so we know what we're dealing with.
SELECT *
FROM visits
WHERE time_in_queue > 500
ORDER BY time_in_queue DESC
LIMIT 20;

-- Step 3: Which source types have extreme queues (> 500 minutes)?
-- Why: "Long queues" alone is a symptom. "Long queues at shared taps"
--      is an actionable insight. Connect visits to water_source via source_id.
SELECT
    w.type_of_water_source,
    COUNT(*) AS number_of_extreme_visits,
    ROUND(AVG(v.time_in_queue), 1) AS avg_queue_minutes
FROM visits AS v
JOIN water_source AS w 
    ON v.source_id = w.source_id
WHERE v.time_in_queue > 500
GROUP BY w.type_of_water_source
ORDER BY number_of_extreme_visits DESC;

-- Step 4: Validate — how many distinct source_ids have extreme queues?
-- Why: Confirms whether 105 visits happened at 105 different sources
--      or a small number of chronically broken sources.
SELECT COUNT(DISTINCT v.source_id) AS distinct_sources
FROM visits AS v
WHERE v.time_in_queue > 500;