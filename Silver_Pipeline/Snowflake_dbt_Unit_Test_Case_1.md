_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer transformation models running in Snowflake. The tests validate data transformations, business rules, edge cases, and error handling across all Silver layer models including SI_USERS, SI_MEETINGS, SI_PARTICIPANTS, SI_FEATURE_USAGE, SI_SUPPORT_TICKETS, SI_BILLING_EVENTS, SI_LICENSES, and SI_Audit_Log.

## Test Coverage Overview

The test suite covers:
- **Data Quality**: Null value elimination, duplicate removal, data validation
- **Business Rules**: Plan type standardization, status validation, amount validation
- **Timestamp Handling**: EST timezone conversion, MM/DD/YYYY format validation
- **Edge Cases**: Invalid formats, missing values, schema mismatches
- **Audit Trail**: Process tracking, error logging, data lineage

---

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate email format using REGEXP_LIKE | All emails follow valid format pattern |
| TC_USR_002 | Test plan type standardization (FREE, BASIC, PRO, ENTERPRISE) | All plan types are standardized |
| TC_USR_003 | Verify null value elimination | No null values in critical fields |
| TC_USR_004 | Test duplicate removal using ROW_NUMBER() | Only latest records retained |
| TC_USR_005 | Validate data quality scoring (0-100) | Quality scores calculated correctly |
| TC_USR_006 | Test invalid email handling | Invalid emails marked with WARNING status |
| TC_USR_007 | Verify UPDATE_TIMESTAMP logic | Latest records identified correctly |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate EST timezone format using REGEXP_LIKE | EST format validated correctly |
| TC_MTG_002 | Test CONVERT_TIMEZONE function for EST to UTC | Timezone conversion accurate |
| TC_MTG_003 | Verify meeting duration calculations | Duration calculated correctly |
| TC_MTG_004 | Test null meeting_id handling | No null meeting IDs in output |
| TC_MTG_005 | Validate meeting status standardization | Status values standardized |
| TC_MTG_006 | Test invalid timezone format handling | Invalid formats handled gracefully |
| TC_MTG_007 | Verify chronological order validation | Start time < End time validation |

### 3. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate MM/DD/YYYY HH:MM format using TRY_TO_TIMESTAMP | Format validation successful |
| TC_PRT_002 | Test timestamp conversion accuracy | Timestamps converted correctly |
| TC_PRT_003 | Verify participant deduplication | Unique participants per meeting |
| TC_PRT_004 | Test join duration calculations | Duration calculated accurately |
| TC_PRT_005 | Validate participant role standardization | Roles standardized correctly |
| TC_PRT_006 | Test invalid timestamp format handling | Invalid formats handled gracefully |
| TC_PRT_007 | Verify participant count aggregations | Counts calculated correctly |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate feature name standardization | Feature names standardized |
| TC_FTR_002 | Test usage count aggregations | Usage counts accurate |
| TC_FTR_003 | Verify null usage handling | Null usage values handled |
| TC_FTR_004 | Test feature category mapping | Categories mapped correctly |
| TC_FTR_005 | Validate usage trend calculations | Trends calculated accurately |
| TC_FTR_006 | Test duplicate feature usage removal | Duplicates removed correctly |
| TC_FTR_007 | Verify feature availability validation | Availability validated |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate resolution status (OPEN, IN PROGRESS, RESOLVED, CLOSED) | Status standardized correctly |
| TC_TKT_002 | Test priority level validation | Priority levels validated |
| TC_TKT_003 | Verify ticket age calculations | Age calculated accurately |
| TC_TKT_004 | Test SLA compliance validation | SLA status calculated correctly |
| TC_TKT_005 | Validate ticket category standardization | Categories standardized |
| TC_TKT_006 | Test null description handling | Null descriptions handled |
| TC_TKT_007 | Verify resolution time calculations | Resolution time accurate |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate positive amount validation | Only positive amounts allowed |
| TC_BIL_002 | Test amount rounding to 2 decimal places | Amounts rounded correctly |
| TC_BIL_003 | Verify currency standardization | Currency codes standardized |
| TC_BIL_004 | Test billing cycle validation | Cycles validated correctly |
| TC_BIL_005 | Validate payment method standardization | Methods standardized |
| TC_BIL_006 | Test negative amount handling | Negative amounts flagged |
| TC_BIL_007 | Verify billing date chronology | Dates in correct order |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate license type standardization | Types standardized correctly |
| TC_LIC_002 | Test date logic validation (start < end) | Date logic validated |
| TC_LIC_003 | Verify license status validation | Status values validated |
| TC_LIC_004 | Test license capacity validation | Capacity values validated |
| TC_LIC_005 | Validate expiration date calculations | Expiration calculated correctly |
| TC_LIC_006 | Test overlapping license detection | Overlaps detected correctly |
| TC_LIC_007 | Verify license utilization calculations | Utilization calculated accurately |

### 8. SI_Audit_Log Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Validate audit log entry creation | Entries created for all processes |
| TC_AUD_002 | Test process start/end time tracking | Times tracked accurately |
| TC_AUD_003 | Verify record count tracking | Counts tracked correctly |
| TC_AUD_004 | Test error logging functionality | Errors logged properly |
| TC_AUD_005 | Validate audit trail completeness | Complete audit trail maintained |
| TC_AUD_006 | Test audit log retention | Retention policy enforced |
| TC_AUD_007 | Verify audit log security | Access controls validated |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/schema.yml
version: 2

models:
  - name: SI_USERS
    description: "Silver layer user data with quality validations"
    columns:
      - name: USER_ID
        description: "Unique user identifier"
        tests:
          - unique
          - not_null
      - name: EMAIL
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')"
      - name: PLAN_TYPE
        description: "Standardized plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: DATA_QUALITY_SCORE
        description: "Data quality score 0-100"
        tests:
          - dbt_utils.expression_is_true:
              expression: "DATA_QUALITY_SCORE BETWEEN 0 AND 100"

  - name: SI_MEETINGS
    description: "Silver layer meeting data with timezone handling"
    columns:
      - name: MEETING_ID
        description: "Unique meeting identifier"
        tests:
          - unique
          - not_null
      - name: START_TIME_UTC
        description: "Meeting start time in UTC"
        tests:
          - not_null
      - name: END_TIME_UTC
        description: "Meeting end time in UTC"
        tests:
          - not_null
      - name: DURATION_MINUTES
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.expression_is_true:
              expression: "DURATION_MINUTES >= 0"

  - name: SI_PARTICIPANTS
    description: "Silver layer participant data with timestamp validation"
    columns:
      - name: PARTICIPANT_ID
        description: "Unique participant identifier"
        tests:
          - unique
          - not_null
      - name: MEETING_ID
        description: "Associated meeting identifier"
        tests:
          - not_null
          - relationships:
              to: ref('SI_MEETINGS')
              field: MEETING_ID
      - name: JOIN_TIME
        description: "Participant join time"
        tests:
          - not_null

  - name: SI_SUPPORT_TICKETS
    description: "Silver layer support ticket data"
    columns:
      - name: TICKET_ID
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: STATUS
        description: "Ticket status"
        tests:
          - not_null
          - accepted_values:
              values: ['OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED']

  - name: SI_BILLING_EVENTS
    description: "Silver layer billing event data"
    columns:
      - name: EVENT_ID
        description: "Unique billing event identifier"
        tests:
          - unique
          - not_null
      - name: AMOUNT
        description: "Billing amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "AMOUNT > 0"
          - dbt_utils.expression_is_true:
              expression: "ROUND(AMOUNT, 2) = AMOUNT"

  - name: SI_LICENSES
    description: "Silver layer license data"
    columns:
      - name: LICENSE_ID
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: START_DATE
        description: "License start date"
        tests:
          - not_null
      - name: END_DATE
        description: "License end date"
        tests:
          - not_null
      - name: date_logic_validation
        description: "Validate start date is before end date"
        tests:
          - dbt_utils.expression_is_true:
              expression: "START_DATE < END_DATE"
```

### Custom SQL-based dbt Tests

#### 1. Email Format Validation Test
```sql
-- tests/test_email_format_validation.sql
SELECT 
    USER_ID,
    EMAIL,
    'Invalid email format' AS error_message
FROM {{ ref('SI_USERS') }}
WHERE NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### 2. Timezone Conversion Accuracy Test
```sql
-- tests/test_timezone_conversion_accuracy.sql
SELECT 
    MEETING_ID,
    ORIGINAL_START_TIME,
    START_TIME_UTC,
    'Timezone conversion failed' AS error_message
FROM {{ ref('SI_MEETINGS') }}
WHERE ORIGINAL_START_TIME IS NOT NULL 
  AND START_TIME_UTC IS NULL
  AND REGEXP_LIKE(ORIGINAL_START_TIME, '.*EST$')
```

#### 3. Duplicate Record Detection Test
```sql
-- tests/test_duplicate_records.sql
SELECT 
    USER_ID,
    COUNT(*) as duplicate_count,
    'Duplicate records found' AS error_message
FROM {{ ref('SI_USERS') }}
GROUP BY USER_ID
HAVING COUNT(*) > 1
```

#### 4. Data Quality Score Validation Test
```sql
-- tests/test_data_quality_score.sql
SELECT 
    USER_ID,
    DATA_QUALITY_SCORE,
    'Invalid data quality score' AS error_message
FROM {{ ref('SI_USERS') }}
WHERE DATA_QUALITY_SCORE < 0 
   OR DATA_QUALITY_SCORE > 100
   OR DATA_QUALITY_SCORE IS NULL
```

#### 5. Meeting Duration Validation Test
```sql
-- tests/test_meeting_duration_validation.sql
SELECT 
    MEETING_ID,
    START_TIME_UTC,
    END_TIME_UTC,
    DURATION_MINUTES,
    'Invalid meeting duration' AS error_message
FROM {{ ref('SI_MEETINGS') }}
WHERE DURATION_MINUTES < 0 
   OR (START_TIME_UTC >= END_TIME_UTC AND END_TIME_UTC IS NOT NULL)
```

#### 6. Billing Amount Validation Test
```sql
-- tests/test_billing_amount_validation.sql
SELECT 
    EVENT_ID,
    AMOUNT,
    'Invalid billing amount' AS error_message
FROM {{ ref('SI_BILLING_EVENTS') }}
WHERE AMOUNT <= 0 
   OR ROUND(AMOUNT, 2) != AMOUNT
   OR AMOUNT IS NULL
```

#### 7. License Date Logic Test
```sql
-- tests/test_license_date_logic.sql
SELECT 
    LICENSE_ID,
    START_DATE,
    END_DATE,
    'Invalid license date logic' AS error_message
FROM {{ ref('SI_LICENSES') }}
WHERE START_DATE >= END_DATE
   OR START_DATE IS NULL
   OR END_DATE IS NULL
```

#### 8. Audit Log Completeness Test
```sql
-- tests/test_audit_log_completeness.sql
SELECT 
    PROCESS_NAME,
    'Missing audit log entry' AS error_message
FROM (
    SELECT 'SI_USERS' AS expected_process
    UNION ALL SELECT 'SI_MEETINGS'
    UNION ALL SELECT 'SI_PARTICIPANTS'
    UNION ALL SELECT 'SI_FEATURE_USAGE'
    UNION ALL SELECT 'SI_SUPPORT_TICKETS'
    UNION ALL SELECT 'SI_BILLING_EVENTS'
    UNION ALL SELECT 'SI_LICENSES'
) expected
WHERE expected_process NOT IN (
    SELECT DISTINCT PROCESS_NAME 
    FROM {{ ref('SI_Audit_Log') }}
    WHERE PROCESS_DATE = CURRENT_DATE
)
```

#### 9. Referential Integrity Test
```sql
-- tests/test_referential_integrity.sql
SELECT 
    p.PARTICIPANT_ID,
    p.MEETING_ID,
    'Orphaned participant record' AS error_message
FROM {{ ref('SI_PARTICIPANTS') }} p
LEFT JOIN {{ ref('SI_MEETINGS') }} m ON p.MEETING_ID = m.MEETING_ID
WHERE m.MEETING_ID IS NULL
```

#### 10. Timestamp Format Validation Test
```sql
-- tests/test_timestamp_format_validation.sql
SELECT 
    PARTICIPANT_ID,
    ORIGINAL_JOIN_TIME,
    'Invalid timestamp format' AS error_message
FROM {{ ref('SI_PARTICIPANTS') }}
WHERE ORIGINAL_JOIN_TIME IS NOT NULL
  AND TRY_TO_TIMESTAMP(ORIGINAL_JOIN_TIME, 'MM/DD/YYYY HH24:MI') IS NULL
  AND REGEXP_LIKE(ORIGINAL_JOIN_TIME, '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$')
```

---

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Execute custom SQL tests in development environment
- Validate data quality thresholds

### 2. Post-deployment Validation
- Verify audit log entries
- Check data lineage completeness
- Validate transformation accuracy

### 3. Continuous Monitoring
- Schedule daily test runs
- Monitor test results in dbt Cloud
- Alert on test failures

### 4. Performance Testing
- Monitor query execution times
- Validate materialization performance
- Check Snowflake resource utilization

---

## Test Results Tracking

### dbt Test Results
- Results stored in `run_results.json`
- Test status: PASS/FAIL/WARN
- Execution timestamps
- Error details and row counts

### Snowflake Audit Schema
- Test execution logs in `AUDIT_SCHEMA.TEST_RESULTS`
- Performance metrics tracking
- Historical test result trends
- Data quality score tracking

---

## Error Handling and Recovery

### 1. Test Failure Response
- Immediate notification to data team
- Automatic rollback procedures
- Root cause analysis workflow

### 2. Data Quality Issues
- Quarantine invalid records
- Apply data correction rules
- Manual review process for edge cases

### 3. Performance Degradation
- Query optimization recommendations
- Resource scaling procedures
- Alternative execution strategies

---

## Maintenance and Updates

### 1. Test Case Evolution
- Regular review of test coverage
- Addition of new edge cases
- Business rule updates

### 2. Performance Optimization
- Test execution time monitoring
- Query optimization for large datasets
- Parallel test execution strategies

### 3. Documentation Updates
- Test case documentation maintenance
- Business rule change tracking
- Version control for test scripts

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Silver Layer dbt models in Snowflake. The combination of schema tests, custom SQL tests, and continuous monitoring provides robust data quality assurance and early detection of potential issues in the data transformation pipeline.

The test cases cover all critical aspects including data validation, business rule compliance, timestamp handling, referential integrity, and audit trail completeness. Regular execution of these tests will maintain high data quality standards and support confident decision-making based on the transformed data.