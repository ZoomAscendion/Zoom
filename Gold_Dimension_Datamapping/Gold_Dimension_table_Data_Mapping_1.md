_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data mapping for Gold Layer Dimension tables from Silver to Gold layer transformation in Zoom Platform Analytics System
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Gold Layer Dimension Table Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides comprehensive data mapping specifications for transforming Silver layer data into Gold layer Dimension tables following the Medallion architecture. The mappings incorporate Snowflake-specific optimizations, business rules, and transformation logic to ensure high-quality dimensional data for analytics and reporting.

### 1.1 Key Architectural Considerations

1. **Performance Optimization Strategies**
   - Clustering keys implemented on frequently joined columns
   - Micro-partition optimization through proper data types and compression
   - Query performance enhanced through star schema design
   - Pre-aggregated dimensions for complex hierarchies

2. **Scalability Design Patterns**
   - SCD Type 2 implementation for historical tracking
   - Surrogate key generation using Snowflake sequences
   - Efficient incremental loading strategies
   - Partition pruning through date-based clustering

3. **Data Consistency Mechanisms**
   - Comprehensive data quality validations
   - Referential integrity through business rules
   - Audit trail maintenance for all transformations
   - Error handling and recovery procedures

### 1.2 Snowflake-Specific Implementation Notes

1. **Clustering Key Recommendations**
   - `Go_Dim_User`: Clustered by `USER_BUSINESS_KEY, IS_CURRENT`
   - `Go_Dim_Date`: Clustered by `DATE_KEY`
   - `Go_Dim_License`: Clustered by `LICENSE_TYPE_KEY, IS_CURRENT`
   - `Go_Dim_Feature`: Clustered by `FEATURE_CATEGORY, IS_ACTIVE`

2. **Partition Pruning Strategies**
   - Date dimensions leverage automatic clustering
   - SCD Type 2 tables use effective date ranges
   - Feature dimensions partitioned by category

3. **Micro-partition Optimization**
   - Optimal column ordering for compression
   - Appropriate data type selection
   - Null value handling strategies

4. **Query Performance Considerations**
   - Materialized views for complex aggregations
   - Efficient join patterns in star schema
   - Proper indexing through clustering keys

## 2. Data Mapping Tables

### 2.1 Dimension Table: Go_Dim_Date

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_Date | DIM_DATE_ID | Silver | SYSTEM_GENERATED | N/A | `'DIM_DATE_' \|\| TO_CHAR(date_value, 'YYYYMMDD')` - Generate unique ID using date format |
| Gold | Go_Dim_Date | DATE_KEY | Silver | SYSTEM_GENERATED | N/A | `DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE)` - Generate date sequence |
| Gold | Go_Dim_Date | YEAR | Silver | SYSTEM_GENERATED | DATE_KEY | `YEAR(DATE_KEY)` - Extract year component |
| Gold | Go_Dim_Date | QUARTER | Silver | SYSTEM_GENERATED | DATE_KEY | `QUARTER(DATE_KEY)` - Extract quarter number |
| Gold | Go_Dim_Date | MONTH | Silver | SYSTEM_GENERATED | DATE_KEY | `MONTH(DATE_KEY)` - Extract month number |
| Gold | Go_Dim_Date | MONTH_NAME | Silver | SYSTEM_GENERATED | DATE_KEY | `MONTHNAME(DATE_KEY)` - Get full month name |
| Gold | Go_Dim_Date | WEEK_OF_YEAR | Silver | SYSTEM_GENERATED | DATE_KEY | `WEEKOFYEAR(DATE_KEY)` - Calculate week number |
| Gold | Go_Dim_Date | DAY_OF_MONTH | Silver | SYSTEM_GENERATED | DATE_KEY | `DAYOFMONTH(DATE_KEY)` - Extract day of month |
| Gold | Go_Dim_Date | DAY_OF_WEEK | Silver | SYSTEM_GENERATED | DATE_KEY | `DAYOFWEEK(DATE_KEY)` - Get day of week number |
| Gold | Go_Dim_Date | DAY_NAME | Silver | SYSTEM_GENERATED | DATE_KEY | `DAYNAME(DATE_KEY)` - Get full day name |
| Gold | Go_Dim_Date | IS_WEEKEND | Silver | SYSTEM_GENERATED | DATE_KEY | `CASE WHEN DAYOFWEEK(DATE_KEY) IN (1, 7) THEN TRUE ELSE FALSE END` - Weekend flag |
| Gold | Go_Dim_Date | IS_HOLIDAY | Silver | BUSINESS_RULES | DATE_KEY | `FALSE` - Default to false, updated via holiday calendar |
| Gold | Go_Dim_Date | FISCAL_YEAR | Silver | SYSTEM_GENERATED | DATE_KEY | `CASE WHEN MONTH(DATE_KEY) >= 4 THEN YEAR(DATE_KEY) ELSE YEAR(DATE_KEY) - 1 END` - Fiscal year calculation |
| Gold | Go_Dim_Date | FISCAL_QUARTER | Silver | SYSTEM_GENERATED | DATE_KEY | `CASE WHEN MONTH(DATE_KEY) BETWEEN 4 AND 6 THEN 1 WHEN MONTH(DATE_KEY) BETWEEN 7 AND 9 THEN 2 WHEN MONTH(DATE_KEY) BETWEEN 10 AND 12 THEN 3 ELSE 4 END` - Fiscal quarter |
| Gold | Go_Dim_Date | LOAD_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System load date |
| Gold | Go_Dim_Date | UPDATE_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System update date |
| Gold | Go_Dim_Date | SOURCE_SYSTEM | Silver | SYSTEM_GENERATED | N/A | `'SYSTEM_GENERATED'` - Static value for system-generated dates |

### 2.2 Dimension Table: Go_Dim_User

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_User | DIM_USER_ID | Silver | SI_USERS | USER_ID | `'DIM_USER_' \|\| USER_ID \|\| '_' \|\| TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')` - SCD Type 2 surrogate key |
| Gold | Go_Dim_User | USER_BUSINESS_KEY | Silver | SI_USERS | USER_ID | `USER_ID` - Direct mapping of business key |
| Gold | Go_Dim_User | USER_NAME | Silver | SI_USERS | USER_NAME | `INITCAP(TRIM(USER_NAME))` - Standardize name formatting |
| Gold | Go_Dim_User | EMAIL_DOMAIN | Silver | SI_USERS | EMAIL | `UPPER(SPLIT_PART(EMAIL, '@', 2))` - Extract and standardize email domain |
| Gold | Go_Dim_User | COMPANY_NAME | Silver | SI_USERS | COMPANY | `INITCAP(TRIM(COMPANY))` - Standardize company name formatting |
| Gold | Go_Dim_User | PLAN_TYPE | Silver | SI_USERS | PLAN_TYPE | `UPPER(PLAN_TYPE)` - Standardize plan type to uppercase |
| Gold | Go_Dim_User | ACCOUNT_STATUS | Silver | SI_USERS | ACCOUNT_STATUS | `UPPER(ACCOUNT_STATUS)` - Standardize account status to uppercase |
| Gold | Go_Dim_User | REGISTRATION_DATE | Silver | SI_USERS | REGISTRATION_DATE | `REGISTRATION_DATE` - Direct mapping |
| Gold | Go_Dim_User | USER_SEGMENT | Silver | SI_USERS | PLAN_TYPE | `CASE WHEN PLAN_TYPE = 'Enterprise' THEN 'Enterprise' WHEN PLAN_TYPE = 'Pro' THEN 'Professional' WHEN PLAN_TYPE = 'Basic' THEN 'Small Business' ELSE 'Individual' END` - Business segmentation |
| Gold | Go_Dim_User | EFFECTIVE_START_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - SCD Type 2 effective start date |
| Gold | Go_Dim_User | EFFECTIVE_END_DATE | Silver | SYSTEM_GENERATED | N/A | `'9999-12-31'::DATE` - SCD Type 2 effective end date |
| Gold | Go_Dim_User | IS_CURRENT | Silver | SYSTEM_GENERATED | N/A | `TRUE` - SCD Type 2 current record flag |
| Gold | Go_Dim_User | LOAD_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System load date |
| Gold | Go_Dim_User | UPDATE_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System update date |
| Gold | Go_Dim_User | SOURCE_SYSTEM | Silver | SI_USERS | SOURCE_SYSTEM | `SOURCE_SYSTEM` - Direct mapping from source |

### 2.3 Dimension Table: Go_Dim_Meeting_Type

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_Meeting_Type | DIM_MEETING_TYPE_ID | Silver | BUSINESS_RULES | MEETING_TYPE_KEY | `'DIM_MEETING_TYPE_' \|\| MEETING_TYPE_KEY` - Generate unique dimension ID |
| Gold | Go_Dim_Meeting_Type | MEETING_TYPE_KEY | Silver | BUSINESS_RULES | N/A | `'SCHEDULED', 'INSTANT', 'WEBINAR', 'PERSONAL'` - Business rule-defined keys |
| Gold | Go_Dim_Meeting_Type | MEETING_TYPE_NAME | Silver | BUSINESS_RULES | N/A | `'Scheduled Meeting', 'Instant Meeting', 'Webinar', 'Personal Room'` - Descriptive names |
| Gold | Go_Dim_Meeting_Type | MEETING_CATEGORY | Silver | BUSINESS_RULES | N/A | `CASE WHEN MEETING_TYPE_KEY = 'WEBINAR' THEN 'Broadcast' ELSE 'Regular' END` - Category classification |
| Gold | Go_Dim_Meeting_Type | IS_SCHEDULED | Silver | BUSINESS_RULES | N/A | `CASE WHEN MEETING_TYPE_KEY IN ('SCHEDULED', 'WEBINAR') THEN TRUE ELSE FALSE END` - Scheduling requirement |
| Gold | Go_Dim_Meeting_Type | SUPPORTS_RECORDING | Silver | BUSINESS_RULES | N/A | `TRUE` - All meeting types support recording |
| Gold | Go_Dim_Meeting_Type | MAX_PARTICIPANTS | Silver | BUSINESS_RULES | N/A | `CASE WHEN MEETING_TYPE_KEY = 'WEBINAR' THEN 10000 ELSE 500 END` - Participant limits |
| Gold | Go_Dim_Meeting_Type | REQUIRES_LICENSE | Silver | BUSINESS_RULES | N/A | `CASE WHEN MEETING_TYPE_KEY = 'WEBINAR' THEN TRUE ELSE FALSE END` - License requirements |
| Gold | Go_Dim_Meeting_Type | LOAD_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System load date |
| Gold | Go_Dim_Meeting_Type | UPDATE_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System update date |
| Gold | Go_Dim_Meeting_Type | SOURCE_SYSTEM | Silver | SYSTEM_GENERATED | N/A | `'BUSINESS_RULES'` - Source identifier |

### 2.4 Dimension Table: Go_Dim_Feature

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_Feature | DIM_FEATURE_ID | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `'DIM_FEATURE_' \|\| MD5(UPPER(TRIM(FEATURE_NAME)))` - Generate unique ID using hash |
| Gold | Go_Dim_Feature | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `UPPER(REPLACE(TRIM(FEATURE_NAME), ' ', '_'))` - Create standardized key |
| Gold | Go_Dim_Feature | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `INITCAP(TRIM(FEATURE_NAME))` - Standardize feature name formatting |
| Gold | Go_Dim_Feature | FEATURE_CATEGORY | Silver | SI_FEATURE_USAGE | FEATURE_CATEGORY | `UPPER(FEATURE_CATEGORY)` - Standardize category to uppercase |
| Gold | Go_Dim_Feature | FEATURE_SUBCATEGORY | Silver | SI_FEATURE_USAGE | FEATURE_CATEGORY, FEATURE_NAME | Complex CASE statement for subcategory classification based on category and name patterns |
| Gold | Go_Dim_Feature | IS_PREMIUM_FEATURE | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN FEATURE_NAME ILIKE '%virtual background%' OR FEATURE_NAME ILIKE '%noise suppression%' OR FEATURE_NAME ILIKE '%cloud recording%' OR FEATURE_NAME ILIKE '%breakout%' THEN TRUE ELSE FALSE END` - Premium feature identification |
| Gold | Go_Dim_Feature | RELEASE_DATE | Silver | BUSINESS_RULES | N/A | `'2020-01-01'::DATE` - Default release date |
| Gold | Go_Dim_Feature | DEPRECATION_DATE | Silver | BUSINESS_RULES | N/A | `NULL` - No deprecated features currently |
| Gold | Go_Dim_Feature | IS_ACTIVE | Silver | BUSINESS_RULES | N/A | `TRUE` - All features currently active |
| Gold | Go_Dim_Feature | LOAD_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System load date |
| Gold | Go_Dim_Feature | UPDATE_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System update date |
| Gold | Go_Dim_Feature | SOURCE_SYSTEM | Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | `SOURCE_SYSTEM` - Direct mapping from source |

### 2.5 Dimension Table: Go_Dim_Support_Category

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_Support_Category | DIM_SUPPORT_CATEGORY_ID | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE, PRIORITY_LEVEL | `'DIM_SUPPORT_CAT_' \|\| MD5(UPPER(TICKET_TYPE \|\| PRIORITY_LEVEL))` - Generate unique ID |
| Gold | Go_Dim_Support_Category | CATEGORY_KEY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `UPPER(REPLACE(TICKET_TYPE, ' ', '_'))` - Create standardized category key |
| Gold | Go_Dim_Support_Category | TICKET_TYPE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `INITCAP(TICKET_TYPE)` - Standardize ticket type formatting |
| Gold | Go_Dim_Support_Category | CATEGORY_GROUP | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BUG REPORT') THEN 'TECHNICAL_SUPPORT' WHEN UPPER(TICKET_TYPE) = 'BILLING' THEN 'FINANCIAL_SUPPORT' WHEN UPPER(TICKET_TYPE) = 'FEATURE REQUEST' THEN 'PRODUCT_ENHANCEMENT' ELSE 'GENERAL_SUPPORT' END` - Group classification |
| Gold | Go_Dim_Support_Category | PRIORITY_LEVEL | Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | `UPPER(PRIORITY_LEVEL)` - Standardize priority level |
| Gold | Go_Dim_Support_Category | SLA_HOURS | Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | `CASE WHEN UPPER(PRIORITY_LEVEL) = 'CRITICAL' THEN 4 WHEN UPPER(PRIORITY_LEVEL) = 'HIGH' THEN 24 WHEN UPPER(PRIORITY_LEVEL) = 'MEDIUM' THEN 72 WHEN UPPER(PRIORITY_LEVEL) = 'LOW' THEN 168 ELSE 72 END` - SLA mapping |
| Gold | Go_Dim_Support_Category | ESCALATION_THRESHOLD_HOURS | Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | `CASE WHEN UPPER(PRIORITY_LEVEL) = 'CRITICAL' THEN 2 WHEN UPPER(PRIORITY_LEVEL) = 'HIGH' THEN 12 WHEN UPPER(PRIORITY_LEVEL) = 'MEDIUM' THEN 48 WHEN UPPER(PRIORITY_LEVEL) = 'LOW' THEN 120 ELSE 48 END` - Escalation thresholds |
| Gold | Go_Dim_Support_Category | REQUIRES_TECHNICAL_EXPERTISE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BUG REPORT') THEN TRUE ELSE FALSE END` - Technical expertise requirement |
| Gold | Go_Dim_Support_Category | LOAD_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System load date |
| Gold | Go_Dim_Support_Category | UPDATE_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System update date |
| Gold | Go_Dim_Support_Category | SOURCE_SYSTEM | Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | `SOURCE_SYSTEM` - Direct mapping from source |

### 2.6 Dimension Table: Go_Dim_License

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_License | DIM_LICENSE_ID | Silver | BUSINESS_RULES | LICENSE_TYPE_KEY | `'DIM_LICENSE_' \|\| LICENSE_TYPE_KEY \|\| '_' \|\| TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS')` - SCD Type 2 surrogate key |
| Gold | Go_Dim_License | LICENSE_TYPE_KEY | Silver | BUSINESS_RULES | N/A | `'BASIC', 'PRO', 'ENTERPRISE'` - Business rule-defined license types |
| Gold | Go_Dim_License | LICENSE_NAME | Silver | BUSINESS_RULES | N/A | `'Zoom Basic', 'Zoom Pro', 'Zoom Enterprise'` - Descriptive license names |
| Gold | Go_Dim_License | LICENSE_TIER | Silver | BUSINESS_RULES | N/A | `'BASIC', 'PROFESSIONAL', 'ENTERPRISE'` - Tier classification |
| Gold | Go_Dim_License | MONTHLY_COST | Silver | BUSINESS_RULES | N/A | `CASE WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 0.00 WHEN LICENSE_TYPE_KEY = 'PRO' THEN 14.99 WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 19.99 END` - Monthly pricing |
| Gold | Go_Dim_License | ANNUAL_COST | Silver | BUSINESS_RULES | N/A | `CASE WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 0.00 WHEN LICENSE_TYPE_KEY = 'PRO' THEN 149.90 WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 199.90 END` - Annual pricing |
| Gold | Go_Dim_License | MAX_PARTICIPANTS | Silver | BUSINESS_RULES | N/A | `CASE WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 100 WHEN LICENSE_TYPE_KEY = 'PRO' THEN 500 WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 1000 END` - Participant limits |
| Gold | Go_Dim_License | STORAGE_GB | Silver | BUSINESS_RULES | N/A | `CASE WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 1 WHEN LICENSE_TYPE_KEY = 'PRO' THEN 5 WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 10 END` - Storage allocation |
| Gold | Go_Dim_License | FEATURES_INCLUDED | Silver | BUSINESS_RULES | N/A | Complex CASE statement mapping license types to feature descriptions |
| Gold | Go_Dim_License | EFFECTIVE_START_DATE | Silver | SYSTEM_GENERATED | N/A | `'2020-01-01'::DATE` - SCD Type 2 effective start date |
| Gold | Go_Dim_License | EFFECTIVE_END_DATE | Silver | SYSTEM_GENERATED | N/A | `'9999-12-31'::DATE` - SCD Type 2 effective end date |
| Gold | Go_Dim_License | IS_CURRENT | Silver | SYSTEM_GENERATED | N/A | `TRUE` - SCD Type 2 current record flag |
| Gold | Go_Dim_License | LOAD_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System load date |
| Gold | Go_Dim_License | UPDATE_DATE | Silver | SYSTEM_GENERATED | N/A | `CURRENT_DATE()` - System update date |
| Gold | Go_Dim_License | SOURCE_SYSTEM | Silver | SYSTEM_GENERATED | N/A | `'BUSINESS_RULES'` - Source identifier |

## 3. Transformation Categories

### 3.1 Data Normalization

1. **Standardize Formats**
   - Date standardization using Snowflake date functions
   - Text formatting with INITCAP and TRIM functions
   - Email domain extraction and standardization
   - Phone number and address formatting (future enhancement)

2. **Business Rule Validations**
   - Plan type validation against allowed values
   - Account status verification
   - Priority level standardization
   - Feature category classification

3. **Cleanse and Deduplicate Data**
   - Remove leading/trailing spaces
   - Handle null values appropriately
   - Eliminate duplicate dimension records
   - Standardize case sensitivity

### 3.2 Hierarchical Relationships

1. **Parent-Child Mappings**
   - Feature category to subcategory relationships
   - Support ticket type to category group mappings
   - License tier to feature inclusion hierarchies

2. **Multi-Level Dimension Hierarchies**
   - Date dimension: Year → Quarter → Month → Day
   - Feature dimension: Category → Subcategory → Feature
   - User dimension: Segment → Plan Type → Account Status

3. **Bridge Table Implementations**
   - Feature-to-License mapping (future enhancement)
   - User-to-Company relationship tracking
   - Meeting-to-Feature usage associations

### 3.3 Category Mappings

1. **Code-to-Description Translations**
   - Plan type codes to descriptive names
   - Meeting type keys to full descriptions
   - Priority level codes to SLA mappings

2. **Business Classification Rules**
   - User segmentation based on plan types
   - Feature premium classification
   - Support category groupings

3. **Reference Data Lookups**
   - Holiday calendar integration
   - Currency code standardization
   - Time zone conversions

### 3.4 Derived Attributes

1. **Calculated Fields**
   - Fiscal year and quarter calculations
   - User segment derivation from plan type
   - Email domain extraction from full email

2. **Concatenations and Aggregations**
   - Full name construction from first/last names
   - Feature description concatenation
   - License feature list compilation

3. **Business Logic Implementations**
   - SLA hour calculations based on priority
   - Premium feature identification logic
   - Weekend and holiday flag derivation

## 4. Snowflake-Specific Features

### 4.1 Surrogate Key Generation

```sql
-- Using Sequences for Dimension Keys
CREATE SEQUENCE SEQ_DIM_USER START = 1 INCREMENT = 1;
CREATE SEQUENCE SEQ_DIM_FEATURE START = 1 INCREMENT = 1;
CREATE SEQUENCE SEQ_DIM_LICENSE START = 1 INCREMENT = 1;

-- In mapping transformations:
-- DIM_USER_ID: SEQ_DIM_USER.NEXTVAL
-- Alternative using UUID: UUID_STRING()
```

### 4.2 Slowly Changing Dimensions (SCD)

```sql
-- SCD Type 2 Implementation for Go_Dim_User
MERGE INTO GOLD.Go_Dim_User target
USING (
    SELECT 
        USER_ID,
        INITCAP(TRIM(USER_NAME)) AS USER_NAME,
        UPPER(SPLIT_PART(EMAIL, '@', 2)) AS EMAIL_DOMAIN,
        INITCAP(TRIM(COMPANY)) AS COMPANY_NAME,
        UPPER(PLAN_TYPE) AS PLAN_TYPE,
        UPPER(ACCOUNT_STATUS) AS ACCOUNT_STATUS
    FROM SILVER.SI_USERS
) source
ON target.USER_BUSINESS_KEY = source.USER_ID AND target.IS_CURRENT = TRUE
WHEN MATCHED AND (
    target.PLAN_TYPE != source.PLAN_TYPE OR
    target.ACCOUNT_STATUS != source.ACCOUNT_STATUS OR
    target.COMPANY_NAME != source.COMPANY_NAME
) THEN UPDATE SET
    IS_CURRENT = FALSE,
    EFFECTIVE_END_DATE = CURRENT_DATE() - 1,
    UPDATE_DATE = CURRENT_DATE()
WHEN NOT MATCHED THEN INSERT (
    DIM_USER_ID,
    USER_BUSINESS_KEY,
    USER_NAME,
    EMAIL_DOMAIN,
    COMPANY_NAME,
    PLAN_TYPE,
    ACCOUNT_STATUS,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    IS_CURRENT,
    LOAD_DATE,
    UPDATE_DATE
) VALUES (
    'DIM_USER_' || source.USER_ID || '_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'),
    source.USER_ID,
    source.USER_NAME,
    source.EMAIL_DOMAIN,
    source.COMPANY_NAME,
    source.PLAN_TYPE,
    source.ACCOUNT_STATUS,
    CURRENT_DATE(),
    '9999-12-31'::DATE,
    TRUE,
    CURRENT_DATE(),
    CURRENT_DATE()
);
```

### 4.3 Change Data Capture

```sql
-- Using Streams for CDC
CREATE STREAM stream_si_users ON TABLE SILVER.SI_USERS;
CREATE STREAM stream_si_feature_usage ON TABLE SILVER.SI_FEATURE_USAGE;
CREATE STREAM stream_si_support_tickets ON TABLE SILVER.SI_SUPPORT_TICKETS;

-- In transformation logic
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    METADATA$ACTION,
    METADATA$ISUPDATE
FROM stream_si_users 
WHERE METADATA$ACTION IN ('INSERT', 'UPDATE');
```

### 4.4 Orchestration

```sql
-- Using Tasks for Dimension Loading
CREATE TASK task_load_dim_date
    WAREHOUSE = WH_POC_ZOOM_DEV_XSMALL
    SCHEDULE = 'USING CRON 0 2 * * * UTC'
AS
    CALL sp_load_dim_date();

CREATE TASK task_load_dim_user
    WAREHOUSE = WH_POC_ZOOM_DEV_XSMALL
    SCHEDULE = 'USING CRON 0 3 * * * UTC'
    AFTER task_load_dim_date
AS
    CALL sp_load_dim_user();
```

## 5. Data Quality and Validation Rules

### 5.1 Dimension Key Validation

```sql
-- Validate dimension keys are not null
INSERT INTO GOLD.Go_Data_Quality_Errors (
    ERROR_ID,
    SOURCE_TABLE_NAME,
    TARGET_TABLE_NAME,
    ERROR_TYPE,
    ERROR_CATEGORY,
    ERROR_DESCRIPTION,
    ERROR_SEVERITY,
    DETECTED_TIMESTAMP,
    RESOLUTION_STATUS,
    LOAD_DATE,
    SOURCE_SYSTEM
)
SELECT 
    'ERROR_' || UUID_STRING() AS ERROR_ID,
    'SILVER.SI_USERS' AS SOURCE_TABLE_NAME,
    'GOLD.Go_Dim_User' AS TARGET_TABLE_NAME,
    'VALIDATION' AS ERROR_TYPE,
    'MISSING_DATA' AS ERROR_CATEGORY,
    'User dimension record with null business key detected' AS ERROR_DESCRIPTION,
    'HIGH' AS ERROR_SEVERITY,
    CURRENT_TIMESTAMP() AS DETECTED_TIMESTAMP,
    'OPEN' AS RESOLUTION_STATUS,
    CURRENT_DATE() AS LOAD_DATE,
    'DATA_QUALITY_CHECK' AS SOURCE_SYSTEM
FROM GOLD.Go_Dim_User
WHERE USER_BUSINESS_KEY IS NULL;
```

### 5.2 SCD Type 2 Integrity Validation

```sql
-- Validate SCD Type 2 integrity
INSERT INTO GOLD.Go_Data_Quality_Errors (
    ERROR_ID,
    SOURCE_TABLE_NAME,
    TARGET_TABLE_NAME,
    ERROR_TYPE,
    ERROR_CATEGORY,
    ERROR_DESCRIPTION,
    ERROR_SEVERITY,
    DETECTED_TIMESTAMP,
    RESOLUTION_STATUS,
    LOAD_DATE,
    SOURCE_SYSTEM
)
SELECT 
    'ERROR_' || UUID_STRING() AS ERROR_ID,
    'GOLD.Go_Dim_User' AS SOURCE_TABLE_NAME,
    'GOLD.Go_Dim_User' AS TARGET_TABLE_NAME,
    'VALIDATION' AS ERROR_TYPE,
    'BUSINESS_RULE' AS ERROR_CATEGORY,
    'Multiple current records found for user: ' || USER_BUSINESS_KEY AS ERROR_DESCRIPTION,
    'CRITICAL' AS ERROR_SEVERITY,
    CURRENT_TIMESTAMP() AS DETECTED_TIMESTAMP,
    'OPEN' AS RESOLUTION_STATUS,
    CURRENT_DATE() AS LOAD_DATE,
    'DATA_QUALITY_CHECK' AS SOURCE_SYSTEM
FROM GOLD.Go_Dim_User
WHERE IS_CURRENT = TRUE
GROUP BY USER_BUSINESS_KEY
HAVING COUNT(*) > 1;
```

## 6. Performance Optimization

### 6.1 Clustering Key Implementation

```sql
-- Add clustering keys for performance optimization
ALTER TABLE GOLD.Go_Dim_User CLUSTER BY (USER_BUSINESS_KEY, IS_CURRENT);
ALTER TABLE GOLD.Go_Dim_Date CLUSTER BY (DATE_KEY);
ALTER TABLE GOLD.Go_Dim_License CLUSTER BY (LICENSE_TYPE_KEY, IS_CURRENT);
ALTER TABLE GOLD.Go_Dim_Feature CLUSTER BY (FEATURE_CATEGORY, IS_ACTIVE);
ALTER TABLE GOLD.Go_Dim_Meeting_Type CLUSTER BY (MEETING_TYPE_KEY);
ALTER TABLE GOLD.Go_Dim_Support_Category CLUSTER BY (CATEGORY_KEY, PRIORITY_LEVEL);
```

### 6.2 Materialization Strategy

```sql
-- Materialized view for active users
CREATE MATERIALIZED VIEW GOLD.MV_ACTIVE_USERS AS
SELECT 
    USER_BUSINESS_KEY,
    USER_NAME,
    EMAIL_DOMAIN,
    COMPANY_NAME,
    PLAN_TYPE,
    USER_SEGMENT
FROM GOLD.Go_Dim_User
WHERE IS_CURRENT = TRUE 
  AND ACCOUNT_STATUS = 'ACTIVE';

-- Materialized view for premium features
CREATE MATERIALIZED VIEW GOLD.MV_PREMIUM_FEATURES AS
SELECT 
    FEATURE_KEY,
    FEATURE_NAME,
    FEATURE_CATEGORY,
    FEATURE_SUBCATEGORY
FROM GOLD.Go_Dim_Feature
WHERE IS_PREMIUM_FEATURE = TRUE 
  AND IS_ACTIVE = TRUE;
```

## 7. Incremental Load Strategy

### 7.1 Change Detection and Processing

```sql
-- Incremental load for Go_Dim_User with change detection
MERGE INTO GOLD.Go_Dim_User AS target
USING (
    SELECT 
        s.USER_ID,
        INITCAP(TRIM(s.USER_NAME)) AS USER_NAME,
        UPPER(SPLIT_PART(s.EMAIL, '@', 2)) AS EMAIL_DOMAIN,
        INITCAP(TRIM(s.COMPANY)) AS COMPANY_NAME,
        UPPER(s.PLAN_TYPE) AS PLAN_TYPE,
        UPPER(s.ACCOUNT_STATUS) AS ACCOUNT_STATUS,
        s.REGISTRATION_DATE,
        s.UPDATE_TIMESTAMP
    FROM SILVER.SI_USERS s
    WHERE s.UPDATE_TIMESTAMP >= (
        SELECT COALESCE(MAX(UPDATE_DATE), '1900-01-01'::DATE) 
        FROM GOLD.Go_Dim_User
    )
) AS source
ON target.USER_BUSINESS_KEY = source.USER_ID AND target.IS_CURRENT = TRUE
WHEN MATCHED AND (
    target.USER_NAME != source.USER_NAME OR
    target.EMAIL_DOMAIN != source.EMAIL_DOMAIN OR
    target.COMPANY_NAME != source.COMPANY_NAME OR
    target.PLAN_TYPE != source.PLAN_TYPE OR
    target.ACCOUNT_STATUS != source.ACCOUNT_STATUS
) THEN UPDATE SET
    EFFECTIVE_END_DATE = CURRENT_DATE() - 1,
    IS_CURRENT = FALSE,
    UPDATE_DATE = CURRENT_DATE();
```

## 8. Data Lineage and Audit Trail

### 8.1 Transformation Audit Logging

```sql
-- Log dimension transformation execution
INSERT INTO GOLD.Go_Process_Audit (
    EXECUTION_ID,
    AUDIT_KEY,
    PIPELINE_NAME,
    EXECUTION_START_TIMESTAMP,
    EXECUTION_END_TIMESTAMP,
    EXECUTION_DURATION_SECONDS,
    EXECUTION_STATUS,
    SOURCE_TABLES_PROCESSED,
    TARGET_TABLES_UPDATED,
    RECORDS_PROCESSED,
    RECORDS_INSERTED,
    RECORDS_UPDATED,
    RECORDS_REJECTED,
    DATA_QUALITY_SCORE,
    EXECUTED_BY,
    EXECUTION_ENVIRONMENT,
    LOAD_DATE,
    SOURCE_SYSTEM
)
VALUES (
    'EXEC_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'),
    'AUDIT_DIM_TRANSFORM_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'),
    'Gold_Dimension_Transformation_Pipeline',
    :pipeline_start_time,
    CURRENT_TIMESTAMP(),
    DATEDIFF('second', :pipeline_start_time, CURRENT_TIMESTAMP()),
    'SUCCESS',
    'SILVER.SI_USERS,SILVER.SI_FEATURE_USAGE,SILVER.SI_SUPPORT_TICKETS,SILVER.SI_LICENSES',
    'GOLD.Go_Dim_User,GOLD.Go_Dim_Feature,GOLD.Go_Dim_Support_Category,GOLD.Go_Dim_License,GOLD.Go_Dim_Meeting_Type,GOLD.Go_Dim_Date',
    :total_records_processed,
    :total_records_inserted,
    :total_records_updated,
    :total_records_rejected,
    :data_quality_score,
    CURRENT_USER(),
    'PRODUCTION',
    CURRENT_DATE(),
    'DIMENSION_TRANSFORMATION_PIPELINE'
);
```

## 9. Security and Compliance

### 9.1 Data Governance Requirements

1. **Sensitive Data Handling**
   - Email addresses masked in non-production environments
   - Company names anonymized for external reporting
   - User names encrypted for PII protection
   - Access control policies enforced at column level

2. **Audit Trail**
   - Complete version history maintained through SCD Type 2
   - All transformation logic documented and versioned
   - Change reasons captured in audit tables
   - Data lineage tracked from source to target

3. **Credential Management**
   - No hardcoded credentials in transformation logic
   - Secure token management for external integrations
   - Role-based access control implementation
   - Least privilege principle enforcement

## 10. Implementation Summary

This comprehensive data mapping specification provides the foundation for transforming Silver layer data into Gold layer dimension tables for the Zoom Platform Analytics System. The mappings incorporate:

1. **Complete Field-Level Mappings** for all 6 dimension tables
2. **Snowflake-Specific Optimizations** including clustering, SCD implementation, and performance tuning
3. **Business Rule Implementation** for data standardization and enrichment
4. **Data Quality Validations** to ensure high-quality dimensional data
5. **Performance Optimization Strategies** for scalable analytics
6. **Comprehensive Audit and Error Handling** for operational excellence

The implementation follows Snowflake best practices and dimensional modeling principles to deliver a robust, scalable, and maintainable data warehouse solution for business intelligence and analytics requirements.

---

*This document serves as the definitive specification for Gold layer dimension table data mapping and should be referenced for all implementation and maintenance activities.*