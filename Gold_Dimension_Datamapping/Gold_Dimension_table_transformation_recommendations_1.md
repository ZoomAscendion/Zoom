_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold layer dimension table transformation recommendations for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Gold Layer Dimension Table Transformation Recommendations

## Transformation Rules for Dimension Tables

### 1. GO_DIM_USER Dimension Table Transformations

#### 1.1 Data Type Conversions

**Rationale:** Ensure data types align with analytical reporting needs and support SCD Type 2 implementation for historical tracking of user attribute changes.

**SQL Example:**
```sql
-- Transform Silver SI_USERS to Gold GO_DIM_USER with SCD Type 2
INSERT INTO GOLD.GO_DIM_USER (
    USER_KEY,
    USER_NAME,
    EMAIL_DOMAIN,
    COMPANY,
    PLAN_TYPE,
    USER_CATEGORY,
    ACCOUNT_CREATION_DATE,
    LAST_ACTIVITY_DATE,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    CURRENT_RECORD_FLAG,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    u.USER_ID::VARCHAR(16777216) as USER_KEY,
    TRIM(UPPER(u.USER_NAME))::VARCHAR(16777216) as USER_NAME,
    SPLIT_PART(LOWER(TRIM(u.EMAIL)), '@', 2)::VARCHAR(16777216) as EMAIL_DOMAIN,
    TRIM(u.COMPANY)::VARCHAR(16777216) as COMPANY,
    UPPER(u.PLAN_TYPE)::VARCHAR(16777216) as PLAN_TYPE,
    CASE 
        WHEN UPPER(u.PLAN_TYPE) IN ('ENTERPRISE', 'BUSINESS') THEN 'PREMIUM'
        WHEN UPPER(u.PLAN_TYPE) = 'PRO' THEN 'STANDARD'
        ELSE 'BASIC'
    END::VARCHAR(100) as USER_CATEGORY,
    u.LOAD_DATE::DATE as ACCOUNT_CREATION_DATE,
    u.UPDATE_DATE::DATE as LAST_ACTIVITY_DATE,
    CURRENT_DATE::DATE as EFFECTIVE_START_DATE,
    '9999-12-31'::DATE as EFFECTIVE_END_DATE,
    TRUE::BOOLEAN as CURRENT_RECORD_FLAG,
    CURRENT_DATE::DATE as LOAD_DATE,
    CURRENT_DATE::DATE as UPDATE_DATE,
    u.SOURCE_SYSTEM::VARCHAR(16777216)
FROM SILVER.SI_USERS u;
```

#### 1.2 Column Derivations

**Rationale:** Create computed attributes for enhanced analytical capabilities including email domain extraction for company analysis and user categorization for segmentation.

**SQL Example:**
```sql
-- Derived column transformations for GO_DIM_USER
SELECT 
    -- Extract email domain for company analysis
    SPLIT_PART(LOWER(TRIM(EMAIL)), '@', 2) as EMAIL_DOMAIN,
    
    -- Categorize users based on plan type
    CASE 
        WHEN UPPER(PLAN_TYPE) IN ('ENTERPRISE', 'BUSINESS') THEN 'PREMIUM'
        WHEN UPPER(PLAN_TYPE) = 'PRO' THEN 'STANDARD'
        WHEN UPPER(PLAN_TYPE) = 'BASIC' THEN 'STANDARD'
        WHEN UPPER(PLAN_TYPE) = 'FREE' THEN 'BASIC'
        ELSE 'UNKNOWN'
    END as USER_CATEGORY,
    
    -- Calculate account age for retention analysis
    DATEDIFF('day', ACCOUNT_CREATION_DATE, CURRENT_DATE) as ACCOUNT_AGE_DAYS
FROM SILVER.SI_USERS;
```

#### 1.3 Hierarchy Mapping

**Rationale:** Define user hierarchy relationships for organizational reporting and drill-down capabilities in analytics dashboards.

**SQL Example:**
```sql
-- User hierarchy mapping for organizational analysis
SELECT 
    USER_KEY,
    COMPANY,
    EMAIL_DOMAIN,
    PLAN_TYPE,
    USER_CATEGORY,
    -- Create hierarchy levels
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
FROM GOLD.GO_DIM_USER;
```

#### 1.4 Normalization & Standardization

**Rationale:** Ensure consistent formats for user names, email domains, and company names to support accurate reporting and analytics.

**SQL Example:**
```sql
-- Standardization rules for GO_DIM_USER
SELECT 
    -- Standardize user name format
    TRIM(UPPER(USER_NAME)) as USER_NAME,
    
    -- Standardize email domain to lowercase
    LOWER(TRIM(EMAIL_DOMAIN)) as EMAIL_DOMAIN,
    
    -- Standardize company name format
    TRIM(INITCAP(COMPANY)) as COMPANY,
    
    -- Standardize plan type to uppercase
    CASE 
        WHEN UPPER(PLAN_TYPE) IN ('BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'FREE') 
        THEN UPPER(PLAN_TYPE)
        ELSE 'UNKNOWN'
    END as PLAN_TYPE
FROM SILVER.SI_USERS;
```

### 2. GO_DIM_DATE Dimension Table Transformations

#### 2.1 Data Type Conversions

**Rationale:** Create comprehensive date dimension with all necessary date attributes for time-based analysis and reporting across different calendar and fiscal periods.

**SQL Example:**
```sql
-- Generate GO_DIM_DATE dimension table
INSERT INTO GOLD.GO_DIM_DATE (
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
    SOURCE_SYSTEM
)
WITH date_range AS (
    SELECT DATEADD('day', ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) as date_val
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years of dates
)
SELECT 
    date_val::DATE as DATE_KEY,
    YEAR(date_val)::NUMBER(4,0) as YEAR,
    QUARTER(date_val)::NUMBER(1,0) as QUARTER,
    MONTH(date_val)::NUMBER(2,0) as MONTH,
    MONTHNAME(date_val)::VARCHAR(20) as MONTH_NAME,
    WEEKOFYEAR(date_val)::NUMBER(2,0) as WEEK_OF_YEAR,
    DAY(date_val)::NUMBER(2,0) as DAY_OF_MONTH,
    DAYOFWEEK(date_val)::NUMBER(1,0) as DAY_OF_WEEK,
    DAYNAME(date_val)::VARCHAR(20) as DAY_NAME,
    CASE WHEN DAYOFWEEK(date_val) IN (1, 7) THEN TRUE ELSE FALSE END::BOOLEAN as IS_WEEKEND,
    FALSE::BOOLEAN as IS_HOLIDAY, -- To be updated with holiday logic
    CASE WHEN MONTH(date_val) >= 4 THEN YEAR(date_val) ELSE YEAR(date_val) - 1 END::NUMBER(4,0) as FISCAL_YEAR,
    CASE 
        WHEN MONTH(date_val) IN (4,5,6) THEN 1
        WHEN MONTH(date_val) IN (7,8,9) THEN 2
        WHEN MONTH(date_val) IN (10,11,12) THEN 3
        ELSE 4
    END::NUMBER(1,0) as FISCAL_QUARTER,
    CURRENT_DATE::DATE as LOAD_DATE,
    'SYSTEM_GENERATED'::VARCHAR(16777216) as SOURCE_SYSTEM
FROM date_range;
```

#### 2.2 Column Derivations

**Rationale:** Create additional date attributes for business intelligence reporting including fiscal periods, business day indicators, and holiday flags.

**SQL Example:**
```sql
-- Additional derived columns for GO_DIM_DATE
SELECT 
    DATE_KEY,
    -- Business day indicator
    CASE 
        WHEN DAY_OF_WEEK BETWEEN 2 AND 6 AND IS_HOLIDAY = FALSE THEN TRUE 
        ELSE FALSE 
    END as IS_BUSINESS_DAY,
    
    -- Quarter name
    'Q' || QUARTER || ' ' || YEAR as QUARTER_NAME,
    
    -- Month-Year combination
    MONTH_NAME || ' ' || YEAR as MONTH_YEAR,
    
    -- Days from today for relative date analysis
    DATEDIFF('day', DATE_KEY, CURRENT_DATE) as DAYS_FROM_TODAY,
    
    -- Week start date
    DATEADD('day', -(DAY_OF_WEEK - 2), DATE_KEY) as WEEK_START_DATE
FROM GOLD.GO_DIM_DATE;
```

### 3. GO_DIM_LICENSE Dimension Table Transformations

#### 3.1 Data Type Conversions

**Rationale:** Implement SCD Type 2 for license dimension to track historical changes in license attributes, costs, and utilization rates for comprehensive license management analytics.

**SQL Example:**
```sql
-- Transform Silver SI_LICENSES to Gold GO_DIM_LICENSE with SCD Type 2
INSERT INTO GOLD.GO_DIM_LICENSE (
    LICENSE_KEY,
    LICENSE_TYPE,
    LICENSE_TIER,
    START_DATE,
    END_DATE,
    LICENSE_STATUS,
    DAYS_TO_EXPIRY,
    LICENSE_COST,
    UTILIZATION_RATE,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    CURRENT_RECORD_FLAG,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    l.LICENSE_ID::VARCHAR(16777216) as LICENSE_KEY,
    UPPER(l.LICENSE_TYPE)::VARCHAR(16777216) as LICENSE_TYPE,
    CASE 
        WHEN UPPER(l.LICENSE_TYPE) = 'ENTERPRISE' THEN 'TIER_1'
        WHEN UPPER(l.LICENSE_TYPE) = 'BUSINESS' THEN 'TIER_2'
        WHEN UPPER(l.LICENSE_TYPE) = 'PRO' THEN 'TIER_3'
        WHEN UPPER(l.LICENSE_TYPE) = 'BASIC' THEN 'TIER_4'
        ELSE 'TIER_5'
    END::VARCHAR(100) as LICENSE_TIER,
    l.START_DATE::DATE,
    l.END_DATE::DATE,
    l.LICENSE_STATUS::VARCHAR(50),
    l.DAYS_TO_EXPIRY::NUMBER(38,0),
    CASE 
        WHEN UPPER(l.LICENSE_TYPE) = 'ENTERPRISE' THEN 240.00
        WHEN UPPER(l.LICENSE_TYPE) = 'BUSINESS' THEN 120.00
        WHEN UPPER(l.LICENSE_TYPE) = 'PRO' THEN 60.00
        WHEN UPPER(l.LICENSE_TYPE) = 'BASIC' THEN 20.00
        ELSE 0.00
    END::NUMBER(10,2) as LICENSE_COST,
    0.00::NUMBER(5,2) as UTILIZATION_RATE, -- To be calculated from usage data
    CURRENT_DATE::DATE as EFFECTIVE_START_DATE,
    '9999-12-31'::DATE as EFFECTIVE_END_DATE,
    TRUE::BOOLEAN as CURRENT_RECORD_FLAG,
    CURRENT_DATE::DATE as LOAD_DATE,
    CURRENT_DATE::DATE as UPDATE_DATE,
    l.SOURCE_SYSTEM::VARCHAR(16777216)
FROM SILVER.SI_LICENSES l;
```

#### 3.2 Column Derivations

**Rationale:** Create computed attributes for license analysis including tier classification, cost calculations, and utilization metrics for license optimization.

**SQL Example:**
```sql
-- Derived columns for GO_DIM_LICENSE
SELECT 
    LICENSE_KEY,
    LICENSE_TYPE,
    
    -- License tier classification
    CASE 
        WHEN UPPER(LICENSE_TYPE) = 'ENTERPRISE' THEN 'TIER_1'
        WHEN UPPER(LICENSE_TYPE) = 'BUSINESS' THEN 'TIER_2'
        WHEN UPPER(LICENSE_TYPE) = 'PRO' THEN 'TIER_3'
        WHEN UPPER(LICENSE_TYPE) = 'BASIC' THEN 'TIER_4'
        ELSE 'TIER_5'
    END as LICENSE_TIER,
    
    -- License duration in days
    DATEDIFF('day', START_DATE, END_DATE) as LICENSE_DURATION_DAYS,
    
    -- License age in days
    DATEDIFF('day', START_DATE, CURRENT_DATE) as LICENSE_AGE_DAYS,
    
    -- Expiry status classification
    CASE 
        WHEN DAYS_TO_EXPIRY < 0 THEN 'EXPIRED'
        WHEN DAYS_TO_EXPIRY <= 30 THEN 'EXPIRING_SOON'
        WHEN DAYS_TO_EXPIRY <= 90 THEN 'EXPIRING_WITHIN_QUARTER'
        ELSE 'ACTIVE'
    END as EXPIRY_STATUS_CATEGORY
FROM GOLD.GO_DIM_LICENSE;
```

#### 3.3 Hierarchy Mapping

**Rationale:** Define license hierarchy for organizational license management and cost allocation across different license tiers and types.

**SQL Example:**
```sql
-- License hierarchy mapping
SELECT 
    LICENSE_KEY,
    LICENSE_TYPE,
    LICENSE_TIER,
    
    -- Create license hierarchy levels
    CASE 
        WHEN LICENSE_TIER = 'TIER_1' THEN 'ENTERPRISE_LEVEL'
        WHEN LICENSE_TIER = 'TIER_2' THEN 'BUSINESS_LEVEL'
        WHEN LICENSE_TIER = 'TIER_3' THEN 'PROFESSIONAL_LEVEL'
        WHEN LICENSE_TIER = 'TIER_4' THEN 'BASIC_LEVEL'
        ELSE 'FREE_LEVEL'
    END as HIERARCHY_LEVEL,
    
    -- License cost category
    CASE 
        WHEN LICENSE_COST >= 200 THEN 'HIGH_COST'
        WHEN LICENSE_COST >= 100 THEN 'MEDIUM_COST'
        WHEN LICENSE_COST >= 50 THEN 'LOW_COST'
        ELSE 'NO_COST'
    END as COST_CATEGORY
FROM GOLD.GO_DIM_LICENSE;
```

#### 3.4 Normalization & Standardization

**Rationale:** Ensure consistent license type formats and status values for accurate reporting and license management analytics.

**SQL Example:**
```sql
-- Standardization rules for GO_DIM_LICENSE
SELECT 
    -- Standardize license type to uppercase
    CASE 
        WHEN UPPER(LICENSE_TYPE) IN ('BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'EDUCATION') 
        THEN UPPER(LICENSE_TYPE)
        ELSE 'UNKNOWN'
    END as LICENSE_TYPE,
    
    -- Standardize license status
    CASE 
        WHEN UPPER(LICENSE_STATUS) IN ('ACTIVE', 'EXPIRED', 'SUSPENDED', 'PENDING') 
        THEN UPPER(LICENSE_STATUS)
        ELSE 'UNKNOWN'
    END as LICENSE_STATUS,
    
    -- Ensure valid date ranges
    CASE 
        WHEN START_DATE > END_DATE THEN NULL
        ELSE START_DATE
    END as START_DATE,
    
    CASE 
        WHEN START_DATE > END_DATE THEN NULL
        ELSE END_DATE
    END as END_DATE
FROM SILVER.SI_LICENSES;
```

### 4. Code Tables Transformations

#### 4.1 GO_CODE_FEATURE_TYPES Transformation

**Rationale:** Standardize feature types and categories for consistent feature usage analysis and adoption tracking.

**SQL Example:**
```sql
-- Populate GO_CODE_FEATURE_TYPES from feature usage patterns
INSERT INTO GOLD.GO_CODE_FEATURE_TYPES (
    FEATURE_CODE,
    FEATURE_NAME,
    FEATURE_CATEGORY,
    FEATURE_DESCRIPTION,
    IS_PREMIUM_FEATURE,
    ADOPTION_PRIORITY,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT DISTINCT
    UPPER(REPLACE(FEATURE_NAME, ' ', '_')) as FEATURE_CODE,
    TRIM(FEATURE_NAME) as FEATURE_NAME,
    CASE 
        WHEN FEATURE_NAME ILIKE '%screen%share%' THEN 'COLLABORATION'
        WHEN FEATURE_NAME ILIKE '%record%' THEN 'RECORDING'
        WHEN FEATURE_NAME ILIKE '%chat%' THEN 'COMMUNICATION'
        WHEN FEATURE_NAME ILIKE '%breakout%' THEN 'ADVANCED'
        ELSE 'BASIC'
    END as FEATURE_CATEGORY,
    'Feature usage tracking for ' || FEATURE_NAME as FEATURE_DESCRIPTION,
    CASE 
        WHEN FEATURE_NAME ILIKE '%breakout%' OR FEATURE_NAME ILIKE '%record%' 
        THEN TRUE ELSE FALSE 
    END as IS_PREMIUM_FEATURE,
    'MEDIUM' as ADOPTION_PRIORITY,
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    'SILVER_LAYER' as SOURCE_SYSTEM
FROM SILVER.SI_FEATURE_USAGE
WHERE FEATURE_NAME IS NOT NULL;
```

#### 4.2 GO_CODE_PLAN_TYPES Transformation

**Rationale:** Create standardized plan type reference data with associated costs and feature sets for revenue and usage analysis.

**SQL Example:**
```sql
-- Populate GO_CODE_PLAN_TYPES with standardized plan information
INSERT INTO GOLD.GO_CODE_PLAN_TYPES (
    PLAN_CODE,
    PLAN_NAME,
    PLAN_TIER,
    PLAN_DESCRIPTION,
    MONTHLY_COST,
    MAX_PARTICIPANTS,
    FEATURE_SET,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
VALUES 
    ('ENT', 'Enterprise', 'PREMIUM', 'Full enterprise features with unlimited participants', 240.00, 1000, 'ALL_FEATURES'),
    ('BUS', 'Business', 'PREMIUM', 'Business features with advanced collaboration tools', 120.00, 300, 'BUSINESS_FEATURES'),
    ('PRO', 'Professional', 'STANDARD', 'Professional features for small teams', 60.00, 100, 'PRO_FEATURES'),
    ('BAS', 'Basic', 'STANDARD', 'Basic meeting features', 20.00, 40, 'BASIC_FEATURES'),
    ('FREE', 'Free', 'BASIC', 'Free tier with limited features', 0.00, 3, 'FREE_FEATURES');
```

### 5. SCD Type 2 Implementation Guidelines

#### 5.1 SCD Type 2 Processing for GO_DIM_USER

**Rationale:** Track historical changes in user attributes to support trend analysis and maintain data lineage for compliance and auditing purposes.

**SQL Example:**
```sql
-- SCD Type 2 processing for GO_DIM_USER
MERGE INTO GOLD.GO_DIM_USER tgt
USING (
    SELECT 
        USER_ID as USER_KEY,
        USER_NAME,
        SPLIT_PART(EMAIL, '@', 2) as EMAIL_DOMAIN,
        COMPANY,
        PLAN_TYPE,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('ENTERPRISE', 'BUSINESS') THEN 'PREMIUM'
            WHEN UPPER(PLAN_TYPE) = 'PRO' THEN 'STANDARD'
            ELSE 'BASIC'
        END as USER_CATEGORY
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
    EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, CURRENT_RECORD_FLAG,
    LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
) VALUES (
    src.USER_KEY, src.USER_NAME, src.EMAIL_DOMAIN, src.COMPANY, 
    src.PLAN_TYPE, src.USER_CATEGORY,
    CURRENT_DATE, '9999-12-31', TRUE,
    CURRENT_DATE, CURRENT_DATE, 'SILVER_LAYER'
);
```

### 6. Data Quality and Validation Rules

#### 6.1 Data Quality Checks for Dimension Tables

**Rationale:** Implement comprehensive data quality checks to ensure dimension table integrity and support reliable analytics and reporting.

**SQL Example:**
```sql
-- Data quality validation for GO_DIM_USER
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
    'GO_DIM_USER' as TABLE_NAME,
    'INVALID_PLAN_TYPE' as CHECK_TYPE,
    COUNT(*) as VIOLATION_COUNT
FROM GOLD.GO_DIM_USER 
WHERE PLAN_TYPE NOT IN ('BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'FREE', 'EDUCATION')

UNION ALL

SELECT 
    'GO_DIM_LICENSE' as TABLE_NAME,
    'INVALID_DATE_RANGE' as CHECK_TYPE,
    COUNT(*) as VIOLATION_COUNT
FROM GOLD.GO_DIM_LICENSE 
WHERE START_DATE > END_DATE;
```

### 7. Performance Optimization Recommendations

#### 7.1 Clustering and Indexing Strategy

**Rationale:** Optimize query performance for dimension tables through appropriate clustering keys and partitioning strategies.

**SQL Example:**
```sql
-- Clustering recommendations for dimension tables
ALTER TABLE GOLD.GO_DIM_USER CLUSTER BY (USER_KEY, EFFECTIVE_START_DATE);
ALTER TABLE GOLD.GO_DIM_LICENSE CLUSTER BY (LICENSE_KEY, EFFECTIVE_START_DATE);
ALTER TABLE GOLD.GO_DIM_DATE CLUSTER BY (DATE_KEY);

-- Create search optimization for frequently queried columns
ALTER TABLE GOLD.GO_DIM_USER ADD SEARCH OPTIMIZATION ON (EMAIL_DOMAIN, COMPANY, PLAN_TYPE);
ALTER TABLE GOLD.GO_DIM_LICENSE ADD SEARCH OPTIMIZATION ON (LICENSE_TYPE, LICENSE_STATUS);
```

### 8. Traceability and Lineage

#### 8.1 Data Lineage Documentation

**Rationale:** Maintain clear traceability from source Silver layer tables to Gold dimension tables for data governance and compliance.

**Mapping Documentation:**

1. **GO_DIM_USER Source Mapping:**
   - Source: SILVER.SI_USERS
   - Key Transformations: Email domain extraction, user categorization, SCD Type 2 implementation
   - Business Rules Applied: Plan type standardization, name formatting

2. **GO_DIM_DATE Source Mapping:**
   - Source: System Generated
   - Key Transformations: Complete date attribute generation, fiscal period calculations
   - Business Rules Applied: Weekend/holiday identification, business day calculations

3. **GO_DIM_LICENSE Source Mapping:**
   - Source: SILVER.SI_LICENSES
   - Key Transformations: License tier classification, cost assignment, SCD Type 2 implementation
   - Business Rules Applied: License status standardization, expiry calculations

4. **Code Tables Source Mapping:**
   - GO_CODE_FEATURE_TYPES: Derived from SILVER.SI_FEATURE_USAGE patterns
   - GO_CODE_PLAN_TYPES: Business-defined reference data

### 9. Error Handling and Monitoring

#### 9.1 Error Tracking Integration

**Rationale:** Integrate with Gold layer error tracking table to capture and monitor transformation issues for continuous improvement.

**SQL Example:**
```sql
-- Error logging for dimension transformations
INSERT INTO GOLD.GO_ERROR_DATA (
    ERROR_KEY,
    PIPELINE_RUN_TIMESTAMP,
    SOURCE_TABLE,
    SOURCE_RECORD_KEY,
    ERROR_TYPE,
    ERROR_COLUMN,
    ERROR_VALUE,
    ERROR_DESCRIPTION,
    VALIDATION_RULE,
    ERROR_SEVERITY,
    ERROR_TIMESTAMP,
    PROCESSING_BATCH_KEY,
    RESOLUTION_STATUS,
    LOAD_DATE,
    SOURCE_SYSTEM
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

This comprehensive transformation framework ensures that all Gold layer dimension tables are populated with high-quality, standardized data that supports robust analytics and reporting capabilities for the Zoom Platform Analytics System.