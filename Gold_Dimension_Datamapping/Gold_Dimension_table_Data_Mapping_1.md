_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Dimension Table Data Mapping for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Gold Layer Dimension Table Data Mapping

## 1. Overview

This document provides comprehensive data mapping specifications for Dimension tables transitioning from Silver to Gold layer in the Zoom Platform Analytics System. The mapping incorporates Snowflake-specific optimizations, business transformation rules, and data quality enhancements to support efficient analytics and reporting.

### 1.1 Key Architectural Considerations

1. **Performance Optimization Strategies**
   - Clustering keys implemented for optimal query performance
   - Surrogate key generation using Snowflake sequences
   - Micro-partition optimization through strategic data organization

2. **Scalability Design Patterns**
   - SCD Type 2 implementation for historical tracking
   - Incremental loading patterns using MERGE operations
   - Change Data Capture (CDC) integration for real-time updates

3. **Data Consistency Mechanisms**
   - Referential integrity validation across dimension tables
   - Standardized data transformation rules
   - Comprehensive data quality checks and error handling

### 1.2 Snowflake-Specific Implementation Notes

1. **Clustering Key Recommendations**
   - User Dimension: Clustered by `user_name` and `effective_start_date`
   - Time Dimension: Clustered by `date_key`
   - Feature Dimension: Clustered by `feature_name` and `feature_category`
   - License Dimension: Clustered by `license_type` and `effective_start_date`

2. **Partition Pruning Strategies**
   - Leverage Snowflake's automatic clustering for optimal data organization
   - Date-based partitioning for time-series analysis
   - Category-based organization for feature and license dimensions

3. **Micro-partition Optimization**
   - Strategic column ordering for compression efficiency
   - Balanced clustering depth to minimize maintenance overhead
   - Query pattern-based optimization for common access patterns

4. **Query Performance Considerations**
   - Search optimization enabled for frequently queried columns
   - Efficient join strategies using surrogate keys
   - Materialized view recommendations for complex aggregations

## 2. Data Mapping Tables

### 2.1 Dimension Table: Go_USER_DIMENSION

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_USER_DIMENSION | user_dimension_id | Silver | Si_USERS | user_id | Generate surrogate key using `ROW_NUMBER() OVER (ORDER BY user_id)` |
| Gold | Go_USER_DIMENSION | user_name | Silver | Si_USERS | user_name | `UPPER(TRIM(user_name))` - Standardize to uppercase and remove whitespace |
| Gold | Go_USER_DIMENSION | email_address | Silver | Si_USERS | email | `LOWER(TRIM(email))` - Standardize to lowercase and remove whitespace |
| Gold | Go_USER_DIMENSION | email_domain | Silver | Si_USERS | email_domain, email | `CASE WHEN email_domain IS NULL OR email_domain = '' THEN SUBSTRING(email, POSITION('@' IN email) + 1) ELSE LOWER(TRIM(email_domain)) END` |
| Gold | Go_USER_DIMENSION | company | Silver | Si_USERS | company | `INITCAP(TRIM(company))` - Standardize to proper case |
| Gold | Go_USER_DIMENSION | plan_type | Silver | Si_USERS | plan_type | `CASE WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN plan_type ELSE 'Unknown' END` |
| Gold | Go_USER_DIMENSION | registration_date | Silver | Si_USERS | registration_date | `CAST(registration_date AS DATE)` - Direct mapping with type casting |
| Gold | Go_USER_DIMENSION | account_age_days | Silver | Si_USERS | account_age_days | `CAST(account_age_days AS NUMBER(38,0))` - Direct mapping with type casting |
| Gold | Go_USER_DIMENSION | user_segment | Silver | Si_USERS | user_segment | `user_segment` - Direct mapping |
| Gold | Go_USER_DIMENSION | geographic_region | Silver | Si_USERS | geographic_region | `geographic_region` - Direct mapping |
| Gold | Go_USER_DIMENSION | user_status | Silver | Si_USERS | account_age_days | `CASE WHEN account_age_days >= 365 THEN 'Established' WHEN account_age_days >= 90 THEN 'Active' WHEN account_age_days >= 30 THEN 'New' ELSE 'Trial' END` |
| Gold | Go_USER_DIMENSION | effective_start_date | Silver | Si_USERS | load_date | `COALESCE(load_date, CURRENT_DATE())` - SCD Type 2 start date |
| Gold | Go_USER_DIMENSION | effective_end_date | Silver | Si_USERS | N/A | `'9999-12-31'::DATE` - SCD Type 2 end date for current records |
| Gold | Go_USER_DIMENSION | current_flag | Silver | Si_USERS | N/A | `TRUE` - SCD Type 2 current flag for active records |
| Gold | Go_USER_DIMENSION | user_id | Silver | Si_USERS | user_id | `user_id` - Business key preservation |
| Gold | Go_USER_DIMENSION | email | Silver | Si_USERS | email | `email` - Original email preservation |
| Gold | Go_USER_DIMENSION | load_date | Silver | Si_USERS | load_date | `load_date` - Audit trail |
| Gold | Go_USER_DIMENSION | update_date | Silver | Si_USERS | update_date | `CURRENT_DATE()` - Current transformation date |
| Gold | Go_USER_DIMENSION | source_system | Silver | Si_USERS | source_system | `COALESCE(source_system, 'DB_POC_ZOOM.SILVER.Si_USERS')` - Source system tracking |

### 2.2 Dimension Table: Go_TIME_DIMENSION

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_TIME_DIMENSION | time_dimension_id | Silver | Generated | N/A | `ROW_NUMBER() OVER (ORDER BY date_key)` - Surrogate key generation |
| Gold | Go_TIME_DIMENSION | date_key | Silver | Generated | N/A | `DATEADD(day, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE)` - Date range generation |
| Gold | Go_TIME_DIMENSION | year | Silver | Generated | date_key | `YEAR(date_key)` - Extract year component |
| Gold | Go_TIME_DIMENSION | quarter | Silver | Generated | date_key | `QUARTER(date_key)` - Extract quarter component |
| Gold | Go_TIME_DIMENSION | month | Silver | Generated | date_key | `MONTH(date_key)` - Extract month component |
| Gold | Go_TIME_DIMENSION | month_name | Silver | Generated | date_key | `MONTHNAME(date_key)` - Extract month name |
| Gold | Go_TIME_DIMENSION | week_of_year | Silver | Generated | date_key | `WEEKOFYEAR(date_key)` - Extract week of year |
| Gold | Go_TIME_DIMENSION | day_of_month | Silver | Generated | date_key | `DAY(date_key)` - Extract day of month |
| Gold | Go_TIME_DIMENSION | day_of_week | Silver | Generated | date_key | `DAYOFWEEK(date_key)` - Extract day of week |
| Gold | Go_TIME_DIMENSION | day_name | Silver | Generated | date_key | `DAYNAME(date_key)` - Extract day name |
| Gold | Go_TIME_DIMENSION | is_weekend | Silver | Generated | date_key | `CASE WHEN DAYOFWEEK(date_key) IN (1, 7) THEN TRUE ELSE FALSE END` - Weekend flag |
| Gold | Go_TIME_DIMENSION | is_business_day | Silver | Generated | date_key | `CASE WHEN DAYOFWEEK(date_key) BETWEEN 2 AND 6 THEN TRUE ELSE FALSE END` - Business day flag |
| Gold | Go_TIME_DIMENSION | fiscal_year | Silver | Generated | date_key | `CASE WHEN MONTH(date_key) >= 4 THEN YEAR(date_key) ELSE YEAR(date_key) - 1 END` - Fiscal year calculation |
| Gold | Go_TIME_DIMENSION | fiscal_quarter | Silver | Generated | date_key | `CASE WHEN MONTH(date_key) BETWEEN 4 AND 6 THEN 1 WHEN MONTH(date_key) BETWEEN 7 AND 9 THEN 2 WHEN MONTH(date_key) BETWEEN 10 AND 12 THEN 3 ELSE 4 END` - Fiscal quarter calculation |
| Gold | Go_TIME_DIMENSION | load_date | Silver | Generated | N/A | `CURRENT_DATE()` - Load date tracking |
| Gold | Go_TIME_DIMENSION | source_system | Silver | Generated | N/A | `'TIME_DIMENSION_GENERATOR'` - Source system identification |

### 2.3 Dimension Table: Go_FEATURE_DIMENSION

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_FEATURE_DIMENSION | feature_dimension_id | Silver | Si_FEATURE_USAGE | feature_name | `ROW_NUMBER() OVER (ORDER BY feature_name)` - Surrogate key generation |
| Gold | Go_FEATURE_DIMENSION | feature_name | Silver | Si_FEATURE_USAGE | feature_name | `UPPER(TRIM(feature_name))` - Standardize feature name |
| Gold | Go_FEATURE_DIMENSION | feature_category | Silver | Si_FEATURE_USAGE | feature_category | `CASE WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Collaboration' WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording' WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Communication' WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Meeting Management' WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Collaboration' ELSE 'Other' END` |
| Gold | Go_FEATURE_DIMENSION | feature_description | Silver | Si_FEATURE_USAGE | feature_category | `CASE WHEN feature_category = 'Collaboration' THEN 'Interactive feature for participant engagement' WHEN feature_category = 'Recording' THEN 'Content capture and storage feature' WHEN feature_category = 'Communication' THEN 'Real-time communication feature' WHEN feature_category = 'Meeting Management' THEN 'Meeting organization and control feature' ELSE 'Platform utility feature' END` |
| Gold | Go_FEATURE_DIMENSION | feature_type | Silver | Si_FEATURE_USAGE | N/A | `'Standard'` - Default feature type |
| Gold | Go_FEATURE_DIMENSION | availability_plan | Silver | Si_FEATURE_USAGE | feature_name | `CASE WHEN feature_name IN ('Screen Share', 'Chat') THEN 'All Plans' WHEN feature_name IN ('Recording', 'Breakout Rooms') THEN 'Basic+' WHEN feature_name IN ('Webinar', 'Advanced Analytics') THEN 'Pro+' WHEN feature_name IN ('Enterprise SSO', 'Advanced Security') THEN 'Enterprise Only' ELSE 'All Plans' END` |
| Gold | Go_FEATURE_DIMENSION | feature_status | Silver | Si_FEATURE_USAGE | N/A | `'Active'` - Default feature status |
| Gold | Go_FEATURE_DIMENSION | launch_date | Silver | Si_FEATURE_USAGE | N/A | `'2020-01-01'::DATE` - Default launch date |
| Gold | Go_FEATURE_DIMENSION | usage_pattern | Silver | Si_FEATURE_USAGE | usage_pattern | `usage_pattern` - Direct mapping |
| Gold | Go_FEATURE_DIMENSION | load_date | Silver | Si_FEATURE_USAGE | load_date | `load_date` - Audit trail |
| Gold | Go_FEATURE_DIMENSION | update_date | Silver | Si_FEATURE_USAGE | update_date | `CURRENT_DATE()` - Current transformation date |
| Gold | Go_FEATURE_DIMENSION | source_system | Silver | Si_FEATURE_USAGE | source_system | `COALESCE(source_system, 'DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE')` - Source system tracking |

### 2.4 Dimension Table: Go_LICENSE_DIMENSION

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_LICENSE_DIMENSION | license_dimension_id | Silver | Si_LICENSES | license_type | `ROW_NUMBER() OVER (ORDER BY license_type)` - Surrogate key generation |
| Gold | Go_LICENSE_DIMENSION | license_type | Silver | Si_LICENSES | license_type | `UPPER(TRIM(license_type))` - Standardize license type |
| Gold | Go_LICENSE_DIMENSION | license_description | Silver | Si_LICENSES | license_type | `CASE WHEN UPPER(license_type) = 'BASIC' THEN 'Basic subscription with standard features' WHEN UPPER(license_type) = 'PRO' THEN 'Professional subscription with advanced features' WHEN UPPER(license_type) = 'ENTERPRISE' THEN 'Enterprise subscription with full feature set' WHEN UPPER(license_type) LIKE '%ADD-ON%' THEN 'Additional feature enhancement' ELSE 'Standard license type' END` |
| Gold | Go_LICENSE_DIMENSION | license_category | Silver | Si_LICENSES | license_type | `CASE WHEN UPPER(license_type) IN ('BASIC', 'PRO', 'ENTERPRISE') THEN 'Core' WHEN UPPER(license_type) LIKE '%ADD-ON%' THEN 'Add-on' ELSE 'Other' END` |
| Gold | Go_LICENSE_DIMENSION | price_tier | Silver | Si_LICENSES | license_type | `CASE WHEN UPPER(license_type) = 'BASIC' THEN 'Tier 1' WHEN UPPER(license_type) = 'PRO' THEN 'Tier 2' WHEN UPPER(license_type) = 'ENTERPRISE' THEN 'Tier 3' ELSE 'Tier 0' END` |
| Gold | Go_LICENSE_DIMENSION | max_participants | Silver | Si_LICENSES | license_type | `CASE WHEN UPPER(license_type) = 'BASIC' THEN 100 WHEN UPPER(license_type) = 'PRO' THEN 500 WHEN UPPER(license_type) = 'ENTERPRISE' THEN 1000 ELSE 50 END` |
| Gold | Go_LICENSE_DIMENSION | meeting_duration_limit | Silver | Si_LICENSES | license_type | `CASE WHEN UPPER(license_type) = 'BASIC' THEN 40 WHEN UPPER(license_type) IN ('PRO', 'ENTERPRISE') THEN 1440 ELSE 30 END` |
| Gold | Go_LICENSE_DIMENSION | storage_limit_gb | Silver | Si_LICENSES | N/A | `CASE WHEN UPPER(license_type) = 'BASIC' THEN 1 WHEN UPPER(license_type) = 'PRO' THEN 5 WHEN UPPER(license_type) = 'ENTERPRISE' THEN 100 ELSE 0 END` - Default storage limits |
| Gold | Go_LICENSE_DIMENSION | support_level | Silver | Si_LICENSES | license_type | `CASE WHEN UPPER(license_type) = 'ENTERPRISE' THEN 'Premium' WHEN UPPER(license_type) = 'PRO' THEN 'Standard' ELSE 'Basic' END` |
| Gold | Go_LICENSE_DIMENSION | effective_start_date | Silver | Si_LICENSES | start_date | `COALESCE(start_date, CURRENT_DATE())` - SCD Type 2 start date |
| Gold | Go_LICENSE_DIMENSION | effective_end_date | Silver | Si_LICENSES | end_date | `COALESCE(end_date, '9999-12-31'::DATE)` - SCD Type 2 end date |
| Gold | Go_LICENSE_DIMENSION | current_flag | Silver | Si_LICENSES | license_status | `CASE WHEN license_status = 'Active' THEN TRUE ELSE FALSE END` - SCD Type 2 current flag |
| Gold | Go_LICENSE_DIMENSION | license_id | Silver | Si_LICENSES | license_id | `license_id` - Business key preservation |
| Gold | Go_LICENSE_DIMENSION | assigned_to_user_id | Silver | Si_LICENSES | assigned_to_user_id | `assigned_to_user_id` - User assignment tracking |
| Gold | Go_LICENSE_DIMENSION | start_date | Silver | Si_LICENSES | start_date | `start_date` - Original start date |
| Gold | Go_LICENSE_DIMENSION | end_date | Silver | Si_LICENSES | end_date | `end_date` - Original end date |
| Gold | Go_LICENSE_DIMENSION | license_status | Silver | Si_LICENSES | license_status | `license_status` - License status tracking |
| Gold | Go_LICENSE_DIMENSION | license_duration_days | Silver | Si_LICENSES | license_duration_days | `license_duration_days` - Duration calculation |
| Gold | Go_LICENSE_DIMENSION | renewal_flag | Silver | Si_LICENSES | renewal_flag | `renewal_flag` - Renewal indicator |
| Gold | Go_LICENSE_DIMENSION | load_date | Silver | Si_LICENSES | load_date | `load_date` - Audit trail |
| Gold | Go_LICENSE_DIMENSION | update_date | Silver | Si_LICENSES | update_date | `CURRENT_DATE()` - Current transformation date |
| Gold | Go_LICENSE_DIMENSION | source_system | Silver | Si_LICENSES | source_system | `COALESCE(source_system, 'DB_POC_ZOOM.SILVER.Si_LICENSES')` - Source system tracking |

## 3. Transformation Implementation Examples

### 3.1 SCD Type 2 Implementation for User Dimension

```sql
-- SCD Type 2 MERGE operation for Go_USER_DIMENSION
MERGE INTO DB_POC_ZOOM.GOLD.Go_USER_DIMENSION AS target
USING (
    SELECT 
        user_id,
        UPPER(TRIM(user_name)) AS user_name,
        LOWER(TRIM(email)) AS email_address,
        CASE 
            WHEN email_domain IS NULL OR email_domain = '' 
            THEN SUBSTRING(email, POSITION('@' IN email) + 1)
            ELSE LOWER(TRIM(email_domain))
        END AS email_domain,
        INITCAP(TRIM(company)) AS company,
        CASE 
            WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') 
            THEN plan_type
            ELSE 'Unknown'
        END AS plan_type,
        CASE 
            WHEN account_age_days >= 365 THEN 'Established'
            WHEN account_age_days >= 90 THEN 'Active'
            WHEN account_age_days >= 30 THEN 'New'
            ELSE 'Trial'
        END AS user_status,
        registration_date,
        account_age_days,
        user_segment,
        geographic_region,
        load_date,
        source_system
    FROM DB_POC_ZOOM.SILVER.Si_USERS
    WHERE update_date >= CURRENT_DATE() - 1
) AS source
ON target.user_id = source.user_id AND target.current_flag = TRUE
WHEN MATCHED AND (
    target.email_address != source.email_address OR 
    target.plan_type != source.plan_type OR
    target.company != source.company OR
    target.user_status != source.user_status
) THEN 
    UPDATE SET 
        effective_end_date = CURRENT_DATE() - 1,
        current_flag = FALSE,
        update_date = CURRENT_DATE()
WHEN NOT MATCHED THEN 
    INSERT (
        user_name, email_address, email_domain, company, plan_type,
        registration_date, account_age_days, user_segment, geographic_region,
        user_status, effective_start_date, effective_end_date, current_flag,
        user_id, email, load_date, update_date, source_system
    )
    VALUES (
        source.user_name, source.email_address, source.email_domain, 
        source.company, source.plan_type, source.registration_date,
        source.account_age_days, source.user_segment, source.geographic_region,
        source.user_status, CURRENT_DATE(), '9999-12-31'::DATE, TRUE,
        source.user_id, source.email_address, source.load_date, 
        CURRENT_DATE(), source.source_system
    );
```

### 3.2 Time Dimension Population

```sql
-- Time Dimension population with comprehensive date attributes
INSERT INTO DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION (
    date_key, year, quarter, month, month_name, week_of_year,
    day_of_month, day_of_week, day_name, is_weekend, is_business_day,
    fiscal_year, fiscal_quarter, load_date, source_system
)
WITH date_range AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) AS date_key
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years
)
SELECT 
    date_key,
    YEAR(date_key) AS year,
    QUARTER(date_key) AS quarter,
    MONTH(date_key) AS month,
    MONTHNAME(date_key) AS month_name,
    WEEKOFYEAR(date_key) AS week_of_year,
    DAY(date_key) AS day_of_month,
    DAYOFWEEK(date_key) AS day_of_week,
    DAYNAME(date_key) AS day_name,
    CASE WHEN DAYOFWEEK(date_key) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
    CASE WHEN DAYOFWEEK(date_key) BETWEEN 2 AND 6 THEN TRUE ELSE FALSE END AS is_business_day,
    CASE 
        WHEN MONTH(date_key) >= 4 THEN YEAR(date_key)
        ELSE YEAR(date_key) - 1
    END AS fiscal_year,
    CASE 
        WHEN MONTH(date_key) BETWEEN 4 AND 6 THEN 1
        WHEN MONTH(date_key) BETWEEN 7 AND 9 THEN 2
        WHEN MONTH(date_key) BETWEEN 10 AND 12 THEN 3
        ELSE 4
    END AS fiscal_quarter,
    CURRENT_DATE() AS load_date,
    'TIME_DIMENSION_GENERATOR' AS source_system
FROM date_range
WHERE date_key NOT IN (SELECT date_key FROM DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION);
```

### 3.3 Feature Dimension with Categorization

```sql
-- Feature Dimension population with intelligent categorization
INSERT INTO DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION (
    feature_name, feature_category, feature_description, feature_type,
    availability_plan, feature_status, launch_date, usage_pattern,
    load_date, update_date, source_system
)
SELECT DISTINCT
    UPPER(TRIM(feature_name)) AS feature_name,
    CASE 
        WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
        WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
        WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Communication'
        WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Meeting Management'
        WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Collaboration'
        ELSE 'Other'
    END AS feature_category,
    CASE 
        WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%WHITEBOARD%' 
            THEN 'Interactive feature for participant engagement'
        WHEN UPPER(feature_name) LIKE '%RECORD%' 
            THEN 'Content capture and storage feature'
        WHEN UPPER(feature_name) LIKE '%CHAT%' 
            THEN 'Real-time communication feature'
        WHEN UPPER(feature_name) LIKE '%BREAKOUT%' 
            THEN 'Meeting organization and control feature'
        ELSE 'Platform utility feature'
    END AS feature_description,
    'Standard' AS feature_type,
    CASE 
        WHEN UPPER(feature_name) IN ('SCREEN SHARE', 'CHAT') THEN 'All Plans'
        WHEN UPPER(feature_name) IN ('RECORDING', 'BREAKOUT ROOMS') THEN 'Basic+'
        WHEN UPPER(feature_name) IN ('WEBINAR', 'ADVANCED ANALYTICS') THEN 'Pro+'
        WHEN UPPER(feature_name) IN ('ENTERPRISE SSO', 'ADVANCED SECURITY') THEN 'Enterprise Only'
        ELSE 'All Plans'
    END AS availability_plan,
    'Active' AS feature_status,
    '2020-01-01'::DATE AS launch_date,
    usage_pattern,
    load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(source_system, 'DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE') AS source_system
FROM DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE
WHERE feature_name IS NOT NULL 
    AND TRIM(feature_name) != ''
    AND UPPER(TRIM(feature_name)) NOT IN (
        SELECT UPPER(TRIM(feature_name)) 
        FROM DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION
    );
```

### 3.4 License Dimension with Business Rules

```sql
-- License Dimension population with comprehensive business rules
INSERT INTO DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION (
    license_type, license_description, license_category, price_tier,
    max_participants, meeting_duration_limit, storage_limit_gb, support_level,
    effective_start_date, effective_end_date, current_flag,
    license_id, assigned_to_user_id, start_date, end_date,
    license_status, license_duration_days, renewal_flag,
    load_date, update_date, source_system
)
SELECT DISTINCT
    UPPER(TRIM(license_type)) AS license_type,
    CASE 
        WHEN UPPER(license_type) = 'BASIC' THEN 'Basic subscription with standard features'
        WHEN UPPER(license_type) = 'PRO' THEN 'Professional subscription with advanced features'
        WHEN UPPER(license_type) = 'ENTERPRISE' THEN 'Enterprise subscription with full feature set'
        WHEN UPPER(license_type) LIKE '%ADD-ON%' THEN 'Additional feature enhancement'
        ELSE 'Standard license type'
    END AS license_description,
    CASE 
        WHEN UPPER(license_type) IN ('BASIC', 'PRO', 'ENTERPRISE') THEN 'Core'
        WHEN UPPER(license_type) LIKE '%ADD-ON%' THEN 'Add-on'
        ELSE 'Other'
    END AS license_category,
    CASE 
        WHEN UPPER(license_type) = 'BASIC' THEN 'Tier 1'
        WHEN UPPER(license_type) = 'PRO' THEN 'Tier 2'
        WHEN UPPER(license_type) = 'ENTERPRISE' THEN 'Tier 3'
        ELSE 'Tier 0'
    END AS price_tier,
    CASE 
        WHEN UPPER(license_type) = 'BASIC' THEN 100
        WHEN UPPER(license_type) = 'PRO' THEN 500
        WHEN UPPER(license_type) = 'ENTERPRISE' THEN 1000
        ELSE 50
    END AS max_participants,
    CASE 
        WHEN UPPER(license_type) = 'BASIC' THEN 40
        WHEN UPPER(license_type) IN ('PRO', 'ENTERPRISE') THEN 1440
        ELSE 30
    END AS meeting_duration_limit,
    CASE 
        WHEN UPPER(license_type) = 'BASIC' THEN 1
        WHEN UPPER(license_type) = 'PRO' THEN 5
        WHEN UPPER(license_type) = 'ENTERPRISE' THEN 100
        ELSE 0
    END AS storage_limit_gb,
    CASE 
        WHEN UPPER(license_type) = 'ENTERPRISE' THEN 'Premium'
        WHEN UPPER(license_type) = 'PRO' THEN 'Standard'
        ELSE 'Basic'
    END AS support_level,
    COALESCE(start_date, CURRENT_DATE()) AS effective_start_date,
    COALESCE(end_date, '9999-12-31'::DATE) AS effective_end_date,
    CASE WHEN license_status = 'Active' THEN TRUE ELSE FALSE END AS current_flag,
    license_id,
    assigned_to_user_id,
    start_date,
    end_date,
    license_status,
    license_duration_days,
    renewal_flag,
    load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(source_system, 'DB_POC_ZOOM.SILVER.Si_LICENSES') AS source_system
FROM DB_POC_ZOOM.SILVER.Si_LICENSES
WHERE license_type IS NOT NULL 
    AND TRIM(license_type) != ''
    AND license_id NOT IN (
        SELECT license_id 
        FROM DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION 
        WHERE license_id IS NOT NULL
    );
```

## 4. Data Quality and Validation Rules

### 4.1 Referential Integrity Validation

```sql
-- Validate User Dimension data quality
SELECT 
    'User Dimension' AS dimension_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT user_name) AS unique_users,
    COUNT(CASE WHEN email_address IS NULL THEN 1 END) AS missing_emails,
    COUNT(CASE WHEN plan_type NOT IN ('Free', 'Basic', 'Pro', 'Enterprise', 'Unknown') THEN 1 END) AS invalid_plan_types,
    COUNT(CASE WHEN current_flag = TRUE THEN 1 END) AS current_records,
    COUNT(CASE WHEN effective_end_date = '9999-12-31' THEN 1 END) AS active_records
FROM DB_POC_ZOOM.GOLD.Go_USER_DIMENSION;

-- Validate Feature Dimension data quality
SELECT 
    'Feature Dimension' AS dimension_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT feature_name) AS unique_features,
    COUNT(CASE WHEN feature_category IS NULL THEN 1 END) AS missing_categories,
    COUNT(CASE WHEN feature_category NOT IN ('Collaboration', 'Recording', 'Communication', 'Meeting Management', 'Other') THEN 1 END) AS invalid_categories
FROM DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION;

-- Validate License Dimension data quality
SELECT 
    'License Dimension' AS dimension_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT license_type) AS unique_license_types,
    COUNT(CASE WHEN license_category IS NULL THEN 1 END) AS missing_categories,
    COUNT(CASE WHEN price_tier IS NULL THEN 1 END) AS missing_price_tiers,
    COUNT(CASE WHEN current_flag = TRUE THEN 1 END) AS current_records
FROM DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION;
```

### 4.2 Data Standardization Function

```sql
-- Standardization function for dimension tables
CREATE OR REPLACE FUNCTION standardize_text(input_text VARCHAR)
RETURNS VARCHAR
AS
$$
    CASE 
        WHEN input_text IS NULL THEN NULL
        WHEN TRIM(input_text) = '' THEN NULL
        ELSE TRIM(REGEXP_REPLACE(input_text, '[^a-zA-Z0-9\s\-_@.]', ''))
    END
$$;
```

## 5. Performance Optimization

### 5.1 Clustering Key Implementation

```sql
-- Clustering keys for optimal query performance
ALTER TABLE DB_POC_ZOOM.GOLD.Go_USER_DIMENSION 
CLUSTER BY (user_name, effective_start_date);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION 
CLUSTER BY (date_key);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION 
CLUSTER BY (feature_category, feature_name);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION 
CLUSTER BY (license_type, effective_start_date);
```

### 5.2 Search Optimization

```sql
-- Create search optimization for dimension tables
ALTER TABLE DB_POC_ZOOM.GOLD.Go_USER_DIMENSION 
ADD SEARCH OPTIMIZATION ON EQUALITY(user_name, email_address);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION 
ADD SEARCH OPTIMIZATION ON EQUALITY(feature_name, feature_category);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION 
ADD SEARCH OPTIMIZATION ON EQUALITY(license_type, license_category);
```

## 6. Change Data Capture Integration

### 6.1 CDC Pattern for Incremental Loading

```sql
-- Create streams for CDC
CREATE STREAM IF NOT EXISTS stream_si_users ON TABLE DB_POC_ZOOM.SILVER.Si_USERS;
CREATE STREAM IF NOT EXISTS stream_si_feature_usage ON TABLE DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE;
CREATE STREAM IF NOT EXISTS stream_si_licenses ON TABLE DB_POC_ZOOM.SILVER.Si_LICENSES;

-- CDC processing for User Dimension
MERGE INTO DB_POC_ZOOM.GOLD.Go_USER_DIMENSION AS target
USING (
    SELECT * FROM stream_si_users 
    WHERE METADATA$ACTION IN ('INSERT', 'UPDATE')
) AS source
ON target.user_id = source.user_id AND target.current_flag = TRUE
WHEN MATCHED AND METADATA$ACTION = 'UPDATE' THEN
    UPDATE SET 
        effective_end_date = CURRENT_DATE() - 1,
        current_flag = FALSE
WHEN NOT MATCHED THEN
    INSERT VALUES (/* transformed values */);
```

## 7. Data Lineage and Audit Trail

### 7.1 Source System Tracking

```sql
-- Add comprehensive lineage tracking
INSERT INTO DB_POC_ZOOM.GOLD.Go_PIPELINE_AUDIT (
    pipeline_name, execution_start_time, execution_end_time,
    source_table_name, target_table_name, records_processed,
    records_success, records_failed, execution_status, processed_by
)
VALUES (
    'DIMENSION_ETL_USER',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP(),
    'DB_POC_ZOOM.SILVER.Si_USERS',
    'DB_POC_ZOOM.GOLD.Go_USER_DIMENSION',
    @@ROWCOUNT,
    @@ROWCOUNT,
    0,
    'SUCCESS',
    'ETL_DIMENSION_LOAD'
);
```

## 8. Business Rule Implementation Summary

### 8.1 Plan Type Hierarchy

1. **Enterprise** (Tier 3): Full feature access, premium support
2. **Pro** (Tier 2): Advanced features, standard support  
3. **Basic** (Tier 1): Standard features, basic support
4. **Free** (Tier 0): Limited features, community support

### 8.2 Feature Availability Matrix

| Feature Category | All Plans | Basic+ | Pro+ | Enterprise Only |
|------------------|-----------|--------|------|----------------|
| Communication | Chat | | | |
| Collaboration | Screen Share | Recording, Breakout Rooms | | |
| Advanced | | | Webinar, Analytics | SSO, Security |

### 8.3 User Lifecycle Stages

1. **Trial** (0-29 days): New user evaluation period
2. **New** (30-89 days): Recently activated user
3. **Active** (90-364 days): Regular platform user
4. **Established** (365+ days): Long-term platform user

---

**End of Gold Layer Dimension Table Data Mapping Document**