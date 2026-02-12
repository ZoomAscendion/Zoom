_____________________________________________
## *Author*: AAVA
## *Created on*: 2026-01-06
## *Description*: Bronze Layer Logical Data Model for Medallion Architecture - E-commerce Domain
## *Version*: 1
## *Updated on*: 2026-01-06
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Customer Information
- **customer_email**: Contains personal email addresses - PII as it can directly identify individuals
- **customer_phone**: Contains personal phone numbers - PII as it's a direct personal identifier
- **customer_first_name**: Contains personal first names - PII as it's personal identifying information
- **customer_last_name**: Contains personal last names - PII as it's personal identifying information
- **customer_address**: Contains residential addresses - PII as it reveals personal location information
- **customer_date_of_birth**: Contains birth dates - PII as it's sensitive personal demographic data

### 1.2 Payment Information
- **payment_card_number**: Contains credit/debit card numbers - PII as it's sensitive financial information
- **payment_cvv**: Contains card security codes - PII as it's sensitive financial security data
- **billing_address**: Contains billing addresses - PII as it reveals personal financial location

### 1.3 Employee Information
- **employee_email**: Contains work email addresses - PII as it can identify individuals
- **employee_phone**: Contains personal/work phone numbers - PII as it's a direct identifier
- **employee_ssn**: Contains social security numbers - PII as it's highly sensitive government identifier

## 2. Bronze Layer Logical Model

### 2.1 Bz_Customers
**Description**: Raw customer data from source systems maintaining original structure

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Primary email address of the customer |
| customer_phone | VARCHAR(20) | Primary contact phone number |
| customer_first_name | VARCHAR(100) | Customer's first name |
| customer_last_name | VARCHAR(100) | Customer's last name |
| customer_address | VARCHAR(500) | Complete residential address |
| customer_date_of_birth | DATE | Customer's birth date |
| customer_registration_date | TIMESTAMP | Date when customer registered |
| customer_status | VARCHAR(20) | Current status (Active, Inactive, Suspended) |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.2 Bz_Products
**Description**: Raw product catalog data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_name | VARCHAR(255) | Full product name |
| product_description | TEXT | Detailed product description |
| product_category | VARCHAR(100) | Product category classification |
| product_subcategory | VARCHAR(100) | Product subcategory classification |
| product_brand | VARCHAR(100) | Product brand name |
| product_price | DECIMAL(10,2) | Current product price |
| product_cost | DECIMAL(10,2) | Product cost price |
| product_weight | DECIMAL(8,2) | Product weight in specified units |
| product_dimensions | VARCHAR(100) | Product dimensions (LxWxH) |
| product_color | VARCHAR(50) | Product color |
| product_size | VARCHAR(20) | Product size |
| product_status | VARCHAR(20) | Product status (Active, Discontinued, Out of Stock) |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.3 Bz_Orders
**Description**: Raw order transaction data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(50) | Unique order identifier |
| customer_email | VARCHAR(255) | Customer email (foreign reference) |
| order_date | TIMESTAMP | Date and time when order was placed |
| order_status | VARCHAR(30) | Current order status |
| order_total_amount | DECIMAL(12,2) | Total order amount including taxes |
| order_subtotal | DECIMAL(12,2) | Order subtotal before taxes |
| order_tax_amount | DECIMAL(10,2) | Total tax amount |
| order_shipping_cost | DECIMAL(8,2) | Shipping cost |
| order_discount_amount | DECIMAL(10,2) | Total discount applied |
| shipping_address | VARCHAR(500) | Delivery address |
| billing_address | VARCHAR(500) | Billing address |
| payment_method | VARCHAR(50) | Payment method used |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.4 Bz_Order_Items
**Description**: Raw order line item data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(50) | Order identifier (foreign reference) |
| product_name | VARCHAR(255) | Product name (foreign reference) |
| item_quantity | INTEGER | Quantity of product ordered |
| item_unit_price | DECIMAL(10,2) | Unit price at time of order |
| item_total_price | DECIMAL(12,2) | Total price for this line item |
| item_discount_amount | DECIMAL(10,2) | Discount applied to this item |
| item_status | VARCHAR(30) | Status of this line item |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.5 Bz_Payments
**Description**: Raw payment transaction data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| payment_transaction_id | VARCHAR(100) | Unique payment transaction identifier |
| order_number | VARCHAR(50) | Associated order number |
| payment_amount | DECIMAL(12,2) | Payment amount |
| payment_method | VARCHAR(50) | Payment method (Credit Card, PayPal, etc.) |
| payment_status | VARCHAR(30) | Payment status (Pending, Completed, Failed) |
| payment_date | TIMESTAMP | Date and time of payment |
| payment_card_number | VARCHAR(20) | Masked card number (last 4 digits) |
| payment_processor | VARCHAR(50) | Payment processor used |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.6 Bz_Inventory
**Description**: Raw inventory data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_name | VARCHAR(255) | Product identifier (foreign reference) |
| warehouse_location | VARCHAR(100) | Warehouse location identifier |
| quantity_on_hand | INTEGER | Current quantity available |
| quantity_reserved | INTEGER | Quantity reserved for orders |
| quantity_available | INTEGER | Quantity available for sale |
| reorder_level | INTEGER | Minimum quantity before reorder |
| reorder_quantity | INTEGER | Standard reorder quantity |
| last_restock_date | DATE | Date of last restocking |
| inventory_value | DECIMAL(12,2) | Total value of inventory |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.7 Bz_Suppliers
**Description**: Raw supplier data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| supplier_name | VARCHAR(255) | Supplier company name |
| supplier_contact_person | VARCHAR(100) | Primary contact person |
| supplier_email | VARCHAR(255) | Supplier email address |
| supplier_phone | VARCHAR(20) | Supplier phone number |
| supplier_address | VARCHAR(500) | Supplier address |
| supplier_country | VARCHAR(100) | Supplier country |
| supplier_rating | DECIMAL(3,2) | Supplier performance rating |
| supplier_status | VARCHAR(20) | Supplier status (Active, Inactive) |
| contract_start_date | DATE | Contract start date |
| contract_end_date | DATE | Contract end date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit trail for all Bronze layer operations

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique identifier for audit record |
| source_table | VARCHAR(100) | Name of the source table being audited |
| load_timestamp | TIMESTAMP | Timestamp when data was loaded |
| processed_by | VARCHAR(100) | System/user that processed the data |
| processing_time | DECIMAL(10,3) | Time taken to process in seconds |
| status | VARCHAR(20) | Processing status (Success, Failed, Warning) |
| record_count | INTEGER | Number of records processed |
| error_message | TEXT | Error details if processing failed |
| source_file_name | VARCHAR(255) | Source file name if applicable |
| target_table | VARCHAR(100) | Target table where data was loaded |
| operation_type | VARCHAR(20) | Type of operation (INSERT, UPDATE, DELETE) |
| data_quality_score | DECIMAL(5,2) | Data quality assessment score |

## 4. Conceptual Data Model Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Bz_Customers  │────▶│   Bz_Orders     │────▶│ Bz_Order_Items  │
│                 │     │                 │     │                 │
│ customer_email  │     │ customer_email  │     │ order_number    │
│ customer_phone  │     │ order_number    │     │ product_name    │
│ customer_name   │     │ order_date      │     │ item_quantity   │
│ customer_address│     │ order_total     │     │ item_price      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                │                         │
                                │                         │
                                ▼                         ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │   Bz_Payments   │     │   Bz_Products   │
                        │                 │     │                 │
                        │ order_number    │     │ product_name    │
                        │ payment_amount  │     │ product_category│
                        │ payment_method  │     │ product_price   │
                        │ payment_status  │     │ product_brand   │
                        └─────────────────┘     └─────────────────┘
                                                          │
                                                          │
                                                          ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Bz_Suppliers   │────▶│  Bz_Inventory   │────▶│   Bz_Products   │
│                 │     │                 │     │                 │
│ supplier_name   │     │ product_name    │     │ product_name    │
│ supplier_email  │     │ warehouse_loc   │     │ product_status  │
│ supplier_status │     │ quantity_on_hand│     │ product_details │
│ contract_dates  │     │ reorder_level   │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 4.1 Table Relationships

1. **Bz_Customers → Bz_Orders**: Connected by `customer_email` field
2. **Bz_Orders → Bz_Order_Items**: Connected by `order_number` field
3. **Bz_Orders → Bz_Payments**: Connected by `order_number` field
4. **Bz_Products → Bz_Order_Items**: Connected by `product_name` field
5. **Bz_Products → Bz_Inventory**: Connected by `product_name` field
6. **Bz_Suppliers → Bz_Inventory**: Connected through supplier contracts (implicit relationship)

### 4.2 Key Design Decisions

1. **Naming Convention**: All Bronze tables prefixed with 'Bz_' for clear identification
2. **Data Preservation**: All source data fields preserved without transformation
3. **Metadata Addition**: Standard metadata columns added to all tables for tracking
4. **PII Identification**: Clear classification of sensitive data fields
5. **Audit Trail**: Comprehensive audit table for data lineage and quality monitoring
6. **Flexible Schema**: VARCHAR fields sized to accommodate various source systems
7. **Timestamp Precision**: TIMESTAMP data type for precise temporal tracking

### 4.3 Assumptions Made

1. Source systems provide data in structured format
2. Customer email serves as natural key for customer identification
3. Product names are unique identifiers across the system
4. Order numbers are unique across all source systems
5. All monetary values are in consistent currency
6. Source systems maintain referential integrity
7. Data quality issues will be addressed in Silver layer transformation