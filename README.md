# 🛒 Seller & GMV Performance Intelligence System

### End-to-End Business Analytics Pipeline | MySQL • Python • Power BI • Statistics • GenAI

[![SQL](https://img.shields.io/badge/SQL-MySQL-blue)]()
[![Python](https://img.shields.io/badge/Python-Pandas%20%7C%20SciPy-blue)]()
[![PowerBI](https://img.shields.io/badge/Dashboard-Power%20BI-yellow)]()
[![Gemini](https://img.shields.io/badge/GenAI-Gemini-green)]()

---

## 📌 Overview

This project investigates one fundamental business question:

> **Why do only 3% of Olist customers make a second purchase, and what actually drives customer retention?**

Instead of building another KPI dashboard, this project performs a complete analytics workflow:

- Data Engineering
- SQL Analytics
- Statistical Hypothesis Testing
- Power BI Dashboard
- AI-generated Executive Insights

The goal is to move beyond reporting and identify **actionable business drivers** using data.

---

# 🚀 Key Business Findings

### Overall Repeat Purchase Rate

> **3.00%**
> (2,801 repeat customers out of 93,358)

---

### Root Cause Analysis

| Hypothesis | Result | p-value |
|------------|--------|---------|
| Delivery Lateness | Small impact | 0.007 |
| Review Score | ❌ No significant relationship | 0.139 |
| Product Category | ✅ Strongest driver (~5x variation) | <0.001 |
| Customer Geography | Moderate effect | Significant |

### Business Conclusion

The retention problem is **category-driven**, not a logistics or customer satisfaction problem.

Instead of investing heavily in delivery improvements, Olist would likely gain more value from:

- Category-specific cross-selling
- Personalized re-engagement campaigns
- Product-focused retention strategies

---

# 📊 Dashboard

The Power BI dashboard includes:

- 📈 Monthly GMV Trend
- 📦 Top Categories by Revenue
- 🏪 Seller Performance Scorecard
- 🤖 AI Business Summary

---

# 🏗 Project Architecture

```
Kaggle Dataset (CSV)
        │
        ▼
Python ETL (Pandas)
        │
        ▼
MySQL Relational Database
(9 Tables + Foreign Keys)
        │
        ▼
Advanced SQL Analytics
(CTEs • Window Functions • Views)
        │
 ┌──────┼──────────────┐
 ▼      ▼              ▼
Power BI    Statistics    Gemini AI
Dashboard   (SciPy)      Executive Summary
```

---

# ⚙ Tech Stack

| Layer | Technologies |
|--------|--------------|
| Database | MySQL |
| ETL | Python, Pandas, SQLAlchemy |
| Analytics | SQL, Window Functions, CTEs |
| Statistics | SciPy, Statsmodels |
| Visualization | Power BI, Matplotlib |
| AI | Google Gemini API |
| Notebook | Jupyter |

---

# 📂 Project Structure

```
.
├── dashboard/
│   └── olist_dashboard.pbix
│
├── notebooks/
│   └── olist_root_cause_analysis.ipynb
│
├── scripts/
│   ├── load_data.py
│   ├── stats_analysis.py
│   └── genai_insights.py
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_module1_analytics.sql
│   └── 03_root_cause_retention.sql
│
├── data/
│   └── raw/
│
├── root_cause_writeup.md
├── .env.example
└── README.md
```

---

# 🔍 Analytics Performed

### SQL

- Window Functions
- CTEs
- Nested CTEs
- Views
- Ranking
- Cohort Analysis
- RFM Segmentation
- Foreign Keys
- Indexing

---

### Statistical Validation

- Chi-Square Test
- Two-Proportion Z-Test
- Hypothesis Testing
- Effect Size Interpretation

---

# 🤖 GenAI Insight Generator

The project includes a Python script that:

- Reads KPIs directly from MySQL
- Sends them to Gemini
- Produces an executive-ready business summary

Example:

```
Monthly GMV declined 4.1% from the previous month.
Health & Beauty continues to generate the highest revenue.
Customer retention remains low (3%), suggesting significant opportunity
through category-specific retention campaigns.
```

---

# 📈 Dataset

**Brazilian E-Commerce Public Dataset by Olist**

- ~99,000 Orders
- 93,000+ Customers
- 9 Relational Tables
- 2016–2018

Dataset:

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

# 🚀 Getting Started

## Clone Repository

```bash
git clone https://github.com/MayurDas24/Olist-E-Commerce-Performance-Retention-Analysis.git

cd Olist-E-Commerce-Performance-Retention-Analysis
```

---

## Create Virtual Environment

```bash
python -m venv venv

venv\Scripts\activate
```

---

## Install Dependencies

```bash
pip install -r requirements.txt
```

---

## Configure Environment

Create a `.env`

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=olist_ecommerce

GEMINI_API_KEY=your_api_key
```

---

## Create Database

```sql
CREATE DATABASE olist_ecommerce;
```

Run

```
sql/01_schema.sql
```

---

## Load Dataset

```bash
python scripts/load_data.py
```

---

## Run SQL Analytics

Execute

```
sql/02_module1_analytics.sql

sql/03_root_cause_retention.sql
```

inside MySQL Workbench.

---

## Run Statistical Analysis

```bash
python scripts/stats_analysis.py
```

---

## Generate AI Insights

```bash
python scripts/genai_insights.py
```

---

## Open Dashboard

Open

```
dashboard/olist_dashboard.pbix
```

using Power BI Desktop.

---

# 💡 Skills Demonstrated

- Business Analytics
- SQL
- Data Modeling
- ETL
- Statistical Testing
- Dashboard Design
- AI Integration
- Data Storytelling

---

# 👨‍💻 Author

**Mayur R Das**

GitHub:
https://github.com/MayurDas24

LinkedIn:
https://linkedin.com/in/mayurrdas24

---

⭐ If you found this project useful, consider giving it a star!
