# 🛒 Marketplace Intelligence & Customer Retention Analytics Platform

> End-to-end Business Analytics project that analyzes marketplace performance, investigates customer retention drivers, and generates executive insights using **MySQL, Python, Advanced SQL, Power BI, Statistics, and Generative AI**.

![SQL](https://img.shields.io/badge/SQL-Advanced-blue)
![MySQL](https://img.shields.io/badge/MySQL-Database-orange)
![Python](https://img.shields.io/badge/Python-Analytics-yellow)
![Power BI](https://img.shields.io/badge/PowerBI-Dashboard-green)
![SciPy](https://img.shields.io/badge/Statistics-SciPy-blueviolet)
![Gemini](https://img.shields.io/badge/GenAI-Gemini-red)

---

# 📌 Business Problem

Customer retention is one of the biggest challenges for e-commerce platforms.

Despite processing **99K+ orders**, only **3% of customers** make a repeat purchase.

This project identifies the business drivers behind low retention through SQL analytics, statistical hypothesis testing, interactive dashboards, and AI-generated executive recommendations.

---

# 🚀 Tech Stack

| Layer | Technologies |
|--------|--------------|
| Database | MySQL |
| ETL | Python, Pandas, SQLAlchemy |
| Analytics | SQL, Window Functions, CTEs |
| Statistics | SciPy, Statsmodels |
| Dashboard | Power BI |
| AI | Google Gemini |
| Tools | Jupyter Notebook, VS Code |

---

# 🏗 Architecture

```text
CSV Dataset
      │
      ▼
Python ETL
      │
      ▼
MySQL Database
      │
      ▼
Advanced SQL Analytics
      │
 ┌────┼──────────────┐
 ▼    ▼              ▼
Power BI   Statistics   Gemini AI
Dashboard    (SciPy)    Executive Insights
```

---

# 📊 Key Insights

- 📦 Processed **99K+ marketplace orders**
- 👥 Analyzed **93K+ customers**
- 🏪 Evaluated seller and category performance
- 📉 Identified **3% repeat purchase rate**
- 📈 Validated business hypotheses using statistical testing
- 🤖 Generated AI-powered executive summaries

---

# 🔍 Business Questions Answered

- How is GMV changing over time?
- Which product categories generate maximum revenue?
- Which sellers contribute most to marketplace performance?
- Why is customer retention only 3%?
- Does delivery performance affect repeat purchases?
- Does customer satisfaction influence retention?
- Which business actions should leadership prioritize?

---

# 📂 Project Structure

```text
.
├── dashboard/
├── data/
├── notebooks/
├── scripts/
├── sql/
├── .env.example
├── requirements.txt
└── README.md
```

---

# ▶️ Getting Started

```bash
git clone https://github.com/MayurDas24/Olist-E-Commerce-Performance-Retention-Analysis.git

cd Olist-E-Commerce-Performance-Retention-Analysis

python -m venv venv

venv\Scripts\activate

pip install -r requirements.txt
```

Configure your `.env`

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=olist_ecommerce

GEMINI_API_KEY=your_api_key
```

Run:

```bash
python scripts/load_data.py
python scripts/stats_analysis.py
python scripts/genai_insights.py
```

Open:

```
dashboard/olist_dashboard.pbix
```

---

# 💡 Skills Demonstrated

- Business Analytics
- SQL & Database Design
- ETL Pipelines
- Advanced SQL
- Statistical Hypothesis Testing
- Data Storytelling
- Dashboard Development
- Generative AI Integration

---

# 👨‍💻 Author

**Mayur R Das**

GitHub: https://github.com/MayurDas24

LinkedIn: https://linkedin.com/in/mayurrdas24
