# Olist E-Commerce Gold Layer: Data Dictionary

1. Star Schema Relationship Overview:

| Fact Table       | Linked Dimension    | Connection Key | Relationship      |
|------------------|---------------------|----------------|-------------------|
| gold.fact_sales  | gold.dim_customers  | customer_key   | Many-to-One (N:1) |
| gold.fact_sales  | gold.dim_products   | product_key    | Many-to-One (N:1) |

-------------------------------------------------------------------------------

2. gold.fact_sales (Fact Table):
Description: Central fact view recording transactional order-item events. Aggregates 
data from ERP and CRM silos.

| Column Name        | Data Type | Key Type        | Business Logic & Description                                     |
|--------------------|-----------|-----------------|------------------------------------------------------------------|
| customer_key       | INT       | Foreign Key     | Unique integer linking to the Customer Dimension.                |
| product_key        | INT       | Foreign Key     | Unique integer linking to the Product Dimension.                 |
| order_id           | VARCHAR   | Operational Key | Unique ID from the ERP system for data lineage.                  |
| order_date         | DATETIME  | Time Key        | Timestamp of the order purchase event.                           |
| item_revenue       | DECIMAL   | Measure         | Revenue strictly from the product price (ERP data).              |
| shipping_cost      | DECIMAL   | Measure         | Operational shipping cost (ERP data).                            |
| total_sales_amount | DECIMAL   | KPI             | Synthesized KPI: (item_revenue + shipping_cost).                 |
| items_quantity     | INT       | Measure         | Count of line items in the transaction event.                    |

-------------------------------------------------------------------------------

3. gold.dim_customers (Dimension Table):
Description: Customer master dimension containing identity and location attributes 
from the CRM silo.

| Column Name | Data Type | Key Type    | Business Logic & Description                                 |
|-------------|-----------|-------------|--------------------------------------------------------------|
| customer_key| INT       | Primary Key | Surrogate Key generated via ROW_NUMBER().                    |
| customer_id | VARCHAR   | Natural Key | Unique ID from the operational CRM.                          |
| city        | VARCHAR   | Attribute   | Physical city of the customer.                               |
| state       | VARCHAR   | Attribute   | Physical state of the customer for mapping.                  |

-------------------------------------------------------------------------------

4. gold.dim_products (Dimension Table):
Description: Product master dimension containing attributes and multilingual 
translations from the ERP silo.

| Column Name      | Data Type | Key Type    | Business Logic & Description                                     |
|------------------|-----------|-------------|------------------------------------------------------------------|
| product_key      | INT       | Primary Key | Surrogate Key generated via ROW_NUMBER().                        |
| product_id       | VARCHAR   | Natural Key | Unique operational SKU ID from the ERP.                          |
| weight_grams     | FLOAT     | Attribute   | Physical product weight. ]                                       |
| product_category | VARCHAR   | Attribute   | English product categories mapped from Portuguese.               |
