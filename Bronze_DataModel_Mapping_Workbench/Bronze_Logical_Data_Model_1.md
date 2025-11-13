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
- **customer_email**: Contains personal email addresses - classified as PII under GDPR Article 4
- **customer_phone**: Contains personal phone numbers - classified as PII for direct contact identification
- **customer_name**: Contains personal names - classified as PII for individual identification
- **customer_address**: Contains residential addresses - classified as PII for location identification
- **date_of_birth**: Contains birth dates - classified as sensitive PII for age/identity verification
- **social_security_number**: Contains SSN - classified as highly sensitive PII for identity theft prevention

### 1.2 Employee Data
- **employee_email**: Contains work email addresses - classified as PII for individual identification
- **employee_phone**: Contains personal/work phone numbers - classified as PII for direct contact
- **employee_name**: Contains personal names - classified as PII for individual identification
- **employee_address**: Contains residential addresses - classified as PII for location identification
- **salary**: Contains compensation information - classified as sensitive data for privacy protection

### 1.3 Transaction Data
- **payment_method**: Contains payment information - classified as PII for financial privacy
- **account_number**: Contains financial account details - classified as highly sensitive PII for fraud prevention

## 2. Bronze Layer Logical Model

### 2.1 Customer Tables

#### Bz_Customer_Profile
**Description**: Raw customer profile data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Customer email address for communication |
| customer_phone | VARCHAR(20) | Customer contact phone number |
| customer_name | VARCHAR(100) | Full name of the customer |
| customer_address | VARCHAR(500) | Complete residential address |
| date_of_birth | DATE | Customer date of birth |
| registration_date | TIMESTAMP | Account registration timestamp |
| customer_status | VARCHAR(20) | Current status of customer account |
| preferred_language | VARCHAR(10) | Customer's preferred communication language |
| load_timestamp | TIMESTAMP | Record load timestamp |
| update_timestamp | TIMESTAMP | Record last update timestamp |
| source_system | VARCHAR(50) | Source system identifier |

#### Bz_Customer_Preferences
**Description**: Raw customer preference and settings data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_email | VARCHAR(255) | Customer email reference |
| notification_preferences | VARCHAR(100) | Customer notification settings |
| marketing_consent | BOOLEAN | Marketing communication consent |
| privacy_settings | VARCHAR(200) | Customer privacy configuration |
| communication_channel | VARCHAR(50) | Preferred communication method |
| load_timestamp | TIMESTAMP | Record load timestamp |
| update_timestamp | TIMESTAMP | Record last update timestamp |
| source_system | VARCHAR(50) | Source system identifier |

### 2.2 Product Tables

#### Bz_Product_Catalog
**Description**: Raw product catalog data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_name | VARCHAR(200) | Product name and title |
| product_description | TEXT | Detailed product description |
| product_category | VARCHAR(100) | Product category classification |
| product_subcategory | VARCHAR(100) | Product subcategory classification |
| brand_name | VARCHAR(100) | Product brand information |
| unit_price | DECIMAL(10,2) | Product unit price |
| currency_code | VARCHAR(3) | Price currency code |
| availability_status | VARCHAR(20) | Product availability status |
| launch_date | DATE | Product launch date |
| load_timestamp | TIMESTAMP | Record load timestamp |
| update_timestamp | TIMESTAMP | Record last update timestamp |
| source_system | VARCHAR(50) | Source system identifier |

#### Bz_Product_Inventory
**Description**: Raw inventory data for products

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_name | VARCHAR(200) | Product name reference |
| warehouse_location | VARCHAR(100) | Warehouse location identifier |
| stock_quantity | INTEGER | Current stock quantity |
| reserved_quantity | INTEGER | Reserved stock quantity |
| reorder_level | INTEGER | Minimum stock reorder level |
| last_restocked_date | DATE | Last inventory restock date |
| expiry_date | DATE | Product expiry date if applicable |
| load_timestamp | TIMESTAMP | Record load timestamp |
| update_timestamp | TIMESTAMP | Record last update timestamp |
| source_system | VARCHAR(50) | Source system identifier |

### 2.3 Transaction Tables

#### Bz_Sales_Transactions
**Description**: Raw sales transaction data from source systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| transaction_number | VARCHAR(50) | Unique transaction identifier |
| customer_email | VARCHAR(255) | Customer email reference |
| product_name | VARCHAR(200) | Product name reference |
| transaction_date | TIMESTAMP | Transaction date and time |
| quantity_purchased | INTEGER | Quantity of products purchased |
| unit_price | DECIMAL(10,2) | Unit price at time of purchase |
| total_amount | DECIMAL(12,2) | Total transaction amount |
| discount_amount | DECIMAL(10,2) | Applied discount amount |
| tax_amount | DECIMAL(10,2) | Applied tax amount |
| payment_method | VARCHAR(50) | Payment method used |
| transaction_status | VARCHAR(20) | Current transaction status |
| sales_channel | VARCHAR(50) | Sales channel identifier |
| load_timestamp | TIMESTAMP | Record load timestamp |
| update_timestamp | TIMESTAMP | Record last update timestamp |
| source_system | VARCHAR(50) | Source system identifier |

#### Bz_Payment_Details
**Description**: Raw payment transaction details

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| transaction_number | VARCHAR(50) | Transaction reference |
| payment_date | TIMESTAMP | Payment processing date |
| payment_amount | DECIMAL(12,2) | Payment amount processed |
| payment_method | VARCHAR(50) | Payment method details |
| payment_status | VARCHAR(20) | Payment processing status |
| currency_code | VARCHAR(3) | Payment currency |
| processing_fee | DECIMAL(8,2) | Payment processing fee |
| gateway_response | VARCHAR(100) | Payment gateway response |
| load_timestamp | TIMESTAMP | Record load timestamp |
| update_timestamp | TIMESTAMP | Record last update timestamp |
| source_system | VARCHAR(50) | Source system identifier |

### 2.4 Employee Tables

#### Bz_Employee_Profile
**Description**: Raw employee profile data from HR systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| employee_email | VARCHAR(255) | Employee email address |
| employee_name | VARCHAR(100) | Full name of employee |
| employee_phone | VARCHAR(20) | Employee contact number |
| department | VARCHAR(100) | Employee department |
| job_title | VARCHAR(100) | Employee job title |
| hire_date | DATE | Employee hire date |
| employment_status | VARCHAR(20) | Current employment status |
| manager_email | VARCHAR(255) | Manager email reference |
| office_location | VARCHAR(100) | Employee office location |
| load_timestamp | TIMESTAMP | Record load timestamp |
| update_timestamp | TIMESTAMP | Record last update timestamp |
| source_system | VARCHAR(50) | Source system identifier |

## 3. Audit Table Design

### Bz_Data_Audit_Log
**Description**: Comprehensive audit trail for all Bronze layer data processing

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique audit record identifier |
| source_table | VARCHAR(100) | Source table name being audited |
| load_timestamp | TIMESTAMP | Data load timestamp |
| processed_by | VARCHAR(100) | System/user that processed the data |
| processing_time | DECIMAL(10,3) | Processing time in seconds |
| status | VARCHAR(20) | Processing status (SUCCESS/FAILED/PARTIAL) |
| records_processed | INTEGER | Number of records processed |
| records_failed | INTEGER | Number of records that failed |
| error_message | TEXT | Error details if processing failed |
| data_quality_score | DECIMAL(5,2) | Data quality assessment score |
| source_system | VARCHAR(50) | Source system identifier |
| batch_id | VARCHAR(100) | Batch processing identifier |

## 4. Conceptual Data Model Diagram

```
┌─────────────────────┐     ┌─────────────────────┐
│   Bz_Customer_      │────▶│  Bz_Customer_       │
│   Profile           │     │  Preferences        │
│                     │     │                     │
│ Key: customer_email │     │ Key: customer_email │
└─────────────────────┘     └─────────────────────┘
           │
           │ customer_email
           ▼
┌─────────────────────┐     ┌─────────────────────┐
│   Bz_Sales_         │────▶│   Bz_Payment_       │
│   Transactions      │     │   Details           │
│                     │     │                     │
│ Key: customer_email │     │ Key: transaction_   │
│      transaction_   │     │      number         │
│      number         │     │                     │
└─────────────────────┘     └─────────────────────┘
           │
           │ product_name
           ▼
┌─────────────────────┐     ┌─────────────────────┐
│   Bz_Product_       │────▶│   Bz_Product_       │
│   Catalog           │     │   Inventory         │
│                     │     │                     │
│ Key: product_name   │     │ Key: product_name   │
└─────────────────────┘     └─────────────────────┘

┌─────────────────────┐
│   Bz_Employee_      │
│   Profile           │
│                     │
│ Key: employee_email │
│ Ref: manager_email  │
└─────────────────────┘
           │
           │ manager_email (self-reference)
           └─────────────────┐
                              │
                              ▼
                    ┌─────────────────────┐
                    │   Bz_Employee_      │
                    │   Profile           │
                    │   (Manager)         │
                    └─────────────────────┘

┌─────────────────────┐
│   Bz_Data_Audit_    │
│   Log               │
│                     │
│ Tracks all tables   │
│ via source_table    │
└─────────────────────┘
```

### Table Relationships:

1. **Bz_Customer_Profile** ↔ **Bz_Customer_Preferences**
   - Connection: customer_email
   - Relationship: One-to-One

2. **Bz_Customer_Profile** ↔ **Bz_Sales_Transactions**
   - Connection: customer_email
   - Relationship: One-to-Many

3. **Bz_Sales_Transactions** ↔ **Bz_Payment_Details**
   - Connection: transaction_number
   - Relationship: One-to-One

4. **Bz_Product_Catalog** ↔ **Bz_Product_Inventory**
   - Connection: product_name
   - Relationship: One-to-Many

5. **Bz_Product_Catalog** ↔ **Bz_Sales_Transactions**
   - Connection: product_name
   - Relationship: One-to-Many

6. **Bz_Employee_Profile** ↔ **Bz_Employee_Profile** (Self-Reference)
   - Connection: manager_email → employee_email
   - Relationship: Many-to-One (Hierarchical)

7. **Bz_Data_Audit_Log** tracks all tables
   - Connection: source_table (references all table names)
   - Relationship: Many-to-One (Audit to Tables)

## Design Rationale and Assumptions

### Key Design Decisions:

1. **Naming Convention**: All Bronze tables prefixed with 'Bz_' for clear layer identification
2. **Data Preservation**: All source data fields preserved without transformation
3. **Metadata Columns**: Consistent metadata columns across all tables for lineage tracking
4. **PII Classification**: Comprehensive PII identification for compliance requirements
5. **Audit Trail**: Detailed audit table for complete data processing transparency

### Assumptions Made:

1. Source systems provide consistent data formats
2. Email addresses serve as primary customer identifiers
3. Product names are unique identifiers in catalog
4. Transaction numbers are globally unique
5. Employee hierarchy is single-manager based
6. All timestamps are in UTC format
7. Currency codes follow ISO 4217 standard

### Compliance Considerations:

1. **GDPR Compliance**: PII fields identified for data protection
2. **Data Retention**: Audit logs support retention policy enforcement
3. **Data Lineage**: Source system tracking enables data governance
4. **Quality Monitoring**: Audit table includes quality metrics

This Bronze layer logical data model provides a solid foundation for the Medallion architecture, ensuring data integrity, compliance, and scalability for downstream Silver and Gold layer processing.