# Seller & GMV Performance Intelligence System
### An end-to-end Business Analytics project on the Olist Brazilian E-Commerce dataset

[![SQL](https://img.shields.io/badge/SQL-MySQL-blue)]()
[![Python](https://img.shields.io/badge/Python-Pandas%20%7C%20SciPy-blue)]()
[![Dashboard](https://img.shields.io/badge/Dashboard-Power%20BI-yellow)]()
[![GenAI](https://img.shields.io/badge/GenAI-Gemini%20API-green)]()

---

## The Question

> **Why is Olist's customer repeat-purchase rate so low, and what actually drives it?**

Rather than stopping at a dashboard of KPIs, this project runs a full root-cause investigation: four competing hypotheses are tested with formal statistical methods, two are ruled out, and one is confirmed as the dominant, actionable driver.

## The Headline Finding

Overall repeat-purchase rate: **3.00%** (2,801 of 93,358 customers ever placed a second order) — well below typical e-commerce benchmarks.

| Hypothesis Tested | Result | p-value |
|---|---|---|
| Delivery lateness | Real but small effect (3.05% on-time vs 2.49% late) | 0.007 |
| First-order review score | **No meaningful relationship** (flat 2.96%–3.32% across 1–5 stars) | 0.139 |
| **Product category** | **Dominant driver — ~5x spread** (1.7% to 8.7% across categories) | ~0.0000 |
| Customer state/geography | Moderate, secondary effect (~2.4x spread) | significant |

**Conclusion:** Olist's retention problem is structural and category-driven — not a logistics or satisfaction problem. The data rules out "fix delivery speed" and "improve reviews" as primary levers; the actionable recommendation is category-specific cross-sell and re-engagement strategy.

**Quantified opportunity:** Bringing all below-average categories up to the platform's 3.00% repeat rate represents an estimated **~R$53,000 in additional GMV**, led by `watches_gifts`, `cool_stuff`, and `auto`. This is intentionally modest relative to total platform GMV — a transparent, honest sizing rather than an inflated claim, and a signal that a full retention strategy needs more than one lever.

Full write-up: [`root_cause_writeup.md`](./root_cause_writeup.md)

---

## Project Architecture

```
Raw CSVs (Kaggle: Olist Brazilian E-Commerce Dataset)
        │
        ▼
Python ETL (Pandas) — cleaning, FK validation, date parsing
        │
        ▼
MySQL Database — 9 normalized tables, indexed, FK-constrained
        │
        ▼
Advanced SQL Analytics — CTEs, window functions, views
        │
        ├──► Power BI Dashboard (GMV trend, category & seller performance)
        ├──► Python/SciPy Hypothesis Testing (chi-square, z-tests)
        └──► Gemini API — auto-generated business insight summaries
```

---

## Tech Stack

| Layer | Tools |
|---|---|
| Database | MySQL (CTEs, window functions, views, foreign keys, indexing) |
| ETL / Data Wrangling | Python, Pandas, SQLAlchemy |
| Statistics | SciPy (chi-square tests, two-proportion z-test) |
| Visualization | Power BI, Matplotlib, Seaborn |
| Spreadsheet Analysis | Excel (pivot tables, VLOOKUP/INDEX-MATCH, conditional formatting) |
| GenAI | Google Gemini API |
| Notebook | Jupyter |

---

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — ~99,000 orders (2016–2018), 9 relational tables (orders, customers, sellers, products, payments, reviews, geolocation).

---

## Repository Structure

```
├── sql/
│   ├── 01_schema.sql                    # Database schema (9 tables, FKs, indexes)
│   ├── 02_module1_analytics.sql         # GMV, seller ranking, cohort retention, RFM, views
│   └── 03_root_cause_retention.sql      # Root-cause hypothesis queries
├── scripts/
│   ├── load_data.py                     # CSV → MySQL ETL pipeline
│   ├── stats_analysis.py                # Chi-square & z-test hypothesis testing
│   └── genai_insights.py                # Gemini API business insight generator
├── notebooks/
│   └── olist_root_cause_analysis.ipynb  # Full analysis with visuals (Matplotlib/Seaborn)
├── dashboard/
│   └── olist_dashboard.pbix             # Power BI dashboard
├── excel/
│   └── Olist_Excel_Analysis.xlsx        # Pivot tables, VLOOKUP, conditional formatting
├── data/raw/                            # Raw CSVs (not committed — see setup below)
├── root_cause_writeup.md                # Full investigation write-up
├── .env.example                         # Environment variable template
└── README.md
```

---

## Setup & Reproduction

**1. Clone the repo**
```bash
git clone https://github.com/MayurDas24/Olist-E-Commerce-Performance-Retention-Analysis.git
cd Olist-E-Commerce-Performance-Retention-Analysis
```

**2. Download the dataset**
Get the CSVs from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place them in `data/raw/`.

**3. Set up Python environment**
```bash
python -m venv venv
venv\Scripts\activate          # Windows
pip install pandas numpy sqlalchemy mysql-connector-python scipy statsmodels matplotlib seaborn jupyter python-dotenv google-genai
```

**4. Configure environment variables**
```bash
cp .env.example .env
# Edit .env with your MySQL credentials and Gemini API key
```

**5. Create the MySQL database and schema**
```sql
CREATE DATABASE olist_ecommerce;
```
Then run `sql/01_schema.sql` in MySQL Workbench.

**6. Load the data**
```bash
python scripts/load_data.py
```

**7. Run the analytics**
```sql
-- Run in MySQL Workbench:
sql/02_module1_analytics.sql
sql/03_root_cause_retention.sql
```
```bash
# Statistical validation:
python scripts/stats_analysis.py

# GenAI insight summary:
python scripts/genai_insights.py
```

**8. Explore the notebook**
```bash
jupyter notebook notebooks/olist_root_cause_analysis.ipynb
```

**9. Open the dashboard**
Open `dashboard/olist_dashboard.pbix` in Power BI Desktop.

---

## Key SQL Techniques Demonstrated
- Window functions: `RANK()`, `LAG()`, `NTILE()`, `ROW_NUMBER()`
- CTEs (including multi-layered/nested CTEs for cohort analysis)
- Views for BI-tool consumption
- Foreign-key-constrained relational schema with indexing for query performance
- RFM customer segmentation

## Key Statistical Techniques Demonstrated
- Chi-square test of independence (categorical vs categorical)
- Two-proportion z-test
- Hypothesis testing with explicit significance thresholds (α = 0.05)
- Effect size interpretation alongside statistical significance (avoiding the "significant but trivial" trap)

---

## Author

**Mayur R Das**
[GitHub](https://github.com/MayurDas24) · [LinkedIn](https://linkedin.com/in/mayurrdas24)
