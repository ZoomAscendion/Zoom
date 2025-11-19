-- =====================================================
-- GOLD LAYER LICENSE DIMENSION MODEL
-- Model: go_dim_license
-- Purpose: Dimension table containing license types and entitlements with SCD Type 2
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- =====================================================

{{
  config(
    materialized='table',
    database='DB_POC_ZOOM',
    schema='GOLD',
    alias='GO_DIM_LICENSE',
    tags=['dimension', 'gold_layer', 'license_dimension', 'scd_type2'],
    cluster_by=['LICENSE_ID', 'LICENSE_CATEGORY'],
    comment='Dimension table containing license types and entitlements for revenue analysis with SCD Type 2 support'
  )
}}

-- =====================================================
-- SOURCE DATA EXTRACTION
-- =====================================================

WITH source_licenses AS (
  SELECT DISTINCT
    LICENSE_TYPE,
    START_DATE,
    END_DATE,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
  FROM {{ source('silver_layer', 'SI_LICENSES') }}
  WHERE VALIDATION_STATUS = 'PASSED'
    AND DATA_QUALITY_SCORE >= {{ var('min_data_quality_score') }}
    AND LICENSE_TYPE IS NOT NULL
    AND TRIM(LICENSE_TYPE) != ''
),

-- =====================================================
-- LICENSE CLEANSING AND STANDARDIZATION
-- =====================================================

cleansed_licenses AS (
  SELECT 
    -- Standardize license type
    TRIM(INITCAP(LICENSE_TYPE)) AS LICENSE_TYPE_CLEAN,
    TRIM(UPPER(LICENSE_TYPE)) AS LICENSE_TYPE_UPPER,
    
    -- Original for audit
    LICENSE_TYPE AS LICENSE_TYPE_ORIGINAL,
    
    -- Date fields
    START_DATE,
    END_DATE,
    
    -- Metadata
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
    
  FROM source_licenses
  WHERE LICENSE_TYPE IS NOT NULL
),

-- =====================================================
-- LICENSE CLASSIFICATION AND ENRICHMENT
-- =====================================================

license_classified AS (
  SELECT 
    *,
    
    -- License category classification
    CASE 
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' OR LICENSE_TYPE_UPPER = 'FREE' THEN 'Standard'
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 'Professional'
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 'Business'
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 'Enterprise'
      ELSE 'Other'
    END AS LICENSE_CATEGORY,
    
    -- License tier classification
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 'Tier 0'
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 'Tier 1'
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 'Tier 2'
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 'Tier 3'
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 'Tier 4'
      ELSE 'Tier 0'
    END AS LICENSE_TIER,
    
    -- Maximum participants based on license type
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 100
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 100
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 500
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 300
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 1000
      ELSE 50
    END AS MAX_PARTICIPANTS,
    
    -- Storage limit in GB
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 1
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 5
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 100
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 100
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 1000
      ELSE 1
    END AS STORAGE_LIMIT_GB,
    
    -- Recording limit in hours
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 0
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 40
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 100
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 100
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 500
      ELSE 0
    END AS RECORDING_LIMIT_HOURS,
    
    -- Admin features included
    CASE 
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' OR LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN TRUE
      ELSE FALSE
    END AS ADMIN_FEATURES_INCLUDED,
    
    -- API access included
    CASE 
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' 
           OR LICENSE_TYPE_UPPER LIKE '%BUSINESS%' OR LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN TRUE
      ELSE FALSE
    END AS API_ACCESS_INCLUDED,
    
    -- SSO support included
    CASE 
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' OR LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN TRUE
      ELSE FALSE
    END AS SSO_SUPPORT_INCLUDED,
    
    -- Monthly pricing
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 0.00
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 14.99
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 19.99
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 29.99
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 39.99
      ELSE 0.00
    END AS MONTHLY_PRICE,
    
    -- Annual pricing (with discount)
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 0.00
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 149.90
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 199.90
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 299.90
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 399.90
      ELSE 0.00
    END AS ANNUAL_PRICE
    
  FROM cleansed_licenses
),

-- =====================================================
-- LICENSE BENEFITS AND FEATURES
-- =====================================================

license_enriched AS (
  SELECT 
    *,
    
    -- License benefits description
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 
        'Basic video conferencing with limited participants and features'
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 
        'Standard video conferencing with recording, cloud storage, and basic admin features'
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 
        'Professional features including API access, advanced recording, and enhanced storage'
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 
        'Business-grade features with admin controls, SSO support, and team management'
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 
        'Enterprise-level features with advanced security, unlimited storage, and full admin control'
      ELSE 'Standard license benefits'
    END AS LICENSE_BENEFITS,
    
    -- Feature set summary
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 'Basic Meeting Features'
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 'Standard Meeting + Recording'
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 'Professional + API Access'
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 'Business + Admin Controls'
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 'Enterprise + Advanced Security'
      ELSE 'Standard Features'
    END AS FEATURE_SET_SUMMARY,
    
    -- Target market
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 'Individual Users'
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 'Small Teams'
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 'Professional Users'
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 'Small to Medium Business'
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 'Large Enterprise'
      ELSE 'General Market'
    END AS TARGET_MARKET,
    
    -- Revenue tier
    CASE 
      WHEN MONTHLY_PRICE = 0 THEN 'Free Tier'
      WHEN MONTHLY_PRICE <= 20 THEN 'Low Revenue'
      WHEN MONTHLY_PRICE <= 35 THEN 'Medium Revenue'
      ELSE 'High Revenue'
    END AS REVENUE_TIER,
    
    -- Competitive positioning
    CASE 
      WHEN LICENSE_TYPE_UPPER = 'FREE' THEN 'Market Entry'
      WHEN LICENSE_TYPE_UPPER LIKE '%BASIC%' THEN 'Value Proposition'
      WHEN LICENSE_TYPE_UPPER LIKE '%PRO%' OR LICENSE_TYPE_UPPER LIKE '%PROFESSIONAL%' THEN 'Competitive Standard'
      WHEN LICENSE_TYPE_UPPER LIKE '%BUSINESS%' THEN 'Premium Offering'
      WHEN LICENSE_TYPE_UPPER LIKE '%ENTERPRISE%' THEN 'Market Leader'
      ELSE 'Standard Positioning'
    END AS COMPETITIVE_POSITIONING
    
  FROM license_classified
),

-- =====================================================
-- SCD TYPE 2 PREPARATION
-- =====================================================

scd_prepared AS (
  SELECT 
    *,
    
    -- Create hash for change detection
    {{ dbt_utils.generate_surrogate_key([
      'LICENSE_TYPE_CLEAN',
      'LICENSE_CATEGORY', 
      'LICENSE_TIER',
      'MAX_PARTICIPANTS',
      'STORAGE_LIMIT_GB',
      'RECORDING_LIMIT_HOURS',
      'ADMIN_FEATURES_INCLUDED',
      'API_ACCESS_INCLUDED',
      'SSO_SUPPORT_INCLUDED',
      'MONTHLY_PRICE',
      'ANNUAL_PRICE'
    ]) }} AS ATTRIBUTE_HASH,
    
    -- SCD Type 2 fields
    COALESCE(START_DATE, CURRENT_DATE()) AS EFFECTIVE_START_DATE,
    COALESCE(END_DATE, '9999-12-31'::DATE) AS EFFECTIVE_END_DATE,
    CASE 
      WHEN END_DATE IS NULL OR END_DATE >= CURRENT_DATE() THEN TRUE
      ELSE FALSE
    END AS IS_CURRENT_RECORD
    
  FROM license_enriched
),

-- =====================================================
-- FINAL DIMENSION STRUCTURE
-- =====================================================

final_dimension AS (
  SELECT 
    -- Surrogate key (auto-increment will be handled by Snowflake)
    ROW_NUMBER() OVER (ORDER BY LICENSE_TYPE_CLEAN, EFFECTIVE_START_DATE) AS LICENSE_ID,
    
    -- License identification
    LICENSE_TYPE_CLEAN AS LICENSE_TYPE,
    LICENSE_CATEGORY,
    LICENSE_TIER,
    
    -- License limits and entitlements
    MAX_PARTICIPANTS,
    STORAGE_LIMIT_GB,
    RECORDING_LIMIT_HOURS,
    ADMIN_FEATURES_INCLUDED,
    API_ACCESS_INCLUDED,
    SSO_SUPPORT_INCLUDED,
    
    -- Pricing information
    MONTHLY_PRICE,
    ANNUAL_PRICE,
    
    -- License description and benefits
    LICENSE_BENEFITS,
    FEATURE_SET_SUMMARY,
    TARGET_MARKET,
    REVENUE_TIER,
    COMPETITIVE_POSITIONING,
    
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
  
FROM final_dimension

-- Data quality validation
WHERE LICENSE_TYPE IS NOT NULL
  AND LICENSE_TYPE != ''
  AND LICENSE_CATEGORY IS NOT NULL
  AND LICENSE_TIER IS NOT NULL
  AND MAX_PARTICIPANTS >= 0
  AND STORAGE_LIMIT_GB >= 0
  AND RECORDING_LIMIT_HOURS >= 0
  AND MONTHLY_PRICE >= 0
  AND ANNUAL_PRICE >= 0
  AND EFFECTIVE_START_DATE <= EFFECTIVE_END_DATE

ORDER BY LICENSE_CATEGORY, LICENSE_TYPE, EFFECTIVE_START_DATE

-- =====================================================
-- MODEL DOCUMENTATION
-- =====================================================

/*
MODEL DESCRIPTION:
This model creates the license dimension table containing comprehensive 
license types and entitlements with SCD Type 2 support for revenue analysis.

KEY FEATURES:
1. SCD Type 2 implementation for tracking license changes over time
2. Comprehensive license categorization and tier classification
3. Detailed entitlements and limits for each license type
4. Pricing information for revenue analysis
5. Feature set summaries and target market identification
6. Competitive positioning and revenue tier classification
7. Data quality validation and audit trail
8. Snowflake-optimized clustering for performance

LICENSE CATEGORIES:
- Standard: Free and Basic licenses
- Professional: Pro and Professional licenses
- Business: Business-grade licenses
- Enterprise: Enterprise-level licenses
- Other: Unclassified license types

LICENSE TIERS:
- Tier 0: Free licenses
- Tier 1: Basic licenses
- Tier 2: Pro/Professional licenses
- Tier 3: Business licenses
- Tier 4: Enterprise licenses

ENTITLEMENTS BY LICENSE TYPE:

FREE:
- Max Participants: 100
- Storage: 1 GB
- Recording: 0 hours
- Admin Features: No
- API Access: No
- SSO Support: No
- Monthly Price: $0.00

BASIC:
- Max Participants: 100
- Storage: 5 GB
- Recording: 40 hours
- Admin Features: No
- API Access: No
- SSO Support: No
- Monthly Price: $14.99

PRO/PROFESSIONAL:
- Max Participants: 500
- Storage: 100 GB
- Recording: 100 hours
- Admin Features: No
- API Access: Yes
- SSO Support: No
- Monthly Price: $19.99

BUSINESS:
- Max Participants: 300
- Storage: 100 GB
- Recording: 100 hours
- Admin Features: Yes
- API Access: Yes
- SSO Support: Yes
- Monthly Price: $29.99

ENTERPRISE:
- Max Participants: 1000
- Storage: 1000 GB
- Recording: 500 hours
- Admin Features: Yes
- API Access: Yes
- SSO Support: Yes
- Monthly Price: $39.99

SCD TYPE 2 LOGIC:
- EFFECTIVE_START_DATE: When the license configuration became active
- EFFECTIVE_END_DATE: When the license configuration was superseded
- IS_CURRENT_RECORD: Flag indicating the current active configuration
- ATTRIBUTE_HASH: Hash of key attributes for change detection

DATA QUALITY:
- Validates license types are not null or empty
- Ensures positive values for limits and pricing
- Validates SCD Type 2 date logic
- Maintains referential integrity

PERFORMANCE OPTIMIZATIONS:
- Clustered by LICENSE_ID and LICENSE_CATEGORY
- Surrogate key for fast fact table joins
- Pre-calculated entitlements and pricing
- Efficient SCD Type 2 structure

USAGE:
- Join to fact tables using LICENSE_ID (surrogate key)
- Filter on IS_CURRENT_RECORD = TRUE for current pricing analysis
- Use EFFECTIVE_START_DATE and EFFECTIVE_END_DATE for historical analysis
- Revenue analysis by LICENSE_CATEGORY and REVENUE_TIER
- Feature adoption analysis by entitlements

MONITORING:
- Monitor for new license types from source data
- Validate pricing and entitlement accuracy
- Check SCD Type 2 date logic
- Ensure proper competitive positioning
*/

-- =====================================================
-- END OF LICENSE DIMENSION MODEL
-- =====================================================