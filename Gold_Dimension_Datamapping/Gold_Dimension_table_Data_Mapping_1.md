_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data mapping for Gold Layer Dimension tables from Silver to Gold transformation in Zoom Platform Analytics System
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Gold Layer Dimension Table Data Mapping

## Overview

This document provides comprehensive data mapping specifications for transforming Silver layer tables to Gold layer Dimension tables in the Zoom Platform Analytics System. The mapping incorporates Snowflake-specific features, SCD Type 2 implementations, business rule transformations, and performance optimizations.

### Key Architectural Considerations

1. **Performance Optimization Strategies**
   - Utilizes Snowflake's automatic micro-partitioning for optimal storage
   - Implements clustering keys on frequently queried columns
   - Leverages AUTOINCREMENT for efficient surrogate key generation
   - Pre-aggregated summary tables for improved query performance

2. **Scalability Design Patterns**
   - SCD Type 2 implementation for historical data tracking
   - Incremental processing using effective date ranges
   - Partitioning strategies based on date and key dimensions
   - Optimized for analytical workloads and reporting

3. **Data Consistency Mechanisms**
   - Comprehensive error tracking and resolution workflow
   - Complete audit trail for all transformation processes
   - Data lineage maintenance through source system tracking
   - Validation rules applied during transformation

### Snowflake-Specific Implementation Notes

1. **Clustering Key Recommendations**
   - GO_DIM_USER: Clustered by (USER_KEY, EFFECTIVE_START_DATE)
   - GO_DIM_LICENSE: Clustered by (LICENSE_KEY, EFFECTIVE_START_DATE)
   - GO_DIM_DATE: Clustered by (DATE_KEY)

2. **Micro-partition Optimization**
   - Automatic clustering based on ingestion patterns
   - Optimized for range and equality predicates
   - Efficient pruning for time-based queries

3. **Query Performance Considerations**
   - Search optimization enabled for frequently filtered columns
   - Materialized views for complex aggregations
   - Efficient join strategies using surrogate keys

---

## Data Mapping Tables

### Dimension Table: GO_DIM_USER

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_USER | USER_DIM_ID | Silver | N/A | N/A | `AUTOINCREMENT` - Snowflake auto-generated surrogate key |
| Gold | GO_DIM_USER | USER_KEY | Silver | SI_USERS | USER_ID | `USER_ID::VARCHAR(16777216)` - Direct mapping as business key |
| Gold | GO_DIM_USER | USER_NAME | Silver | SI_USERS | USER_NAME | `TRIM(UPPER(USER_NAME))::VARCHAR(16777216)` - Standardized formatting |
| Gold | GO_DIM_USER | EMAIL_DOMAIN | Silver | SI_USERS | EMAIL | `SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2)::VARCHAR(16777216)` - Extract domain for analysis |
| Gold | GO_DIM_USER | COMPANY | Silver | SI_USERS | COMPANY | `TRIM(COMPANY)::VARCHAR(16777216)` - Standardized company name |
| Gold | GO_DIM_USER | PLAN_TYPE | Silver | SI_USERS | PLAN_TYPE | `UPPER(PLAN_TYPE)::VARCHAR(16777216)` - Standardized plan type |
| Gold | GO_DIM_USER | USER_CATEGORY | Silver | SI_USERS | PLAN_TYPE | `CASE WHEN UPPER(PLAN_TYPE) IN ('ENTERPRISE', 'BUSINESS') THEN 'PREMIUM' WHEN UPPER(PLAN_TYPE) = 'PRO' THEN 'STANDARD' ELSE 'BASIC' END::VARCHAR(100)` - Business categorization |
| Gold | GO_DIM_USER | ACCOUNT_CREATION_DATE | Silver | SI_USERS | LOAD_DATE | `LOAD_DATE::DATE` - Account creation tracking |
| Gold | GO_DIM_USER | LAST_ACTIVITY_DATE | Silver | SI_USERS | UPDATE_DATE | `UPDATE_DATE::DATE` - Last activity tracking |
| Gold | GO_DIM_USER | EFFECTIVE_START_DATE | Silver | N/A | N/A | `CURRENT_DATE::DATE` - SCD Type 2 start date |
| Gold | GO_DIM_USER | EFFECTIVE_END_DATE | Silver | N/A | N/A | `'9999-12-31'::DATE` - SCD Type 2 end date (active record) |
| Gold | GO_DIM_USER | CURRENT_RECORD_FLAG | Silver | N/A | N/A | `TRUE::BOOLEAN` - SCD Type 2 current record indicator |
| Gold | GO_DIM_USER | LOAD_DATE | Silver | N/A | N/A | `CURRENT_DATE::DATE` - Gold layer load date |
| Gold | GO_DIM_USER | UPDATE_DATE | Silver | N/A | N/A | `CURRENT_DATE::DATE` - Gold layer update date |
| Gold | GO_DIM_USER | SOURCE_SYSTEM | Silver | SI_USERS | SOURCE_SYSTEM | `SOURCE_SYSTEM::VARCHAR(16777216)` - Data lineage tracking |

### Dimension Table: GO_DIM_DATE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_DATE | DATE_DIM_ID | Silver | N/A | N/A | `AUTOINCREMENT` - Snowflake auto-generated surrogate key |
| Gold | GO_DIM_DATE | DATE_KEY | Silver | N/A | N/A | `DATEADD('day', ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE)` - Generated date sequence |
| Gold | GO_DIM_DATE | YEAR | Silver | N/A | N/A | `YEAR(DATE_KEY)::NUMBER(4,0)` - Extract year from date |
| Gold | GO_DIM_DATE | QUARTER | Silver | N/A | N/A | `QUARTER(DATE_KEY)::NUMBER(1,0)` - Extract quarter from date |
| Gold | GO_DIM_DATE | MONTH | Silver | N/A | N/A | `MONTH(DATE_KEY)::NUMBER(2,0)` - Extract month from date |
| Gold | GO_DIM_DATE | MONTH_NAME | Silver | N/A | N/A | `MONTHNAME(DATE_KEY)::VARCHAR(20)` - Month name for reporting |
| Gold | GO_DIM_DATE | WEEK_OF_YEAR | Silver | N/A | N/A | `WEEKOFYEAR(DATE_KEY)::NUMBER(2,0)` - Week number for analysis |
| Gold | GO_DIM_DATE | DAY_OF_MONTH | Silver | N/A | N/A | `DAY(DATE_KEY)::NUMBER(2,0)` - Day of month |
| Gold | GO_DIM_DATE | DAY_OF_WEEK | Silver | N/A | N/A | `DAYOFWEEK(DATE_KEY)::NUMBER(1,0)` - Day of week (1=Sunday) |
| Gold | GO_DIM_DATE | DAY_NAME | Silver | N/A | N/A | `DAYNAME(DATE_KEY)::VARCHAR(20)` - Day name for reporting |
| Gold | GO_DIM_DATE | IS_WEEKEND | Silver | N/A | N/A | `CASE WHEN DAYOFWEEK(DATE_KEY) IN (1, 7) THEN TRUE ELSE FALSE END::BOOLEAN` - Weekend indicator |
| Gold | GO_DIM_DATE | IS_HOLIDAY | Silver | N/A | N/A | `FALSE::BOOLEAN` - Holiday indicator (to be updated with holiday logic) |
| Gold | GO_DIM_DATE | FISCAL_YEAR | Silver | N/A | N/A | `CASE WHEN MONTH(DATE_KEY) >= 4 THEN YEAR(DATE_KEY) ELSE YEAR(DATE_KEY) - 1 END::NUMBER(4,0)` - Fiscal year calculation |
| Gold | GO_DIM_DATE | FISCAL_QUARTER | Silver | N/A | N/A | `CASE WHEN MONTH(DATE_KEY) IN (4,5,6) THEN 1 WHEN MONTH(DATE_KEY) IN (7,8,9) THEN 2 WHEN MONTH(DATE_KEY) IN (10,11,12) THEN 3 ELSE 4 END::NUMBER(1,0)` - Fiscal quarter |
| Gold | GO_DIM_DATE | LOAD_DATE | Silver | N/A | N/A | `CURRENT_DATE::DATE` - Gold layer load date |
| Gold | GO_DIM_DATE | SOURCE_SYSTEM | Silver | N/A | N/A | `'SYSTEM_GENERATED'::VARCHAR(16777216)` - System generated dimension |

### Dimension Table: GO_DIM_LICENSE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_LICENSE | LICENSE_DIM_ID | Silver | N/A | N/A | `AUTOINCREMENT` - Snowflake auto-generated surrogate key |
| Gold | GO_DIM_LICENSE | LICENSE_KEY | Silver | SI_LICENSES | LICENSE_ID | `LICENSE_ID::VARCHAR(16777216)` - Direct mapping as business key |
| Gold | GO_DIM_LICENSE | LICENSE_TYPE | Silver | SI_LICENSES | LICENSE_TYPE | `UPPER(LICENSE_TYPE)::VARCHAR(16777216)` - Standardized license type |
| Gold | GO_DIM_LICENSE | LICENSE_TIER | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) = 'ENTERPRISE' THEN 'TIER_1' WHEN UPPER(LICENSE_TYPE) = 'BUSINESS' THEN 'TIER_2' WHEN UPPER(LICENSE_TYPE) = 'PRO' THEN 'TIER_3' WHEN UPPER(LICENSE_TYPE) = 'BASIC' THEN 'TIER_4' ELSE 'TIER_5' END::VARCHAR(100)` - License tier classification |
| Gold | GO_DIM_LICENSE | START_DATE | Silver | SI_LICENSES | START_DATE | `START_DATE::DATE` - License start date |
| Gold | GO_DIM_LICENSE | END_DATE | Silver | SI_LICENSES | END_DATE | `END_DATE::DATE` - License end date |
| Gold | GO_DIM_LICENSE | LICENSE_STATUS | Silver | SI_LICENSES | LICENSE_STATUS | `LICENSE_STATUS::VARCHAR(50)` - License status |
| Gold | GO_DIM_LICENSE | DAYS_TO_EXPIRY | Silver | SI_LICENSES | DAYS_TO_EXPIRY | `DAYS_TO_EXPIRY::NUMBER(38,0)` - Days until expiry |
| Gold | GO_DIM_LICENSE | LICENSE_COST | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) = 'ENTERPRISE' THEN 240.00 WHEN UPPER(LICENSE_TYPE) = 'BUSINESS' THEN 120.00 WHEN UPPER(LICENSE_TYPE) = 'PRO' THEN 60.00 WHEN UPPER(LICENSE_TYPE) = 'BASIC' THEN 20.00 ELSE 0.00 END::NUMBER(10,2)` - Calculated license cost |
| Gold | GO_DIM_LICENSE | UTILIZATION_RATE | Silver | N/A | N/A | `0.00::NUMBER(5,2)` - Utilization rate (to be calculated from usage data) |
| Gold | GO_DIM_LICENSE | EFFECTIVE_START_DATE | Silver | N/A | N/A | `CURRENT_DATE::DATE` - SCD Type 2 start date |
| Gold | GO_DIM_LICENSE | EFFECTIVE_END_DATE | Silver | N/A | N/A | `'9999-12-31'::DATE` - SCD Type 2 end date (active record) |
| Gold | GO_DIM_LICENSE | CURRENT_RECORD_FLAG | Silver | N/A | N/A | `TRUE::BOOLEAN` - SCD Type 2 current record indicator |
| Gold | GO_DIM_LICENSE | LOAD_DATE | Silver | N/A | N/A | `CURRENT_DATE::DATE` - Gold layer load date |
| Gold | GO_DIM_LICENSE | UPDATE_DATE | Silver | N/A | N/A | `CURRENT_DATE::DATE` - Gold layer update date |
| Gold | GO_DIM_LICENSE | SOURCE_SYSTEM | Silver | SI_LICENSES | SOURCE_SYSTEM | `SOURCE_SYSTEM::VARCHAR(16777216)` - Data lineage tracking |

### Code Table: GO_CODE_FEATURE_TYPES

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_CODE_FEATURE_TYPES | FEATURE_TYPE_ID | Silver | N/A | N/A | `AUTOINCREMENT` - Snowflake auto-generated surrogate key |
| Gold | GO_CODE_FEATURE_TYPES | FEATURE_CODE | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `UPPER(REPLACE(FEATURE_NAME, ' ', '_'))` - Standardized feature code |
| Gold | GO_CODE_FEATURE_TYPES | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `TRIM(FEATURE_NAME)` - Cleaned feature name |
| Gold | GO_CODE_FEATURE_TYPES | FEATURE_CATEGORY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN FEATURE_NAME ILIKE '%screen%share%' THEN 'COLLABORATION' WHEN FEATURE_NAME ILIKE '%record%' THEN 'RECORDING' WHEN FEATURE_NAME ILIKE '%chat%' THEN 'COMMUNICATION' WHEN FEATURE_NAME ILIKE '%breakout%' THEN 'ADVANCED' ELSE 'BASIC' END` - Feature categorization |
| Gold | GO_CODE_FEATURE_TYPES | FEATURE_DESCRIPTION | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `'Feature usage tracking for ' || FEATURE_NAME` - Generated description |
| Gold | GO_CODE_FEATURE_TYPES | IS_PREMIUM_FEATURE | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN FEATURE_NAME ILIKE '%breakout%' OR FEATURE_NAME ILIKE '%record%' THEN TRUE ELSE FALSE END::BOOLEAN` - Premium feature flag |
| Gold | GO_CODE_FEATURE_TYPES | ADOPTION_PRIORITY | Silver | N/A | N/A | `'MEDIUM'` - Default adoption priority |
| Gold | GO_CODE_FEATURE_TYPES | LOAD_DATE | Silver | N/A | N/A | `CURRENT_DATE` - Gold layer load date |
| Gold | GO_CODE_FEATURE_TYPES | UPDATE_DATE | Silver | N/A | N/A | `CURRENT_DATE` - Gold layer update date |
| Gold | GO_CODE_FEATURE_TYPES | SOURCE_SYSTEM | Silver | N/A | N/A | `'SILVER_LAYER'` - Source system identifier |

### Code Table: GO_CODE_PLAN_TYPES

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_CODE_PLAN_TYPES | PLAN_TYPE_ID | Silver | N/A | N/A | `AUTOINCREMENT` - Snowflake auto-generated surrogate key |
| Gold | GO_CODE_PLAN_TYPES | PLAN_CODE | Silver | N/A | N/A | `Business-defined values: 'ENT', 'BUS', 'PRO', 'BAS', 'FREE'` - Standardized plan codes |
| Gold | GO_CODE_PLAN_TYPES | PLAN_NAME | Silver | N/A | N/A | `Business-defined values: 'Enterprise', 'Business', 'Professional', 'Basic', 'Free'` - Plan names |
| Gold | GO_CODE_PLAN_TYPES | PLAN_TIER | Silver | N/A | N/A | `Business-defined values: 'PREMIUM', 'STANDARD', 'BASIC'` - Plan tier classification |
| Gold | GO_CODE_PLAN_TYPES | PLAN_DESCRIPTION | Silver | N/A | N/A | `Business-defined descriptions for each plan type` - Plan descriptions |
| Gold | GO_CODE_PLAN_TYPES | MONTHLY_COST | Silver | N/A | N/A | `Business-defined costs: 240.00, 120.00, 60.00, 20.00, 0.00` - Monthly cost by plan |
| Gold | GO_CODE_PLAN_TYPES | MAX_PARTICIPANTS | Silver | N/A | N/A | `Business-defined limits: 1000, 300, 100, 40, 3` - Maximum participants by plan |
| Gold | GO_CODE_PLAN_TYPES | FEATURE_SET | Silver | N/A | N/A | `Business-defined feature sets: 'ALL_FEATURES', 'BUSINESS_FEATURES', etc.` - Available features |
| Gold | GO_CODE_PLAN_TYPES | LOAD_DATE | Silver | N/A | N/A | `CURRENT_DATE` - Gold layer load date |
| Gold | GO_CODE_PLAN_TYPES | UPDATE_DATE | Silver | N/A | N/A | `CURRENT_DATE` - Gold layer update date |
| Gold | GO_CODE_PLAN_TYPES | SOURCE_SYSTEM | Silver | N/A | N/A | `'BUSINESS_RULES'` - Source system identifier |

---

## Transformation Implementation Examples

### 1. SCD Type 2 Implementation for GO_DIM_USER

```sql
-- SCD Type 2 processing using MERGE INTO
MERGE INTO GOLD.GO_DIM_USER tgt
USING (
    SELECT 
        USER_ID as USER_KEY,
        TRIM(UPPER(USER_NAME)) as USER_NAME,
        SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) as EMAIL_DOMAIN,
        TRIM(COMPANY) as COMPANY,
        UPPER(PLAN_TYPE) as PLAN_TYPE,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('ENTERPRISE', 'BUSINESS') THEN 'PREMIUM'
            WHEN UPPER(PLAN_TYPE) = 'PRO' THEN 'STANDARD'
            ELSE 'BASIC'
        END as USER_CATEGORY,
        LOAD_DATE as ACCOUNT_CREATION_DATE,
        UPDATE_DATE as LAST_ACTIVITY_DATE,
        SOURCE_SYSTEM
    FROM SILVER.SI_USERS
) src ON tgt.USER_KEY = src.USER_KEY AND tgt.CURRENT_RECORD_FLAG = TRUE
WHEN MATCHED AND (
    tgt.USER_NAME != src.USER_NAME OR
    tgt.EMAIL_DOMAIN != src.EMAIL_DOMAIN OR
    tgt.COMPANY != src.COMPANY OR
    tgt.PLAN_TYPE != src.PLAN_TYPE OR
    tgt.USER_CATEGORY != src.USER_CATEGORY
) THEN UPDATE SET 
    EFFECTIVE_END_DATE = CURRENT_DATE - 1,
    CURRENT_RECORD_FLAG = FALSE,
    UPDATE_DATE = CURRENT_DATE
WHEN NOT MATCHED THEN INSERT (
    USER_KEY, USER_NAME, EMAIL_DOMAIN, COMPANY, PLAN_TYPE, USER_CATEGORY,
    ACCOUNT_CREATION_DATE, LAST_ACTIVITY_DATE,
    EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, CURRENT_RECORD_FLAG,
    LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
) VALUES (
    src.USER_KEY, src.USER_NAME, src.EMAIL_DOMAIN, src.COMPANY, 
    src.PLAN_TYPE, src.USER_CATEGORY,
    src.ACCOUNT_CREATION_DATE, src.LAST_ACTIVITY_DATE,
    CURRENT_DATE, '9999-12-31', TRUE,
    CURRENT_DATE, CURRENT_DATE, src.SOURCE_SYSTEM
);
```

### 2. Date Dimension Population

```sql
-- Generate comprehensive date dimension
INSERT INTO GOLD.GO_DIM_DATE (
    DATE_KEY, YEAR, QUARTER, MONTH, MONTH_NAME, WEEK_OF_YEAR,
    DAY_OF_MONTH, DAY_OF_WEEK, DAY_NAME, IS_WEEKEND, IS_HOLIDAY,
    FISCAL_YEAR, FISCAL_QUARTER, LOAD_DATE, SOURCE_SYSTEM
)
WITH date_range AS (
    SELECT DATEADD('day', ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) as date_val
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years of dates
)
SELECT 
    date_val as DATE_KEY,
    YEAR(date_val) as YEAR,
    QUARTER(date_val) as QUARTER,
    MONTH(date_val) as MONTH,
    MONTHNAME(date_val) as MONTH_NAME,
    WEEKOFYEAR(date_val) as WEEK_OF_YEAR,
    DAY(date_val) as DAY_OF_MONTH,
    DAYOFWEEK(date_val) as DAY_OF_WEEK,
    DAYNAME(date_val) as DAY_NAME,
    CASE WHEN DAYOFWEEK(date_val) IN (1, 7) THEN TRUE ELSE FALSE END as IS_WEEKEND,
    FALSE as IS_HOLIDAY,
    CASE WHEN MONTH(date_val) >= 4 THEN YEAR(date_val) ELSE YEAR(date_val) - 1 END as FISCAL_YEAR,
    CASE 
        WHEN MONTH(date_val) IN (4,5,6) THEN 1
        WHEN MONTH(date_val) IN (7,8,9) THEN 2
        WHEN MONTH(date_val) IN (10,11,12) THEN 3
        ELSE 4
    END as FISCAL_QUARTER,
    CURRENT_DATE as LOAD_DATE,
    'SYSTEM_GENERATED' as SOURCE_SYSTEM
FROM date_range;
```

### 3. License Dimension with Business Rules

```sql
-- Populate license dimension with calculated fields
INSERT INTO GOLD.GO_DIM_LICENSE (
    LICENSE_KEY, LICENSE_TYPE, LICENSE_TIER, START_DATE, END_DATE,
    LICENSE_STATUS, DAYS_TO_EXPIRY, LICENSE_COST, UTILIZATION_RATE,
    EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, CURRENT_RECORD_FLAG,
    LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    LICENSE_ID as LICENSE_KEY,
    UPPER(LICENSE_TYPE) as LICENSE_TYPE,
    CASE 
        WHEN UPPER(LICENSE_TYPE) = 'ENTERPRISE' THEN 'TIER_1'
        WHEN UPPER(LICENSE_TYPE) = 'BUSINESS' THEN 'TIER_2'
        WHEN UPPER(LICENSE_TYPE) = 'PRO' THEN 'TIER_3'
        WHEN UPPER(LICENSE_TYPE) = 'BASIC' THEN 'TIER_4'
        ELSE 'TIER_5'
    END as LICENSE_TIER,
    START_DATE,
    END_DATE,
    LICENSE_STATUS,
    DAYS_TO_EXPIRY,
    CASE 
        WHEN UPPER(LICENSE_TYPE) = 'ENTERPRISE' THEN 240.00
        WHEN UPPER(LICENSE_TYPE) = 'BUSINESS' THEN 120.00
        WHEN UPPER(LICENSE_TYPE) = 'PRO' THEN 60.00
        WHEN UPPER(LICENSE_TYPE) = 'BASIC' THEN 20.00
        ELSE 0.00
    END as LICENSE_COST,
    0.00 as UTILIZATION_RATE,
    CURRENT_DATE as EFFECTIVE_START_DATE,
    '9999-12-31' as EFFECTIVE_END_DATE,
    TRUE as CURRENT_RECORD_FLAG,
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    SOURCE_SYSTEM
FROM SILVER.SI_LICENSES;
```

---

## Data Quality and Validation Rules

### 1. Data Quality Checks

```sql
-- Comprehensive data quality validation
SELECT 
    'GO_DIM_USER' as TABLE_NAME,
    'NULL_USER_KEY' as CHECK_TYPE,
    COUNT(*) as VIOLATION_COUNT
FROM GOLD.GO_DIM_USER 
WHERE USER_KEY IS NULL

UNION ALL

SELECT 
    'GO_DIM_USER' as TABLE_NAME,
    'INVALID_EMAIL_DOMAIN' as CHECK_TYPE,
    COUNT(*) as VIOLATION_COUNT
FROM GOLD.GO_DIM_USER 
WHERE EMAIL_DOMAIN IS NULL OR EMAIL_DOMAIN = ''

UNION ALL

SELECT 
    'GO_DIM_LICENSE' as TABLE_NAME,
    'INVALID_DATE_RANGE' as CHECK_TYPE,
    COUNT(*) as VIOLATION_COUNT
FROM GOLD.GO_DIM_LICENSE 
WHERE START_DATE > END_DATE;
```

### 2. Error Handling Integration

```sql
-- Error logging for dimension transformations
INSERT INTO GOLD.GO_ERROR_DATA (
    ERROR_KEY, PIPELINE_RUN_TIMESTAMP, SOURCE_TABLE, SOURCE_RECORD_KEY,
    ERROR_TYPE, ERROR_COLUMN, ERROR_VALUE, ERROR_DESCRIPTION,
    VALIDATION_RULE, ERROR_SEVERITY, ERROR_TIMESTAMP,
    PROCESSING_BATCH_KEY, RESOLUTION_STATUS, LOAD_DATE, SOURCE_SYSTEM
)
SELECT 
    'DIM_USER_' || USER_ID as ERROR_KEY,
    CURRENT_TIMESTAMP as PIPELINE_RUN_TIMESTAMP,
    'SI_USERS' as SOURCE_TABLE,
    USER_ID as SOURCE_RECORD_KEY,
    'INVALID_EMAIL' as ERROR_TYPE,
    'EMAIL' as ERROR_COLUMN,
    EMAIL as ERROR_VALUE,
    'Email does not contain @ symbol' as ERROR_DESCRIPTION,
    'EMAIL LIKE %@%' as VALIDATION_RULE,
    'HIGH' as ERROR_SEVERITY,
    CURRENT_TIMESTAMP as ERROR_TIMESTAMP,
    'BATCH_' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS') as PROCESSING_BATCH_KEY,
    'OPEN' as RESOLUTION_STATUS,
    CURRENT_DATE as LOAD_DATE,
    'DIMENSION_TRANSFORMATION' as SOURCE_SYSTEM
FROM SILVER.SI_USERS
WHERE EMAIL IS NULL OR EMAIL NOT LIKE '%@%';
```

---

## Performance Optimization Guidelines

### 1. Clustering Strategy

```sql
-- Recommended clustering keys for optimal performance
ALTER TABLE GOLD.GO_DIM_USER CLUSTER BY (USER_KEY, EFFECTIVE_START_DATE);
ALTER TABLE GOLD.GO_DIM_LICENSE CLUSTER BY (LICENSE_KEY, EFFECTIVE_START_DATE);
ALTER TABLE GOLD.GO_DIM_DATE CLUSTER BY (DATE_KEY);
```

### 2. Search Optimization

```sql
-- Enable search optimization for frequently queried columns
ALTER TABLE GOLD.GO_DIM_USER ADD SEARCH OPTIMIZATION ON (EMAIL_DOMAIN, COMPANY, PLAN_TYPE);
ALTER TABLE GOLD.GO_DIM_LICENSE ADD SEARCH OPTIMIZATION ON (LICENSE_TYPE, LICENSE_STATUS);
```

### 3. Materialized Views for Complex Queries

```sql
-- Create materialized view for user hierarchy analysis
CREATE MATERIALIZED VIEW GOLD.MV_USER_HIERARCHY AS
SELECT 
    USER_KEY,
    COMPANY,
    EMAIL_DOMAIN,
    PLAN_TYPE,
    USER_CATEGORY,
    CASE 
        WHEN COMPANY IS NOT NULL THEN COMPANY
        ELSE EMAIL_DOMAIN
    END as ORGANIZATION_LEVEL,
    CASE 
        WHEN USER_CATEGORY = 'PREMIUM' THEN 1
        WHEN USER_CATEGORY = 'STANDARD' THEN 2
        WHEN USER_CATEGORY = 'BASIC' THEN 3
        ELSE 4
    END as HIERARCHY_LEVEL
FROM GOLD.GO_DIM_USER
WHERE CURRENT_RECORD_FLAG = TRUE;
```

---

## Data Lineage and Traceability

### Source to Target Mapping Summary

1. **GO_DIM_USER**
   - **Primary Source**: SILVER.SI_USERS
   - **Key Transformations**: Email domain extraction, user categorization, SCD Type 2
   - **Business Rules**: Plan type standardization, name formatting
   - **Update Pattern**: SCD Type 2 with effective dating

2. **GO_DIM_DATE**
   - **Primary Source**: System Generated
   - **Key Transformations**: Complete date attribute generation, fiscal calculations
   - **Business Rules**: Weekend/holiday identification, fiscal year logic
   - **Update Pattern**: Static dimension, populated once

3. **GO_DIM_LICENSE**
   - **Primary Source**: SILVER.SI_LICENSES
   - **Key Transformations**: License tier classification, cost calculation, SCD Type 2
   - **Business Rules**: License status standardization, cost assignment
   - **Update Pattern**: SCD Type 2 with effective dating

4. **GO_CODE_FEATURE_TYPES**
   - **Primary Source**: SILVER.SI_FEATURE_USAGE (distinct values)
   - **Key Transformations**: Feature categorization, premium flag assignment
   - **Business Rules**: Category classification based on feature names
   - **Update Pattern**: Incremental updates for new features

5. **GO_CODE_PLAN_TYPES**
   - **Primary Source**: Business-defined reference data
   - **Key Transformations**: Static business rule implementation
   - **Business Rules**: Cost and feature set assignments
   - **Update Pattern**: Manual updates for new plan types

---

## Monitoring and Maintenance

### 1. Data Freshness Monitoring

```sql
-- Monitor data freshness across dimension tables
SELECT 
    'GO_DIM_USER' as TABLE_NAME,
    MAX(LOAD_DATE) as LAST_LOAD_DATE,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(CASE WHEN CURRENT_RECORD_FLAG = TRUE THEN 1 END) as CURRENT_RECORDS
FROM GOLD.GO_DIM_USER

UNION ALL

SELECT 
    'GO_DIM_LICENSE' as TABLE_NAME,
    MAX(LOAD_DATE) as LAST_LOAD_DATE,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(CASE WHEN CURRENT_RECORD_FLAG = TRUE THEN 1 END) as CURRENT_RECORDS
FROM GOLD.GO_DIM_LICENSE;
```

### 2. SCD Type 2 Health Check

```sql
-- Validate SCD Type 2 implementation
SELECT 
    USER_KEY,
    COUNT(*) as VERSION_COUNT,
    MAX(CASE WHEN CURRENT_RECORD_FLAG = TRUE THEN EFFECTIVE_START_DATE END) as CURRENT_START_DATE,
    COUNT(CASE WHEN CURRENT_RECORD_FLAG = TRUE THEN 1 END) as CURRENT_RECORD_COUNT
FROM GOLD.GO_DIM_USER
GROUP BY USER_KEY
HAVING COUNT(CASE WHEN CURRENT_RECORD_FLAG = TRUE THEN 1 END) != 1;
```

---

*End of Gold Layer Dimension Table Data Mapping Document*