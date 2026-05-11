Olist E-Commerce Gold Layer: Data Dictionary
1. Star Schema Relationship Overview
Fact Table	Linked Dimension	Connection Key	Relationship
gold.fact_sales	gold.dim_customers	customer_key	Many-to-One (N:1)
gold.fact_sales	gold.dim_products	product_key	Many-to-One (N:1)
________________________________________
2. gold.fact_sales (Fact Table)
Description: Central fact view recording transactional order-item events. Aggregates data from ERP and CRM silos.
Column Name	Data Type	Key Type	Nullable?	Business Logic & Description
customer_key	INT	Foreign Key	NO	Unique integer linking to the Customer Dimension. Acts as the main Customer 360 bridge.
product_key	INT	Foreign Key	NO	Unique integer linking to the Product Dimension. Enables multilingual reporting.
order_id	VARCHAR	Operational Key	NO	Unique ID from the ERP system, preserved for data lineage.
order_date	DATETIME	Time Key	NO	Timestamp of the order purchase event. Enables trend analysis.
item_revenue	DECIMAL	Measure	NO	Revenue strictly from the product price (ERP data).
shipping_cost	DECIMAL	Measure	NO	Operational shipping cost (ERP data). A known predictor of review scores.
total_sales_amount	DECIMAL	Measure	NO	Synthesized KPI: $(Item\_Revenue + Shipping\_Cost)$. Single source of truth for total cash flow.
items_quantity	INT	Measure	NO	Count of line items in the transaction event.
________________________________________
3. gold.dim_customers (Dimension Table)
Description: Customer master dimension containing identity and location attributes from the CRM silo.
Column Name  	Data Type	  Key Type	Nullable?	Business Logic & Description
customer_key	INT	Primary Key	NO	Surrogate Key (ROW_NUMBER). Decouples the warehouse from source customer_id changes.
customer_id	  VARCHAR	    Natural Key	NO	Unique ID from the operational CRM.
city	        VARCHAR	    Attribute	NO	Physical city of the customer.
state	        VARCHAR	Attribute	NO	Physical state of the customer. Enables state-level revenue mapping.
________________________________________
4. gold.dim_products (Dimension Table)
Description: Product master dimension containing attributes and multilingual translations from the ERP silo.

Column Name	Data Type	Key Type	Nullable?	Business Logic & Description
product_key	INT	Primary Key	NO	Surrogate Key (ROW_NUMBER). Simplifies joins and ensures performance.
product_id	VARCHAR	Natural Key	NO	Unique operational SKU ID from the ERP.
weight_grams	FLOAT	Attribute	YES	Physical product weight. A logistics predictor.
product_category	VARCHAR	Attribute	NO	Multilingual Logic: English product categories mapped from Portuguese using ISNULL(..., 'Other').

