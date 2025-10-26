_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Gold Layer Dimension Table Transformation Recommendations for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Gold Layer Dimension Table Transformation Recommendations

## Executive Summary

This document provides comprehensive transformation rules for dimension tables in the Gold layer of the Zoom Platform Analytics System. The transformations ensure data integrity, standardization, and consistency while implementing Slowly Changing Dimension (SCD) Type 2 for historical tracking where required.

## 1. Go_USER_DIMENSION Transformation Rules

### 1.1 Data Type Conversions and Standardizations

**Rule 1.1.1: Email Address Standardization**
- **Source**: Si_USERS.email
- **Target**: Go_USER_DIMENSION.email_address
- **Transformation**: Convert to lowercase and validate format
- **Rationale**: Ensures consistent email format for analytics and prevents duplicate users due to case sensitivity
- **Traceability**: Maps to Conceptual Model "Users.Email Address" attribute

```sql
-- Email Address Standardization
SELECT 
    LOWER(TRIM(email)) AS email_address,
    CASE 
        WHEN REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
        THEN LOWER(TRIM(email))
        ELSE NULL 
    END AS validated_email_address
FROM DB_POC_ZOOM.SILVER.Si_USERS;
```

**Rule 1.1.2: Plan Type Validation and Standardization**
- **Source**: Si_USERS.plan_type
- **Target**: Go_USER_DIMENSION.plan_type
- **Transformation**: Validate against allowed values and standardize casing
- **Rationale**: Enforces business constraint that Plan_Type must be one of ['Free', 'Basic', 'Pro', 'Enterprise']
- **Traceability**: Maps to Conceptual Model "Users.Plan Type" and Data Constraints

```sql
-- Plan Type Validation
SELECT 
    CASE 
        WHEN UPPER(TRIM(plan_type)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
        THEN INITCAP(TRIM(plan_type))
        ELSE 'Unknown'
    END AS plan_type
FROM DB_POC_ZOOM.SILVER.Si_USERS;
```

**Rule 1.1.3: User Status Derivation**
- **Source**: Si_USERS (multiple columns)
- **Target**: Go_USER_DIMENSION.user_status
- **Transformation**: Derive user status based on account age and activity
- **Rationale**: Provides business-friendly categorization for user lifecycle analysis
- **Traceability**: Supports KPI "Active User" definitions from Conceptual Model

```sql
-- User Status Derivation
SELECT 
    user_id,
    CASE 
        WHEN account_age_days <= 30 THEN 'New'
        WHEN account_age_days <= 90 THEN 'Active'
        WHEN account_age_days > 365 AND plan_type = 'Free' THEN 'Dormant'
        ELSE 'Established'
    END AS user_status
FROM DB_POC_ZOOM.SILVER.Si_USERS;
```

### 1.2 SCD Type 2 Implementation

**Rule 1.2.1: SCD Type 2 for User Dimension**
- **Purpose**: Track historical changes in user attributes (plan_type, company, user_segment)
- **Key Columns**: effective_start_date, effective_end_date, current_flag
- **Rationale**: Business requirement to analyze user plan changes and company transitions over time
- **Traceability**: Supports Revenue & License Analysis KPIs from Conceptual Model

```sql
-- SCD Type 2 Implementation for User Dimension
MERGE INTO DB_POC_ZOOM.GOLD.Go_USER_DIMENSION AS target
USING (
    SELECT 
        user_id,
        user_name,
        LOWER(TRIM(email)) AS email_address,
        email_domain,
        company,
        INITCAP(plan_type) AS plan_type,
        registration_date,
        account_age_days,
        user_segment,
        geographic_region,
        CASE 
            WHEN account_age_days <= 30 THEN 'New'
            WHEN account_age_days <= 90 THEN 'Active'
            WHEN account_age_days > 365 AND plan_type = 'Free' THEN 'Dormant'
            ELSE 'Established'
        END AS user_status,
        CURRENT_DATE AS effective_start_date,
        '9999-12-31'::DATE AS effective_end_date,
        TRUE AS current_flag,
        email,
        CURRENT_DATE AS load_date,
        CURRENT_DATE AS update_date,
        'SILVER_LAYER' AS source_system
    FROM DB_POC_ZOOM.SILVER.Si_USERS
) AS source
ON target.user_id = source.user_id AND target.current_flag = TRUE
WHEN MATCHED AND (
    target.plan_type != source.plan_type OR
    target.company != source.company OR
    target.user_segment != source.user_segment OR
    target.geographic_region != source.geographic_region
) THEN
    UPDATE SET 
        effective_end_date = CURRENT_DATE - 1,
        current_flag = FALSE,
        update_date = CURRENT_DATE
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
        source.user_status, source.effective_start_date, source.effective_end_date,
        source.current_flag, source.user_id, source.email, source.load_date,
        source.update_date, source.source_system
    );
```

## 2. Go_TIME_DIMENSION Transformation Rules

### 2.1 Time Dimension Population

**Rule 2.1.1: Complete Time Dimension Generation**
- **Source**: Generated date range
- **Target**: Go_TIME_DIMENSION (all columns)
- **Transformation**: Generate comprehensive time attributes for analytics
- **Rationale**: Provides complete temporal context for all time-based analysis
- **Traceability**: Supports all temporal KPIs from Conceptual Model

```sql
-- Time Dimension Population
INSERT INTO DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION (
    date_key, year, quarter, month, month_name, week_of_year,
    day_of_month, day_of_week, day_name, is_weekend, is_business_day,
    fiscal_year, fiscal_quarter, load_date, source_system
)
WITH date_range AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) AS date_key
    FROM TABLE(GENERATOR(ROWCOUNT => 3653)) -- 10 years of dates
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
    CURRENT_DATE AS load_date,
    'SYSTEM_GENERATED' AS source_system
FROM date_range;
```

## 3. Go_FEATURE_DIMENSION Transformation Rules

### 3.1 Feature Dimension Enrichment

**Rule 3.1.1: Feature Categorization and Enrichment**
- **Source**: Si_FEATURE_USAGE.feature_name, feature_category
- **Target**: Go_FEATURE_DIMENSION (all columns)
- **Transformation**: Enrich with business metadata and categorization
- **Rationale**: Provides comprehensive feature context for adoption analysis
- **Traceability**: Maps to Conceptual Model "Features Usage" entity

```sql
-- Feature Dimension Enrichment
INSERT INTO DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION (
    feature_name, feature_category, feature_description, feature_type,
    availability_plan, feature_status, launch_date, usage_pattern,
    load_date, update_date, source_system
)
WITH feature_metadata AS (
    SELECT DISTINCT
        feature_name,
        feature_category,
        usage_pattern
    FROM DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE
),
feature_enriched AS (
    SELECT 
        feature_name,
        COALESCE(feature_category, 'General') AS feature_category,
        CASE 
            WHEN feature_name LIKE '%Screen%Share%' THEN 'Screen sharing functionality for presentations and collaboration'
            WHEN feature_name LIKE '%Record%' THEN 'Meeting recording capability for future reference'
            WHEN feature_name LIKE '%Chat%' THEN 'In-meeting text communication feature'
            WHEN feature_name LIKE '%Breakout%' THEN 'Breakout rooms for small group discussions'
            WHEN feature_name LIKE '%Whiteboard%' THEN 'Interactive whiteboard for visual collaboration'
            ELSE 'Platform feature for enhanced meeting experience'
        END AS feature_description,
        CASE 
            WHEN feature_name IN ('Screen Share', 'Chat', 'Audio', 'Video') THEN 'Core'
            WHEN feature_name IN ('Recording', 'Whiteboard', 'Breakout Rooms') THEN 'Premium'
            ELSE 'Add-on'
        END AS feature_type,
        CASE 
            WHEN feature_name IN ('Screen Share', 'Chat', 'Audio', 'Video') THEN 'Free,Basic,Pro,Enterprise'
            WHEN feature_name IN ('Recording', 'Whiteboard') THEN 'Pro,Enterprise'
            WHEN feature_name IN ('Breakout Rooms', 'Advanced Analytics') THEN 'Enterprise'
            ELSE 'Pro,Enterprise'
        END AS availability_plan,
        'Active' AS feature_status,
        '2020-01-01'::DATE AS launch_date,
        COALESCE(usage_pattern, 'Standard') AS usage_pattern
    FROM feature_metadata
)
SELECT 
    feature_name,
    feature_category,
    feature_description,
    feature_type,
    availability_plan,
    feature_status,
    launch_date,
    usage_pattern,
    CURRENT_DATE AS load_date,
    CURRENT_DATE AS update_date,
    'SILVER_LAYER' AS source_system
FROM feature_enriched;
```

## 4. Go_LICENSE_DIMENSION Transformation Rules

### 4.1 License Dimension Enrichment and SCD Type 2

**Rule 4.1.1: License Type Enrichment**
- **Source**: Si_LICENSES.license_type
- **Target**: Go_LICENSE_DIMENSION (enriched columns)
- **Transformation**: Add business metadata for license types
- **Rationale**: Provides comprehensive license context for revenue analysis
- **Traceability**: Maps to Conceptual Model "Licenses" entity and Revenue KPIs

```sql
-- License Dimension Enrichment
WITH license_enrichment AS (
    SELECT 
        license_type,
        CASE 
            WHEN license_type = 'Basic' THEN 'Basic Zoom license with essential meeting features'
            WHEN license_type = 'Pro' THEN 'Professional license with advanced features and cloud recording'
            WHEN license_type = 'Enterprise' THEN 'Enterprise license with full feature set and admin controls'
            WHEN license_type = 'Add-on' THEN 'Additional feature license for specific capabilities'
            ELSE 'Standard Zoom license'
        END AS license_description,
        CASE 
            WHEN license_type IN ('Basic', 'Free') THEN 'Basic'
            WHEN license_type = 'Pro' THEN 'Professional'
            WHEN license_type = 'Enterprise' THEN 'Enterprise'
            ELSE 'Specialty'
        END AS license_category,
        CASE 
            WHEN license_type = 'Basic' THEN 'Tier 1'
            WHEN license_type = 'Pro' THEN 'Tier 2'
            WHEN license_type = 'Enterprise' THEN 'Tier 3'
            ELSE 'Tier 0'
        END AS price_tier,
        CASE 
            WHEN license_type = 'Basic' THEN 100
            WHEN license_type = 'Pro' THEN 500
            WHEN license_type = 'Enterprise' THEN 1000
            ELSE 100
        END AS max_participants,
        CASE 
            WHEN license_type = 'Basic' THEN 40
            WHEN license_type IN ('Pro', 'Enterprise') THEN 1440
            ELSE 40
        END AS meeting_duration_limit,
        CASE 
            WHEN license_type = 'Pro' THEN 1
            WHEN license_type = 'Enterprise' THEN 10
            ELSE 0
        END AS storage_limit_gb,
        CASE 
            WHEN license_type = 'Enterprise' THEN 'Premium'
            WHEN license_type = 'Pro' THEN 'Standard'
            ELSE 'Basic'
        END AS support_level
    FROM (SELECT DISTINCT license_type FROM DB_POC_ZOOM.SILVER.Si_LICENSES)
)
SELECT * FROM license_enrichment;
```

**Rule 4.1.2: SCD Type 2 for License Dimension**
- **Purpose**: Track historical changes in license assignments and status
- **Key Columns**: effective_start_date, effective_end_date, current_flag
- **Rationale**: Business requirement to analyze license utilization trends over time
- **Traceability**: Supports License Utilization KPIs from Conceptual Model

```sql
-- SCD Type 2 Implementation for License Dimension
MERGE INTO DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION AS target
USING (
    SELECT 
        l.license_id,
        l.license_type,
        le.license_description,
        le.license_category,
        le.price_tier,
        le.max_participants,
        le.meeting_duration_limit,
        le.storage_limit_gb,
        le.support_level,
        CURRENT_DATE AS effective_start_date,
        '9999-12-31'::DATE AS effective_end_date,
        TRUE AS current_flag,
        l.assigned_to_user_id,
        l.start_date,
        l.end_date,
        CASE 
            WHEN l.license_status IN ('Active', 'Expired', 'Suspended') 
            THEN l.license_status
            ELSE 'Unknown'
        END AS license_status,
        l.license_duration_days,
        l.renewal_flag,
        CURRENT_DATE AS load_date,
        CURRENT_DATE AS update_date,
        'SILVER_LAYER' AS source_system
    FROM DB_POC_ZOOM.SILVER.Si_LICENSES l
    JOIN (
        SELECT 
            license_type,
            CASE 
                WHEN license_type = 'Basic' THEN 'Basic Zoom license with essential meeting features'
                WHEN license_type = 'Pro' THEN 'Professional license with advanced features and cloud recording'
                WHEN license_type = 'Enterprise' THEN 'Enterprise license with full feature set and admin controls'
                WHEN license_type = 'Add-on' THEN 'Additional feature license for specific capabilities'
                ELSE 'Standard Zoom license'
            END AS license_description,
            CASE 
                WHEN license_type IN ('Basic', 'Free') THEN 'Basic'
                WHEN license_type = 'Pro' THEN 'Professional'
                WHEN license_type = 'Enterprise' THEN 'Enterprise'
                ELSE 'Specialty'
            END AS license_category,
            CASE 
                WHEN license_type = 'Basic' THEN 'Tier 1'
                WHEN license_type = 'Pro' THEN 'Tier 2'
                WHEN license_type = 'Enterprise' THEN 'Tier 3'
                ELSE 'Tier 0'
            END AS price_tier,
            CASE 
                WHEN license_type = 'Basic' THEN 100
                WHEN license_type = 'Pro' THEN 500
                WHEN license_type = 'Enterprise' THEN 1000
                ELSE 100
            END AS max_participants,
            CASE 
                WHEN license_type = 'Basic' THEN 40
                WHEN license_type IN ('Pro', 'Enterprise') THEN 1440
                ELSE 40
            END AS meeting_duration_limit,
            CASE 
                WHEN license_type = 'Pro' THEN 1
                WHEN license_type = 'Enterprise' THEN 10
                ELSE 0
            END AS storage_limit_gb,
            CASE 
                WHEN license_type = 'Enterprise' THEN 'Premium'
                WHEN license_type = 'Pro' THEN 'Standard'
                ELSE 'Basic'
            END AS support_level
        FROM (SELECT DISTINCT license_type FROM DB_POC_ZOOM.SILVER.Si_LICENSES)
    ) le ON l.license_type = le.license_type
) AS source
ON target.license_id = source.license_id AND target.current_flag = TRUE
WHEN MATCHED AND (
    target.license_status != source.license_status OR
    target.assigned_to_user_id != source.assigned_to_user_id OR
    target.end_date != source.end_date
) THEN
    UPDATE SET 
        effective_end_date = CURRENT_DATE - 1,
        current_flag = FALSE,
        update_date = CURRENT_DATE
WHEN NOT MATCHED THEN
    INSERT (
        license_type, license_description, license_category, price_tier,
        max_participants, meeting_duration_limit, storage_limit_gb, support_level,
        effective_start_date, effective_end_date, current_flag,
        license_id, assigned_to_user_id, start_date, end_date, license_status,
        license_duration_days, renewal_flag, load_date, update_date, source_system
    )
    VALUES (
        source.license_type, source.license_description, source.license_category,
        source.price_tier, source.max_participants, source.meeting_duration_limit,
        source.storage_limit_gb, source.support_level, source.effective_start_date,
        source.effective_end_date, source.current_flag, source.license_id,
        source.assigned_to_user_id, source.start_date, source.end_date,
        source.license_status, source.license_duration_days, source.renewal_flag,
        source.load_date, source.update_date, source.source_system
    );
```

## 5. Data Quality and Validation Rules

### 5.1 Cross-Dimension Validation

**Rule 5.1.1: Referential Integrity Validation**
- **Purpose**: Ensure data consistency across dimensions
- **Validation**: Check for orphaned records and invalid references
- **Rationale**: Maintains data integrity as per business constraints

```sql
-- Referential Integrity Validation
WITH validation_results AS (
    SELECT 
        'USER_DIMENSION' AS table_name,
        'INVALID_EMAIL_FORMAT' AS validation_type,
        COUNT(*) AS error_count
    FROM DB_POC_ZOOM.GOLD.Go_USER_DIMENSION
    WHERE email_address IS NULL OR email_address = ''
    
    UNION ALL
    
    SELECT 
        'USER_DIMENSION' AS table_name,
        'INVALID_PLAN_TYPE' AS validation_type,
        COUNT(*) AS error_count
    FROM DB_POC_ZOOM.GOLD.Go_USER_DIMENSION
    WHERE plan_type NOT IN ('Free', 'Basic', 'Pro', 'Enterprise', 'Unknown')
    
    UNION ALL
    
    SELECT 
        'LICENSE_DIMENSION' AS table_name,
        'INVALID_LICENSE_STATUS' AS validation_type,
        COUNT(*) AS error_count
    FROM DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION
    WHERE license_status NOT IN ('Active', 'Expired', 'Suspended', 'Unknown')
)
SELECT * FROM validation_results WHERE error_count > 0;
```

## 6. Performance Optimization Rules

### 6.1 Indexing and Clustering Strategy

**Rule 6.1.1: Dimension Table Clustering**
- **Purpose**: Optimize query performance for dimension lookups
- **Strategy**: Cluster on most frequently used filter columns
- **Rationale**: Improves join performance with fact tables

```sql
-- Clustering Keys for Dimension Tables
ALTER TABLE DB_POC_ZOOM.GOLD.Go_USER_DIMENSION 
CLUSTER BY (user_name, effective_start_date);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION 
CLUSTER BY (date_key);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION 
CLUSTER BY (feature_name, feature_category);

ALTER TABLE DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION 
CLUSTER BY (license_type, effective_start_date);
```

## 7. Monitoring and Audit Rules

### 7.1 Data Lineage Tracking

**Rule 7.1.1: Transformation Audit Trail**
- **Purpose**: Track data lineage from Silver to Gold layer
- **Implementation**: Log all transformation activities
- **Rationale**: Ensures traceability and supports data governance

```sql
-- Data Lineage Tracking
INSERT INTO DB_POC_ZOOM.GOLD.Go_PIPELINE_AUDIT (
    pipeline_name, execution_start_time, execution_end_time,
    source_table_name, target_table_name, records_processed,
    records_success, execution_status, processed_by
)
VALUES (
    'DIMENSION_TRANSFORMATION',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'Si_USERS',
    'Go_USER_DIMENSION',
    (SELECT COUNT(*) FROM DB_POC_ZOOM.SILVER.Si_USERS),
    (SELECT COUNT(*) FROM DB_POC_ZOOM.GOLD.Go_USER_DIMENSION WHERE current_flag = TRUE),
    'SUCCESS',
    'ETL_PROCESS'
);
```

## 8. Implementation Schedule and Dependencies

### 8.1 Transformation Execution Order

1. **Go_TIME_DIMENSION**: Independent, can be loaded first
2. **Go_FEATURE_DIMENSION**: Depends on Si_FEATURE_USAGE analysis
3. **Go_USER_DIMENSION**: Depends on Si_USERS, implements SCD Type 2
4. **Go_LICENSE_DIMENSION**: Depends on Si_LICENSES and Go_USER_DIMENSION, implements SCD Type 2

### 8.2 Data Refresh Strategy

- **Go_TIME_DIMENSION**: Static, refresh annually
- **Go_FEATURE_DIMENSION**: Refresh when new features are introduced
- **Go_USER_DIMENSION**: Daily refresh with SCD Type 2 processing
- **Go_LICENSE_DIMENSION**: Daily refresh with SCD Type 2 processing

## 9. Success Criteria and Validation

### 9.1 Data Quality Metrics

1. **Completeness**: 99%+ of records have all required fields populated
2. **Accuracy**: 100% compliance with business rules and constraints
3. **Consistency**: 100% referential integrity across dimensions
4. **Timeliness**: Daily refresh completed within 2-hour window

### 9.2 Business Validation

1. **User Dimension**: Supports all Platform Usage & Adoption KPIs
2. **License Dimension**: Enables Revenue & License Management analysis
3. **Feature Dimension**: Facilitates feature adoption tracking
4. **Time Dimension**: Provides comprehensive temporal analysis capability

---

**Document Version Control:**
- Version 1.0: Initial transformation recommendations
- Created: 2024-12-19
- Next Review: 2024-12-26

**Approval Status:** Ready for Implementation Review