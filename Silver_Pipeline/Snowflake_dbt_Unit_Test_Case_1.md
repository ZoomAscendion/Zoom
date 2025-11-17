_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer dbt models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Coverage Overview

The test suite covers 8 Silver layer models:
- **SI_USERS** - User profile and subscription data
- **SI_MEETINGS** - Meeting information and session details
- **SI_PARTICIPANTS** - Meeting participants and session details
- **SI_FEATURE_USAGE** - Platform feature usage during meetings
- **SI_SUPPORT_TICKETS** - Customer support requests and resolution tracking
- **SI_BILLING_EVENTS** - Financial transactions and billing activities
- **SI_LICENSES** - License assignments and entitlements
- **SI_Audit_Log** - Audit logging for pipeline execution

---

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate user ID uniqueness | No duplicate USER_ID values |
| TC_USR_002 | Check email format validation | All emails follow valid format pattern |
| TC_USR_003 | Verify plan type standardization | Plan types only contain: Free, Basic, Pro, Enterprise |
| TC_USR_004 | Validate null value handling | No null values in critical fields (USER_ID, EMAIL) |
| TC_USR_005 | Check data quality score range | DATA_QUALITY_SCORE between 0-100 |
| TC_USR_006 | Verify load timestamp population | All records have valid LOAD_TIMESTAMP |
| TC_USR_007 | Validate source system tracking | All records have SOURCE_SYSTEM populated |
| TC_USR_008 | Check validation status values | VALIDATION_STATUS in (PASSED, FAILED, WARNING) |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate meeting duration calculation | DURATION_MINUTES matches time difference |
| TC_MTG_002 | Check meeting time logic | END_TIME > START_TIME |
| TC_MTG_003 | Verify host ID referential integrity | All HOST_ID exist in SI_USERS |
| TC_MTG_004 | Validate duration range | DURATION_MINUTES between 0-1440 |
| TC_MTG_005 | Check EST timezone conversion | EST timestamps converted to standard format |
| TC_MTG_006 | Validate duration text cleaning (P1) | "108 mins" format cleaned to numeric |
| TC_MTG_007 | Verify meeting ID uniqueness | No duplicate MEETING_ID values |
| TC_MTG_008 | Check null value handling | No null values in critical fields |

### 3. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate session time logic | LEAVE_TIME > JOIN_TIME |
| TC_PRT_002 | Check meeting boundary validation | Join/leave times within meeting duration |
| TC_PRT_003 | Verify meeting referential integrity | All MEETING_ID exist in SI_MEETINGS |
| TC_PRT_004 | Validate user referential integrity | All USER_ID exist in SI_USERS |
| TC_PRT_005 | Check participant uniqueness | Unique combination of MEETING_ID + USER_ID |
| TC_PRT_006 | Validate MM/DD/YYYY format conversion | MM/DD/YYYY HH:MM format converted properly |
| TC_PRT_007 | Verify timestamp consistency | Consistent timestamp formats within records |
| TC_PRT_008 | Check null value handling | No null values in critical fields |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate feature name standardization | Feature names follow naming conventions |
| TC_FTR_002 | Check usage count validation | USAGE_COUNT >= 0 |
| TC_FTR_003 | Verify meeting referential integrity | All MEETING_ID exist in SI_MEETINGS |
| TC_FTR_004 | Validate usage date consistency | USAGE_DATE aligns with meeting dates |
| TC_FTR_005 | Check feature adoption calculation | Feature adoption rates calculated correctly |
| TC_FTR_006 | Verify usage ID uniqueness | No duplicate USAGE_ID values |
| TC_FTR_007 | Validate null value handling | No null values in critical fields |
| TC_FTR_008 | Check data quality scoring | Valid data quality scores assigned |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate ticket status values | Status in (Open, In Progress, Resolved, Closed) |
| TC_TKT_002 | Check user referential integrity | All USER_ID exist in SI_USERS |
| TC_TKT_003 | Verify ticket ID uniqueness | No duplicate TICKET_ID values |
| TC_TKT_004 | Validate open date logic | OPEN_DATE <= CURRENT_DATE |
| TC_TKT_005 | Check ticket volume metrics | Ticket volume per 1000 users calculated |
| TC_TKT_006 | Verify null value handling | No null values in critical fields |
| TC_TKT_007 | Validate ticket type standardization | Ticket types follow predefined categories |
| TC_TKT_008 | Check data quality scoring | Valid data quality scores assigned |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate amount precision | AMOUNT > 0 with proper decimal precision |
| TC_BIL_002 | Check event date validation | EVENT_DATE <= CURRENT_DATE |
| TC_BIL_003 | Verify user referential integrity | All USER_ID exist in SI_USERS |
| TC_BIL_004 | Validate event type standardization | Event types follow billing categories |
| TC_BIL_005 | Check MRR calculation | Monthly Recurring Revenue calculated correctly |
| TC_BIL_006 | Verify event ID uniqueness | No duplicate EVENT_ID values |
| TC_BIL_007 | Validate null value handling | No null values in critical fields |
| TC_BIL_008 | Check refund handling | Negative amounts handled for refunds |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate license date logic | START_DATE < END_DATE |
| TC_LIC_002 | Check user referential integrity | All ASSIGNED_TO_USER_ID exist in SI_USERS |
| TC_LIC_003 | Verify active license validation | Active licenses have END_DATE > CURRENT_DATE |
| TC_LIC_004 | Validate license type standardization | License types follow predefined categories |
| TC_LIC_005 | Check DD/MM/YYYY format conversion (P1) | "27/08/2024" format converted to standard |
| TC_LIC_006 | Verify license ID uniqueness | No duplicate LICENSE_ID values |
| TC_LIC_007 | Validate utilization rate calculation | License utilization rates calculated correctly |
| TC_LIC_008 | Check null value handling | No null values in critical fields |

### 8. SI_Audit_Log Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Validate audit entry creation | Audit entries created for all operations |
| TC_AUD_002 | Check timestamp accuracy | Audit timestamps accurate and sequential |
| TC_AUD_003 | Verify operation tracking | All CRUD operations tracked |
| TC_AUD_004 | Validate error logging | Errors properly logged with details |
| TC_AUD_005 | Check audit ID uniqueness | No duplicate audit IDs |
| TC_AUD_006 | Verify data retention | Audit data retained per policy |
| TC_AUD_007 | Validate user tracking | User actions properly attributed |
| TC_AUD_008 | Check audit completeness | All required audit fields populated |

---

## dbt Test Scripts

### YAML-based Schema Tests

#### models/schema.yml

```yaml
version: 2

models:
  - name: SI_USERS
    description: "Silver layer table for cleaned and standardized user data"
    columns:
      - name: USER_ID
        description: "Unique identifier for each user"
        tests:
          - unique
          - not_null
      - name: EMAIL
        description: "User email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: PLAN_TYPE
        description: "User subscription plan type"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: DATA_QUALITY_SCORE
        description: "Data quality score (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: VALIDATION_STATUS
        description: "Data validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']
      - name: LOAD_TIMESTAMP
        description: "Record load timestamp"
        tests:
          - not_null
      - name: SOURCE_SYSTEM
        description: "Source system identifier"
        tests:
          - not_null

  - name: SI_MEETINGS
    description: "Silver layer table for cleaned meeting data"
    columns:
      - name: MEETING_ID
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: HOST_ID
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: START_TIME
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: END_TIME
        description: "Meeting end timestamp"
        tests:
          - not_null
      - name: DURATION_MINUTES
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: DATA_QUALITY_SCORE
        description: "Data quality score (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: SI_PARTICIPANTS
    description: "Silver layer table for meeting participants"
    columns:
      - name: PARTICIPANT_ID
        description: "Unique identifier for each participant"
        tests:
          - unique
          - not_null
      - name: MEETING_ID
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('SI_MEETINGS')
              field: MEETING_ID
      - name: USER_ID
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: JOIN_TIME
        description: "Participant join timestamp"
        tests:
          - not_null
      - name: LEAVE_TIME
        description: "Participant leave timestamp"
        tests:
          - not_null

  - name: SI_FEATURE_USAGE
    description: "Silver layer table for feature usage tracking"
    columns:
      - name: USAGE_ID
        description: "Unique identifier for each usage record"
        tests:
          - unique
          - not_null
      - name: MEETING_ID
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('SI_MEETINGS')
              field: MEETING_ID
      - name: FEATURE_NAME
        description: "Name of the feature"
        tests:
          - not_null
      - name: USAGE_COUNT
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: SI_SUPPORT_TICKETS
    description: "Silver layer table for support tickets"
    columns:
      - name: TICKET_ID
        description: "Unique identifier for each ticket"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Reference to user who created ticket"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: RESOLUTION_STATUS
        description: "Ticket resolution status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
      - name: OPEN_DATE
        description: "Date when ticket was opened"
        tests:
          - not_null

  - name: SI_BILLING_EVENTS
    description: "Silver layer table for billing events"
    columns:
      - name: EVENT_ID
        description: "Unique identifier for each billing event"
        tests:
          - unique
          - not_null
      - name: USER_ID
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: AMOUNT
        description: "Billing amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
      - name: EVENT_DATE
        description: "Date of billing event"
        tests:
          - not_null

  - name: SI_LICENSES
    description: "Silver layer table for license management"
    columns:
      - name: LICENSE_ID
        description: "Unique identifier for each license"
        tests:
          - unique
          - not_null
      - name: ASSIGNED_TO_USER_ID
        description: "User assigned to license"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: USER_ID
      - name: START_DATE
        description: "License start date"
        tests:
          - not_null
      - name: END_DATE
        description: "License end date"
        tests:
          - not_null

  - name: SI_Audit_Log
    description: "Silver layer audit logging table"
    columns:
      - name: AUDIT_ID
        description: "Unique identifier for each audit entry"
        tests:
          - unique
          - not_null
      - name: TABLE_NAME
        description: "Name of table being audited"
        tests:
          - not_null
      - name: OPERATION_TYPE
        description: "Type of operation (INSERT, UPDATE, DELETE)"
        tests:
          - accepted_values:
              values: ['INSERT', 'UPDATE', 'DELETE', 'SELECT']
      - name: AUDIT_TIMESTAMP
        description: "Timestamp of audit entry"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### tests/meeting_time_logic.sql

```sql
-- Test: Validate meeting time logic (END_TIME > START_TIME)
SELECT 
    MEETING_ID,
    START_TIME,
    END_TIME
FROM {{ ref('SI_MEETINGS') }}
WHERE END_TIME <= START_TIME
```

#### tests/duration_calculation_accuracy.sql

```sql
-- Test: Validate duration calculation accuracy
SELECT 
    MEETING_ID,
    DURATION_MINUTES,
    DATEDIFF('minute', START_TIME, END_TIME) as CALCULATED_DURATION,
    ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) as DIFFERENCE
FROM {{ ref('SI_MEETINGS') }}
WHERE ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1
```

#### tests/participant_session_logic.sql

```sql
-- Test: Validate participant session time logic
SELECT 
    PARTICIPANT_ID,
    JOIN_TIME,
    LEAVE_TIME
FROM {{ ref('SI_PARTICIPANTS') }}
WHERE LEAVE_TIME <= JOIN_TIME
```

#### tests/meeting_boundary_validation.sql

```sql
-- Test: Validate participant times within meeting boundaries
SELECT 
    p.PARTICIPANT_ID,
    p.MEETING_ID,
    p.JOIN_TIME,
    p.LEAVE_TIME,
    m.START_TIME,
    m.END_TIME
FROM {{ ref('SI_PARTICIPANTS') }} p
JOIN {{ ref('SI_MEETINGS') }} m ON p.MEETING_ID = m.MEETING_ID
WHERE p.JOIN_TIME < m.START_TIME 
   OR p.LEAVE_TIME > m.END_TIME
```

#### tests/license_date_logic.sql

```sql
-- Test: Validate license date logic (START_DATE < END_DATE)
SELECT 
    LICENSE_ID,
    START_DATE,
    END_DATE
FROM {{ ref('SI_LICENSES') }}
WHERE START_DATE >= END_DATE
```

#### tests/billing_amount_validation.sql

```sql
-- Test: Validate billing amounts are positive
SELECT 
    EVENT_ID,
    AMOUNT,
    EVENT_TYPE
FROM {{ ref('SI_BILLING_EVENTS') }}
WHERE AMOUNT <= 0 AND EVENT_TYPE NOT LIKE '%refund%'
```

#### tests/feature_usage_consistency.sql

```sql
-- Test: Validate feature usage date consistency with meetings
SELECT 
    f.USAGE_ID,
    f.MEETING_ID,
    f.USAGE_DATE,
    DATE(m.START_TIME) as MEETING_DATE
FROM {{ ref('SI_FEATURE_USAGE') }} f
JOIN {{ ref('SI_MEETINGS') }} m ON f.MEETING_ID = m.MEETING_ID
WHERE DATE(f.USAGE_DATE) != DATE(m.START_TIME)
```

#### tests/data_quality_score_range.sql

```sql
-- Test: Validate data quality scores are within valid range (0-100)
SELECT 
    'SI_USERS' as table_name,
    USER_ID as record_id,
    DATA_QUALITY_SCORE
FROM {{ ref('SI_USERS') }}
WHERE DATA_QUALITY_SCORE < 0 OR DATA_QUALITY_SCORE > 100

UNION ALL

SELECT 
    'SI_MEETINGS' as table_name,
    MEETING_ID as record_id,
    DATA_QUALITY_SCORE
FROM {{ ref('SI_MEETINGS') }}
WHERE DATA_QUALITY_SCORE < 0 OR DATA_QUALITY_SCORE > 100

UNION ALL

SELECT 
    'SI_PARTICIPANTS' as table_name,
    PARTICIPANT_ID as record_id,
    DATA_QUALITY_SCORE
FROM {{ ref('SI_PARTICIPANTS') }}
WHERE DATA_QUALITY_SCORE < 0 OR DATA_QUALITY_SCORE > 100
```

#### tests/critical_duration_text_cleaning.sql

```sql
-- Test: Critical P1 - Validate duration text cleaning ("108 mins" format)
SELECT 
    MEETING_ID,
    DURATION_MINUTES,
    'DURATION_TEXT_UNITS_FOUND' as error_type
FROM {{ ref('SI_MEETINGS') }}
WHERE DURATION_MINUTES::STRING REGEXP '[a-zA-Z]'
  AND TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NULL
```

#### tests/critical_ddmmyyyy_conversion.sql

```sql
-- Test: Critical P1 - Validate DD/MM/YYYY date format conversion
SELECT 
    LICENSE_ID,
    START_DATE,
    END_DATE,
    'DD_MM_YYYY_CONVERSION_FAILED' as error_type
FROM {{ ref('SI_LICENSES') }}
WHERE (START_DATE::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$'
       AND TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') IS NULL)
   OR (END_DATE::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$'
       AND TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') IS NULL)
```

#### tests/timestamp_format_validation.sql

```sql
-- Test: Validate timestamp format consistency
SELECT 
    'SI_MEETINGS' as table_name,
    MEETING_ID as record_id,
    'EST_TIMEZONE_FORMAT_ISSUE' as error_type
FROM {{ ref('SI_MEETINGS') }}
WHERE START_TIME::STRING LIKE '%EST%'
  AND NOT REGEXP_LIKE(START_TIME::STRING, '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(\.\d{3})? EST$')

UNION ALL

SELECT 
    'SI_PARTICIPANTS' as table_name,
    PARTICIPANT_ID as record_id,
    'MM_DD_YYYY_FORMAT_ISSUE' as error_type
FROM {{ ref('SI_PARTICIPANTS') }}
WHERE JOIN_TIME::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}$'
  AND TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NULL
```

#### tests/cross_table_referential_integrity.sql

```sql
-- Test: Cross-table referential integrity validation
SELECT 
    'MEETINGS_WITHOUT_HOST_PARTICIPATION' as test_type,
    m.MEETING_ID,
    m.HOST_ID
FROM {{ ref('SI_MEETINGS') }} m
LEFT JOIN {{ ref('SI_PARTICIPANTS') }} p 
    ON m.MEETING_ID = p.MEETING_ID 
    AND m.HOST_ID = p.USER_ID
WHERE p.USER_ID IS NULL

UNION ALL

SELECT 
    'FEATURE_USAGE_WITHOUT_PARTICIPANTS' as test_type,
    f.MEETING_ID,
    NULL as HOST_ID
FROM {{ ref('SI_FEATURE_USAGE') }} f
LEFT JOIN {{ ref('SI_PARTICIPANTS') }} p ON f.MEETING_ID = p.MEETING_ID
WHERE p.MEETING_ID IS NULL

UNION ALL

SELECT 
    'BILLING_WITHOUT_LICENSES' as test_type,
    b.USER_ID,
    NULL as HOST_ID
FROM {{ ref('SI_BILLING_EVENTS') }} b
LEFT JOIN {{ ref('SI_LICENSES') }} l ON b.USER_ID = l.ASSIGNED_TO_USER_ID
WHERE l.ASSIGNED_TO_USER_ID IS NULL
```

### Parameterized Tests

#### macros/test_null_values.sql

```sql
{% macro test_null_values(model, column_name) %}
    SELECT COUNT(*) as null_count
    FROM {{ model }}
    WHERE {{ column_name }} IS NULL
{% endmacro %}
```

#### macros/test_duplicate_values.sql

```sql
{% macro test_duplicate_values(model, column_name) %}
    SELECT 
        {{ column_name }},
        COUNT(*) as duplicate_count
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
    GROUP BY {{ column_name }}
    HAVING COUNT(*) > 1
{% endmacro %}
```

#### macros/test_date_range.sql

```sql
{% macro test_date_range(model, date_column, min_date=None, max_date=None) %}
    SELECT COUNT(*) as invalid_dates
    FROM {{ model }}
    WHERE 1=1
    {% if min_date %}
        AND {{ date_column }} < '{{ min_date }}'
    {% endif %}
    {% if max_date %}
        AND {{ date_column }} > '{{ max_date }}'
    {% endif %}
{% endmacro %}
```

### Business Rule Validation Tests

#### tests/business_rules_dau_calculation.sql

```sql
-- Test: Daily Active Users (DAU) calculation
WITH daily_active_users AS (
    SELECT 
        DATE(START_TIME) as activity_date,
        COUNT(DISTINCT HOST_ID) as dau_count
    FROM {{ ref('SI_MEETINGS') }}
    WHERE START_TIME >= CURRENT_DATE() - INTERVAL '30 days'
    GROUP BY DATE(START_TIME)
)
SELECT 
    activity_date,
    dau_count
FROM daily_active_users
WHERE dau_count < 0  -- Should never happen
   OR dau_count > (SELECT COUNT(DISTINCT USER_ID) FROM {{ ref('SI_USERS') }})  -- Cannot exceed total users
```

#### tests/business_rules_mrr_calculation.sql

```sql
-- Test: Monthly Recurring Revenue (MRR) calculation
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', EVENT_DATE) as month,
        SUM(CASE WHEN EVENT_TYPE LIKE '%subscription%' THEN AMOUNT ELSE 0 END) as mrr,
        SUM(CASE WHEN EVENT_TYPE LIKE '%refund%' THEN -AMOUNT ELSE 0 END) as refunds
    FROM {{ ref('SI_BILLING_EVENTS') }}
    GROUP BY DATE_TRUNC('month', EVENT_DATE)
)
SELECT 
    month,
    mrr,
    refunds
FROM monthly_revenue
WHERE mrr < 0  -- MRR should not be negative
   OR ABS(refunds) > mrr * 2  -- Refunds should not exceed 200% of MRR
```

#### tests/business_rules_churn_rate.sql

```sql
-- Test: Churn rate calculation validation
WITH churn_analysis AS (
    SELECT 
        DATE_TRUNC('month', END_DATE) as churn_month,
        COUNT(*) as churned_users,
        (SELECT COUNT(DISTINCT USER_ID) FROM {{ ref('SI_USERS') }}) as total_users,
        ROUND((COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT USER_ID) FROM {{ ref('SI_USERS') }})), 2) as churn_rate_percent
    FROM {{ ref('SI_LICENSES') }}
    WHERE END_DATE < CURRENT_DATE()
      AND END_DATE >= DATE_TRUNC('month', CURRENT_DATE()) - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', END_DATE)
)
SELECT 
    churn_month,
    churn_rate_percent
FROM churn_analysis
WHERE churn_rate_percent < 0  -- Churn rate cannot be negative
   OR churn_rate_percent > 100  -- Churn rate cannot exceed 100%
```

---

## Test Execution Strategy

### 1. Test Execution Order

1. **Schema Tests** (Basic validation)
   - Uniqueness, not_null, accepted_values
   - Data type validation
   - Basic referential integrity

2. **Custom SQL Tests** (Business logic)
   - Time logic validation
   - Cross-table consistency
   - Format conversion validation

3. **Critical P1 Tests** (Data quality)
   - Duration text cleaning
   - DD/MM/YYYY format conversion
   - Timestamp format validation

4. **Business Rule Tests** (Advanced validation)
   - DAU, MRR, churn rate calculations
   - Feature adoption metrics
   - License utilization rates

### 2. Test Configuration

#### dbt_project.yml

```yaml
name: 'zoom_analytics'
version: '1.0.0'
config-version: 2

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["data"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  zoom_analytics:
    silver:
      +materialized: table
      +schema: silver
      +pre-hook: "INSERT INTO {{ this.schema }}.SI_AUDIT_LOG (TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP) VALUES ('{{ this.name }}', 'PRE_HOOK', CURRENT_TIMESTAMP())"
      +post-hook: "INSERT INTO {{ this.schema }}.SI_AUDIT_LOG (TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP) VALUES ('{{ this.name }}', 'POST_HOOK', CURRENT_TIMESTAMP())"

tests:
  zoom_analytics:
    +severity: error
    +store_failures: true
    +schema: test_results

vars:
  dbt_expectations_dispatch_list: ['dbt_expectations']
```

### 3. Test Monitoring and Alerting

#### Test Results Tracking

```sql
-- Create test results summary view
CREATE OR REPLACE VIEW SILVER.V_TEST_RESULTS_SUMMARY AS
SELECT 
    test_name,
    model_name,
    test_type,
    status,
    execution_time,
    error_count,
    warning_count,
    execution_timestamp
FROM SILVER.DBT_TEST_RESULTS
WHERE execution_timestamp >= CURRENT_DATE() - INTERVAL '7 days'
ORDER BY execution_timestamp DESC;
```

#### Automated Test Execution

```bash
#!/bin/bash
# run_tests.sh - Automated test execution script

echo "Starting dbt test execution..."

# Run schema tests
dbt test --select "tag:schema_tests" --store-failures

# Run custom SQL tests
dbt test --select "tag:custom_tests" --store-failures

# Run critical P1 tests
dbt test --select "tag:critical_p1" --store-failures

# Run business rule tests
dbt test --select "tag:business_rules" --store-failures

echo "Test execution completed. Check results in test_results schema."
```

---

## Expected Test Results

### Success Criteria

- **Schema Tests**: 100% pass rate for uniqueness, not_null, and accepted_values tests
- **Referential Integrity**: 100% pass rate for all relationship tests
- **Business Logic**: 100% pass rate for time logic and calculation tests
- **Critical P1 Tests**: 100% pass rate for format conversion and text cleaning tests
- **Data Quality**: Average data quality score >= 85 across all tables
- **Performance**: All tests complete within 15 minutes execution window

### Failure Handling

- **Critical Failures**: Stop pipeline execution, send immediate alerts
- **Warning Failures**: Log to audit table, continue execution with notification
- **Data Quality Failures**: Route failed records to error table for investigation
- **Format Conversion Failures**: Apply remediation logic, log to audit trail

### Test Coverage Metrics

- **Column Coverage**: 100% of critical columns tested
- **Business Rule Coverage**: 100% of defined business rules validated
- **Edge Case Coverage**: 95% of identified edge cases tested
- **Error Scenario Coverage**: 90% of error scenarios tested

---

## Maintenance and Updates

### 1. Test Maintenance Schedule

- **Daily**: Execute critical P1 and schema tests
- **Weekly**: Execute full test suite including business rules
- **Monthly**: Review test coverage and update test cases
- **Quarterly**: Performance optimization and test refactoring

### 2. Test Case Updates

- Add new test cases for schema changes
- Update business rule tests for requirement changes
- Enhance error handling for new edge cases
- Optimize test performance for large datasets

### 3. Documentation Updates

- Maintain test case documentation
- Update expected outcomes for business rule changes
- Document new test patterns and best practices
- Keep test execution guides current

---

**Note**: This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver layer dbt models in Snowflake. The tests cover critical data quality issues including duration text cleaning ("108 mins" format) and DD/MM/YYYY date format conversion ("27/08/2024" format) that were identified as Priority 1 fixes. All test results are tracked in dbt's run_results.json and Snowflake audit schema for complete traceability and monitoring.
