_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Bronze Layer Logical Data Model for Medallion Architecture
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Customer Data
- **customer_email**: Contains personal email addresses - classified as PII under GDPR Article 4(1) as it can identify a natural person
- **customer_phone**: Contains personal phone numbers - classified as PII as it's a direct identifier
- **customer_name**: Contains full names - classified as PII as it directly identifies individuals
- **customer_address**: Contains residential addresses - classified as PII as it can locate and identify individuals
- **date_of_birth**: Contains birth dates - classified as PII as it's personal demographic information
- **social_security_number**: Contains SSN - classified as sensitive PII requiring highest protection

### 1.2 Employee Data
- **employee_email**: Contains work email addresses - classified as PII as it identifies employees
- **employee_phone**: Contains employee contact numbers - classified as PII
- **employee_name**: Contains employee full names - classified as PII
- **employee_address**: Contains employee addresses - classified as PII
- **salary**: Contains compensation information - classified as sensitive PII

### 1.3 Transaction Data
- **credit_card_number**: Contains payment card information - classified as sensitive PII under PCI DSS
- **bank_account_number**: Contains banking details - classified as sensitive financial PII

## 2. Bronze Layer Logical Model

### 2.1 Customer Tables

#### Bz_Customer_Profile
**Description**: Raw customer profile data from source systems

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
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

#### Bz_Customer_Preferences
**Description**: Raw customer preference and settings data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Reference to customer |
| preference_type | VARCHAR(50) | Type of preference setting |
| preference_value | VARCHAR(200) | Value of the preference |
| notification_opt_in | BOOLEAN | Email notification preference |
| marketing_consent | BOOLEAN | Marketing communication consent |
| data_sharing_consent | BOOLEAN | Data sharing agreement status |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.2 Product Tables

#### Bz_Product_Catalog
**Description**: Raw product information from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_code | VARCHAR(50) | Unique product identifier |
| product_name | VARCHAR(200) | Product display name |
| product_description | TEXT | Detailed product description |
| category_name | VARCHAR(100) | Product category |
| brand_name | VARCHAR(100) | Product brand |
| unit_price | DECIMAL(10,2) | Base unit price |
| currency_code | VARCHAR(3) | Currency for pricing |
| availability_status | VARCHAR(20) | Current availability status |
| launch_date | DATE | Product launch date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

#### Bz_Product_Inventory
**Description**: Raw inventory data from warehouse systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_code | VARCHAR(50) | Reference to product |
| warehouse_location | VARCHAR(100) | Warehouse identifier |
| quantity_available | INTEGER | Current available quantity |
| quantity_reserved | INTEGER | Reserved quantity |
| reorder_level | INTEGER | Minimum stock level |
| last_restock_date | DATE | Last restocking date |
| expiry_date | DATE | Product expiry date if applicable |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.3 Transaction Tables

#### Bz_Sales_Orders
**Description**: Raw sales order data from e-commerce and POS systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(50) | Unique order identifier |
| customer_email | VARCHAR(255) | Reference to customer |
| order_date | TIMESTAMP | When order was placed |
| order_status | VARCHAR(20) | Current order status |
| total_amount | DECIMAL(12,2) | Total order amount |
| currency_code | VARCHAR(3) | Order currency |
| payment_method | VARCHAR(50) | Payment method used |
| shipping_address | VARCHAR(500) | Delivery address |
| shipping_method | VARCHAR(50) | Shipping method selected |
| discount_amount | DECIMAL(10,2) | Total discount applied |
| tax_amount | DECIMAL(10,2) | Tax amount |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

#### Bz_Order_Line_Items
**Description**: Raw order line item details

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(50) | Reference to sales order |
| line_item_number | INTEGER | Line item sequence number |
| product_code | VARCHAR(50) | Reference to product |
| quantity_ordered | INTEGER | Quantity of product ordered |
| unit_price | DECIMAL(10,2) | Price per unit |
| line_total | DECIMAL(12,2) | Total for this line item |
| discount_percentage | DECIMAL(5,2) | Discount percentage applied |
| tax_rate | DECIMAL(5,2) | Tax rate applied |
| fulfillment_status | VARCHAR(20) | Fulfillment status of line item |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### 2.4 Employee Tables

#### Bz_Employee_Master
**Description**: Raw employee master data from HR systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| employee_number | VARCHAR(20) | Unique employee identifier |
| employee_name | VARCHAR(100) | Employee full name |
| employee_email | VARCHAR(255) | Employee work email |
| employee_phone | VARCHAR(20) | Employee contact number |
| department_name | VARCHAR(100) | Department assignment |
| job_title | VARCHAR(100) | Current job title |
| manager_employee_number | VARCHAR(20) | Reference to manager |
| hire_date | DATE | Employee hire date |
| employment_status | VARCHAR(20) | Current employment status |
| salary | DECIMAL(12,2) | Current salary |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

## 3. Audit Table Design

### Bz_Data_Audit_Log
**Description**: Comprehensive audit trail for all Bronze layer data operations

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique identifier for audit record |
| source_table | VARCHAR(100) | Name of the source table being audited |
| load_timestamp | TIMESTAMP | When the data load operation occurred |
| processed_by | VARCHAR(100) | System or user that processed the data |
| processing_time | DECIMAL(10,3) | Time taken to process in seconds |
| status | VARCHAR(20) | Status of the operation (SUCCESS, FAILED, PARTIAL) |
| record_count | INTEGER | Number of records processed |
| error_message | TEXT | Error details if status is FAILED |
| source_file_path | VARCHAR(500) | Path to source file if applicable |
| checksum | VARCHAR(64) | Data integrity checksum |
| operation_type | VARCHAR(20) | Type of operation (INSERT, UPDATE, DELETE) |

## 4. Conceptual Data Model Diagram

```
┌─────────────────────┐
│   Bz_Customer_      │
│     Profile         │
│                     │
│ • customer_email    │◄──┐
│ • customer_name     │   │
│ • customer_phone    │   │
│ • customer_address  │   │
└─────────────────────┘   │
                          │
                          │ customer_email
                          │
┌─────────────────────┐   │
│  Bz_Customer_       │   │
│   Preferences       │   │
│                     │   │
│ • customer_email    │───┘
│ • preference_type   │
│ • preference_value  │
└─────────────────────┘

┌─────────────────────┐
│   Bz_Sales_Orders   │
│                     │
│ • order_number      │◄──┐
│ • customer_email    │───┼─── customer_email ──► Bz_Customer_Profile
│ • order_date        │   │
│ • total_amount      │   │
└─────────────────────┘   │
                          │ order_number
                          │
┌─────────────────────┐   │
│  Bz_Order_Line_     │   │
│     Items           │   │
│                     │   │
│ • order_number      │───┘
│ • product_code      │───┐
│ • quantity_ordered  │   │
│ • unit_price        │   │
└─────────────────────┘   │
                          │ product_code
                          │
┌─────────────────────┐   │
│  Bz_Product_        │   │
│    Catalog          │   │
│                     │   │
│ • product_code      │◄──┘
│ • product_name      │
│ • category_name     │
│ • unit_price        │
└─────────────────────┘

┌─────────────────────┐
│  Bz_Product_        │
│   Inventory         │
│                     │
│ • product_code      │───── product_code ──► Bz_Product_Catalog
│ • warehouse_location│
│ • quantity_available│
└─────────────────────┘

┌─────────────────────┐
│  Bz_Employee_       │
│    Master           │
│                     │
│ • employee_number   │◄──┐
│ • employee_name     │   │ manager_employee_number
│ • manager_emp_num   │───┘ (self-referencing)
│ • department_name   │
└─────────────────────┘

┌─────────────────────┐
│  Bz_Data_Audit_Log  │
│                     │
│ • record_id         │
│ • source_table      │ ──── References all Bronze tables
│ • load_timestamp    │
│ • status            │
└─────────────────────┘
```

### Key Relationships:

1. **Customer Profile ↔ Customer Preferences**: Connected via `customer_email`
2. **Customer Profile ↔ Sales Orders**: Connected via `customer_email`
3. **Sales Orders ↔ Order Line Items**: Connected via `order_number`
4. **Product Catalog ↔ Order Line Items**: Connected via `product_code`
5. **Product Catalog ↔ Product Inventory**: Connected via `product_code`
6. **Employee Master**: Self-referencing via `manager_employee_number`
7. **Audit Log**: References all tables via `source_table` field

### Design Rationale:

1. **Naming Convention**: All Bronze tables prefixed with 'Bz_' for clear identification
2. **Metadata Columns**: Consistent `load_timestamp`, `update_timestamp`, and `source_system` across all tables
3. **PII Handling**: Sensitive fields identified and documented for proper governance
4. **Audit Trail**: Comprehensive logging for data lineage and compliance
5. **Data Types**: Appropriate sizing for scalability and performance
6. **Relationships**: Maintained through business keys rather than technical primary keys

### Assumptions Made:

1. Source systems provide data in structured format
2. Customer email serves as primary business identifier
3. Product codes are unique across all product lines
4. Order numbers are globally unique
5. Employee numbers follow organizational standards
6. All timestamps are in UTC format
7. Currency codes follow ISO 4217 standard