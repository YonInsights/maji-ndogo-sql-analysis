-- ============================================================
-- Maji Ndogo SQL Analysis
-- Phase 2: Water Source Exploration
-- ============================================================
-- Purpose:
--   Identify all unique types of water sources and understand
--   their scale of impact in the community.
--
-- Why:
--   Different water sources carry different risks. A river is
--   an open source with high contamination risk; a tap in a
--   home is a closed source with low risk. Knowing which types
--   exist — and how many people depend on each — lets us
--   prioritise interventions.
-- ============================================================

USE md_water_services;

-- Step 1: What unique water source types exist?
-- Why: DISTINCT collapses duplicates so we see only categories.
SELECT DISTINCT type_of_water_source
FROM water_source;

-- Step 2: How many sources of each type exist?
-- Why: Tells us the scale of each category.
SELECT
    type_of_water_source,
    COUNT(*) AS number_of_sources
FROM water_source
GROUP BY type_of_water_source
ORDER BY number_of_sources DESC;

-- Step 3: How many people depend on each source type?
-- Why: This is the real measure of impact. A type with few
--      sources but millions served is a critical bottleneck.
SELECT
    type_of_water_source,
    COUNT(*) AS number_of_sources,
    SUM(number_of_people_served) AS total_people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY total_people_served DESC;