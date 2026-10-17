-- 3. Sub-Category Return Rates & Lost Revenue Analysis (using LEFT JOIN, conditional aggregation, and RANK() OVER()).
WITH product_return AS (
SELECT p."SubCategory" ,od."Quantity" ,od."Revenue" ,od."Profit" ,r."ReturnID" 
FROM products p 
INNER JOIN order_details od ON p."ProductID" = od."ProductID" 
LEFT JOIN "returns" r ON od."DetailID" = r."DetailID" ),

subcategory_summary AS (
SELECT "SubCategory" ,
SUM(CASE WHEN "ReturnID" IS NOT NULL THEN "Quantity" ELSE 0 END) AS  returned_quantity,

round(SUM(CASE WHEN "ReturnID" IS NOT NULL THEN "Revenue" ELSE 0 END)::numeric,2) AS lost_revenue ,

round((SUM(CASE WHEN "ReturnID" IS NOT NULL THEN "Quantity" ELSE 0 END) / SUM("Quantity" ) * 100),2) AS quantity_return_rate_pct,

SUM("Quantity") AS total_quantity ,round(SUM("Revenue")::numeric,2) AS total_revenue ,round(SUM("Profit")::numeric,2) AS total_profit
FROM product_return
GROUP BY "SubCategory"
)

SELECT "SubCategory",
    returned_quantity,
    total_quantity,
    quantity_return_rate_pct,
    lost_revenue,
    total_revenue,
    total_profit,
    rank() OVER (ORDER BY quantity_return_rate_pct DESC) AS return_rank
FROM subcategory_summary