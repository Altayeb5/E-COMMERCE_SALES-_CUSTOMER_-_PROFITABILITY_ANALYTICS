-- 1. Pareto 80/20 Customer Analysis (using CTEs & Window running totals)
WITH customer_performance AS (
    SELECT 
        c."CustomerID",
        c."CustomerName",
        SUM(od."Revenue") AS total_revenue,
        SUM(od."Profit") AS total_profit
    FROM customers c
    INNER JOIN orders o ON c."CustomerID" = o."CustomerID"
    INNER JOIN order_details od ON o."OrderID" = od."OrderID"
    GROUP BY c."CustomerID", c."CustomerName"
),
customer_cumulative AS (
SELECT 
        "CustomerID",
        "CustomerName",
        total_revenue,
        total_profit,
        SUM(total_revenue) OVER (
            ORDER BY total_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_revenue,
        SUM(total_revenue) OVER () AS grand_total
    FROM customer_performance)

SELECT 
    "CustomerID",
    "CustomerName",
    ROUND(total_revenue::numeric, 2) AS total_revenue,
    ROUND(running_revenue::numeric, 2) AS running_revenue,
    Round((total_revenue/ grand_total*100)::numeric,2) AS revenue_pct,
    Round((running_revenue / grand_total *100)::numeric,2) AS cumulative_revenue_pct
FROM customer_cumulative
ORDER BY total_revenue DESC