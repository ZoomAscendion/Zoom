# Bronze Layer Logical Data Model

_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Bronze layer logical data model for Medallion architecture with raw data ingestion and audit capabilities
## *Version*: 1
## *Updated on*: 
_____________________________________________

## 1. PII Classification

### 1.1 Identified PII Fields

| Column Name | Table | Reason for PII Classification |
|-------------|-------|------------------------------|
| customer_email | Bz_Customers | Contains personal email addresses that can identify individuals |
| customer_phone | Bz_Customers | Phone numbers are personal identifiers protected under privacy regulations |
| customer_first_name | Bz_Customers | Personal name information that can identify individuals |
| customer_last_name | Bz_Customers | Personal name information that can identify individuals |
| billing_address | Bz_Orders | Physical address information is considered PII under GDPR |
| shipping_address | Bz_Orders | Physical address information is considered PII under GDPR |
| payment_method_details | Bz_Payments | Financial information including card details are sensitive PII |
| employee_ssn | Bz_Employees | Social Security Numbers are highly sensitive PII |
| employee_email | Bz_Employees | Work email addresses can identify individuals |
| supplier_contact_email | Bz_Suppliers | Business contact information may contain personal identifiers |

## 2. Bronze Layer Logical Model

### 2.1 Table: Bz_Customers
**Description**: Raw customer data ingested from source systems containing customer profile information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_code | VARCHAR(50) | Unique customer identifier from source system |
| customer_first_name | VARCHAR(100) | Customer's first name |
| customer_last_name | VARCHAR(100) | Customer's last name |
| customer_email | VARCHAR(255) | Customer's email address |
| customer_phone | VARCHAR(20) | Customer's contact phone number |
| date_of_birth | DATE | Customer's date of birth |
| registration_date | TIMESTAMP | Date when customer registered |
| customer_status | VARCHAR(20) | Current status of customer account |
| preferred_language | VARCHAR(10) | Customer's preferred language code |
| marketing_consent | BOOLEAN | Customer's consent for marketing communications |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.2 Table: Bz_Products
**Description**: Raw product catalog data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_code | VARCHAR(50) | Unique product identifier from source system |
| product_name | VARCHAR(255) | Name of the product |
| product_description | TEXT | Detailed description of the product |
| category_code | VARCHAR(50) | Product category identifier |
| brand_name | VARCHAR(100) | Brand name of the product |
| unit_price | DECIMAL(10,2) | Base price per unit |
| cost_price | DECIMAL(10,2) | Cost price of the product |
| weight | DECIMAL(8,3) | Weight of the product in kg |
| dimensions | VARCHAR(100) | Product dimensions (LxWxH) |
| color | VARCHAR(50) | Product color |
| size | VARCHAR(20) | Product size |
| stock_quantity | INTEGER | Available stock quantity |
| reorder_level | INTEGER | Minimum stock level for reordering |
| supplier_code | VARCHAR(50) | Supplier identifier |
| product_status | VARCHAR(20) | Current status of the product |
| launch_date | DATE | Product launch date |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.3 Table: Bz_Orders
**Description**: Raw order transaction data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(50) | Unique order identifier from source system |
| customer_code | VARCHAR(50) | Customer identifier |
| order_date | TIMESTAMP | Date and time when order was placed |
| order_status | VARCHAR(20) | Current status of the order |
| total_amount | DECIMAL(12,2) | Total order amount including taxes |
| subtotal_amount | DECIMAL(12,2) | Subtotal before taxes and discounts |
| tax_amount | DECIMAL(10,2) | Total tax amount |
| discount_amount | DECIMAL(10,2) | Total discount applied |
| shipping_cost | DECIMAL(8,2) | Shipping charges |
| billing_address | TEXT | Billing address for the order |
| shipping_address | TEXT | Shipping address for the order |
| payment_method | VARCHAR(50) | Payment method used |
| currency_code | VARCHAR(3) | Currency code for the transaction |
| order_channel | VARCHAR(50) | Channel through which order was placed |
| delivery_date | DATE | Expected or actual delivery date |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.4 Table: Bz_Order_Items
**Description**: Raw order line item data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_item_code | VARCHAR(50) | Unique order item identifier |
| order_number | VARCHAR(50) | Order identifier |
| product_code | VARCHAR(50) | Product identifier |
| quantity | INTEGER | Quantity of product ordered |
| unit_price | DECIMAL(10,2) | Price per unit at time of order |
| line_total | DECIMAL(12,2) | Total amount for this line item |
| discount_percent | DECIMAL(5,2) | Discount percentage applied |
| tax_rate | DECIMAL(5,4) | Tax rate applied |
| item_status | VARCHAR(20) | Status of the individual item |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.5 Table: Bz_Payments
**Description**: Raw payment transaction data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| payment_transaction_code | VARCHAR(50) | Unique payment transaction identifier |
| order_number | VARCHAR(50) | Associated order identifier |
| payment_date | TIMESTAMP | Date and time of payment |
| payment_amount | DECIMAL(12,2) | Amount paid |
| payment_method | VARCHAR(50) | Payment method used |
| payment_status | VARCHAR(20) | Status of the payment |
| transaction_reference | VARCHAR(100) | External transaction reference |
| gateway_response | VARCHAR(255) | Payment gateway response |
| currency_code | VARCHAR(3) | Currency of the payment |
| processing_fee | DECIMAL(8,2) | Processing fee charged |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.6 Table: Bz_Suppliers
**Description**: Raw supplier master data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| supplier_code | VARCHAR(50) | Unique supplier identifier |
| supplier_name | VARCHAR(255) | Name of the supplier |
| contact_person | VARCHAR(100) | Primary contact person |
| contact_email | VARCHAR(255) | Contact email address |
| contact_phone | VARCHAR(20) | Contact phone number |
| address | TEXT | Supplier address |
| city | VARCHAR(100) | City |
| state | VARCHAR(100) | State or province |
| country | VARCHAR(100) | Country |
| postal_code | VARCHAR(20) | Postal or ZIP code |
| tax_number | VARCHAR(50) | Tax identification number |
| payment_terms | VARCHAR(100) | Payment terms and conditions |
| supplier_rating | DECIMAL(3,2) | Supplier performance rating |
| contract_start_date | DATE | Contract start date |
| contract_end_date | DATE | Contract end date |
| supplier_status | VARCHAR(20) | Current status of supplier |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.7 Table: Bz_Inventory
**Description**: Raw inventory data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| inventory_record_code | VARCHAR(50) | Unique inventory record identifier |
| product_code | VARCHAR(50) | Product identifier |
| warehouse_code | VARCHAR(50) | Warehouse identifier |
| available_quantity | INTEGER | Available stock quantity |
| reserved_quantity | INTEGER | Reserved stock quantity |
| damaged_quantity | INTEGER | Damaged stock quantity |
| last_stock_count | INTEGER | Last physical count quantity |
| stock_count_date | DATE | Date of last physical count |
| reorder_point | INTEGER | Reorder point threshold |
| max_stock_level | INTEGER | Maximum stock level |
| location_code | VARCHAR(50) | Storage location within warehouse |
| batch_number | VARCHAR(50) | Batch or lot number |
| expiry_date | DATE | Expiry date for perishable items |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

## 3. Audit Table Design

### 3.1 Table: Bz_Audit_Log
**Description**: Comprehensive audit trail for all Bronze layer data processing activities

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(50) | Unique audit record identifier |
| source_table | VARCHAR(100) | Name of the source table being processed |
| load_timestamp | TIMESTAMP | Timestamp when the data load process started |
| processed_by | VARCHAR(100) | System or user that processed the data |
| processing_time | INTEGER | Time taken to process in seconds |
| status | VARCHAR(20) | Status of the processing (SUCCESS, FAILED, PARTIAL) |
| records_processed | INTEGER | Number of records processed |
| records_inserted | INTEGER | Number of new records inserted |
| records_updated | INTEGER | Number of existing records updated |
| records_failed | INTEGER | Number of records that failed processing |
| error_message | TEXT | Error message if processing failed |
| batch_id | VARCHAR(50) | Batch identifier for grouping related operations |
| source_file_name | VARCHAR(255) | Name of source file if applicable |
| file_size | BIGINT | Size of source file in bytes |
| checksum | VARCHAR(64) | File checksum for integrity verification |
| load_type | VARCHAR(20) | Type of load (FULL, INCREMENTAL, DELTA) |
| data_quality_score | DECIMAL(5,2) | Data quality score percentage |
| created_timestamp | TIMESTAMP | Timestamp when audit record was created |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationships (Block Diagram Format)

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Bz_Customers  │────▶│    Bz_Orders    │────▶│  Bz_Order_Items │
│                 │     │                 │     │                 │
│ customer_code   │     │ customer_code   │     │ order_number    │
│ (connects via   │     │ order_number    │     │ product_code    │
│ customer_code)  │     │ (connects via   │     │ (connects via   │
└─────────────────┘     │ order_number)   │     │ order_number &  │
                        └─────────────────┘     │ product_code)   │
                                 │              └─────────────────┘
                                 ▼                       │
                        ┌─────────────────┐              │
                        │   Bz_Payments   │              │
                        │                 │              │
                        │ order_number    │              │
                        │ (connects via   │              │
                        │ order_number)   │              │
                        └─────────────────┘              │
                                                         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Bz_Suppliers   │────▶│   Bz_Products   │◀────│  Bz_Inventory   │
│                 │     │                 │     │                 │
│ supplier_code   │     │ supplier_code   │     │ product_code    │
│ (connects via   │     │ product_code    │     │ (connects via   │
│ supplier_code)  │     │ (connects via   │     │ product_code)   │
└─────────────────┘     │ product_code)   │     └─────────────────┘
                        └─────────────────┘
```

### 4.2 Key Relationships

1. **Bz_Customers → Bz_Orders**: Connected via `customer_code`
   - One customer can have multiple orders

2. **Bz_Orders → Bz_Order_Items**: Connected via `order_number`
   - One order can have multiple order items

3. **Bz_Orders → Bz_Payments**: Connected via `order_number`
   - One order can have multiple payment transactions

4. **Bz_Products → Bz_Order_Items**: Connected via `product_code`
   - One product can appear in multiple order items

5. **Bz_Suppliers → Bz_Products**: Connected via `supplier_code`
   - One supplier can supply multiple products

6. **Bz_Products → Bz_Inventory**: Connected via `product_code`
   - One product can have inventory records across multiple warehouses

7. **Bz_Audit_Log**: Tracks all processing activities across all tables via `source_table` field

### 4.3 Design Rationale

1. **Naming Convention**: All Bronze layer tables use 'Bz_' prefix for consistent identification
2. **Metadata Columns**: Standard metadata columns (load_timestamp, update_timestamp, source_system) added to all tables for lineage tracking
3. **PII Handling**: Identified PII fields for proper data governance and compliance
4. **Audit Trail**: Comprehensive audit table to track all data processing activities
5. **Data Types**: Selected appropriate data types based on expected data volume and precision requirements
6. **Relationships**: Maintained referential relationships through business keys rather than technical keys

### 4.4 Key Assumptions

1. Source systems provide data in structured format
2. Business keys are unique within their respective domains
3. All timestamps are in UTC format
4. Currency amounts are stored with 2 decimal precision
5. Text fields accommodate international character sets
6. Audit logging is mandatory for all data processing operations