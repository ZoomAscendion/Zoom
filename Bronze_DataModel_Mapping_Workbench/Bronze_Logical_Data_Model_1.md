_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Bronze layer logical data model for medallion architecture supporting e-commerce data platform
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Customer Data PII Fields
- **customer_email**: Contains personal email addresses that can directly identify individuals (GDPR Article 4)
- **customer_phone**: Phone numbers are personal identifiers that can be used to contact and identify individuals
- **first_name**: Personal name information that identifies individuals
- **last_name**: Personal surname information that identifies individuals
- **date_of_birth**: Sensitive personal information that can be used for identity verification
- **billing_address**: Physical address information that can identify individual's location and residence
- **shipping_address**: Physical address information that can identify individual's location

### 1.2 Employee Data PII Fields
- **employee_email**: Work email addresses that identify individual employees
- **employee_phone**: Contact numbers for individual employees
- **employee_first_name**: Personal name information of employees
- **employee_last_name**: Personal surname information of employees
- **social_security_number**: Highly sensitive government identifier
- **employee_address**: Physical address information of employees

### 1.3 Payment Data PII Fields
- **credit_card_number**: Financial payment information that requires PCI DSS compliance
- **bank_account_number**: Financial account information that can be used for unauthorized access
- **payment_method_details**: Contains sensitive financial information

## 2. Bronze Layer Logical Model

### 2.1 Bz_Customers
**Description**: Raw customer data from source systems containing all customer information as received

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Primary email address of the customer |
| customer_phone | VARCHAR(20) | Primary phone number of the customer |
| first_name | VARCHAR(100) | Customer's first name |
| last_name | VARCHAR(100) | Customer's last name |
| date_of_birth | DATE | Customer's date of birth |
| registration_date | TIMESTAMP | Date when customer registered |
| customer_status | VARCHAR(50) | Current status of customer account |
| billing_address | VARCHAR(500) | Customer's billing address |
| shipping_address | VARCHAR(500) | Customer's default shipping address |
| customer_segment | VARCHAR(100) | Customer segmentation category |
| preferred_language | VARCHAR(10) | Customer's preferred language code |
| marketing_consent | BOOLEAN | Customer's consent for marketing communications |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(100) | Source system that provided the data |

### 2.2 Bz_Products
**Description**: Raw product catalog data containing all product information and attributes

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_name | VARCHAR(255) | Name of the product |
| product_description | TEXT | Detailed description of the product |
| category_name | VARCHAR(100) | Product category classification |
| subcategory_name | VARCHAR(100) | Product subcategory classification |
| brand_name | VARCHAR(100) | Brand name of the product |
| unit_price | DECIMAL(10,2) | Base price per unit |
| cost_price | DECIMAL(10,2) | Cost price of the product |
| weight | DECIMAL(8,2) | Weight of the product in specified units |
| dimensions | VARCHAR(100) | Product dimensions (length x width x height) |
| color | VARCHAR(50) | Product color |
| size | VARCHAR(50) | Product size |
| material | VARCHAR(100) | Material composition of the product |
| stock_quantity | INTEGER | Current stock quantity available |
| reorder_level | INTEGER | Minimum stock level before reordering |
| supplier_name | VARCHAR(255) | Name of the product supplier |
| product_status | VARCHAR(50) | Current status of the product (active/inactive) |
| launch_date | DATE | Date when product was launched |
| discontinue_date | DATE | Date when product was discontinued |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(100) | Source system that provided the data |

### 2.3 Bz_Orders
**Description**: Raw order transaction data capturing all order details as received from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(100) | Unique order identifier |
| customer_email | VARCHAR(255) | Email of the customer who placed the order |
| order_date | TIMESTAMP | Date and time when order was placed |
| order_status | VARCHAR(50) | Current status of the order |
| total_amount | DECIMAL(12,2) | Total order amount including taxes |
| subtotal_amount | DECIMAL(12,2) | Order subtotal before taxes and fees |
| tax_amount | DECIMAL(10,2) | Total tax amount for the order |
| shipping_cost | DECIMAL(8,2) | Shipping charges for the order |
| discount_amount | DECIMAL(10,2) | Total discount applied to the order |
| payment_method | VARCHAR(100) | Payment method used for the order |
| shipping_method | VARCHAR(100) | Shipping method selected |
| billing_address | VARCHAR(500) | Billing address for the order |
| shipping_address | VARCHAR(500) | Shipping address for the order |
| estimated_delivery_date | DATE | Estimated delivery date |
| actual_delivery_date | DATE | Actual delivery date |
| order_source | VARCHAR(100) | Channel through which order was placed |
| currency_code | VARCHAR(3) | Currency code for the order |
| exchange_rate | DECIMAL(10,4) | Exchange rate applied if applicable |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(100) | Source system that provided the data |

### 2.4 Bz_Order_Items
**Description**: Raw order line item data containing detailed information about each product in an order

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(100) | Reference to the parent order |
| line_item_number | INTEGER | Line item sequence number within the order |
| product_name | VARCHAR(255) | Name of the ordered product |
| quantity_ordered | INTEGER | Quantity of the product ordered |
| unit_price | DECIMAL(10,2) | Price per unit at the time of order |
| line_total | DECIMAL(12,2) | Total amount for this line item |
| discount_applied | DECIMAL(10,2) | Discount applied to this line item |
| tax_amount | DECIMAL(8,2) | Tax amount for this line item |
| product_category | VARCHAR(100) | Category of the ordered product |
| product_brand | VARCHAR(100) | Brand of the ordered product |
| product_size | VARCHAR(50) | Size of the ordered product |
| product_color | VARCHAR(50) | Color of the ordered product |
| fulfillment_status | VARCHAR(50) | Fulfillment status of this line item |
| shipped_date | DATE | Date when this item was shipped |
| delivered_date | DATE | Date when this item was delivered |
| return_eligible | BOOLEAN | Whether this item is eligible for return |
| warranty_period | INTEGER | Warranty period in months |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(100) | Source system that provided the data |

### 2.5 Bz_Payments
**Description**: Raw payment transaction data containing all payment processing information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| payment_transaction_number | VARCHAR(100) | Unique payment transaction identifier |
| order_number | VARCHAR(100) | Reference to the associated order |
| payment_date | TIMESTAMP | Date and time of payment processing |
| payment_amount | DECIMAL(12,2) | Amount processed in this payment |
| payment_method | VARCHAR(100) | Method used for payment |
| payment_status | VARCHAR(50) | Status of the payment transaction |
| currency_code | VARCHAR(3) | Currency of the payment |
| exchange_rate | DECIMAL(10,4) | Exchange rate applied if applicable |
| payment_gateway | VARCHAR(100) | Payment gateway used for processing |
| transaction_fee | DECIMAL(8,2) | Fee charged for the transaction |
| authorization_code | VARCHAR(100) | Payment authorization code |
| payment_reference | VARCHAR(255) | External payment reference number |
| refund_amount | DECIMAL(10,2) | Amount refunded if applicable |
| refund_date | DATE | Date of refund if applicable |
| refund_reason | VARCHAR(255) | Reason for refund if applicable |
| chargeback_amount | DECIMAL(10,2) | Chargeback amount if applicable |
| chargeback_date | DATE | Date of chargeback if applicable |
| risk_score | DECIMAL(5,2) | Fraud risk score for the transaction |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(100) | Source system that provided the data |

### 2.6 Bz_Employees
**Description**: Raw employee data containing all employee information and employment details

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| employee_number | VARCHAR(50) | Unique employee identifier |
| employee_email | VARCHAR(255) | Employee's work email address |
| employee_phone | VARCHAR(20) | Employee's contact phone number |
| employee_first_name | VARCHAR(100) | Employee's first name |
| employee_last_name | VARCHAR(100) | Employee's last name |
| department_name | VARCHAR(100) | Department where employee works |
| job_title | VARCHAR(150) | Employee's job title |
| employment_status | VARCHAR(50) | Current employment status |
| hire_date | DATE | Date when employee was hired |
| termination_date | DATE | Date when employment was terminated |
| salary | DECIMAL(12,2) | Employee's annual salary |
| hourly_rate | DECIMAL(8,2) | Hourly rate if applicable |
| manager_employee_number | VARCHAR(50) | Employee number of direct manager |
| work_location | VARCHAR(255) | Primary work location |
| employment_type | VARCHAR(50) | Type of employment (full-time, part-time, contract) |
| benefits_eligible | BOOLEAN | Whether employee is eligible for benefits |
| performance_rating | VARCHAR(50) | Latest performance rating |
| last_promotion_date | DATE | Date of last promotion |
| training_completion_status | VARCHAR(100) | Status of mandatory training completion |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(100) | Source system that provided the data |

### 2.7 Bz_Suppliers
**Description**: Raw supplier data containing all vendor and supplier information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| supplier_name | VARCHAR(255) | Name of the supplier company |
| supplier_contact_email | VARCHAR(255) | Primary contact email for the supplier |
| supplier_contact_phone | VARCHAR(20) | Primary contact phone for the supplier |
| supplier_address | VARCHAR(500) | Physical address of the supplier |
| supplier_country | VARCHAR(100) | Country where supplier is located |
| supplier_category | VARCHAR(100) | Category of products/services supplied |
| contract_start_date | DATE | Start date of supplier contract |
| contract_end_date | DATE | End date of supplier contract |
| payment_terms | VARCHAR(100) | Payment terms agreed with supplier |
| credit_limit | DECIMAL(15,2) | Credit limit extended to supplier |
| supplier_rating | DECIMAL(3,1) | Performance rating of the supplier |
| quality_certification | VARCHAR(255) | Quality certifications held by supplier |
| preferred_supplier | BOOLEAN | Whether this is a preferred supplier |
| supplier_status | VARCHAR(50) | Current status of supplier relationship |
| tax_identification_number | VARCHAR(100) | Supplier's tax identification number |
| bank_account_details | VARCHAR(255) | Supplier's banking information |
| insurance_coverage | VARCHAR(255) | Insurance coverage details |
| compliance_status | VARCHAR(100) | Regulatory compliance status |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(100) | Source system that provided the data |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit trail for all data processing activities in the Bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique identifier for the audit record |
| source_table | VARCHAR(100) | Name of the source table being processed |
| load_timestamp | TIMESTAMP | Timestamp when the data load process started |
| processed_by | VARCHAR(100) | System or user that processed the data |
| processing_time | DECIMAL(10,3) | Time taken to process the data in seconds |
| status | VARCHAR(50) | Status of the processing (SUCCESS, FAILED, PARTIAL) |
| records_processed | INTEGER | Number of records processed in the operation |
| records_inserted | INTEGER | Number of new records inserted |
| records_updated | INTEGER | Number of existing records updated |
| records_failed | INTEGER | Number of records that failed processing |
| error_message | TEXT | Detailed error message if processing failed |
| data_quality_score | DECIMAL(5,2) | Overall data quality score for the batch |
| source_file_name | VARCHAR(255) | Name of the source file if applicable |
| source_file_size | BIGINT | Size of the source file in bytes |
| checksum | VARCHAR(255) | Checksum of the source data for integrity verification |
| pipeline_run_id | VARCHAR(100) | Identifier for the data pipeline run |
| environment | VARCHAR(50) | Environment where processing occurred (DEV, TEST, PROD) |
| load_type | VARCHAR(50) | Type of load operation (FULL, INCREMENTAL, DELTA) |
| business_date | DATE | Business date for which data is being processed |
| created_timestamp | TIMESTAMP | When this audit record was created |

## 4. Conceptual Data Model Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Bz_Customers  │────▶│    Bz_Orders    │────▶│  Bz_Order_Items │
│                 │     │                 │     │                 │
│ customer_email  │     │ customer_email  │     │ order_number    │
│ first_name      │     │ order_number    │     │ product_name    │
│ last_name       │     │ order_date      │     │ quantity_ordered│
│ date_of_birth   │     │ total_amount    │     │ unit_price      │
│ customer_status │     │ order_status    │     │ line_total      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                        │                        │
         │                        │                        │
         │                        ▼                        │
         │               ┌─────────────────┐               │
         │               │   Bz_Payments   │               │
         │               │                 │               │
         │               │ order_number    │               │
         │               │ payment_amount  │               │
         │               │ payment_method  │               │
         │               │ payment_status  │               │
         │               └─────────────────┘               │
         │                                                 │
         │               ┌─────────────────┐               │
         └──────────────▶│   Bz_Products   │◀──────────────┘
                         │                 │
                         │ product_name    │
                         │ category_name   │
                         │ brand_name      │
                         │ unit_price      │
                         │ stock_quantity  │
                         └─────────────────┘
                                  │
                                  │
                                  ▼
                         ┌─────────────────┐
                         │  Bz_Suppliers   │
                         │                 │
                         │ supplier_name   │
                         │ supplier_contact│
                         │ contract_dates  │
                         │ supplier_rating │
                         └─────────────────┘

                         ┌─────────────────┐
                         │  Bz_Employees   │
                         │                 │
                         │ employee_number │
                         │ employee_email  │
                         │ department_name │
                         │ job_title       │
                         │ employment_status│
                         └─────────────────┘

                         ┌─────────────────┐
                         │  Bz_Audit_Log   │
                         │                 │
                         │ record_id       │
                         │ source_table    │
                         │ load_timestamp  │
                         │ processing_time │
                         │ status          │
                         └─────────────────┘
```

### 4.1 Table Relationships

1. **Bz_Customers → Bz_Orders**: Connected via `customer_email` field
   - One customer can have multiple orders
   - Relationship type: One-to-Many

2. **Bz_Orders → Bz_Order_Items**: Connected via `order_number` field
   - One order can have multiple line items
   - Relationship type: One-to-Many

3. **Bz_Orders → Bz_Payments**: Connected via `order_number` field
   - One order can have multiple payment transactions
   - Relationship type: One-to-Many

4. **Bz_Products → Bz_Order_Items**: Connected via `product_name` field
   - One product can appear in multiple order items
   - Relationship type: One-to-Many

5. **Bz_Suppliers → Bz_Products**: Connected via `supplier_name` field
   - One supplier can supply multiple products
   - Relationship type: One-to-Many

6. **Bz_Employees**: Standalone table for employee management
   - Self-referencing relationship via `manager_employee_number`
   - Relationship type: Self-referencing One-to-Many

7. **Bz_Audit_Log**: Tracks all tables via `source_table` field
   - References all Bronze layer tables for audit purposes
   - Relationship type: Many-to-Many (audit records for all tables)

### 4.2 Key Design Decisions and Rationale

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for clear identification
2. **Data Preservation**: All source data fields preserved without transformation
3. **Metadata Columns**: Consistent metadata columns across all tables for lineage tracking
4. **PII Identification**: Clear classification of sensitive data for compliance
5. **Audit Trail**: Comprehensive audit table for data governance and troubleshooting
6. **Flexible Schema**: VARCHAR fields sized generously to accommodate source system variations
7. **Timestamp Precision**: TIMESTAMP data type used for precise temporal tracking
8. **Currency Handling**: Separate currency code and exchange rate fields for multi-currency support

### 4.3 Assumptions Made

1. Source systems provide data in structured format (JSON, CSV, or database extracts)
2. Customer email serves as a natural business key for customer identification
3. Order numbers are unique across all source systems
4. Product names are sufficiently unique for initial Bronze layer processing
5. All monetary amounts are stored with 2 decimal precision
6. Source systems provide consistent data types for similar fields
7. Audit requirements include detailed processing metrics and error tracking
8. Data retention policies will be applied at the Silver/Gold layers, not Bronze
9. Source system timestamps are in UTC or will be converted to UTC during ingestion
10. PII classification follows GDPR and common data privacy regulations