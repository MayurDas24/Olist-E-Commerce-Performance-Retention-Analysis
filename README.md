# 🛒 Marketplace Intelligence & Customer Retention Analytics Platform

> End-to-End Business Analytics Pipeline built using **MySQL, Python, Advanced SQL, Statistics, Power BI, and Generative AI** to diagnose customer retention challenges and generate executive-level business recommendations for a large-scale e-commerce marketplace.

![SQL](https://img.shields.io/badge/SQL-Advanced-blue)
![MySQL](https://img.shields.io/badge/MySQL-Database-orange)
![Python](https://img.shields.io/badge/Python-Analytics-yellow)
![Power BI](https://img.shields.io/badge/PowerBI-Dashboard-green)
![SciPy](https://img.shields.io/badge/SciPy-Statistics-blueviolet)
![Gemini](https://img.shields.io/badge/GenAI-Gemini-red)

---

# 📌 Business Problem

Customer acquisition is expensive.

Retaining an existing customer is significantly cheaper and contributes far more to long-term business growth.

Despite processing **99,000+ customer orders**, the marketplace records only a **3% repeat purchase rate**, indicating a major customer retention challenge.

Rather than simply creating dashboards, this project investigates the underlying business drivers behind poor customer retention using statistical validation and converts those findings into actionable recommendations for business stakeholders.

---

# 🎯 Project Objective

Build an end-to-end analytics pipeline capable of:

- Engineering raw transactional data into an analytical database
- Measuring marketplace performance through business KPIs
- Investigating the drivers behind low customer retention
- Statistically validating business hypotheses
- Building executive dashboards
- Generating AI-powered executive summaries and recommendations

---

# 📊 Executive Summary

| Metric | Value |
|---------|-------|
| Orders | **99,441** |
| Customers | **93,358** |
| Sellers | **3,095** |
| Products | **32,951** |
| Tables | **9 Relational Tables** |
| Repeat Purchase Rate | **3.00%** |

---

# ❓ Business Questions Answered

This project answers several real-world marketplace questions:

- How is Gross Merchandise Value (GMV) changing over time?
- Which product categories generate the highest revenue?
- Which sellers contribute most to marketplace performance?
- Why do only 3% of customers make another purchase?
- Does delivery performance influence customer retention?
- Does customer satisfaction affect repeat purchases?
- Which product categories create loyal customers?
- Are some geographic regions more likely to retain customers?
- Which business initiatives should leadership prioritize?

---

# 🏗 End-to-End Architecture

```text
                    Kaggle Olist Dataset
                           │
                           ▼
                 Python ETL (Pandas)
                           │
                           ▼
                 MySQL Relational Database
             (9 Tables + Foreign Keys + Indexes)
                           │
                           ▼
                 Advanced SQL Analytics
       (CTEs • Window Functions • Views • Ranking)
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
  Power BI Dashboard   Statistical Tests   Gemini AI
       │                  (SciPy)          Decision Engine
        └──────────────────┼──────────────────┘
                           ▼
              Executive Business Recommendations
```

---

# 🔍 Analytics Methodology

The project follows a structured analytics workflow.

### 1. Data Engineering

- Load raw CSV datasets
- Build relational schema
- Configure foreign keys
- Create analytical indexes
- Data quality validation

---

### 2. SQL Analytics

Business KPIs calculated:

- GMV
- Revenue
- Average Order Value
- Monthly Sales Trend
- Seller Performance
- Category Performance
- Customer Retention
- Cancellation Rate
- Delivery Performance

Advanced SQL techniques:

- Window Functions
- CTEs
- Nested Queries
- Views
- Ranking
- Aggregations
- Joins
- Indexing

---

### 3. Root Cause Investigation

Instead of stopping at descriptive analytics, the project investigates **why** customer retention is low.

The following hypotheses were tested.

| Hypothesis | Statistical Result | Business Conclusion |
|------------|-------------------|--------------------|
| Delivery delays reduce repeat purchase | Significant but small effect | Low business priority |
| Review score drives retention | No significant relationship | Not a primary driver |
| Product category influences retention | Strong statistical relationship | Highest business priority |
| Geography affects repeat purchase | Moderate effect | Region-specific strategies |

---

# 📈 Key Business Findings

## Overall Repeat Purchase Rate

**3.00%**

Only **2,801 customers** placed more than one order.

---

## Most Important Finding

Customer retention is primarily **category-driven**, not driven by logistics or review scores.

Some categories generate customers who naturally purchase again, while others behave as one-time purchases.

---

## Business Implication

Rather than investing heavily in delivery improvements, marketplace teams should focus on:

- Personalized re-engagement campaigns
- Category-specific cross-selling
- Product recommendations
- Loyalty initiatives
- Repeat purchase incentives

---

# 📊 Dashboard Overview

The Power BI dashboard includes:

- 📈 Monthly GMV Trend
- 🏪 Seller Performance Scorecard
- 📦 Top Revenue Categories
- 📊 Repeat Purchase KPI
- 📉 Cancellation Analysis
- 🤖 AI Executive Summary

> *(Dashboard screenshots will be added here)*

---

# 🤖 AI Decision Engine

Instead of displaying raw KPIs, the project uses **Google Gemini** to generate executive-ready business insights.

Input:

- GMV
- Category Performance
- Seller KPIs
- Customer Retention
- Cancellation Rate

Output:

- Executive Summary
- Business Impact
- Strategic Recommendations
- Decision Priorities

Example:

> Customer retention remains critically low at 3%. Statistical analysis indicates that product category has the strongest influence on repeat purchases, while delivery performance contributes only marginally. Leadership should prioritize category-specific retention campaigns and personalized cross-selling strategies to improve long-term customer value.

---

# 💡 Business Recommendations

| Recommendation | Expected Impact | Priority |
|---------------|----------------|----------|
| Category-specific cross-selling | ⭐⭐⭐⭐⭐ | High |
| Personalized re-engagement campaigns | ⭐⭐⭐⭐⭐ | High |
| Loyalty program for repeat-friendly categories | ⭐⭐⭐⭐ | Medium |
| Improve seller cancellation rates | ⭐⭐⭐ | Medium |
| Delivery optimization | ⭐⭐ | Low |

---

# 🛠 Tech Stack

| Layer | Technologies |
|--------|--------------|
| Database | MySQL |
| ETL | Python, Pandas, SQLAlchemy |
| Analytics | Advanced SQL |
| Statistics | SciPy, Statsmodels |
| Dashboard | Power BI |
| AI | Google Gemini |
| Environment | VS Code, Jupyter Notebook |

---

# 📂 Project Structure

```
Marketplace-Intelligence-Retention-Analytics/
│
├── dashboard/
│   └── olist_dashboard.pbix
│
├── data/
│   └── raw/
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
├── .env.example
├── README.md
└── requirements.txt
```

---

# 🚀 Getting Started

## Clone Repository

```bash
git clone https://github.com/MayurDas24/Olist-E-Commerce-Performance-Retention-Analysis.git

cd Olist-E-Commerce-Performance-Retention-Analysis
```

## Create Virtual Environment

```bash
python -m venv venv

venv\Scripts\activate
```

## Install Dependencies

```bash
pip install -r requirements.txt
```

## Configure Environment

Create a `.env`

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=olist_ecommerce

GEMINI_API_KEY=your_api_key
```

---

## Run Project

Create database

```sql
CREATE DATABASE olist_ecommerce;
```

Execute

```
sql/01_schema.sql
```

Load Data

```bash
python scripts/load_data.py
```

Execute SQL analytics

```
sql/02_module1_analytics.sql

sql/03_root_cause_retention.sql
```

Run statistical analysis

```bash
python scripts/stats_analysis.py
```

Generate AI insights

```bash
python scripts/genai_insights.py
```

Open

```
dashboard/olist_dashboard.pbix
```

using Power BI Desktop.

---

# 🎯 Skills Demonstrated

- Business Analytics
- Product Analytics
- Data Engineering
- SQL Optimization
- Data Modeling
- Window Functions
- Common Table Expressions
- Dashboard Design
- Statistical Hypothesis Testing
- ETL Development
- Data Storytelling
- Executive Reporting
- Generative AI Integration

---

# 🚀 Future Improvements

- Customer Lifetime Value (CLV) Analysis
- Seller Health Score
- Customer Segmentation Dashboard
- Demand Forecasting Module
- Automated PDF Executive Reports
- Interactive AI Business Assistant

---

# 👨‍💻 Author

**Mayur R Das**

GitHub: https://github.com/MayurDas24

LinkedIn: https://linkedin.com/in/mayurrdas24

---

⭐ If you found this project interesting, consider giving it a star!
