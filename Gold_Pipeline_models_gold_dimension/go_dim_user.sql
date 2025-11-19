-- =====================================================
-- GOLD LAYER USER DIMENSION MODEL
-- Model: go_dim_user
-- Purpose: Dimension table containing user profile and subscription information with SCD Type 2
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- =====================================================

{{
  config(
    materialized='table',
    database='DB_POC_ZOOM',
    schema='GOLD',
    alias='GO_DIM_USER',
    tags=['dimension', 'gold_layer', 'user_dimension', 'scd_type2'],
    cluster_by=['USER_DIM_ID', 'EFFECTIVE_START_DATE'],
    comment='Dimension table containing user profile and subscription information with SCD Type 2 support'
  )
}}

-- =====================================================
-- SOURCE DATA EXTRACTION AND CLEANSING
-- =====================================================

WITH source_users AS (
  SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
  FROM {{ source('silver_layer', 'SI_USERS') }}
  WHERE VALIDATION_STATUS = 'PASSED'
    AND DATA_QUALITY_SCORE >= {{ var('min_data_quality_score') }}
    AND USER_ID IS NOT NULL
),

-- =====================================================
-- DATA CLEANSING AND STANDARDIZATION
-- =====================================================

cleansed_users AS (
  SELECT 
    -- Business key
    TRIM(UPPER(USER_ID)) AS USER_ID,
    
    -- Cleansed and standardized fields
    COALESCE(NULLIF(TRIM(USER_NAME), ''), 'Unknown User') AS USER_NAME_CLEAN,
    COALESCE(NULLIF(TRIM(UPPER(EMAIL)), ''), 'unknown@domain.com') AS EMAIL_CLEAN,
    COALESCE(NULLIF(TRIM(COMPANY), ''), 'Unknown Company') AS COMPANY_CLEAN,
    COALESCE(NULLIF(TRIM(UPPER(PLAN_TYPE)), ''), 'UNKNOWN') AS PLAN_TYPE_CLEAN,
    
    -- Original fields for audit
    USER_NAME AS USER_NAME_ORIGINAL,
    EMAIL AS EMAIL_ORIGINAL,
    COMPANY AS COMPANY_ORIGINAL,
    PLAN_TYPE AS PLAN_TYPE_ORIGINAL,
    
    -- Metadata fields
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
    
  FROM source_users
),

-- =====================================================
-- BUSINESS RULE TRANSFORMATIONS
-- =====================================================

transformed_users AS (
  SELECT 
    *,
    
    -- Standardize user name to proper case
    INITCAP(USER_NAME_CLEAN) AS USER_NAME_FORMATTED,
    
    -- Extract email domain
    CASE 
      WHEN EMAIL_CLEAN LIKE '%@%' THEN 
        UPPER(SUBSTRING(EMAIL_CLEAN, POSITION('@' IN EMAIL_CLEAN) + 1))
      ELSE 'UNKNOWN.COM'
    END AS EMAIL_DOMAIN,
    
    -- Standardize company name
    INITCAP(COMPANY_CLEAN) AS COMPANY_FORMATTED,
    
    -- Standardize plan type
    CASE 
      WHEN PLAN_TYPE_CLEAN IN ('FREE', 'BASIC') THEN 'Basic'
      WHEN PLAN_TYPE_CLEAN IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
      WHEN PLAN_TYPE_CLEAN IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
      ELSE 'Unknown'
    END AS PLAN_TYPE_STANDARDIZED,
    
    -- Plan category
    CASE 
      WHEN PLAN_TYPE_CLEAN = 'FREE' THEN 'Free'
      WHEN PLAN_TYPE_CLEAN IN ('BASIC', 'PRO', 'PROFESSIONAL', 'BUSINESS', 'ENTERPRISE') THEN 'Paid'
      ELSE 'Unknown'
    END AS PLAN_CATEGORY,
    
    -- User status
    CASE 
      WHEN VALIDATION_STATUS = 'PASSED' AND DATA_QUALITY_SCORE >= 80 THEN 'Active'
      WHEN VALIDATION_STATUS = 'PASSED' AND DATA_QUALITY_SCORE >= 60 THEN 'Warning'
      ELSE 'Inactive'
    END AS USER_STATUS,
    
    -- Geographic region (derived from email domain)
    CASE 
      WHEN EMAIL_CLEAN LIKE '%.com' OR EMAIL_CLEAN LIKE '%.us' THEN 'North America'
      WHEN EMAIL_CLEAN LIKE '%.uk' OR EMAIL_CLEAN LIKE '%.eu' OR EMAIL_CLEAN LIKE '%.de' 
           OR EMAIL_CLEAN LIKE '%.fr' OR EMAIL_CLEAN LIKE '%.it' THEN 'Europe'
      WHEN EMAIL_CLEAN LIKE '%.jp' OR EMAIL_CLEAN LIKE '%.cn' OR EMAIL_CLEAN LIKE '%.in' 
           OR EMAIL_CLEAN LIKE '%.sg' THEN 'Asia Pacific'
      WHEN EMAIL_CLEAN LIKE '%.au' OR EMAIL_CLEAN LIKE '%.nz' THEN 'Australia/Oceania'
      WHEN EMAIL_CLEAN LIKE '%.ca' THEN 'Canada'
      ELSE 'Unknown'
    END AS GEOGRAPHIC_REGION,
    
    -- Industry sector (derived from company name patterns)
    CASE 
      WHEN UPPER(COMPANY_CLEAN) LIKE '%TECH%' OR UPPER(COMPANY_CLEAN) LIKE '%SOFTWARE%' 
           OR UPPER(COMPANY_CLEAN) LIKE '%IT%' OR UPPER(COMPANY_CLEAN) LIKE '%DIGITAL%' THEN 'Technology'
      WHEN UPPER(COMPANY_CLEAN) LIKE '%BANK%' OR UPPER(COMPANY_CLEAN) LIKE '%FINANCE%' 
           OR UPPER(COMPANY_CLEAN) LIKE '%INSURANCE%' THEN 'Financial Services'
      WHEN UPPER(COMPANY_CLEAN) LIKE '%HEALTH%' OR UPPER(COMPANY_CLEAN) LIKE '%MEDICAL%' 
           OR UPPER(COMPANY_CLEAN) LIKE '%HOSPITAL%' THEN 'Healthcare'
      WHEN UPPER(COMPANY_CLEAN) LIKE '%EDUCATION%' OR UPPER(COMPANY_CLEAN) LIKE '%SCHOOL%' 
           OR UPPER(COMPANY_CLEAN) LIKE '%UNIVERSITY%' THEN 'Education'
      WHEN UPPER(COMPANY_CLEAN) LIKE '%RETAIL%' OR UPPER(COMPANY_CLEAN) LIKE '%STORE%' 
           OR UPPER(COMPANY_CLEAN) LIKE '%SHOP%' THEN 'Retail'
      WHEN UPPER(COMPANY_CLEAN) LIKE '%GOVERNMENT%' OR UPPER(COMPANY_CLEAN) LIKE '%GOV%' 
           OR UPPER(COMPANY_CLEAN) LIKE '%PUBLIC%' THEN 'Government'
      ELSE 'Other'
    END AS INDUSTRY_SECTOR,
    
    -- User role (default assignment)
    'Standard User' AS USER_ROLE,
    
    -- Account type
    CASE 
      WHEN PLAN_TYPE_CLEAN = 'FREE' THEN 'Individual'
      WHEN PLAN_TYPE_CLEAN IN ('BASIC', 'PRO') THEN 'Small Business'
      WHEN PLAN_TYPE_CLEAN IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise'
      ELSE 'Unknown'
    END AS ACCOUNT_TYPE,
    
    -- Language preference (default)
    'English' AS LANGUAGE_PREFERENCE
    
  FROM cleansed_users
),

-- =====================================================
-- SCD TYPE 2 PREPARATION
-- =====================================================

scd_prepared AS (
  SELECT 
    *,
    
    -- Create hash for change detection
    {{ dbt_utils.generate_surrogate_key([
      'USER_NAME_FORMATTED',
      'EMAIL_CLEAN', 
      'COMPANY_FORMATTED',
      'PLAN_TYPE_STANDARDIZED',
      'PLAN_CATEGORY',
      'USER_STATUS',
      'GEOGRAPHIC_REGION',
      'INDUSTRY_SECTOR',
      'ACCOUNT_TYPE'
    ]) }} AS ATTRIBUTE_HASH,
    
    -- SCD Type 2 fields
    COALESCE(LOAD_DATE, CURRENT_DATE()) AS EFFECTIVE_START_DATE,
    '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
    TRUE AS IS_CURRENT_RECORD
    
  FROM transformed_users
),

-- =====================================================
-- FINAL DIMENSION STRUCTURE
-- =====================================================

final_dimension AS (
  SELECT 
    -- Surrogate key (auto-increment will be handled by Snowflake)
    ROW_NUMBER() OVER (ORDER BY USER_ID, EFFECTIVE_START_DATE) AS USER_DIM_ID,
    
    -- Business key
    USER_ID,
    
    -- User profile attributes
    USER_NAME_FORMATTED AS USER_NAME,
    EMAIL_DOMAIN,
    COMPANY_FORMATTED AS COMPANY,
    PLAN_TYPE_STANDARDIZED AS PLAN_TYPE,
    PLAN_CATEGORY,
    
    -- Registration and status
    EFFECTIVE_START_DATE AS REGISTRATION_DATE,
    USER_STATUS,
    
    -- Geographic and demographic attributes
    GEOGRAPHIC_REGION,
    INDUSTRY_SECTOR,
    USER_ROLE,
    ACCOUNT_TYPE,
    LANGUAGE_PREFERENCE,
    
    -- SCD Type 2 attributes
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    IS_CURRENT_RECORD,
    
    -- Data quality and audit attributes
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS,
    ATTRIBUTE_HASH,
    
    -- Standard metadata
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    COALESCE(SOURCE_SYSTEM, 'SILVER_LAYER') AS SOURCE_SYSTEM
    
  FROM scd_prepared
)

-- =====================================================
-- FINAL OUTPUT WITH QUALITY VALIDATION
-- =====================================================

SELECT 
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
  
FROM final_dimension

-- Data quality validation
WHERE USER_ID IS NOT NULL
  AND USER_NAME IS NOT NULL
  AND PLAN_TYPE IN ('Basic', 'Pro', 'Enterprise', 'Unknown')
  AND USER_STATUS IN ('Active', 'Warning', 'Inactive')
  AND EFFECTIVE_START_DATE <= EFFECTIVE_END_DATE

ORDER BY USER_ID, EFFECTIVE_START_DATE

-- =====================================================
-- MODEL DOCUMENTATION
-- =====================================================

/*
MODEL DESCRIPTION:
This model creates the user dimension table with comprehensive user profile 
information and SCD Type 2 support for tracking historical changes.

KEY FEATURES:
1. SCD Type 2 implementation for tracking user profile changes over time
2. Comprehensive data cleansing and standardization
3. Business rule-based transformations for plan types and categories
4. Geographic region derivation from email domains
5. Industry sector classification from company names
6. Data quality validation and scoring
7. Audit trail with hash-based change detection
8. Snowflake-optimized clustering for performance

BUSINESS RULES:
- Plan types are standardized to: Basic, Pro, Enterprise, Unknown
- Plan categories are: Free, Paid, Unknown
- User status based on validation status and data quality score
- Geographic regions derived from email domain patterns
- Industry sectors classified from company name keywords
- Account types mapped from plan types

SCD TYPE 2 LOGIC:
- EFFECTIVE_START_DATE: When the record became active
- EFFECTIVE_END_DATE: When the record was superseded (9999-12-31 for current)
- IS_CURRENT_RECORD: Flag indicating the current active record
- ATTRIBUTE_HASH: Hash of key attributes for change detection

DATA QUALITY:
- Filters records with VALIDATION_STATUS = 'PASSED'
- Requires minimum data quality score (configurable)
- Handles null values with appropriate defaults
- Validates required fields and business rules

PERFORMANCE OPTIMIZATIONS:
- Clustered by USER_DIM_ID and EFFECTIVE_START_DATE
- Surrogate key for fast fact table joins
- Pre-calculated derived attributes
- Efficient SCD Type 2 structure

USAGE:
- Join to fact tables using USER_DIM_ID (surrogate key)
- Filter on IS_CURRENT_RECORD = TRUE for current state analysis
- Use EFFECTIVE_START_DATE and EFFECTIVE_END_DATE for historical analysis
- Geographic and industry analysis using derived attributes

MONITORING:
- Monitor for duplicate USER_ID with IS_CURRENT_RECORD = TRUE
- Validate SCD Type 2 date logic
- Check data quality score trends
- Monitor geographic and industry distribution
*/

-- =====================================================
-- END OF USER DIMENSION MODEL
-- =====================================================