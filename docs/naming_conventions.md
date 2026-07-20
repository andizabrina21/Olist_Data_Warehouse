# Naming Conventions
This document outlines conventions used for schemas, tables, views, columns and other objects in the data warehouse.

## **General Principles**
- Naming Conventions: Use snake_case, with lowercase letters and underscores (`_`) to separate words.
- Languages: Use English for all names.
- Avoid Reserved Words: Do not use SQL reserved words as object names.

## Tabel Naming Conventions
### **Bronze Rules**
- All names must start with the source system name, and table must match their original names but without 'dataset' word.
- `<sourcesystem>_<entity>`
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`, `scm`).
  - `<entity>`: Exact table name from the source system.
  - Example: `crm_customers` $\to$ Customer information from the CRM system.
  
### **Silver Rules**
- All names must start with the source system name, and table names must match their original names but without 'dataset' word.
- `<sourcesystem>_<entity>`
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`, `scm`).
  - `<entity>`: Exact table name from the source system.
  - Example: `crm_customers` $\to$ Customer information from the CRM system.

### **Gold Rules**
- All names must use meaningful, business-aligned for tables, starting with category prefix.
- `<category>_<entity>`
  - `<category>`: Describe the role of the table, such as `dim` (dimension)  or `fact` (fact table).
  - `<entity>`: Descriptive name of the table, aligned with the business domain (e.g., `customers`, `products`, `order_items`, `sellers`).
  - Example:
    - `dim_customers` $\to$ Dimension table for customer data.
    - `fact_order_items` $\to$ Fact table containing orders & order items transactions.
    
#### **Glossary of Category Patterns**
| Pattern    | Meaning          | Example(s)                    |
|----------  |------------------|------------------------------ |
| `dim_`     | Dimension table  | `dim_customer`, `dim_product` |
| `fact_`    | Fact table       | `fact_orders`                 |
| `report_`     | Report table     | `report_customers`, `report_orders_monthly`  |

## **Column Naming Conventions**
### **Surrogate Keys**
- All primary keys in dimension tables must use the suffix `_key`.
- `<table_name>_key `
  - `<table_name>`: Refers to the name of the table or entity the key belongs to.
  - `_key`: A suffix indicating that this column is a surrogate key.
  - Example: `customer_key` $\to$ Surrogate key in the `dim_customers` table.

### **Technical Columns**
- All technical columns must start with the prefix `dwh_`, followed by a descriptive name indicating the column's purpose.
- `dwh_<column_name> `
  - `dwh`: Prefix exclusively for system-generated metadata.
  - `<column_name>`: Descriptive name indicating the column's purpose.
  - Example: `dwh_load_date` $\to$ System-generated column used to store the date when the record was loaded.

## Stored Procedure
- All store procedures used for loading data must follow naming patterns:
- `load_<layer>`.
    - `<layer>`: Represents the layer being loaded, such as `bronze`, `silver`, or `gold`.
    - Example:
        - `load_bronze` $\to$ Stored procedure for loading data into Bronze layer.
        - `load_silver` $\to$ Stored procedure for loading data into Silver layer.
