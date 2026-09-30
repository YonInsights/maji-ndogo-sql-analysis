# Maji Ndogo Project: Analytical Notes

## 1. Project Background
Maji Ndogo is a nation facing critical clean water shortages. The national survey logged over 60,000 observations across 39,650 water source locations. As junior data scientists working alongside our senior mentor, our goal was to clean, explore, and analyze the data to guide national policy and protect public health.

---

## 2. Key Findings Summary

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

## 3. Data Cleaning Pipeline Applied
1. **Sandbox Creation:** Built a temporary copy table (`well_pollution_copy`).
2. **Staged Updates:** Corrected descriptions and reclassified false-clean records to `'Contaminated: Biological'`.
3. **Validation Check:** Confirmed 0 error records remain before applying changes to production.
4. **Production Update:** Safely executed changes on `well_pollution` and dropped the staging copy table.
5. **Quality Assurance:** Re-verified live database with post-cleaning validation script.
