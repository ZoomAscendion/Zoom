_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Bronze Layer Logical Data Model for Medallion Architecture - Raw Data Ingestion Layer
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### Customer Data
- **customer_email**: Contains personally identifiable email addresses that can be used to identify individuals (GDPR Article 4)
- **customer_phone**: Phone numbers are considered personal data under privacy regulations
- **first_name**: Personal identifier that combined with other data can identify individuals
- **last_name**: Personal identifier that combined with other data can identify individuals
- **date_of_birth**: Sensitive personal data that reveals age and can be used for identity verification
- **address_line_1**: Physical address information is considered PII under most privacy frameworks
- **address_line_2**: Additional address details that enhance location identification
- **city**: Geographic location data that contributes to personal identification
- **state**: Geographic location data that contributes to personal identification
- **postal_code**: Specific location identifier that can narrow down individual residence
- **country**: Geographic identifier for personal location

### Employee Data
- **employee_email**: Work email addresses that identify specific individuals
- **employee_phone**: Personal contact information for employees
- **employee_first_name**: Personal identifier for staff members
- **employee_last_name**: Personal identifier for staff members
- **hire_date**: Employment history information that is personally identifiable

## 2. Bronze Layer Logical Model

### Bz_Customers
**Description**: Raw customer data ingested from source systems without transformation

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_code | VARCHAR(50) | Unique business identifier for customer |
| customer_email | VARCHAR(255) | Customer's email address for communication |
| customer_phone | VARCHAR(20) | Customer's contact phone number |
| first_name | VARCHAR(100) | Customer's first name |
| last_name | VARCHAR(100) | Customer's last name |
| date_of_birth | DATE | Customer's birth date |
| registration_date | TIMESTAMP | Date when customer registered |
| customer_status | VARCHAR(20) | Current status of customer account |
| address_line_1 | VARCHAR(255) | Primary address line |
| address_line_2 | VARCHAR(255) | Secondary address line |
| city | VARCHAR(100) | City of residence |
| state | VARCHAR(100) | State or province |
| postal_code | VARCHAR(20) | Postal or ZIP code |
| country | VARCHAR(100) | Country of residence |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### Bz_Products
**Description**: Raw product catalog data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_code | VARCHAR(50) | Unique business identifier for product |
| product_name | VARCHAR(255) | Name of the product |
| product_description | TEXT | Detailed description of product |
| category_name | VARCHAR(100) | Product category classification |
| brand_name | VARCHAR(100) | Brand or manufacturer name |
| unit_price | DECIMAL(10,2) | Base selling price per unit |
| cost_price | DECIMAL(10,2) | Cost price of the product |
| weight | DECIMAL(8,2) | Product weight in standard units |
| dimensions | VARCHAR(100) | Product dimensions (length x width x height) |
| color | VARCHAR(50) | Product color |
| size | VARCHAR(50) | Product size |
| material | VARCHAR(100) | Primary material composition |
| product_status | VARCHAR(20) | Current status (Active, Discontinued, etc.) |
| launch_date | DATE | Product launch date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### Bz_Orders
**Description**: Raw order transaction data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(50) | Unique business identifier for order |
| customer_code | VARCHAR(50) | Reference to customer who placed order |
| order_date | TIMESTAMP | Date and time when order was placed |
| order_status | VARCHAR(20) | Current status of the order |
| total_amount | DECIMAL(12,2) | Total order value including taxes |
| subtotal_amount | DECIMAL(12,2) | Order subtotal before taxes and fees |
| tax_amount | DECIMAL(10,2) | Total tax amount |
| shipping_amount | DECIMAL(10,2) | Shipping and handling charges |
| discount_amount | DECIMAL(10,2) | Total discount applied |
| payment_method | VARCHAR(50) | Method used for payment |
| shipping_address_line_1 | VARCHAR(255) | Primary shipping address |
| shipping_address_line_2 | VARCHAR(255) | Secondary shipping address |
| shipping_city | VARCHAR(100) | Shipping city |
| shipping_state | VARCHAR(100) | Shipping state or province |
| shipping_postal_code | VARCHAR(20) | Shipping postal code |
| shipping_country | VARCHAR(100) | Shipping country |
| expected_delivery_date | DATE | Expected delivery date |
| actual_delivery_date | DATE | Actual delivery date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### Bz_Order_Items
**Description**: Raw order line item details from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_item_number | VARCHAR(50) | Unique identifier for order line item |
| order_number | VARCHAR(50) | Reference to parent order |
| product_code | VARCHAR(50) | Reference to ordered product |
| quantity_ordered | INTEGER | Number of units ordered |
| unit_price | DECIMAL(10,2) | Price per unit at time of order |
| line_total | DECIMAL(12,2) | Total amount for this line item |
| discount_percentage | DECIMAL(5,2) | Discount percentage applied |
| discount_amount | DECIMAL(10,2) | Discount amount for this line |
| item_status | VARCHAR(20) | Status of this specific item |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### Bz_Inventory
**Description**: Raw inventory level data from warehouse systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| inventory_record_number | VARCHAR(50) | Unique identifier for inventory record |
| product_code | VARCHAR(50) | Reference to product |
| warehouse_code | VARCHAR(50) | Warehouse location identifier |
| quantity_on_hand | INTEGER | Current available quantity |
| quantity_reserved | INTEGER | Quantity reserved for pending orders |
| quantity_on_order | INTEGER | Quantity on order from suppliers |
| reorder_level | INTEGER | Minimum quantity before reorder |
| maximum_stock_level | INTEGER | Maximum quantity to maintain |
| last_stock_count_date | DATE | Date of last physical inventory count |
| inventory_value | DECIMAL(12,2) | Total value of inventory on hand |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### Bz_Suppliers
**Description**: Raw supplier and vendor data from procurement systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| supplier_code | VARCHAR(50) | Unique business identifier for supplier |
| supplier_name | VARCHAR(255) | Legal name of supplier company |
| contact_person | VARCHAR(100) | Primary contact person name |
| contact_email | VARCHAR(255) | Primary contact email address |
| contact_phone | VARCHAR(20) | Primary contact phone number |
| supplier_address_line_1 | VARCHAR(255) | Primary business address |
| supplier_address_line_2 | VARCHAR(255) | Secondary address line |
| supplier_city | VARCHAR(100) | City location |
| supplier_state | VARCHAR(100) | State or province |
| supplier_postal_code | VARCHAR(20) | Postal code |
| supplier_country | VARCHAR(100) | Country |
| supplier_status | VARCHAR(20) | Current supplier status |
| payment_terms | VARCHAR(100) | Standard payment terms |
| credit_limit | DECIMAL(12,2) | Credit limit extended |
| tax_identification_number | VARCHAR(50) | Tax ID or VAT number |
| contract_start_date | DATE | Contract effective date |
| contract_end_date | DATE | Contract expiration date |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

### Bz_Employees
**Description**: Raw employee data from HR systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| employee_code | VARCHAR(50) | Unique business identifier for employee |
| employee_email | VARCHAR(255) | Work email address |
| employee_phone | VARCHAR(20) | Work contact number |
| employee_first_name | VARCHAR(100) | Employee first name |
| employee_last_name | VARCHAR(100) | Employee last name |
| job_title | VARCHAR(100) | Current job title |
| department_name | VARCHAR(100) | Department assignment |
| manager_employee_code | VARCHAR(50) | Reference to manager |
| hire_date | DATE | Date of employment start |
| employment_status | VARCHAR(20) | Current employment status |
| salary_amount | DECIMAL(10,2) | Current salary amount |
| work_location | VARCHAR(100) | Primary work location |
| load_timestamp | TIMESTAMP | When record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | When record was last updated |
| source_system | VARCHAR(50) | Source system identifier |

## 3. Audit Table Design

### Bz_Audit_Log
**Description**: Comprehensive audit trail for all Bronze layer data processing activities

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique identifier for audit record |
| source_table | VARCHAR(100) | Name of the source table being processed |
| load_timestamp | TIMESTAMP | When the data load process started |
| processed_by | VARCHAR(100) | System or user that processed the data |
| processing_time | INTEGER | Time taken to process in seconds |
| status | VARCHAR(20) | Processing status (SUCCESS, FAILED, PARTIAL) |
| records_processed | INTEGER | Number of records processed |
| records_inserted | INTEGER | Number of new records inserted |
| records_updated | INTEGER | Number of existing records updated |
| records_failed | INTEGER | Number of records that failed processing |
| error_message | TEXT | Detailed error message if processing failed |
| batch_id | VARCHAR(100) | Batch identifier for grouping related processes |
| source_file_name | VARCHAR(255) | Name of source file if applicable |
| source_file_size | BIGINT | Size of source file in bytes |
| checksum | VARCHAR(100) | Data integrity checksum |
| load_type | VARCHAR(20) | Type of load (FULL, INCREMENTAL, DELTA) |
| start_timestamp | TIMESTAMP | Process start time |
| end_timestamp | TIMESTAMP | Process completion time |

## 4. Conceptual Data Model Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Bz_Customers  │────▶│   Bz_Orders     │────▶│ Bz_Order_Items  │
│                 │     │                 │     │                 │
│ customer_code   │     │ customer_code   │     │ order_number    │
│ customer_email  │     │ order_number    │     │ product_code    │
│ first_name      │     │ order_date      │     │ quantity_ordered│
│ last_name       │     │ total_amount    │     │ unit_price      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                          │
                                                          ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Bz_Suppliers   │────▶│  Bz_Products    │◀────│  Bz_Inventory   │
│                 │     │                 │     │                 │
│ supplier_code   │     │ product_code    │     │ product_code    │
│ supplier_name   │     │ product_name    │     │ warehouse_code  │
│ contact_person  │     │ category_name   │     │ quantity_on_hand│
│ contact_email   │     │ unit_price      │     │ reorder_level   │
└─────────────────┘     └─────────────────┘     └─────────────────┘

┌─────────────────┐     ┌─────────────────┐
│  Bz_Employees   │     │  Bz_Audit_Log   │
│                 │     │                 │
│ employee_code   │     │ record_id       │
│ employee_email  │     │ source_table    │
│ job_title       │     │ load_timestamp  │
│ department_name │     │ status          │
└─────────────────┘     └─────────────────┘
```

### **Table Relationships:**

1. **Bz_Customers → Bz_Orders**: Connected by `customer_code`
   - One customer can have multiple orders

2. **Bz_Orders → Bz_Order_Items**: Connected by `order_number`
   - One order can have multiple line items

3. **Bz_Products → Bz_Order_Items**: Connected by `product_code`
   - One product can appear in multiple order items

4. **Bz_Products → Bz_Inventory**: Connected by `product_code`
   - One product can have inventory in multiple warehouses

5. **Bz_Suppliers → Bz_Products**: Connected by `supplier_code` (implied relationship)
   - One supplier can supply multiple products

6. **Bz_Employees**: Standalone entity for HR data
   - Self-referencing through `manager_employee_code`

7. **Bz_Audit_Log**: Tracks all table processing activities
   - References all tables through `source_table` field

### **Design Rationale:**

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for clear identification
2. **Data Preservation**: All source data fields preserved without transformation
3. **Metadata Columns**: Consistent audit fields across all tables for data lineage
4. **PII Identification**: Clear classification of sensitive data for compliance
5. **Scalability**: Design supports high-volume data ingestion with minimal processing
6. **Audit Trail**: Comprehensive logging for data governance and troubleshooting

### **Key Assumptions:**

1. Source systems provide consistent data formats
2. Business keys (codes) are unique within their respective domains
3. All timestamps are in UTC for consistency
4. Source systems support incremental data extraction
5. Data quality issues will be addressed in Silver layer processing