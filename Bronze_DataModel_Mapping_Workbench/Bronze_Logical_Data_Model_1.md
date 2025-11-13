_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for E-commerce Data Platform
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Customer Data
- **customer_email**: Contains personal email addresses which can directly identify individuals (GDPR Article 4)
- **customer_phone**: Phone numbers are personal identifiers that can be used to contact individuals
- **customer_first_name**: Personal name information that identifies individuals
- **customer_last_name**: Personal surname information that identifies individuals
- **billing_address**: Physical address information that can identify where a person lives
- **shipping_address**: Physical address information that can identify delivery locations
- **date_of_birth**: Sensitive personal information that can be used for identity verification
- **payment_method_details**: Financial information including card numbers, bank details

### 1.2 Employee Data
- **employee_email**: Work email addresses that can identify staff members
- **employee_phone**: Contact numbers for employees
- **employee_name**: Personal identification information for staff
- **employee_address**: Physical address information for employees

### 1.3 Vendor Data
- **vendor_contact_email**: Business contact information that may include personal emails
- **vendor_phone**: Contact numbers that may be personal or business
- **vendor_address**: Business address information

## 2. Bronze Layer Logical Model

### 2.1 Bz_Customers
**Description**: Raw customer data from source systems containing all customer information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Primary email address of the customer |
| customer_first_name | VARCHAR(100) | Customer's first name |
| customer_last_name | VARCHAR(100) | Customer's last name |
| customer_phone | VARCHAR(20) | Customer's primary phone number |
| date_of_birth | DATE | Customer's date of birth |
| registration_date | TIMESTAMP | Date when customer registered |
| customer_status | VARCHAR(50) | Current status of customer account |
| preferred_language | VARCHAR(10) | Customer's preferred language code |
| marketing_consent | BOOLEAN | Whether customer consented to marketing |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.2 Bz_Products
**Description**: Raw product catalog data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_name | VARCHAR(255) | Name of the product |
| product_description | TEXT | Detailed description of the product |
| product_category | VARCHAR(100) | Primary category of the product |
| product_subcategory | VARCHAR(100) | Subcategory classification |
| brand_name | VARCHAR(100) | Brand or manufacturer name |
| unit_price | DECIMAL(10,2) | Base price per unit |
| cost_price | DECIMAL(10,2) | Cost price of the product |
| weight | DECIMAL(8,2) | Product weight in specified units |
| dimensions | VARCHAR(100) | Product dimensions (LxWxH) |
| color | VARCHAR(50) | Product color |
| size | VARCHAR(50) | Product size |
| stock_quantity | INTEGER | Current stock quantity |
| reorder_level | INTEGER | Minimum stock level for reordering |
| supplier_name | VARCHAR(100) | Primary supplier name |
| product_status | VARCHAR(50) | Current status (active, discontinued, etc.) |
| launch_date | DATE | Product launch date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.3 Bz_Orders
**Description**: Raw order transaction data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Email of customer who placed the order |
| order_date | TIMESTAMP | Date and time when order was placed |
| order_status | VARCHAR(50) | Current status of the order |
| total_amount | DECIMAL(12,2) | Total order amount including taxes |
| subtotal_amount | DECIMAL(12,2) | Subtotal before taxes and fees |
| tax_amount | DECIMAL(10,2) | Total tax amount |
| shipping_cost | DECIMAL(8,2) | Shipping and handling charges |
| discount_amount | DECIMAL(10,2) | Total discount applied |
| payment_method | VARCHAR(50) | Payment method used |
| payment_status | VARCHAR(50) | Status of payment |
| billing_address | TEXT | Billing address for the order |
| shipping_address | TEXT | Shipping address for the order |
| estimated_delivery_date | DATE | Estimated delivery date |
| actual_delivery_date | DATE | Actual delivery date |
| order_channel | VARCHAR(50) | Channel through which order was placed |
| currency_code | VARCHAR(3) | Currency code for the transaction |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.4 Bz_Order_Items
**Description**: Raw order line item data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(50) | Reference to the parent order |
| product_name | VARCHAR(255) | Name of the ordered product |
| quantity_ordered | INTEGER | Quantity of product ordered |
| unit_price | DECIMAL(10,2) | Price per unit at time of order |
| line_total | DECIMAL(12,2) | Total amount for this line item |
| discount_applied | DECIMAL(10,2) | Discount applied to this line item |
| product_category | VARCHAR(100) | Category of the ordered product |
| product_brand | VARCHAR(100) | Brand of the ordered product |
| item_status | VARCHAR(50) | Status of this line item |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.5 Bz_Inventory
**Description**: Raw inventory data from warehouse management systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_name | VARCHAR(255) | Name of the product |
| warehouse_location | VARCHAR(100) | Warehouse or location identifier |
| current_stock | INTEGER | Current stock quantity |
| reserved_stock | INTEGER | Stock reserved for pending orders |
| available_stock | INTEGER | Available stock for new orders |
| reorder_point | INTEGER | Minimum stock level trigger |
| max_stock_level | INTEGER | Maximum stock capacity |
| last_restock_date | DATE | Date of last restocking |
| next_restock_date | DATE | Planned next restock date |
| stock_value | DECIMAL(12,2) | Total value of current stock |
| inventory_status | VARCHAR(50) | Status of inventory item |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.6 Bz_Suppliers
**Description**: Raw supplier and vendor data from procurement systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| supplier_name | VARCHAR(255) | Name of the supplier company |
| supplier_contact_name | VARCHAR(100) | Primary contact person name |
| supplier_email | VARCHAR(255) | Primary email contact |
| supplier_phone | VARCHAR(20) | Primary phone contact |
| supplier_address | TEXT | Complete supplier address |
| supplier_country | VARCHAR(100) | Country of supplier |
| supplier_category | VARCHAR(100) | Category of products supplied |
| payment_terms | VARCHAR(100) | Payment terms and conditions |
| lead_time_days | INTEGER | Standard lead time in days |
| quality_rating | DECIMAL(3,2) | Quality rating score |
| supplier_status | VARCHAR(50) | Current status of supplier |
| contract_start_date | DATE | Contract start date |
| contract_end_date | DATE | Contract end date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit trail for all Bronze layer data processing activities

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique identifier for the audit record |
| source_table | VARCHAR(100) | Name of the source table being processed |
| load_timestamp | TIMESTAMP | Timestamp when the data load process started |
| processed_by | VARCHAR(100) | System or user that processed the data |
| processing_time | INTEGER | Time taken to process in seconds |
| status | VARCHAR(50) | Status of the processing (SUCCESS, FAILED, PARTIAL) |
| records_processed | INTEGER | Number of records processed |
| records_inserted | INTEGER | Number of new records inserted |
| records_updated | INTEGER | Number of existing records updated |
| records_failed | INTEGER | Number of records that failed processing |
| error_message | TEXT | Error message if processing failed |
| batch_id | VARCHAR(100) | Batch identifier for grouping related processes |
| source_file_name | VARCHAR(255) | Name of source file if applicable |
| target_table | VARCHAR(100) | Target table where data was loaded |
| data_quality_score | DECIMAL(5,2) | Data quality score for the batch |

## 4. Conceptual Data Model Diagram

```
┌─────────────────┐         ┌─────────────────┐
│   Bz_Customers  │         │   Bz_Orders     │
│                 │◄────────┤                 │
│ customer_email  │         │ customer_email  │
│ customer_name   │         │ order_date      │
│ phone           │         │ total_amount    │
│ address         │         │ order_status    │
└─────────────────┘         └─────────────────┘
                                      │
                                      │
                                      ▼
                            ┌─────────────────┐
                            │ Bz_Order_Items  │
                            │                 │
                            │ order_number    │
                            │ product_name    │
                            │ quantity        │
                            │ unit_price      │
                            └─────────────────┘
                                      │
                                      │
                                      ▼
┌─────────────────┐         ┌─────────────────┐
│  Bz_Suppliers   │         │   Bz_Products   │
│                 │────────►│                 │
│ supplier_name   │         │ product_name    │
│ contact_info    │         │ category        │
│ address         │         │ unit_price      │
│ payment_terms   │         │ supplier_name   │
└─────────────────┘         └─────────────────┘
                                      │
                                      │
                                      ▼
                            ┌─────────────────┐
                            │  Bz_Inventory   │
                            │                 │
                            │ product_name    │
                            │ warehouse_loc   │
                            │ current_stock   │
                            │ reorder_point   │
                            └─────────────────┘
```

### 4.1 Table Relationships

1. **Bz_Customers → Bz_Orders**: Connected by `customer_email` field
   - One customer can have multiple orders (1:N relationship)

2. **Bz_Orders → Bz_Order_Items**: Connected by `order_number` field
   - One order can have multiple line items (1:N relationship)

3. **Bz_Products → Bz_Order_Items**: Connected by `product_name` field
   - One product can appear in multiple order items (1:N relationship)

4. **Bz_Products → Bz_Inventory**: Connected by `product_name` field
   - One product can have inventory records across multiple warehouses (1:N relationship)

5. **Bz_Suppliers → Bz_Products**: Connected by `supplier_name` field
   - One supplier can supply multiple products (1:N relationship)

6. **Bz_Audit_Log**: Tracks all tables through `source_table` and `target_table` fields
   - Provides audit trail for all data processing activities

### 4.2 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for clear identification
2. **Metadata Columns**: Consistent metadata columns across all tables for data lineage
3. **Data Types**: Appropriate data types chosen based on expected data volume and precision
4. **PII Identification**: Clear classification of sensitive data for compliance requirements
5. **Audit Trail**: Comprehensive audit table to track all data processing activities
6. **No Primary Keys**: Following Bronze layer principles, no artificial keys introduced
7. **Source Preservation**: All source data structure preserved without transformation