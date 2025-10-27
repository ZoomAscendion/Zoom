_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Dimension Table Data Mapping for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Gold Layer Dimension Table Data Mapping

## 1. Overview

This document provides comprehensive data mapping specifications for transforming Silver layer data into Gold layer dimension tables within the Zoom Platform Analytics System. The mapping covers four primary dimension tables that support business intelligence and analytics requirements across Platform Usage & Adoption, Service Reliability & Support, and Revenue & License Management domains.

### 1.1 Architectural Considerations

1. **Data Lineage**: Clear traceability from Silver to Gold layer with transformation logic documentation
2. **SCD Implementation**: Slowly Changing Dimension Type 2 for User and License dimensions to maintain historical context
3. **Business Rule Application**: Standardized categorization and classification logic for enhanced analytics
4. **Performance Optimization**: Clustering keys and indexing strategies for efficient query performance
5. **Data Quality**: Validation rules and error handling mechanisms for data integrity
6. **Snowflake Features**: Leveraging AUTOINCREMENT, UUID_STRING(), and MERGE INTO for optimal performance

### 1.2 Transformation Patterns

1. **Data Type Standardization**: Converting Silver layer STRING types to appropriate Gold layer VARCHAR with specific sizing
2. **Business Logic Enhancement**: Adding derived attributes and categorizations for improved analytics
3. **Temporal Processing**: Comprehensive time dimension with fiscal year calculations and business day logic
4. **Hierarchy Mapping**: Feature categorization with category → type → feature relationships
5. **Historical Tracking**: SCD Type 2 implementation for maintaining change history

## 2. Gold User Dimension (Go_USER_DIMENSION)

### 2.1 User Dimension Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| GOLD | Go_USER_DIMENSION | user_dimension_id | - | - | - | NUMBER AUTOINCREMENT (Snowflake sequence) |
| GOLD | Go_USER_DIMENSION | user_name | SILVER | Si_USERS | user_name | TRIM(UPPER(COALESCE(user_name, 'UNKNOWN'))) |
| GOLD | Go_USER_DIMENSION | email_address | SILVER | Si_USERS | email | LOWER(TRIM(email)) |
| GOLD | Go_USER_DIMENSION | email_domain | SILVER | Si_USERS | email_domain | LOWER(TRIM(COALESCE(email_domain, SPLIT_PART(email, '@', 2)))) |
| GOLD | Go_USER_DIMENSION | company | SILVER | Si_USERS | company | TRIM(INITCAP(COALESCE(company, 'Individual User'))) |
| GOLD | Go_USER_DIMENSION | plan_type | SILVER | Si_USERS | plan_type | CASE WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN plan_type ELSE 'Unknown' END |
| GOLD | Go_USER_DIMENSION | registration_date | SILVER | Si_USERS | registration_date | registration_date |
| GOLD | Go_USER_DIMENSION | account_age_days | SILVER | Si_USERS | account_age_days | COALESCE(account_age_days, DATEDIFF('day', registration_date, CURRENT_DATE())) |
| GOLD | Go_USER_DIMENSION | user_segment | SILVER | Si_USERS | user_segment | CASE WHEN account_age_days <= 30 THEN 'New User' WHEN account_age_days <= 365 THEN 'Active User' ELSE 'Veteran User' END |
| GOLD | Go_USER_DIMENSION | geographic_region | SILVER | Si_USERS | geographic_region | COALESCE(geographic_region, 'Unknown Region') |
| GOLD | Go_USER_DIMENSION | user_status | - | - | - | CASE WHEN CURRENT_DATE() BETWEEN effective_start_date AND COALESCE(effective_end_date, '9999-12-31') THEN 'Active' ELSE 'Inactive' END |
| GOLD | Go_USER_DIMENSION | effective_start_date | - | - | - | COALESCE(load_date, CURRENT_DATE()) |
| GOLD | Go_USER_DIMENSION | effective_end_date | - | - | - | NULL (for current records) or calculated end date for historical records |
| GOLD | Go_USER_DIMENSION | current_flag | - | - | - | TRUE for current records, FALSE for historical records |
| GOLD | Go_USER_DIMENSION | user_id | SILVER | Si_USERS | user_id | user_id |
| GOLD | Go_USER_DIMENSION | email | SILVER | Si_USERS | email | email |
| GOLD | Go_USER_DIMENSION | load_date | SILVER | Si_USERS | load_date | CURRENT_DATE() |
| GOLD | Go_USER_DIMENSION | update_date | SILVER | Si_USERS | update_date | CURRENT_DATE() |
| GOLD | Go_USER_DIMENSION | source_system | SILVER | Si_USERS | source_system | COALESCE(source_system, 'Zoom Platform') |

### 2.2 User Dimension SCD Type 2 Logic

```sql
MERGE INTO DB_POC_ZOOM.GOLD.Go_USER_DIMENSION AS target
USING (
    SELECT 
        user_id,
        TRIM(UPPER(COALESCE(user_name, 'UNKNOWN'))) AS user_name,
        LOWER(TRIM(email)) AS email_address,
        LOWER(TRIM(COALESCE(email_domain, SPLIT_PART(email, '@', 2)))) AS email_domain,
        TRIM(INITCAP(COALESCE(company, 'Individual User'))) AS company,
        CASE WHEN plan_type IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN plan_type ELSE 'Unknown' END AS plan_type,
        registration_date,
        COALESCE(account_age_days, DATEDIFF('day', registration_date, CURRENT_DATE())) AS account_age_days,
        CASE WHEN COALESCE(account_age_days, DATEDIFF('day', registration_date, CURRENT_DATE())) <= 30 THEN 'New User' 
             WHEN COALESCE(account_age_days, DATEDIFF('day', registration_date, CURRENT_DATE())) <= 365 THEN 'Active User' 
             ELSE 'Veteran User' END AS user_segment,
        COALESCE(geographic_region, 'Unknown Region') AS geographic_region,
        email,
        COALESCE(source_system, 'Zoom Platform') AS source_system
    FROM DB_POC_ZOOM.SILVER.Si_USERS
    WHERE load_date = CURRENT_DATE()
) AS source
ON target.user_id = source.user_id AND target.current_flag = TRUE
WHEN MATCHED AND (
    target.user_name != source.user_name OR
    target.email_address != source.email_address OR
    target.company != source.company OR
    target.plan_type != source.plan_type
) THEN UPDATE SET
    effective_end_date = CURRENT_DATE() - 1,
    current_flag = FALSE,
    update_date = CURRENT_DATE()
WHEN NOT MATCHED THEN INSERT (
    user_name, email_address, email_domain, company, plan_type, registration_date,
    account_age_days, user_segment, geographic_region, user_status,
    effective_start_date, effective_end_date, current_flag, user_id, email,
    load_date, update_date, source_system
) VALUES (
    source.user_name, source.email_address, source.email_domain, source.company, source.plan_type, source.registration_date,
    source.account_age_days, source.user_segment, source.geographic_region, 'Active',
    CURRENT_DATE(), NULL, TRUE, source.user_id, source.email,
    CURRENT_DATE(), CURRENT_DATE(), source.source_system
);
```

## 3. Gold Time Dimension (Go_TIME_DIMENSION)

### 3.1 Time Dimension Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| GOLD | Go_TIME_DIMENSION | time_dimension_id | - | - | - | NUMBER AUTOINCREMENT (Snowflake sequence) |
| GOLD | Go_TIME_DIMENSION | date_key | - | - | - | Generated date sequence from 2020-01-01 to 2030-12-31 |
| GOLD | Go_TIME_DIMENSION | year | - | - | - | EXTRACT(YEAR FROM date_key) |
| GOLD | Go_TIME_DIMENSION | quarter | - | - | - | EXTRACT(QUARTER FROM date_key) |
| GOLD | Go_TIME_DIMENSION | month | - | - | - | EXTRACT(MONTH FROM date_key) |
| GOLD | Go_TIME_DIMENSION | month_name | - | - | - | TO_CHAR(date_key, 'MMMM') |
| GOLD | Go_TIME_DIMENSION | week_of_year | - | - | - | EXTRACT(WEEK FROM date_key) |
| GOLD | Go_TIME_DIMENSION | day_of_month | - | - | - | EXTRACT(DAY FROM date_key) |
| GOLD | Go_TIME_DIMENSION | day_of_week | - | - | - | EXTRACT(DAYOFWEEK FROM date_key) |
| GOLD | Go_TIME_DIMENSION | day_name | - | - | - | TO_CHAR(date_key, 'Day') |
| GOLD | Go_TIME_DIMENSION | is_weekend | - | - | - | CASE WHEN EXTRACT(DAYOFWEEK FROM date_key) IN (1, 7) THEN TRUE ELSE FALSE END |
| GOLD | Go_TIME_DIMENSION | is_business_day | - | - | - | CASE WHEN EXTRACT(DAYOFWEEK FROM date_key) BETWEEN 2 AND 6 THEN TRUE ELSE FALSE END |
| GOLD | Go_TIME_DIMENSION | fiscal_year | - | - | - | CASE WHEN EXTRACT(MONTH FROM date_key) >= 4 THEN EXTRACT(YEAR FROM date_key) ELSE EXTRACT(YEAR FROM date_key) - 1 END |
| GOLD | Go_TIME_DIMENSION | fiscal_quarter | - | - | - | CASE WHEN EXTRACT(MONTH FROM date_key) IN (4,5,6) THEN 1 WHEN EXTRACT(MONTH FROM date_key) IN (7,8,9) THEN 2 WHEN EXTRACT(MONTH FROM date_key) IN (10,11,12) THEN 3 ELSE 4 END |
| GOLD | Go_TIME_DIMENSION | load_date | - | - | - | CURRENT_DATE() |
| GOLD | Go_TIME_DIMENSION | source_system | - | - | - | 'System Generated' |

### 3.2 Time Dimension Population Logic

```sql
INSERT INTO DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION (
    date_key, year, quarter, month, month_name, week_of_year, day_of_month, day_of_week, day_name,
    is_weekend, is_business_day, fiscal_year, fiscal_quarter, load_date, source_system
)
WITH date_series AS (
    SELECT DATEADD(day, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) AS date_key
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 11 years of dates
)
SELECT 
    date_key,
    EXTRACT(YEAR FROM date_key) AS year,
    EXTRACT(QUARTER FROM date_key) AS quarter,
    EXTRACT(MONTH FROM date_key) AS month,
    TO_CHAR(date_key, 'MMMM') AS month_name,
    EXTRACT(WEEK FROM date_key) AS week_of_year,
    EXTRACT(DAY FROM date_key) AS day_of_month,
    EXTRACT(DAYOFWEEK FROM date_key) AS day_of_week,
    TO_CHAR(date_key, 'Day') AS day_name,
    CASE WHEN EXTRACT(DAYOFWEEK FROM date_key) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
    CASE WHEN EXTRACT(DAYOFWEEK FROM date_key) BETWEEN 2 AND 6 THEN TRUE ELSE FALSE END AS is_business_day,
    CASE WHEN EXTRACT(MONTH FROM date_key) >= 4 THEN EXTRACT(YEAR FROM date_key) 
         ELSE EXTRACT(YEAR FROM date_key) - 1 END AS fiscal_year,
    CASE WHEN EXTRACT(MONTH FROM date_key) IN (4,5,6) THEN 1 
         WHEN EXTRACT(MONTH FROM date_key) IN (7,8,9) THEN 2 
         WHEN EXTRACT(MONTH FROM date_key) IN (10,11,12) THEN 3 
         ELSE 4 END AS fiscal_quarter,
    CURRENT_DATE() AS load_date,
    'System Generated' AS source_system
FROM date_series
WHERE date_key <= '2030-12-31';
```

## 4. Gold Feature Dimension (Go_FEATURE_DIMENSION)

### 4.1 Feature Dimension Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| GOLD | Go_FEATURE_DIMENSION | feature_dimension_id | - | - | - | NUMBER AUTOINCREMENT (Snowflake sequence) |
| GOLD | Go_FEATURE_DIMENSION | feature_name | SILVER | Si_FEATURE_USAGE | feature_name | TRIM(INITCAP(feature_name)) |
| GOLD | Go_FEATURE_DIMENSION | feature_category | SILVER | Si_FEATURE_USAGE | feature_category | CASE WHEN feature_name LIKE '%Screen%' THEN 'Collaboration' WHEN feature_name LIKE '%Record%' THEN 'Recording' WHEN feature_name LIKE '%Chat%' THEN 'Communication' WHEN feature_name LIKE '%Breakout%' THEN 'Meeting Management' ELSE 'General' END |
| GOLD | Go_FEATURE_DIMENSION | feature_description | - | - | - | CASE feature_name WHEN 'Screen Share' THEN 'Share desktop or application screen with participants' WHEN 'Recording' THEN 'Record meeting audio and video for later playback' WHEN 'Chat' THEN 'Text-based communication during meetings' WHEN 'Breakout Rooms' THEN 'Split meeting into smaller group sessions' ELSE CONCAT('Feature: ', feature_name) END |
| GOLD | Go_FEATURE_DIMENSION | feature_type | - | - | - | CASE WHEN feature_category IN ('Collaboration', 'Communication') THEN 'Interactive' WHEN feature_category = 'Recording' THEN 'Utility' ELSE 'Standard' END |
| GOLD | Go_FEATURE_DIMENSION | availability_plan | - | - | - | CASE WHEN feature_name IN ('Screen Share', 'Chat') THEN 'All Plans' WHEN feature_name IN ('Recording', 'Breakout Rooms') THEN 'Pro and Above' WHEN feature_name LIKE '%Webinar%' THEN 'Enterprise Only' ELSE 'Basic and Above' END |
| GOLD | Go_FEATURE_DIMENSION | feature_status | - | - | - | 'Active' |
| GOLD | Go_FEATURE_DIMENSION | launch_date | - | - | - | COALESCE(MIN(usage_date), '2020-01-01') FROM Si_FEATURE_USAGE GROUP BY feature_name |
| GOLD | Go_FEATURE_DIMENSION | usage_pattern | SILVER | Si_FEATURE_USAGE | usage_pattern | COALESCE(usage_pattern, 'Standard') |
| GOLD | Go_FEATURE_DIMENSION | load_date | SILVER | Si_FEATURE_USAGE | load_date | CURRENT_DATE() |
| GOLD | Go_FEATURE_DIMENSION | update_date | SILVER | Si_FEATURE_USAGE | update_date | CURRENT_DATE() |
| GOLD | Go_FEATURE_DIMENSION | source_system | SILVER | Si_FEATURE_USAGE | source_system | COALESCE(source_system, 'Zoom Platform') |

### 4.2 Feature Dimension Population Logic

```sql
INSERT INTO DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION (
    feature_name, feature_category, feature_description, feature_type, availability_plan,
    feature_status, launch_date, usage_pattern, load_date, update_date, source_system
)
SELECT DISTINCT
    TRIM(INITCAP(feature_name)) AS feature_name,
    CASE 
        WHEN feature_name LIKE '%Screen%' THEN 'Collaboration'
        WHEN feature_name LIKE '%Record%' THEN 'Recording'
        WHEN feature_name LIKE '%Chat%' THEN 'Communication'
        WHEN feature_name LIKE '%Breakout%' THEN 'Meeting Management'
        ELSE 'General'
    END AS feature_category,
    CASE feature_name
        WHEN 'Screen Share' THEN 'Share desktop or application screen with participants'
        WHEN 'Recording' THEN 'Record meeting audio and video for later playback'
        WHEN 'Chat' THEN 'Text-based communication during meetings'
        WHEN 'Breakout Rooms' THEN 'Split meeting into smaller group sessions'
        ELSE CONCAT('Feature: ', feature_name)
    END AS feature_description,
    CASE 
        WHEN CASE 
                WHEN feature_name LIKE '%Screen%' THEN 'Collaboration'
                WHEN feature_name LIKE '%Record%' THEN 'Recording'
                WHEN feature_name LIKE '%Chat%' THEN 'Communication'
                WHEN feature_name LIKE '%Breakout%' THEN 'Meeting Management'
                ELSE 'General'
             END IN ('Collaboration', 'Communication') THEN 'Interactive'
        WHEN CASE 
                WHEN feature_name LIKE '%Screen%' THEN 'Collaboration'
                WHEN feature_name LIKE '%Record%' THEN 'Recording'
                WHEN feature_name LIKE '%Chat%' THEN 'Communication'
                WHEN feature_name LIKE '%Breakout%' THEN 'Meeting Management'
                ELSE 'General'
             END = 'Recording' THEN 'Utility'
        ELSE 'Standard'
    END AS feature_type,
    CASE 
        WHEN feature_name IN ('Screen Share', 'Chat') THEN 'All Plans'
        WHEN feature_name IN ('Recording', 'Breakout Rooms') THEN 'Pro and Above'
        WHEN feature_name LIKE '%Webinar%' THEN 'Enterprise Only'
        ELSE 'Basic and Above'
    END AS availability_plan,
    'Active' AS feature_status,
    COALESCE(MIN(usage_date), '2020-01-01'::DATE) AS launch_date,
    COALESCE(MAX(usage_pattern), 'Standard') AS usage_pattern,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    COALESCE(MAX(source_system), 'Zoom Platform') AS source_system
FROM DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE
WHERE feature_name IS NOT NULL
GROUP BY feature_name;
```

## 5. Gold License Dimension (Go_LICENSE_DIMENSION)

### 5.1 License Dimension Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| GOLD | Go_LICENSE_DIMENSION | license_dimension_id | - | - | - | NUMBER AUTOINCREMENT (Snowflake sequence) |
| GOLD | Go_LICENSE_DIMENSION | license_type | SILVER | Si_LICENSES | license_type | TRIM(INITCAP(license_type)) |
| GOLD | Go_LICENSE_DIMENSION | license_description | - | - | - | CASE license_type WHEN 'Basic' THEN 'Basic plan with essential meeting features' WHEN 'Pro' THEN 'Professional plan with advanced features and cloud recording' WHEN 'Enterprise' THEN 'Enterprise plan with advanced security and admin features' WHEN 'Add-on' THEN 'Additional feature enhancement for existing plans' ELSE CONCAT('License Type: ', license_type) END |
| GOLD | Go_LICENSE_DIMENSION | license_category | - | - | - | CASE WHEN license_type IN ('Free', 'Basic') THEN 'Standard' WHEN license_type = 'Pro' THEN 'Professional' WHEN license_type = 'Enterprise' THEN 'Enterprise' ELSE 'Add-on' END |
| GOLD | Go_LICENSE_DIMENSION | price_tier | - | - | - | CASE license_type WHEN 'Free' THEN 'Free' WHEN 'Basic' THEN 'Entry' WHEN 'Pro' THEN 'Mid-tier' WHEN 'Enterprise' THEN 'Premium' ELSE 'Variable' END |
| GOLD | Go_LICENSE_DIMENSION | max_participants | - | - | - | CASE license_type WHEN 'Free' THEN 100 WHEN 'Basic' THEN 100 WHEN 'Pro' THEN 500 WHEN 'Enterprise' THEN 1000 ELSE 100 END |
| GOLD | Go_LICENSE_DIMENSION | meeting_duration_limit | - | - | - | CASE license_type WHEN 'Free' THEN 40 WHEN 'Basic' THEN 1440 WHEN 'Pro' THEN 1440 WHEN 'Enterprise' THEN 1440 ELSE 1440 END |
| GOLD | Go_LICENSE_DIMENSION | storage_limit_gb | - | - | - | CASE license_type WHEN 'Free' THEN 0 WHEN 'Basic' THEN 5 WHEN 'Pro' THEN 100 WHEN 'Enterprise' THEN 1000 ELSE 0 END |
| GOLD | Go_LICENSE_DIMENSION | support_level | - | - | - | CASE license_type WHEN 'Free' THEN 'Community' WHEN 'Basic' THEN 'Email Support' WHEN 'Pro' THEN 'Priority Support' WHEN 'Enterprise' THEN 'Dedicated Support' ELSE 'Standard' END |
| GOLD | Go_LICENSE_DIMENSION | effective_start_date | - | - | - | COALESCE(load_date, CURRENT_DATE()) |
| GOLD | Go_LICENSE_DIMENSION | effective_end_date | - | - | - | NULL (for current records) or calculated end date for historical records |
| GOLD | Go_LICENSE_DIMENSION | current_flag | - | - | - | TRUE for current records, FALSE for historical records |
| GOLD | Go_LICENSE_DIMENSION | license_id | SILVER | Si_LICENSES | license_id | license_id |
| GOLD | Go_LICENSE_DIMENSION | assigned_to_user_id | SILVER | Si_LICENSES | assigned_to_user_id | assigned_to_user_id |
| GOLD | Go_LICENSE_DIMENSION | start_date | SILVER | Si_LICENSES | start_date | start_date |
| GOLD | Go_LICENSE_DIMENSION | end_date | SILVER | Si_LICENSES | end_date | end_date |
| GOLD | Go_LICENSE_DIMENSION | license_status | SILVER | Si_LICENSES | license_status | CASE WHEN license_status IN ('Active', 'Expired', 'Suspended') THEN license_status ELSE 'Unknown' END |
| GOLD | Go_LICENSE_DIMENSION | license_duration_days | SILVER | Si_LICENSES | license_duration_days | COALESCE(license_duration_days, DATEDIFF('day', start_date, end_date)) |
| GOLD | Go_LICENSE_DIMENSION | renewal_flag | SILVER | Si_LICENSES | renewal_flag | COALESCE(renewal_flag, FALSE) |
| GOLD | Go_LICENSE_DIMENSION | load_date | SILVER | Si_LICENSES | load_date | CURRENT_DATE() |
| GOLD | Go_LICENSE_DIMENSION | update_date | SILVER | Si_LICENSES | update_date | CURRENT_DATE() |
| GOLD | Go_LICENSE_DIMENSION | source_system | SILVER | Si_LICENSES | source_system | COALESCE(source_system, 'Zoom Platform') |

### 5.2 License Dimension SCD Type 2 Logic

```sql
MERGE INTO DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION AS target
USING (
    SELECT 
        license_id,
        TRIM(INITCAP(license_type)) AS license_type,
        CASE license_type
            WHEN 'Basic' THEN 'Basic plan with essential meeting features'
            WHEN 'Pro' THEN 'Professional plan with advanced features and cloud recording'
            WHEN 'Enterprise' THEN 'Enterprise plan with advanced security and admin features'
            WHEN 'Add-on' THEN 'Additional feature enhancement for existing plans'
            ELSE CONCAT('License Type: ', license_type)
        END AS license_description,
        CASE 
            WHEN license_type IN ('Free', 'Basic') THEN 'Standard'
            WHEN license_type = 'Pro' THEN 'Professional'
            WHEN license_type = 'Enterprise' THEN 'Enterprise'
            ELSE 'Add-on'
        END AS license_category,
        CASE license_type
            WHEN 'Free' THEN 'Free'
            WHEN 'Basic' THEN 'Entry'
            WHEN 'Pro' THEN 'Mid-tier'
            WHEN 'Enterprise' THEN 'Premium'
            ELSE 'Variable'
        END AS price_tier,
        CASE license_type
            WHEN 'Free' THEN 100
            WHEN 'Basic' THEN 100
            WHEN 'Pro' THEN 500
            WHEN 'Enterprise' THEN 1000
            ELSE 100
        END AS max_participants,
        CASE license_type
            WHEN 'Free' THEN 40
            ELSE 1440
        END AS meeting_duration_limit,
        CASE license_type
            WHEN 'Free' THEN 0
            WHEN 'Basic' THEN 5
            WHEN 'Pro' THEN 100
            WHEN 'Enterprise' THEN 1000
            ELSE 0
        END AS storage_limit_gb,
        CASE license_type
            WHEN 'Free' THEN 'Community'
            WHEN 'Basic' THEN 'Email Support'
            WHEN 'Pro' THEN 'Priority Support'
            WHEN 'Enterprise' THEN 'Dedicated Support'
            ELSE 'Standard'
        END AS support_level,
        assigned_to_user_id,
        start_date,
        end_date,
        CASE WHEN license_status IN ('Active', 'Expired', 'Suspended') THEN license_status ELSE 'Unknown' END AS license_status,
        COALESCE(license_duration_days, DATEDIFF('day', start_date, end_date)) AS license_duration_days,
        COALESCE(renewal_flag, FALSE) AS renewal_flag,
        COALESCE(source_system, 'Zoom Platform') AS source_system
    FROM DB_POC_ZOOM.SILVER.Si_LICENSES
    WHERE load_date = CURRENT_DATE()
) AS source
ON target.license_id = source.license_id AND target.current_flag = TRUE
WHEN MATCHED AND (
    target.license_type != source.license_type OR
    target.license_status != source.license_status OR
    target.assigned_to_user_id != source.assigned_to_user_id
) THEN UPDATE SET
    effective_end_date = CURRENT_DATE() - 1,
    current_flag = FALSE,
    update_date = CURRENT_DATE()
WHEN NOT MATCHED THEN INSERT (
    license_type, license_description, license_category, price_tier, max_participants,
    meeting_duration_limit, storage_limit_gb, support_level, effective_start_date,
    effective_end_date, current_flag, license_id, assigned_to_user_id, start_date,
    end_date, license_status, license_duration_days, renewal_flag, load_date,
    update_date, source_system
) VALUES (
    source.license_type, source.license_description, source.license_category, source.price_tier, source.max_participants,
    source.meeting_duration_limit, source.storage_limit_gb, source.support_level, CURRENT_DATE(),
    NULL, TRUE, source.license_id, source.assigned_to_user_id, source.start_date,
    source.end_date, source.license_status, source.license_duration_days, source.renewal_flag, CURRENT_DATE(),
    CURRENT_DATE(), source.source_system
);
```

## 6. Data Quality and Validation Rules

### 6.1 User Dimension Validation

1. **Email Format Validation**: Email addresses must contain '@' symbol and valid domain
2. **Plan Type Validation**: Plan type must be one of ['Free', 'Basic', 'Pro', 'Enterprise']
3. **Registration Date Validation**: Registration date cannot be future dated
4. **User Name Validation**: User name cannot be null or empty

### 6.2 Time Dimension Validation

1. **Date Range Validation**: Date key must be within valid range (2020-2030)
2. **Fiscal Year Calculation**: Fiscal year must be correctly calculated based on April start
3. **Business Day Logic**: Weekend and business day flags must be mutually exclusive

### 6.3 Feature Dimension Validation

1. **Feature Name Uniqueness**: Feature names must be unique within the dimension
2. **Category Mapping**: Feature category must be properly mapped based on feature name
3. **Availability Plan Logic**: Plan availability must align with feature complexity

### 6.4 License Dimension Validation

1. **License Type Validation**: License type must be from predefined list
2. **Date Logic Validation**: Start date must be before or equal to end date
3. **Status Validation**: License status must be one of ['Active', 'Expired', 'Suspended']
4. **Capacity Validation**: Max participants and storage limits must align with license type

## 7. Performance Optimization

### 7.1 Clustering Keys

1. **User Dimension**: CLUSTER BY (user_name, effective_start_date)
2. **Time Dimension**: CLUSTER BY (date_key)
3. **Feature Dimension**: CLUSTER BY (feature_name, feature_category)
4. **License Dimension**: CLUSTER BY (license_type, effective_start_date)

### 7.2 Indexing Strategy

1. **Primary Keys**: All dimension tables use AUTOINCREMENT for surrogate keys
2. **Natural Keys**: Business keys (user_id, license_id) maintained for referential integrity
3. **SCD Columns**: Effective dates and current flags optimized for temporal queries

## 8. Error Handling and Data Lineage

### 8.1 Error Handling

1. **Null Value Handling**: COALESCE functions provide default values for missing data
2. **Data Type Conversion**: Explicit casting and validation for data type consistency
3. **Business Rule Validation**: CASE statements ensure data conforms to business rules
4. **Referential Integrity**: Foreign key relationships maintained through validation

### 8.2 Data Lineage Tracking

1. **Source System Tracking**: Source system field maintained throughout transformation
2. **Load Date Tracking**: Load and update dates tracked for audit purposes
3. **Transformation Logic**: All transformation rules documented and version controlled
4. **Change History**: SCD Type 2 implementation maintains complete change history

## 9. Deployment and Maintenance

### 9.1 Deployment Process

1. **Sequential Execution**: Dimension tables loaded before fact tables
2. **Dependency Management**: Time dimension loaded first as it has no dependencies
3. **Validation Checks**: Data quality validation after each dimension load
4. **Performance Monitoring**: Query performance tracked and optimized

### 9.2 Maintenance Procedures

1. **Regular Validation**: Daily data quality checks and validation
2. **Performance Tuning**: Monthly clustering key optimization
3. **Schema Evolution**: Version-controlled schema changes with backward compatibility
4. **Capacity Planning**: Storage and compute resource monitoring and scaling

---

**Document Version**: 1.0  
**Last Updated**: Current Date  
**Next Review**: Quarterly  
**Approved By**: Data Architecture Team