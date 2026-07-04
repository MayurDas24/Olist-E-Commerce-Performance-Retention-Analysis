"""
genai_insights.py
Module 5: GenAI Insight Generator

Pulls key KPIs from the MySQL database and asks Gemini to turn them
into a short, human-readable business insight -- instead of a raw
number like "Revenue = R$1.13M", it writes a sentence explaining
what happened and why it matters.

Usage: python scripts/genai_insights.py
"""

import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus
from google import genai
import os
from dotenv import load_dotenv

# ------------------------------------------------------------
# 1. CONFIG — reads from .env (never hardcode real credentials)
# ------------------------------------------------------------
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# ------------------------------------------------------------
# 2. DB CONNECTION
# ------------------------------------------------------------
encoded_password = quote_plus(DB_PASSWORD)
engine = create_engine(
    f"mysql+mysqlconnector://{DB_USER}:{encoded_password}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

client = genai.Client(api_key=GEMINI_API_KEY)
MODEL_NAME = "gemini-flash-lite-latest"


def get_kpi_snapshot():
    """Pull the key numbers we've already validated through the project."""

    # Last 2 months of GMV, to compute latest MoM change
    monthly_gmv = pd.read_sql(
        "SELECT * FROM vw_monthly_gmv ORDER BY order_month DESC LIMIT 2",
        con=engine
    )
    latest_month = monthly_gmv.iloc[0]
    prev_month = monthly_gmv.iloc[1]
    mom_change_pct = round(
        (latest_month["gmv"] - prev_month["gmv"]) / prev_month["gmv"] * 100, 2
    )

    # Top category by GMV
    top_category = pd.read_sql(
        "SELECT * FROM vw_category_performance ORDER BY gmv DESC LIMIT 1",
        con=engine
    ).iloc[0]

    # Worst seller by cancellation % (with meaningful volume)
    worst_seller = pd.read_sql(
        """
        SELECT * FROM vw_seller_scorecard
        WHERE total_orders >= 20
        ORDER BY cancellation_pct DESC
        LIMIT 1
        """,
        con=engine
    ).iloc[0]

    return {
        "latest_month": latest_month["order_month"],
        "latest_gmv": round(latest_month["gmv"], 2),
        "mom_change_pct": mom_change_pct,
        "top_category": top_category["category"],
        "top_category_gmv": round(top_category["gmv"], 2),
        "worst_seller_id": worst_seller["seller_id"],
        "worst_seller_cancellation_pct": worst_seller["cancellation_pct"],
        "repeat_purchase_rate": 3.00,   # from Module 3 findings
    }


def generate_insight(kpis):
    prompt = f"""
You are a business analyst writing a short executive summary for a monthly
e-commerce performance review. Use ONLY the numbers given below. Do not invent
any figures. Write 3-4 sentences, in plain business English, as if briefing
a senior manager. Be direct and specific, not generic.

Data:
- Latest month: {kpis['latest_month']}
- GMV this month: R${kpis['latest_gmv']:,}
- Month-over-month GMV change: {kpis['mom_change_pct']}%
- Top-performing category by GMV: {kpis['top_category']} (R${kpis['top_category_gmv']:,})
- Worst-performing seller by cancellation rate: seller {kpis['worst_seller_id']} at {kpis['worst_seller_cancellation_pct']}% cancellations (min. 20 orders)
- Overall customer repeat-purchase rate: {kpis['repeat_purchase_rate']}% (statistically confirmed to be driven mainly by product category, not delivery speed or review scores)

Write the summary now.
"""
    response = client.models.generate_content(
        model=MODEL_NAME,
        contents=prompt
    )
    return response.text


if __name__ == "__main__":
    print("Pulling KPI snapshot from MySQL...")
    kpis = get_kpi_snapshot()

    print("\nKPI Snapshot:")
    for k, v in kpis.items():
        print(f"  {k}: {v}")

    print("\nGenerating AI insight summary...")
    insight = generate_insight(kpis)

    print("\n" + "=" * 70)
    print("AI-GENERATED BUSINESS INSIGHT")
    print("=" * 70)
    print(insight)