# 📊 Retail Profitability & Return Leakage Intelligence

<!--
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Pandas](https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Power BI](https://img.shields.io/badge/Power_BI-F2C94C?style=for-the-badge&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)]() -->

An end-to-end data analytics project uncovering discount margin erosion, return friction, and revenue leakage. Built using **Python (Pandas & SQLAlchemy)** for exploratory data analysis and database loading, **PostgreSQL** for query validation, and **Power BI** for executive dashboarding.

---

## 🔄 End-to-End Project Workflow

```text
  ┌────────────────────────┐      ┌────────────────────────┐      ┌────────────────────────┐
  │ 1. Python (EDA & ETL)  │ ───► │   2. PostgreSQL Engine │ ───► │  3. Power BI Dashboard │
  │ - Data Cleaning & EDA  │      │ - Advanced CTE Queries │      │ - Star Schema Modeling │
  │ - Outlier Detection    │      │ - Window Functions     │      │ - Dynamic DAX Measures │
  │ - SQLAlchemy Ingestion │      │ - Aggregation Truth    │      │ - Interactive Visuals  │
  └────────────────────────┘      └────────────────────────┘      └────────────────────────┘
```

---

## 🎯 Executive Summary & Key EDA Discoveries

Through initial Python exploratory analysis and subsequent BI modeling, three primary profit drivers were identified:

- **High Negative Profit Volume:** Initial EDA revealed that **32.6% of order detail lines were operating at a net loss**, triggering a deeper investigation into discount structures.
- **Discount Margin Erosion:** Orders discounted above **20%** drastically erode profit margins down to **-7.7%**, converting high transaction volumes into direct financial losses.
- **High Return Friction:** Total lost revenue due to returns reached **$621K** (4.7% return rate), led by **Binders (7.0%)** and **Laptops (6.9%)**.
- **Net Loss Sub-Categories:** **Accessories** (-$61.5K profit) and **Paper** (-$51.8K profit) operate at net negative margins due to compounding return costs.

---

## 🐍 Phase 1: Python EDA & Automated Database Pipeline

Python was used to inspect raw datasets, evaluate missing values, detect outliers via the Interquartile Range (IQR) method, and push cleaned tables into PostgreSQL via SQLAlchemy.

<details>
<summary><b>View Python Ingestion & EDA Script</b></summary>

```python
import pandas as pd
import numpy as np
from sqlalchemy import create_engine

# 1. Load Raw Datasets
df_customers = pd.read_csv("Datasets/customers.csv")
df_order_details = pd.read_csv("Datasets/order_details.csv")
df_orders = pd.read_csv("Datasets/orders.csv")
df_products = pd.read_csv("Datasets/products.csv")
df_returns = pd.read_csv("Datasets/returns.csv")

# 2. EDA: Negative Profit Percentage
df_merged = pd.merge(
    df_order_details,
    df_products[['ProductID', 'ProductName', 'Category', 'SubCategory', 'CostPrice']],
    on="ProductID",
    how="left"
)
df_negative_profit = df_merged[df_merged["Profit"] < 0]
pct_negative = (len(df_negative_profit) / len(df_merged)) * 100
print(f"Negative Profit Transaction Proportion: {pct_negative:.2f}%") # 32.60%

# 3. IQR Outlier Detection (Revenue & Quantity)
Q1_Rev, Q3_Rev = df_order_details["Revenue"].quantile([0.25, 0.75])
IQR_Rev = Q3_Rev - Q1_Rev
df_Rev_outliers = df_order_details[
    (df_order_details["Revenue"] > Q3_Rev + 1.5 * IQR_Rev) |
    (df_order_details["Revenue"] < Q1_Rev - 1.5 * IQR_Rev)
]

# 4. Create Master Pipeline Table & Standardize Types
df_master = df_order_details.merge(df_orders, on='OrderID', how='left') \
                            .merge(df_customers, on='CustomerID', how='left') \
                            .merge(df_products[['ProductID', 'ProductName', 'Category', 'SubCategory', 'CostPrice']], on='ProductID', how='left') \
                            .merge(df_returns[['DetailID', 'ReturnID', 'ReturnReason', 'ReturnDate']], on='DetailID', how='left')

df_master['IsReturned'] = df_master['ReturnID'].notna().astype(int)
df_master['OrderDate'] = pd.to_datetime(df_master['OrderDate'])

# 5. Database Pipeline via SQLAlchemy
engine = create_engine('postgresql://postgres:pass@localhost:port/apex_retail')

df_customers.to_sql('customers', engine, if_exists='replace', index=False)
df_products.to_sql('products', engine, if_exists='replace', index=False)
df_orders.to_sql('orders', engine, if_exists='replace', index=False)
df_order_details.to_sql('order_details', engine, if_exists='replace', index=False)
df_returns.to_sql('returns', engine, if_exists='replace', index=False)
print("All 5 tables successfully loaded into PostgreSQL database 'apex_retail'!")
```

</details>

---

## 🏗️ Data Architecture & Star Schema

In Power BI, tables were structured into an optimized **Star Schema** to enable flexible dynamic measure evaluation across dimensions:

```text
                  +-------------------+
                  |   dim_customers   |
                  +-------------------+
                            | 1
                            |
                            | N
                  +-------------------+
                  |    fact_orders    |
                  +-------------------+
                            | 1
                            |
                            | N
                  +-------------------+          +-------------------+
                  | fact_order_details|--------->|   dim_products    |
                  +-------------------+ N      1 +-------------------+
                            |
                            | 1
                  +-------------------+
                  |   fact_returns    |
                  +-------------------+
```

---

## 📂 Repository Structure

```text
├── Datasets/              # Raw CSV data sources
├── python/                # Python scripts for EDA & database ingestion
│   └── eda_and_loader.ipynb
├── sql/                   # PostgreSQL analytical scripts
│   ├── 01_pareto_analysis.sql
│   ├── 02_discount_leakage.sql
│   └── 03_return_rates.sql
├── powerbi/               # Power BI report files (.pbix)
│   └── Retail_Profitability_Dashboard.pbix
├── docs/                  # Dashboard screenshots
└── README.md              # Project documentation
```

---

## ⚡ Key DAX Measures

| Measure Name              | DAX Formula / Logic                                                                           | Business Context                               |
| :------------------------ | :-------------------------------------------------------------------------------------------- | :--------------------------------------------- |
| **Total Revenue**         | `SUM(fact_order_details[Revenue])`                                                            | Gross revenue across all transactions          |
| **Total Profit**          | `SUM(fact_order_details[Profit])`                                                             | Net profit earned                              |
| **Profit Margin %**       | `DIVIDE([Total Profit], [Total Revenue], 0)`                                                  | Overall profit efficiency                      |
| **Lost Revenue**          | `CALCULATE(SUM(fact_order_details[Revenue]), fact_returns)`                                   | Total dollar revenue lost to returned items    |
| **Return Rate %**         | `DIVIDE([Returned Units], SUM(fact_order_details[Quantity]), 0)`                              | Physical inventory return percentage           |
| **High Discount Sales %** | `DIVIDE(CALCULATE([Total Revenue], fact_order_details[Discount] > 0.20), [Total Revenue], 0)` | Share of total sales volume with >20% discount |

---

## 🔍 SQL Analytical Engine Highlights

<details>
<summary><b>Sub-Category Return Rates & Lost Revenue Query</b></summary>

```sql
WITH product_return AS (
    SELECT
        p."SubCategory",
        od."Quantity",
        od."Revenue",
        od."Profit",
        r."ReturnID"
    FROM products p
    INNER JOIN order_details od ON p."ProductID" = od."ProductID"
    LEFT JOIN returns r ON od."DetailID" = r."DetailID"
),
subcategory_summary AS (
    SELECT
        "SubCategory",
        SUM(CASE WHEN "ReturnID" IS NOT NULL THEN "Quantity" ELSE 0 END) AS returned_quantity,
        ROUND(SUM(CASE WHEN "ReturnID" IS NOT NULL THEN "Revenue" ELSE 0 END)::numeric, 2) AS lost_revenue,
        ROUND((SUM(CASE WHEN "ReturnID" IS NOT NULL THEN "Quantity" ELSE 0 END)::numeric / SUM("Quantity") * 100), 2) AS quantity_return_rate_pct,
        SUM("Quantity") AS total_quantity,
        ROUND(SUM("Revenue")::numeric, 2) AS total_revenue,
        ROUND(SUM("Profit")::numeric, 2) AS total_profit
    FROM product_return
    GROUP BY "SubCategory"
)
SELECT
    "SubCategory",
    returned_quantity,
    total_quantity,
    quantity_return_rate_pct,
    lost_revenue,
    total_revenue,
    total_profit,
    RANK() OVER (ORDER BY quantity_return_rate_pct DESC) AS return_rank
FROM subcategory_summary;
```

</details>

---

## 🖥️ Interactive Power BI Dashboard Showcase

### Page 1: Executive Overview

Monitors high-level KPIs, monthly sales trends, geographic distribution, and sub-category profitability highlighting loss-makers in red.
![Executive Overview](/docs/Retail_Sales_Executive_Overview.png)

### Page 2: Profit Leakage & Return Analysis

Evaluates the root causes of margin erosion across discount tiers, return rates by region, and detailed transactional order loss.
![Profit Leakage](/docs/Profit_Leakage_&_Return_Analysis.png)

---

## 💡 Strategic Business Recommendations

1. **Cap Maximum Promotional Discounts at 20%:** Eliminate the `21%+` discount tier immediately to stop negative margin sales (**-7.7%** profit margin).
2. **Supplier Quality Audit for High-Return Items:** Inspect packaging and listing descriptions for **Binders** (7.0% return rate) and **Laptops** (6.9% return rate) to reduce the **$621K** lost revenue.
3. **Re-evaluate Pricing for Net-Loss Categories:** Adjust pricing and promotional rules for **Accessories** and **Paper** to pull both sub-categories back into net profitability.

---

## 🚀 How to Reproduce

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/your-username/retail-profitability-analytics.git](https://github.com/your-username/retail-profitability-analytics.git)
   ```
2. **Run Python Pipeline:**
   ```bash
   python python/eda_and_loader.py
   ```
3. **Power BI Setup:**
   - Open `powerbi/Retail_Profitability_Dashboard.pbix` using Power BI Desktop.
   - Update database server credentials under **Transform Data → Data source settings** if connecting live to PostgreSQL.
