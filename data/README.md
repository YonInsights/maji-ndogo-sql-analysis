\# Maji Ndogo — Data Documentation



This project analyzes water access data from the Maji Ndogo survey.

The full database (`md\_water\_services`) is \*\*not stored in this repository\*\* to keep the repo lightweight and reproducible.



The source data was provided as part of the ALX Data Science program.



\---



\## Database Overview



| Property | Value |

|---|---|

| \*\*Database name\*\* | `md\_water\_services` |

| \*\*Total records\*\* | \~60,000 |

| \*\*Total columns\*\* | 43 |

| \*\*Tables\*\* | 8 |

| \*\*Source\*\* | ALX Data Science / Maji Ndogo Integrated Project |



\---



\## Table 1: `employee`



Information about the field workers who collected the survey data.



| Column | Description | Data Type |

|---|---|---|

| `assigned\_employee\_id` | Unique ID for each employee | INT |

| `employee\_name` | Full name | VARCHAR(255) |

| `phone\_number` | Contact number | VARCHAR(15) |

| `email` | Email address | VARCHAR(255) |

| `address` | Residential address | VARCHAR(255) |

| `town\_name` | Town of residence | VARCHAR(255) |

| `province\_name` | Province of residence | VARCHAR(255) |

| `position` | Job title | VARCHAR(255) |



\---



\## Table 2: `global\_water\_access`



Country-level water access statistics.



| Column | Description | Data Type |

|---|---|---|

| `name` | Country or region name | VARCHAR(255) |

| `region` | Geographic region | VARCHAR(255) |

| `year` | Year of record | INT |

| `pop\_n` | National population (thousands) | FLOAT |

| `pop\_u` | Urban population share (%) | FLOAT |

| `wat\_bas\_n` | National share with basic service (%) | FLOAT |

| `wat\_lim\_n` | National share with limited service (%) | FLOAT |

| `wat\_unimp\_n` | National share with unimproved service (%) | FLOAT |

| `wat\_sur\_n` | National share with surface service (%) | FLOAT |

| `wat\_bas\_r` | Rural share with basic service (%) | FLOAT |

| `wat\_lim\_r` | Rural share with limited service (%) | FLOAT |

| `wat\_unimp\_r` | Rural share with unimproved service (%) | FLOAT |

| `wat\_sur\_r` | Rural share with surface service (%) | FLOAT |

| `wat\_bas\_u` | Urban share with basic service (%) | FLOAT |

| `wat\_lim\_u` | Urban share with limited service (%) | FLOAT |

| `wat\_unimp\_u` | Urban share with unimproved service (%) | FLOAT |

| `wat\_sur\_u` | Urban share with surface service (%) | FLOAT |



\---



\## Table 3: `location`



Geographic locations of water sources.



| Column | Description | Data Type |

|---|---|---|

| `location\_id` | Unique location ID | VARCHAR(255) |

| `address` | Street address | VARCHAR(255) |

| `province\_name` | Province | VARCHAR(255) |

| `town\_name` | Town | VARCHAR(255) |

| `location\_type` | Urban / Rural | VARCHAR(255) |



\---



\## Table 4: `visits`



Log of every visit made by an employee to a water source.



| Column | Description | Data Type |

|---|---|---|

| `record\_id` | Unique visit record ID | INT |

| `location\_id` | FK → `location.location\_id` | VARCHAR(255) |

| `source\_id` | FK → `water\_source.source\_id` | VARCHAR(510) |

| `time\_of\_record` | Date and time of visit | DATETIME |

| `visit\_count` | Number of visits made here | INT |

| `time\_in\_queue` | Wait time (minutes) | INT |

| `assigned\_employee\_id` | FK → `employee.assigned\_employee\_id` | INT |



\---



\## Table 5: `water\_quality`



Subjective quality scores assigned by field surveyors.



| Column | Description | Data Type |

|---|---|---|

| `record\_id` | Unique record ID | INT |

| `subjective\_quality\_score` | 1 (terrible) to 10 (clean) | INT |

| `visit\_count` | Number of visits | INT |



\---



\## Table 6: `water\_source`



Types of water sources and how many people they serve.



| Column | Description | Data Type |

|---|---|---|

| `source\_id` | Unique water source ID | INT |

| `type\_of\_water\_source` | `tap\_in\_home`, `tap\_in\_home\_broken`, `well`, `shared\_tap`, `river` | VARCHAR |

| `number\_of\_people\_served` | Population served by this source | INT |



\*\*Note:\*\* For `tap\_in\_home` and `tap\_in\_home\_broken` records, one row represents an aggregate of many households (\~160 homes × \~6 people ≈ 956 served).



\---



\## Table 7: `well\_pollution`



Laboratory test results for well water contamination.



| Column | Description | Data Type |

|---|---|---|

| `source\_id` | FK → `water\_source.source\_id` | VARCHAR(258) |

| `date` | Date of pollution test | DATETIME |

| `description` | Text note from scientists | VARCHAR(255) |

| `pollutant\_ppm` | Chemical pollutant (parts per million) | FLOAT |

| `biological` | Biological contamination (CFU/mL) | FLOAT |

| `results` | `Clean`, `Contaminated: Biological`, or `Contaminated: Chemical` | VARCHAR(255) |



\*\*Threshold:\*\* `biological > 0.01` indicates contamination.



\---



\## Table 8: `data\_dictionary`



Column descriptions embedded in the database itself (reference table).



\---



\## Relationship Diagram

location ────┐

│ location\_id

▼

visits ────────┐

│ source\_id

▼

water\_source ────┐

│ source\_id

▼

well\_pollution



employee ◄──── assigned\_employee\_id ──── visits



water\_quality ◄──── record\_id ──── visits

