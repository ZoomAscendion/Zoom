_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Medallion Architecture - Raw Data Ingestion Layer
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Customer Data
- **customer_email**: Contains personal email addresses - PII as it can directly identify individuals
- **customer_phone**: Contains personal phone numbers - PII as it can directly identify individuals
- **customer_name**: Contains personal names - PII as it directly identifies individuals
- **customer_address**: Contains residential addresses - PII as it can identify individual locations
- **date_of_birth**: Contains birth dates - PII as it's sensitive personal information
- **social_security_number**: Contains SSN - PII as it's a government identifier

### 1.2 Employee Data
- **employee_email**: Contains work email addresses - PII as it can identify individuals
- **employee_phone**: Contains personal/work phone numbers - PII as it can identify individuals
- **employee_name**: Contains personal names - PII as it directly identifies individuals
- **employee_address**: Contains residential addresses - PII as it can identify individual locations
- **salary**: Contains compensation information - PII as it's sensitive financial data

### 1.3 Transaction Data
- **credit_card_number**: Contains payment card information - PII as it's sensitive financial data
- **bank_account_number**: Contains banking information - PII as it's sensitive financial data
- **ip_address**: Contains network identifiers - PII as it can potentially identify individuals

## 2. Bronze Layer Logical Model

### 2.1 Customer Management Tables

#### 2.1.1 Bz_Customers
**Description**: Raw customer data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Customer's primary email address |
| customer_phone | VARCHAR(20) | Customer's contact phone number |
| customer_name | VARCHAR(100) | Customer's full name |
| customer_address | VARCHAR(500) | Customer's residential address |
| date_of_birth | DATE | Customer's date of birth |
| registration_date | TIMESTAMP | Date when customer registered |
| customer_status | VARCHAR(20) | Current status of customer account |
| preferred_language | VARCHAR(10) | Customer's preferred language |
| marketing_consent | BOOLEAN | Customer's marketing consent flag |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

#### 2.1.2 Bz_Customer_Preferences
**Description**: Raw customer preference data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Reference to customer |
| preference_type | VARCHAR(50) | Type of preference (notification, privacy, etc.) |
| preference_value | VARCHAR(100) | Value of the preference |
| preference_date | TIMESTAMP | When preference was set |
| is_active | BOOLEAN | Whether preference is currently active |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.2 Product Management Tables

#### 2.2.1 Bz_Products
**Description**: Raw product catalog data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_code | VARCHAR(50) | Unique product identifier |
| product_name | VARCHAR(200) | Product name |
| product_description | TEXT | Detailed product description |
| category | VARCHAR(100) | Product category |
| subcategory | VARCHAR(100) | Product subcategory |
| brand | VARCHAR(100) | Product brand |
| unit_price | DECIMAL(10,2) | Base unit price |
| currency | VARCHAR(3) | Currency code |
| weight | DECIMAL(8,2) | Product weight |
| dimensions | VARCHAR(100) | Product dimensions |
| availability_status | VARCHAR(20) | Current availability status |
| launch_date | DATE | Product launch date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

#### 2.2.2 Bz_Product_Inventory
**Description**: Raw inventory data for products

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_code | VARCHAR(50) | Reference to product |
| warehouse_location | VARCHAR(100) | Warehouse identifier |
| quantity_available | INTEGER | Available quantity |
| quantity_reserved | INTEGER | Reserved quantity |
| reorder_level | INTEGER | Minimum stock level |
| last_restock_date | DATE | Last restocking date |
| expiry_date | DATE | Product expiry date (if applicable) |
| batch_number | VARCHAR(50) | Manufacturing batch number |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.3 Transaction Management Tables

#### 2.3.1 Bz_Orders
**Description**: Raw order transaction data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(50) | Unique order identifier |
| customer_email | VARCHAR(255) | Reference to customer |
| order_date | TIMESTAMP | When order was placed |
| order_status | VARCHAR(20) | Current order status |
| total_amount | DECIMAL(12,2) | Total order amount |
| currency | VARCHAR(3) | Currency code |
| payment_method | VARCHAR(50) | Payment method used |
| shipping_address | VARCHAR(500) | Delivery address |
| billing_address | VARCHAR(500) | Billing address |
| discount_applied | DECIMAL(10,2) | Discount amount |
| tax_amount | DECIMAL(10,2) | Tax amount |
| shipping_cost | DECIMAL(8,2) | Shipping cost |
| estimated_delivery | DATE | Estimated delivery date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

#### 2.3.2 Bz_Order_Items
**Description**: Raw order line item data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(50) | Reference to order |
| line_item_number | INTEGER | Line item sequence number |
| product_code | VARCHAR(50) | Reference to product |
| quantity_ordered | INTEGER | Quantity ordered |
| unit_price | DECIMAL(10,2) | Unit price at time of order |
| line_total | DECIMAL(12,2) | Total for this line item |
| discount_percent | DECIMAL(5,2) | Discount percentage applied |
| special_instructions | TEXT | Special handling instructions |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

#### 2.3.3 Bz_Payments
**Description**: Raw payment transaction data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| payment_transaction_id | VARCHAR(100) | Unique payment identifier |
| order_number | VARCHAR(50) | Reference to order |
| payment_date | TIMESTAMP | When payment was processed |
| payment_amount | DECIMAL(12,2) | Payment amount |
| currency | VARCHAR(3) | Currency code |
| payment_method | VARCHAR(50) | Payment method (credit card, bank transfer, etc.) |
| payment_status | VARCHAR(20) | Payment status |
| gateway_response | VARCHAR(100) | Payment gateway response |
| transaction_fee | DECIMAL(8,2) | Transaction processing fee |
| refund_amount | DECIMAL(12,2) | Refunded amount (if any) |
| refund_date | TIMESTAMP | Refund processing date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.4 Employee Management Tables

#### 2.4.1 Bz_Employees
**Description**: Raw employee data from HR systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| employee_number | VARCHAR(20) | Unique employee identifier |
| employee_name | VARCHAR(100) | Employee's full name |
| employee_email | VARCHAR(255) | Employee's work email |
| employee_phone | VARCHAR(20) | Employee's contact number |
| department | VARCHAR(100) | Employee's department |
| job_title | VARCHAR(100) | Employee's job title |
| manager_employee_number | VARCHAR(20) | Reference to manager |
| hire_date | DATE | Employee hire date |
| employment_status | VARCHAR(20) | Current employment status |
| work_location | VARCHAR(100) | Primary work location |
| salary_band | VARCHAR(10) | Salary band classification |
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
| load_timestamp | TIMESTAMP | When the data load operation occurred |
| processed_by | VARCHAR(100) | System or user that processed the data |
| processing_time | DECIMAL(10,3) | Time taken to process in seconds |
| status | VARCHAR(20) | Status of the operation (SUCCESS, FAILED, PARTIAL) |
| record_count | INTEGER | Number of records processed |
| error_count | INTEGER | Number of records that failed processing |
| error_details | TEXT | Detailed error information if applicable |
| data_source | VARCHAR(100) | Original data source system |
| batch_id | VARCHAR(100) | Batch identifier for grouped operations |
| checksum | VARCHAR(64) | Data integrity checksum |
| operation_type | VARCHAR(20) | Type of operation (INSERT, UPDATE, DELETE) |

## 4. Conceptual Data Model Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Bz_Customers  │────▶│    Bz_Orders    │────▶│  Bz_Order_Items │
│                 │     │                 │     │                 │
│ customer_email  │     │ customer_email  │     │ order_number    │
│ customer_name   │     │ order_number    │     │ product_code    │
│ customer_phone  │     │ order_date      │     │ quantity_ordered│
│ customer_address│     │ total_amount    │     │ unit_price      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                        │                        │
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│Bz_Customer_Prefs│     │   Bz_Payments   │     │   Bz_Products   │
│                 │     │                 │     │                 │
│ customer_email  │     │ order_number    │     │ product_code    │
│ preference_type │     │ payment_amount  │     │ product_name    │
│ preference_value│     │ payment_status  │     │ category        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                          │
                                                          │
                                                          ▼
┌─────────────────┐                            ┌─────────────────┐
│  Bz_Employees   │                            │Bz_Product_Invent│
│                 │                            │                 │
│ employee_number │                            │ product_code    │
│ employee_name   │                            │ warehouse_loc   │
│ department      │                            │ quantity_avail  │
│ manager_emp_num │◄──────────────────────────┤│ reorder_level   │
└─────────────────┘                            └─────────────────┘

                    ┌─────────────────┐
                    │  Bz_Audit_Log   │
                    │                 │
                    │ record_id       │
                    │ source_table    │
                    │ load_timestamp  │
                    │ processed_by    │
                    │ status          │
                    └─────────────────┘
```

### 4.1 Table Relationships

1. **Bz_Customers → Bz_Orders**: Connected via `customer_email`
2. **Bz_Orders → Bz_Order_Items**: Connected via `order_number`
3. **Bz_Orders → Bz_Payments**: Connected via `order_number`
4. **Bz_Order_Items → Bz_Products**: Connected via `product_code`
5. **Bz_Products → Bz_Product_Inventory**: Connected via `product_code`
6. **Bz_Customers → Bz_Customer_Preferences**: Connected via `customer_email`
7. **Bz_Employees → Bz_Employees**: Self-referencing via `manager_employee_number`
8. **Bz_Audit_Log**: Tracks all tables via `source_table` field

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for clear identification
2. **Metadata Columns**: Consistent metadata columns across all tables for data lineage
3. **Data Types**: Conservative data type sizing to accommodate various source systems
4. **PII Handling**: Clear identification of PII fields for compliance and governance
5. **Audit Trail**: Comprehensive audit logging for data quality and compliance

### 5.2 Assumptions Made

1. **Source Systems**: Assumed multiple source systems feeding into Bronze layer
2. **Data Volume**: Designed for high-volume transactional data
3. **Data Quality**: Raw data may contain inconsistencies requiring downstream cleansing
4. **Compliance**: GDPR and similar privacy regulations apply
5. **Scalability**: Model designed to handle growing data volumes and new source systems

### 5.3 Implementation Considerations

1. **Partitioning**: Consider partitioning large tables by load_timestamp
2. **Indexing**: Create indexes on frequently queried columns
3. **Data Retention**: Implement appropriate data retention policies
4. **Security**: Apply row-level security for PII data access
5. **Monitoring**: Implement data quality monitoring and alerting

---

**Output URL**: https://github.com/ZoomAscendion/Zoom/tree/Agent_Output/Bronze_DataModel_Mapping_Workbench

**Pipeline ID**: 8285