-- 2. Profit Leakage & Discount Tiers Analysis (using CASE statements and side-by-side aggregations).
WITH category_discount_tiers AS (
SELECT p."Category" ,
CASE 
	WHEN od."Discount" > 0.2 THEN 'High Discount (>20%)'
	ELSE 'Stander Discount (<=20%)'
END AS discount_tier ,
od."Revenue",
od."Profit" 
FROM products p 
INNER JOIN order_details od ON p."ProductID" = od."ProductID"
)

SELECT "Category" ,discount_tier ,
round(SUM("Revenue")::numeric,2) AS total_revenue ,
round(SUM("Profit")::NUMERIC,2) AS total_profit,
round((SUM("Profit")/SUM("Revenue")*100)::numeric,2) AS profit_margin_pct
FROM category_discount_tiers
GROUP BY "Category",discount_tier
ORDER BY "Category"