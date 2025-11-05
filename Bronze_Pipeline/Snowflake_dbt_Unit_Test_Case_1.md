_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics Bronze Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models.

## Test Coverage Overview

The test suite covers 8 Bronze Layer models:
- `bz_audit_log` - Audit tracking table
- `bz_users` - User account information
- `bz_meetings` - Meeting session data
- `bz_participants` - Meeting participation records
- `bz_feature_usage` - Feature usage analytics
- `bz_support_tickets` - Customer support tickets
- `bz_billing_events` - Billing transaction records
- `bz_licenses` - License assignment data

---

## Test Case List

### 1. Data Quality and Integrity Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_DQ_001 | Validate primary key uniqueness across all bronze tables | All primary key fields should be unique with no duplicates | All models |
| TC_DQ_002 | Validate not null constraints on critical fields | Critical fields should not contain null values | All models |
| TC_DQ_003 | Validate data type consistency between source and bronze | All data types should match expected Snowflake types | All models |
| TC_DQ_004 | Validate referential integrity between related tables | Foreign key relationships should be maintained | bz_meetings, bz_participants, bz_feature_usage |
| TC_DQ_005 | Validate accepted values for enumerated fields | Enumerated fields should only contain valid domain values | bz_users, bz_support_tickets, bz_billing_events |

### 2. Data Transformation Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_DT_001 | Validate 1-1 mapping from RAW to BRONZE schema | All source records should be mapped correctly to bronze | All models |
| TC_DT_002 | Validate data type casting operations | All CAST operations should execute without errors | All models |
| TC_DT_003 | Validate duplicate record handling using ROW_NUMBER | Only most recent records should be retained per primary key | All models |
| TC_DT_004 | Validate data quality flag assignment | Records should be correctly flagged as VALID or with specific error codes | All models |
| TC_DT_005 | Validate metadata field population | LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM should be populated | All models |

### 3. Business Logic Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_BL_001 | Validate meeting duration calculation consistency | DURATION_MINUTES should align with START_TIME and END_TIME | bz_meetings |
| TC_BL_002 | Validate participant session time logic | JOIN_TIME should be <= LEAVE_TIME when both are present | bz_participants |
| TC_BL_003 | Validate license date range logic | START_DATE should be <= END_DATE when END_DATE is present | bz_licenses |
| TC_BL_004 | Validate billing amount precision | AMOUNT field should maintain 2 decimal precision | bz_billing_events |
| TC_BL_005 | Validate feature usage count logic | USAGE_COUNT should be >= 0 | bz_feature_usage |

### 4. Edge Case Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_EC_001 | Handle empty source tables | Models should execute successfully with empty result sets | All models |
| TC_EC_002 | Handle records with all null values | Records should be filtered out by data quality checks | All models |
| TC_EC_003 | Handle extremely large string values | String fields should accommodate maximum Snowflake VARCHAR length | All models |
| TC_EC_004 | Handle future dates in timestamp fields | Future dates should be accepted without validation errors | All models |
| TC_EC_005 | Handle negative values in numeric fields | Negative values should be handled according to business rules | bz_billing_events, bz_feature_usage |

### 5. Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_EH_001 | Handle missing source tables gracefully | Models should fail gracefully with clear error messages | All models |
| TC_EH_002 | Handle schema mismatches in source data | Models should continue processing with logged warnings | All models |
| TC_EH_003 | Handle circular dependency in audit logging | Audit hooks should only execute when audit table exists | All models |
| TC_EH_004 | Handle concurrent execution scenarios | Models should handle concurrent runs without data corruption | All models |
| TC_EH_005 | Handle source system connectivity issues | Models should retry and log appropriate error messages | All models |

### 6. Performance Tests

| Test Case ID | Test Case Description | Expected Outcome | Model(s) Tested |
|--------------|----------------------|------------------|----------------|
| TC_PF_001 | Validate execution time within SLA | Each model should complete within 60 seconds for standard datasets | All models |
| TC_PF_002 | Validate memory usage efficiency | Models should not exceed warehouse memory limits | All models |
| TC_PF_003 | Validate incremental processing capability | Models should support incremental loads using LOAD_TIMESTAMP | All models |
| TC_PF_004 | Validate large dataset processing | Models should handle datasets with 1M+ records efficiently | All models |
| TC_PF_005 | Validate concurrent user access | Multiple users should be able to query bronze tables simultaneously | All models |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

sources:
  - name: raw_zoom
    description: "Raw data source for Zoom platform analytics"
    database: DB_POC_ZOOM
    schema: RAW
    tables:
      - name: users
        description: "Raw user account information"
        columns:
          - name: user_id
            description: "Unique identifier for each user account"
            tests:
              - not_null
              - unique
          - name: email
            description: "Email address of the user account"
            tests:
              - not_null
              - unique

      - name: meetings
        description: "Raw meeting information"
        columns:
          - name: meeting_id
            description: "Unique identifier for each meeting session"
            tests:
              - not_null
              - unique
          - name: host_id
            description: "User ID of the meeting host"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom', 'users')
                  field: user_id

      - name: participants
        description: "Raw participant information"
        columns:
          - name: participant_id
            description: "Unique identifier for each participant session"
            tests:
              - not_null
              - unique
          - name: meeting_id
            description: "Meeting identifier"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom', 'meetings')
                  field: meeting_id
          - name: user_id
            description: "User identifier"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom', 'users')
                  field: user_id

      - name: feature_usage
        description: "Raw feature usage information"
        columns:
          - name: usage_id
            description: "Unique identifier for each feature usage record"
            tests:
              - not_null
              - unique
          - name: meeting_id
            description: "Meeting identifier"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom', 'meetings')
                  field: meeting_id
          - name: feature_name
            description: "Name of the Zoom feature"
            tests:
              - not_null
              - accepted_values:
                  values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
          - name: usage_count
            description: "Number of times feature was used"
            tests:
              - not_null
              - dbt_utils.expression_is_true:
                  expression: ">= 0"

      - name: support_tickets
        description: "Raw support ticket information"
        columns:
          - name: ticket_id
            description: "Unique identifier for each support ticket"
            tests:
              - not_null
              - unique
          - name: user_id
            description: "User identifier"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom', 'users')
                  field: user_id
          - name: ticket_type
            description: "Category of support ticket"
            tests:
              - not_null
              - accepted_values:
                  values: ['technical_issue', 'billing_inquiry', 'feature_request', 'account_access']
          - name: resolution_status
            description: "Current status of ticket"
            tests:
              - not_null
              - accepted_values:
                  values: ['open', 'in_progress', 'resolved', 'closed', 'escalated']

      - name: billing_events
        description: "Raw billing event information"
        columns:
          - name: event_id
            description: "Unique identifier for each billing event"
            tests:
              - not_null
              - unique
          - name: user_id
            description: "User identifier"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom', 'users')
                  field: user_id
          - name: event_type
            description: "Type of billing event"
            tests:
              - not_null
              - accepted_values:
                  values: ['charge', 'credit', 'refund', 'adjustment']
          - name: amount
            description: "Monetary amount"
            tests:
              - not_null

      - name: licenses
        description: "Raw license information"
        columns:
          - name: license_id
            description: "Unique identifier for each license"
            tests:
              - not_null
              - unique
          - name: assigned_to_user_id
            description: "User ID assigned to license"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom', 'users')
                  field: user_id
          - name: license_type
            description: "Type of license"
            tests:
              - not_null
              - accepted_values:
                  values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']

models:
  - name: bz_audit_log
    description: "Bronze layer audit log for tracking data processing activities"
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier for audit records"
        tests:
          - unique
      - name: source_table
        description: "Name of the source table being processed"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when the processing started"
        tests:
          - not_null
      - name: processed_by
        description: "System or process that performed the operation"
        tests:
          - not_null
      - name: status
        description: "Status of the processing operation"
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED']

  - name: bz_users
    description: "Bronze layer users table with cleaned and validated data"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "Display name of the user"
        tests:
          - not_null
      - name: email
        description: "Email address of the user account"
        tests:
          - not_null
          - unique
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'User_Management_System', 'Registration_Portal']

  - name: bz_meetings
    description: "Bronze layer meetings table with cleaned and validated data"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting session"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'Meeting_Dashboard']

  - name: bz_participants
    description: "Bronze layer participants table with cleaned and validated data"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant session"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Meeting identifier"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        description: "User identifier"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: join_time
        description: "Participant join timestamp"
        tests:
          - not_null
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'Participant_Tracking_System']

  - name: bz_feature_usage
    description: "Bronze layer feature usage table with cleaned and validated data"
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Meeting identifier"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        description: "Name of the Zoom feature"
        tests:
          - not_null
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'Analytics_System']

  - name: bz_support_tickets
    description: "Bronze layer support tickets table with cleaned and validated data"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "User identifier"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        description: "Category of support ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['technical_issue', 'billing_inquiry', 'feature_request', 'account_access']
      - name: resolution_status
        description: "Current status of ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed', 'escalated']
      - name: open_date
        description: "Date when ticket was created"
        tests:
          - not_null
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Support_Portal', 'CRM_System', 'Email_Integration']

  - name: bz_billing_events
    description: "Bronze layer billing events table with cleaned and validated data"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "User identifier"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null
          - accepted_values:
              values: ['charge', 'credit', 'refund', 'adjustment']
      - name: amount
        description: "Monetary amount"
        tests:
          - not_null
      - name: event_date
        description: "Date of billing event"
        tests:
          - not_null
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_API', 'Billing_System', 'Manual_Entry']

  - name: bz_licenses
    description: "Bronze layer licenses table with cleaned and validated data"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        description: "User ID assigned to license"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: license_type
        description: "Type of license"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['Zoom_Admin_API', 'License_Management_System']
```

### Custom SQL Tests

#### 1. Data Quality Tests (tests/data_quality/)

**test_duplicate_records.sql**
```sql
-- Test to ensure no duplicate records exist after deduplication logic
{{ config(severity = 'error') }}

WITH duplicate_check AS (
    SELECT 
        'bz_users' as table_name,
        user_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_users') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        meeting_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_meetings') }}
    GROUP BY meeting_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        participant_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_participants') }}
    GROUP BY participant_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        usage_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_feature_usage') }}
    GROUP BY usage_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        ticket_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_support_tickets') }}
    GROUP BY ticket_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        event_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_billing_events') }}
    GROUP BY event_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        license_id as primary_key,
        COUNT(*) as record_count
    FROM {{ ref('bz_licenses') }}
    GROUP BY license_id
    HAVING COUNT(*) > 1
)

SELECT *
FROM duplicate_check
```

**test_data_freshness.sql**
```sql
-- Test to ensure data freshness within acceptable limits
{{ config(severity = 'warn') }}

WITH freshness_check AS (
    SELECT 
        'bz_users' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hours', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hours', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hours', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hours', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_feature_usage') }}
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hours', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_support_tickets') }}
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hours', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hours', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_licenses') }}
)

SELECT *
FROM freshness_check
WHERE hours_since_load > 24  -- Alert if data is older than 24 hours
```

#### 2. Business Logic Tests (tests/business_logic/)

**test_meeting_duration_consistency.sql**
```sql
-- Test to validate meeting duration calculation consistency
{{ config(severity = 'error') }}

WITH duration_check AS (
    SELECT 
        meeting_id,
        start_time,
        end_time,
        duration_minutes,
        CASE 
            WHEN end_time IS NOT NULL AND start_time IS NOT NULL 
            THEN DATEDIFF('minutes', start_time, end_time)
            ELSE NULL 
        END as calculated_duration
    FROM {{ ref('bz_meetings') }}
    WHERE end_time IS NOT NULL 
    AND start_time IS NOT NULL
    AND duration_minutes IS NOT NULL
)

SELECT 
    meeting_id,
    duration_minutes,
    calculated_duration,
    ABS(duration_minutes - calculated_duration) as duration_difference
FROM duration_check
WHERE ABS(duration_minutes - calculated_duration) > 1  -- Allow 1 minute tolerance
```

**test_participant_time_logic.sql**
```sql
-- Test to validate participant join/leave time logic
{{ config(severity = 'error') }}

SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE leave_time IS NOT NULL 
AND join_time IS NOT NULL
AND leave_time < join_time  -- Leave time should not be before join time
```

**test_license_date_range_logic.sql**
```sql
-- Test to validate license date range logic
{{ config(severity = 'error') }}

SELECT 
    license_id,
    assigned_to_user_id,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE end_date IS NOT NULL 
AND start_date IS NOT NULL
AND end_date < start_date  -- End date should not be before start date
```

#### 3. Edge Case Tests (tests/edge_cases/)

**test_empty_string_handling.sql**
```sql
-- Test to identify records with empty strings that should be null
{{ config(severity = 'warn') }}

WITH empty_string_check AS (
    SELECT 'bz_users' as table_name, user_id as record_id, 'user_name' as field_name
    FROM {{ ref('bz_users') }}
    WHERE user_name = ''
    
    UNION ALL
    
    SELECT 'bz_users' as table_name, user_id as record_id, 'email' as field_name
    FROM {{ ref('bz_users') }}
    WHERE email = ''
    
    UNION ALL
    
    SELECT 'bz_meetings' as table_name, meeting_id as record_id, 'meeting_topic' as field_name
    FROM {{ ref('bz_meetings') }}
    WHERE meeting_topic = ''
)

SELECT *
FROM empty_string_check
```

**test_future_dates.sql**
```sql
-- Test to identify records with future dates that may indicate data quality issues
{{ config(severity = 'warn') }}

WITH future_date_check AS (
    SELECT 
        'bz_meetings' as table_name,
        meeting_id as record_id,
        'start_time' as field_name,
        start_time as date_value
    FROM {{ ref('bz_meetings') }}
    WHERE start_time > CURRENT_TIMESTAMP()
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        ticket_id as record_id,
        'open_date' as field_name,
        open_date::timestamp as date_value
    FROM {{ ref('bz_support_tickets') }}
    WHERE open_date > CURRENT_DATE()
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        event_id as record_id,
        'event_date' as field_name,
        event_date::timestamp as date_value
    FROM {{ ref('bz_billing_events') }}
    WHERE event_date > CURRENT_DATE()
)

SELECT *
FROM future_date_check
```

#### 4. Performance Tests (tests/performance/)

**test_row_count_validation.sql**
```sql
-- Test to validate expected row counts and identify significant changes
{{ config(severity = 'warn') }}

WITH row_counts AS (
    SELECT 'bz_users' as table_name, COUNT(*) as current_count
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 'bz_meetings' as table_name, COUNT(*) as current_count
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 'bz_participants' as table_name, COUNT(*) as current_count
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    SELECT 'bz_feature_usage' as table_name, COUNT(*) as current_count
    FROM {{ ref('bz_feature_usage') }}
    
    UNION ALL
    
    SELECT 'bz_support_tickets' as table_name, COUNT(*) as current_count
    FROM {{ ref('bz_support_tickets') }}
    
    UNION ALL
    
    SELECT 'bz_billing_events' as table_name, COUNT(*) as current_count
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 'bz_licenses' as table_name, COUNT(*) as current_count
    FROM {{ ref('bz_licenses') }}
)

SELECT 
    table_name,
    current_count,
    CASE 
        WHEN current_count = 0 THEN 'EMPTY_TABLE'
        WHEN current_count < 100 THEN 'LOW_VOLUME'
        WHEN current_count > 1000000 THEN 'HIGH_VOLUME'
        ELSE 'NORMAL'
    END as volume_status
FROM row_counts
```

#### 5. Audit Tests (tests/audit/)

**test_audit_log_completeness.sql**
```sql
-- Test to ensure audit log captures all table processing activities
{{ config(severity = 'error') }}

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
logged_tables AS (
    SELECT DISTINCT source_table as table_name
    FROM {{ ref('bz_audit_log') }}
    WHERE load_timestamp >= CURRENT_DATE()
)

SELECT et.table_name
FROM expected_tables et
LEFT JOIN logged_tables lt ON et.table_name = lt.table_name
WHERE lt.table_name IS NULL
```

**test_processing_time_monitoring.sql**
```sql
-- Test to monitor processing times and identify performance issues
{{ config(severity = 'warn') }}

SELECT 
    source_table,
    load_timestamp,
    processing_time,
    status
FROM {{ ref('bz_audit_log') }}
WHERE processing_time > 300  -- Alert if processing takes more than 5 minutes
AND load_timestamp >= CURRENT_DATE()
ORDER BY processing_time DESC
```

---

## Test Execution Guidelines

### 1. Test Execution Order
1. **Schema Tests**: Run first to validate basic data structure and constraints
2. **Data Quality Tests**: Validate data integrity and completeness
3. **Business Logic Tests**: Verify business rule compliance
4. **Edge Case Tests**: Check handling of unusual data scenarios
5. **Performance Tests**: Monitor execution performance and resource usage
6. **Audit Tests**: Validate audit trail completeness

### 2. Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select bz_users

# Run specific test type
dbt test --select tag:data_quality

# Run tests with specific severity
dbt test --severity error

# Generate test documentation
dbt docs generate
dbt docs serve
```

### 3. Test Result Interpretation

| Test Result | Action Required | Description |
|-------------|-----------------|-------------|
| PASS | None | Test executed successfully with no issues |
| WARN | Review | Test identified potential issues that should be reviewed |
| ERROR | Fix Required | Test failed and requires immediate attention |
| SKIP | Investigate | Test was skipped, verify test configuration |

### 4. Continuous Integration

```yaml
# Example GitHub Actions workflow for dbt testing
name: dbt_test_pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup dbt
        uses: dbt-labs/dbt-action@v1
        with:
          dbt-command: "dbt deps && dbt test --profiles-dir ."
```

---

## Monitoring and Alerting

### 1. Key Metrics to Monitor
- Test pass/fail rates by model and test type
- Data freshness and processing times
- Row count variations and data volume trends
- Error patterns and frequency

### 2. Alert Thresholds
- **Critical**: Any ERROR level test failures
- **Warning**: More than 5 WARN level test failures in 24 hours
- **Info**: Processing time exceeds baseline by 50%

### 3. Test Result Storage
Test results are automatically stored in:
- `target/run_results.json` - Detailed test execution results
- Snowflake audit schema - Test execution history
- dbt Cloud - Test result dashboard (if using dbt Cloud)

---

## Maintenance and Updates

### 1. Regular Review Schedule
- **Weekly**: Review test results and failure patterns
- **Monthly**: Update test thresholds based on data patterns
- **Quarterly**: Review and update test coverage

### 2. Test Evolution
- Add new tests as business requirements change
- Update accepted values as domain values evolve
- Enhance performance tests as data volumes grow
- Refine edge case tests based on production issues

### 3. Documentation Updates
- Keep test descriptions current with business logic
- Update expected outcomes as requirements change
- Maintain test execution guidelines
- Document test result interpretation procedures

---

**End of Document**

*This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics Bronze Layer dbt models in Snowflake. Regular execution and monitoring of these tests will help maintain high-quality data pipelines and catch issues early in the development cycle.*