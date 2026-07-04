-- ============================================================
-- MODULE 1: Core SQL Analytics
-- Olist E-Commerce Database
-- Covers: GMV analysis, Seller ranking, Cohort retention, RFM segmentation
-- ============================================================

USE olist_ecommerce;

-- ============================================================
-- SECTION A: GMV / REVENUE ANALYSIS
-- ============================================================

-- A1. Overall GMV (delivered orders only — cancelled/unavailable orders
--     don't count as realized revenue)
SELECT
    ROUND(SUM(oi.price), 2)          AS total_product_revenue,
    ROUND(SUM(oi.freight_value), 2)  AS total_freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_gmv,
    COUNT(DISTINCT o.order_id)       AS total_delivered_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


-- A2. Monthly GMV trend with Month-over-Month growth %
--     (window function: LAG to compare against previous month)
WITH monthly_gmv AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS gmv
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)
SELECT
    order_month,
    gmv,
    LAG(gmv) OVER (ORDER BY order_month) AS prev_month_gmv,
    ROUND(
        (gmv - LAG(gmv) OVER (ORDER BY order_month))
        / LAG(gmv) OVER (ORDER BY order_month) * 100, 2
    ) AS mom_growth_pct
FROM monthly_gmv
ORDER BY order_month;


-- A3. GMV by product category (English names), ranked
--     (window function: RANK)
SELECT
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gmv,
    COUNT(DISTINCT oi.order_id) AS num_orders,
    RANK() OVER (ORDER BY SUM(oi.price + oi.freight_value) DESC) AS category_rank
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY gmv DESC;


-- A4. GMV by customer state (region performance)
SELECT
    c.customer_state,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gmv,
    COUNT(DISTINCT o.order_id) AS num_orders,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY gmv DESC;


-- ============================================================
-- SECTION B: SELLER PERFORMANCE RANKING
-- ============================================================

-- B1. Full seller scorecard: revenue, order volume, late delivery %,
--     avg review score, cancellation rate — ranked by revenue
WITH seller_orders AS (
    SELECT
        s.seller_id,
        s.seller_state,
        o.order_id,
        o.order_status,
        oi.price,
        oi.freight_value,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END AS is_late
    FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN orders o ON oi.order_id = o.order_id
),
seller_reviews AS (
    SELECT
        oi.seller_id,
        AVG(r.review_score) AS avg_review_score
    FROM order_items oi
    JOIN order_reviews r ON oi.order_id = r.order_id
    GROUP BY oi.seller_id
)
SELECT
    so.seller_id,
    so.seller_state,
    COUNT(DISTINCT so.order_id) AS total_orders,
    ROUND(SUM(so.price + so.freight_value), 2) AS total_revenue,
    ROUND(SUM(so.is_late) / COUNT(DISTINCT so.order_id) * 100, 2) AS late_delivery_pct,
    ROUND(
        SUM(CASE WHEN so.order_status = 'canceled' THEN 1 ELSE 0 END)
        / COUNT(DISTINCT so.order_id) * 100, 2
    ) AS cancellation_pct,
    ROUND(sr.avg_review_score, 2) AS avg_review_score,
    RANK() OVER (ORDER BY SUM(so.price + so.freight_value) DESC) AS revenue_rank
FROM seller_orders so
LEFT JOIN seller_reviews sr ON so.seller_id = sr.seller_id
GROUP BY so.seller_id, so.seller_state, sr.avg_review_score
ORDER BY total_revenue DESC;


-- B2. Worst performing sellers (high return-risk signal):
--     highest cancellation % among sellers with meaningful order volume
WITH seller_stats AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY oi.seller_id
)
SELECT
    seller_id,
    total_orders,
    canceled_orders,
    ROUND(canceled_orders / total_orders * 100, 2) AS cancellation_pct
FROM seller_stats
WHERE total_orders >= 20          -- filter out low-volume noise
ORDER BY cancellation_pct DESC
LIMIT 20;


-- ============================================================
-- SECTION C: CUSTOMER COHORT RETENTION
-- ============================================================

-- C1. Monthly cohort retention: for each customer's first-purchase month,
--     what % of that cohort returned to purchase in subsequent months
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01')) AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
customer_orders AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort_activity AS (
    SELECT
        fp.cohort_month,
        co.order_month,
        TIMESTAMPDIFF(MONTH, fp.cohort_month, co.order_month) AS month_number,
        COUNT(DISTINCT co.customer_unique_id) AS active_customers
    FROM first_purchase fp
    JOIN customer_orders co ON fp.customer_unique_id = co.customer_unique_id
    GROUP BY fp.cohort_month, co.order_month
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS num_customers
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    ca.cohort_month,
    ca.month_number,
    ca.active_customers,
    cs.num_customers AS cohort_size,
    ROUND(ca.active_customers / cs.num_customers * 100, 2) AS retention_pct
FROM cohort_activity ca
JOIN cohort_size cs ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.month_number;


-- ============================================================
-- SECTION D: RFM SEGMENTATION
-- (Recency, Frequency, Monetary — window functions: NTILE)
-- ============================================================

WITH customer_rfm AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp) FROM orders),
            MAX(o.order_purchase_timestamp)
        ) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        -- NTILE splits customers into 5 buckets each — 5 = best, 1 = worst
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_rfm
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_total_score,
    CASE
        WHEN (recency_score + frequency_score + monetary_score) >= 13 THEN 'Champions'
        WHEN (recency_score + frequency_score + monetary_score) >= 10 THEN 'Loyal Customers'
        WHEN (recency_score + frequency_score + monetary_score) >= 7  THEN 'Potential Loyalists'
        WHEN (recency_score + frequency_score + monetary_score) >= 4  THEN 'At Risk'
        ELSE 'Lost'
    END AS customer_segment
FROM rfm_scored
ORDER BY rfm_total_score DESC;


-- ============================================================
-- SECTION E: SAVED VIEWS
-- (These will be used directly as Power BI data sources later)
-- ============================================================

CREATE OR REPLACE VIEW vw_monthly_gmv AS
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gmv,
    COUNT(DISTINCT o.order_id) AS num_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m');


CREATE OR REPLACE VIEW vw_seller_scorecard AS
SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(
        SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)
        / COUNT(DISTINCT o.order_id) * 100, 2
    ) AS late_delivery_pct,
    ROUND(
        SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END)
        / COUNT(DISTINCT o.order_id) * 100, 2
    ) AS cancellation_pct
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_state;


CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gmv,
    COUNT(DISTINCT oi.order_id) AS num_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english;