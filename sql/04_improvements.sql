-- ============================================================
-- IMPROVEMENT 3: Production-ready views
-- - Seller leaderboard filter baked into the view itself
-- - Live repeat-purchase-rate view (no more hardcoded "3.00%")
-- ============================================================

USE olist_ecommerce;

-- ------------------------------------------------------------
-- 3a. Seller scorecard, but only for sellers with meaningful
--     volume (>=20 orders). This replaces the manual Power BI
--     filter — the dashboard is now self-correct on refresh.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_seller_leaderboard AS
SELECT *
FROM vw_seller_scorecard
WHERE total_orders >= 20;


-- ------------------------------------------------------------
-- 3b. Live repeat-purchase-rate view — powers the dashboard
--     callout card with a real number instead of static text.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_repeat_purchase_rate AS
WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS num_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS repeat_rate_pct
FROM customer_order_counts;


-- ============================================================
-- IMPROVEMENT 2: Quantify the business impact
-- "If low-repeat categories were brought up to the overall
--  average repeat rate, what's the estimated GMV opportunity?"
-- ============================================================

-- Step 1: Get repeat rate + customer volume + avg order value per category
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
),
category_stats AS (
    SELECT
        foc.category,
        COUNT(*) AS num_customers,
        ROUND(SUM(CASE WHEN coc.num_orders > 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS repeat_rate_pct
    FROM first_order_category foc
    JOIN customer_order_counts coc ON foc.customer_unique_id = coc.customer_unique_id
    GROUP BY foc.category
    HAVING COUNT(*) >= 100
),
avg_order_value AS (
    -- Overall average order value, used to translate "extra orders" into revenue
    SELECT ROUND(AVG(oi.price + oi.freight_value), 2) AS aov
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
),
overall_rate AS (
    SELECT repeat_rate_pct AS overall_repeat_rate_pct
    FROM vw_repeat_purchase_rate
)
SELECT
    cs.category,
    cs.num_customers,
    cs.repeat_rate_pct AS current_repeat_rate_pct,
    ov.overall_repeat_rate_pct,
    -- Only categories BELOW the overall average have an "opportunity gap"
    GREATEST(ov.overall_repeat_rate_pct - cs.repeat_rate_pct, 0) AS repeat_rate_gap_pct,
    -- Estimated additional repeat customers if this category matched the overall average
    ROUND(cs.num_customers * GREATEST(ov.overall_repeat_rate_pct - cs.repeat_rate_pct, 0) / 100, 0) AS estimated_additional_repeat_customers,
    -- Estimated additional GMV (extra repeat customers x average order value)
    ROUND(
        cs.num_customers * GREATEST(ov.overall_repeat_rate_pct - cs.repeat_rate_pct, 0) / 100 * aov.aov,
        2
    ) AS estimated_additional_gmv
FROM category_stats cs
CROSS JOIN avg_order_value aov
CROSS JOIN overall_rate ov
WHERE cs.repeat_rate_pct < ov.overall_repeat_rate_pct   -- only below-average categories
ORDER BY estimated_additional_gmv DESC;