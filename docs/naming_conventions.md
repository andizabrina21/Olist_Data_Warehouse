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
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`, `lob`).
  - `<entity>`: Exact table name from the source system.
  - Example: `crm_customers` $\to$ Customer information from the CRM system.
  
### **Silver Rules**
- All names must start with the source system name, and table names must match their original names but without 'dataset' word.
- `<sourcesystem>_<entity>`
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`, `lob`).
  - `<entity>`: Exact table name from the source system.
  - Example: `crm_customers` $\to$ Customer information from the CRM system.

### **Gold Rules**
- All names must use meaningful, business-aligned for tables, starting with category prefix.
- `<category>_<entity>`
  - `<category>`: Describe the role of the table, such as `dim` (dimension)  or `fact` (fact table).
  - `<entity>`: Descriptive name of the table, aligned with the business domain (e.g., `customers`, `products`, `orders`, `sellers`).
  - Example:
    - `dim_customers` $\to$ Dimension table for customer data.
    - `fact_orders` $\to$ Fact table containing orders transactions.
    
#### **Glossary of Category Patterns**
| Pattern    | Meaning          | Example(S)                    |
|----------  |------------------|------------------------------ |
| `dim_`     | Dimension table  | `dim_customer`, `dim_product` |
| `fact_`    | Fact table       | `fact_orders`                 |
| `dim_`     | Report table     | `report_customers`, `report_orders_monthly`  |

## **Column Naming Conventions**

### **Surrogate Keys**

### **Technical Columns**

## Stored Procedure
- All store procedures used for loading data must follow naming patterns:
- `load_<layer>`.
    - `<layer>`: Represents the layer being loaded, such as `bronze`, `silver`, or `gold`.
    - Example:
        - `load_bronze` $\to$ Stored procedure for loading data into Bronze layer.
