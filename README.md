# RCM Claims & Denial Management Dashboard

An end-to-end revenue cycle analytics project: raw claims data → SQL analysis → interactive Power BI dashboard.

Built to answer the questions a revenue cycle team asks every week: **Where are we losing money to denials, which payers are the problem, how old is our A/R, and are we appealing enough?**

![Dashboard](dashboard.png)

---

## Tools

| Step | Tool |
|---|---|
| Data storage & analysis | SQLite (DB Browser for SQLite) |
| Data modeling & visualization | Power BI Desktop |
| Calculations | SQL (JOINs, CASE, subqueries, date math) and DAX measures |

## Data

Synthetic dataset of **6,094 claims** across 6 related tables:

| Table | Description |
|---|---|
| `claims` | One row per claim: status, billed/allowed/paid amounts, service and submit dates, denial code |
| `payers` | Payer names and types (Commercial, Medicare, Medicaid, Self-Pay) |
| `clinics` | Clinic locations |
| `cpt_codes` | Procedure codes and descriptions |
| `denial_reasons` | CARC codes (e.g., CO-16, CO-197) and descriptions |
| `appeals` | Appeal outcomes and recovered amounts |

**Data model:** star schema with `claims` at the center. `payers`, `clinics`, `cpt_codes`, and `denial_reasons` link to it many-to-one, and `appeals` links one-to-one by `claim_id`.

---

## Key Findings

**1. Overall denial rate is 19.4%, and it varies sharply by payer.**
Coastal Medicaid MCO denies **33.9%** of adjudicated claims, roughly double the rate of Medicare Part B. Self-Pay is lowest at 5.7%.

**2. The most frequent denial is not the most expensive one.**
- **CO-16 (missing/invalid claim information)** is the most common denial reason, which points to a front-end registration problem.
- **CO-197 (prior authorization absent)** ranks 4th in volume but **#1 in dollars, at about $1.1M**.

**3. A/R is heavily aged.**
About **68% of open A/R dollars ($2.46M) are more than 90 days old**, averaging 231 days outstanding. These are the hardest dollars to collect and are at risk of timely-filing write-offs.

**4. Appeals work, but most denials are never appealed.**
- 481 appeals were filed, and **39.5% were overturned**, recovering $162,784.
- Only **46% of denials were appealed**. At the same win rate, the ~556 unappealed denials represent an **estimated $188K in recoverable revenue**.

## Recommendations

1. **Prioritize unappealed prior-auth denials (CO-197).** They are the highest-dollar category and have a proven appeal path.
2. **Add a pre-submission auth check** to stop CO-197 denials before they happen.
3. **Work the 90+ day A/R bucket by payer**, starting with Coastal Medicaid MCO.
4. **Fix front-end registration** to reduce CO-16 (missing information) denials.

---

## SQL Analysis

All queries are in [`rcm_analysis.sql`](rcm_analysis.sql).

| # | Question | Techniques |
|---|---|---|
| 1 | How many claims are paid, denied, or pending? | `GROUP BY` |
| 2 | What is the denial rate by payer? | `JOIN`, `CASE`, excluding pending claims |
| 3 | Which denial reasons cost the most? | `JOIN`, `SUM`, subquery for % of total |
| 4 | How old is open A/R? | `CASE` buckets, `julianday()` date math |
| 5 | How effective are appeals? | Conditional aggregation, `CAST` |

## Power BI Dashboard

**KPI cards:** Total Claims · Denied Claims · Denial Rate · Open A/R · Appeal Overturn Rate

**Charts:**
- Denial Rate by Payer
- Denied Dollars by Reason
- Open A/R by Aging Bucket
- Monthly Denial Rate Trend

**Filters:** payer, clinic, and service date range. Every visual updates together.

**DAX measures:**
```
Denial Rate   = DIVIDE([Denied Claims], CALCULATE(COUNTROWS(claims), claims[claim_status] <> "Pending"))
Open AR       = CALCULATE(SUM(claims[billed_amount]), claims[claim_status] <> "Paid")
Overturn Rate = DIVIDE(CALCULATE(COUNTROWS(appeals), appeals[appeal_outcome] = "Overturned"), COUNTROWS(appeals))
```

**Validation:** every dashboard KPI was checked against the matching SQL query result.

---

## Repository Contents

| File | Description |
|---|---|
| `rcm_analysis.sql` | The 5 SQL analysis queries |
| `RCM_Claims_Dashboard.pbix` | Power BI dashboard file (open in Power BI Desktop, free) |
| `dashboard.png` | Dashboard screenshot |
| `data/` | Source CSV files |

## About

Built by **Jaden Waiters, CHFP, CRCR, CSPR**, a benefits investigation and prior authorization specialist building toward revenue cycle analytics.
[LinkedIn](https://linkedin.com/in/jadenwaiters) · [Tableau Public](https://public.tableau.com/app/profile/jaden.waiters)

*All data is synthetic and contains no real patient information.*
