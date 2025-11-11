_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data mapping for Gold layer dimension tables from Silver to Gold layer transformation
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Gold Layer Dimension Table Data Mapping

## Overview

This document provides comprehensive data mapping specifications for transforming Silver layer tables to Gold layer dimension tables in the Zoom Platform Analytics System. The mappings incorporate Snowflake-specific optimizations, business rules, and dimensional modeling best practices to ensure high-quality, analytics-ready data in the Gold layer.

### Key Architectural Considerations

1. **Performance Optimization Strategies**
   - Clustering keys on frequently joined columns (DATE_KEY, USER_KEY)
   - Micro-partition optimization through proper data distribution
   - Query performance enhancement via surrogate key implementation
   - Efficient SCD Type 2 processing using MERGE INTO statements

2. **Scalability Design Patterns**
   - Auto-increment surrogate keys for unlimited growth
   - Partitioning strategies based on effective dates
   - Horizontal scaling through Snowflake's elastic compute
   - Stream-based change data capture for incremental processing

3. **Data Consistency Mechanisms**
   - MD5 hash-based business keys for consistent identification
   - Standardized data validation and cleansing rules
   - Comprehensive audit trails and error handling
   - Data quality scoring and validation status tracking

### Snowflake-Specific Implementation Notes

1. **Clustering Key Recommendations**
   - GO_DIM_USER: Cluster by (USER_KEY, EFFECTIVE_START_DATE)
   - GO_DIM_DATE: Cluster by (DATE_KEY, FISCAL_YEAR)
   - GO_DIM_FEATURE: Cluster by (FEATURE_KEY, FEATURE_CATEGORY)
   - GO_DIM_LICENSE: Cluster by (LICENSE_KEY, LICENSE_CATEGORY)
   - GO_DIM_MEETING: Cluster by (MEETING_KEY, TIME_OF_DAY_CATEGORY)
   - GO_DIM_SUPPORT_CATEGORY: Cluster by (SUPPORT_CATEGORY_KEY, PRIORITY_LEVEL)

2. **Partition Pruning Strategies**
   - Leverage DATE_KEY for time-based partition pruning
   - Use EFFECTIVE_START_DATE for SCD historical queries
   - Implement proper WHERE clause filtering on clustered columns

3. **Micro-partition Optimization**
   - Maintain optimal file sizes through proper data distribution
   - Use COPY INTO with file format optimization
   - Implement incremental loading patterns

4. **Query Performance Considerations**
   - Use surrogate keys for fast joins in fact tables
   - Implement proper indexing strategies
   - Optimize for BI tool query patterns

## Data Mapping Tables

### Dimension Table: GO_DIM_USER

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_USER | USER_KEY | Silver | SI_USERS | USER_ID | `MD5(UPPER(TRIM(USER_ID)))` - Generate consistent hash-based surrogate key |
| Gold | GO_DIM_USER | USER_DIM_ID | Silver | SI_USERS | - | `AUTOINCREMENT` - System-generated sequential ID for BI tools |
| Gold | GO_DIM_USER | USER_ID | Silver | SI_USERS | USER_ID | Direct mapping - Business key preservation |
| Gold | GO_DIM_USER | USER_NAME | Silver | SI_USERS | USER_NAME | `INITCAP(TRIM(USER_NAME))` - Standardize to proper case format |
| Gold | GO_DIM_USER | EMAIL_DOMAIN | Silver | SI_USERS | EMAIL | `UPPER(SUBSTRING(EMAIL, POSITION('@' IN EMAIL) + 1))` - Extract and standardize domain |
| Gold | GO_DIM_USER | COMPANY | Silver | SI_USERS | COMPANY | `INITCAP(TRIM(COMPANY))` - Standardize company name format |
| Gold | GO_DIM_USER | PLAN_TYPE | Silver | SI_USERS | PLAN_TYPE | `CASE WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC') THEN 'Basic' WHEN UPPER(PLAN_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Pro' WHEN UPPER(PLAN_TYPE) IN ('BUSINESS', 'ENTERPRISE') THEN 'Enterprise' ELSE 'Unknown' END` |
| Gold | GO_DIM_USER | PLAN_CATEGORY | Silver | SI_USERS | PLAN_TYPE | `CASE WHEN UPPER(PLAN_TYPE) = 'FREE' THEN 'Free' ELSE 'Paid' END` - High-level plan categorization |
| Gold | GO_DIM_USER | REGISTRATION_DATE | Silver | SI_USERS | LOAD_DATE | Direct mapping - User registration date |
| Gold | GO_DIM_USER | USER_STATUS | Silver | SI_USERS | VALIDATION_STATUS | `CASE WHEN VALIDATION_STATUS = 'PASSED' THEN 'Active' ELSE 'Inactive' END` |
| Gold | GO_DIM_USER | GEOGRAPHIC_REGION | Silver | SI_USERS | EMAIL | `CASE WHEN EMAIL_DOMAIN LIKE '%.com' THEN 'North America' WHEN EMAIL_DOMAIN LIKE '%.uk' OR EMAIL_DOMAIN LIKE '%.eu' THEN 'Europe' ELSE 'Unknown' END` - Derive from email domain |
| Gold | GO_DIM_USER | INDUSTRY_SECTOR | Silver | SI_USERS | COMPANY | `CASE WHEN UPPER(COMPANY) LIKE '%TECH%' OR UPPER(COMPANY) LIKE '%SOFTWARE%' THEN 'Technology' WHEN UPPER(COMPANY) LIKE '%BANK%' OR UPPER(COMPANY) LIKE '%FINANCE%' THEN 'Financial Services' ELSE 'Unknown' END` |
| Gold | GO_DIM_USER | USER_ROLE | Silver | SI_USERS | - | `'Standard User'` - Default role assignment |
| Gold | GO_DIM_USER | ACCOUNT_TYPE | Silver | SI_USERS | PLAN_TYPE | `CASE WHEN UPPER(PLAN_TYPE) = 'FREE' THEN 'Individual' ELSE 'Business' END` |
| Gold | GO_DIM_USER | LANGUAGE_PREFERENCE | Silver | SI_USERS | - | `'English'` - Default language preference |
| Gold | GO_DIM_USER | EFFECTIVE_START_DATE | Silver | SI_USERS | - | `CURRENT_DATE` - SCD Type 2 start date |
| Gold | GO_DIM_USER | EFFECTIVE_END_DATE | Silver | SI_USERS | - | `'9999-12-31'::DATE` - SCD Type 2 end date for current records |
| Gold | GO_DIM_USER | IS_CURRENT_RECORD | Silver | SI_USERS | - | `TRUE` - SCD Type 2 current record flag |
| Gold | GO_DIM_USER | LOAD_DATE | Silver | SI_USERS | - | `CURRENT_DATE` - Record load date |
| Gold | GO_DIM_USER | UPDATE_DATE | Silver | SI_USERS | - | `CURRENT_DATE` - Record update date |
| Gold | GO_DIM_USER | SOURCE_SYSTEM | Silver | SI_USERS | SOURCE_SYSTEM | Direct mapping - Source system identification |

### Dimension Table: GO_DIM_DATE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_DATE | DATE_KEY | Silver | - | - | `DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE)` - Generate date series from 2020-2030 |
| Gold | GO_DIM_DATE | DATE_ID | Silver | - | - | `AUTOINCREMENT` - System-generated sequential ID |
| Gold | GO_DIM_DATE | DATE_VALUE | Silver | - | - | `date_value` - Same as DATE_KEY |
| Gold | GO_DIM_DATE | YEAR | Silver | - | - | `YEAR(date_value)` - Extract year component |
| Gold | GO_DIM_DATE | QUARTER | Silver | - | - | `QUARTER(date_value)` - Extract quarter component |
| Gold | GO_DIM_DATE | MONTH | Silver | - | - | `MONTH(date_value)` - Extract month component |
| Gold | GO_DIM_DATE | MONTH_NAME | Silver | - | - | `MONTHNAME(date_value)` - Extract month name |
| Gold | GO_DIM_DATE | DAY_OF_MONTH | Silver | - | - | `DAY(date_value)` - Extract day of month |
| Gold | GO_DIM_DATE | DAY_OF_WEEK | Silver | - | - | `DAYOFWEEK(date_value)` - Extract day of week (1-7) |
| Gold | GO_DIM_DATE | DAY_NAME | Silver | - | - | `DAYNAME(date_value)` - Extract day name |
| Gold | GO_DIM_DATE | IS_WEEKEND | Silver | - | - | `CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END` - Weekend flag |
| Gold | GO_DIM_DATE | IS_HOLIDAY | Silver | - | - | `FALSE` - Default holiday flag (to be enhanced with holiday logic) |
| Gold | GO_DIM_DATE | FISCAL_YEAR | Silver | - | - | `CASE WHEN MONTH(date_value) >= 4 THEN YEAR(date_value) ELSE YEAR(date_value) - 1 END` - Fiscal year starting April 1st |
| Gold | GO_DIM_DATE | FISCAL_QUARTER | Silver | - | - | `CASE WHEN MONTH(date_value) IN (4, 5, 6) THEN 1 WHEN MONTH(date_value) IN (7, 8, 9) THEN 2 WHEN MONTH(date_value) IN (10, 11, 12) THEN 3 ELSE 4 END` |
| Gold | GO_DIM_DATE | WEEK_OF_YEAR | Silver | - | - | `WEEKOFYEAR(date_value)` - Extract week of year |
| Gold | GO_DIM_DATE | LOAD_DATE | Silver | - | - | `CURRENT_DATE` - Record load date |
| Gold | GO_DIM_DATE | UPDATE_DATE | Silver | - | - | `CURRENT_DATE` - Record update date |
| Gold | GO_DIM_DATE | SOURCE_SYSTEM | Silver | - | - | `'SYSTEM_GENERATED'` - System-generated dimension |

### Dimension Table: GO_DIM_FEATURE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_FEATURE | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `MD5(UPPER(TRIM(FEATURE_NAME)))` - Generate consistent hash-based surrogate key |
| Gold | GO_DIM_FEATURE | FEATURE_ID | Silver | SI_FEATURE_USAGE | - | `AUTOINCREMENT` - System-generated sequential ID |
| Gold | GO_DIM_FEATURE | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `INITCAP(TRIM(FEATURE_NAME))` - Standardize feature name format |
| Gold | GO_DIM_FEATURE | FEATURE_CATEGORY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN 'Collaboration' WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Recording' WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN 'Communication' WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN 'Advanced Meeting' WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'Engagement' ELSE 'General' END` |
| Gold | GO_DIM_FEATURE | FEATURE_TYPE | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN UPPER(FEATURE_NAME) LIKE '%BASIC%' THEN 'Core' WHEN UPPER(FEATURE_NAME) LIKE '%ADVANCED%' THEN 'Advanced' ELSE 'Standard' END` |
| Gold | GO_DIM_FEATURE | FEATURE_COMPLEXITY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' OR UPPER(FEATURE_NAME) LIKE '%POLL%' THEN 'High' WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN 'Medium' ELSE 'Low' END` |
| Gold | GO_DIM_FEATURE | IS_PREMIUM_FEATURE | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `CASE WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' OR UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_FEATURE | FEATURE_RELEASE_DATE | Silver | SI_FEATURE_USAGE | - | `'2020-01-01'::DATE` - Default release date |
| Gold | GO_DIM_FEATURE | FEATURE_STATUS | Silver | SI_FEATURE_USAGE | - | `'Active'` - Default feature status |
| Gold | GO_DIM_FEATURE | USAGE_FREQUENCY_CATEGORY | Silver | SI_FEATURE_USAGE | - | `'Medium'` - Default usage frequency |
| Gold | GO_DIM_FEATURE | FEATURE_DESCRIPTION | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `'Feature usage tracking for ' || FEATURE_NAME` - Generated description |
| Gold | GO_DIM_FEATURE | TARGET_USER_SEGMENT | Silver | SI_FEATURE_USAGE | - | `'All Users'` - Default target segment |
| Gold | GO_DIM_FEATURE | LOAD_DATE | Silver | SI_FEATURE_USAGE | - | `CURRENT_DATE` - Record load date |
| Gold | GO_DIM_FEATURE | UPDATE_DATE | Silver | SI_FEATURE_USAGE | - | `CURRENT_DATE` - Record update date |
| Gold | GO_DIM_FEATURE | SOURCE_SYSTEM | Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | Direct mapping - Source system identification |

### Dimension Table: GO_DIM_LICENSE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_LICENSE | LICENSE_KEY | Silver | SI_LICENSES | LICENSE_TYPE | `MD5(UPPER(TRIM(LICENSE_TYPE)))` - Generate consistent hash-based surrogate key |
| Gold | GO_DIM_LICENSE | LICENSE_ID | Silver | SI_LICENSES | - | `AUTOINCREMENT` - System-generated sequential ID |
| Gold | GO_DIM_LICENSE | LICENSE_TYPE | Silver | SI_LICENSES | LICENSE_TYPE | `INITCAP(TRIM(LICENSE_TYPE))` - Standardize license type format |
| Gold | GO_DIM_LICENSE | LICENSE_CATEGORY | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'Standard' WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'Professional' WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'Enterprise' ELSE 'Other' END` |
| Gold | GO_DIM_LICENSE | LICENSE_TIER | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'Tier 1' WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'Tier 2' WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'Tier 3' ELSE 'Tier 0' END` |
| Gold | GO_DIM_LICENSE | MAX_PARTICIPANTS | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 100 WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 500 WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 1000 ELSE 50 END` |
| Gold | GO_DIM_LICENSE | STORAGE_LIMIT_GB | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 5 WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 100 WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 1000 ELSE 1 END` |
| Gold | GO_DIM_LICENSE | RECORDING_LIMIT_HOURS | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 40 WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 100 WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 500 ELSE 0 END` |
| Gold | GO_DIM_LICENSE | ADMIN_FEATURES_INCLUDED | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_LICENSE | API_ACCESS_INCLUDED | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' OR UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_LICENSE | SSO_SUPPORT_INCLUDED | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_LICENSE | MONTHLY_PRICE | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 14.99 WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 19.99 WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 39.99 ELSE 0.00 END` |
| Gold | GO_DIM_LICENSE | ANNUAL_PRICE | Silver | SI_LICENSES | LICENSE_TYPE | `CASE WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 149.90 WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 199.90 WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 399.90 ELSE 0.00 END` |
| Gold | GO_DIM_LICENSE | LICENSE_BENEFITS | Silver | SI_LICENSES | LICENSE_TYPE | `'Standard license benefits for ' || LICENSE_TYPE` - Generated benefits description |
| Gold | GO_DIM_LICENSE | EFFECTIVE_START_DATE | Silver | SI_LICENSES | START_DATE | Direct mapping - License effective start date |
| Gold | GO_DIM_LICENSE | EFFECTIVE_END_DATE | Silver | SI_LICENSES | END_DATE | Direct mapping - License effective end date |
| Gold | GO_DIM_LICENSE | IS_CURRENT_RECORD | Silver | SI_LICENSES | - | `TRUE` - SCD Type 2 current record flag |
| Gold | GO_DIM_LICENSE | LOAD_DATE | Silver | SI_LICENSES | - | `CURRENT_DATE` - Record load date |
| Gold | GO_DIM_LICENSE | UPDATE_DATE | Silver | SI_LICENSES | - | `CURRENT_DATE` - Record update date |
| Gold | GO_DIM_LICENSE | SOURCE_SYSTEM | Silver | SI_LICENSES | SOURCE_SYSTEM | Direct mapping - Source system identification |

### Dimension Table: GO_DIM_MEETING

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_MEETING | MEETING_KEY | Silver | SI_MEETINGS | MEETING_ID | `MD5(UPPER(TRIM(MEETING_ID)))` - Generate consistent hash-based surrogate key |
| Gold | GO_DIM_MEETING | MEETING_ID | Silver | SI_MEETINGS | - | `AUTOINCREMENT` - System-generated sequential ID |
| Gold | GO_DIM_MEETING | MEETING_TYPE | Silver | SI_MEETINGS | - | `'Standard Meeting'` - Default meeting type |
| Gold | GO_DIM_MEETING | MEETING_CATEGORY | Silver | SI_MEETINGS | DURATION_MINUTES | `CASE WHEN DURATION_MINUTES <= 15 THEN 'Quick Sync' WHEN DURATION_MINUTES <= 60 THEN 'Standard Meeting' WHEN DURATION_MINUTES <= 120 THEN 'Extended Meeting' ELSE 'Long Session' END` |
| Gold | GO_DIM_MEETING | DURATION_CATEGORY | Silver | SI_MEETINGS | DURATION_MINUTES | `CASE WHEN DURATION_MINUTES <= 15 THEN 'Brief' WHEN DURATION_MINUTES <= 60 THEN 'Standard' WHEN DURATION_MINUTES <= 120 THEN 'Extended' ELSE 'Long' END` |
| Gold | GO_DIM_MEETING | PARTICIPANT_SIZE_CATEGORY | Silver | SI_MEETINGS | - | `'Unknown'` - To be enhanced with participant count logic |
| Gold | GO_DIM_MEETING | TIME_OF_DAY_CATEGORY | Silver | SI_MEETINGS | START_TIME | `CASE WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning' WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon' WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening' ELSE 'Night' END` |
| Gold | GO_DIM_MEETING | DAY_OF_WEEK | Silver | SI_MEETINGS | START_TIME | `DAYNAME(START_TIME)` - Extract day name from start time |
| Gold | GO_DIM_MEETING | IS_WEEKEND | Silver | SI_MEETINGS | START_TIME | `CASE WHEN DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE ELSE FALSE END` - Weekend meeting flag |
| Gold | GO_DIM_MEETING | IS_RECURRING | Silver | SI_MEETINGS | - | `FALSE` - Default recurring flag (to be enhanced) |
| Gold | GO_DIM_MEETING | MEETING_QUALITY_SCORE | Silver | SI_MEETINGS | DATA_QUALITY_SCORE | `CASE WHEN DATA_QUALITY_SCORE >= 90 THEN 9.0 WHEN DATA_QUALITY_SCORE >= 80 THEN 8.0 WHEN DATA_QUALITY_SCORE >= 70 THEN 7.0 ELSE 6.0 END` |
| Gold | GO_DIM_MEETING | TYPICAL_FEATURES_USED | Silver | SI_MEETINGS | - | `'Standard meeting features'` - Default features description |
| Gold | GO_DIM_MEETING | BUSINESS_PURPOSE | Silver | SI_MEETINGS | - | `'Business Meeting'` - Default business purpose |
| Gold | GO_DIM_MEETING | LOAD_DATE | Silver | SI_MEETINGS | - | `CURRENT_DATE` - Record load date |
| Gold | GO_DIM_MEETING | UPDATE_DATE | Silver | SI_MEETINGS | - | `CURRENT_DATE` - Record update date |
| Gold | GO_DIM_MEETING | SOURCE_SYSTEM | Silver | SI_MEETINGS | SOURCE_SYSTEM | Direct mapping - Source system identification |

### Dimension Table: GO_DIM_SUPPORT_CATEGORY

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY_KEY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `MD5(UPPER(TRIM(TICKET_TYPE)))` - Generate consistent hash-based surrogate key |
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY_ID | Silver | SI_SUPPORT_TICKETS | - | `AUTOINCREMENT` - System-generated sequential ID |
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `INITCAP(TRIM(TICKET_TYPE))` - Standardize ticket type format |
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_SUBCATEGORY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Issue' WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Inquiry' WHEN UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN 'Feature Request' ELSE 'General Support' END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | PRIORITY_LEVEL | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'Critical' WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'High' WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Medium' ELSE 'Low' END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | EXPECTED_RESOLUTION_TIME_HOURS | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0 WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0 WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0 ELSE 72.0 END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | REQUIRES_ESCALATION | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | SELF_SERVICE_AVAILABLE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' OR UPPER(TICKET_TYPE) LIKE '%FEATURE%' THEN TRUE ELSE FALSE END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | KNOWLEDGE_BASE_ARTICLES | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 15 WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 10 ELSE 5 END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | COMMON_RESOLUTION_STEPS | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `'Standard resolution steps for ' || TICKET_TYPE` - Generated resolution steps |
| Gold | GO_DIM_SUPPORT_CATEGORY | CUSTOMER_IMPACT_LEVEL | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'High' WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Medium' ELSE 'Low' END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | DEPARTMENT_RESPONSIBLE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'Technical Support' WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'Billing Department' ELSE 'Customer Success' END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | SLA_TARGET_HOURS | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 4.0 WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 24.0 WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 48.0 ELSE 72.0 END` |
| Gold | GO_DIM_SUPPORT_CATEGORY | LOAD_DATE | Silver | SI_SUPPORT_TICKETS | - | `CURRENT_DATE` - Record load date |
| Gold | GO_DIM_SUPPORT_CATEGORY | UPDATE_DATE | Silver | SI_SUPPORT_TICKETS | - | `CURRENT_DATE` - Record update date |
| Gold | GO_DIM_SUPPORT_CATEGORY | SOURCE_SYSTEM | Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | Direct mapping - Source system identification |

## Transformation Implementation Examples

### 1. Surrogate Key Generation Using Sequences

```sql
-- Create sequences for dimension tables
CREATE SEQUENCE SEQ_USER_DIM START = 1 INCREMENT = 1;
CREATE SEQUENCE SEQ_FEATURE_DIM START = 1 INCREMENT = 1;
CREATE SEQUENCE SEQ_LICENSE_DIM START = 1 INCREMENT = 1;
CREATE SEQUENCE SEQ_MEETING_DIM START = 1 INCREMENT = 1;
CREATE SEQUENCE SEQ_SUPPORT_CATEGORY_DIM START = 1 INCREMENT = 1;

-- Usage in transformation
SELECT 
    SEQ_USER_DIM.NEXTVAL AS USER_DIM_ID,
    MD5(USER_ID) AS USER_KEY,
    -- other columns
FROM SILVER.SI_USERS;
```

### 2. Slowly Changing Dimensions (SCD Type 2) Implementation

```sql
-- SCD Type 2 for GO_DIM_USER using MERGE INTO
MERGE INTO GOLD.GO_DIM_USER target
USING (
    SELECT 
        MD5(USER_ID) AS USER_KEY,
        USER_ID,
        INITCAP(TRIM(USER_NAME)) AS USER_NAME,
        -- other transformed columns
        MD5(CONCAT(USER_NAME, COMPANY, PLAN_TYPE)) AS ATTRIBUTE_HASH
    FROM SILVER.SI_USERS
    WHERE VALIDATION_STATUS = 'PASSED'
) source
ON target.USER_KEY = source.USER_KEY AND target.IS_CURRENT_RECORD = TRUE
WHEN MATCHED AND target.ATTRIBUTE_HASH <> source.ATTRIBUTE_HASH THEN
    UPDATE SET 
        IS_CURRENT_RECORD = FALSE,
        EFFECTIVE_END_DATE = CURRENT_DATE,
        UPDATE_DATE = CURRENT_DATE
WHEN NOT MATCHED THEN
    INSERT (
        USER_KEY, USER_ID, USER_NAME, 
        EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, IS_CURRENT_RECORD,
        LOAD_DATE, UPDATE_DATE
    )
    VALUES (
        source.USER_KEY, source.USER_ID, source.USER_NAME,
        CURRENT_DATE, '9999-12-31'::DATE, TRUE,
        CURRENT_DATE, CURRENT_DATE
    );
```

### 3. Change Data Capture Using Streams

```sql
-- Create streams for incremental processing
CREATE STREAM stream_si_users ON TABLE SILVER.SI_USERS;
CREATE STREAM stream_si_licenses ON TABLE SILVER.SI_LICENSES;
CREATE STREAM stream_si_feature_usage ON TABLE SILVER.SI_FEATURE_USAGE;

-- Process changes using streams
SELECT 
    MD5(USER_ID) AS USER_KEY,
    USER_ID,
    INITCAP(TRIM(USER_NAME)) AS USER_NAME,
    METADATA$ACTION,
    METADATA$ISUPDATE
FROM stream_si_users
WHERE METADATA$ACTION IN ('INSERT', 'UPDATE');
```

### 4. Task-Based Orchestration

```sql
-- Create tasks for automated dimension loading
CREATE TASK task_load_dim_user
    WAREHOUSE = WH_POC_ZOOM_DEV_XSMALL
    SCHEDULE = 'USING CRON 0 2 * * * UTC'
AS
    CALL sp_load_dim_user();

CREATE TASK task_load_dim_feature
    WAREHOUSE = WH_POC_ZOOM_DEV_XSMALL
    SCHEDULE = 'USING CRON 0 3 * * * UTC'
    AFTER task_load_dim_user
AS
    CALL sp_load_dim_feature();
```

## Data Quality and Validation Rules

### 1. Data Integrity Checks

1. **Null Value Handling**
   - Replace NULL USER_NAME with 'Unknown User'
   - Replace NULL COMPANY with 'Unknown Company'
   - Replace NULL EMAIL with 'unknown@domain.com'
   - Flag records with critical missing data using DATA_QUALITY_SCORE

2. **Data Type Validation**
   - Ensure DATE fields are valid dates within reasonable ranges
   - Validate EMAIL format using REGEXP_LIKE
   - Check numeric precision for PRICE fields
   - Validate BOOLEAN fields are TRUE/FALSE

3. **Business Rule Validation**
   - Validate PLAN_TYPE against allowed values ('Basic', 'Pro', 'Enterprise')
   - Check EFFECTIVE_START_DATE <= EFFECTIVE_END_DATE
   - Ensure LICENSE_TYPE matches predefined categories
   - Validate PRIORITY_LEVEL against standard values

### 2. Standardization Rules

1. **Text Standardization**
   - Apply INITCAP for names and company fields
   - TRIM whitespace from all text fields
   - UPPER case for codes and categories
   - Remove special characters using REGEXP_REPLACE

2. **Code Standardization**
   - Map legacy PLAN_TYPE codes to standard values
   - Standardize TICKET_TYPE categories
   - Apply consistent FEATURE_CATEGORY classifications
   - Implement business rule-based transformations

### 3. Enrichment Rules

1. **Derived Attributes**
   - Calculate USER_STATUS from VALIDATION_STATUS
   - Generate GEOGRAPHIC_REGION from EMAIL domain
   - Create INDUSTRY_SECTOR from COMPANY name patterns
   - Derive ACCOUNT_TYPE from PLAN_TYPE

2. **Lookup Enrichment**
   - Add pricing information based on LICENSE_TYPE
   - Include feature entitlements for each license
   - Append SLA targets for support categories
   - Generate resolution steps for ticket types

## Performance Optimization Strategies

### 1. Clustering Key Implementation

```sql
-- Optimize dimension tables with clustering keys
ALTER TABLE GOLD.GO_DIM_USER CLUSTER BY (USER_KEY, EFFECTIVE_START_DATE);
ALTER TABLE GOLD.GO_DIM_DATE CLUSTER BY (DATE_KEY, FISCAL_YEAR);
ALTER TABLE GOLD.GO_DIM_FEATURE CLUSTER BY (FEATURE_KEY, FEATURE_CATEGORY);
ALTER TABLE GOLD.GO_DIM_LICENSE CLUSTER BY (LICENSE_KEY, LICENSE_CATEGORY);
ALTER TABLE GOLD.GO_DIM_MEETING CLUSTER BY (MEETING_KEY, TIME_OF_DAY_CATEGORY);
ALTER TABLE GOLD.GO_DIM_SUPPORT_CATEGORY CLUSTER BY (SUPPORT_CATEGORY_KEY, PRIORITY_LEVEL);
```

### 2. Query Optimization Techniques

1. **Efficient Joins**
   - Use surrogate keys (USER_KEY, DATE_KEY) for fact table joins
   - Implement proper WHERE clause filtering on clustered columns
   - Leverage Snowflake's automatic query optimization

2. **Partition Pruning**
   - Filter on DATE_KEY for time-based queries
   - Use EFFECTIVE_START_DATE for historical analysis
   - Implement proper date range filtering

3. **Materialized Views**
   - Create materialized views for frequently accessed dimension combinations
   - Implement incremental refresh strategies
   - Optimize for common BI query patterns

## Monitoring and Maintenance

### 1. Data Quality Monitoring

1. **Quality Metrics Tracking**
   - Monitor completeness rates for critical fields
   - Track transformation success rates
   - Alert on data quality score degradation
   - Generate daily data quality reports

2. **Validation Reporting**
   - Track records processed vs. records failed
   - Monitor SCD processing performance
   - Report on business rule violations
   - Track source system data availability

### 2. Dimension Maintenance

1. **SCD Management**
   - Implement automated SCD Type 2 processing
   - Maintain historical accuracy for reporting
   - Manage effective date ranges properly
   - Handle late-arriving dimensions

2. **Reference Data Management**
   - Update lookup tables for categorization
   - Maintain code mappings and translations
   - Synchronize with source system changes
   - Version control reference data changes

## Conclusion

This comprehensive data mapping specification provides the foundation for transforming Silver layer data into Gold layer dimension tables optimized for analytics and BI reporting. The mappings incorporate Snowflake-specific features, business rules, and performance optimizations to ensure high-quality, scalable, and maintainable dimensional data structures.

All transformations include comprehensive error handling, data quality validation, and performance optimization to ensure reliable and efficient data processing in the Gold layer of the Zoom Platform Analytics System.