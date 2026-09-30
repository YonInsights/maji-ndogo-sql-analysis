-- ============================================================
-- Maji Ndogo SQL Analysis - Part 2
-- Phase 13: Queue Time Analysis & SQL Pivot Table
-- Script: 13_queue_pivot_analysis.sql
-- ============================================================
-- Business Context:
--   To deploy emergency water tankers and schedule repair crews,
--   we must uncover temporal patterns in citizen water collection:
--     1. How long did the entire survey take?
--     2. What is the real average wait time (excluding 0-minute home taps)?
--     3. Which days of the week have the worst congestion?
--     4. What hours of the day are peak collection times?
--     5. Build an executive Pivot Table in SQL breaking down queue times
--        by hour across all 7 days of the week.
-- ============================================================

USE md_water_services;

-- ------------------------------------------------------------
-- Step 1: Survey Duration (Days between first and last visit)
-- Why: Understand time elapsed across the data collection initiative.
-- Expected Result: 924 days (~2.5 years).
-- ------------------------------------------------------------
SELECT
    MIN(time_of_record) AS survey_start,
    MAX(time_of_record) AS survey_end,
    DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS survey_duration_days
FROM visits;

-- ------------------------------------------------------------
-- Step 2: Average Queue Time for Queuing Sources
-- Why: Home taps record 0 minutes. Using NULLIF(time_in_queue, 0)
--      excludes instant access and measures the true queue burden.
-- Expected Result: ~123 minutes (~2 hours).
-- ------------------------------------------------------------
SELECT
    ROUND(AVG(NULLIF(time_in_queue, 0)), 0) AS avg_queue_time_minutes
FROM visits;

-- ------------------------------------------------------------
-- Step 3: Average Queue Time by Day of the Week
-- Why: Identify peak congestion days.
-- Note: Saturday has peak wait times (~246 min / > 4 hours).
--       Sunday has the lowest queue times (~82 min).
-- ------------------------------------------------------------
SELECT
    DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(NULLIF(time_in_queue, 0)), 0) AS avg_queue_time
FROM visits
GROUP BY DAYNAME(time_of_record)
ORDER BY avg_queue_time DESC;

-- ------------------------------------------------------------
-- Step 4: Average Queue Time by Hour of the Day
-- Why: Identify daily rush hours (mornings and evenings).
-- ------------------------------------------------------------
SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue, 0)), 0) AS avg_queue_time
FROM visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- ------------------------------------------------------------
-- Step 5: Executive SQL Pivot Table (Hour of Day x Day of Week)
-- Why: Provides an hourly heatmap across all days for logistics deployment.
-- Method: Conditional aggregation using CASE statements inside AVG().
-- ------------------------------------------------------------
SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    -- Sunday
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue ELSE NULL END), 0) AS Sunday,
    -- Monday
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue ELSE NULL END), 0) AS Monday,
    -- Tuesday
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue ELSE NULL END), 0) AS Tuesday,
    -- Wednesday
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue ELSE NULL END), 0) AS Wednesday,
    -- Thursday
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue ELSE NULL END), 0) AS Thursday,
    -- Friday
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue ELSE NULL END), 0) AS Friday,
    -- Saturday
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue ELSE NULL END), 0) AS Saturday
FROM visits
WHERE time_in_queue != 0
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;
