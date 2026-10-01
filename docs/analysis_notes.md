# Maji Ndogo Project: Analytical Notes

## 1. Project Background
Maji Ndogo is a nation facing critical clean water shortages. The national survey logged over 60,000 observations across 39,650 water source locations. As junior data scientists working alongside our senior mentor, our goal was to clean, explore, and analyze the data to guide national policy and protect public health.

---

## 2. Part 1 Key Findings Summary

### Finding 1: Shared Tap Bottleneck & Crisis
- **5,767 shared taps** serve **11,945,272 people** (~2,071 people per tap).
- **105 survey visits** recorded queue times exceeding **500 minutes (8+ hours)**, averaging **519.2 minutes (~8.7 hours)**.
- **100% of extreme queues** were concentrated exclusively at shared taps.

### Finding 2: Broken Infrastructure
- **5,856 home taps** are physically installed but non-functional (`tap_in_home_broken`), affecting **3,799,720 people**.
- Repairing existing piped home infrastructure could immediately relieve pressure on shared taps.

### Finding 3: High-Risk Water Sources
- **3,379 river locations** serve **2,362,544 people**.
- Rivers represent open, unmanaged surface water with the highest biological and chemical contamination vulnerability.

### Finding 4: Survey Fraud / Audit Flags
- Clean home taps (`tap_in_home`) are rated with a maximum subjective quality score of **10**.
- Protocol required home taps to be visited only once (`visit_count = 1`).
- Analysis identified **218 records** where `score = 10` and `visit_count = 2`.
- These impossible combinations indicate data-entry errors or survey fraud, justifying an independent auditor.

### Finding 5: Well Pollution Data Inconsistencies & Corrections
- **40 contaminated wells** with biological counts $> 0.01$ CFU/mL were falsely labeled as `"Clean"`.
- **38 records** contained typographical errors starting with `"Clean "` (`Clean Bacteria: E. coli` and `Clean Bacteria: Giardia Lamblia`).
- Data entry clerks relied on the leading word `"Clean"` rather than the biological laboratory results.

---

## 3. Part 2 Key Findings & Advanced Analytics

### Finding 6: Employee Data Standardization
- Reconstructed corporate emails (`first.last@ndogowater.gov`) using SQL string functions (`LOWER`, `REPLACE`, `CONCAT`).
- Fixed hidden trailing spaces in phone numbers using `TRIM()` (reduced length from 13 to 12 characters) to enable automated SMS alert systems.

### Finding 7: 60% Rural Distribution
- **60% of all water sources (23,740 sources)** are located in rural communities, while only 40% are urban.
- Infrastructure teams must prioritize rural logistics, mobile maintenance crews, and specialized equipment.

### Finding 8: National Population Proportions
- **Total Population Surveyed:** 27,628,140 citizens.
- **Shared Taps (43%):** 11.9 million people depend on public taps.
- **Home Taps (31% total):** 17% functional, but 14% broken (meaning 45% of existing home infrastructure is failing).
- **Wells (18%):** 4.8 million people.
- **Rivers (9%):** 2.4 million people drinking raw river water.

### Finding 9: Data-Driven Priority Queuing
- Excluded functional home taps (`tap_in_home`) from repair lists.
- Used SQL Window Functions (`RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC)`) to build an engineering priority list ranking sources by population impact.

### Finding 10: The Saturday Queue Crisis & Hourly Heatmap
- Survey elapsed over **924 days** (~2.5 years).
- Citizens without home taps spend an average of **123 minutes (~2 hours)** queuing for water.
- **Saturday Crisis:** Average queue time surges to **246 minutes (>4.1 hours)** as households gather their weekly water supply.
- **Rush Hours:** Weekdays experience twin spikes in the early morning (06:00-08:00) and evening (17:00-19:00).
- **Sunday Respite:** Shortest queue times (**82 minutes**) due to cultural, religious, and family priorities.

---

## 4. Strategic Recommendations for President Naledi

1. **Target the UN 30-Minute Water Standard:**
   - Under international standards, acceptable wait time for drinking water is $\le 30$ minutes.
   - Install additional shared taps in dense neighborhoods to reduce average waits from 123 minutes to under 30 minutes.
2. **Immediate Saturday Water Tanker Relief:**
   - Deploy emergency mobile water trucks to the highest-ranked shared taps on Saturdays and weekday peak hours (guided by our SQL Pivot Table heatmap).
3. **High-ROI Piped Infrastructure Repairs:**
   - Repairing central treatment plants and feeder pipes will immediately restore running water to 3.8 million people with broken home taps, instantly taking pressure off shared taps.
4. **Water Quality Upgrades:**
   - Install UV purification filters on biologically contaminated wells.
   - Install reverse osmosis filtration units on chemically contaminated wells.

---

## 5. Part 3 Independent Audit & Corruption Findings

### Finding 11: Ground Audit Baseline (94% Accuracy)
- Chief Auditor Tendai Mubarak re-surveyed 1,620 sites independently.
- **1,518 sites (93.7% / ~94%)** matched original surveyor scores.
- **102 sites (6.3%)** had falsified scores (clean scores of 10 logged for dirty/unusable water).
- Water source categories were unaffected; corruption was isolated to quality ratings.

### Finding 12: Identification of Primary Corrupt Suspects
- Cross-referencing incorrect records identified 17 surveyors, but errors were heavily skewed:
  - Average mistakes across cohort: ~6.
  - **4 Surveyors accounted for 71 out of 102 tampered records (70%):**
    1. **Bello Azibo:** 26 corrupt entries
    2. **Malachi Mavuso:** 21 corrupt entries
    3. **Zuriel Matembo:** 17 corrupt entries
    4. **Lalitha Kaburi:** 7 corrupt entries
  - The remaining 13 surveyors averaged only 1-2 mistakes, representing standard human error.

### Finding 13: Concrete Bribery Evidence
- Filtering citizen interview statements for keyword `'cash'` revealed multiple eyewitness reports of corrupt officials accepting money to falsely report clean water.
- A cross-check confirmed that **0 employees outside the 4 suspects** had any allegations of cash bribery.
- A formal dossier of SQL evidence was compiled for President Naledi's anti-corruption commission.
