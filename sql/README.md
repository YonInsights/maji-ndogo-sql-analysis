\# SQL Scripts



Each script in this folder corresponds to one phase of the Maji Ndogo analysis.

Run them in numbered order in MySQL Workbench.



| File | Phase | Purpose |

|---|---|---|

| `01\_database\_exploration.sql` | 1 | Explore the database structure and tables |

| `02\_water\_sources.sql` | 2 | Identify unique water source types |

| `03\_water\_source\_visits.sql` | 3 | Analyze visit patterns and queue times |

| `04\_water\_quality.sql` | 4 | Assess water quality scores and anomalies |

| `05\_pollution\_analysis.sql` | 5 | Investigate well pollution records |

| `06\_data\_cleaning.sql` | 6 | Safely correct erroneous pollution data |

| `07\_validation.sql` | 7 | Verify that all data-quality issues are resolved |



\## Prerequisites



1\. MySQL Server installed and running

2\. MySQL Workbench installed

3\. Database `md\_water\_services` loaded (see `../data/README.md`)



\## How to Run



1\. Open MySQL Workbench.

2\. Connect to your local MySQL server.

3\. Open each `.sql` file (File → Open SQL Script).

4\. Execute in numerical order.



\## Conventions Used



\- Every query block is preceded by a comment explaining what it does.

\- Comments explain why the query is needed (business context).

\- Results are documented in `../results/README.md`.

