# Data Catalog for Gold Layer
## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for spesific business metrics.

### 1. gold.dim_customers
- **Purpose:** Stores customer information enriched with demographic and geographic data.
- **Columns:**

| Column Name          | Data Type            | Description                                                                     |
|----------------------|----------------------|---------------------------------------------------------------------------------|
| customer_key         | INT                  |Surrogate key uniquely identifying each customer record in the dimension table.  |
| customer_id          | NVARCHAR(50)         | Identifier of a customer in a specific order. This value may differ across orders for the same customer.                                       |
| customer_unique_id   | NVARCHAR(50)         | Unique identifier assigned to each customer, allowing the same customer to be identified across multiple orders.                          |
| customer_type        | NVARCHAR(50)         | Customer category based on purchase frequency (e.g., 'Repeat User', 'Single User')     |
| customer_city        | NVARCHAR(50)         | The city of residence for the customer (e.g., 'osasco', 'sao paulo')                              |
| customer_state       | NVARCHAR(2)          | State code of the customer's residence (e.g., 'SP', 'MG')                              |
| customer_region      | NVARCHAR(50)         | Geographic region of the customer's residence (e.g., 'Southeast', 'Central-West')    |
| customer_lat         | FLOAT                | Latitude coordinate of the customer's location, derived from the corresponding ZIP code prefix in the geolocation dataset. (e.g., -23.499062689784747)                        |
| customer_lng         | FLOAT                | Longitude coordinate of the customer's location, derived from the corresponding ZIP code prefix in the geolocation dataset. (e.g., -46.76793857798514)                        |

### 2. gold.dim_products
- **Purpose:** Provides infromation about the products and their attributes.
- **Columns:**

| Column Name          | Data Type            | Description                                                                     |
|----------------------|----------------------|---------------------------------------------------------------------------------|
| product_key         | INT                  |Surrogate key uniquely identifying each customer record in the dimension table.  |
| product_id         | NVARCHAR(50)                  |A unique identifier assigned to the product for internal tracking and referencing.  |
| product_category         | NVARCHAR(50)                  |The broader classification of the product (e.g., Beauty & Health, Fashion) to group related items.   |
| product_subcategory         | NVARCHAR(50)                  |A more detailed classification of the product (e.g., Beauty & Health, Fashion   |
