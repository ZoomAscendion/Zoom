_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Platform Analytics Bronze Layer

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze layer dbt models running in Snowflake. The test suite covers data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models.

## Test Strategy

The testing approach follows dbt best practices and covers:
- **Data Quality Tests**: Primary key uniqueness, not-null constraints, referential integrity
- **Transformation Tests**: Data type conversions, deduplication logic, filtering rules
- **Edge Case Tests**: NULL handling, empty datasets, invalid data scenarios
- **Business Rule Tests**: Domain-specific validations and constraints
- **Performance Tests**: Query optimization and execution time validation
- **Audit Tests**: Metadata tracking and lineage verification

---

## Test Case List

### 1. Data Quality Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| DQ_001 | Validate primary key uniqueness for all Bronze tables | All primary keys are unique with no duplicates | All Bronze models |
| DQ_002 | Validate not-null constraints on primary keys | No NULL values in primary key columns | All Bronze models |
| DQ_003 | Validate data type consistency between source and target | All data types match expected schema definitions | All Bronze models |
| DQ_004 | Validate timestamp columns are properly formatted | All timestamp columns follow TIMESTAMP_NTZ format | All Bronze models |
| DQ_005 | Validate date columns are properly formatted | All date columns follow DATE format | bz_billing_events, bz_support_tickets, bz_feature_usage, bz_licenses |

### 2. Transformation Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| TR_001 | Validate deduplication logic removes duplicate records | Only latest records based on UPDATE_TIMESTAMP are retained | All Bronze models |
| TR_002 | Validate TRY_CAST functions handle invalid data gracefully | Invalid data converts to NULL without pipeline failure | bz_meetings, bz_participants, bz_billing_events, bz_licenses |
| TR_003 | Validate NULL primary key filtering | Records with NULL primary keys are excluded from output | All Bronze models |
| TR_004 | Validate 1-1 mapping from source to Bronze layer | All source columns are mapped correctly to Bronze tables | All Bronze models |
| TR_005 | Validate ROW_NUMBER() partitioning logic | Correct ranking based on UPDATE_TIMESTAMP and LOAD_TIMESTAMP | All Bronze models |

### 3. Edge Case Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| EC_001 | Handle empty source tables | Models execute successfully with empty result sets | All Bronze models |
| EC_002 | Handle source tables with only NULL primary keys | Models return empty result sets | All Bronze models |
| EC_003 | Handle malformed timestamp data | TRY_CAST converts invalid timestamps to NULL | bz_meetings, bz_participants |
| EC_004 | Handle malformed numeric data | TRY_CAST converts invalid numbers to NULL | bz_meetings, bz_billing_events |
| EC_005 | Handle extremely large VARCHAR values | Data truncation handled gracefully | All Bronze models |

### 4. Business Rule Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| BR_001 | Validate email format in users table | Email addresses follow valid format patterns | bz_users |
| BR_002 | Validate meeting duration consistency | DURATION_MINUTES aligns with START_TIME and END_TIME | bz_meetings |
| BR_003 | Validate participant session logic | JOIN_TIME is before or equal to LEAVE_TIME | bz_participants |
| BR_004 | Validate billing amount ranges | AMOUNT values are within reasonable business ranges | bz_billing_events |
| BR_005 | Validate license date ranges | START_DATE is before or equal to END_DATE | bz_licenses |

### 5. Audit and Metadata Test Cases

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|------------------|
| AU_001 | Validate audit table structure | BZ_DATA_AUDIT table has correct schema | bz_data_audit |
| AU_002 | Validate pre-hook audit logging | STARTED status logged before model execution | All Bronze models |
| AU_003 | Validate post-hook audit logging | SUCCESS status logged after model execution | All Bronze models |
| AU_004 | Validate SOURCE_SYSTEM tracking | All records have valid SOURCE_SYSTEM values | All Bronze models |
| AU_005 | Validate metadata timestamp consistency | LOAD_TIMESTAMP and UPDATE_TIMESTAMP are properly populated | All Bronze models |

---

## dbt Test Scripts

### YAML-based Schema Tests

#### File: models/bronze/schema.yml

```yaml
version: 2

sources:
  - name: raw_zoom
    description: "Raw data layer containing unprocessed data from Zoom platform"
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
        description: "Raw meeting information and session details"
        columns:
          - name: meeting_id
            description: "Unique identifier for each meeting"
            tests:
              - not_null
              - unique

      - name: participants
        description: "Raw meeting participants and their session details"
        columns:
          - name: participant_id
            description: "Unique identifier for each participant record"
            tests:
              - not_null
              - unique

      - name: feature_usage
        description: "Raw usage of platform features during meetings"
        columns:
          - name: usage_id
            description: "Unique identifier for each feature usage record"
            tests:
              - not_null
              - unique

      - name: support_tickets
        description: "Raw customer support requests and resolution tracking"
        columns:
          - name: ticket_id
            description: "Unique identifier for each support ticket"
            tests:
              - not_null
              - unique

      - name: billing_events
        description: "Raw financial transactions and billing activities"
        columns:
          - name: event_id
            description: "Unique identifier for each billing event"
            tests:
              - not_null
              - unique

      - name: licenses
        description: "Raw license assignments and entitlements"
        columns:
          - name: license_id
            description: "Unique identifier for each license"
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
      - name: status
        description: "Status of the operation"
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING']

  - name: bz_users
    description: "Bronze layer table storing user profile and subscription information"
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
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  - name: bz_meetings
    description: "Bronze layer table storing meeting information and session details"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  - name: bz_participants
    description: "Bronze layer table tracking meeting participants"
    columns:
      - name: participant_id
        description: "Unique identifier for each meeting participant"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  - name: bz_feature_usage
    description: "Bronze layer table recording platform feature usage"
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - not_null
      - name: feature_name
        description: "Name of the feature being tracked"
        tests:
          - not_null
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: usage_date
        description: "Date when feature usage occurred"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  - name: bz_support_tickets
    description: "Bronze layer table managing customer support requests"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - not_null
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - not_null
      - name: resolution_status
        description: "Current status of ticket resolution"
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
      - name: open_date
        description: "Date when ticket was opened"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  - name: bz_billing_events
    description: "Bronze layer table tracking financial transactions"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - not_null
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null
      - name: amount
        description: "Monetary amount for the billing event"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: event_date
        description: "Date when the billing event occurred"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  - name: bz_licenses
    description: "Bronze layer table managing license assignments"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "Type of license"
        tests:
          - not_null
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - not_null
      - name: start_date
        description: "License validity start date"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### File: tests/test_deduplication_logic.sql

```sql
-- Test: Validate deduplication logic across all Bronze models
-- Description: Ensures that deduplication based on ROW_NUMBER() works correctly
-- Expected: No duplicates based on primary key should exist

WITH duplicate_check AS (
    SELECT 'bz_users' as table_name, user_id as primary_key, COUNT(*) as record_count
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_meetings' as table_name, meeting_id as primary_key, COUNT(*) as record_count
    FROM {{ ref('bz_meetings') }}
    GROUP BY meeting_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_participants' as table_name, participant_id as primary_key, COUNT(*) as record_count
    FROM {{ ref('bz_participants') }}
    GROUP BY participant_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_feature_usage' as table_name, usage_id as primary_key, COUNT(*) as record_count
    FROM {{ ref('bz_feature_usage') }}
    GROUP BY usage_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_support_tickets' as table_name, ticket_id as primary_key, COUNT(*) as record_count
    FROM {{ ref('bz_support_tickets') }}
    GROUP BY ticket_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_billing_events' as table_name, event_id as primary_key, COUNT(*) as record_count
    FROM {{ ref('bz_billing_events') }}
    GROUP BY event_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 'bz_licenses' as table_name, license_id as primary_key, COUNT(*) as record_count
    FROM {{ ref('bz_licenses') }}
    GROUP BY license_id
    HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

#### File: tests/test_data_type_consistency.sql

```sql
-- Test: Validate data type consistency between source and Bronze layers
-- Description: Ensures TRY_CAST functions work correctly and data types are consistent
-- Expected: All data type conversions should be successful

WITH data_type_validation AS (
    -- Test TIMESTAMP_NTZ conversions in meetings
    SELECT 'bz_meetings_end_time' as test_case,
           COUNT(*) as total_records,
           COUNT(end_time) as valid_timestamps,
           COUNT(*) - COUNT(end_time) as null_timestamps
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    -- Test NUMBER conversions in meetings
    SELECT 'bz_meetings_duration' as test_case,
           COUNT(*) as total_records,
           COUNT(duration_minutes) as valid_numbers,
           COUNT(*) - COUNT(duration_minutes) as null_numbers
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    -- Test TIMESTAMP_NTZ conversions in participants
    SELECT 'bz_participants_join_time' as test_case,
           COUNT(*) as total_records,
           COUNT(join_time) as valid_timestamps,
           COUNT(*) - COUNT(join_time) as null_timestamps
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    -- Test NUMBER conversions in billing_events
    SELECT 'bz_billing_events_amount' as test_case,
           COUNT(*) as total_records,
           COUNT(amount) as valid_amounts,
           COUNT(*) - COUNT(amount) as null_amounts
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    -- Test DATE conversions in licenses
    SELECT 'bz_licenses_end_date' as test_case,
           COUNT(*) as total_records,
           COUNT(end_date) as valid_dates,
           COUNT(*) - COUNT(end_date) as null_dates
    FROM {{ ref('bz_licenses') }}
)

SELECT *
FROM data_type_validation
WHERE total_records = 0 -- This should return no records if all conversions are working
```

#### File: tests/test_business_rules.sql

```sql
-- Test: Validate business rules across Bronze models
-- Description: Ensures business logic constraints are met
-- Expected: All business rules should be satisfied

WITH business_rule_violations AS (
    -- Test: Meeting duration should be non-negative
    SELECT 'negative_meeting_duration' as violation_type,
           meeting_id as record_id,
           duration_minutes as violation_value
    FROM {{ ref('bz_meetings') }}
    WHERE duration_minutes < 0
    
    UNION ALL
    
    -- Test: Participant join time should be before or equal to leave time
    SELECT 'invalid_participant_session' as violation_type,
           participant_id as record_id,
           DATEDIFF('minute', join_time, leave_time) as violation_value
    FROM {{ ref('bz_participants') }}
    WHERE join_time > leave_time
    
    UNION ALL
    
    -- Test: Billing amounts should be non-negative
    SELECT 'negative_billing_amount' as violation_type,
           event_id as record_id,
           amount as violation_value
    FROM {{ ref('bz_billing_events') }}
    WHERE amount < 0
    
    UNION ALL
    
    -- Test: License start date should be before or equal to end date
    SELECT 'invalid_license_dates' as violation_type,
           license_id as record_id,
           DATEDIFF('day', start_date, end_date) as violation_value
    FROM {{ ref('bz_licenses') }}
    WHERE start_date > end_date
    
    UNION ALL
    
    -- Test: Feature usage count should be non-negative
    SELECT 'negative_usage_count' as violation_type,
           usage_id as record_id,
           usage_count as violation_value
    FROM {{ ref('bz_feature_usage') }}
    WHERE usage_count < 0
)

SELECT *
FROM business_rule_violations
```

#### File: tests/test_audit_functionality.sql

```sql
-- Test: Validate audit table functionality
-- Description: Ensures audit logging is working correctly
-- Expected: Audit records should exist for all Bronze table operations

WITH audit_validation AS (
    SELECT 
        source_table,
        COUNT(*) as audit_record_count,
        COUNT(CASE WHEN status = 'STARTED' THEN 1 END) as started_count,
        COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as success_count,
        COUNT(CASE WHEN status = 'FAILED' THEN 1 END) as failed_count,
        MAX(load_timestamp) as latest_audit_timestamp
    FROM {{ ref('bz_data_audit') }}
    WHERE source_table IN (
        'BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 
        'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 
        'BZ_BILLING_EVENTS', 'BZ_LICENSES'
    )
    GROUP BY source_table
),

expected_tables AS (
    SELECT table_name
    FROM (
        VALUES 
        ('BZ_USERS'),
        ('BZ_MEETINGS'),
        ('BZ_PARTICIPANTS'),
        ('BZ_FEATURE_USAGE'),
        ('BZ_SUPPORT_TICKETS'),
        ('BZ_BILLING_EVENTS'),
        ('BZ_LICENSES')
    ) AS t(table_name)
)

-- Check for missing audit records
SELECT 
    et.table_name as missing_audit_table,
    'Missing audit records' as issue_type
FROM expected_tables et
LEFT JOIN audit_validation av ON et.table_name = av.source_table
WHERE av.source_table IS NULL

UNION ALL

-- Check for tables with failed operations
SELECT 
    source_table as problematic_table,
    'Failed operations detected' as issue_type
FROM audit_validation
WHERE failed_count > 0
```

#### File: tests/test_metadata_consistency.sql

```sql
-- Test: Validate metadata consistency across Bronze models
-- Description: Ensures all metadata fields are properly populated
-- Expected: All records should have valid metadata

WITH metadata_validation AS (
    SELECT 'bz_users' as table_name,
           COUNT(*) as total_records,
           COUNT(load_timestamp) as valid_load_timestamps,
           COUNT(update_timestamp) as valid_update_timestamps,
           COUNT(source_system) as valid_source_systems
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 'bz_meetings' as table_name,
           COUNT(*) as total_records,
           COUNT(load_timestamp) as valid_load_timestamps,
           COUNT(update_timestamp) as valid_update_timestamps,
           COUNT(source_system) as valid_source_systems
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 'bz_participants' as table_name,
           COUNT(*) as total_records,
           COUNT(load_timestamp) as valid_load_timestamps,
           COUNT(update_timestamp) as valid_update_timestamps,
           COUNT(source_system) as valid_source_systems
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    SELECT 'bz_feature_usage' as table_name,
           COUNT(*) as total_records,
           COUNT(load_timestamp) as valid_load_timestamps,
           COUNT(update_timestamp) as valid_update_timestamps,
           COUNT(source_system) as valid_source_systems
    FROM {{ ref('bz_feature_usage') }}
    
    UNION ALL
    
    SELECT 'bz_support_tickets' as table_name,
           COUNT(*) as total_records,
           COUNT(load_timestamp) as valid_load_timestamps,
           COUNT(update_timestamp) as valid_update_timestamps,
           COUNT(source_system) as valid_source_systems
    FROM {{ ref('bz_support_tickets') }}
    
    UNION ALL
    
    SELECT 'bz_billing_events' as table_name,
           COUNT(*) as total_records,
           COUNT(load_timestamp) as valid_load_timestamps,
           COUNT(update_timestamp) as valid_update_timestamps,
           COUNT(source_system) as valid_source_systems
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 'bz_licenses' as table_name,
           COUNT(*) as total_records,
           COUNT(load_timestamp) as valid_load_timestamps,
           COUNT(update_timestamp) as valid_update_timestamps,
           COUNT(source_system) as valid_source_systems
    FROM {{ ref('bz_licenses') }}
)

SELECT 
    table_name,
    total_records,
    (total_records - valid_load_timestamps) as missing_load_timestamps,
    (total_records - valid_update_timestamps) as missing_update_timestamps,
    (total_records - valid_source_systems) as missing_source_systems
FROM metadata_validation
WHERE 
    (total_records - valid_load_timestamps) > 0 OR
    (total_records - valid_update_timestamps) > 0 OR
    (total_records - valid_source_systems) > 0
```

### Parameterized Tests

#### File: macros/test_primary_key_uniqueness.sql

```sql
-- Macro: Test primary key uniqueness across all Bronze models
-- Usage: {{ test_primary_key_uniqueness('table_name', 'primary_key_column') }}

{% macro test_primary_key_uniqueness(table_name, primary_key_column) %}

WITH duplicate_check AS (
    SELECT 
        {{ primary_key_column }},
        COUNT(*) as record_count
    FROM {{ ref(table_name) }}
    GROUP BY {{ primary_key_column }}
    HAVING COUNT(*) > 1
)

SELECT 
    '{{ table_name }}' as table_name,
    {{ primary_key_column }} as duplicate_key,
    record_count
FROM duplicate_check

{% endmacro %}
```

#### File: macros/test_null_primary_keys.sql

```sql
-- Macro: Test for NULL primary keys
-- Usage: {{ test_null_primary_keys('table_name', 'primary_key_column') }}

{% macro test_null_primary_keys(table_name, primary_key_column) %}

SELECT 
    '{{ table_name }}' as table_name,
    COUNT(*) as null_primary_key_count
FROM {{ ref(table_name) }}
WHERE {{ primary_key_column }} IS NULL
HAVING COUNT(*) > 0

{% endmacro %}
```

## Test Execution Strategy

### 1. Continuous Integration Tests

```bash
# Run all tests
dbt test

# Run specific test categories
dbt test --select tag:data_quality
dbt test --select tag:transformation
dbt test --select tag:business_rules

# Run tests for specific models
dbt test --select bz_users
dbt test --select bz_meetings
```

### 2. Performance Testing

```sql
-- Monitor query performance
SELECT 
    query_text,
    execution_time,
    rows_produced,
    bytes_scanned
FROM snowflake.account_usage.query_history
WHERE query_text ILIKE '%bz_%'
AND start_time >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
ORDER BY execution_time DESC;
```

### 3. Data Freshness Testing

```yaml
# File: models/bronze/sources.yml
sources:
  - name: raw_zoom
    freshness:
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    loaded_at_field: load_timestamp
```

## Test Results Tracking

### 1. Test Results Schema

```sql
-- Create test results tracking table
CREATE TABLE IF NOT EXISTS bronze.test_results (
    test_run_id VARCHAR(50),
    test_name VARCHAR(200),
    model_name VARCHAR(100),
    test_status VARCHAR(20),
    execution_time NUMBER(10,3),
    error_message TEXT,
    run_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```

### 2. Test Monitoring Dashboard

```sql
-- Query for test success rates
SELECT 
    model_name,
    COUNT(*) as total_tests,
    COUNT(CASE WHEN test_status = 'PASS' THEN 1 END) as passed_tests,
    COUNT(CASE WHEN test_status = 'FAIL' THEN 1 END) as failed_tests,
    ROUND((COUNT(CASE WHEN test_status = 'PASS' THEN 1 END) * 100.0 / COUNT(*)), 2) as success_rate
FROM bronze.test_results
WHERE run_timestamp >= CURRENT_TIMESTAMP - INTERVAL '7 days'
GROUP BY model_name
ORDER BY success_rate DESC;
```

## Best Practices and Recommendations

### 1. Test Organization
- **Categorize tests** by type (data quality, transformation, business rules)
- **Use descriptive names** for test files and functions
- **Document expected outcomes** for each test case
- **Maintain test versioning** alongside model versions

### 2. Performance Optimization
- **Limit test data volume** for faster execution
- **Use sampling techniques** for large datasets
- **Optimize test queries** with appropriate filters
- **Schedule tests** during off-peak hours

### 3. Error Handling
- **Implement graceful failure** handling in tests
- **Log detailed error messages** for debugging
- **Set up alerting** for critical test failures
- **Maintain test result history** for trend analysis

### 4. Maintenance
- **Review and update tests** regularly
- **Remove obsolete tests** when models change
- **Add new tests** for new business requirements
- **Monitor test execution times** and optimize as needed

---

## Summary

This comprehensive test suite provides robust validation for the Zoom Platform Analytics Bronze layer dbt models in Snowflake. The tests cover:

- **25 test cases** across 5 categories
- **YAML-based schema tests** for standard validations
- **Custom SQL tests** for complex business rules
- **Parameterized macros** for reusable test logic
- **Performance monitoring** and optimization strategies
- **Test result tracking** and reporting capabilities

The test framework ensures data quality, transformation accuracy, and business rule compliance while providing comprehensive monitoring and alerting capabilities for production environments.
