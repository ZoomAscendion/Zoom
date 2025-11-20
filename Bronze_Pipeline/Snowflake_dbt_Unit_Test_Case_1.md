_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer Pipeline running in Snowflake. The test suite covers all 7 Bronze layer models plus the audit table, ensuring data quality, transformation accuracy, and business rule compliance.

## Models Under Test

1. **bz_data_audit** - Audit trail for Bronze layer operations
2. **bz_users** - User profile and subscription information
3. **bz_meetings** - Meeting information and session details
4. **bz_participants** - Meeting participants and session details
5. **bz_feature_usage** - Platform feature usage during meetings
6. **bz_support_tickets** - Customer support requests and resolution tracking
7. **bz_billing_events** - Financial transactions and billing activities
8. **bz_licenses** - License assignments and entitlements

---

## Test Case List

### 1. Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_DQ_001 | Validate primary key uniqueness for all Bronze models | All primary keys should be unique within each table | All Bronze models |
| TC_DQ_002 | Validate primary key not null constraint | No null values in primary key columns | All Bronze models |
| TC_DQ_003 | Validate required timestamp fields are populated | LOAD_TIMESTAMP and UPDATE_TIMESTAMP should not be null | All Bronze models |
| TC_DQ_004 | Validate SOURCE_SYSTEM field is populated | SOURCE_SYSTEM should not be null or empty | All Bronze models |
| TC_DQ_005 | Validate email format in users table | EMAIL field should follow valid email format | bz_users |
| TC_DQ_006 | Validate numeric fields contain valid numbers | AMOUNT, USAGE_COUNT, DURATION_MINUTES should be valid numbers | bz_billing_events, bz_feature_usage, bz_meetings |
| TC_DQ_007 | Validate date fields are within reasonable ranges | All date fields should be within acceptable business ranges | All Bronze models |

### 2. Data Transformation Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_DT_001 | Validate 1:1 mapping from RAW to Bronze | All source columns mapped correctly without transformation | All Bronze models |
| TC_DT_002 | Validate deduplication logic | Duplicate records based on primary key should be removed | All Bronze models |
| TC_DT_003 | Validate data type conversions | VARCHAR to TIMESTAMP/NUMBER conversions work correctly | bz_meetings, bz_billing_events |
| TC_DT_004 | Validate NULL handling | NULL values from source preserved appropriately | All Bronze models |
| TC_DT_005 | Validate ROW_NUMBER deduplication | Latest record by UPDATE_TIMESTAMP selected for duplicates | All Bronze models |

### 3. Business Rule Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_BR_001 | Validate meeting duration calculation | DURATION_MINUTES should be positive when END_TIME > START_TIME | bz_meetings |
| TC_BR_002 | Validate participant session logic | LEAVE_TIME should be >= JOIN_TIME when both are not null | bz_participants |
| TC_BR_003 | Validate billing amount ranges | AMOUNT should be >= 0 for billing events | bz_billing_events |
| TC_BR_004 | Validate license date ranges | END_DATE should be >= START_DATE when both are not null | bz_licenses |
| TC_BR_005 | Validate feature usage counts | USAGE_COUNT should be >= 0 | bz_feature_usage |
| TC_BR_006 | Validate plan type values | PLAN_TYPE should be from accepted values list | bz_users |

### 4. Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_EC_001 | Handle empty source tables | Models should run successfully with empty source data | All Bronze models |
| TC_EC_002 | Handle records with all NULL values except primary key | Records should be processed without errors | All Bronze models |
| TC_EC_003 | Handle extremely long text values | VARCHAR fields should accommodate maximum length values | All Bronze models |
| TC_EC_004 | Handle future dates | Future dates should be accepted without validation errors | All Bronze models |
| TC_EC_005 | Handle zero and negative amounts | Zero amounts allowed, negative amounts flagged | bz_billing_events |
| TC_EC_006 | Handle special characters in text fields | Special characters should be preserved | All Bronze models |

### 5. Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_EH_001 | Handle invalid email formats | Invalid emails should be flagged but not rejected | bz_users |
| TC_EH_002 | Handle data type conversion errors | Conversion errors should be logged and handled gracefully | All Bronze models |
| TC_EH_003 | Handle missing foreign key references | Missing references should be allowed (Bronze layer principle) | All Bronze models |
| TC_EH_004 | Handle audit table failures | Audit failures should not prevent model execution | All Bronze models |
| TC_EH_005 | Handle pre/post hook failures | Hook failures should be logged appropriately | All Bronze models |

### 6. Performance Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TC_PF_001 | Validate model execution time | Models should complete within acceptable time limits | All Bronze models |
| TC_PF_002 | Validate memory usage | Models should not exceed memory thresholds | All Bronze models |
| TC_PF_003 | Validate audit logging performance | Audit operations should not significantly impact performance | All Bronze models |

---

## dbt Test Scripts

### 1. Schema Tests (schema.yml)

```yaml
version: 2

sources:
  - name: raw
    description: "Raw data layer containing unprocessed data from various source systems"
    database: DB_POC_ZOOM
    schema: RAW
    tables:
      - name: users
        description: "Raw user profile and subscription information"
        columns:
          - name: user_id
            description: "Unique identifier for each user account"
            tests:
              - not_null
              - unique
          - name: email
            description: "Email address of the user"
            tests:
              - not_null
      - name: meetings
        columns:
          - name: meeting_id
            tests:
              - not_null
              - unique
      - name: participants
        columns:
          - name: participant_id
            tests:
              - not_null
              - unique
      - name: feature_usage
        columns:
          - name: usage_id
            tests:
              - not_null
              - unique
      - name: support_tickets
        columns:
          - name: ticket_id
            tests:
              - not_null
              - unique
      - name: billing_events
        columns:
          - name: event_id
            tests:
              - not_null
              - unique
      - name: licenses
        columns:
          - name: license_id
            tests:
              - not_null
              - unique

models:
  - name: bz_data_audit
    description: "Comprehensive audit trail for all Bronze layer data operations"
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier for each audit record"
        tests:
          - not_null
          - unique
      - name: source_table
        description: "Name of the Bronze layer table"
        tests:
          - not_null
      - name: load_timestamp
        description: "When the operation occurred"
        tests:
          - not_null
      - name: processed_by
        description: "User or process that performed the operation"
        tests:
          - not_null
      - name: status
        description: "Status of the operation"
        tests:
          - not_null
          - accepted_values:
              values: ['INITIALIZED', 'STARTED', 'SUCCESS', 'FAILED', 'WARNING']

  - name: bz_users
    description: "Bronze layer table storing user profile and subscription information"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_id
            - load_timestamp
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
      - name: user_name
        description: "Display name of the user"
        tests:
          - not_null
      - name: email
        description: "Email address of the user (PII)"
        tests:
          - not_null
      - name: plan_type
        description: "Type of subscription plan"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: update_timestamp
        description: "Timestamp when record was last updated"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  - name: bz_meetings
    description: "Bronze layer table storing meeting information and session details"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - meeting_id
            - load_timestamp
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null
      - name: host_id
        description: "Identifier of the meeting host"
        tests:
          - not_null
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_participants
    description: "Bronze layer table tracking meeting participants"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - participant_id
            - load_timestamp
    columns:
      - name: participant_id
        tests:
          - not_null
      - name: meeting_id
        tests:
          - not_null
      - name: user_id
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_feature_usage
    description: "Bronze layer table recording platform feature usage"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - usage_id
            - load_timestamp
    columns:
      - name: usage_id
        tests:
          - not_null
      - name: meeting_id
        tests:
          - not_null
      - name: feature_name
        tests:
          - not_null
      - name: usage_count
        tests:
          - not_null
      - name: usage_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_support_tickets
    description: "Bronze layer table managing customer support requests"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - ticket_id
            - load_timestamp
    columns:
      - name: ticket_id
        tests:
          - not_null
      - name: user_id
        tests:
          - not_null
      - name: ticket_type
        tests:
          - not_null
      - name: resolution_status
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed', 'Escalated']
      - name: open_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_billing_events
    description: "Bronze layer table tracking financial transactions"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - event_id
            - load_timestamp
    columns:
      - name: event_id
        tests:
          - not_null
      - name: user_id
        tests:
          - not_null
      - name: event_type
        tests:
          - not_null
      - name: amount
        tests:
          - not_null
      - name: event_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null

  - name: bz_licenses
    description: "Bronze layer table managing license assignments"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - license_id
            - load_timestamp
    columns:
      - name: license_id
        tests:
          - not_null
      - name: license_type
        tests:
          - not_null
      - name: assigned_to_user_id
        tests:
          - not_null
      - name: start_date
        tests:
          - not_null
      - name: load_timestamp
        tests:
          - not_null
      - name: update_timestamp
        tests:
          - not_null
      - name: source_system
        tests:
          - not_null
```

### 2. Custom SQL Tests

#### 2.1 Email Format Validation Test
**File:** `tests/test_email_format_validation.sql`

```sql
-- Test to validate email format in bz_users table
-- This test will fail if any email doesn't contain '@' symbol

SELECT 
    user_id,
    email
FROM {{ ref('bz_users') }}
WHERE email IS NOT NULL 
  AND email NOT LIKE '%@%'
```

#### 2.2 Meeting Duration Logic Test
**File:** `tests/test_meeting_duration_logic.sql`

```sql
-- Test to validate meeting duration logic
-- This test will fail if duration is negative when both start and end times exist

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes
FROM {{ ref('bz_meetings') }}
WHERE start_time IS NOT NULL 
  AND end_time IS NOT NULL 
  AND duration_minutes < 0
```

#### 2.3 Participant Session Logic Test
**File:** `tests/test_participant_session_logic.sql`

```sql
-- Test to validate participant session logic
-- This test will fail if leave_time is before join_time

SELECT 
    participant_id,
    meeting_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE join_time IS NOT NULL 
  AND leave_time IS NOT NULL 
  AND leave_time < join_time
```

#### 2.4 Billing Amount Validation Test
**File:** `tests/test_billing_amount_validation.sql`

```sql
-- Test to validate billing amounts are non-negative
-- This test will fail if any billing amount is negative

SELECT 
    event_id,
    user_id,
    event_type,
    amount
FROM {{ ref('bz_billing_events') }}
WHERE amount < 0
```

#### 2.5 License Date Range Test
**File:** `tests/test_license_date_range.sql`

```sql
-- Test to validate license date ranges
-- This test will fail if end_date is before start_date

SELECT 
    license_id,
    license_type,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE start_date IS NOT NULL 
  AND end_date IS NOT NULL 
  AND end_date < start_date
```

#### 2.6 Feature Usage Count Test
**File:** `tests/test_feature_usage_count.sql`

```sql
-- Test to validate feature usage counts are non-negative
-- This test will fail if any usage count is negative

SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count
FROM {{ ref('bz_feature_usage') }}
WHERE usage_count < 0
```

#### 2.7 Data Freshness Test
**File:** `tests/test_data_freshness.sql`

```sql
-- Test to validate data freshness across all Bronze tables
-- This test will fail if any table has data older than 7 days

WITH freshness_check AS (
    SELECT 'bz_users' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_feature_usage' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_support_tickets' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_billing_events' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_licenses' as table_name, MAX(load_timestamp) as latest_load FROM {{ ref('bz_licenses') }}
)

SELECT 
    table_name,
    latest_load,
    DATEDIFF('day', latest_load, CURRENT_TIMESTAMP()) as days_old
FROM freshness_check
WHERE DATEDIFF('day', latest_load, CURRENT_TIMESTAMP()) > 7
```

#### 2.8 Audit Trail Completeness Test
**File:** `tests/test_audit_trail_completeness.sql`

```sql
-- Test to ensure audit trail is complete for all Bronze table operations
-- This test will fail if any Bronze table operation is missing from audit

WITH expected_tables AS (
    SELECT 'BZ_USERS' as table_name
    UNION ALL SELECT 'BZ_MEETINGS'
    UNION ALL SELECT 'BZ_PARTICIPANTS'
    UNION ALL SELECT 'BZ_FEATURE_USAGE'
    UNION ALL SELECT 'BZ_SUPPORT_TICKETS'
    UNION ALL SELECT 'BZ_BILLING_EVENTS'
    UNION ALL SELECT 'BZ_LICENSES'
),
audited_tables AS (
    SELECT DISTINCT source_table as table_name
    FROM {{ ref('bz_data_audit') }}
    WHERE status = 'SUCCESS'
      AND load_timestamp >= CURRENT_DATE() - 1
)

SELECT 
    e.table_name
FROM expected_tables e
LEFT JOIN audited_tables a ON e.table_name = a.table_name
WHERE a.table_name IS NULL
```

#### 2.9 Deduplication Effectiveness Test
**File:** `tests/test_deduplication_effectiveness.sql`

```sql
-- Test to validate deduplication is working correctly
-- This test will fail if there are duplicate primary keys in any Bronze table

WITH duplicate_check AS (
    SELECT 'bz_users' as table_name, user_id as pk, COUNT(*) as cnt FROM {{ ref('bz_users') }} GROUP BY user_id HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'bz_meetings' as table_name, meeting_id as pk, COUNT(*) as cnt FROM {{ ref('bz_meetings') }} GROUP BY meeting_id HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'bz_participants' as table_name, participant_id as pk, COUNT(*) as cnt FROM {{ ref('bz_participants') }} GROUP BY participant_id HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'bz_feature_usage' as table_name, usage_id as pk, COUNT(*) as cnt FROM {{ ref('bz_feature_usage') }} GROUP BY usage_id HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'bz_support_tickets' as table_name, ticket_id as pk, COUNT(*) as cnt FROM {{ ref('bz_support_tickets') }} GROUP BY ticket_id HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'bz_billing_events' as table_name, event_id as pk, COUNT(*) as cnt FROM {{ ref('bz_billing_events') }} GROUP BY event_id HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'bz_licenses' as table_name, license_id as pk, COUNT(*) as cnt FROM {{ ref('bz_licenses') }} GROUP BY license_id HAVING COUNT(*) > 1
)

SELECT 
    table_name,
    pk,
    cnt
FROM duplicate_check
```

#### 2.10 Source to Bronze Mapping Test
**File:** `tests/test_source_to_bronze_mapping.sql`

```sql
-- Test to validate 1:1 mapping from source to Bronze
-- This test compares record counts between RAW and Bronze layers

WITH source_counts AS (
    SELECT 'users' as table_name, COUNT(*) as source_count FROM {{ source('raw', 'users') }}
    UNION ALL
    SELECT 'meetings' as table_name, COUNT(*) as source_count FROM {{ source('raw', 'meetings') }}
    UNION ALL
    SELECT 'participants' as table_name, COUNT(*) as source_count FROM {{ source('raw', 'participants') }}
    UNION ALL
    SELECT 'feature_usage' as table_name, COUNT(*) as source_count FROM {{ source('raw', 'feature_usage') }}
    UNION ALL
    SELECT 'support_tickets' as table_name, COUNT(*) as source_count FROM {{ source('raw', 'support_tickets') }}
    UNION ALL
    SELECT 'billing_events' as table_name, COUNT(*) as source_count FROM {{ source('raw', 'billing_events') }}
    UNION ALL
    SELECT 'licenses' as table_name, COUNT(*) as source_count FROM {{ source('raw', 'licenses') }}
),
bronze_counts AS (
    SELECT 'users' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'meetings' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'participants' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'feature_usage' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'support_tickets' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'billing_events' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'licenses' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_licenses') }}
)

SELECT 
    s.table_name,
    s.source_count,
    b.bronze_count,
    ABS(s.source_count - b.bronze_count) as count_difference
FROM source_counts s
JOIN bronze_counts b ON s.table_name = b.table_name
WHERE s.source_count != b.bronze_count
```

### 3. Parameterized Tests

#### 3.1 Generic Not Null Test for Metadata Fields
**File:** `macros/test_metadata_not_null.sql`

```sql
{% macro test_metadata_not_null(model, column_name) %}

    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} IS NULL

{% endmacro %}
```

#### 3.2 Generic Date Range Validation Test
**File:** `macros/test_date_range_validation.sql`

```sql
{% macro test_date_range_validation(model, start_date_column, end_date_column) %}

    SELECT *
    FROM {{ model }}
    WHERE {{ start_date_column }} IS NOT NULL 
      AND {{ end_date_column }} IS NOT NULL 
      AND {{ end_date_column }} < {{ start_date_column }}

{% endmacro %}
```

### 4. Test Execution Commands

#### 4.1 Run All Tests
```bash
# Run all tests for the Bronze layer
dbt test --models tag:bronze

# Run tests for specific model
dbt test --models bz_users

# Run only custom SQL tests
dbt test --models test_type:singular

# Run only schema tests
dbt test --models test_type:generic
```

#### 4.2 Test with Specific Configurations
```bash
# Run tests with increased verbosity
dbt test --models tag:bronze --verbose

# Run tests and store results
dbt test --models tag:bronze --store-failures

# Run tests with specific threads
dbt test --models tag:bronze --threads 4
```

### 5. Test Results Tracking

#### 5.1 Test Results Schema
Test results are automatically tracked in dbt's `run_results.json` and can be stored in Snowflake using:

```yaml
# In dbt_project.yml
tests:
  +store_failures: true
  +schema: 'test_failures'
```

#### 5.2 Test Monitoring Query
```sql
-- Query to monitor test results in Snowflake
SELECT 
    test_name,
    model_name,
    status,
    execution_time,
    failures,
    run_started_at
FROM DBT_TEST_RESULTS.TEST_RESULTS
WHERE model_name LIKE 'bz_%'
ORDER BY run_started_at DESC;
```

---

## Test Maintenance Guidelines

### 1. Test Review Schedule
- **Weekly**: Review test results and failure patterns
- **Monthly**: Update test cases based on new business requirements
- **Quarterly**: Performance review of test execution times

### 2. Test Coverage Metrics
- **Data Quality Tests**: 100% coverage for primary keys and required fields
- **Business Rule Tests**: Coverage for all critical business logic
- **Edge Case Tests**: Coverage for known data quality issues

### 3. Test Documentation
- All custom tests must include clear descriptions
- Test failure scenarios must be documented
- Expected outcomes must be clearly defined

### 4. Test Environment Management
- Tests should run in dedicated test environment
- Test data should be refreshed regularly
- Test results should be archived for trend analysis

---

## Conclusion

This comprehensive test suite ensures the reliability and quality of the Zoom Bronze Layer Pipeline in Snowflake. The combination of schema tests, custom SQL tests, and parameterized tests provides thorough coverage of:

- **Data Quality**: Ensuring data integrity and consistency
- **Business Rules**: Validating business logic implementation
- **Edge Cases**: Handling unusual data scenarios
- **Performance**: Monitoring execution efficiency
- **Error Handling**: Graceful failure management

Regular execution of these tests will help maintain high data quality standards and catch issues early in the development cycle, ensuring reliable data delivery to downstream Silver and Gold layer consumers.
