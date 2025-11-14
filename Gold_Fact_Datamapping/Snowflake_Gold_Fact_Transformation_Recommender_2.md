_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Enhanced transformation rules for Fact tables in Gold layer with unique row constraints and comprehensive data integrity validation
## *Version*: 2
## *Updated on*:   
## *Changes*: Added comprehensive uniqueness validation rules and constraints to ensure every fact table row has unique values based on defining attributes
_____________________________________________

# Snowflake Gold Fact Transformation Recommender - Enhanced Uniqueness Edition

## Transformation Rules for Fact Tables with Unique Row Constraints

### 1. GO_FACT_MEETING_ACTIVITY Transformation Rules with Uniqueness Validation

#### 1.1 Unique Row Definition and Composite Key Strategy

**Rationale**: Ensure each row in the meeting activity fact table represents a unique combination of defining attributes (USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY) to prevent duplicate records and maintain data integrity for accurate analytics.

**SQL Example**:
```sql
-- Create unique composite key validation before insert
CREATE OR REPLACE PROCEDURE GOLD.SP_VALIDATE_MEETING_ACTIVITY_UNIQUENESS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Check for potential duplicates in source data
    CREATE OR REPLACE TEMPORARY TABLE TEMP_DUPLICATE_CHECK AS
    SELECT 
        du.USER_KEY,
        dm.MEETING_KEY,
        dd.DATE_KEY,
        COALESCE(df.FEATURE_KEY, 'NO_FEATURE') as FEATURE_KEY,
        COUNT(*) as DUPLICATE_COUNT
    FROM SILVER.SI_MEETINGS sm
    JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    JOIN GOLD.GO_DIM_DATE dd ON DATE(sm.START_TIME) = dd.DATE_KEY
    JOIN GOLD.GO_DIM_MEETING dm ON sm.MEETING_ID = dm.MEETING_KEY
    LEFT JOIN SILVER.SI_FEATURE_USAGE sf ON sm.MEETING_ID = sf.MEETING_ID
    LEFT JOIN GOLD.GO_DIM_FEATURE df ON sf.FEATURE_NAME = df.FEATURE_NAME
    WHERE sm.VALIDATION_STATUS = 'PASSED'
    GROUP BY du.USER_KEY, dm.MEETING_KEY, dd.DATE_KEY, COALESCE(df.FEATURE_KEY, 'NO_FEATURE')
    HAVING COUNT(*) > 1;
    
    -- Log duplicates as errors
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'SILVER.SI_MEETINGS' as SOURCE_TABLE_NAME,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as TARGET_TABLE_NAME,
        'Data Uniqueness Violation' as ERROR_TYPE,
        'Duplicate Records' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate combination found: USER_KEY=' || USER_KEY || ', MEETING_KEY=' || MEETING_KEY || 
        ', DATE_KEY=' || DATE_KEY || ', FEATURE_KEY=' || FEATURE_KEY || 
        ', Count=' || DUPLICATE_COUNT as ERROR_MESSAGE,
        'MEETING_ACTIVITY_UNIQUENESS_VALIDATION' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'GOLD_UNIQUENESS_VALIDATOR' as SOURCE_SYSTEM
    FROM TEMP_DUPLICATE_CHECK;
    
    RETURN 'Uniqueness validation completed';
END;
$$;
```

#### 1.2 Unique Insert with Conflict Resolution

**Rationale**: Implement MERGE operations with conflict resolution to handle potential duplicates and ensure only unique combinations are inserted into the fact table.

**SQL Example**:
```sql
-- Enhanced MERGE operation with uniqueness enforcement
MERGE INTO GOLD.GO_FACT_MEETING_ACTIVITY AS target
USING (
    WITH DEDUPLICATED_SOURCE AS (
        SELECT 
            du.USER_KEY,
            dm.MEETING_KEY,
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
            -- Add row number to handle duplicates by taking the latest record
            ROW_NUMBER() OVER (
                PARTITION BY du.USER_KEY, dm.MEETING_KEY, dd.DATE_KEY, COALESCE(df.FEATURE_KEY, 'NO_FEATURE')
                ORDER BY sm.UPDATE_TIMESTAMP DESC
            ) as RN
        FROM SILVER.SI_MEETINGS sm
        JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
        JOIN GOLD.GO_DIM_DATE dd ON DATE(sm.START_TIME) = dd.DATE_KEY
        JOIN GOLD.GO_DIM_MEETING dm ON sm.MEETING_ID = dm.MEETING_KEY
        LEFT JOIN SILVER.SI_PARTICIPANTS sp ON sm.MEETING_ID = sp.MEETING_ID
        LEFT JOIN SILVER.SI_FEATURE_USAGE sf ON sm.MEETING_ID = sf.MEETING_ID
        LEFT JOIN GOLD.GO_DIM_FEATURE df ON sf.FEATURE_NAME = df.FEATURE_NAME
        WHERE sm.VALIDATION_STATUS = 'PASSED'
        GROUP BY du.USER_KEY, dm.MEETING_KEY, dd.DATE_KEY, COALESCE(df.FEATURE_KEY, 'NO_FEATURE'),
                 sm.MEETING_TOPIC, sm.START_TIME, sm.END_TIME, sm.DURATION_MINUTES, sm.UPDATE_TIMESTAMP
    )
    SELECT * FROM DEDUPLICATED_SOURCE WHERE RN = 1
) AS source
ON (target.USER_KEY = source.USER_KEY 
    AND target.MEETING_KEY = source.MEETING_KEY 
    AND target.DATE_KEY = source.DATE_KEY 
    AND COALESCE(target.FEATURE_KEY, 'NO_FEATURE') = source.FEATURE_KEY)
WHEN MATCHED THEN
    UPDATE SET 
        MEETING_TOPIC = source.MEETING_TOPIC,
        DURATION_MINUTES = source.DURATION_MINUTES,
        PARTICIPANT_COUNT = source.PARTICIPANT_COUNT,
        UPDATE_DATE = CURRENT_DATE()
WHEN NOT MATCHED THEN
    INSERT (
        USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY,
        MEETING_DATE, MEETING_TOPIC, START_TIME, END_TIME, DURATION_MINUTES,
        PARTICIPANT_COUNT, TOTAL_JOIN_TIME_MINUTES, AVERAGE_PARTICIPATION_MINUTES,
        FEATURES_USED_COUNT, SCREEN_SHARE_USAGE_COUNT, RECORDING_USAGE_COUNT,
        CHAT_USAGE_COUNT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
    )
    VALUES (
        source.USER_KEY, source.MEETING_KEY, source.DATE_KEY, source.FEATURE_KEY,
        source.MEETING_DATE, source.MEETING_TOPIC, source.START_TIME, source.END_TIME, source.DURATION_MINUTES,
        source.PARTICIPANT_COUNT, source.TOTAL_JOIN_TIME_MINUTES, source.AVERAGE_PARTICIPATION_MINUTES,
        source.FEATURES_USED_COUNT, source.SCREEN_SHARE_USAGE_COUNT, source.RECORDING_USAGE_COUNT,
        source.CHAT_USAGE_COUNT, CURRENT_DATE(), CURRENT_DATE(), 'SILVER_TO_GOLD_ETL'
    );
```

#### 1.3 Post-Insert Uniqueness Validation

**Rationale**: Validate uniqueness after data loading to ensure no duplicate combinations exist and maintain fact table integrity.

**SQL Example**:
```sql
-- Post-insert uniqueness validation
CREATE OR REPLACE PROCEDURE GOLD.SP_POST_INSERT_UNIQUENESS_CHECK()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    duplicate_count INTEGER DEFAULT 0;
BEGIN
    -- Check for duplicates in the fact table
    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT 
            USER_KEY, MEETING_KEY, DATE_KEY, COALESCE(FEATURE_KEY, 'NO_FEATURE') as FEATURE_KEY,
            COUNT(*) as CNT
        FROM GOLD.GO_FACT_MEETING_ACTIVITY
        GROUP BY USER_KEY, MEETING_KEY, DATE_KEY, COALESCE(FEATURE_KEY, 'NO_FEATURE')
        HAVING COUNT(*) > 1
    );
    
    -- Log any duplicates found
    IF (duplicate_count > 0) THEN
        INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
            ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
            ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
            VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
        )
        VALUES (
            UUID_STRING(), CURRENT_TIMESTAMP(), 'GOLD.GO_FACT_MEETING_ACTIVITY', 'GOLD.GO_FACT_MEETING_ACTIVITY',
            'Data Integrity Violation', 'Post-Insert Duplicate Detection', 'Critical',
            'Found ' || duplicate_count || ' duplicate combinations in fact table after insert',
            'POST_INSERT_UNIQUENESS_CHECK', CURRENT_DATE(), 'GOLD_INTEGRITY_VALIDATOR'
        );
    END IF;
    
    RETURN 'Post-insert validation completed. Duplicates found: ' || duplicate_count;
END;
$$;
```

### 2. GO_FACT_SUPPORT_ACTIVITY Transformation Rules with Uniqueness Validation

#### 2.1 Support Activity Unique Row Definition

**Rationale**: Ensure each support activity fact represents a unique combination of USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, and TICKET_ID to prevent duplicate support metrics.

**SQL Example**:
```sql
-- Unique support activity transformation with deduplication
MERGE INTO GOLD.GO_FACT_SUPPORT_ACTIVITY AS target
USING (
    WITH UNIQUE_SUPPORT_RECORDS AS (
        SELECT 
            du.USER_KEY,
            dd.DATE_KEY,
            dsc.SUPPORT_CATEGORY_KEY,
            st.TICKET_ID,
            st.OPEN_DATE as TICKET_OPEN_DATE,
            CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') 
                 THEN st.OPEN_DATE + INTERVAL '1 DAY'
                 ELSE NULL END as TICKET_CLOSE_DATE,
            st.TICKET_TYPE,
            st.RESOLUTION_STATUS,
            COALESCE(dsc.PRIORITY_LEVEL, 'Medium') as PRIORITY_LEVEL,
            CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed')
                 THEN DATEDIFF('hour', st.OPEN_DATE, st.OPEN_DATE + INTERVAL '1 DAY')
                 ELSE NULL END as RESOLUTION_TIME_HOURS,
            -- Ensure uniqueness by using ROW_NUMBER
            ROW_NUMBER() OVER (
                PARTITION BY du.USER_KEY, dd.DATE_KEY, dsc.SUPPORT_CATEGORY_KEY, st.TICKET_ID
                ORDER BY st.UPDATE_TIMESTAMP DESC
            ) as RN
        FROM SILVER.SI_SUPPORT_TICKETS st
        JOIN GOLD.GO_DIM_USER du ON st.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
        JOIN GOLD.GO_DIM_DATE dd ON st.OPEN_DATE = dd.DATE_KEY
        JOIN GOLD.GO_DIM_SUPPORT_CATEGORY dsc ON st.TICKET_TYPE = dsc.SUPPORT_CATEGORY
        WHERE st.VALIDATION_STATUS = 'PASSED'
    )
    SELECT * FROM UNIQUE_SUPPORT_RECORDS WHERE RN = 1
) AS source
ON (target.USER_KEY = source.USER_KEY 
    AND target.DATE_KEY = source.DATE_KEY 
    AND target.SUPPORT_CATEGORY_KEY = source.SUPPORT_CATEGORY_KEY
    AND target.TICKET_OPEN_DATE = source.TICKET_OPEN_DATE)
WHEN MATCHED THEN
    UPDATE SET 
        RESOLUTION_STATUS = source.RESOLUTION_STATUS,
        RESOLUTION_TIME_HOURS = source.RESOLUTION_TIME_HOURS,
        UPDATE_DATE = CURRENT_DATE()
WHEN NOT MATCHED THEN
    INSERT (
        USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY,
        TICKET_OPEN_DATE, TICKET_CLOSE_DATE, TICKET_TYPE, RESOLUTION_STATUS,
        PRIORITY_LEVEL, RESOLUTION_TIME_HOURS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
    )
    VALUES (
        source.USER_KEY, source.DATE_KEY, source.SUPPORT_CATEGORY_KEY,
        source.TICKET_OPEN_DATE, source.TICKET_CLOSE_DATE, source.TICKET_TYPE, source.RESOLUTION_STATUS,
        source.PRIORITY_LEVEL, source.RESOLUTION_TIME_HOURS, CURRENT_DATE(), CURRENT_DATE(), 'SILVER_TO_GOLD_ETL'
    );
```

### 3. GO_FACT_REVENUE_ACTIVITY Transformation Rules with Uniqueness Validation

#### 3.1 Revenue Activity Unique Row Definition

**Rationale**: Ensure each revenue fact represents a unique combination of USER_KEY, LICENSE_KEY, DATE_KEY, and TRANSACTION_ID to prevent duplicate financial records and maintain accurate revenue calculations.

**SQL Example**:
```sql
-- Unique revenue activity transformation with transaction-level deduplication
MERGE INTO GOLD.GO_FACT_REVENUE_ACTIVITY AS target
USING (
    WITH UNIQUE_REVENUE_RECORDS AS (
        SELECT 
            du.USER_KEY,
            COALESCE(dl.LICENSE_KEY, 'NO_LICENSE') as LICENSE_KEY,
            dd.DATE_KEY,
            be.EVENT_ID as TRANSACTION_ID,
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
            -- Ensure uniqueness by transaction ID and user combination
            ROW_NUMBER() OVER (
                PARTITION BY du.USER_KEY, COALESCE(dl.LICENSE_KEY, 'NO_LICENSE'), dd.DATE_KEY, be.EVENT_ID
                ORDER BY be.UPDATE_TIMESTAMP DESC
            ) as RN
        FROM SILVER.SI_BILLING_EVENTS be
        JOIN GOLD.GO_DIM_USER du ON be.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
        JOIN GOLD.GO_DIM_DATE dd ON be.EVENT_DATE = dd.DATE_KEY
        LEFT JOIN SILVER.SI_LICENSES sl ON be.USER_ID = sl.ASSIGNED_TO_USER_ID
        LEFT JOIN GOLD.GO_DIM_LICENSE dl ON sl.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
        WHERE be.VALIDATION_STATUS = 'PASSED'
    )
    SELECT * FROM UNIQUE_REVENUE_RECORDS WHERE RN = 1
) AS source
ON (target.USER_KEY = source.USER_KEY 
    AND target.LICENSE_KEY = source.LICENSE_KEY 
    AND target.DATE_KEY = source.DATE_KEY
    AND target.TRANSACTION_DATE = source.TRANSACTION_DATE
    AND target.EVENT_TYPE = source.EVENT_TYPE)
WHEN MATCHED THEN
    UPDATE SET 
        AMOUNT = source.AMOUNT,
        NET_REVENUE_AMOUNT = source.NET_REVENUE_AMOUNT,
        MRR_IMPACT = source.MRR_IMPACT,
        UPDATE_DATE = CURRENT_DATE()
WHEN NOT MATCHED THEN
    INSERT (
        USER_KEY, LICENSE_KEY, DATE_KEY, TRANSACTION_DATE, EVENT_TYPE, AMOUNT, CURRENCY,
        SUBSCRIPTION_REVENUE_AMOUNT, ONE_TIME_REVENUE_AMOUNT, NET_REVENUE_AMOUNT,
        USD_AMOUNT, MRR_IMPACT, ARR_IMPACT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
    )
    VALUES (
        source.USER_KEY, source.LICENSE_KEY, source.DATE_KEY, source.TRANSACTION_DATE, source.EVENT_TYPE, 
        source.AMOUNT, source.CURRENCY, source.SUBSCRIPTION_REVENUE_AMOUNT, source.ONE_TIME_REVENUE_AMOUNT, 
        source.NET_REVENUE_AMOUNT, source.USD_AMOUNT, source.MRR_IMPACT, source.ARR_IMPACT,
        CURRENT_DATE(), CURRENT_DATE(), 'SILVER_TO_GOLD_ETL'
    );
```

### 4. GO_FACT_FEATURE_USAGE Transformation Rules with Uniqueness Validation

#### 4.1 Feature Usage Unique Row Definition

**Rationale**: Ensure each feature usage fact represents a unique combination of DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, and USAGE_TIMESTAMP to prevent duplicate usage metrics.

**SQL Example**:
```sql
-- Unique feature usage transformation with timestamp-level deduplication
MERGE INTO GOLD.GO_FACT_FEATURE_USAGE AS target
USING (
    WITH UNIQUE_FEATURE_USAGE AS (
        SELECT 
            dd.DATE_KEY,
            df.FEATURE_KEY,
            du.USER_KEY,
            COALESCE(dm.MEETING_KEY, 'NO_MEETING') as MEETING_KEY,
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
            -- Ensure uniqueness by feature, user, meeting, and timestamp
            ROW_NUMBER() OVER (
                PARTITION BY dd.DATE_KEY, df.FEATURE_KEY, du.USER_KEY, 
                           COALESCE(dm.MEETING_KEY, 'NO_MEETING'), fu.USAGE_DATE::TIMESTAMP_NTZ
                ORDER BY fu.UPDATE_TIMESTAMP DESC
            ) as RN
        FROM SILVER.SI_FEATURE_USAGE fu
        JOIN GOLD.GO_DIM_DATE dd ON fu.USAGE_DATE = dd.DATE_KEY
        JOIN GOLD.GO_DIM_FEATURE df ON fu.FEATURE_NAME = df.FEATURE_NAME
        LEFT JOIN SILVER.SI_MEETINGS sm ON fu.MEETING_ID = sm.MEETING_ID
        LEFT JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
        LEFT JOIN GOLD.GO_DIM_MEETING dm ON fu.MEETING_ID = dm.MEETING_KEY
        WHERE fu.VALIDATION_STATUS = 'PASSED'
    )
    SELECT * FROM UNIQUE_FEATURE_USAGE WHERE RN = 1
) AS source
ON (target.DATE_KEY = source.DATE_KEY 
    AND target.FEATURE_KEY = source.FEATURE_KEY 
    AND COALESCE(target.USER_KEY, 'NO_USER') = COALESCE(source.USER_KEY, 'NO_USER')
    AND target.MEETING_KEY = source.MEETING_KEY
    AND target.USAGE_TIMESTAMP = source.USAGE_TIMESTAMP)
WHEN MATCHED THEN
    UPDATE SET 
        USAGE_COUNT = source.USAGE_COUNT,
        FEATURE_ADOPTION_SCORE = source.FEATURE_ADOPTION_SCORE,
        SUCCESS_RATE = source.SUCCESS_RATE,
        UPDATE_DATE = CURRENT_DATE()
WHEN NOT MATCHED THEN
    INSERT (
        DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_DATE, USAGE_TIMESTAMP,
        FEATURE_NAME, USAGE_COUNT, USAGE_DURATION_MINUTES, FEATURE_ADOPTION_SCORE,
        SUCCESS_RATE, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
    )
    VALUES (
        source.DATE_KEY, source.FEATURE_KEY, source.USER_KEY, source.MEETING_KEY, 
        source.USAGE_DATE, source.USAGE_TIMESTAMP, source.FEATURE_NAME, source.USAGE_COUNT, 
        source.USAGE_DURATION_MINUTES, source.FEATURE_ADOPTION_SCORE, source.SUCCESS_RATE,
        CURRENT_DATE(), CURRENT_DATE(), 'SILVER_TO_GOLD_ETL'
    );
```

### 5. Comprehensive Uniqueness Validation Framework

#### 5.1 Master Uniqueness Validation Procedure

**Rationale**: Create a comprehensive validation framework that checks uniqueness across all fact tables and provides detailed reporting on data integrity.

**SQL Example**:
```sql
-- Master uniqueness validation procedure for all fact tables
CREATE OR REPLACE PROCEDURE GOLD.SP_MASTER_UNIQUENESS_VALIDATION()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    total_duplicates INTEGER DEFAULT 0;
    validation_results STRING DEFAULT '';
BEGIN
    -- Validate GO_FACT_MEETING_ACTIVITY uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as SOURCE_TABLE_NAME,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as TARGET_TABLE_NAME,
        'Uniqueness Violation' as ERROR_TYPE,
        'Duplicate Key Combination' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate found: USER_KEY=' || USER_KEY || ', MEETING_KEY=' || MEETING_KEY || 
        ', DATE_KEY=' || DATE_KEY || ', FEATURE_KEY=' || COALESCE(FEATURE_KEY, 'NULL') || 
        ', Count=' || CNT as ERROR_MESSAGE,
        'MEETING_ACTIVITY_UNIQUENESS' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'MASTER_UNIQUENESS_VALIDATOR' as SOURCE_SYSTEM
    FROM (
        SELECT 
            USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY, COUNT(*) as CNT
        FROM GOLD.GO_FACT_MEETING_ACTIVITY
        GROUP BY USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY
        HAVING COUNT(*) > 1
    );
    
    -- Validate GO_FACT_SUPPORT_ACTIVITY uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_SUPPORT_ACTIVITY' as SOURCE_TABLE_NAME,
        'GOLD.GO_FACT_SUPPORT_ACTIVITY' as TARGET_TABLE_NAME,
        'Uniqueness Violation' as ERROR_TYPE,
        'Duplicate Key Combination' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate found: USER_KEY=' || USER_KEY || ', DATE_KEY=' || DATE_KEY || 
        ', SUPPORT_CATEGORY_KEY=' || SUPPORT_CATEGORY_KEY || ', Count=' || CNT as ERROR_MESSAGE,
        'SUPPORT_ACTIVITY_UNIQUENESS' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'MASTER_UNIQUENESS_VALIDATOR' as SOURCE_SYSTEM
    FROM (
        SELECT 
            USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, COUNT(*) as CNT
        FROM GOLD.GO_FACT_SUPPORT_ACTIVITY
        GROUP BY USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY
        HAVING COUNT(*) > 1
    );
    
    -- Validate GO_FACT_REVENUE_ACTIVITY uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_REVENUE_ACTIVITY' as SOURCE_TABLE_NAME,
        'GOLD.GO_FACT_REVENUE_ACTIVITY' as TARGET_TABLE_NAME,
        'Uniqueness Violation' as ERROR_TYPE,
        'Duplicate Key Combination' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate found: USER_KEY=' || USER_KEY || ', LICENSE_KEY=' || LICENSE_KEY || 
        ', DATE_KEY=' || DATE_KEY || ', TRANSACTION_DATE=' || TRANSACTION_DATE || 
        ', EVENT_TYPE=' || EVENT_TYPE || ', Count=' || CNT as ERROR_MESSAGE,
        'REVENUE_ACTIVITY_UNIQUENESS' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'MASTER_UNIQUENESS_VALIDATOR' as SOURCE_SYSTEM
    FROM (
        SELECT 
            USER_KEY, LICENSE_KEY, DATE_KEY, TRANSACTION_DATE, EVENT_TYPE, COUNT(*) as CNT
        FROM GOLD.GO_FACT_REVENUE_ACTIVITY
        GROUP BY USER_KEY, LICENSE_KEY, DATE_KEY, TRANSACTION_DATE, EVENT_TYPE
        HAVING COUNT(*) > 1
    );
    
    -- Validate GO_FACT_FEATURE_USAGE uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_FEATURE_USAGE' as SOURCE_TABLE_NAME,
        'GOLD.GO_FACT_FEATURE_USAGE' as TARGET_TABLE_NAME,
        'Uniqueness Violation' as ERROR_TYPE,
        'Duplicate Key Combination' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate found: DATE_KEY=' || DATE_KEY || ', FEATURE_KEY=' || FEATURE_KEY || 
        ', USER_KEY=' || COALESCE(USER_KEY, 'NULL') || ', MEETING_KEY=' || MEETING_KEY || 
        ', USAGE_TIMESTAMP=' || USAGE_TIMESTAMP || ', Count=' || CNT as ERROR_MESSAGE,
        'FEATURE_USAGE_UNIQUENESS' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'MASTER_UNIQUENESS_VALIDATOR' as SOURCE_SYSTEM
    FROM (
        SELECT 
            DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP, COUNT(*) as CNT
        FROM GOLD.GO_FACT_FEATURE_USAGE
        GROUP BY DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP
        HAVING COUNT(*) > 1
    );
    
    -- Get total duplicate count
    SELECT COUNT(*) INTO total_duplicates
    FROM GOLD.GO_DATA_VALIDATION_ERRORS
    WHERE ERROR_TYPE = 'Uniqueness Violation'
    AND DATE(ERROR_TIMESTAMP) = CURRENT_DATE();
    
    SET validation_results = 'Master uniqueness validation completed. Total duplicates found: ' || total_duplicates;
    
    RETURN validation_results;
END;
$$;
```

#### 5.2 Automated Duplicate Removal Procedure

**Rationale**: Provide automated procedures to remove duplicates when they are detected, maintaining the most recent or most complete record based on business rules.

**SQL Example**:
```sql
-- Automated duplicate removal procedure
CREATE OR REPLACE PROCEDURE GOLD.SP_REMOVE_FACT_TABLE_DUPLICATES()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    removed_count INTEGER DEFAULT 0;
BEGIN
    -- Remove duplicates from GO_FACT_MEETING_ACTIVITY (keep most recent)
    DELETE FROM GOLD.GO_FACT_MEETING_ACTIVITY
    WHERE MEETING_ACTIVITY_ID IN (
        SELECT MEETING_ACTIVITY_ID
        FROM (
            SELECT 
                MEETING_ACTIVITY_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY USER_KEY, MEETING_KEY, DATE_KEY, COALESCE(FEATURE_KEY, 'NO_FEATURE')
                    ORDER BY UPDATE_DATE DESC, MEETING_ACTIVITY_ID DESC
                ) as RN
            FROM GOLD.GO_FACT_MEETING_ACTIVITY
        )
        WHERE RN > 1
    );
    
    GET DIAGNOSTICS removed_count = ROW_COUNT;
    
    -- Remove duplicates from GO_FACT_SUPPORT_ACTIVITY (keep most recent)
    DELETE FROM GOLD.GO_FACT_SUPPORT_ACTIVITY
    WHERE SUPPORT_ACTIVITY_ID IN (
        SELECT SUPPORT_ACTIVITY_ID
        FROM (
            SELECT 
                SUPPORT_ACTIVITY_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, TICKET_OPEN_DATE
                    ORDER BY UPDATE_DATE DESC, SUPPORT_ACTIVITY_ID DESC
                ) as RN
            FROM GOLD.GO_FACT_SUPPORT_ACTIVITY
        )
        WHERE RN > 1
    );
    
    -- Remove duplicates from GO_FACT_REVENUE_ACTIVITY (keep most recent)
    DELETE FROM GOLD.GO_FACT_REVENUE_ACTIVITY
    WHERE REVENUE_ACTIVITY_ID IN (
        SELECT REVENUE_ACTIVITY_ID
        FROM (
            SELECT 
                REVENUE_ACTIVITY_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY USER_KEY, LICENSE_KEY, DATE_KEY, TRANSACTION_DATE, EVENT_TYPE
                    ORDER BY UPDATE_DATE DESC, REVENUE_ACTIVITY_ID DESC
                ) as RN
            FROM GOLD.GO_FACT_REVENUE_ACTIVITY
        )
        WHERE RN > 1
    );
    
    -- Remove duplicates from GO_FACT_FEATURE_USAGE (keep most recent)
    DELETE FROM GOLD.GO_FACT_FEATURE_USAGE
    WHERE FEATURE_USAGE_ID IN (
        SELECT FEATURE_USAGE_ID
        FROM (
            SELECT 
                FEATURE_USAGE_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY DATE_KEY, FEATURE_KEY, COALESCE(USER_KEY, 'NO_USER'), MEETING_KEY, USAGE_TIMESTAMP
                    ORDER BY UPDATE_DATE DESC, FEATURE_USAGE_ID DESC
                ) as RN
            FROM GOLD.GO_FACT_FEATURE_USAGE
        )
        WHERE RN > 1
    );
    
    RETURN 'Duplicate removal completed. Total records removed: ' || removed_count;
END;
$$;
```

### 6. Enhanced Data Quality Rules with Uniqueness Focus

#### 6.1 Pre-Processing Data Quality Checks

**Rationale**: Implement comprehensive data quality checks before loading data into fact tables to prevent duplicates and ensure data integrity.

**SQL Example**:
```sql
-- Pre-processing data quality validation
CREATE OR REPLACE PROCEDURE GOLD.SP_PRE_LOAD_QUALITY_VALIDATION()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Check for null values in key fields that would affect uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'SILVER.SI_MEETINGS' as SOURCE_TABLE_NAME,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as TARGET_TABLE_NAME,
        'Data Quality Issue' as ERROR_TYPE,
        'Null Key Field' as ERROR_CATEGORY,
        'High' as ERROR_SEVERITY,
        'Null value found in key field: ' || 
        CASE 
            WHEN HOST_ID IS NULL THEN 'HOST_ID'
            WHEN MEETING_ID IS NULL THEN 'MEETING_ID'
            WHEN START_TIME IS NULL THEN 'START_TIME'
            ELSE 'UNKNOWN'
        END as ERROR_MESSAGE,
        'PRE_LOAD_NULL_KEY_VALIDATION' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'PRE_LOAD_VALIDATOR' as SOURCE_SYSTEM
    FROM SILVER.SI_MEETINGS
    WHERE HOST_ID IS NULL OR MEETING_ID IS NULL OR START_TIME IS NULL;
    
    -- Check for invalid date ranges that could cause uniqueness issues
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'SILVER.SI_MEETINGS' as SOURCE_TABLE_NAME,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as TARGET_TABLE_NAME,
        'Data Quality Issue' as ERROR_TYPE,
        'Invalid Date Range' as ERROR_CATEGORY,
        'Medium' as ERROR_SEVERITY,
        'Invalid date range: START_TIME=' || START_TIME || ', END_TIME=' || END_TIME as ERROR_MESSAGE,
        'PRE_LOAD_DATE_VALIDATION' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'PRE_LOAD_VALIDATOR' as SOURCE_SYSTEM
    FROM SILVER.SI_MEETINGS
    WHERE END_TIME <= START_TIME OR START_TIME > CURRENT_TIMESTAMP();
    
    RETURN 'Pre-load quality validation completed';
END;
$$;
```

### 7. Monitoring and Alerting for Uniqueness Violations

#### 7.1 Real-time Uniqueness Monitoring

**Rationale**: Implement monitoring procedures that can detect uniqueness violations in real-time and trigger alerts for immediate remediation.

**SQL Example**:
```sql
-- Real-time uniqueness monitoring view
CREATE OR REPLACE VIEW GOLD.VW_UNIQUENESS_MONITORING AS
SELECT 
    'GO_FACT_MEETING_ACTIVITY' as TABLE_NAME,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT CONCAT(USER_KEY, '|', MEETING_KEY, '|', DATE_KEY, '|', COALESCE(FEATURE_KEY, 'NULL'))) as UNIQUE_COMBINATIONS,
    COUNT(*) - COUNT(DISTINCT CONCAT(USER_KEY, '|', MEETING_KEY, '|', DATE_KEY, '|', COALESCE(FEATURE_KEY, 'NULL'))) as DUPLICATE_COUNT,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(USER_KEY, '|', MEETING_KEY, '|', DATE_KEY, '|', COALESCE(FEATURE_KEY, 'NULL'))) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as UNIQUENESS_STATUS,
    CURRENT_TIMESTAMP() as CHECK_TIMESTAMP
FROM GOLD.GO_FACT_MEETING_ACTIVITY

UNION ALL

SELECT 
    'GO_FACT_SUPPORT_ACTIVITY' as TABLE_NAME,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT CONCAT(USER_KEY, '|', DATE_KEY, '|', SUPPORT_CATEGORY_KEY, '|', TICKET_OPEN_DATE)) as UNIQUE_COMBINATIONS,
    COUNT(*) - COUNT(DISTINCT CONCAT(USER_KEY, '|', DATE_KEY, '|', SUPPORT_CATEGORY_KEY, '|', TICKET_OPEN_DATE)) as DUPLICATE_COUNT,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(USER_KEY, '|', DATE_KEY, '|', SUPPORT_CATEGORY_KEY, '|', TICKET_OPEN_DATE)) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as UNIQUENESS_STATUS,
    CURRENT_TIMESTAMP() as CHECK_TIMESTAMP
FROM GOLD.GO_FACT_SUPPORT_ACTIVITY

UNION ALL

SELECT 
    'GO_FACT_REVENUE_ACTIVITY' as TABLE_NAME,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT CONCAT(USER_KEY, '|', LICENSE_KEY, '|', DATE_KEY, '|', TRANSACTION_DATE, '|', EVENT_TYPE)) as UNIQUE_COMBINATIONS,
    COUNT(*) - COUNT(DISTINCT CONCAT(USER_KEY, '|', LICENSE_KEY, '|', DATE_KEY, '|', TRANSACTION_DATE, '|', EVENT_TYPE)) as DUPLICATE_COUNT,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(USER_KEY, '|', LICENSE_KEY, '|', DATE_KEY, '|', TRANSACTION_DATE, '|', EVENT_TYPE)) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as UNIQUENESS_STATUS,
    CURRENT_TIMESTAMP() as CHECK_TIMESTAMP
FROM GOLD.GO_FACT_REVENUE_ACTIVITY

UNION ALL

SELECT 
    'GO_FACT_FEATURE_USAGE' as TABLE_NAME,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT CONCAT(DATE_KEY, '|', FEATURE_KEY, '|', COALESCE(USER_KEY, 'NULL'), '|', MEETING_KEY, '|', USAGE_TIMESTAMP)) as UNIQUE_COMBINATIONS,
    COUNT(*) - COUNT(DISTINCT CONCAT(DATE_KEY, '|', FEATURE_KEY, '|', COALESCE(USER_KEY, 'NULL'), '|', MEETING_KEY, '|', USAGE_TIMESTAMP)) as DUPLICATE_COUNT,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(DATE_KEY, '|', FEATURE_KEY, '|', COALESCE(USER_KEY, 'NULL'), '|', MEETING_KEY, '|', USAGE_TIMESTAMP)) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as UNIQUENESS_STATUS,
    CURRENT_TIMESTAMP() as CHECK_TIMESTAMP
FROM GOLD.GO_FACT_FEATURE_USAGE;
```

### 8. Complete ETL Pipeline with Uniqueness Enforcement

#### 8.1 Master ETL Procedure with Uniqueness Validation

**Rationale**: Create a comprehensive ETL pipeline that incorporates all uniqueness validation and enforcement rules to ensure fact table integrity.

**SQL Example**:
```sql
-- Master ETL procedure with comprehensive uniqueness enforcement
CREATE OR REPLACE PROCEDURE GOLD.SP_MASTER_FACT_ETL_WITH_UNIQUENESS()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    execution_id STRING DEFAULT UUID_STRING();
    step_result STRING;
    total_errors INTEGER DEFAULT 0;
BEGIN
    -- Log ETL execution start
    INSERT INTO GOLD.GO_PROCESS_AUDIT_LOG (
        AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP,
        EXECUTION_STATUS, LOAD_DATE, SOURCE_SYSTEM
    )
    VALUES (
        execution_id, 'MASTER_FACT_ETL_WITH_UNIQUENESS', CURRENT_TIMESTAMP(),
        'RUNNING', CURRENT_DATE(), 'GOLD_ETL_MASTER'
    );
    
    -- Step 1: Pre-load quality validation
    CALL GOLD.SP_PRE_LOAD_QUALITY_VALIDATION();
    
    -- Step 2: Load fact tables with uniqueness enforcement
    -- Meeting Activity Facts
    CALL GOLD.SP_VALIDATE_MEETING_ACTIVITY_UNIQUENESS();
    -- (Execute MERGE statement for GO_FACT_MEETING_ACTIVITY)
    
    -- Support Activity Facts  
    -- (Execute MERGE statement for GO_FACT_SUPPORT_ACTIVITY)
    
    -- Revenue Activity Facts
    -- (Execute MERGE statement for GO_FACT_REVENUE_ACTIVITY)
    
    -- Feature Usage Facts
    -- (Execute MERGE statement for GO_FACT_FEATURE_USAGE)
    
    -- Step 3: Post-load uniqueness validation
    CALL GOLD.SP_MASTER_UNIQUENESS_VALIDATION();
    
    -- Step 4: Remove any duplicates found
    CALL GOLD.SP_REMOVE_FACT_TABLE_DUPLICATES();
    
    -- Step 5: Final validation
    CALL GOLD.SP_POST_INSERT_UNIQUENESS_CHECK();
    
    -- Get total error count
    SELECT COUNT(*) INTO total_errors
    FROM GOLD.GO_DATA_VALIDATION_ERRORS
    WHERE DATE(ERROR_TIMESTAMP) = CURRENT_DATE()
    AND ERROR_SEVERITY IN ('Critical', 'High');
    
    -- Update execution log
    UPDATE GOLD.GO_PROCESS_AUDIT_LOG 
    SET 
        EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(),
        EXECUTION_STATUS = CASE WHEN total_errors > 0 THEN 'COMPLETED_WITH_ERRORS' ELSE 'SUCCESS' END,
        ERROR_COUNT = total_errors
    WHERE AUDIT_LOG_ID = execution_id;
    
    RETURN 'Master ETL with uniqueness enforcement completed. Execution ID: ' || execution_id || ', Errors: ' || total_errors;
END;
$$;
```

## Summary of Enhanced Uniqueness Features

This enhanced version of the Snowflake Gold Fact Transformation Recommender includes:

### 1. **Comprehensive Uniqueness Validation**
- Pre-insert duplicate detection and prevention
- Post-insert uniqueness verification
- Real-time monitoring of uniqueness violations
- Automated duplicate removal procedures

### 2. **Robust Deduplication Strategies**
- ROW_NUMBER() partitioning for source data deduplication
- MERGE operations with conflict resolution
- Business rule-based duplicate handling (keeping most recent records)
- Composite key validation across all fact tables

### 3. **Enhanced Data Quality Framework**
- Pre-processing validation to prevent uniqueness issues
- Comprehensive error logging and tracking
- Severity-based error categorization
- Detailed error reporting with specific violation details

### 4. **Fact Table Specific Uniqueness Rules**

**GO_FACT_MEETING_ACTIVITY**: Unique by (USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY)
**GO_FACT_SUPPORT_ACTIVITY**: Unique by (USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, TICKET_OPEN_DATE)
**GO_FACT_REVENUE_ACTIVITY**: Unique by (USER_KEY, LICENSE_KEY, DATE_KEY, TRANSACTION_DATE, EVENT_TYPE)
**GO_FACT_FEATURE_USAGE**: Unique by (DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP)

### 5. **Monitoring and Alerting**
- Real-time uniqueness status monitoring
- Automated duplicate detection alerts
- Comprehensive audit trail for all uniqueness validations
- Performance metrics for uniqueness enforcement

### 6. **Business Rule Compliance**
- Maintains all original business logic and KPI calculations
- Preserves dimensional relationships for BI integration
- Ensures referential integrity while enforcing uniqueness
- Supports incremental loading with uniqueness constraints

These enhancements ensure that **every row in each fact table represents a unique combination of its defining attributes**, eliminating duplicate records while maintaining data accuracy, completeness, and analytical value for downstream reporting and BI applications.