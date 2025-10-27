_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Dimension Table Transformation Recommendations for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Gold Layer Dimension Table Transformation Recommendations

## 1. Go_USER_DIMENSION Transformation Rules

### 1.1 Data Type Conversions

**Rationale**: Ensure consistent data types between Silver and Gold layers for optimal query performance and data integrity.

**SQL Example**:
```sql
SELECT 
    ROW_NUMBER() OVER (ORDER BY user_id) AS user_dimension_id,
    CAST(user_name AS VARCHAR(200)) AS user_name,
    CAST(email AS VARCHAR(300)) AS email_address,
    CAST(email_domain AS VARCHAR(100)) AS email_domain,
    CAST(company AS VARCHAR(200)) AS company,
    CAST(plan_type AS VARCHAR(30)) AS plan_type,
    CAST(registration_date AS DATE) AS registration_date,
    CAST(account_age_days AS NUMBER(38,0)) AS account_age_days,
    CAST(user_segment AS VARCHAR(30)) AS user_segment,
    CAST(geographic_region AS VARCHAR(50)) AS geographic_region
FROM DB_POC_ZOOM.SILVER.Si_USERS;
```

### 1.2 Column Derivations and Standardization

**Rationale**: Create standardized user status and enhance email domain extraction for better analytics and reporting.

**SQL Example**:
```sql
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
    END AS user_status
FROM DB_POC_ZOOM.SILVER.Si_USERS;
```

### 1.3 SCD Type 2 Implementation

**Rationale**: Track historical changes in user attributes for trend analysis and compliance requirements.

**SQL Example**:
```sql
INSERT INTO DB_POC_ZOOM.GOLD.Go_USER_DIMENSION (
    user_name, email_address, company, plan_type, 
    effective_start_date, effective_end_date, current_flag
)
SELECT 
    user_name,
    email_address,
    company,
    plan_type,
    CURRENT_DATE() AS effective_start_date,
    '9999-12-31'::DATE AS effective_end_date,
    TRUE AS current_flag
FROM DB_POC_ZOOM.SILVER.Si_USERS s
WHERE NOT EXISTS (
    SELECT 1 FROM DB_POC_ZOOM.GOLD.Go_USER_DIMENSION g
    WHERE g.user_name = s.user_name AND g.current_flag = TRUE
);
```

## 2. Go_TIME_DIMENSION Transformation Rules

### 2.1 Date Hierarchy Generation

**Rationale**: Create comprehensive time hierarchy for temporal analysis and reporting across different granularities.

**SQL Example**:
```sql
WITH date_range AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) AS date_key
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY date_key) AS time_dimension_id,
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
    CASE WHEN DAYOFWEEK(date_key) BETWEEN 2 AND 6 THEN TRUE ELSE FALSE END AS is_business_day
FROM date_range;
```

### 2.2 Fiscal Calendar Integration

**Rationale**: Support fiscal year reporting requirements for business analytics.

**SQL Example**:
```sql
SELECT 
    date_key,
    CASE 
        WHEN MONTH(date_key) >= 4 THEN YEAR(date_key)
        ELSE YEAR(date_key) - 1
    END AS fiscal_year,
    CASE 
        WHEN MONTH(date_key) BETWEEN 4 AND 6 THEN 1
        WHEN MONTH(date_key) BETWEEN 7 AND 9 THEN 2
        WHEN MONTH(date_key) BETWEEN 10 AND 12 THEN 3
        ELSE 4
    END AS fiscal_quarter
FROM DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION;
```

## 3. Go_FEATURE_DIMENSION Transformation Rules

### 3.1 Feature Categorization and Standardization

**Rationale**: Standardize feature names and create consistent categorization for feature adoption analysis.

**SQL Example**:
```sql
SELECT 
    ROW_NUMBER() OVER (ORDER BY feature_name) AS feature_dimension_id,
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
        WHEN feature_category = 'Collaboration' THEN 'Interactive feature for participant engagement'
        WHEN feature_category = 'Recording' THEN 'Content capture and storage feature'
        WHEN feature_category = 'Communication' THEN 'Real-time communication feature'
        WHEN feature_category = 'Meeting Management' THEN 'Meeting organization and control feature'
        ELSE 'Platform utility feature'
    END AS feature_description,
    'Standard' AS feature_type,
    'All Plans' AS availability_plan,
    'Active' AS feature_status
FROM (
    SELECT DISTINCT feature_name, usage_pattern
    FROM DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE
    WHERE feature_name IS NOT NULL AND TRIM(feature_name) != ''
) src;
```

### 3.2 Feature Usage Pattern Analysis

**Rationale**: Enhance feature dimension with usage patterns for adoption analytics.

**SQL Example**:
```sql
SELECT 
    f.feature_name,
    f.feature_category,
    CASE 
        WHEN AVG(fu.usage_count) > 10 THEN 'High Usage'
        WHEN AVG(fu.usage_count) > 5 THEN 'Medium Usage'
        ELSE 'Low Usage'
    END AS usage_intensity,
    COUNT(DISTINCT fu.meeting_id) AS meetings_used_count
FROM DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION f
LEFT JOIN DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE fu ON f.feature_name = fu.feature_name
GROUP BY f.feature_name, f.feature_category;
```

## 4. Go_LICENSE_DIMENSION Transformation Rules

### 4.1 License Type Standardization and Enhancement

**Rationale**: Create comprehensive license attributes for revenue analysis and capacity planning.

**SQL Example**:
```sql
SELECT 
    ROW_NUMBER() OVER (ORDER BY license_type) AS license_dimension_id,
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
    END AS meeting_duration_limit
FROM (
    SELECT DISTINCT license_type
    FROM DB_POC_ZOOM.SILVER.Si_LICENSES
    WHERE license_type IS NOT NULL AND TRIM(license_type) != ''
) src;
```

### 4.2 License Lifecycle Management

**Rationale**: Track license lifecycle for renewal analysis and capacity management.

**SQL Example**:
```sql
SELECT 
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    license_status,
    DATEDIFF(day, start_date, COALESCE(end_date, CURRENT_DATE())) AS license_duration_days,
    CASE 
        WHEN end_date > CURRENT_DATE() THEN TRUE
        ELSE FALSE
    END AS renewal_flag,
    CASE 
        WHEN license_status = 'Active' AND end_date > CURRENT_DATE() THEN 'Current'
        WHEN license_status = 'Active' AND end_date <= CURRENT_DATE() THEN 'Expired'
        WHEN license_status = 'Suspended' THEN 'Suspended'
        ELSE 'Inactive'
    END AS lifecycle_status
FROM DB_POC_ZOOM.SILVER.Si_LICENSES;
```

## 5. Cross-Dimensional Data Quality Rules

### 5.1 Referential Integrity Validation

**Rationale**: Ensure data consistency across dimension tables and maintain referential integrity.

**SQL Example**:
```sql
-- Validate User Dimension integrity
SELECT 
    'User Dimension' AS dimension_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT user_name) AS unique_users,
    COUNT(CASE WHEN email_address IS NULL THEN 1 END) AS missing_emails,
    COUNT(CASE WHEN plan_type NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 1 END) AS invalid_plan_types
FROM DB_POC_ZOOM.GOLD.Go_USER_DIMENSION
WHERE current_flag = TRUE;
```

### 5.2 Data Standardization Rules

**Rationale**: Apply consistent formatting and validation rules across all dimension tables.

**SQL Example**:
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

## 6. Performance Optimization Rules

### 6.1 Clustering Key Implementation

**Rationale**: Optimize query performance for dimension tables based on common access patterns.

**SQL Example**:
```sql
-- Clustering keys for dimension tables
ALTER TABLE DB_POC_ZOOM.GOLD.Go_USER_DIMENSION 
CLUSTER BY (user_name, effective_start_date);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION 
CLUSTER BY (date_key);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION 
CLUSTER BY (feature_category, feature_name);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION 
CLUSTER BY (license_type, effective_start_date);
```

### 6.2 Index Recommendations

**Rationale**: Improve query performance for common lookup patterns in dimension tables.

**SQL Example**:
```sql
-- Create search optimization for dimension tables
ALTER TABLE DB_POC_ZOOM.GOLD.Go_USER_DIMENSION 
ADD SEARCH OPTIMIZATION ON EQUALITY(user_name, email_address);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION 
ADD SEARCH OPTIMIZATION ON EQUALITY(feature_name, feature_category);
```

## 7. Data Lineage and Traceability

### 7.1 Source System Tracking

**Rationale**: Maintain complete data lineage for audit and troubleshooting purposes.

**SQL Example**:
```sql
-- Add source tracking to all dimension transformations
SELECT 
    *,
    'DB_POC_ZOOM.SILVER.Si_USERS' AS source_table,
    'ETL_DIMENSION_LOAD' AS source_system,
    CURRENT_DATE() AS load_date,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM transformed_user_data;
```

### 7.2 Change Data Capture Integration

**Rationale**: Enable incremental loading and change tracking for dimension tables.

**SQL Example**:
```sql
-- CDC pattern for dimension updates
MERGE INTO DB_POC_ZOOM.GOLD.Go_USER_DIMENSION AS target
USING (
    SELECT * FROM DB_POC_ZOOM.SILVER.Si_USERS 
    WHERE update_date >= CURRENT_DATE() - 1
) AS source
ON target.user_name = source.user_name AND target.current_flag = TRUE
WHEN MATCHED AND (
    target.email_address != source.email OR 
    target.plan_type != source.plan_type
) THEN 
    UPDATE SET 
        effective_end_date = CURRENT_DATE() - 1,
        current_flag = FALSE
WHEN NOT MATCHED THEN 
    INSERT VALUES (source.user_name, source.email, CURRENT_DATE(), '9999-12-31', TRUE);
```

## 8. Business Rule Implementation

### 8.1 Plan Type Hierarchy

**Rationale**: Implement business rules for plan type categorization and user segmentation.

**SQL Example**:
```sql
SELECT 
    user_name,
    plan_type,
    CASE 
        WHEN plan_type = 'Enterprise' THEN 1
        WHEN plan_type = 'Pro' THEN 2
        WHEN plan_type = 'Basic' THEN 3
        WHEN plan_type = 'Free' THEN 4
        ELSE 5
    END AS plan_hierarchy_level,
    CASE 
        WHEN plan_type IN ('Enterprise', 'Pro') THEN 'Premium'
        WHEN plan_type = 'Basic' THEN 'Standard'
        ELSE 'Free Tier'
    END AS user_segment
FROM DB_POC_ZOOM.GOLD.Go_USER_DIMENSION;
```

### 8.2 Feature Availability Rules

**Rationale**: Map feature availability to plan types for access control and analytics.

**SQL Example**:
```sql
SELECT 
    f.feature_name,
    f.feature_category,
    CASE 
        WHEN f.feature_name IN ('Screen Share', 'Chat') THEN 'All Plans'
        WHEN f.feature_name IN ('Recording', 'Breakout Rooms') THEN 'Basic+'
        WHEN f.feature_name IN ('Webinar', 'Advanced Analytics') THEN 'Pro+'
        WHEN f.feature_name IN ('Enterprise SSO', 'Advanced Security') THEN 'Enterprise Only'
        ELSE 'All Plans'
    END AS availability_plan
FROM DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION f;
```