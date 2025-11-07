_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data mapping for Gold Layer Dimension tables from Silver to Gold layer in Zoom Platform Analytics System
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Gold Layer Dimension Table Data Mapping

## Overview

This document provides comprehensive data mapping specifications for transforming Silver layer data into Gold layer Dimension tables in the Zoom Platform Analytics System. The mapping incorporates Snowflake-specific features, business rules, and transformation logic to ensure optimal performance and data quality.

### Key Architectural Considerations

1. **Performance Optimization Strategies**
   - Leverage Snowflake's automatic clustering for large dimension tables
   - Implement efficient surrogate key generation using AUTOINCREMENT sequences
   - Design clustering keys based on query patterns and join conditions
   - Utilize micro-partition pruning for optimal query performance

2. **Scalability Design Patterns**
   - Implement Slowly Changing Dimensions (SCD) Type 2 for historical tracking
   - Use MERGE INTO statements for efficient upsert operations
   - Design for horizontal scaling with Snowflake's elastic compute
   - Implement incremental loading patterns for large datasets

3. **Data Consistency Mechanisms**
   - Apply comprehensive data validation and cleansing rules
   - Implement referential integrity checks through transformation logic
   - Use standardized data formats and business rule validations
   - Maintain audit trails and data lineage information

### Snowflake-Specific Implementation Notes

1. **Clustering Key Recommendations**
   - **GO_DIM_USER**: Cluster by (PLAN_CATEGORY, REGISTRATION_DATE)
   - **GO_DIM_DATE**: Cluster by (DATE_VALUE)
   - **GO_DIM_FEATURE**: Cluster by (FEATURE_CATEGORY, FEATURE_TYPE)
   - **GO_DIM_LICENSE**: Cluster by (LICENSE_CATEGORY, EFFECTIVE_START_DATE)
   - **GO_DIM_MEETING_TYPE**: Cluster by (MEETING_CATEGORY)
   - **GO_DIM_SUPPORT_CATEGORY**: Cluster by (PRIORITY_LEVEL, SUPPORT_CATEGORY)

2. **Partition Pruning Strategies**
   - Leverage date-based partitioning for time-sensitive dimensions
   - Use effective date ranges for SCD Type 2 implementations
   - Implement query patterns that maximize partition elimination

3. **Micro-partition Optimization**
   - Design transformation logic to maintain optimal micro-partition sizes
   - Use appropriate data types to minimize storage overhead
   - Implement compression-friendly data patterns

4. **Query Performance Considerations**
   - Use `QUALIFY` for window function filtering in SCD implementations
   - Leverage `TRY_CAST` for safe type conversions
   - Implement efficient join strategies using surrogate keys
   - Use `COALESCE` for null value handling and default assignments

---

## Data Mapping Tables

### Dimension Table: GO_DIM_DATE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_DATE | DATE_ID | Silver | Generated | N/A | `AUTOINCREMENT` surrogate key generation |
| Gold | GO_DIM_DATE | DATE_VALUE | Silver | Generated | N/A | `DATEADD(day, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE)` for date range generation |
| Gold | GO_DIM_DATE | YEAR | Silver | Generated | DATE_VALUE | `YEAR(DATE_VALUE)` |
| Gold | GO_DIM_DATE | QUARTER | Silver | Generated | DATE_VALUE | `QUARTER(DATE_VALUE)` |
| Gold | GO_DIM_DATE | MONTH | Silver | Generated | DATE_VALUE | `MONTH(DATE_VALUE)` |
| Gold | GO_DIM_DATE | MONTH_NAME | Silver | Generated | DATE_VALUE | `MONTHNAME(DATE_VALUE)` |
| Gold | GO_DIM_DATE | DAY_OF_MONTH | Silver | Generated | DATE_VALUE | `DAY(DATE_VALUE)` |
| Gold | GO_DIM_DATE | DAY_OF_WEEK | Silver | Generated | DATE_VALUE | `DAYOFWEEK(DATE_VALUE)` |
| Gold | GO_DIM_DATE | DAY_NAME | Silver | Generated | DATE_VALUE | `DAYNAME(DATE_VALUE)` |
| Gold | GO_DIM_DATE | IS_WEEKEND | Silver | Generated | DATE_VALUE | `CASE WHEN DAYOFWEEK(DATE_VALUE) IN (1, 7) THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_DATE | IS_HOLIDAY | Silver | Generated | DATE_VALUE | `FALSE` (default, to be updated with holiday logic) |
| Gold | GO_DIM_DATE | FISCAL_YEAR | Silver | Generated | DATE_VALUE | `CASE WHEN MONTH(DATE_VALUE) <= 6 THEN YEAR(DATE_VALUE) ELSE YEAR(DATE_VALUE) + 1 END` |
| Gold | GO_DIM_DATE | FISCAL_QUARTER | Silver | Generated | DATE_VALUE | `CASE WHEN MONTH(DATE_VALUE) <= 6 THEN QUARTER(DATE_VALUE) + 2 ELSE QUARTER(DATE_VALUE) - 2 END` |
| Gold | GO_DIM_DATE | WEEK_OF_YEAR | Silver | Generated | DATE_VALUE | `WEEKOFYEAR(DATE_VALUE)` |
| Gold | GO_DIM_DATE | QUARTER_NAME | Silver | Generated | DATE_VALUE | `'Q' || QUARTER(DATE_VALUE)` |
| Gold | GO_DIM_DATE | MONTH_YEAR | Silver | Generated | DATE_VALUE | `TO_CHAR(DATE_VALUE, 'MON-YYYY')` |
| Gold | GO_DIM_DATE | LOAD_DATE | Silver | Generated | N/A | `CURRENT_DATE` |
| Gold | GO_DIM_DATE | UPDATE_DATE | Silver | Generated | N/A | `CURRENT_DATE` |
| Gold | GO_DIM_DATE | SOURCE_SYSTEM | Silver | Generated | N/A | `'SYSTEM_GENERATED'` |

### Dimension Table: GO_DIM_USER

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_USER | USER_DIM_ID | Silver | SI_USERS | USER_ID | `AUTOINCREMENT` surrogate key generation |
| Gold | GO_DIM_USER | USER_NAME | Silver | SI_USERS | USER_NAME | `COALESCE(TRIM(UPPER(USER_NAME)), 'Unknown User')` |
| Gold | GO_DIM_USER | EMAIL_DOMAIN | Silver | SI_USERS | EMAIL | `COALESCE(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1), 'Unknown Domain')` where EMAIL contains '@' |
| Gold | GO_DIM_USER | COMPANY | Silver | SI_USERS | COMPANY | `COALESCE(TRIM(INITCAP(COMPANY)), 'Unknown Company')` |
| Gold | GO_DIM_USER | PLAN_TYPE | Silver | SI_USERS | PLAN_TYPE | `COALESCE(UPPER(TRIM(PLAN_TYPE)), 'Unknown Plan')` |
| Gold | GO_DIM_USER | PLAN_CATEGORY | Silver | SI_USERS | PLAN_TYPE | `CASE WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Basic' WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Professional' WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise' ELSE 'Other' END` |
| Gold | GO_DIM_USER | REGISTRATION_DATE | Silver | SI_USERS | LOAD_DATE | `COALESCE(LOAD_DATE, CURRENT_DATE)` |
| Gold | GO_DIM_USER | USER_STATUS | Silver | SI_USERS, SI_LICENSES | USER_ID, ASSIGNED_TO_USER_ID | `CASE WHEN l.LICENSE_ID IS NOT NULL AND l.END_DATE >= CURRENT_DATE THEN 'Active' WHEN l.LICENSE_ID IS NOT NULL AND l.END_DATE < CURRENT_DATE THEN 'Expired' ELSE 'Inactive' END` |
| Gold | GO_DIM_USER | GEOGRAPHIC_REGION | Silver | SI_USERS | EMAIL_DOMAIN | `'Unknown Region'` (default, to be enhanced with geo-mapping logic) |
| Gold | GO_DIM_USER | INDUSTRY_SECTOR | Silver | SI_USERS | COMPANY | `'Unknown Industry'` (default, to be enhanced with industry mapping) |
| Gold | GO_DIM_USER | USER_ROLE | Silver | SI_USERS | PLAN_TYPE | `CASE WHEN UPPER(PLAN_TYPE) LIKE '%ADMIN%' THEN 'Administrator' WHEN UPPER(PLAN_TYPE) LIKE '%ENTERPRISE%' THEN 'Enterprise User' ELSE 'Standard User' END` |
| Gold | GO_DIM_USER | ACCOUNT_TYPE | Silver | SI_USERS | PLAN_TYPE | `CASE WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Individual' ELSE 'Business' END` |
| Gold | GO_DIM_USER | TIME_ZONE | Silver | SI_USERS | N/A | `'UTC'` (default, to be enhanced with timezone detection) |
| Gold | GO_DIM_USER | LANGUAGE_PREFERENCE | Silver | SI_USERS | N/A | `'English'` (default, to be enhanced with language detection) |
| Gold | GO_DIM_USER | EFFECTIVE_START_DATE | Silver | SI_USERS | LOAD_DATE | `COALESCE(LOAD_DATE, CURRENT_DATE)` for SCD Type 2 |
| Gold | GO_DIM_USER | EFFECTIVE_END_DATE | Silver | SI_USERS | N/A | `'9999-12-31'::DATE` for current records in SCD Type 2 |
| Gold | GO_DIM_USER | IS_CURRENT_RECORD | Silver | SI_USERS | N/A | `TRUE` for current records in SCD Type 2 |
| Gold | GO_DIM_USER | LOAD_DATE | Silver | SI_USERS | LOAD_DATE | `COALESCE(LOAD_DATE, CURRENT_DATE)` |
| Gold | GO_DIM_USER | UPDATE_DATE | Silver | SI_USERS | UPDATE_DATE | `COALESCE(UPDATE_DATE, CURRENT_DATE)` |
| Gold | GO_DIM_USER | SOURCE_SYSTEM | Silver | SI_USERS | SOURCE_SYSTEM | `COALESCE(SOURCE_SYSTEM, 'SILVER.SI_USERS')` |

### Dimension Table: GO_DIM_FEATURE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_FEATURE | FEATURE_ID | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `AUTOINCREMENT` surrogate key generation |
| Gold | GO_DIM_FEATURE | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `COALESCE(TRIM(UPPER(FEATURE_NAME)), 'Unknown Feature')` from distinct values |
| Gold | GO_DIM_FEATURE | FEATURE_CATEGORY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Collaboration' WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording' WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Communication' WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Meeting Management' WHEN UPPER(FEATURE_NAME) LIKE '%WHITEBOARD%' THEN 'Collaboration' ELSE 'Other' END` |
| Gold | GO_DIM_FEATURE | FEATURE_TYPE | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN UPPER(FEATURE_NAME) IN ('SCREEN_SHARE', 'CHAT', 'AUDIO', 'VIDEO') THEN 'Core' ELSE 'Advanced' END` |
| Gold | GO_DIM_FEATURE | FEATURE_COMPLEXITY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN FEATURE_CATEGORY IN ('Communication', 'Core') THEN 'Low' WHEN FEATURE_CATEGORY IN ('Collaboration') THEN 'Medium' WHEN FEATURE_CATEGORY IN ('Recording', 'Meeting Management') THEN 'High' ELSE 'Medium' END` |
| Gold | GO_DIM_FEATURE | IS_PREMIUM_FEATURE | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN FEATURE_TYPE = 'Advanced' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_FEATURE | FEATURE_RELEASE_DATE | Silver | SI_FEATURE_USAGE | N/A | `'2020-01-01'::DATE` (default, to be enhanced with actual release dates) |
| Gold | GO_DIM_FEATURE | FEATURE_STATUS | Silver | SI_FEATURE_USAGE | N/A | `'Active'` (default) |
| Gold | GO_DIM_FEATURE | USAGE_FREQUENCY_CATEGORY | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `CASE WHEN AVG(USAGE_COUNT) > 100 THEN 'High' WHEN AVG(USAGE_COUNT) > 10 THEN 'Medium' ELSE 'Low' END` based on historical usage |
| Gold | GO_DIM_FEATURE | FEATURE_DESCRIPTION | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `FEATURE_NAME || ' functionality'` (default description) |
| Gold | GO_DIM_FEATURE | TARGET_USER_TYPE | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN FEATURE_TYPE = 'Core' THEN 'All Users' ELSE 'Advanced Users' END` |
| Gold | GO_DIM_FEATURE | PLATFORM_AVAILABILITY | Silver | SI_FEATURE_USAGE | N/A | `'All Platforms'` (default) |
| Gold | GO_DIM_FEATURE | LOAD_DATE | Silver | SI_FEATURE_USAGE | LOAD_DATE | `CURRENT_DATE` |
| Gold | GO_DIM_FEATURE | UPDATE_DATE | Silver | SI_FEATURE_USAGE | UPDATE_DATE | `CURRENT_DATE` |
| Gold | GO_DIM_FEATURE | SOURCE_SYSTEM | Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | `COALESCE(SOURCE_SYSTEM, 'SILVER.SI_FEATURE_USAGE')` |

### Dimension Table: GO_DIM_LICENSE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_LICENSE | LICENSE_ID | Silver | SI_LICENSES | LICENSE_TYPE | `AUTOINCREMENT` surrogate key generation |
| Gold | GO_DIM_LICENSE | LICENSE_TYPE | Silver | SI_LICENSES | LICENSE_TYPE | `COALESCE(TRIM(UPPER(LICENSE_TYPE)), 'Unknown License')` from distinct values |
| Gold | GO_DIM_LICENSE | LICENSE_CATEGORY | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'Basic' WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'Professional' WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' THEN 'Business' WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'Enterprise' ELSE 'Other' END` |
| Gold | GO_DIM_LICENSE | LICENSE_TIER | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'Tier 1' WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'Tier 2' WHEN UPPER(LICENSE_TYPE) LIKE '%BUSINESS%' THEN 'Tier 3' WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'Tier 4' ELSE 'Tier 0' END` |
| Gold | GO_DIM_LICENSE | MAX_PARTICIPANTS | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN LICENSE_TIER = 'Tier 1' THEN 100 WHEN LICENSE_TIER = 'Tier 2' THEN 500 WHEN LICENSE_TIER = 'Tier 3' THEN 1000 WHEN LICENSE_TIER = 'Tier 4' THEN 5000 ELSE 50 END` |
| Gold | GO_DIM_LICENSE | STORAGE_LIMIT_GB | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN LICENSE_TIER = 'Tier 1' THEN 5 WHEN LICENSE_TIER = 'Tier 2' THEN 25 WHEN LICENSE_TIER = 'Tier 3' THEN 100 WHEN LICENSE_TIER = 'Tier 4' THEN 1000 ELSE 1 END` |
| Gold | GO_DIM_LICENSE | RECORDING_LIMIT_HOURS | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN LICENSE_TIER = 'Tier 1' THEN 10 WHEN LICENSE_TIER = 'Tier 2' THEN 50 WHEN LICENSE_TIER = 'Tier 3' THEN 200 WHEN LICENSE_TIER = 'Tier 4' THEN 1000 ELSE 5 END` |
| Gold | GO_DIM_LICENSE | ADMIN_FEATURES_INCLUDED | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN LICENSE_TIER IN ('Tier 3', 'Tier 4') THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_LICENSE | API_ACCESS_INCLUDED | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN LICENSE_TIER = 'Tier 4' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_LICENSE | SSO_SUPPORT_INCLUDED | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN LICENSE_TIER IN ('Tier 3', 'Tier 4') THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_LICENSE | MONTHLY_PRICE | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN LICENSE_TIER = 'Tier 1' THEN 0.00 WHEN LICENSE_TIER = 'Tier 2' THEN 14.99 WHEN LICENSE_TIER = 'Tier 3' THEN 19.99 WHEN LICENSE_TIER = 'Tier 4' THEN 240.00 ELSE 0.00 END` |
| Gold | GO_DIM_LICENSE | ANNUAL_PRICE | Silver | SI_LICENSES | LICENSE_TYPE | `MONTHLY_PRICE * 12 * 0.9` (10% annual discount) |
| Gold | GO_DIM_LICENSE | LICENSE_DURATION_MONTHS | Silver | SI_LICENSES | START_DATE, END_DATE | `DATEDIFF(month, START_DATE, END_DATE)` |
| Gold | GO_DIM_LICENSE | CONCURRENT_MEETINGS_LIMIT | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN LICENSE_TIER = 'Tier 1' THEN 1 WHEN LICENSE_TIER = 'Tier 2' THEN 3 WHEN LICENSE_TIER = 'Tier 3' THEN 10 WHEN LICENSE_TIER = 'Tier 4' THEN 50 ELSE 1 END` |
| Gold | GO_DIM_LICENSE | EFFECTIVE_START_DATE | Silver | SI_LICENSES | START_DATE | `COALESCE(START_DATE, CURRENT_DATE)` for SCD Type 2 |
| Gold | GO_DIM_LICENSE | EFFECTIVE_END_DATE | Silver | SI_LICENSES | END_DATE | `COALESCE(END_DATE, '9999-12-31'::DATE)` for SCD Type 2 |
| Gold | GO_DIM_LICENSE | IS_CURRENT_RECORD | Silver | SI_LICENSES | END_DATE | `CASE WHEN END_DATE >= CURRENT_DATE OR END_DATE IS NULL THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_LICENSE | LOAD_DATE | Silver | SI_LICENSES | LOAD_DATE | `COALESCE(LOAD_DATE, CURRENT_DATE)` |
| Gold | GO_DIM_LICENSE | UPDATE_DATE | Silver | SI_LICENSES | UPDATE_DATE | `COALESCE(UPDATE_DATE, CURRENT_DATE)` |
| Gold | GO_DIM_LICENSE | SOURCE_SYSTEM | Silver | SI_LICENSES | SOURCE_SYSTEM | `COALESCE(SOURCE_SYSTEM, 'SILVER.SI_LICENSES')` |

### Dimension Table: GO_DIM_MEETING_TYPE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_MEETING_TYPE | MEETING_TYPE_ID | Silver | Generated | N/A | `AUTOINCREMENT` surrogate key generation |
| Gold | GO_DIM_MEETING_TYPE | MEETING_TYPE | Silver | Generated | N/A | Static values: 'Instant Meeting', 'Scheduled Meeting', 'Webinar', 'Personal Meeting Room' |
| Gold | GO_DIM_MEETING_TYPE | MEETING_CATEGORY | Silver | Generated | MEETING_TYPE | `CASE WHEN MEETING_TYPE LIKE '%WEBINAR%' THEN 'Webinar' WHEN MEETING_TYPE LIKE '%INSTANT%' THEN 'Instant' WHEN MEETING_TYPE LIKE '%SCHEDULED%' THEN 'Scheduled' ELSE 'Regular' END` |
| Gold | GO_DIM_MEETING_TYPE | DURATION_CATEGORY | Silver | SI_MEETINGS | DURATION_MINUTES | `CASE WHEN AVG(DURATION_MINUTES) <= 30 THEN 'Short' WHEN AVG(DURATION_MINUTES) <= 120 THEN 'Medium' ELSE 'Long' END` based on historical data |
| Gold | GO_DIM_MEETING_TYPE | PARTICIPANT_SIZE_CATEGORY | Silver | SI_PARTICIPANTS | MEETING_ID | `CASE WHEN AVG(participant_count) <= 5 THEN 'Small' WHEN AVG(participant_count) <= 25 THEN 'Medium' ELSE 'Large' END` |
| Gold | GO_DIM_MEETING_TYPE | TIME_OF_DAY_CATEGORY | Silver | SI_MEETINGS | START_TIME | `CASE WHEN HOUR(START_TIME) BETWEEN 6 AND 12 THEN 'Morning' WHEN HOUR(START_TIME) BETWEEN 12 AND 18 THEN 'Afternoon' ELSE 'Evening' END` |
| Gold | GO_DIM_MEETING_TYPE | IS_RECURRING_TYPE | Silver | Generated | MEETING_TYPE | `CASE WHEN MEETING_TYPE LIKE '%RECURRING%' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_MEETING_TYPE | REQUIRES_REGISTRATION | Silver | Generated | MEETING_TYPE | `CASE WHEN MEETING_TYPE = 'Webinar' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_MEETING_TYPE | SUPPORTS_RECORDING | Silver | Generated | MEETING_TYPE | `TRUE` (all meeting types support recording) |
| Gold | GO_DIM_MEETING_TYPE | MAX_PARTICIPANTS_ALLOWED | Silver | Generated | MEETING_TYPE | `CASE WHEN MEETING_TYPE = 'Webinar' THEN 10000 WHEN MEETING_TYPE = 'Scheduled Meeting' THEN 1000 ELSE 500 END` |
| Gold | GO_DIM_MEETING_TYPE | SECURITY_LEVEL | Silver | Generated | MEETING_TYPE | `CASE WHEN MEETING_TYPE = 'Personal Meeting Room' THEN 'High' ELSE 'Standard' END` |
| Gold | GO_DIM_MEETING_TYPE | MEETING_FORMAT | Silver | Generated | MEETING_TYPE | `CASE WHEN MEETING_TYPE = 'Webinar' THEN 'Broadcast' ELSE 'Interactive' END` |
| Gold | GO_DIM_MEETING_TYPE | LOAD_DATE | Silver | Generated | N/A | `CURRENT_DATE` |
| Gold | GO_DIM_MEETING_TYPE | UPDATE_DATE | Silver | Generated | N/A | `CURRENT_DATE` |
| Gold | GO_DIM_MEETING_TYPE | SOURCE_SYSTEM | Silver | Generated | N/A | `'SYSTEM_GENERATED'` |

### Dimension Table: GO_DIM_SUPPORT_CATEGORY

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY_ID | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `AUTOINCREMENT` surrogate key generation |
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `COALESCE(TRIM(UPPER(TICKET_TYPE)), 'General')` from distinct values |
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_SUBCATEGORY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical' WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing' WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request' WHEN UPPER(TICKET_TYPE) LIKE '%ACCOUNT%' THEN 'Account' ELSE 'General' END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | PRIORITY_LEVEL | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical' WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 'High' WHEN UPPER(TICKET_TYPE) LIKE '%MEDIUM%' THEN 'Medium' ELSE 'Low' END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | EXPECTED_RESOLUTION_HOURS | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN PRIORITY_LEVEL = 'Critical' THEN 4 WHEN PRIORITY_LEVEL = 'High' THEN 24 WHEN PRIORITY_LEVEL = 'Medium' THEN 72 WHEN PRIORITY_LEVEL = 'Low' THEN 168 ELSE 72 END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | REQUIRES_ESCALATION | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN PRIORITY_LEVEL IN ('Critical', 'High') THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | SELF_SERVICE_AVAILABLE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN SUPPORT_SUBCATEGORY IN ('General', 'Account') THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | SPECIALIST_REQUIRED | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN SUPPORT_SUBCATEGORY = 'Technical' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | CATEGORY_COMPLEXITY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN SUPPORT_SUBCATEGORY = 'Technical' THEN 'High' WHEN SUPPORT_SUBCATEGORY IN ('Feature Request', 'Billing') THEN 'Medium' ELSE 'Low' END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | CUSTOMER_IMPACT_LEVEL | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN PRIORITY_LEVEL = 'Critical' THEN 'High' WHEN PRIORITY_LEVEL = 'High' THEN 'Medium' ELSE 'Low' END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | RESOLUTION_METHOD | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN SELF_SERVICE_AVAILABLE THEN 'Self-Service' WHEN SPECIALIST_REQUIRED THEN 'Specialist Support' ELSE 'Standard Support' END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | KNOWLEDGE_BASE_ARTICLES | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN SUPPORT_SUBCATEGORY = 'General' THEN 50 WHEN SUPPORT_SUBCATEGORY = 'Technical' THEN 100 ELSE 25 END` (estimated count) |
| Gold | GO_DIM_SUPPORT_CATEGORY | LOAD_DATE | Silver | SI_SUPPORT_TICKETS | LOAD_DATE | `CURRENT_DATE` |
| Gold | GO_DIM_SUPPORT_CATEGORY | UPDATE_DATE | Silver | SI_SUPPORT_TICKETS | UPDATE_DATE | `CURRENT_DATE` |
| Gold | GO_DIM_SUPPORT_CATEGORY | SOURCE_SYSTEM | Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | `COALESCE(SOURCE_SYSTEM, 'SILVER.SI_SUPPORT_TICKETS')` |

---

## Transformation Implementation Guidelines

### 1. Data Quality and Validation Rules

#### 1.1 Null Value Handling
```sql
-- Standardized null handling across all dimensions
SELECT 
    COALESCE(source_field, 'Unknown Value') AS target_field
FROM source_table;
```

#### 1.2 Data Standardization
```sql
-- Text field standardization
SELECT 
    TRIM(UPPER(text_field)) AS standardized_field,
    TRIM(INITCAP(name_field)) AS proper_case_field
FROM source_table;
```

#### 1.3 Referential Integrity Validation
```sql
-- Validate user references in related tables
SELECT 
    s.USER_ID,
    CASE 
        WHEN u.USER_ID IS NULL THEN 'ORPHANED_RECORD'
        ELSE 'VALID'
    END AS VALIDATION_STATUS
FROM SILVER.SI_MEETINGS s
LEFT JOIN SILVER.SI_USERS u ON s.HOST_ID = u.USER_ID;
```

### 2. Slowly Changing Dimensions (SCD) Type 2 Implementation

#### 2.1 SCD Type 2 for GO_DIM_USER
```sql
-- SCD Type 2 implementation using MERGE INTO
MERGE INTO GOLD.GO_DIM_USER target
USING (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL_DOMAIN,
        COMPANY,
        PLAN_TYPE,
        PLAN_CATEGORY,
        CURRENT_DATE AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD
    FROM transformed_user_data
) source
ON target.USER_ID = source.USER_ID AND target.IS_CURRENT_RECORD = TRUE
WHEN MATCHED AND (
    target.USER_NAME <> source.USER_NAME OR
    target.PLAN_TYPE <> source.PLAN_TYPE OR
    target.COMPANY <> source.COMPANY
) THEN
    UPDATE SET 
        IS_CURRENT_RECORD = FALSE,
        EFFECTIVE_END_DATE = CURRENT_DATE
WHEN NOT MATCHED THEN
    INSERT (USER_ID, USER_NAME, EMAIL_DOMAIN, COMPANY, PLAN_TYPE, PLAN_CATEGORY, 
            EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, IS_CURRENT_RECORD)
    VALUES (source.USER_ID, source.USER_NAME, source.EMAIL_DOMAIN, source.COMPANY, 
            source.PLAN_TYPE, source.PLAN_CATEGORY, source.EFFECTIVE_START_DATE, 
            source.EFFECTIVE_END_DATE, source.IS_CURRENT_RECORD);
```

#### 2.2 SCD Type 2 for GO_DIM_LICENSE
```sql
-- SCD Type 2 implementation for license dimension
MERGE INTO GOLD.GO_DIM_LICENSE target
USING (
    SELECT 
        LICENSE_TYPE,
        LICENSE_CATEGORY,
        LICENSE_TIER,
        MAX_PARTICIPANTS,
        MONTHLY_PRICE,
        CURRENT_DATE AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD
    FROM transformed_license_data
) source
ON target.LICENSE_TYPE = source.LICENSE_TYPE AND target.IS_CURRENT_RECORD = TRUE
WHEN MATCHED AND (
    target.MAX_PARTICIPANTS <> source.MAX_PARTICIPANTS OR
    target.MONTHLY_PRICE <> source.MONTHLY_PRICE
) THEN
    UPDATE SET 
        IS_CURRENT_RECORD = FALSE,
        EFFECTIVE_END_DATE = CURRENT_DATE
WHEN NOT MATCHED THEN
    INSERT (LICENSE_TYPE, LICENSE_CATEGORY, LICENSE_TIER, MAX_PARTICIPANTS, 
            MONTHLY_PRICE, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, IS_CURRENT_RECORD)
    VALUES (source.LICENSE_TYPE, source.LICENSE_CATEGORY, source.LICENSE_TIER, 
            source.MAX_PARTICIPANTS, source.MONTHLY_PRICE, source.EFFECTIVE_START_DATE, 
            source.EFFECTIVE_END_DATE, source.IS_CURRENT_RECORD);
```

### 3. Performance Optimization Strategies

#### 3.1 Clustering Implementation
```sql
-- Apply clustering keys for optimal query performance
ALTER TABLE GOLD.GO_DIM_USER CLUSTER BY (PLAN_CATEGORY, REGISTRATION_DATE);
ALTER TABLE GOLD.GO_DIM_DATE CLUSTER BY (DATE_VALUE);
ALTER TABLE GOLD.GO_DIM_FEATURE CLUSTER BY (FEATURE_CATEGORY, FEATURE_TYPE);
ALTER TABLE GOLD.GO_DIM_LICENSE CLUSTER BY (LICENSE_CATEGORY, EFFECTIVE_START_DATE);
ALTER TABLE GOLD.GO_DIM_MEETING_TYPE CLUSTER BY (MEETING_CATEGORY);
ALTER TABLE GOLD.GO_DIM_SUPPORT_CATEGORY CLUSTER BY (PRIORITY_LEVEL, SUPPORT_CATEGORY);
```

#### 3.2 Incremental Loading Pattern
```sql
-- Incremental loading using change detection
SELECT *
FROM SILVER.SI_USERS
WHERE UPDATE_DATE > (
    SELECT COALESCE(MAX(UPDATE_DATE), '1900-01-01'::DATE)
    FROM GOLD.GO_DIM_USER
);
```

### 4. Data Lineage and Audit Trail

#### 4.1 Source System Tracking
```sql
-- Maintain comprehensive data lineage
SELECT 
    *,
    CURRENT_DATE AS LOAD_DATE,
    CURRENT_DATE AS UPDATE_DATE,
    'SILVER.SI_USERS' AS SOURCE_SYSTEM,
    'GOLD_DIM_TRANSFORMATION_V1.0' AS TRANSFORMATION_VERSION
FROM transformed_data;
```

#### 4.2 Data Quality Monitoring
```sql
-- Monitor data completeness and quality
SELECT 
    'GO_DIM_USER' AS TABLE_NAME,
    COUNT(*) AS TOTAL_RECORDS,
    COUNT(USER_NAME) AS NON_NULL_USER_NAME,
    COUNT(EMAIL_DOMAIN) AS NON_NULL_EMAIL_DOMAIN,
    ROUND((COUNT(USER_NAME) * 100.0 / COUNT(*)), 2) AS USER_NAME_COMPLETENESS_PCT,
    ROUND((COUNT(EMAIL_DOMAIN) * 100.0 / COUNT(*)), 2) AS EMAIL_DOMAIN_COMPLETENESS_PCT
FROM GOLD.GO_DIM_USER;
```

### 5. Error Handling and Data Validation

#### 5.1 Comprehensive Error Handling
```sql
-- Safe type conversions and error handling
SELECT 
    TRY_CAST(numeric_field AS NUMBER(10,2)) AS safe_numeric_field,
    TRY_TO_DATE(date_string, 'YYYY-MM-DD') AS safe_date_field,
    CASE 
        WHEN TRY_CAST(numeric_field AS NUMBER) IS NULL THEN 'INVALID_NUMBER'
        ELSE 'VALID'
    END AS validation_status
FROM source_table;
```

#### 5.2 Business Rule Validation
```sql
-- Validate business rules during transformation
SELECT 
    *,
    CASE 
        WHEN PLAN_TYPE IS NULL THEN 'MISSING_PLAN_TYPE'
        WHEN EMAIL NOT LIKE '%@%' THEN 'INVALID_EMAIL_FORMAT'
        WHEN COMPANY IS NULL OR TRIM(COMPANY) = '' THEN 'MISSING_COMPANY'
        ELSE 'VALID'
    END AS business_rule_validation
FROM SILVER.SI_USERS;
```

---

## Implementation Sequence

### 1. Pre-Execution Setup
1. **Validate GitHub credentials and access permissions**
2. **Verify Silver layer data availability and quality**
3. **Create necessary sequences for surrogate key generation**
4. **Set up error logging and monitoring infrastructure**

### 2. Dimension Population Sequence
1. **GO_DIM_DATE**: Generate comprehensive date dimension (2020-2030)
2. **GO_DIM_FEATURE**: Extract and categorize features from usage data
3. **GO_DIM_LICENSE**: Create license hierarchy with entitlements
4. **GO_DIM_MEETING_TYPE**: Generate meeting type classifications
5. **GO_DIM_SUPPORT_CATEGORY**: Categorize support ticket types
6. **GO_DIM_USER**: Implement SCD Type 2 for user dimension

### 3. Data Quality Validation
1. **Execute referential integrity checks**
2. **Validate business rule compliance**
3. **Monitor data completeness metrics**
4. **Generate data quality reports**

### 4. Performance Optimization
1. **Apply clustering keys to all dimension tables**
2. **Analyze query patterns and optimize accordingly**
3. **Implement incremental refresh strategies**
4. **Monitor and tune performance metrics**

### 5. Documentation and Monitoring
1. **Update data lineage documentation**
2. **Configure automated monitoring and alerting**
3. **Establish refresh schedules and maintenance windows**
4. **Create operational runbooks and troubleshooting guides**

---

## Success Criteria and Validation

### 1. Data Quality Metrics
- **Completeness**: >95% for critical fields (USER_NAME, FEATURE_NAME, LICENSE_TYPE)
- **Accuracy**: 100% referential integrity between dimensions and facts
- **Consistency**: Standardized formats across all text fields
- **Timeliness**: Daily refresh with <2 hour SLA

### 2. Performance Benchmarks
- **Query Response Time**: <5 seconds for standard dimension lookups
- **Load Performance**: Complete dimension refresh in <30 minutes
- **Storage Efficiency**: <10% storage overhead compared to Silver layer
- **Clustering Effectiveness**: >80% partition pruning for date-based queries

### 3. Business Rule Compliance
- **SCD Type 2**: Accurate historical tracking for user and license changes
- **Data Standardization**: Consistent categorization and classification
- **Business Logic**: Correct application of all transformation rules
- **Audit Trail**: Complete lineage and change tracking

This comprehensive data mapping ensures that Gold layer dimension tables are optimized for analytics, maintain high data quality, support efficient querying, and provide the foundation for robust business intelligence and reporting capabilities in the Zoom Platform Analytics System.