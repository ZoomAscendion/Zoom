# Gold Layer Dimension Table Data Mapping

_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Comprehensive data mapping for Gold layer dimension tables from Silver to Gold layer in Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

## Overview

This document provides comprehensive data mapping specifications for transforming Silver layer tables into Gold layer Dimension tables in the Zoom Platform Analytics System. The mapping incorporates Snowflake-specific optimizations, business rules, and transformation logic to ensure high-quality dimensional data for analytics and reporting.

### Key Architectural Considerations

1. **Performance Optimization Strategies**
   - Clustering keys on frequently queried columns (DATE_KEY, USER_BUSINESS_KEY)
   - Micro-partition optimization through proper data distribution
   - Query performance enhancement via pre-computed derived attributes

2. **Scalability Design Patterns**
   - Slowly Changing Dimension (SCD) Type 2 implementation for historical tracking
   - Surrogate key generation using Snowflake sequences
   - Efficient incremental loading patterns

3. **Data Consistency Mechanisms**
   - Data quality score validation (>= 0.8 threshold)
   - Standardized data cleansing and formatting rules
   - Comprehensive error handling and audit trails

4. **Snowflake-Specific Implementation Notes**
   - Leveraging `MERGE INTO` statements for SCD operations
   - Using `UUID_STRING()` and sequences for unique key generation
   - Implementing `STREAMS` and `TASKS` for automated processing
   - Optimizing with `QUALIFY` and window functions

---

## Data Mapping Tables

### Dimension Table: Go_Dim_Date

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_Date | DIM_DATE_ID | Silver | Generated | Date Spine | `CONCAT('DIM_DATE_', TO_CHAR(date_value, 'YYYYMMDD'))` |
| Gold | Go_Dim_Date | DATE_KEY | Silver | Generated | Date Spine | `date_value` (Primary date key from generated date spine) |
| Gold | Go_Dim_Date | YEAR | Silver | Generated | Date Spine | `YEAR(date_value)` |
| Gold | Go_Dim_Date | QUARTER | Silver | Generated | Date Spine | `QUARTER(date_value)` |
| Gold | Go_Dim_Date | MONTH | Silver | Generated | Date Spine | `MONTH(date_value)` |
| Gold | Go_Dim_Date | MONTH_NAME | Silver | Generated | Date Spine | `MONTHNAME(date_value)` |
| Gold | Go_Dim_Date | WEEK_OF_YEAR | Silver | Generated | Date Spine | `WEEKOFYEAR(date_value)` |
| Gold | Go_Dim_Date | DAY_OF_MONTH | Silver | Generated | Date Spine | `DAY(date_value)` |
| Gold | Go_Dim_Date | DAY_OF_WEEK | Silver | Generated | Date Spine | `DAYOFWEEK(date_value)` |
| Gold | Go_Dim_Date | DAY_NAME | Silver | Generated | Date Spine | `DAYNAME(date_value)` |
| Gold | Go_Dim_Date | IS_WEEKEND | Silver | Generated | Date Spine | `CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END` |
| Gold | Go_Dim_Date | IS_HOLIDAY | Silver | Generated | Date Spine | `FALSE` (Default, to be updated with holiday calendar) |
| Gold | Go_Dim_Date | FISCAL_YEAR | Silver | Generated | Date Spine | `CASE WHEN MONTH(date_value) >= 4 THEN YEAR(date_value) ELSE YEAR(date_value) - 1 END` |
| Gold | Go_Dim_Date | FISCAL_QUARTER | Silver | Generated | Date Spine | `CASE WHEN MONTH(date_value) >= 4 THEN QUARTER(date_value) ELSE QUARTER(date_value) + 4 END` |
| Gold | Go_Dim_Date | LOAD_DATE | Silver | Generated | System | `CURRENT_DATE()` |
| Gold | Go_Dim_Date | UPDATE_DATE | Silver | Generated | System | `CURRENT_DATE()` |
| Gold | Go_Dim_Date | SOURCE_SYSTEM | Silver | Generated | System | `'ZOOM_PLATFORM'` |

### Dimension Table: Go_Dim_User (SCD Type 2)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_User | DIM_USER_ID | Silver | SI_USERS | USER_ID | `CONCAT('DIM_USER_', USER_ID, '_', ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY LOAD_TIMESTAMP))` |
| Gold | Go_Dim_User | USER_BUSINESS_KEY | Silver | SI_USERS | USER_ID | `USER_ID` (Business key for SCD tracking) |
| Gold | Go_Dim_User | USER_NAME | Silver | SI_USERS | USER_NAME | `INITCAP(TRIM(USER_NAME))` |
| Gold | Go_Dim_User | EMAIL_DOMAIN | Silver | SI_USERS | EMAIL | `UPPER(SPLIT_PART(EMAIL, '@', 2))` |
| Gold | Go_Dim_User | COMPANY_NAME | Silver | SI_USERS | COMPANY | `INITCAP(TRIM(COMPANY))` |
| Gold | Go_Dim_User | PLAN_TYPE | Silver | SI_USERS | PLAN_TYPE | `UPPER(PLAN_TYPE)` |
| Gold | Go_Dim_User | ACCOUNT_STATUS | Silver | SI_USERS | ACCOUNT_STATUS | `UPPER(ACCOUNT_STATUS)` |
| Gold | Go_Dim_User | REGISTRATION_DATE | Silver | SI_USERS | REGISTRATION_DATE | `REGISTRATION_DATE` |
| Gold | Go_Dim_User | USER_SEGMENT | Silver | SI_USERS | PLAN_TYPE | `CASE WHEN PLAN_TYPE = 'Enterprise' THEN 'Enterprise' WHEN PLAN_TYPE = 'Pro' THEN 'Professional' WHEN PLAN_TYPE = 'Basic' THEN 'Standard' ELSE 'Free' END` |
| Gold | Go_Dim_User | EFFECTIVE_START_DATE | Silver | SI_USERS | LOAD_DATE | `LOAD_DATE` |
| Gold | Go_Dim_User | EFFECTIVE_END_DATE | Silver | SI_USERS | System | `'9999-12-31'::DATE` (Default for current records) |
| Gold | Go_Dim_User | IS_CURRENT | Silver | SI_USERS | System | `TRUE` (Default for new records) |
| Gold | Go_Dim_User | LOAD_DATE | Silver | SI_USERS | LOAD_DATE | `LOAD_DATE` |
| Gold | Go_Dim_User | UPDATE_DATE | Silver | SI_USERS | UPDATE_DATE | `UPDATE_DATE` |
| Gold | Go_Dim_User | SOURCE_SYSTEM | Silver | SI_USERS | SOURCE_SYSTEM | `SOURCE_SYSTEM` |

### Dimension Table: Go_Dim_Meeting_Type

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_Meeting_Type | DIM_MEETING_TYPE_ID | Silver | SI_MEETINGS | MEETING_TYPE | `CONCAT('DIM_MEETING_TYPE_', UPPER(REPLACE(MEETING_TYPE, ' ', '_')))` |
| Gold | Go_Dim_Meeting_Type | MEETING_TYPE_KEY | Silver | SI_MEETINGS | MEETING_TYPE | `UPPER(MEETING_TYPE)` |
| Gold | Go_Dim_Meeting_Type | MEETING_TYPE_NAME | Silver | SI_MEETINGS | MEETING_TYPE | `INITCAP(MEETING_TYPE)` |
| Gold | Go_Dim_Meeting_Type | MEETING_CATEGORY | Silver | SI_MEETINGS | MEETING_TYPE | `CASE WHEN UPPER(MEETING_TYPE) = 'WEBINAR' THEN 'Broadcasting' WHEN UPPER(MEETING_TYPE) IN ('SCHEDULED', 'INSTANT') THEN 'Collaboration' ELSE 'Personal' END` |
| Gold | Go_Dim_Meeting_Type | IS_SCHEDULED | Silver | SI_MEETINGS | MEETING_TYPE | `CASE WHEN UPPER(MEETING_TYPE) = 'SCHEDULED' THEN TRUE ELSE FALSE END` |
| Gold | Go_Dim_Meeting_Type | SUPPORTS_RECORDING | Silver | SI_MEETINGS | System | `TRUE` (All meeting types support recording) |
| Gold | Go_Dim_Meeting_Type | MAX_PARTICIPANTS | Silver | SI_MEETINGS | MEETING_TYPE | `CASE WHEN UPPER(MEETING_TYPE) = 'WEBINAR' THEN 10000 WHEN UPPER(MEETING_TYPE) = 'PERSONAL' THEN 3 ELSE 1000 END` |
| Gold | Go_Dim_Meeting_Type | REQUIRES_LICENSE | Silver | SI_MEETINGS | MEETING_TYPE | `CASE WHEN UPPER(MEETING_TYPE) = 'WEBINAR' THEN TRUE ELSE FALSE END` |
| Gold | Go_Dim_Meeting_Type | LOAD_DATE | Silver | SI_MEETINGS | System | `CURRENT_DATE()` |
| Gold | Go_Dim_Meeting_Type | UPDATE_DATE | Silver | SI_MEETINGS | System | `CURRENT_DATE()` |
| Gold | Go_Dim_Meeting_Type | SOURCE_SYSTEM | Silver | SI_MEETINGS | System | `'ZOOM_PLATFORM'` |

### Dimension Table: Go_Dim_Feature

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_Feature | DIM_FEATURE_ID | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CONCAT('DIM_FEATURE_', UPPER(REPLACE(FEATURE_NAME, ' ', '_')))` |
| Gold | Go_Dim_Feature | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `UPPER(REPLACE(FEATURE_NAME, ' ', '_'))` |
| Gold | Go_Dim_Feature | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `INITCAP(TRIM(FEATURE_NAME))` |
| Gold | Go_Dim_Feature | FEATURE_CATEGORY | Silver | SI_FEATURE_USAGE | FEATURE_CATEGORY | `UPPER(FEATURE_CATEGORY)` |
| Gold | Go_Dim_Feature | FEATURE_SUBCATEGORY | Silver | SI_FEATURE_USAGE | FEATURE_CATEGORY | `CASE WHEN UPPER(FEATURE_CATEGORY) = 'AUDIO' THEN 'Communication' WHEN UPPER(FEATURE_CATEGORY) = 'VIDEO' THEN 'Communication' WHEN UPPER(FEATURE_CATEGORY) = 'COLLABORATION' THEN 'Productivity' WHEN UPPER(FEATURE_CATEGORY) = 'SECURITY' THEN 'Protection' ELSE 'General' END` |
| Gold | Go_Dim_Feature | IS_PREMIUM_FEATURE | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%RECORDING%' OR UPPER(FEATURE_NAME) LIKE '%WEBINAR%' THEN TRUE ELSE FALSE END` |
| Gold | Go_Dim_Feature | RELEASE_DATE | Silver | SI_FEATURE_USAGE | System | `'2020-01-01'::DATE` (Default release date) |
| Gold | Go_Dim_Feature | DEPRECATION_DATE | Silver | SI_FEATURE_USAGE | System | `NULL` |
| Gold | Go_Dim_Feature | IS_ACTIVE | Silver | SI_FEATURE_USAGE | System | `TRUE` |
| Gold | Go_Dim_Feature | LOAD_DATE | Silver | SI_FEATURE_USAGE | LOAD_DATE | `CURRENT_DATE()` |
| Gold | Go_Dim_Feature | UPDATE_DATE | Silver | SI_FEATURE_USAGE | UPDATE_DATE | `CURRENT_DATE()` |
| Gold | Go_Dim_Feature | SOURCE_SYSTEM | Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | `'ZOOM_PLATFORM'` |

### Dimension Table: Go_Dim_Support_Category

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_Support_Category | DIM_SUPPORT_CATEGORY_ID | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CONCAT('DIM_SUPPORT_CAT_', UPPER(REPLACE(TICKET_TYPE, ' ', '_')))` |
| Gold | Go_Dim_Support_Category | CATEGORY_KEY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `UPPER(REPLACE(TICKET_TYPE, ' ', '_'))` |
| Gold | Go_Dim_Support_Category | TICKET_TYPE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `INITCAP(TICKET_TYPE)` |
| Gold | Go_Dim_Support_Category | CATEGORY_GROUP | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BUG REPORT') THEN 'Technical' WHEN UPPER(TICKET_TYPE) = 'BILLING' THEN 'Financial' WHEN UPPER(TICKET_TYPE) = 'FEATURE REQUEST' THEN 'Product' ELSE 'General' END` |
| Gold | Go_Dim_Support_Category | PRIORITY_LEVEL | Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | `PRIORITY_LEVEL` |
| Gold | Go_Dim_Support_Category | SLA_HOURS | Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | `CASE WHEN UPPER(PRIORITY_LEVEL) = 'CRITICAL' THEN 4 WHEN UPPER(PRIORITY_LEVEL) = 'HIGH' THEN 24 WHEN UPPER(PRIORITY_LEVEL) = 'MEDIUM' THEN 72 ELSE 168 END` |
| Gold | Go_Dim_Support_Category | ESCALATION_THRESHOLD_HOURS | Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | `CASE WHEN UPPER(PRIORITY_LEVEL) = 'CRITICAL' THEN 2 WHEN UPPER(PRIORITY_LEVEL) = 'HIGH' THEN 12 WHEN UPPER(PRIORITY_LEVEL) = 'MEDIUM' THEN 48 ELSE 120 END` |
| Gold | Go_Dim_Support_Category | REQUIRES_TECHNICAL_EXPERTISE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BUG REPORT') THEN TRUE ELSE FALSE END` |
| Gold | Go_Dim_Support_Category | LOAD_DATE | Silver | SI_SUPPORT_TICKETS | System | `CURRENT_DATE()` |
| Gold | Go_Dim_Support_Category | UPDATE_DATE | Silver | SI_SUPPORT_TICKETS | System | `CURRENT_DATE()` |
| Gold | Go_Dim_Support_Category | SOURCE_SYSTEM | Silver | SI_SUPPORT_TICKETS | System | `'ZOOM_PLATFORM'` |

### Dimension Table: Go_Dim_License (SCD Type 2)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Dim_License | DIM_LICENSE_ID | Silver | SI_LICENSES | LICENSE_TYPE | `CONCAT('DIM_LICENSE_', LICENSE_TYPE, '_', ROW_NUMBER() OVER (PARTITION BY LICENSE_TYPE ORDER BY LOAD_TIMESTAMP))` |
| Gold | Go_Dim_License | LICENSE_TYPE_KEY | Silver | SI_LICENSES | LICENSE_TYPE | `UPPER(REPLACE(LICENSE_TYPE, ' ', '_'))` |
| Gold | Go_Dim_License | LICENSE_NAME | Silver | SI_LICENSES | LICENSE_TYPE | `INITCAP(LICENSE_TYPE)` |
| Gold | Go_Dim_License | LICENSE_TIER | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) = 'ENTERPRISE' THEN 'Enterprise' WHEN UPPER(LICENSE_TYPE) = 'PRO' THEN 'Professional' WHEN UPPER(LICENSE_TYPE) = 'BASIC' THEN 'Standard' ELSE 'Add-on' END` |
| Gold | Go_Dim_License | MONTHLY_COST | Silver | SI_LICENSES | LICENSE_COST | `LICENSE_COST` |
| Gold | Go_Dim_License | ANNUAL_COST | Silver | SI_LICENSES | LICENSE_COST | `LICENSE_COST * 12 * 0.9` (10% annual discount) |
| Gold | Go_Dim_License | MAX_PARTICIPANTS | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) = 'ENTERPRISE' THEN 1000 WHEN UPPER(LICENSE_TYPE) = 'PRO' THEN 100 WHEN UPPER(LICENSE_TYPE) = 'BASIC' THEN 25 ELSE 3 END` |
| Gold | Go_Dim_License | STORAGE_GB | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) = 'ENTERPRISE' THEN 1000 WHEN UPPER(LICENSE_TYPE) = 'PRO' THEN 100 WHEN UPPER(LICENSE_TYPE) = 'BASIC' THEN 10 ELSE 1 END` |
| Gold | Go_Dim_License | FEATURES_INCLUDED | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) = 'ENTERPRISE' THEN 'All Features, Advanced Security, Admin Controls' WHEN UPPER(LICENSE_TYPE) = 'PRO' THEN 'Recording, Breakout Rooms, Polling' WHEN UPPER(LICENSE_TYPE) = 'BASIC' THEN 'Basic Meeting Features' ELSE 'Limited Features' END` |
| Gold | Go_Dim_License | EFFECTIVE_START_DATE | Silver | SI_LICENSES | START_DATE | `START_DATE` |
| Gold | Go_Dim_License | EFFECTIVE_END_DATE | Silver | SI_LICENSES | END_DATE | `COALESCE(END_DATE, '9999-12-31'::DATE)` |
| Gold | Go_Dim_License | IS_CURRENT | Silver | SI_LICENSES | END_DATE | `CASE WHEN END_DATE IS NULL THEN TRUE ELSE FALSE END` |
| Gold | Go_Dim_License | LOAD_DATE | Silver | SI_LICENSES | LOAD_DATE | `LOAD_DATE` |
| Gold | Go_Dim_License | UPDATE_DATE | Silver | SI_LICENSES | UPDATE_DATE | `UPDATE_DATE` |
| Gold | Go_Dim_License | SOURCE_SYSTEM | Silver | SI_LICENSES | SOURCE_SYSTEM | `SOURCE_SYSTEM` |

---

## Transformation Implementation Examples

### 1. SCD Type 2 Implementation for Go_Dim_User

```sql
MERGE INTO GOLD.Go_Dim_User AS target
USING (
    SELECT 
        CONCAT('DIM_USER_', USER_ID, '_', ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY LOAD_TIMESTAMP)) AS DIM_USER_ID,
        USER_ID AS USER_BUSINESS_KEY,
        INITCAP(TRIM(USER_NAME)) AS USER_NAME,
        UPPER(SPLIT_PART(EMAIL, '@', 2)) AS EMAIL_DOMAIN,
        INITCAP(TRIM(COMPANY)) AS COMPANY_NAME,
        UPPER(PLAN_TYPE) AS PLAN_TYPE,
        UPPER(ACCOUNT_STATUS) AS ACCOUNT_STATUS,
        REGISTRATION_DATE,
        CASE 
            WHEN PLAN_TYPE = 'Enterprise' THEN 'Enterprise'
            WHEN PLAN_TYPE = 'Pro' THEN 'Professional'
            WHEN PLAN_TYPE = 'Basic' THEN 'Standard'
            ELSE 'Free'
        END AS USER_SEGMENT,
        LOAD_DATE AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM
    FROM SILVER.SI_USERS
    WHERE DATA_QUALITY_SCORE >= 0.8
) AS source
ON target.USER_BUSINESS_KEY = source.USER_BUSINESS_KEY 
   AND target.IS_CURRENT = TRUE
WHEN MATCHED AND (
    target.PLAN_TYPE != source.PLAN_TYPE OR
    target.ACCOUNT_STATUS != source.ACCOUNT_STATUS OR
    target.COMPANY_NAME != source.COMPANY_NAME
) THEN UPDATE SET
    EFFECTIVE_END_DATE = CURRENT_DATE() - 1,
    IS_CURRENT = FALSE,
    UPDATE_DATE = CURRENT_DATE()
WHEN NOT MATCHED THEN INSERT VALUES (
    source.DIM_USER_ID,
    source.USER_BUSINESS_KEY,
    source.USER_NAME,
    source.EMAIL_DOMAIN,
    source.COMPANY_NAME,
    source.PLAN_TYPE,
    source.ACCOUNT_STATUS,
    source.REGISTRATION_DATE,
    source.USER_SEGMENT,
    source.EFFECTIVE_START_DATE,
    source.EFFECTIVE_END_DATE,
    source.IS_CURRENT,
    source.LOAD_DATE,
    source.UPDATE_DATE,
    source.SOURCE_SYSTEM
);
```

### 2. Date Dimension Population

```sql
INSERT INTO GOLD.Go_Dim_Date (
    DIM_DATE_ID,
    DATE_KEY,
    YEAR,
    QUARTER,
    MONTH,
    MONTH_NAME,
    WEEK_OF_YEAR,
    DAY_OF_MONTH,
    DAY_OF_WEEK,
    DAY_NAME,
    IS_WEEKEND,
    IS_HOLIDAY,
    FISCAL_YEAR,
    FISCAL_QUARTER,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    CONCAT('DIM_DATE_', TO_CHAR(date_value, 'YYYYMMDD')) AS DIM_DATE_ID,
    date_value AS DATE_KEY,
    YEAR(date_value) AS YEAR,
    QUARTER(date_value) AS QUARTER,
    MONTH(date_value) AS MONTH,
    MONTHNAME(date_value) AS MONTH_NAME,
    WEEKOFYEAR(date_value) AS WEEK_OF_YEAR,
    DAY(date_value) AS DAY_OF_MONTH,
    DAYOFWEEK(date_value) AS DAY_OF_WEEK,
    DAYNAME(date_value) AS DAY_NAME,
    CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
    FALSE AS IS_HOLIDAY,
    CASE WHEN MONTH(date_value) >= 4 THEN YEAR(date_value) ELSE YEAR(date_value) - 1 END AS FISCAL_YEAR,
    CASE WHEN MONTH(date_value) >= 4 THEN QUARTER(date_value) ELSE QUARTER(date_value) + 4 END AS FISCAL_QUARTER,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'ZOOM_PLATFORM' AS SOURCE_SYSTEM
FROM (
    SELECT DATEADD(day, seq4(), '2020-01-01') AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 3653))
) date_spine
WHERE date_value <= CURRENT_DATE() + 365;
```

### 3. Incremental Load Pattern

```sql
MERGE INTO GOLD.Go_Dim_Feature AS target
USING (
    SELECT *
    FROM SILVER.SI_FEATURE_USAGE
    WHERE UPDATE_TIMESTAMP > (
        SELECT COALESCE(MAX(UPDATE_DATE), '1900-01-01'::DATE)
        FROM GOLD.Go_Dim_Feature
    )
      AND DATA_QUALITY_SCORE >= 0.7
) AS source
ON target.FEATURE_KEY = UPPER(REPLACE(source.FEATURE_NAME, ' ', '_'))
WHEN MATCHED THEN UPDATE SET
    FEATURE_NAME = INITCAP(TRIM(source.FEATURE_NAME)),
    UPDATE_DATE = CURRENT_DATE()
WHEN NOT MATCHED THEN INSERT (
    DIM_FEATURE_ID,
    FEATURE_KEY,
    FEATURE_NAME,
    FEATURE_CATEGORY,
    FEATURE_SUBCATEGORY,
    IS_PREMIUM_FEATURE,
    RELEASE_DATE,
    DEPRECATION_DATE,
    IS_ACTIVE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
) VALUES (
    CONCAT('DIM_FEATURE_', UPPER(REPLACE(source.FEATURE_NAME, ' ', '_'))),
    UPPER(REPLACE(source.FEATURE_NAME, ' ', '_')),
    INITCAP(TRIM(source.FEATURE_NAME)),
    UPPER(source.FEATURE_CATEGORY),
    CASE 
        WHEN UPPER(source.FEATURE_CATEGORY) = 'AUDIO' THEN 'Communication'
        WHEN UPPER(source.FEATURE_CATEGORY) = 'VIDEO' THEN 'Communication'
        WHEN UPPER(source.FEATURE_CATEGORY) = 'COLLABORATION' THEN 'Productivity'
        WHEN UPPER(source.FEATURE_CATEGORY) = 'SECURITY' THEN 'Protection'
        ELSE 'General'
    END,
    CASE 
        WHEN UPPER(source.FEATURE_NAME) LIKE '%BREAKOUT%' OR 
             UPPER(source.FEATURE_NAME) LIKE '%RECORDING%' OR 
             UPPER(source.FEATURE_NAME) LIKE '%WEBINAR%' THEN TRUE 
        ELSE FALSE 
    END,
    '2020-01-01'::DATE,
    NULL,
    TRUE,
    CURRENT_DATE(),
    CURRENT_DATE(),
    'ZOOM_PLATFORM'
);
```

---

## Data Quality and Validation Rules

### 1. Data Quality Filters
- All source records must have `DATA_QUALITY_SCORE >= 0.8`
- Required fields must not be NULL or empty
- Email addresses must contain '@' symbol for domain extraction
- Date fields must be valid dates within reasonable ranges

### 2. Standardization Rules
- String fields: `TRIM()` and proper case formatting using `INITCAP()`
- Status fields: `UPPER()` for consistency
- Null handling: `COALESCE()` with appropriate defaults
- Date standardization: ISO format (YYYY-MM-DD)

### 3. Business Rule Validations
- User segments derived from plan types
- SLA hours calculated based on priority levels
- Premium features identified by naming patterns
- License tiers mapped to standard classifications

---

## Performance Optimization Recommendations

### 1. Clustering Keys
```sql
-- Recommended clustering for dimension tables
ALTER TABLE GOLD.Go_Dim_Date CLUSTER BY (DATE_KEY);
ALTER TABLE GOLD.Go_Dim_User CLUSTER BY (USER_BUSINESS_KEY, IS_CURRENT);
ALTER TABLE GOLD.Go_Dim_License CLUSTER BY (LICENSE_TYPE_KEY, IS_CURRENT);
```

### 2. Materialized Views for Common Queries
```sql
CREATE MATERIALIZED VIEW GOLD.MV_ACTIVE_USERS AS
SELECT USER_BUSINESS_KEY, USER_NAME, EMAIL_DOMAIN, PLAN_TYPE, USER_SEGMENT
FROM GOLD.Go_Dim_User
WHERE IS_CURRENT = TRUE AND ACCOUNT_STATUS = 'ACTIVE';
```

### 3. Automated Processing with Tasks
```sql
CREATE TASK GOLD.TASK_REFRESH_DIMENSIONS
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 2 * * * UTC'
AS
  CALL GOLD.SP_REFRESH_ALL_DIMENSIONS();
```

---

## Error Handling and Monitoring

### 1. Data Quality Error Tracking
```sql
INSERT INTO GOLD.Go_Data_Quality_Errors (
    ERROR_ID,
    SOURCE_TABLE_NAME,
    TARGET_TABLE_NAME,
    SOURCE_RECORD_IDENTIFIER,
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
    CONCAT('ERROR_', UUID_STRING()) AS ERROR_ID,
    'SI_USERS' AS SOURCE_TABLE_NAME,
    'Go_Dim_User' AS TARGET_TABLE_NAME,
    USER_ID AS SOURCE_RECORD_IDENTIFIER,
    'Validation' AS ERROR_TYPE,
    'Missing Data' AS ERROR_CATEGORY,
    'Required field USER_NAME is null or empty' AS ERROR_DESCRIPTION,
    'High' AS ERROR_SEVERITY,
    CURRENT_TIMESTAMP() AS DETECTED_TIMESTAMP,
    'Open' AS RESOLUTION_STATUS,
    CURRENT_DATE() AS LOAD_DATE,
    'ZOOM_PLATFORM' AS SOURCE_SYSTEM
FROM SILVER.SI_USERS
WHERE USER_NAME IS NULL OR TRIM(USER_NAME) = '';
```

### 2. Process Audit Logging
```sql
INSERT INTO GOLD.Go_Process_Audit (
    EXECUTION_ID,
    AUDIT_KEY,
    PIPELINE_NAME,
    EXECUTION_START_TIMESTAMP,
    EXECUTION_END_TIMESTAMP,
    EXECUTION_STATUS,
    RECORDS_PROCESSED,
    RECORDS_INSERTED,
    RECORDS_UPDATED,
    EXECUTED_BY,
    LOAD_DATE,
    SOURCE_SYSTEM
)
VALUES (
    UUID_STRING(),
    CONCAT('AUDIT_', CURRENT_TIMESTAMP()),
    'DIMENSION_REFRESH_PIPELINE',
    :start_time,
    CURRENT_TIMESTAMP(),
    'Success',
    :total_records,
    :inserted_records,
    :updated_records,
    CURRENT_USER(),
    CURRENT_DATE(),
    'ZOOM_PLATFORM'
);
```

---

## Summary

This comprehensive data mapping specification provides:

1. **Complete field-level mappings** for all 6 Gold layer dimension tables
2. **Snowflake-optimized transformation logic** using native functions and features
3. **SCD Type 2 implementation** for Go_Dim_User and Go_Dim_License
4. **Business rule applications** for data enrichment and standardization
5. **Performance optimization strategies** including clustering and materialized views
6. **Data quality validation** and error handling mechanisms
7. **Automated processing patterns** using Snowflake Tasks and Streams
8. **Comprehensive audit trails** for monitoring and compliance

The mappings ensure high-quality, consistent dimensional data that supports efficient analytics and reporting while maintaining data governance standards and optimal performance in the Snowflake environment.