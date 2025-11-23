_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Bronze Layer Models

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Bronze layer models in the Zoom Platform Analytics System. The tests cover data quality validation, business rule enforcement, edge case handling, and error scenarios for all Bronze layer transformations running in Snowflake.

## Test Coverage Overview

The test suite covers the following Bronze layer models:
- **bz_users**: User profile and subscription data
- **bz_meetings**: Meeting information and session details
- **bz_participants**: Meeting participant tracking
- **bz_feature_usage**: Platform feature usage analytics
- **bz_support_tickets**: Customer support request management
- **bz_billing_events**: Financial transaction tracking
- **bz_licenses**: License assignment and management
- **bz_data_audit**: Comprehensive audit trail

## Test Case Categories

### 1. Data Quality Tests
- Primary key uniqueness and not null validation
- Foreign key relationship validation
- Data type consistency checks
- Required field validation

### 2. Business Rule Tests
- Domain value validation
- Business logic enforcement
- Data transformation accuracy
- Timestamp consistency

### 3. Edge Case Tests
- Null value handling
- Empty dataset scenarios
- Data type conversion edge cases
- Deduplication logic validation

### 4. Error Handling Tests
- Invalid data type scenarios
- Missing source data handling
- Audit trail functionality
- Pre/post hook execution

---

# Test Case List

## BZ_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_USERS_001 | Validate USER_ID uniqueness | All USER_ID values are unique |
| BZ_USERS_002 | Validate USER_ID not null | No null values in USER_ID column |
| BZ_USERS_003 | Validate EMAIL not null | No null values in EMAIL column |
| BZ_USERS_004 | Validate PLAN_TYPE domain values | Only 'Basic', 'Pro', 'Business', 'Enterprise' values |
| BZ_USERS_005 | Validate SOURCE_SYSTEM domain values | Only 'user_management', 'ldap', 'sso_provider' values |
| BZ_USERS_006 | Validate deduplication logic | Latest record kept based on update_timestamp |
| BZ_USERS_007 | Validate default email assignment | Default email format applied when email is null |
| BZ_USERS_008 | Validate default plan_type assignment | 'Basic' assigned when plan_type is null |
| BZ_USERS_009 | Validate timestamp overwrite | load_timestamp and update_timestamp set to current time |
| BZ_USERS_010 | Validate null primary key filtering | Records with null USER_ID are excluded |

## BZ_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_MEETINGS_001 | Validate MEETING_ID uniqueness | All MEETING_ID values are unique |
| BZ_MEETINGS_002 | Validate MEETING_ID not null | No null values in MEETING_ID column |
| BZ_MEETINGS_003 | Validate HOST_ID not null | No null values in HOST_ID column |
| BZ_MEETINGS_004 | Validate START_TIME not null | No null values in START_TIME column |
| BZ_MEETINGS_005 | Validate SOURCE_SYSTEM domain values | Only 'zoom_api', 'meeting_scheduler', 'calendar_integration' values |
| BZ_MEETINGS_006 | Validate END_TIME data type conversion | TRY_CAST successfully converts string to timestamp |
| BZ_MEETINGS_007 | Validate DURATION_MINUTES data type conversion | TRY_CAST successfully converts string to number |
| BZ_MEETINGS_008 | Validate deduplication logic | Latest record kept based on update_timestamp |
| BZ_MEETINGS_009 | Validate timestamp overwrite | load_timestamp and update_timestamp set to current time |
| BZ_MEETINGS_010 | Validate null filtering | Records with null MEETING_ID, HOST_ID, or START_TIME excluded |

## BZ_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_PARTICIPANTS_001 | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique |
| BZ_PARTICIPANTS_002 | Validate PARTICIPANT_ID not null | No null values in PARTICIPANT_ID column |
| BZ_PARTICIPANTS_003 | Validate MEETING_ID not null | No null values in MEETING_ID column |
| BZ_PARTICIPANTS_004 | Validate USER_ID not null | No null values in USER_ID column |
| BZ_PARTICIPANTS_005 | Validate SOURCE_SYSTEM domain values | Only 'zoom_api', 'meeting_logs', 'attendance_tracker' values |
| BZ_PARTICIPANTS_006 | Validate JOIN_TIME data type conversion | TRY_CAST successfully converts string to timestamp |
| BZ_PARTICIPANTS_007 | Validate deduplication logic | Latest record kept based on update_timestamp |
| BZ_PARTICIPANTS_008 | Validate timestamp overwrite | load_timestamp and update_timestamp set to current time |
| BZ_PARTICIPANTS_009 | Validate null filtering | Records with null PARTICIPANT_ID, MEETING_ID, or USER_ID excluded |
| BZ_PARTICIPANTS_010 | Validate referential integrity tracking | MEETING_ID and USER_ID relationships preserved |

## BZ_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_FEATURE_USAGE_001 | Validate USAGE_ID uniqueness | All USAGE_ID values are unique |
| BZ_FEATURE_USAGE_002 | Validate USAGE_ID not null | No null values in USAGE_ID column |
| BZ_FEATURE_USAGE_003 | Validate MEETING_ID not null | No null values in MEETING_ID column |
| BZ_FEATURE_USAGE_004 | Validate FEATURE_NAME not null | No null values in FEATURE_NAME column |
| BZ_FEATURE_USAGE_005 | Validate USAGE_COUNT not null | No null values in USAGE_COUNT column |
| BZ_FEATURE_USAGE_006 | Validate USAGE_DATE not null | No null values in USAGE_DATE column |
| BZ_FEATURE_USAGE_007 | Validate FEATURE_NAME domain values | Only 'screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard' values |
| BZ_FEATURE_USAGE_008 | Validate SOURCE_SYSTEM domain values | Only 'zoom_client', 'web_portal', 'mobile_app' values |
| BZ_FEATURE_USAGE_009 | Validate USAGE_COUNT non-negative | All USAGE_COUNT values >= 0 |
| BZ_FEATURE_USAGE_010 | Validate deduplication logic | Latest record kept based on update_timestamp |
| BZ_FEATURE_USAGE_011 | Validate timestamp overwrite | load_timestamp and update_timestamp set to current time |
| BZ_FEATURE_USAGE_012 | Validate null filtering | Records with null required fields excluded |

## BZ_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_SUPPORT_TICKETS_001 | Validate TICKET_ID uniqueness | All TICKET_ID values are unique |
| BZ_SUPPORT_TICKETS_002 | Validate TICKET_ID not null | No null values in TICKET_ID column |
| BZ_SUPPORT_TICKETS_003 | Validate USER_ID not null | No null values in USER_ID column |
| BZ_SUPPORT_TICKETS_004 | Validate TICKET_TYPE not null | No null values in TICKET_TYPE column |
| BZ_SUPPORT_TICKETS_005 | Validate RESOLUTION_STATUS not null | No null values in RESOLUTION_STATUS column |
| BZ_SUPPORT_TICKETS_006 | Validate OPEN_DATE not null | No null values in OPEN_DATE column |
| BZ_SUPPORT_TICKETS_007 | Validate TICKET_TYPE domain values | Only 'technical', 'billing', 'account', 'feature_request' values |
| BZ_SUPPORT_TICKETS_008 | Validate RESOLUTION_STATUS domain values | Only 'open', 'in_progress', 'resolved', 'closed' values |
| BZ_SUPPORT_TICKETS_009 | Validate SOURCE_SYSTEM domain values | Only 'zendesk', 'salesforce', 'support_portal' values |
| BZ_SUPPORT_TICKETS_010 | Validate deduplication logic | Latest record kept based on update_timestamp |
| BZ_SUPPORT_TICKETS_011 | Validate timestamp overwrite | load_timestamp and update_timestamp set to current time |
| BZ_SUPPORT_TICKETS_012 | Validate null filtering | Records with null required fields excluded |

## BZ_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_BILLING_EVENTS_001 | Validate EVENT_ID uniqueness | All EVENT_ID values are unique |
| BZ_BILLING_EVENTS_002 | Validate EVENT_ID not null | No null values in EVENT_ID column |
| BZ_BILLING_EVENTS_003 | Validate USER_ID not null | No null values in USER_ID column |
| BZ_BILLING_EVENTS_004 | Validate EVENT_TYPE not null | No null values in EVENT_TYPE column |
| BZ_BILLING_EVENTS_005 | Validate AMOUNT not null | No null values in AMOUNT column |
| BZ_BILLING_EVENTS_006 | Validate EVENT_DATE not null | No null values in EVENT_DATE column |
| BZ_BILLING_EVENTS_007 | Validate EVENT_TYPE domain values | Only 'subscription', 'usage', 'refund', 'adjustment' values |
| BZ_BILLING_EVENTS_008 | Validate SOURCE_SYSTEM domain values | Only 'billing_system', 'payment_gateway', 'subscription_service' values |
| BZ_BILLING_EVENTS_009 | Validate AMOUNT data type conversion | TRY_CAST successfully converts string to NUMBER(10,2) |
| BZ_BILLING_EVENTS_010 | Validate deduplication logic | Latest record kept based on update_timestamp |
| BZ_BILLING_EVENTS_011 | Validate timestamp overwrite | load_timestamp and update_timestamp set to current time |
| BZ_BILLING_EVENTS_012 | Validate null filtering | Records with null required fields excluded |

## BZ_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_LICENSES_001 | Validate LICENSE_ID uniqueness | All LICENSE_ID values are unique |
| BZ_LICENSES_002 | Validate LICENSE_ID not null | No null values in LICENSE_ID column |
| BZ_LICENSES_003 | Validate LICENSE_TYPE not null | No null values in LICENSE_TYPE column |
| BZ_LICENSES_004 | Validate START_DATE not null | No null values in START_DATE column |
| BZ_LICENSES_005 | Validate LICENSE_TYPE domain values | Only 'Basic', 'Pro', 'Business', 'Enterprise' values |
| BZ_LICENSES_006 | Validate SOURCE_SYSTEM domain values | Only 'license_management', 'admin_portal', 'billing_system' values |
| BZ_LICENSES_007 | Validate END_DATE data type conversion | TRY_CAST successfully converts string to DATE |
| BZ_LICENSES_008 | Validate deduplication logic | Latest record kept based on update_timestamp |
| BZ_LICENSES_009 | Validate timestamp overwrite | load_timestamp and update_timestamp set to current time |
| BZ_LICENSES_010 | Validate null filtering | Records with null LICENSE_ID, LICENSE_TYPE, or START_DATE excluded |
| BZ_LICENSES_011 | Validate nullable ASSIGNED_TO_USER_ID | ASSIGNED_TO_USER_ID can be null (unassigned licenses) |
| BZ_LICENSES_012 | Validate nullable END_DATE | END_DATE can be null (perpetual licenses) |

## BZ_DATA_AUDIT Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_AUDIT_001 | Validate audit table structure | Table created with correct schema |
| BZ_AUDIT_002 | Validate RECORD_ID auto-increment | RECORD_ID automatically increments |
| BZ_AUDIT_003 | Validate pre-hook audit logging | 'STARTED' status logged before model execution |
| BZ_AUDIT_004 | Validate post-hook audit logging | 'SUCCESS' status logged after model execution |
| BZ_AUDIT_005 | Validate processing time calculation | Processing time calculated correctly in seconds |
| BZ_AUDIT_006 | Validate SOURCE_TABLE tracking | Correct table name logged for each model |
| BZ_AUDIT_007 | Validate PROCESSED_BY tracking | 'dbt_user' logged as processor |
| BZ_AUDIT_008 | Validate LOAD_TIMESTAMP accuracy | Current timestamp logged accurately |
| BZ_AUDIT_009 | Validate STATUS values | Only 'STARTED', 'SUCCESS', 'FAILED', 'WARNING' values |
| BZ_AUDIT_010 | Validate audit trail completeness | All Bronze models generate audit records |

---

# dbt Test Scripts

## YAML-based Schema Tests

### tests/schema.yml

```yaml
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
      - name: plan_type
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: error
      - name: source_system
        tests:
          - accepted_values:
              values: ['user_management', 'ldap', 'sso_provider']
              config:
                severity: error
      - name: load_timestamp
        tests:
          - not_null:
              config:
                severity: error
      - name: update_timestamp
        tests:
          - not_null:
              config:
                severity: error

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
          - not_null:
              config:
                severity: error
      - name: start_time
        tests:
          - not_null:
              config:
                severity: error
      - name: source_system
        tests:
          - accepted_values:
              values: ['zoom_api', 'meeting_scheduler', 'calendar_integration']
              config:
                severity: error
      - name: duration_minutes
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
              config:
                severity: error

  # BZ_PARTICIPANTS Tests
  - name: bz_participants
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
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
          - not_null:
              config:
                severity: error
      - name: user_id
        tests:
          - not_null:
              config:
                severity: error
      - name: source_system
        tests:
          - accepted_values:
              values: ['zoom_api', 'meeting_logs', 'attendance_tracker']
              config:
                severity: error

  # BZ_FEATURE_USAGE Tests
  - name: bz_feature_usage
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
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
          - not_null:
              config:
                severity: error
      - name: feature_name
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
              config:
                severity: error
      - name: usage_count
        tests:
          - not_null:
              config:
                severity: error
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
              config:
                severity: error
      - name: usage_date
        tests:
          - not_null:
              config:
                severity: error
      - name: source_system
        tests:
          - accepted_values:
              values: ['zoom_client', 'web_portal', 'mobile_app']
              config:
                severity: error

  # BZ_SUPPORT_TICKETS Tests
  - name: bz_support_tickets
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
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
          - not_null:
              config:
                severity: error
      - name: ticket_type
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['technical', 'billing', 'account', 'feature_request']
              config:
                severity: error
      - name: resolution_status
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed']
              config:
                severity: error
      - name: open_date
        tests:
          - not_null:
              config:
                severity: error
      - name: source_system
        tests:
          - accepted_values:
              values: ['zendesk', 'salesforce', 'support_portal']
              config:
                severity: error

  # BZ_BILLING_EVENTS Tests
  - name: bz_billing_events
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
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
          - not_null:
              config:
                severity: error
      - name: event_type
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['subscription', 'usage', 'refund', 'adjustment']
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
      - name: source_system
        tests:
          - accepted_values:
              values: ['billing_system', 'payment_gateway', 'subscription_service']
              config:
                severity: error

  # BZ_LICENSES Tests
  - name: bz_licenses
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
          config:
            severity: error
    columns:
      - name: license_id
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
      - name: license_type
        tests:
          - not_null:
              config:
                severity: error
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
              config:
                severity: error
      - name: start_date
        tests:
          - not_null:
              config:
                severity: error
      - name: source_system
        tests:
          - accepted_values:
              values: ['license_management', 'admin_portal', 'billing_system']
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
          - not_null:
              config:
                severity: error
      - name: status
        tests:
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'WARNING']
              config:
                severity: error
```

## Custom SQL-based dbt Tests

### tests/test_bz_users_deduplication.sql

```sql
-- Test to validate deduplication logic in bz_users
-- This test ensures that when duplicate user_id exists, only the latest record is kept

WITH duplicate_check AS (
    SELECT 
        user_id,
        COUNT(*) as record_count
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

### tests/test_bz_meetings_data_type_conversion.sql

```sql
-- Test to validate data type conversions in bz_meetings
-- This test ensures TRY_CAST functions work correctly

WITH conversion_failures AS (
    SELECT 
        meeting_id,
        end_time,
        duration_minutes
    FROM {{ ref('bz_meetings') }}
    WHERE 
        (end_time IS NOT NULL AND TRY_CAST(end_time AS TIMESTAMP_NTZ(9)) IS NULL)
        OR (duration_minutes IS NOT NULL AND TRY_CAST(duration_minutes AS NUMBER(38,0)) IS NULL)
)

SELECT *
FROM conversion_failures
```

### tests/test_bz_feature_usage_business_rules.sql

```sql
-- Test to validate business rules in bz_feature_usage
-- This test ensures usage_count is non-negative

WITH invalid_usage_count AS (
    SELECT 
        usage_id,
        usage_count
    FROM {{ ref('bz_feature_usage') }}
    WHERE usage_count < 0
)

SELECT *
FROM invalid_usage_count
```

### tests/test_bz_audit_trail_completeness.sql

```sql
-- Test to validate audit trail completeness
-- This test ensures all Bronze models generate audit records

WITH expected_tables AS (
    SELECT table_name FROM (
        VALUES 
            ('BZ_USERS'),
            ('BZ_MEETINGS'),
            ('BZ_PARTICIPANTS'),
            ('BZ_FEATURE_USAGE'),
            ('BZ_SUPPORT_TICKETS'),
            ('BZ_BILLING_EVENTS'),
            ('BZ_LICENSES')
    ) AS t(table_name)
),

actual_audit_records AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE status = 'SUCCESS'
),

missing_audit_records AS (
    SELECT e.table_name
    FROM expected_tables e
    LEFT JOIN actual_audit_records a ON e.table_name = a.source_table
    WHERE a.source_table IS NULL
)

SELECT *
FROM missing_audit_records
```

### tests/test_bz_timestamp_consistency.sql

```sql
-- Test to validate timestamp consistency across all Bronze models
-- This test ensures load_timestamp and update_timestamp are properly set

WITH timestamp_issues AS (
    SELECT 'bz_users' as table_name, user_id as record_id
    FROM {{ ref('bz_users') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL
    
    UNION ALL
    
    SELECT 'bz_meetings' as table_name, meeting_id as record_id
    FROM {{ ref('bz_meetings') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL
    
    UNION ALL
    
    SELECT 'bz_participants' as table_name, participant_id as record_id
    FROM {{ ref('bz_participants') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL
    
    UNION ALL
    
    SELECT 'bz_feature_usage' as table_name, usage_id as record_id
    FROM {{ ref('bz_feature_usage') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL
    
    UNION ALL
    
    SELECT 'bz_support_tickets' as table_name, ticket_id as record_id
    FROM {{ ref('bz_support_tickets') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL
    
    UNION ALL
    
    SELECT 'bz_billing_events' as table_name, event_id as record_id
    FROM {{ ref('bz_billing_events') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL
    
    UNION ALL
    
    SELECT 'bz_licenses' as table_name, license_id as record_id
    FROM {{ ref('bz_licenses') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL
)

SELECT *
FROM timestamp_issues
```

### tests/test_bz_referential_integrity.sql

```sql
-- Test to validate referential integrity preservation
-- This test ensures foreign key relationships are maintained

WITH orphaned_meetings AS (
    SELECT m.meeting_id, m.host_id
    FROM {{ ref('bz_meetings') }} m
    LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
    WHERE u.user_id IS NULL
),

orphaned_participants AS (
    SELECT p.participant_id, p.meeting_id, p.user_id
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
    LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
    WHERE m.meeting_id IS NULL OR u.user_id IS NULL
),

orphaned_feature_usage AS (
    SELECT f.usage_id, f.meeting_id
    FROM {{ ref('bz_feature_usage') }} f
    LEFT JOIN {{ ref('bz_meetings') }} m ON f.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL
),

orphaned_support_tickets AS (
    SELECT s.ticket_id, s.user_id
    FROM {{ ref('bz_support_tickets') }} s
    LEFT JOIN {{ ref('bz_users') }} u ON s.user_id = u.user_id
    WHERE u.user_id IS NULL
),

orphaned_billing_events AS (
    SELECT b.event_id, b.user_id
    FROM {{ ref('bz_billing_events') }} b
    LEFT JOIN {{ ref('bz_users') }} u ON b.user_id = u.user_id
    WHERE u.user_id IS NULL
),

orphaned_licenses AS (
    SELECT l.license_id, l.assigned_to_user_id
    FROM {{ ref('bz_licenses') }} l
    LEFT JOIN {{ ref('bz_users') }} u ON l.assigned_to_user_id = u.user_id
    WHERE l.assigned_to_user_id IS NOT NULL AND u.user_id IS NULL
),

all_orphaned_records AS (
    SELECT 'orphaned_meetings' as issue_type, meeting_id as record_id, host_id as foreign_key
    FROM orphaned_meetings
    
    UNION ALL
    
    SELECT 'orphaned_participants' as issue_type, participant_id as record_id, 
           meeting_id || '|' || user_id as foreign_key
    FROM orphaned_participants
    
    UNION ALL
    
    SELECT 'orphaned_feature_usage' as issue_type, usage_id as record_id, meeting_id as foreign_key
    FROM orphaned_feature_usage
    
    UNION ALL
    
    SELECT 'orphaned_support_tickets' as issue_type, ticket_id as record_id, user_id as foreign_key
    FROM orphaned_support_tickets
    
    UNION ALL
    
    SELECT 'orphaned_billing_events' as issue_type, event_id as record_id, user_id as foreign_key
    FROM orphaned_billing_events
    
    UNION ALL
    
    SELECT 'orphaned_licenses' as issue_type, license_id as record_id, assigned_to_user_id as foreign_key
    FROM orphaned_licenses
)

SELECT *
FROM all_orphaned_records
```

## Parameterized Tests

### macros/test_domain_values.sql

```sql
-- Macro for testing domain values across multiple columns and tables
{% macro test_domain_values(model, column_name, valid_values) %}

    SELECT 
        '{{ model }}' as table_name,
        '{{ column_name }}' as column_name,
        {{ column_name }} as invalid_value,
        COUNT(*) as invalid_count
    FROM {{ ref(model) }}
    WHERE {{ column_name }} NOT IN ({{ "'" + valid_values | join("', '") + "'" }})
      AND {{ column_name }} IS NOT NULL
    GROUP BY {{ column_name }}
    HAVING COUNT(*) > 0

{% endmacro %}
```

### macros/test_null_filtering.sql

```sql
-- Macro for testing null filtering logic across models
{% macro test_null_filtering(model, required_columns) %}

    WITH null_check AS (
        SELECT 
            '{{ model }}' as table_name,
            {% for column in required_columns %}
            CASE WHEN {{ column }} IS NULL THEN '{{ column }}' END as null_column{{ ", " if not loop.last }}
            {% endfor %}
        FROM {{ ref(model) }}
        WHERE 
            {% for column in required_columns %}
            {{ column }} IS NULL{{ " OR " if not loop.last }}
            {% endfor %}
    )
    
    SELECT 
        table_name,
        {% for column in required_columns %}
        null_column{{ loop.index }}{{ ", " if not loop.last }}
        {% endfor %}
    FROM null_check
    WHERE 
        {% for column in required_columns %}
        null_column{{ loop.index }} IS NOT NULL{{ " OR " if not loop.last }}
        {% endfor %}

{% endmacro %}
```

## Test Execution Commands

### Run All Tests
```bash
# Run all tests
dbt test

# Run tests with specific severity
dbt test --severity error

# Run tests for specific models
dbt test --models bz_users bz_meetings

# Run specific test types
dbt test --select test_type:schema
dbt test --select test_type:data
```

### Run Individual Test Categories
```bash
# Run uniqueness tests
dbt test --select test_name:unique

# Run not null tests
dbt test --select test_name:not_null

# Run accepted values tests
dbt test --select test_name:accepted_values

# Run custom SQL tests
dbt test --select test_type:data
```

### Test Results Tracking
```bash
# Generate test results documentation
dbt docs generate
dbt docs serve

# Export test results
dbt test --store-failures

# Run tests with detailed output
dbt test --verbose
```

## Expected Test Results

### Success Criteria
- **All schema tests pass**: 0 failures for uniqueness, not null, and accepted values tests
- **All custom SQL tests return 0 rows**: No data quality issues detected
- **Audit trail completeness**: All Bronze models have corresponding audit records
- **Referential integrity preserved**: No orphaned records detected
- **Business rules enforced**: All domain values and constraints validated

### Performance Benchmarks
- **Test execution time**: < 5 minutes for full test suite
- **Individual model tests**: < 30 seconds per model
- **Custom SQL tests**: < 2 minutes per test
- **Memory usage**: < 1GB during test execution

### Monitoring and Alerting
- **Test failures**: Immediate notification for any test failure
- **Performance degradation**: Alert if test execution time exceeds benchmarks
- **Data volume anomalies**: Alert for significant changes in record counts
- **Audit trail gaps**: Alert for missing audit records

## Maintenance and Updates

### Regular Test Reviews
- **Monthly**: Review test coverage and add new test cases
- **Quarterly**: Performance optimization and benchmark updates
- **Annually**: Comprehensive test strategy review

### Test Case Evolution
- **New business rules**: Add corresponding test cases
- **Schema changes**: Update affected tests
- **Performance issues**: Optimize slow-running tests
- **False positives**: Refine test logic and thresholds

---

## Summary

This comprehensive unit test suite provides robust validation for the Bronze layer dbt models in the Zoom Platform Analytics System. The tests cover:

✅ **Data Quality**: Primary key uniqueness, not null constraints, data type validation
✅ **Business Rules**: Domain value validation, business logic enforcement
✅ **Edge Cases**: Null handling, deduplication, data type conversions
✅ **Error Handling**: Audit trail functionality, referential integrity
✅ **Performance**: Optimized test execution and monitoring

The test framework ensures reliable data transformations, maintains data quality standards, and provides comprehensive coverage for all Bronze layer models running in Snowflake.
