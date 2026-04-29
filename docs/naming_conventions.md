# Naming Conventions
This document outlines conventions used for schemas, tables, views, columns and other objects in the data warehouse.

## General Principles
- Naming Conventions: Use snake_case, with lowercase letters and underscores (`_`) to separate words.
- Languages: Use English for all names.
- Avoid Reserved Words: Do not use SQL reserved words as object names.

## Tabel Naming Conventions
### Bronze Rules
- All names must start with the source system name, and table must match their original names but without 'dataset' word.
- `<sourcesystem>_<entity>`
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).
  - `<entity>`: Exact table name from the source system.
  - Example: `crm_customers` ➡ Customer information from the CRM system.
  
### Silver Rules
