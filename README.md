# MEDALLION-ARCHITECTURE-DATA-PIPELINE
Building a modern data warehouse with micro soft SQL server, including ETL processes, data modelling, and analytics 

Medallion Data Pipeline: Olist E-Commerce Data Warehouse
📋 Project Overview
This project implements a modern Medallion Architecture data warehouse using the Olist Brazilian E-Commerce dataset. The pipeline integrates fragmented data from simulated CRM and ERP source systems to create a unified "Customer 360" view. This infrastructure serves as the foundational engineering layer for predictive modeling (Trimester 8) and AI agent deployment (Trimester 9).  

🏗️ Architecture :
<img width="2000" height="980" alt="image" src="https://github.com/user-attachments/assets/c66cec14-62a8-4ff5-aba1-570069f37646" />

The pipeline follows a three-tier Medallion structure to ensure data lineage and quality:

Bronze (Raw Layer): Ingests raw CSV files into SQL staging tables using BULK INSERT. Data is stored in its original form to maintain a permanent audit trail.

Silver (Cleansed Layer): Performs data standardization, deduplication (using ROW_NUMBER()), and translation of product categories from Portuguese to English. Audit metadata (dw_load_date) is appended to every record.

Gold (Curated Layer): Implements a Star Schema using SQL Views. This layer features a central fact_sales table linked to dim_customers and dim_products via system-generated surrogate keys.

🛠️ Tools & Technologies
Database: Microsoft SQL Server (SSMS)

Language: T-SQL

Documentation: LaTeX (IEEE Format)   

Visualization: Power BI 

Dataset: Olist Brazilian E-Commerce (Kaggle)

📁 Source System Mapping
To meet enterprise requirements, data is segregated as follows:

CRM (Front-Office): Customers, Reviews, and Geolocation data.

ERP (Back-Office): Orders, Items, Payments, Products, and Sellers data.

🚀 Key Features:

End-to-End Automation: A master stored procedure (sp_Run_Medallion_Pipeline) orchestrates the entire data flow.

Error Handling: Implemented TRY...CATCH blocks with a dedicated Error_Logs table for pipeline observability.

Data Quality Framework: Automated checks ensure primary key uniqueness and referential integrity between Fact and Dimension tables.

🛡️ License
This project is licensed under the MIT License. You are free to use, modify, and share this project with proper attribution.
