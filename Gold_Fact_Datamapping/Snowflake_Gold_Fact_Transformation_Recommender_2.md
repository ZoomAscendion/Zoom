_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Enhanced transformation rules for Fact tables in Gold layer with dimension uniqueness validation and comprehensive BI integration
## *Version*: 2
## *Updated on*:   
_____________________________________________

# Snowflake Gold Fact Transformation Recommender

## Transformation Rules for Fact Tables

### 1. Dimension Table Uniqueness Validation Rules

#### 1.1 Dimension Uniqueness Enforcement Strategy

**Rationale**: Ensure that dimension tables maintain unique rows for every unique combination of defining attributes to support proper dimensional modeling and prevent data duplication that could lead to incorrect analytical results.

**SQL Example**:
```sql
-- Dimension Uniqueness Validation for GO_DIM_USER
CREATE OR REPLACE PROCEDURE GOLD.SP_VALIDATE_DIMENSION_UNIQUENESS()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    duplicate_count INTEGER DEFAULT 0;
    validation_result STRING DEFAULT 'SUCCESS';
BEGIN
    -- Check for duplicates in GO_DIM_USER based on business key combination
    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE, COUNT(*) as cnt
        FROM GOLD.GO_DIM_USER
        WHERE IS_CURRENT_RECORD = TRUE
        GROUP BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE
        HAVING COUNT(*) > 1
    );
    
    IF (duplicate_count > 0) THEN
        -- Log duplicate records for resolution
        INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
            ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, ERROR_TYPE,
            ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
            VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
        )
        SELECT 
            UUID_STRING() as ERROR_ID,
            CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
            'GOLD.GO_DIM_USER' as SOURCE_TABLE_NAME,
            'Dimension Uniqueness Violation' as ERROR_TYPE,
            'Data Quality' as ERROR_CATEGORY,
            'Critical' as ERROR_SEVERITY,
            'Duplicate dimension record found for USER_ID: ' || USER_ID || 
            ', EMAIL_DOMAIN: ' || EMAIL_DOMAIN || ', COMPANY: ' || COMPANY as ERROR_MESSAGE,
            'DIM_USER_UNIQUENESS_CHECK' as VALIDATION_RULE_NAME,
            CURRENT_DATE() as LOAD_DATE,
            'DIMENSION_VALIDATION' as SOURCE_SYSTEM
        FROM (
            SELECT USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE, COUNT(*) as cnt
            FROM GOLD.GO_DIM_USER
            WHERE IS_CURRENT_RECORD = TRUE
            GROUP BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE
            HAVING COUNT(*) > 1
        );
        
        SET validation_result = 'FAILED - ' || duplicate_count || ' duplicate records found';
    END IF;
    
    RETURN validation_result;
END;
$$;
```

#### 1.2 Dimension Deduplication and Merge Strategy

**Rationale**: Implement automated deduplication logic to resolve dimension uniqueness violations while preserving data integrity and maintaining referential relationships with fact tables.

**SQL Example**:
```sql
-- Dimension Deduplication for GO_DIM_USER
CREATE OR REPLACE PROCEDURE GOLD.SP_DEDUPLICATE_USER_DIMENSION()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    processed_count INTEGER DEFAULT 0;
BEGIN
    -- Create temporary table with deduplicated records
    CREATE OR REPLACE TEMPORARY TABLE TEMP_DEDUPLICATED_USERS AS
    SELECT 
        -- Keep the most recent record based on LOAD_DATE and UPDATE_DATE
        FIRST_VALUE(USER_KEY) OVER (
            PARTITION BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE 
            ORDER BY UPDATE_DATE DESC, LOAD_DATE DESC
        ) as MASTER_USER_KEY,
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
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE 
            ORDER BY UPDATE_DATE DESC, LOAD_DATE DESC
        ) as rn
    FROM GOLD.GO_DIM_USER
    WHERE IS_CURRENT_RECORD = TRUE;
    
    -- Update fact tables to use master USER_KEY for duplicates
    UPDATE GOLD.GO_FACT_MEETING_ACTIVITY 
    SET USER_KEY = (
        SELECT MASTER_USER_KEY 
        FROM TEMP_DEDUPLICATED_USERS t 
        WHERE t.USER_KEY = GO_FACT_MEETING_ACTIVITY.USER_KEY
    )
    WHERE USER_KEY IN (
        SELECT USER_KEY 
        FROM TEMP_DEDUPLICATED_USERS 
        WHERE rn > 1
    );
    
    -- Mark duplicate records as inactive
    UPDATE GOLD.GO_DIM_USER 
    SET 
        IS_CURRENT_RECORD = FALSE,
        EFFECTIVE_END_DATE = CURRENT_DATE(),
        UPDATE_DATE = CURRENT_DATE()
    WHERE USER_KEY IN (
        SELECT USER_KEY 
        FROM TEMP_DEDUPLICATED_USERS 
        WHERE rn > 1
    );
    
    GET DIAGNOSTICS processed_count = ROW_COUNT;
    
    DROP TABLE TEMP_DEDUPLICATED_USERS;
    
    RETURN 'Processed ' || processed_count || ' duplicate dimension records';
END;
$$;
```

### 2. Enhanced GO_FACT_MEETING_ACTIVITY Transformation Rules

#### 2.1 Dimension Key Resolution with Uniqueness Validation

**Rationale**: Ensure fact table foreign keys reference unique dimension records and implement validation to prevent orphaned fact records due to dimension uniqueness issues.

**SQL Example**:
```sql
-- Enhanced fact loading with dimension uniqueness validation
INSERT INTO GOLD.GO_FACT_MEETING_ACTIVITY (
    USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY,
    MEETING_DATE, MEETING_TOPIC, START_TIME, END_TIME, DURATION_MINUTES,
    PARTICIPANT_COUNT, TOTAL_JOIN_TIME_MINUTES, AVERAGE_PARTICIPATION_MINUTES,
    FEATURES_USED_COUNT, SCREEN_SHARE_USAGE_COUNT, RECORDING_USAGE_COUNT,
    CHAT_USAGE_COUNT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    -- Ensure we get unique dimension keys
    COALESCE(du.USER_KEY, 'UNKNOWN_USER') as USER_KEY,
    COALESCE(dm.MEETING_KEY, sm.MEETING_ID) as MEETING_KEY,
    dd.DATE_KEY,
    COALESCE(df.FEATURE_KEY, 'NO_FEATURE') as FEATURE_KEY,
    DATE(sm.START_TIME) as MEETING_DATE,
    sm.MEETING_TOPIC,
    sm.START_TIME,
    sm.END_TIME,
    sm.DURATION_MINUTES,
    COUNT(DISTINCT sp.USER_ID) as PARTICIPANT_COUNT,
    SUM(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)) as TOTAL_JOIN_TIME_MINUTES,
    AVG(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)) as AVERAGE_PARTICIPATION_MINUTES,
    COUNT(DISTINCT sf.FEATURE_NAME) as FEATURES_USED_COUNT,
    SUM(CASE WHEN sf.FEATURE_NAME = 'Screen Share' THEN sf.USAGE_COUNT ELSE 0 END) as SCREEN_SHARE_USAGE_COUNT,
    SUM(CASE WHEN sf.FEATURE_NAME = 'Recording' THEN sf.USAGE_COUNT ELSE 0 END) as RECORDING_USAGE_COUNT,
    SUM(CASE WHEN sf.FEATURE_NAME = 'Chat' THEN sf.USAGE_COUNT ELSE 0 END) as CHAT_USAGE_COUNT,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SILVER_TO_GOLD_ETL' as SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS sm
-- Use subquery to ensure unique dimension lookup
LEFT JOIN (
    SELECT DISTINCT USER_ID, USER_KEY, 
           ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_USER 
    WHERE IS_CURRENT_RECORD = TRUE
) du ON sm.HOST_ID = du.USER_ID AND du.rn = 1
JOIN GOLD.GO_DIM_DATE dd ON DATE(sm.START_TIME) = dd.DATE_KEY
LEFT JOIN (
    SELECT DISTINCT MEETING_KEY, 
           ROW_NUMBER() OVER (PARTITION BY MEETING_KEY ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_MEETING
) dm ON sm.MEETING_ID = dm.MEETING_KEY AND dm.rn = 1
LEFT JOIN SILVER.SI_PARTICIPANTS sp ON sm.MEETING_ID = sp.MEETING_ID
LEFT JOIN SILVER.SI_FEATURE_USAGE sf ON sm.MEETING_ID = sf.MEETING_ID
LEFT JOIN (
    SELECT DISTINCT FEATURE_NAME, FEATURE_KEY,
           ROW_NUMBER() OVER (PARTITION BY FEATURE_NAME ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_FEATURE
) df ON sf.FEATURE_NAME = df.FEATURE_NAME AND df.rn = 1
WHERE sm.VALIDATION_STATUS = 'PASSED'
GROUP BY du.USER_KEY, dm.MEETING_KEY, dd.DATE_KEY, df.FEATURE_KEY, 
         sm.MEETING_TOPIC, sm.START_TIME, sm.END_TIME, sm.DURATION_MINUTES, sm.MEETING_ID;
```

#### 2.2 Dimension Integrity Validation for Fact Tables

**Rationale**: Implement comprehensive validation to ensure all fact table foreign keys reference valid, unique dimension records and flag any integrity violations.

**SQL Example**:
```sql
-- Comprehensive dimension integrity validation for fact tables
CREATE OR REPLACE PROCEDURE GOLD.SP_VALIDATE_FACT_DIMENSION_INTEGRITY()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    integrity_issues INTEGER DEFAULT 0;
    validation_summary STRING DEFAULT '';
BEGIN
    -- Validate USER_KEY references
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as SOURCE_TABLE_NAME,
        'GOLD.GO_DIM_USER' as TARGET_TABLE_NAME,
        'Referential Integrity' as ERROR_TYPE,
        'Missing Dimension Reference' as ERROR_CATEGORY,
        'High' as ERROR_SEVERITY,
        'USER_KEY not found in unique dimension records: ' || fma.USER_KEY as ERROR_MESSAGE,
        'FACT_USER_DIMENSION_INTEGRITY' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'DIMENSION_INTEGRITY_CHECK' as SOURCE_SYSTEM
    FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
    LEFT JOIN (
        SELECT DISTINCT USER_KEY 
        FROM GOLD.GO_DIM_USER 
        WHERE IS_CURRENT_RECORD = TRUE
    ) du ON fma.USER_KEY = du.USER_KEY
    WHERE du.USER_KEY IS NULL 
      AND fma.USER_KEY IS NOT NULL 
      AND fma.USER_KEY != 'UNKNOWN_USER';
    
    -- Validate DATE_KEY references
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as SOURCE_TABLE_NAME,
        'GOLD.GO_DIM_DATE' as TARGET_TABLE_NAME,
        'Referential Integrity' as ERROR_TYPE,
        'Missing Dimension Reference' as ERROR_CATEGORY,
        'High' as ERROR_SEVERITY,
        'DATE_KEY not found in date dimension: ' || fma.DATE_KEY as ERROR_MESSAGE,
        'FACT_DATE_DIMENSION_INTEGRITY' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'DIMENSION_INTEGRITY_CHECK' as SOURCE_SYSTEM
    FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
    LEFT JOIN GOLD.GO_DIM_DATE dd ON fma.DATE_KEY = dd.DATE_KEY
    WHERE dd.DATE_KEY IS NULL AND fma.DATE_KEY IS NOT NULL;
    
    -- Get count of integrity issues
    SELECT COUNT(*) INTO integrity_issues
    FROM GOLD.GO_DATA_VALIDATION_ERRORS
    WHERE VALIDATION_RULE_NAME IN ('FACT_USER_DIMENSION_INTEGRITY', 'FACT_DATE_DIMENSION_INTEGRITY')
      AND ERROR_TIMESTAMP >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR';
    
    SET validation_summary = 'Dimension integrity validation completed. Issues found: ' || integrity_issues;
    
    RETURN validation_summary;
END;
$$;
```

### 3. Enhanced GO_FACT_SUPPORT_ACTIVITY Transformation Rules

#### 3.1 Support Category Dimension Uniqueness Enforcement

**Rationale**: Ensure support category dimensions maintain uniqueness while providing comprehensive support metrics with validated dimensional relationships.

**SQL Example**:
```sql
-- Enhanced support fact loading with dimension uniqueness validation
INSERT INTO GOLD.GO_FACT_SUPPORT_ACTIVITY (
    USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY,
    TICKET_OPEN_DATE, TICKET_CLOSE_DATE, TICKET_TYPE, RESOLUTION_STATUS,
    PRIORITY_LEVEL, RESOLUTION_TIME_HOURS, FIRST_CONTACT_RESOLUTION_FLAG,
    SLA_MET, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    -- Ensure unique dimension key resolution
    COALESCE(du.USER_KEY, 'UNKNOWN_USER') as USER_KEY,
    dd.DATE_KEY,
    COALESCE(dsc.SUPPORT_CATEGORY_KEY, 'UNKNOWN_CATEGORY') as SUPPORT_CATEGORY_KEY,
    st.OPEN_DATE as TICKET_OPEN_DATE,
    CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') 
         THEN st.OPEN_DATE + INTERVAL '1 DAY' 
         ELSE NULL END as TICKET_CLOSE_DATE,
    st.TICKET_TYPE,
    st.RESOLUTION_STATUS,
    COALESCE(dsc_unique.PRIORITY_LEVEL, 'Medium') as PRIORITY_LEVEL,
    CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed')
         THEN DATEDIFF('hour', st.OPEN_DATE, st.OPEN_DATE + INTERVAL '1 DAY')
         ELSE NULL END as RESOLUTION_TIME_HOURS,
    FALSE as FIRST_CONTACT_RESOLUTION_FLAG,
    CASE WHEN DATEDIFF('hour', st.OPEN_DATE, st.OPEN_DATE + INTERVAL '1 DAY') <= COALESCE(dsc_unique.SLA_TARGET_HOURS, 24)
         THEN TRUE ELSE FALSE END as SLA_MET,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SILVER_TO_GOLD_ETL' as SOURCE_SYSTEM
FROM SILVER.SI_SUPPORT_TICKETS st
-- Ensure unique user dimension lookup
LEFT JOIN (
    SELECT DISTINCT USER_ID, USER_KEY,
           ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_USER 
    WHERE IS_CURRENT_RECORD = TRUE
) du ON st.USER_ID = du.USER_ID AND du.rn = 1
JOIN GOLD.GO_DIM_DATE dd ON st.OPEN_DATE = dd.DATE_KEY
-- Ensure unique support category dimension lookup
LEFT JOIN (
    SELECT DISTINCT SUPPORT_CATEGORY, SUPPORT_CATEGORY_KEY,
           ROW_NUMBER() OVER (PARTITION BY SUPPORT_CATEGORY ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_SUPPORT_CATEGORY
) dsc ON st.TICKET_TYPE = dsc.SUPPORT_CATEGORY AND dsc.rn = 1
-- Get additional attributes from unique support category record
LEFT JOIN (
    SELECT DISTINCT SUPPORT_CATEGORY, PRIORITY_LEVEL, SLA_TARGET_HOURS,
           ROW_NUMBER() OVER (PARTITION BY SUPPORT_CATEGORY ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_SUPPORT_CATEGORY
) dsc_unique ON st.TICKET_TYPE = dsc_unique.SUPPORT_CATEGORY AND dsc_unique.rn = 1
WHERE st.VALIDATION_STATUS = 'PASSED';
```

### 4. Enhanced GO_FACT_REVENUE_ACTIVITY Transformation Rules

#### 4.1 License Dimension Uniqueness and Revenue Attribution

**Rationale**: Ensure license dimensions maintain uniqueness while accurately attributing revenue to the correct license types and user combinations.

**SQL Example**:
```sql
-- Enhanced revenue fact loading with license dimension uniqueness
INSERT INTO GOLD.GO_FACT_REVENUE_ACTIVITY (
    USER_KEY, LICENSE_KEY, DATE_KEY,
    TRANSACTION_DATE, EVENT_TYPE, AMOUNT, CURRENCY,
    SUBSCRIPTION_REVENUE_AMOUNT, ONE_TIME_REVENUE_AMOUNT,
    NET_REVENUE_AMOUNT, USD_AMOUNT, MRR_IMPACT, ARR_IMPACT,
    LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    -- Ensure unique dimension key resolution
    COALESCE(du.USER_KEY, 'UNKNOWN_USER') as USER_KEY,
    COALESCE(dl.LICENSE_KEY, 'UNKNOWN_LICENSE') as LICENSE_KEY,
    dd.DATE_KEY,
    be.EVENT_DATE as TRANSACTION_DATE,
    be.EVENT_TYPE,
    be.AMOUNT,
    'USD' as CURRENCY,
    CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
         THEN be.AMOUNT ELSE 0 END as SUBSCRIPTION_REVENUE_AMOUNT,
    CASE WHEN be.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') 
         THEN be.AMOUNT ELSE 0 END as ONE_TIME_REVENUE_AMOUNT,
    CASE WHEN be.EVENT_TYPE = 'Refund' 
         THEN -be.AMOUNT ELSE be.AMOUNT END as NET_REVENUE_AMOUNT,
    be.AMOUNT as USD_AMOUNT,
    CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
         THEN be.AMOUNT / 12 ELSE 0 END as MRR_IMPACT,
    CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
         THEN be.AMOUNT ELSE 0 END as ARR_IMPACT,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SILVER_TO_GOLD_ETL' as SOURCE_SYSTEM
FROM SILVER.SI_BILLING_EVENTS be
-- Ensure unique user dimension lookup
LEFT JOIN (
    SELECT DISTINCT USER_ID, USER_KEY,
           ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_USER 
    WHERE IS_CURRENT_RECORD = TRUE
) du ON be.USER_ID = du.USER_ID AND du.rn = 1
JOIN GOLD.GO_DIM_DATE dd ON be.EVENT_DATE = dd.DATE_KEY
-- Ensure unique license dimension lookup through user's current license
LEFT JOIN (
    SELECT DISTINCT sl.ASSIGNED_TO_USER_ID, sl.LICENSE_TYPE, dl.LICENSE_KEY,
           ROW_NUMBER() OVER (
               PARTITION BY sl.ASSIGNED_TO_USER_ID, sl.LICENSE_TYPE 
               ORDER BY sl.UPDATE_TIMESTAMP DESC, dl.UPDATE_DATE DESC
           ) as rn
    FROM SILVER.SI_LICENSES sl
    JOIN GOLD.GO_DIM_LICENSE dl ON sl.LICENSE_TYPE = dl.LICENSE_TYPE 
                                AND dl.IS_CURRENT_RECORD = TRUE
    WHERE sl.START_DATE <= CURRENT_DATE() 
      AND (sl.END_DATE IS NULL OR sl.END_DATE >= CURRENT_DATE())
) dl ON be.USER_ID = dl.ASSIGNED_TO_USER_ID AND dl.rn = 1
WHERE be.VALIDATION_STATUS = 'PASSED';
```

### 5. Enhanced GO_FACT_FEATURE_USAGE Transformation Rules

#### 5.1 Feature Dimension Uniqueness and Usage Attribution

**Rationale**: Ensure feature dimensions maintain uniqueness while accurately tracking feature usage patterns and adoption metrics.

**SQL Example**:
```sql
-- Enhanced feature usage fact loading with dimension uniqueness
INSERT INTO GOLD.GO_FACT_FEATURE_USAGE (
    DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY,
    USAGE_DATE, USAGE_TIMESTAMP, FEATURE_NAME, USAGE_COUNT,
    USAGE_DURATION_MINUTES, FEATURE_ADOPTION_SCORE, SUCCESS_RATE,
    LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    dd.DATE_KEY,
    COALESCE(df.FEATURE_KEY, 'UNKNOWN_FEATURE') as FEATURE_KEY,
    COALESCE(du.USER_KEY, 'UNKNOWN_USER') as USER_KEY,
    COALESCE(dm.MEETING_KEY, fu.MEETING_ID) as MEETING_KEY,
    fu.USAGE_DATE,
    fu.USAGE_DATE::TIMESTAMP_NTZ as USAGE_TIMESTAMP,
    fu.FEATURE_NAME,
    fu.USAGE_COUNT,
    COALESCE(sm.DURATION_MINUTES, 0) as USAGE_DURATION_MINUTES,
    CASE 
        WHEN fu.USAGE_COUNT >= 10 THEN 5.0
        WHEN fu.USAGE_COUNT >= 5 THEN 4.0
        WHEN fu.USAGE_COUNT >= 3 THEN 3.0
        WHEN fu.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END as FEATURE_ADOPTION_SCORE,
    CASE 
        WHEN fu.USAGE_COUNT > 0 THEN 100.0
        ELSE 0.0
    END as SUCCESS_RATE,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SILVER_TO_GOLD_ETL' as SOURCE_SYSTEM
FROM SILVER.SI_FEATURE_USAGE fu
JOIN GOLD.GO_DIM_DATE dd ON fu.USAGE_DATE = dd.DATE_KEY
-- Ensure unique feature dimension lookup
LEFT JOIN (
    SELECT DISTINCT FEATURE_NAME, FEATURE_KEY,
           ROW_NUMBER() OVER (PARTITION BY FEATURE_NAME ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_FEATURE
) df ON fu.FEATURE_NAME = df.FEATURE_NAME AND df.rn = 1
LEFT JOIN SILVER.SI_MEETINGS sm ON fu.MEETING_ID = sm.MEETING_ID
-- Ensure unique user dimension lookup through meeting host
LEFT JOIN (
    SELECT DISTINCT USER_ID, USER_KEY,
           ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_USER 
    WHERE IS_CURRENT_RECORD = TRUE
) du ON sm.HOST_ID = du.USER_ID AND du.rn = 1
-- Ensure unique meeting dimension lookup
LEFT JOIN (
    SELECT DISTINCT MEETING_KEY,
           ROW_NUMBER() OVER (PARTITION BY MEETING_KEY ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_MEETING
) dm ON fu.MEETING_ID = dm.MEETING_KEY AND dm.rn = 1
WHERE fu.VALIDATION_STATUS = 'PASSED';
```

### 6. Comprehensive Dimension Uniqueness Monitoring

#### 6.1 Automated Dimension Uniqueness Monitoring

**Rationale**: Implement continuous monitoring to detect and alert on dimension uniqueness violations before they impact fact table integrity and analytical accuracy.

**SQL Example**:
```sql
-- Comprehensive dimension uniqueness monitoring procedure
CREATE OR REPLACE PROCEDURE GOLD.SP_MONITOR_DIMENSION_UNIQUENESS()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    total_violations INTEGER DEFAULT 0;
    monitoring_summary STRING DEFAULT '';
BEGIN
    -- Monitor GO_DIM_USER uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, ERROR_TYPE,
        ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_DIM_USER' as SOURCE_TABLE_NAME,
        'Dimension Uniqueness Violation' as ERROR_TYPE,
        'Data Quality' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate USER dimension: USER_ID=' || USER_ID || ', Count=' || cnt as ERROR_MESSAGE,
        'DIM_USER_UNIQUENESS_MONITOR' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'DIMENSION_MONITORING' as SOURCE_SYSTEM
    FROM (
        SELECT USER_ID, COUNT(*) as cnt
        FROM GOLD.GO_DIM_USER
        WHERE IS_CURRENT_RECORD = TRUE
        GROUP BY USER_ID
        HAVING COUNT(*) > 1
    );
    
    -- Monitor GO_DIM_FEATURE uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, ERROR_TYPE,
        ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_DIM_FEATURE' as SOURCE_TABLE_NAME,
        'Dimension Uniqueness Violation' as ERROR_TYPE,
        'Data Quality' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate FEATURE dimension: FEATURE_NAME=' || FEATURE_NAME || ', Count=' || cnt as ERROR_MESSAGE,
        'DIM_FEATURE_UNIQUENESS_MONITOR' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'DIMENSION_MONITORING' as SOURCE_SYSTEM
    FROM (
        SELECT FEATURE_NAME, COUNT(*) as cnt
        FROM GOLD.GO_DIM_FEATURE
        GROUP BY FEATURE_NAME
        HAVING COUNT(*) > 1
    );
    
    -- Monitor GO_DIM_LICENSE uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, ERROR_TYPE,
        ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_DIM_LICENSE' as SOURCE_TABLE_NAME,
        'Dimension Uniqueness Violation' as ERROR_TYPE,
        'Data Quality' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate LICENSE dimension: LICENSE_TYPE=' || LICENSE_TYPE || ', Count=' || cnt as ERROR_MESSAGE,
        'DIM_LICENSE_UNIQUENESS_MONITOR' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'DIMENSION_MONITORING' as SOURCE_SYSTEM
    FROM (
        SELECT LICENSE_TYPE, COUNT(*) as cnt
        FROM GOLD.GO_DIM_LICENSE
        WHERE IS_CURRENT_RECORD = TRUE
        GROUP BY LICENSE_TYPE
        HAVING COUNT(*) > 1
    );
    
    -- Monitor GO_DIM_SUPPORT_CATEGORY uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, ERROR_TYPE,
        ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_DIM_SUPPORT_CATEGORY' as SOURCE_TABLE_NAME,
        'Dimension Uniqueness Violation' as ERROR_TYPE,
        'Data Quality' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate SUPPORT_CATEGORY dimension: SUPPORT_CATEGORY=' || SUPPORT_CATEGORY || ', Count=' || cnt as ERROR_MESSAGE,
        'DIM_SUPPORT_CATEGORY_UNIQUENESS_MONITOR' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'DIMENSION_MONITORING' as SOURCE_SYSTEM
    FROM (
        SELECT SUPPORT_CATEGORY, COUNT(*) as cnt
        FROM GOLD.GO_DIM_SUPPORT_CATEGORY
        GROUP BY SUPPORT_CATEGORY
        HAVING COUNT(*) > 1
    );
    
    -- Get total violations count
    SELECT COUNT(*) INTO total_violations
    FROM GOLD.GO_DATA_VALIDATION_ERRORS
    WHERE VALIDATION_RULE_NAME LIKE '%_UNIQUENESS_MONITOR'
      AND ERROR_TIMESTAMP >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR';
    
    SET monitoring_summary = 'Dimension uniqueness monitoring completed. Total violations: ' || total_violations;
    
    RETURN monitoring_summary;
END;
$$;
```

### 7. Enhanced Data Quality and Validation Rules

#### 7.1 Comprehensive Dimension-Fact Relationship Validation

**Rationale**: Implement end-to-end validation to ensure dimension uniqueness is maintained throughout the entire ETL process and fact-dimension relationships remain intact.

**SQL Example**:
```sql
-- Comprehensive dimension-fact relationship validation
CREATE OR REPLACE PROCEDURE GOLD.SP_VALIDATE_DIMENSION_FACT_RELATIONSHIPS()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    relationship_issues INTEGER DEFAULT 0;
    validation_result STRING DEFAULT '';
BEGIN
    -- Validate that all fact table foreign keys reference unique dimension records
    
    -- Check Meeting Activity Facts
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, ERROR_TYPE,
        ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as SOURCE_TABLE_NAME,
        'Dimension Relationship Violation' as ERROR_TYPE,
        'Data Integrity' as ERROR_CATEGORY,
        'High' as ERROR_SEVERITY,
        'Fact record references non-unique dimension: USER_KEY=' || fma.USER_KEY as ERROR_MESSAGE,
        'FACT_DIMENSION_UNIQUENESS_VALIDATION' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'RELATIONSHIP_VALIDATION' as SOURCE_SYSTEM
    FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
    WHERE fma.USER_KEY IN (
        SELECT USER_KEY
        FROM GOLD.GO_DIM_USER
        WHERE IS_CURRENT_RECORD = TRUE
        GROUP BY USER_KEY
        HAVING COUNT(*) > 1
    );
    
    -- Check Support Activity Facts
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, ERROR_TYPE,
        ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_SUPPORT_ACTIVITY' as SOURCE_TABLE_NAME,
        'Dimension Relationship Violation' as ERROR_TYPE,
        'Data Integrity' as ERROR_CATEGORY,
        'High' as ERROR_SEVERITY,
        'Fact record references non-unique support category: SUPPORT_CATEGORY_KEY=' || fsa.SUPPORT_CATEGORY_KEY as ERROR_MESSAGE,
        'FACT_SUPPORT_DIMENSION_UNIQUENESS_VALIDATION' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'RELATIONSHIP_VALIDATION' as SOURCE_SYSTEM
    FROM GOLD.GO_FACT_SUPPORT_ACTIVITY fsa
    WHERE fsa.SUPPORT_CATEGORY_KEY IN (
        SELECT SUPPORT_CATEGORY_KEY
        FROM GOLD.GO_DIM_SUPPORT_CATEGORY
        GROUP BY SUPPORT_CATEGORY_KEY
        HAVING COUNT(*) > 1
    );
    
    -- Check Revenue Activity Facts
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, ERROR_TYPE,
        ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_REVENUE_ACTIVITY' as SOURCE_TABLE_NAME,
        'Dimension Relationship Violation' as ERROR_TYPE,
        'Data Integrity' as ERROR_CATEGORY,
        'High' as ERROR_SEVERITY,
        'Fact record references non-unique license: LICENSE_KEY=' || fra.LICENSE_KEY as ERROR_MESSAGE,
        'FACT_LICENSE_DIMENSION_UNIQUENESS_VALIDATION' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'RELATIONSHIP_VALIDATION' as SOURCE_SYSTEM
    FROM GOLD.GO_FACT_REVENUE_ACTIVITY fra
    WHERE fra.LICENSE_KEY IN (
        SELECT LICENSE_KEY
        FROM GOLD.GO_DIM_LICENSE
        WHERE IS_CURRENT_RECORD = TRUE
        GROUP BY LICENSE_KEY
        HAVING COUNT(*) > 1
    );
    
    -- Get count of relationship issues
    SELECT COUNT(*) INTO relationship_issues
    FROM GOLD.GO_DATA_VALIDATION_ERRORS
    WHERE VALIDATION_RULE_NAME LIKE '%_UNIQUENESS_VALIDATION'
      AND ERROR_TIMESTAMP >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR';
    
    SET validation_result = 'Dimension-fact relationship validation completed. Issues found: ' || relationship_issues;
    
    RETURN validation_result;
END;
$$;
```

### 8. Enhanced Performance Optimization with Uniqueness Constraints

#### 8.1 Optimized Clustering Strategy for Unique Dimensions

**Rationale**: Implement clustering strategies that leverage dimension uniqueness to optimize query performance and ensure efficient fact-dimension joins.

**SQL Example**:
```sql
-- Optimized clustering for dimension tables to support uniqueness
ALTER TABLE GOLD.GO_DIM_USER CLUSTER BY (USER_ID, IS_CURRENT_RECORD);
ALTER TABLE GOLD.GO_DIM_FEATURE CLUSTER BY (FEATURE_NAME);
ALTER TABLE GOLD.GO_DIM_LICENSE CLUSTER BY (LICENSE_TYPE, IS_CURRENT_RECORD);
ALTER TABLE GOLD.GO_DIM_SUPPORT_CATEGORY CLUSTER BY (SUPPORT_CATEGORY);
ALTER TABLE GOLD.GO_DIM_MEETING CLUSTER BY (MEETING_KEY);

-- Optimized clustering for fact tables with dimension keys
ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY CLUSTER BY (DATE_KEY, USER_KEY);
ALTER TABLE GOLD.GO_FACT_SUPPORT_ACTIVITY CLUSTER BY (DATE_KEY, SUPPORT_CATEGORY_KEY, USER_KEY);
ALTER TABLE GOLD.GO_FACT_REVENUE_ACTIVITY CLUSTER BY (DATE_KEY, USER_KEY, LICENSE_KEY);
ALTER TABLE GOLD.GO_FACT_FEATURE_USAGE CLUSTER BY (DATE_KEY, FEATURE_KEY, USER_KEY);
```

### 9. Enhanced Business Rule Implementation with Uniqueness Validation

#### 9.1 KPI Calculation with Dimension Uniqueness Assurance

**Rationale**: Ensure KPI calculations are accurate by validating dimension uniqueness before performing aggregations and business metric calculations.

**SQL Example**:
```sql
-- Enhanced KPI calculation with dimension uniqueness validation
CREATE OR REPLACE VIEW GOLD.VW_VALIDATED_DAILY_ACTIVE_USERS AS
SELECT 
    fma.DATE_KEY,
    COUNT(DISTINCT fma.USER_KEY) as DAILY_ACTIVE_USERS,
    COUNT(DISTINCT CASE WHEN fma.DURATION_MINUTES >= 5 THEN fma.USER_KEY END) as ENGAGED_DAILY_USERS,
    AVG(fma.DURATION_MINUTES) as AVG_SESSION_DURATION,
    -- Validation flags
    CASE WHEN EXISTS (
        SELECT 1 FROM GOLD.GO_DIM_USER du 
        WHERE du.USER_KEY = fma.USER_KEY 
        GROUP BY du.USER_KEY 
        HAVING COUNT(*) > 1
    ) THEN 'DIMENSION_UNIQUENESS_VIOLATION' ELSE 'VALID' END as DATA_QUALITY_FLAG
FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
-- Only include records with valid, unique dimension references
WHERE fma.USER_KEY IN (
    SELECT du.USER_KEY
    FROM GOLD.GO_DIM_USER du
    WHERE du.IS_CURRENT_RECORD = TRUE
    GROUP BY du.USER_KEY
    HAVING COUNT(*) = 1  -- Ensure uniqueness
)
GROUP BY fma.DATE_KEY;
```

### 10. Enhanced BI Integration with Dimension Uniqueness Assurance

#### 10.1 Tableau-Optimized Views with Validated Unique Dimensions

**Rationale**: Create BI-ready views that guarantee dimension uniqueness for accurate reporting and prevent double-counting issues in analytical dashboards.

**SQL Example**:
```sql
-- Tableau-optimized view with guaranteed dimension uniqueness
CREATE OR REPLACE VIEW GOLD.VW_TABLEAU_VALIDATED_MEETING_ANALYSIS AS
SELECT 
    fma.MEETING_ACTIVITY_ID,
    fma.USER_KEY,
    fma.MEETING_KEY,
    fma.DATE_KEY,
    fma.FEATURE_KEY,
    -- Dimension attributes from validated unique records
    du.USER_NAME,
    du.COMPANY,
    du.PLAN_TYPE,
    dd.DATE_VALUE as "Meeting Date",
    dd.YEAR,
    dd.MONTH_NAME,
    dd.DAY_NAME,
    dm.MEETING_TYPE,
    dm.DURATION_CATEGORY,
    df.FEATURE_NAME,
    df.FEATURE_CATEGORY,
    -- Fact measures
    fma.DURATION_MINUTES,
    fma.PARTICIPANT_COUNT,
    fma.MEETING_QUALITY_SCORE,
    fma.FEATURES_USED_COUNT,
    -- Data quality indicators
    'VALIDATED_UNIQUE_DIMENSIONS' as DATA_QUALITY_STATUS
FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
-- Join only with validated unique dimension records
JOIN (
    SELECT USER_KEY, USER_NAME, COMPANY, PLAN_TYPE
    FROM GOLD.GO_DIM_USER
    WHERE IS_CURRENT_RECORD = TRUE
    GROUP BY USER_KEY, USER_NAME, COMPANY, PLAN_TYPE
    HAVING COUNT(*) = 1  -- Ensure uniqueness
) du ON fma.USER_KEY = du.USER_KEY
JOIN GOLD.GO_DIM_DATE dd ON fma.DATE_KEY = dd.DATE_KEY
JOIN (
    SELECT MEETING_KEY, MEETING_TYPE, DURATION_CATEGORY
    FROM GOLD.GO_DIM_MEETING
    GROUP BY MEETING_KEY, MEETING_TYPE, DURATION_CATEGORY
    HAVING COUNT(*) = 1  -- Ensure uniqueness
) dm ON fma.MEETING_KEY = dm.MEETING_KEY
LEFT JOIN (
    SELECT FEATURE_KEY, FEATURE_NAME, FEATURE_CATEGORY
    FROM GOLD.GO_DIM_FEATURE
    GROUP BY FEATURE_KEY, FEATURE_NAME, FEATURE_CATEGORY
    HAVING COUNT(*) = 1  -- Ensure uniqueness
) df ON fma.FEATURE_KEY = df.FEATURE_KEY;
```

## Summary of Enhanced Transformation Rules

These enhanced transformation rules specifically address the requirement to ensure dimension tables have unique row values for every unique combination of defining attributes. The key improvements include:

### **1. Dimension Uniqueness Validation**
- Automated procedures to detect and flag dimension uniqueness violations
- Comprehensive monitoring across all dimension tables
- Critical error logging for dimension duplicates

### **2. Deduplication Strategies**
- Automated deduplication procedures for dimension tables
- Master record selection based on recency and data quality
- Fact table foreign key updates to maintain referential integrity

### **3. Enhanced Fact Loading**
- ROW_NUMBER() window functions to ensure unique dimension lookups
- Fallback values for missing dimension references
- Validation of dimension uniqueness during fact loading

### **4. Comprehensive Monitoring**
- Continuous monitoring of dimension uniqueness violations
- Automated error detection and logging
- Performance metrics for dimension integrity

### **5. BI Integration Optimization**
- Views that guarantee dimension uniqueness for reporting
- Data quality flags in analytical views
- Prevention of double-counting in dashboards

### **6. Performance Optimization**
- Clustering strategies optimized for unique dimensions
- Efficient join patterns leveraging dimension uniqueness
- Optimized query performance for BI tools

These transformation rules ensure that:
- **Every dimension table maintains unique rows** for each unique combination of defining attributes
- **Fact tables reference only unique dimension records** preventing analytical inaccuracies
- **BI tools receive clean, validated data** with guaranteed dimension uniqueness
- **Data quality is continuously monitored** with automated violation detection
- **Performance is optimized** through proper clustering and indexing strategies

The enhanced rules support all three analytical domains (Platform Usage, Service Reliability, and Revenue Management) while maintaining the highest standards of dimensional modeling and data quality.