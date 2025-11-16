_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold layer dimension table transformation recommendations for Zoom Platform Analytics System ensuring unique row values
## *Version*: 2
## *Updated on*:   
_____________________________________________

# Gold Layer Dimension Table Transformation Recommendations

## Overview

This document provides comprehensive transformation rules for converting Silver layer data into Gold layer dimension tables for the Zoom Platform Analytics System. The primary focus is ensuring each dimension table contains unique row values for every unique combination of defining attributes, supporting optimal analytical performance and data integrity.

## Transformation Rules for Dimension Tables

### 1. GO_DIM_USER - User Dimension Transformation

**Rationale**: Transform Silver layer user data into a comprehensive user dimension with unique records per user, incorporating slowly changing dimension (SCD) Type 2 logic to track historical changes while ensuring current active records are unique.

**Uniqueness Strategy**: Implement composite uniqueness based on USER_ID + IS_CURRENT_RECORD flag to ensure only one active record per user exists.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_DIM_USER (
    USER_KEY,
    USER_DIM_ID,
    USER_ID,
    USER_NAME,
    EMAIL_DOMAIN,
    COMPANY,
    PLAN_TYPE,
    PLAN_CATEGORY,
    REGISTRATION_DATE,
    USER_STATUS,
    GEOGRAPHIC_REGION,
    INDUSTRY_SECTOR,
    USER_ROLE,
    ACCOUNT_TYPE,
    LANGUAGE_PREFERENCE,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    IS_CURRENT_RECORD,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT DISTINCT
    CONCAT('USR_', USER_ID, '_', ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY LOAD_TIMESTAMP DESC)) AS USER_KEY,
    NULL AS USER_DIM_ID, -- Auto-increment
    USER_ID,
    UPPER(TRIM(USER_NAME)) AS USER_NAME,
    UPPER(SPLIT_PART(EMAIL, '@', 2)) AS EMAIL_DOMAIN,
    UPPER(TRIM(COMPANY)) AS COMPANY,
    CASE 
        WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'BASIC'
        WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'PRO'
        WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'ENTERPRISE'
        ELSE 'OTHER'
    END AS PLAN_TYPE,
    CASE 
        WHEN UPPER(PLAN_TYPE) IN ('FREE') THEN 'FREE_TIER'
        WHEN UPPER(PLAN_TYPE) IN ('BASIC', 'PRO', 'PROFESSIONAL') THEN 'PAID_INDIVIDUAL'
        WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'PAID_ORGANIZATION'
        ELSE 'UNKNOWN'
    END AS PLAN_CATEGORY,
    DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
    'ACTIVE' AS USER_STATUS,
    'UNKNOWN' AS GEOGRAPHIC_REGION,
    'UNKNOWN' AS INDUSTRY_SECTOR,
    'STANDARD_USER' AS USER_ROLE,
    'INDIVIDUAL' AS ACCOUNT_TYPE,
    'ENGLISH' AS LANGUAGE_PREFERENCE,
    DATE(LOAD_TIMESTAMP) AS EFFECTIVE_START_DATE,
    DATE('9999-12-31') AS EFFECTIVE_END_DATE,
    TRUE AS IS_CURRENT_RECORD,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    SOURCE_SYSTEM
FROM SILVER.SI_USERS
WHERE VALIDATION_STATUS = 'PASSED'
QUALIFY ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY LOAD_TIMESTAMP DESC) = 1;
```

### 2. GO_DIM_DATE - Date Dimension Transformation

**Rationale**: Create a comprehensive date dimension covering the full range of dates needed for analysis, ensuring each date appears only once with complete temporal attributes.

**Uniqueness Strategy**: Single unique record per calendar date with DATE_KEY as the primary identifier.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_DIM_DATE (
    DATE_KEY,
    DATE_ID,
    DATE_VALUE,
    YEAR,
    QUARTER,
    MONTH,
    MONTH_NAME,
    DAY_OF_MONTH,
    DAY_OF_WEEK,
    DAY_NAME,
    IS_WEEKEND,
    IS_HOLIDAY,
    FISCAL_YEAR,
    FISCAL_QUARTER,
    WEEK_OF_YEAR,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
WITH date_range AS (
    SELECT 
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years of dates
)
SELECT DISTINCT
    date_value AS DATE_KEY,
    NULL AS DATE_ID, -- Auto-increment
    date_value AS DATE_VALUE,
    YEAR(date_value) AS YEAR,
    QUARTER(date_value) AS QUARTER,
    MONTH(date_value) AS MONTH,
    MONTHNAME(date_value) AS MONTH_NAME,
    DAY(date_value) AS DAY_OF_MONTH,
    DAYOFWEEK(date_value) AS DAY_OF_WEEK,
    DAYNAME(date_value) AS DAY_NAME,
    CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
    FALSE AS IS_HOLIDAY, -- To be updated with holiday logic
    CASE WHEN MONTH(date_value) >= 4 THEN YEAR(date_value) ELSE YEAR(date_value) - 1 END AS FISCAL_YEAR,
    CASE WHEN MONTH(date_value) >= 4 THEN QUARTER(date_value) ELSE QUARTER(date_value) + 4 END AS FISCAL_QUARTER,
    WEEKOFYEAR(date_value) AS WEEK_OF_YEAR,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'SYSTEM_GENERATED' AS SOURCE_SYSTEM
FROM date_range
WHERE date_value <= CURRENT_DATE() + INTERVAL '2 years';
```

### 3. GO_DIM_FEATURE - Feature Dimension Transformation

**Rationale**: Transform feature usage data into a standardized feature dimension with unique records per feature, including feature categorization and characteristics.

**Uniqueness Strategy**: One unique record per FEATURE_NAME with standardized naming and categorization.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_DIM_FEATURE (
    FEATURE_KEY,
    FEATURE_ID,
    FEATURE_NAME,
    FEATURE_CATEGORY,
    FEATURE_TYPE,
    FEATURE_COMPLEXITY,
    IS_PREMIUM_FEATURE,
    FEATURE_RELEASE_DATE,
    FEATURE_STATUS,
    USAGE_FREQUENCY_CATEGORY,
    FEATURE_DESCRIPTION,
    TARGET_USER_SEGMENT,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT DISTINCT
    CONCAT('FTR_', UPPER(REPLACE(REPLACE(FEATURE_NAME, ' ', '_'), '-', '_'))) AS FEATURE_KEY,
    NULL AS FEATURE_ID, -- Auto-increment
    UPPER(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
    CASE 
        WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'COLLABORATION'
        WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'RECORDING'
        WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'COMMUNICATION'
        WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'ENGAGEMENT'
        WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'MEETING_MANAGEMENT'
        ELSE 'OTHER'
    END AS FEATURE_CATEGORY,
    CASE 
        WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' THEN 'BASIC'
        WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' THEN 'ADVANCED'
        ELSE 'STANDARD'
    END AS FEATURE_TYPE,
    CASE 
        WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'HIGH'
        WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'MEDIUM'
        ELSE 'LOW'
    END AS FEATURE_COMPLEXITY,
    CASE 
        WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN TRUE
        ELSE FALSE
    END AS IS_PREMIUM_FEATURE,
    DATE('2020-01-01') AS FEATURE_RELEASE_DATE, -- Default, to be updated
    'ACTIVE' AS FEATURE_STATUS,
    'MEDIUM' AS USAGE_FREQUENCY_CATEGORY, -- To be calculated from usage data
    CONCAT('Feature for ', FEATURE_NAME) AS FEATURE_DESCRIPTION,
    'ALL_USERS' AS TARGET_USER_SEGMENT,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    SOURCE_SYSTEM
FROM (
    SELECT DISTINCT 
        FEATURE_NAME,
        SOURCE_SYSTEM
    FROM SILVER.SI_FEATURE_USAGE
    WHERE VALIDATION_STATUS = 'PASSED'
      AND FEATURE_NAME IS NOT NULL
      AND TRIM(FEATURE_NAME) != ''
);
```

### 4. GO_DIM_LICENSE - License Dimension Transformation

**Rationale**: Create a comprehensive license dimension with unique records per license type, including pricing and entitlement information.

**Uniqueness Strategy**: One unique record per LICENSE_TYPE with current record flag for SCD Type 2 implementation.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_DIM_LICENSE (
    LICENSE_KEY,
    LICENSE_ID,
    LICENSE_TYPE,
    LICENSE_CATEGORY,
    LICENSE_TIER,
    MAX_PARTICIPANTS,
    STORAGE_LIMIT_GB,
    RECORDING_LIMIT_HOURS,
    ADMIN_FEATURES_INCLUDED,
    API_ACCESS_INCLUDED,
    SSO_SUPPORT_INCLUDED,
    MONTHLY_PRICE,
    ANNUAL_PRICE,
    LICENSE_BENEFITS,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    IS_CURRENT_RECORD,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT DISTINCT
    CONCAT('LIC_', UPPER(REPLACE(LICENSE_TYPE, ' ', '_'))) AS LICENSE_KEY,
    NULL AS LICENSE_ID, -- Auto-increment
    UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%FREE%' THEN 'FREE'
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'BASIC'
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'PROFESSIONAL'
        WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' OR UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'ENTERPRISE'
        ELSE 'OTHER'
    END AS LICENSE_CATEGORY,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%FREE%' THEN 'TIER_0'
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'TIER_1'
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'TIER_2'
        WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' THEN 'TIER_3'
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'TIER_4'
        ELSE 'TIER_UNKNOWN'
    END AS LICENSE_TIER,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%FREE%' THEN 100
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 100
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 500
        WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' THEN 1000
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 10000
        ELSE 100
    END AS MAX_PARTICIPANTS,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%FREE%' THEN 5
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 10
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 100
        WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' THEN 1000
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 10000
        ELSE 5
    END AS STORAGE_LIMIT_GB,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%FREE%' THEN 0
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 10
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 100
        WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' THEN 1000
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 10000
        ELSE 0
    END AS RECORDING_LIMIT_HOURS,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' OR UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE
        ELSE FALSE
    END AS ADMIN_FEATURES_INCLUDED,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' OR UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' OR UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE
        ELSE FALSE
    END AS API_ACCESS_INCLUDED,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE
        ELSE FALSE
    END AS SSO_SUPPORT_INCLUDED,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%FREE%' THEN 0.00
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 14.99
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 19.99
        WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' THEN 29.99
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 49.99
        ELSE 0.00
    END AS MONTHLY_PRICE,
    CASE 
        WHEN UPPER(LICENSE_TYPE) LIKE '%FREE%' THEN 0.00
        WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 149.90
        WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 199.90
        WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' THEN 299.90
        WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 499.90
        ELSE 0.00
    END AS ANNUAL_PRICE,
    CONCAT('Benefits for ', LICENSE_TYPE, ' license') AS LICENSE_BENEFITS,
    MIN(START_DATE) AS EFFECTIVE_START_DATE,
    DATE('9999-12-31') AS EFFECTIVE_END_DATE,
    TRUE AS IS_CURRENT_RECORD,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    SOURCE_SYSTEM
FROM SILVER.SI_LICENSES
WHERE VALIDATION_STATUS = 'PASSED'
  AND LICENSE_TYPE IS NOT NULL
  AND TRIM(LICENSE_TYPE) != ''
GROUP BY LICENSE_TYPE, SOURCE_SYSTEM;
```

### 5. GO_DIM_MEETING - Meeting Dimension Transformation

**Rationale**: Transform meeting data into a meeting dimension focusing on meeting characteristics and categorization, ensuring unique records per meeting type combination.

**Uniqueness Strategy**: Unique records based on meeting characteristic combinations rather than individual meeting instances.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_DIM_MEETING (
    MEETING_KEY,
    MEETING_ID,
    MEETING_TYPE,
    MEETING_CATEGORY,
    DURATION_CATEGORY,
    PARTICIPANT_SIZE_CATEGORY,
    TIME_OF_DAY_CATEGORY,
    DAY_OF_WEEK,
    IS_WEEKEND,
    IS_RECURRING,
    MEETING_QUALITY_SCORE,
    TYPICAL_FEATURES_USED,
    BUSINESS_PURPOSE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
WITH meeting_characteristics AS (
    SELECT DISTINCT
        'STANDARD' AS MEETING_TYPE,
        'BUSINESS' AS MEETING_CATEGORY,
        CASE 
            WHEN DURATION_MINUTES <= 15 THEN 'SHORT'
            WHEN DURATION_MINUTES <= 60 THEN 'MEDIUM'
            WHEN DURATION_MINUTES <= 180 THEN 'LONG'
            ELSE 'EXTENDED'
        END AS DURATION_CATEGORY,
        'SMALL' AS PARTICIPANT_SIZE_CATEGORY, -- To be enhanced with actual participant data
        CASE 
            WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'MORNING'
            WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'AFTERNOON'
            WHEN HOUR(START_TIME) BETWEEN 18 AND 22 THEN 'EVENING'
            ELSE 'NIGHT'
        END AS TIME_OF_DAY_CATEGORY,
        DAYNAME(START_TIME) AS DAY_OF_WEEK,
        CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
        FALSE AS IS_RECURRING, -- Default value
        8.5 AS MEETING_QUALITY_SCORE, -- Default value
        'SCREEN_SHARE,CHAT' AS TYPICAL_FEATURES_USED,
        'GENERAL_MEETING' AS BUSINESS_PURPOSE,
        SOURCE_SYSTEM
    FROM SILVER.SI_MEETINGS
    WHERE VALIDATION_STATUS = 'PASSED'
      AND DURATION_MINUTES > 0
      AND START_TIME IS NOT NULL
)
SELECT DISTINCT
    CONCAT('MTG_', 
           REPLACE(MEETING_TYPE, ' ', '_'), '_',
           REPLACE(MEETING_CATEGORY, ' ', '_'), '_',
           DURATION_CATEGORY, '_',
           PARTICIPANT_SIZE_CATEGORY, '_',
           TIME_OF_DAY_CATEGORY
    ) AS MEETING_KEY,
    NULL AS MEETING_ID, -- Auto-increment
    MEETING_TYPE,
    MEETING_CATEGORY,
    DURATION_CATEGORY,
    PARTICIPANT_SIZE_CATEGORY,
    TIME_OF_DAY_CATEGORY,
    DAY_OF_WEEK,
    IS_WEEKEND,
    IS_RECURRING,
    MEETING_QUALITY_SCORE,
    TYPICAL_FEATURES_USED,
    BUSINESS_PURPOSE,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    SOURCE_SYSTEM
FROM meeting_characteristics;
```

### 6. GO_DIM_SUPPORT_CATEGORY - Support Category Dimension Transformation

**Rationale**: Create a comprehensive support category dimension with unique records per support category, including SLA and resolution characteristics.

**Uniqueness Strategy**: One unique record per SUPPORT_CATEGORY and SUPPORT_SUBCATEGORY combination.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_DIM_SUPPORT_CATEGORY (
    SUPPORT_CATEGORY_KEY,
    SUPPORT_CATEGORY_ID,
    SUPPORT_CATEGORY,
    SUPPORT_SUBCATEGORY,
    PRIORITY_LEVEL,
    EXPECTED_RESOLUTION_TIME_HOURS,
    REQUIRES_ESCALATION,
    SELF_SERVICE_AVAILABLE,
    KNOWLEDGE_BASE_ARTICLES,
    COMMON_RESOLUTION_STEPS,
    CUSTOMER_IMPACT_LEVEL,
    DEPARTMENT_RESPONSIBLE,
    SLA_TARGET_HOURS,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT DISTINCT
    CONCAT('SUP_', UPPER(REPLACE(TICKET_TYPE, ' ', '_'))) AS SUPPORT_CATEGORY_KEY,
    NULL AS SUPPORT_CATEGORY_ID, -- Auto-increment
    UPPER(TRIM(TICKET_TYPE)) AS SUPPORT_CATEGORY,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'TECHNICAL_ISSUE'
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'BILLING_INQUIRY'
        WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'FEATURE_REQUEST'
        WHEN UPPER(TICKET_TYPE) LIKE '%ACCOUNT%' THEN 'ACCOUNT_MANAGEMENT'
        ELSE 'GENERAL_INQUIRY'
    END AS SUPPORT_SUBCATEGORY,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'HIGH'
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'MEDIUM'
        ELSE 'LOW'
    END AS PRIORITY_LEVEL,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 24.0
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
        ELSE 72.0
    END AS EXPECTED_RESOLUTION_TIME_HOURS,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN TRUE
        ELSE FALSE
    END AS REQUIRES_ESCALATION,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%ACCOUNT%' THEN TRUE
        ELSE FALSE
    END AS SELF_SERVICE_AVAILABLE,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 25
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 15
        WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 10
        ELSE 5
    END AS KNOWLEDGE_BASE_ARTICLES,
    CONCAT('Standard resolution steps for ', TICKET_TYPE) AS COMMON_RESOLUTION_STEPS,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'HIGH'
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'MEDIUM'
        ELSE 'LOW'
    END AS CUSTOMER_IMPACT_LEVEL,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'TECHNICAL_SUPPORT'
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'BILLING_DEPARTMENT'
        WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'PRODUCT_MANAGEMENT'
        ELSE 'CUSTOMER_SUCCESS'
    END AS DEPARTMENT_RESPONSIBLE,
    CASE 
        WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0
        WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 24.0
        WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0
        ELSE 72.0
    END AS SLA_TARGET_HOURS,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    SOURCE_SYSTEM
FROM (
    SELECT DISTINCT 
        TICKET_TYPE,
        SOURCE_SYSTEM
    FROM SILVER.SI_SUPPORT_TICKETS
    WHERE VALIDATION_STATUS = 'PASSED'
      AND TICKET_TYPE IS NOT NULL
      AND TRIM(TICKET_TYPE) != ''
);
```

## Data Quality and Uniqueness Validation Rules

### 1. Duplicate Detection and Prevention

**Rule**: Implement QUALIFY clauses with ROW_NUMBER() window functions to ensure only the most recent or relevant record is selected for each unique combination of dimension attributes.

**SQL Pattern**:
```sql
QUALIFY ROW_NUMBER() OVER (PARTITION BY [unique_key_columns] ORDER BY [priority_columns] DESC) = 1
```

### 2. Data Standardization Rules

1. **String Standardization**: Apply UPPER() and TRIM() functions to ensure consistent casing and remove leading/trailing spaces
2. **Date Standardization**: Convert all timestamps to consistent date formats using DATE() function
3. **Categorical Standardization**: Use CASE statements to map variations to standard category values
4. **Null Handling**: Replace NULL values with appropriate defaults or 'UNKNOWN' placeholders

### 3. Referential Integrity Validation

**Rule**: Validate that all foreign key references exist in their respective dimension tables before inserting fact records.

**SQL Example**:
```sql
-- Validate user references before fact table insert
WHERE EXISTS (
    SELECT 1 FROM GOLD.GO_DIM_USER u 
    WHERE u.USER_KEY = source.USER_KEY 
    AND u.IS_CURRENT_RECORD = TRUE
)
```

### 4. Slowly Changing Dimension (SCD) Implementation

**Type 1 SCD**: For attributes that should be updated in place (e.g., user status, contact information)
**Type 2 SCD**: For attributes that require historical tracking (e.g., plan changes, company changes)

**SQL Pattern for SCD Type 2**:
```sql
-- Close existing record
UPDATE GOLD.GO_DIM_USER 
SET EFFECTIVE_END_DATE = CURRENT_DATE() - 1,
    IS_CURRENT_RECORD = FALSE
WHERE USER_ID = :user_id 
  AND IS_CURRENT_RECORD = TRUE;

-- Insert new record
INSERT INTO GOLD.GO_DIM_USER (...)
VALUES (..., CURRENT_DATE(), '9999-12-31', TRUE, ...);
```

## Performance Optimization Recommendations

### 1. Clustering Keys

**Recommendation**: Implement clustering on frequently queried columns to improve query performance.

**SQL Examples**:
```sql
ALTER TABLE GOLD.GO_DIM_USER CLUSTER BY (USER_KEY, IS_CURRENT_RECORD);
ALTER TABLE GOLD.GO_DIM_DATE CLUSTER BY (DATE_KEY);
ALTER TABLE GOLD.GO_DIM_FEATURE CLUSTER BY (FEATURE_KEY, FEATURE_CATEGORY);
```

### 2. Incremental Loading Strategy

**Recommendation**: Implement incremental loading using MERGE statements to handle both inserts and updates efficiently.

**SQL Pattern**:
```sql
MERGE INTO GOLD.GO_DIM_USER AS target
USING (
    -- Source query with transformation logic
) AS source
ON target.USER_ID = source.USER_ID 
   AND target.IS_CURRENT_RECORD = TRUE
WHEN MATCHED AND (target.PLAN_TYPE != source.PLAN_TYPE OR target.COMPANY != source.COMPANY) THEN
    UPDATE SET 
        EFFECTIVE_END_DATE = CURRENT_DATE() - 1,
        IS_CURRENT_RECORD = FALSE
WHEN NOT MATCHED THEN
    INSERT (...) VALUES (...);
```

## Monitoring and Validation

### 1. Data Quality Checks

**Daily Validation Queries**:
```sql
-- Check for duplicate records in dimension tables
SELECT 
    'GO_DIM_USER' AS table_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT USER_KEY) AS unique_keys,
    COUNT(*) - COUNT(DISTINCT USER_KEY) AS duplicate_count
FROM GOLD.GO_DIM_USER
WHERE IS_CURRENT_RECORD = TRUE;

-- Validate referential integrity
SELECT COUNT(*) AS orphaned_records
FROM GOLD.GO_FACT_MEETING_ACTIVITY f
LEFT JOIN GOLD.GO_DIM_USER u ON f.USER_KEY = u.USER_KEY AND u.IS_CURRENT_RECORD = TRUE
WHERE u.USER_KEY IS NULL;
```

### 2. Automated Alerts

**Set up alerts for**:
1. Duplicate key violations
2. Referential integrity failures
3. Unexpected data volume changes
4. Data quality score degradation

## Conclusion

These transformation rules ensure that each Gold layer dimension table maintains unique row values for every unique combination of defining attributes while supporting comprehensive analytics and reporting requirements. The implementation focuses on data quality, performance optimization, and maintainability to support the Zoom Platform Analytics System's analytical needs.
