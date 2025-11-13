_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Bronze Layer Logical Data Model for Medallion Architecture
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### Customer Data
- **customer_email**: Contains personal email addresses that can identify individuals (GDPR Article 4)
- **customer_phone**: Phone numbers are personal identifiers under privacy regulations
- **first_name**: Personal identifier that can be used to identify individuals
- **last_name**: Personal identifier that can be used to identify individuals
- **date_of_birth**: Sensitive personal data that reveals age and can be used for identification
- **address_line_1**: Physical address is personal data under GDPR
- **address_line_2**: Physical address is personal data under GDPR
- **city**: Part of address information that can identify location
- **state**: Part of address information that can identify location
- **postal_code**: Part of address information that can identify location
- **country**: Part of address information that can identify location

### Employee Data
- **employee_email**: Work email addresses that can identify individuals
- **employee_phone**: Personal contact information
- **employee_first_name**: Personal identifier
- **employee_last_name**: Personal identifier
- **social_security_number**: Highly sensitive personal identifier
- **employee_address**: Physical address information
- **emergency_contact_name**: Personal information of related individuals
- **emergency_contact_phone**: Personal contact information of related individuals

## 2. Bronze Layer Logical Model

### Bz_Customers
**Description**: Raw customer data from source systems containing customer registration and profile information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Customer's email address used for communication and login |
| customer_phone | VARCHAR(20) | Customer's primary contact phone number |
| first_name | VARCHAR(100) | Customer's first name as provided during registration |
| last_name | VARCHAR(100) | Customer's last name as provided during registration |
| date_of_birth | DATE | Customer's date of birth for age verification and marketing |
| registration_date | TIMESTAMP | Date and time when customer registered |
| customer_status | VARCHAR(50) | Current status of customer account (Active, Inactive, Suspended) |
| preferred_language | VARCHAR(10) | Customer's preferred language for communication |
| marketing_opt_in | BOOLEAN | Customer's consent for marketing communications |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(100) | Source system from which data originated |

### Bz_Customer_Addresses
**Description**: Raw customer address information from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Reference to customer email |
| address_type | VARCHAR(50) | Type of address (Billing, Shipping, Home) |
| address_line_1 | VARCHAR(255) | Primary address line |
| address_line_2 | VARCHAR(255) | Secondary address line (apartment, suite, etc.) |
| city | VARCHAR(100) | City name |
| state | VARCHAR(100) | State or province name |
| postal_code | VARCHAR(20) | Postal or ZIP code |
| country | VARCHAR(100) | Country name |
| is_default | BOOLEAN | Indicates if this is the default address |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(100) | Source system from which data originated |

### Bz_Products
**Description**: Raw product catalog data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_name | VARCHAR(255) | Name of the product |
| product_description | TEXT | Detailed description of the product |
| category_name | VARCHAR(100) | Product category classification |
| subcategory_name | VARCHAR(100) | Product subcategory classification |
| brand_name | VARCHAR(100) | Brand or manufacturer name |
| unit_price | DECIMAL(10,2) | Base price per unit |
| currency_code | VARCHAR(3) | Currency code (USD, EUR, etc.) |
| weight | DECIMAL(8,2) | Product weight |
| weight_unit | VARCHAR(10) | Unit of weight measurement |
| dimensions | VARCHAR(100) | Product dimensions |
| color | VARCHAR(50) | Product color |
| size | VARCHAR(50) | Product size |
| material | VARCHAR(100) | Product material composition |
| availability_status | VARCHAR(50) | Current availability status |
| launch_date | DATE | Product launch date |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(100) | Source system from which data originated |

### Bz_Orders
**Description**: Raw order transaction data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(100) | Unique order identifier |
| customer_email | VARCHAR(255) | Customer who placed the order |
| order_date | TIMESTAMP | Date and time when order was placed |
| order_status | VARCHAR(50) | Current status of the order |
| total_amount | DECIMAL(12,2) | Total order amount including taxes |
| subtotal_amount | DECIMAL(12,2) | Order subtotal before taxes and fees |
| tax_amount | DECIMAL(10,2) | Total tax amount |
| shipping_amount | DECIMAL(10,2) | Shipping charges |
| discount_amount | DECIMAL(10,2) | Total discount applied |
| currency_code | VARCHAR(3) | Currency code for the order |
| payment_method | VARCHAR(50) | Payment method used |
| shipping_method | VARCHAR(100) | Shipping method selected |
| billing_address | TEXT | Billing address information |
| shipping_address | TEXT | Shipping address information |
| order_notes | TEXT | Special instructions or notes |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(100) | Source system from which data originated |

### Bz_Order_Items
**Description**: Raw order line item data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | VARCHAR(100) | Reference to the order |
| line_item_number | INTEGER | Line item sequence number |
| product_name | VARCHAR(255) | Product ordered |
| quantity | INTEGER | Quantity ordered |
| unit_price | DECIMAL(10,2) | Price per unit at time of order |
| line_total | DECIMAL(12,2) | Total amount for this line item |
| discount_applied | DECIMAL(10,2) | Discount applied to this line item |
| product_variant | VARCHAR(100) | Specific variant (size, color, etc.) |
| fulfillment_status | VARCHAR(50) | Fulfillment status of this item |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(100) | Source system from which data originated |

### Bz_Employees
**Description**: Raw employee data from HR systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| employee_number | VARCHAR(50) | Unique employee identifier |
| employee_email | VARCHAR(255) | Employee's work email address |
| employee_phone | VARCHAR(20) | Employee's contact phone number |
| employee_first_name | VARCHAR(100) | Employee's first name |
| employee_last_name | VARCHAR(100) | Employee's last name |
| department | VARCHAR(100) | Department where employee works |
| job_title | VARCHAR(100) | Employee's job title |
| hire_date | DATE | Date when employee was hired |
| employment_status | VARCHAR(50) | Current employment status |
| manager_employee_number | VARCHAR(50) | Employee number of direct manager |
| salary | DECIMAL(12,2) | Employee's current salary |
| employee_address | TEXT | Employee's home address |
| emergency_contact_name | VARCHAR(200) | Emergency contact person name |
| emergency_contact_phone | VARCHAR(20) | Emergency contact phone number |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(100) | Source system from which data originated |

### Bz_Inventory
**Description**: Raw inventory and stock level data from warehouse systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_name | VARCHAR(255) | Product being tracked |
| warehouse_location | VARCHAR(100) | Warehouse or store location |
| quantity_on_hand | INTEGER | Current quantity available |
| quantity_reserved | INTEGER | Quantity reserved for pending orders |
| quantity_available | INTEGER | Quantity available for new orders |
| reorder_point | INTEGER | Minimum quantity before reordering |
| reorder_quantity | INTEGER | Standard reorder quantity |
| last_received_date | DATE | Date of last inventory receipt |
| last_sold_date | DATE | Date of last sale |
| cost_per_unit | DECIMAL(10,2) | Current cost per unit |
| inventory_value | DECIMAL(12,2) | Total value of inventory on hand |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(100) | Source system from which data originated |

## 3. Audit Table Design

### Bz_Audit_Log
**Description**: Comprehensive audit trail for all Bronze layer data processing activities

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique identifier for the audit record |
| source_table | VARCHAR(100) | Name of the source table being processed |
| load_timestamp | TIMESTAMP | Timestamp when the data load process started |
| processed_by | VARCHAR(100) | System or user that processed the data |
| processing_time | DECIMAL(10,3) | Time taken to process in seconds |
| status | VARCHAR(50) | Processing status (Success, Failed, Warning) |
| records_processed | INTEGER | Number of records processed |
| records_inserted | INTEGER | Number of new records inserted |
| records_updated | INTEGER | Number of existing records updated |
| records_failed | INTEGER | Number of records that failed processing |
| error_message | TEXT | Error message if processing failed |
| batch_id | VARCHAR(100) | Batch identifier for grouping related processes |
| source_file_name | VARCHAR(255) | Name of source file if applicable |
| source_file_size | BIGINT | Size of source file in bytes |
| checksum | VARCHAR(255) | Data integrity checksum |

## 4. Conceptual Data Model Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Bz_Customers  │────▶│Bz_Customer_Addr │     │   Bz_Products   │
│                 │     │                 │     │                 │
│ customer_email  │     │ customer_email  │     │ product_name    │
│ first_name      │     │ address_line_1  │     │ category_name   │
│ last_name       │     │ city            │     │ unit_price      │
│ phone           │     │ state           │     │ brand_name      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                                               │
         │                                               │
         ▼                                               ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Bz_Orders     │────▶│ Bz_Order_Items  │────▶│  Bz_Inventory   │
│                 │     │                 │     │                 │
│ order_number    │     │ order_number    │     │ product_name    │
│ customer_email  │     │ product_name    │     │ warehouse_loc   │
│ order_date      │     │ quantity        │     │ quantity_on_hand│
│ total_amount    │     │ unit_price      │     │ reorder_point   │
└─────────────────┘     └─────────────────┘     └─────────────────┘

┌─────────────────┐     ┌─────────────────┐
│  Bz_Employees   │     │  Bz_Audit_Log   │
│                 │     │                 │
│ employee_number │     │ record_id       │
│ employee_email  │     │ source_table    │
│ department      │     │ load_timestamp  │
│ manager_emp_num │────▶│ processed_by    │
└─────────────────┘     └─────────────────┘
```

### **Relationship Connections:**

1. **Bz_Customers ↔ Bz_Customer_Addresses**
   - Connection: `customer_email`
   - Relationship: One customer can have multiple addresses

2. **Bz_Customers ↔ Bz_Orders**
   - Connection: `customer_email`
   - Relationship: One customer can place multiple orders

3. **Bz_Orders ↔ Bz_Order_Items**
   - Connection: `order_number`
   - Relationship: One order can contain multiple line items

4. **Bz_Products ↔ Bz_Order_Items**
   - Connection: `product_name`
   - Relationship: One product can appear in multiple order items

5. **Bz_Products ↔ Bz_Inventory**
   - Connection: `product_name`
   - Relationship: One product can have inventory in multiple locations

6. **Bz_Employees ↔ Bz_Employees (Self-Reference)**
   - Connection: `manager_employee_number` → `employee_number`
   - Relationship: Hierarchical manager-employee relationship

7. **All Tables ↔ Bz_Audit_Log**
   - Connection: `source_table` references table names
   - Relationship: All tables have audit trail entries

---

**Design Rationale:**

1. **Naming Convention**: All Bronze layer tables use 'Bz_' prefix for consistent identification
2. **Data Preservation**: Source data structure is mirrored exactly without transformation
3. **Metadata Columns**: Standard load_timestamp, update_timestamp, and source_system columns added to all tables
4. **PII Classification**: Comprehensive identification of sensitive data for compliance
5. **Audit Trail**: Complete tracking of all data processing activities for governance
6. **Scalability**: Design supports multiple source systems and batch processing

**Key Assumptions:**

1. Source systems provide consistent data formats
2. Customer email serves as natural key for customer identification
3. Product names are unique identifiers in source systems
4. Order numbers are unique across all source systems
5. Employee numbers are unique organizational identifiers