-- ============================================================
-- MODULE 3: Root-Cause Investigation
-- Question: Why is repeat purchase rate so low, and what drives it?
-- ============================================================

USE olist_ecommerce;

-- ============================================================
-- STEP 1: Confirm the headline number
-- What % of customers ever place a 2nd order?
-- ============================================================
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
-- STEP 2: HYPOTHESIS 1 — Does a late first delivery kill repeat purchase?
-- Compares repeat rate for customers whose FIRST order arrived late
-- vs on-time
-- ============================================================
WITH first_order AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
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
            THEN 'Late'
            ELSE 'On-time'
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
    COUNT(*) AS num_customers,
    SUM(CASE WHEN coc.num_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN coc.num_orders > 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS repeat_rate_pct
FROM first_order_only fo
JOIN customer_order_counts coc ON fo.customer_unique_id = coc.customer_unique_id
GROUP BY fo.delivery_experience;


-- ============================================================
-- STEP 3: HYPOTHESIS 2 — Does the FIRST order's review score
-- predict whether a customer comes back?
-- ============================================================
WITH first_order AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_rank
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
first_order_review AS (
    SELECT
        fo.customer_unique_id,
        r.review_score
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
    COUNT(*) AS num_customers,
    SUM(CASE WHEN coc.num_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN coc.num_orders > 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS repeat_rate_pct
FROM first_order_review fr
JOIN customer_order_counts coc ON fr.customer_unique_id = coc.customer_unique_id
GROUP BY fr.review_score
ORDER BY fr.review_score;


-- ============================================================
-- STEP 4: HYPOTHESIS 3 — Does repeat rate vary by first-purchase category?
-- (Are some categories inherently one-time-purchase items, e.g. furniture,
--  vs repeat-friendly categories, e.g. health & beauty consumables?)
-- ============================================================
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
    COUNT(*) AS num_customers,
    SUM(CASE WHEN coc.num_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN coc.num_orders > 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS repeat_rate_pct
FROM first_order_category foc
JOIN customer_order_counts coc ON foc.customer_unique_id = coc.customer_unique_id
GROUP BY foc.category
HAVING COUNT(*) >= 100        -- filter out tiny categories for statistical noise
ORDER BY repeat_rate_pct DESC;


-- ============================================================
-- STEP 5: HYPOTHESIS 4 — Does repeat rate vary by customer state?
-- (Is this a logistics/regional issue, e.g. worse in far-flung states?)
-- ============================================================
WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS num_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id, c.customer_state
)
SELECT
    customer_state,
    COUNT(*) AS num_customers,
    SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS repeat_rate_pct
FROM customer_order_counts
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY repeat_rate_pct DESC;