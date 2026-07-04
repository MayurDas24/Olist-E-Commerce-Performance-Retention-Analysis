"""
stats_analysis.py
Module 2: Statistical validation of the root-cause findings from Module 3.

Tests whether category, delivery lateness, review score, and geography
are STATISTICALLY SIGNIFICANT drivers of repeat purchase, not just
different-looking percentages.

Usage: python scripts/stats_analysis.py
"""

import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus
from scipy import stats
import numpy as np
import os
from dotenv import load_dotenv

# ------------------------------------------------------------
# DB CONNECTION — reads from .env (never hardcode real credentials)
# ------------------------------------------------------------
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

encoded_password = quote_plus(DB_PASSWORD)
engine = create_engine(
    f"mysql+mysqlconnector://{DB_USER}:{encoded_password}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)


def print_section(title):
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


# ============================================================
# TEST 1: Delivery lateness vs repeat purchase
# Chi-square test of independence on a 2x2 contingency table
# ============================================================
def test_delivery_lateness():
    print_section("TEST 1: Delivery Lateness vs Repeat Purchase")

    query = """
    WITH first_order AS (
        SELECT
            c.customer_unique_id,
            o.order_id,
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date,
            ROW_NUMBER() OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp
            ) AS order_rank
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.order_status = 'delivered'
    ),
    first_order_only AS (
        SELECT
            customer_unique_id,
            CASE
                WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'Late' ELSE 'On-time'
            END AS delivery_experience
        FROM first_order
        WHERE order_rank = 1
    ),
    customer_order_counts AS (
        SELECT
            c.customer_unique_id,
            COUNT(DISTINCT o.order_id) AS num_orders
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.order_status = 'delivered'
        GROUP BY c.customer_unique_id
    )
    SELECT
        fo.delivery_experience,
        CASE WHEN coc.num_orders > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type
    FROM first_order_only fo
    JOIN customer_order_counts coc ON fo.customer_unique_id = coc.customer_unique_id
    """

    df = pd.read_sql(query, con=engine)
    contingency = pd.crosstab(df["delivery_experience"], df["customer_type"])
    print("\nContingency table:")
    print(contingency)

    chi2, p_value, dof, expected = stats.chi2_contingency(contingency)
    print(f"\nChi-square statistic: {chi2:.4f}")
    print(f"p-value: {p_value:.6f}")
    print(f"Degrees of freedom: {dof}")

    alpha = 0.05
    if p_value < alpha:
        print(f"\n=> STATISTICALLY SIGNIFICANT (p < {alpha}).")
        print("   Delivery lateness IS associated with repeat purchase,")
        print("   though the earlier percentage gap (3.05% vs 2.49%) shows the effect size is small.")
    else:
        print(f"\n=> NOT statistically significant (p >= {alpha}).")
        print("   The observed gap could be due to random chance.")


# ============================================================
# TEST 2: Review score vs repeat purchase
# Chi-square test on a 5x2 contingency table
# ============================================================
def test_review_score():
    print_section("TEST 2: First-Order Review Score vs Repeat Purchase")

    query = """
    WITH first_order AS (
        SELECT
            c.customer_unique_id,
            o.order_id,
            ROW_NUMBER() OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp
            ) AS order_rank
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.order_status = 'delivered'
    ),
    first_order_review AS (
        SELECT fo.customer_unique_id, r.review_score
        FROM first_order fo
        JOIN order_reviews r ON fo.order_id = r.order_id
        WHERE fo.order_rank = 1
    ),
    customer_order_counts AS (
        SELECT
            c.customer_unique_id,
            COUNT(DISTINCT o.order_id) AS num_orders
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.order_status = 'delivered'
        GROUP BY c.customer_unique_id
    )
    SELECT
        fr.review_score,
        CASE WHEN coc.num_orders > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type
    FROM first_order_review fr
    JOIN customer_order_counts coc ON fr.customer_unique_id = coc.customer_unique_id
    """

    df = pd.read_sql(query, con=engine)
    contingency = pd.crosstab(df["review_score"], df["customer_type"])
    print("\nContingency table:")
    print(contingency)

    chi2, p_value, dof, expected = stats.chi2_contingency(contingency)
    print(f"\nChi-square statistic: {chi2:.4f}")
    print(f"p-value: {p_value:.6f}")
    print(f"Degrees of freedom: {dof}")

    alpha = 0.05
    if p_value < alpha:
        print(f"\n=> STATISTICALLY SIGNIFICANT (p < {alpha}), but note effect size:")
        print("   with ~93K customers, even a trivial difference can be statistically")
        print("   significant. Compare the % spread (2.96%-3.32%) to judge practical relevance.")
    else:
        print(f"\n=> NOT statistically significant (p >= {alpha}).")
        print("   Review score does NOT meaningfully predict repeat purchase.")


# ============================================================
# TEST 3: Category vs repeat purchase (the headline finding)
# Chi-square test on an NxM contingency table
# ============================================================
def test_category():
    print_section("TEST 3: Product Category vs Repeat Purchase (headline finding)")

    query = """
    WITH first_order AS (
        SELECT
            c.customer_unique_id,
            o.order_id,
            ROW_NUMBER() OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp
            ) AS order_rank
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.order_status = 'delivered'
    ),
    first_order_category AS (
        SELECT DISTINCT
            fo.customer_unique_id,
            ct.product_category_name_english AS category
        FROM first_order fo
        JOIN order_items oi ON fo.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        JOIN category_translation ct ON p.product_category_name = ct.product_category_name
        WHERE fo.order_rank = 1
    ),
    customer_order_counts AS (
        SELECT
            c.customer_unique_id,
            COUNT(DISTINCT o.order_id) AS num_orders
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.order_status = 'delivered'
        GROUP BY c.customer_unique_id
    )
    SELECT
        foc.category,
        CASE WHEN coc.num_orders > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type
    FROM first_order_category foc
    JOIN customer_order_counts coc ON foc.customer_unique_id = coc.customer_unique_id
    """

    df = pd.read_sql(query, con=engine)

    # Keep only categories with enough volume (matches the SQL HAVING >= 100 filter)
    category_counts = df["category"].value_counts()
    valid_categories = category_counts[category_counts >= 100].index
    df = df[df["category"].isin(valid_categories)]

    contingency = pd.crosstab(df["category"], df["customer_type"])
    chi2, p_value, dof, expected = stats.chi2_contingency(contingency)

    print(f"\nNumber of categories tested: {contingency.shape[0]}")
    print(f"Chi-square statistic: {chi2:.4f}")
    print(f"p-value: {p_value:.10f}")
    print(f"Degrees of freedom: {dof}")

    alpha = 0.05
    if p_value < alpha:
        print(f"\n=> STATISTICALLY SIGNIFICANT (p < {alpha}).")
        print("   Category IS a real, significant driver of repeat purchase —")
        print("   confirming this is the strongest lever identified in the analysis.")
    else:
        print(f"\n=> NOT statistically significant (p >= {alpha}).")


# ============================================================
# TEST 4: Two-proportion z-test — cleanest way to present the
# delivery lateness gap for a stakeholder (simpler than chi-square)
# ============================================================
def two_proportion_ztest(success1, n1, success2, n2, label1="Group 1", label2="Group 2"):
    p1 = success1 / n1
    p2 = success2 / n2
    p_pool = (success1 + success2) / (n1 + n2)
    se = np.sqrt(p_pool * (1 - p_pool) * (1 / n1 + 1 / n2))
    z = (p1 - p2) / se
    p_value = 2 * (1 - stats.norm.cdf(abs(z)))

    print(f"\n{label1}: {p1*100:.2f}% (n={n1})")
    print(f"{label2}: {p2*100:.2f}% (n={n2})")
    print(f"Z-statistic: {z:.4f}")
    print(f"p-value: {p_value:.6f}")
    return z, p_value


if __name__ == "__main__":
    test_delivery_lateness()
    test_review_score()
    test_category()

    print_section("TEST 4: Two-Proportion Z-Test (On-time vs Late) — using known numbers")
    # Plug in the numbers from your Module 3 SQL results:
    # On-time: 2612 repeat out of 85756 | Late: 189 repeat out of 7602
    two_proportion_ztest(
        success1=2612, n1=85756, label1="On-time",
        success2=189, n2=7602, label2="Late"
    )

    print("\n\nAll statistical tests complete.")