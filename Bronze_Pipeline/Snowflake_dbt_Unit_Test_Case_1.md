_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Bronze layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Bronze Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Bronze layer dbt models that run in Snowflake. The test cases cover key transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Strategy Overview

The testing approach covers:
- **Happy Path Testing**: Valid transformations, joins, and aggregations
- **Edge Case Testing**: Null values, empty datasets, invalid lookups, schema mismatches
- **Exception Testing**: Failed relationships, unexpected values, data type mismatches
- **Data Quality Testing**: Uniqueness, completeness, referential integrity
- **Performance Testing**: Large dataset handling and query optimization

---

## Test Case List

### 1. BZ_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_USERS_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| TC_BZ_USERS_002 | Validate email field handling for null values | Null emails are replaced with username@gmail.com |
| TC_BZ_USERS_003 | Validate deduplication logic based on UPDATE_TIMESTAMP | Only latest record per USER_ID is retained |
| TC_BZ_USERS_004 | Validate timestamp overwrite with current DBT run time | LOAD_TIMESTAMP and UPDATE_TIMESTAMP reflect current execution time |
| TC_BZ_USERS_005 | Validate plan_type accepted values | Only valid plan types (Basic, Pro, Business, Enterprise) are accepted |
| TC_BZ_USERS_006 | Test handling of records with null primary keys | Records with null USER_ID are filtered out |
| TC_BZ_USERS_007 | Validate source system attribution | SOURCE_SYSTEM field is preserved from raw data |
| TC_BZ_USERS_008 | Test email format validation | Generated emails follow username@gmail.com pattern |

### 2. BZ_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_MEETINGS_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| TC_BZ_MEETINGS_002 | Validate meeting duration calculation consistency | DURATION_MINUTES matches time difference between START_TIME and END_TIME |
| TC_BZ_MEETINGS_003 | Validate deduplication logic | Only latest record per MEETING_ID is retained |
| TC_BZ_MEETINGS_004 | Test handling of meetings with invalid time ranges | Meetings with END_TIME before START_TIME are flagged |
| TC_BZ_MEETINGS_005 | Validate HOST_ID referential integrity | All HOST_ID values exist in BZ_USERS table |
| TC_BZ_MEETINGS_006 | Test timestamp overwrite functionality | LOAD_TIMESTAMP and UPDATE_TIMESTAMP reflect current execution time |
| TC_BZ_MEETINGS_007 | Validate meeting topic PII handling | Meeting topics are preserved but flagged as potential PII |
| TC_BZ_MEETINGS_008 | Test null primary key filtering | Records with null MEETING_ID are excluded |

### 3. BZ_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_PARTICIPANTS_001 | Validate PARTICIPANT_ID uniqueness and not null | All PARTICIPANT_ID values are unique and not null |
| TC_BZ_PARTICIPANTS_002 | Validate MEETING_ID foreign key relationship | All MEETING_ID values exist in BZ_MEETINGS table |
| TC_BZ_PARTICIPANTS_003 | Validate USER_ID foreign key relationship | All USER_ID values exist in BZ_USERS table |
| TC_BZ_PARTICIPANTS_004 | Test participant session time validation | LEAVE_TIME is after JOIN_TIME for all records |
| TC_BZ_PARTICIPANTS_005 | Validate deduplication logic | Only latest record per PARTICIPANT_ID is retained |
| TC_BZ_PARTICIPANTS_006 | Test handling of participants who never left | Records with null LEAVE_TIME are handled appropriately |
| TC_BZ_PARTICIPANTS_007 | Validate timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP reflect current execution time |
| TC_BZ_PARTICIPANTS_008 | Test orphaned participant records | Participants without valid meeting or user references are flagged |

### 4. BZ_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_FEATURE_USAGE_001 | Validate USAGE_ID uniqueness and not null | All USAGE_ID values are unique and not null |
| TC_BZ_FEATURE_USAGE_002 | Validate MEETING_ID foreign key relationship | All MEETING_ID values exist in BZ_MEETINGS table |
| TC_BZ_FEATURE_USAGE_003 | Validate usage count data type and range | USAGE_COUNT is numeric and non-negative |
| TC_BZ_FEATURE_USAGE_004 | Test feature name standardization | FEATURE_NAME values follow consistent naming convention |
| TC_BZ_FEATURE_USAGE_005 | Validate usage date consistency | USAGE_DATE aligns with meeting date ranges |
| TC_BZ_FEATURE_USAGE_006 | Validate deduplication logic | Only latest record per USAGE_ID is retained |
| TC_BZ_FEATURE_USAGE_007 | Test timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP reflect current execution time |
| TC_BZ_FEATURE_USAGE_008 | Validate feature usage aggregation | Multiple usage records for same feature/meeting are handled correctly |

### 5. BZ_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_SUPPORT_TICKETS_001 | Validate TICKET_ID uniqueness and not null | All TICKET_ID values are unique and not null |
| TC_BZ_SUPPORT_TICKETS_002 | Validate USER_ID foreign key relationship | All USER_ID values exist in BZ_USERS table |
| TC_BZ_SUPPORT_TICKETS_003 | Validate ticket type accepted values | Only valid ticket types are accepted |
| TC_BZ_SUPPORT_TICKETS_004 | Validate resolution status workflow | Resolution status follows valid state transitions |
| TC_BZ_SUPPORT_TICKETS_005 | Test open date validation | OPEN_DATE is not in the future |
| TC_BZ_SUPPORT_TICKETS_006 | Validate deduplication logic | Only latest record per TICKET_ID is retained |
| TC_BZ_SUPPORT_TICKETS_007 | Test timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP reflect current execution time |
| TC_BZ_SUPPORT_TICKETS_008 | Validate ticket lifecycle tracking | Ticket status changes are properly tracked |

### 6. BZ_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_BILLING_EVENTS_001 | Validate EVENT_ID uniqueness and not null | All EVENT_ID values are unique and not null |
| TC_BZ_BILLING_EVENTS_002 | Validate USER_ID foreign key relationship | All USER_ID values exist in BZ_USERS table |
| TC_BZ_BILLING_EVENTS_003 | Validate amount data type and precision | AMOUNT is numeric with proper decimal precision |
| TC_BZ_BILLING_EVENTS_004 | Test negative amount handling | Negative amounts (refunds) are properly handled |
| TC_BZ_BILLING_EVENTS_005 | Validate event type accepted values | Only valid billing event types are accepted |
| TC_BZ_BILLING_EVENTS_006 | Validate event date consistency | EVENT_DATE is within reasonable business range |
| TC_BZ_BILLING_EVENTS_007 | Validate deduplication logic | Only latest record per EVENT_ID is retained |
| TC_BZ_BILLING_EVENTS_008 | Test timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP reflect current execution time |

### 7. BZ_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_LICENSES_001 | Validate LICENSE_ID uniqueness and not null | All LICENSE_ID values are unique and not null |
| TC_BZ_LICENSES_002 | Validate ASSIGNED_TO_USER_ID foreign key relationship | All user assignments exist in BZ_USERS table |
| TC_BZ_LICENSES_003 | Validate license date range consistency | END_DATE is after START_DATE |
| TC_BZ_LICENSES_004 | Test license type validation | Only valid license types are accepted |
| TC_BZ_LICENSES_005 | Validate active license logic | Current date falls within START_DATE and END_DATE for active licenses |
| TC_BZ_LICENSES_006 | Test license assignment uniqueness | One user cannot have multiple active licenses of same type |
| TC_BZ_LICENSES_007 | Validate deduplication logic | Only latest record per LICENSE_ID is retained |
| TC_BZ_LICENSES_008 | Test timestamp overwrite | LOAD_TIMESTAMP and UPDATE_TIMESTAMP reflect current execution time |

### 8. BZ_DATA_AUDIT Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_AUDIT_001 | Validate RECORD_ID auto-increment functionality | Each audit record has unique auto-generated ID |
| TC_BZ_AUDIT_002 | Test audit trail completeness | All Bronze table operations are logged |
| TC_BZ_AUDIT_003 | Validate processing time calculation | PROCESSING_TIME accurately reflects operation duration |
| TC_BZ_AUDIT_004 | Test status value validation | Only valid status values (SUCCESS, FAILED, WARNING) are recorded |
| TC_BZ_AUDIT_005 | Validate source table tracking | SOURCE_TABLE correctly identifies the processed table |
| TC_BZ_AUDIT_006 | Test concurrent operation handling | Multiple simultaneous operations are properly tracked |
| TC_BZ_AUDIT_007 | Validate timestamp accuracy | LOAD_TIMESTAMP reflects actual operation time |
| TC_BZ_AUDIT_008 | Test audit data retention | Audit records are preserved according to retention policy |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# tests/bronze_layer_tests.yml
version: 2

models:
  # BZ_USERS Tests
  - name: bz_users
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: user_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: email
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "email LIKE '%@%'"
              config:
                severity: warn
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: error
      - name: load_timestamp
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "load_timestamp >= CURRENT_DATE() - INTERVAL '1 DAY'"
              config:
                severity: warn

  # BZ_MEETINGS Tests
  - name: bz_meetings
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: meeting_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: host_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: error
      - name: start_time
        tests:
          - not_null:
              config:
                severity: error
      - name: end_time
        tests:
          - dbt_utils.expression_is_true:
              expression: "end_time >= start_time"
              config:
                severity: error
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0"
              config:
                severity: error

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    columns:
      - name: participant_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: error
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: error
      - name: join_time
        tests:
          - not_null:
              config:
                severity: error
      - name: leave_time
        tests:
          - dbt_utils.expression_is_true:
              expression: "leave_time IS NULL OR leave_time >= join_time"
              config:
                severity: error

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    columns:
      - name: usage_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: meeting_id
        tests:
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
              config:
                severity: error
      - name: usage_count
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
              config:
                severity: error
      - name: feature_name
        tests:
          - not_null:
              config:
                severity: error

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    columns:
      - name: ticket_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: error
      - name: open_date
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "open_date <= CURRENT_DATE()"
              config:
                severity: error

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    columns:
      - name: event_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: error
      - name: amount
        tests:
          - not_null:
              config:
                severity: error
      - name: event_date
        tests:
          - not_null:
              config:
                severity: error

  # BZ_LICENSES Tests
  - name: bz_licenses
    columns:
      - name: license_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: assigned_to_user_id
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
              config:
                severity: error
      - name: start_date
        tests:
          - not_null:
              config:
                severity: error
      - name: end_date
        tests:
          - dbt_utils.expression_is_true:
              expression: "end_date >= start_date"
              config:
                severity: error

  # BZ_DATA_AUDIT Tests
  - name: bz_data_audit
    columns:
      - name: record_id
        tests:
          - unique:
              config:
                severity: error
      - name: source_table
        tests:
          - accepted_values:
              values: ['BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 'BZ_BILLING_EVENTS', 'BZ_LICENSES']
              config:
                severity: warn
      - name: status
        tests:
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING']
              config:
                severity: error
```

### Custom SQL-based dbt Tests

#### Test 1: Email Format Validation for Generated Emails
```sql
-- tests/test_generated_email_format.sql
{{ config(severity = 'error') }}

SELECT 
    user_id,
    email,
    user_name
FROM {{ ref('bz_users') }}
WHERE email LIKE '%@gmail.com'
  AND email != CONCAT(user_name, '@gmail.com')
```

#### Test 2: Deduplication Effectiveness Test
```sql
-- tests/test_deduplication_effectiveness.sql
{{ config(severity = 'error') }}

SELECT 
    'bz_users' as table_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT user_id, COUNT(*) as cnt
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT meeting_id, COUNT(*) as cnt
    FROM {{ ref('bz_meetings') }}
    GROUP BY meeting_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'bz_participants' as table_name,
    COUNT(*) as duplicate_count
FROM (
    SELECT participant_id, COUNT(*) as cnt
    FROM {{ ref('bz_participants') }}
    GROUP BY participant_id
    HAVING COUNT(*) > 1
)

HAVING duplicate_count > 0
```

#### Test 3: Timestamp Overwrite Validation
```sql
-- tests/test_timestamp_overwrite.sql
{{ config(severity = 'warn') }}

SELECT 
    'bz_users' as table_name,
    COUNT(*) as records_with_old_timestamps
FROM {{ ref('bz_users') }}
WHERE load_timestamp < CURRENT_DATE() - INTERVAL '1 DAY'
   OR update_timestamp < CURRENT_DATE() - INTERVAL '1 DAY'

UNION ALL

SELECT 
    'bz_meetings' as table_name,
    COUNT(*) as records_with_old_timestamps
FROM {{ ref('bz_meetings') }}
WHERE load_timestamp < CURRENT_DATE() - INTERVAL '1 DAY'
   OR update_timestamp < CURRENT_DATE() - INTERVAL '1 DAY'

HAVING records_with_old_timestamps > 0
```

#### Test 4: Audit Trail Completeness
```sql
-- tests/test_audit_trail_completeness.sql
{{ config(severity = 'error') }}

WITH expected_tables AS (
    SELECT table_name
    FROM VALUES 
        ('BZ_USERS'),
        ('BZ_MEETINGS'),
        ('BZ_PARTICIPANTS'),
        ('BZ_FEATURE_USAGE'),
        ('BZ_SUPPORT_TICKETS'),
        ('BZ_BILLING_EVENTS'),
        ('BZ_LICENSES')
    AS t(table_name)
),
audited_tables AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE status = 'SUCCESS'
      AND load_timestamp >= CURRENT_DATE()
)

SELECT 
    e.table_name as missing_audit_table
FROM expected_tables e
LEFT JOIN audited_tables a ON e.table_name = a.source_table
WHERE a.source_table IS NULL
```

#### Test 5: Referential Integrity Cross-Check
```sql
-- tests/test_referential_integrity.sql
{{ config(severity = 'error') }}

-- Check for orphaned meeting participants
SELECT 
    'orphaned_participants_meeting' as issue_type,
    COUNT(*) as issue_count
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL

UNION ALL

-- Check for orphaned meeting participants (user)
SELECT 
    'orphaned_participants_user' as issue_type,
    COUNT(*) as issue_count
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check for orphaned feature usage
SELECT 
    'orphaned_feature_usage' as issue_type,
    COUNT(*) as issue_count
FROM {{ ref('bz_feature_usage') }} f
LEFT JOIN {{ ref('bz_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL

HAVING issue_count > 0
```

#### Test 6: Data Quality Metrics
```sql
-- tests/test_data_quality_metrics.sql
{{ config(severity = 'warn') }}

SELECT 
    'bz_users_completeness' as metric_name,
    ROUND((COUNT(email) * 100.0 / COUNT(*)), 2) as metric_value
FROM {{ ref('bz_users') }}
HAVING metric_value < 95.0  -- Expect 95% email completeness

UNION ALL

SELECT 
    'bz_meetings_duration_validity' as metric_name,
    ROUND((COUNT(CASE WHEN duration_minutes > 0 THEN 1 END) * 100.0 / COUNT(*)), 2) as metric_value
FROM {{ ref('bz_meetings') }}
HAVING metric_value < 90.0  -- Expect 90% valid durations

UNION ALL

SELECT 
    'bz_participants_session_validity' as metric_name,
    ROUND((COUNT(CASE WHEN leave_time IS NULL OR leave_time >= join_time THEN 1 END) * 100.0 / COUNT(*)), 2) as metric_value
FROM {{ ref('bz_participants') }}
HAVING metric_value < 98.0  -- Expect 98% valid sessions
```

---

## Test Execution Guidelines

### Running Tests

1. **Execute all tests:**
   ```bash
   dbt test
   ```

2. **Execute tests for specific model:**
   ```bash
   dbt test --select bz_users
   ```

3. **Execute tests with specific severity:**
   ```bash
   dbt test --severity error
   ```

4. **Execute custom SQL tests only:**
   ```bash
   dbt test --select test_type:generic
   ```

### Test Results Tracking

- Test results are automatically logged in dbt's `run_results.json`
- Failed tests are tracked in Snowflake's audit schema
- Custom test results can be stored in dedicated test results tables

### Continuous Integration

- Integrate tests into CI/CD pipeline
- Set up automated alerts for test failures
- Establish test coverage metrics and monitoring
- Implement test result dashboards for visibility

---

## Performance Considerations

### Test Optimization

1. **Sampling for Large Datasets:**
   ```sql
   -- Use SAMPLE for performance on large tables
   SELECT * FROM {{ ref('bz_users') }} SAMPLE (10)
   ```

2. **Incremental Testing:**
   ```sql
   -- Test only recent data for performance
   WHERE load_timestamp >= CURRENT_DATE() - INTERVAL '7 DAYS'
   ```

3. **Parallel Test Execution:**
   - Configure dbt to run tests in parallel
   - Use appropriate thread counts for Snowflake warehouse

### Monitoring and Alerting

- Set up Snowflake resource monitors for test execution
- Implement cost controls for test runs
- Monitor test execution times and optimize accordingly
- Establish SLAs for test completion times

---

## Conclusion

This comprehensive test suite ensures the reliability, performance, and data quality of the Bronze layer dbt models in Snowflake. The combination of schema-based tests and custom SQL tests provides thorough coverage of:

- **Data Integrity**: Primary keys, foreign keys, and referential integrity
- **Business Rules**: Data validation and business logic compliance
- **Edge Cases**: Null handling, data type validation, and boundary conditions
- **Performance**: Query optimization and resource utilization
- **Audit Trail**: Complete tracking of data operations and transformations

Regular execution of these tests will help maintain high data quality standards and catch potential issues early in the development cycle, ensuring reliable data pipelines in production.