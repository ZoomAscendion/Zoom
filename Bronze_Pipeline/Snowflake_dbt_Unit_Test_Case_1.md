_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Platform Analytics Bronze Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Bronze layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliability and performance of the Bronze layer data pipeline.

## Test Coverage Overview

The Bronze layer consists of 8 main components:
- 7 Bronze layer tables (BZ_USERS, BZ_MEETINGS, BZ_PARTICIPANTS, BZ_FEATURE_USAGE, BZ_SUPPORT_TICKETS, BZ_BILLING_EVENTS, BZ_LICENSES)
- 1 Audit table (BZ_DATA_AUDIT)
- Data transformation logic with deduplication
- Audit logging with pre/post hooks

## Test Case List

### 1. Data Quality and Integrity Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_001 | Validate primary key uniqueness for all Bronze tables | All primary keys should be unique with no duplicates |
| TC_BZ_002 | Validate not-null constraints on mandatory fields | No null values in required fields (USER_ID, MEETING_ID, etc.) |
| TC_BZ_003 | Validate data type conversions from VARCHAR to appropriate types | All TRY_CAST operations should succeed or return null gracefully |
| TC_BZ_004 | Validate deduplication logic based on primary keys and timestamps | Only latest records should be retained based on LOAD_TIMESTAMP |
| TC_BZ_005 | Validate foreign key relationships (referential integrity) | All foreign key references should exist in parent tables |

### 2. Business Rule Validation Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_006 | Validate PLAN_TYPE domain values in BZ_USERS | Only 'Basic', 'Pro', 'Business', 'Enterprise' values allowed |
| TC_BZ_007 | Validate EVENT_TYPE domain values in BZ_BILLING_EVENTS | Only 'charge', 'refund', 'adjustment' values allowed |
| TC_BZ_008 | Validate FEATURE_NAME domain values in BZ_FEATURE_USAGE | Only 'screen_share', 'recording', 'chat', 'breakout_rooms' allowed |
| TC_BZ_009 | Validate TICKET_TYPE domain values in BZ_SUPPORT_TICKETS | Only 'technical', 'billing', 'account', 'feature_request' allowed |
| TC_BZ_010 | Validate RESOLUTION_STATUS domain values in BZ_SUPPORT_TICKETS | Only 'open', 'in_progress', 'resolved', 'closed' allowed |
| TC_BZ_011 | Validate LICENSE_TYPE domain values in BZ_LICENSES | Only 'Basic', 'Pro', 'Business', 'Enterprise' allowed |
| TC_BZ_012 | Validate SOURCE_SYSTEM values for each table | Verify correct source system mappings per table |

### 3. Edge Case and Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_013 | Handle null primary keys in source data | Records with null primary keys should be filtered out |
| TC_BZ_014 | Handle invalid date formats in source data | TRY_CAST should convert invalid dates to null |
| TC_BZ_015 | Handle invalid numeric formats in source data | TRY_CAST should convert invalid numbers to null |
| TC_BZ_016 | Handle empty string values in mandatory fields | Empty strings should be treated as null and handled appropriately |
| TC_BZ_017 | Handle duplicate records with same timestamp | Deduplication should use additional criteria (e.g., UPDATE_TIMESTAMP) |
| TC_BZ_018 | Handle missing source tables or schema changes | Pipeline should fail gracefully with appropriate error messages |
| TC_BZ_019 | Handle extremely large VARCHAR values | Values should be truncated or handled per Snowflake limits |
| TC_BZ_020 | Handle timezone conversion issues | TIMESTAMP_NTZ should handle various timezone inputs correctly |

### 4. Performance and Scalability Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_021 | Validate incremental model performance | Incremental loads should process only new/changed records |
| TC_BZ_022 | Validate large dataset processing | Models should handle datasets > 1M records efficiently |
| TC_BZ_023 | Validate memory usage during processing | Memory consumption should remain within acceptable limits |
| TC_BZ_024 | Validate concurrent execution handling | Multiple model runs should not cause deadlocks or conflicts |

### 5. Audit and Monitoring Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_025 | Validate audit table population | BZ_DATA_AUDIT should capture all model executions |
| TC_BZ_026 | Validate pre-hook audit logging | Pre-hook should log start of each model execution |
| TC_BZ_027 | Validate post-hook audit logging | Post-hook should log completion and processing metrics |
| TC_BZ_028 | Validate error logging in audit table | Failed executions should be logged with error details |
| TC_BZ_029 | Validate processing time tracking | Audit table should accurately track processing duration |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# schema.yml - Comprehensive schema tests for Bronze layer
version: 2

sources:
  - name: raw_zoom_data
    description: "Raw data from Zoom platform systems"
    database: DB_POC_ZOOM
    schema: RAW
    tables:
      - name: users
        description: "Raw user account information"
        columns:
          - name: user_id
            description: "Unique user identifier"
            tests:
              - not_null
              - unique
          - name: email
            description: "User email address"
            tests:
              - not_null
              - unique
          - name: plan_type
            description: "User subscription plan"
            tests:
              - accepted_values:
                  values: ['Basic', 'Pro', 'Business', 'Enterprise']
      
      - name: meetings
        description: "Raw meeting session data"
        columns:
          - name: meeting_id
            description: "Unique meeting identifier"
            tests:
              - not_null
              - unique
          - name: host_id
            description: "Meeting host user ID"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom_data', 'users')
                  field: user_id
      
      - name: participants
        description: "Raw meeting participant data"
        columns:
          - name: participant_id
            description: "Unique participant session identifier"
            tests:
              - not_null
              - unique
          - name: meeting_id
            description: "Reference to meeting"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom_data', 'meetings')
                  field: meeting_id
          - name: user_id
            description: "Reference to user"
            tests:
              - not_null
              - relationships:
                  to: source('raw_zoom_data', 'users')
                  field: user_id
      
      - name: feature_usage
        description: "Raw feature usage tracking"
        columns:
          - name: usage_id
            description: "Unique usage record identifier"
            tests:
              - not_null
              - unique
          - name: feature_name
            description: "Name of feature used"
            tests:
              - accepted_values:
                  values: ['screen_share', 'recording', 'chat', 'breakout_rooms']
          - name: usage_count
            description: "Number of times feature was used"
            tests:
              - not_null
              - dbt_utils.expression_is_true:
                  expression: ">= 0"
      
      - name: support_tickets
        description: "Raw support ticket data"
        columns:
          - name: ticket_id
            description: "Unique ticket identifier"
            tests:
              - not_null
              - unique
          - name: ticket_type
            description: "Type of support ticket"
            tests:
              - accepted_values:
                  values: ['technical', 'billing', 'account', 'feature_request']
          - name: resolution_status
            description: "Current ticket status"
            tests:
              - accepted_values:
                  values: ['open', 'in_progress', 'resolved', 'closed']
      
      - name: billing_events
        description: "Raw billing transaction data"
        columns:
          - name: event_id
            description: "Unique billing event identifier"
            tests:
              - not_null
              - unique
          - name: event_type
            description: "Type of billing event"
            tests:
              - accepted_values:
                  values: ['charge', 'refund', 'adjustment']
          - name: amount
            description: "Transaction amount"
            tests:
              - not_null
      
      - name: licenses
        description: "Raw license assignment data"
        columns:
          - name: license_id
            description: "Unique license identifier"
            tests:
              - not_null
              - unique
          - name: license_type
            description: "Type of license"
            tests:
              - accepted_values:
                  values: ['Basic', 'Pro', 'Business', 'Enterprise']

models:
  - name: bz_users
    description: "Bronze layer user data with deduplication and type conversion"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - not_null
          - unique
      - name: email
        description: "User email address"
        tests:
          - not_null
          - unique
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: load_timestamp
        description: "Record load timestamp"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['user_management', 'identity_service']
  
  - name: bz_meetings
    description: "Bronze layer meeting data with deduplication"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "Meeting host user ID"
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
              expression: ">= 0 OR duration_minutes IS NULL"
  
  - name: bz_participants
    description: "Bronze layer participant data with referential integrity"
    columns:
      - name: participant_id
        description: "Unique participant session identifier"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
  
  - name: bz_feature_usage
    description: "Bronze layer feature usage data"
    columns:
      - name: usage_id
        description: "Unique usage record identifier"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        description: "Name of feature used"
        tests:
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms']
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
  
  - name: bz_support_tickets
    description: "Bronze layer support ticket data"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user who created ticket"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - accepted_values:
              values: ['technical', 'billing', 'account', 'feature_request']
      - name: resolution_status
        description: "Current ticket status"
        tests:
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed']
  
  - name: bz_billing_events
    description: "Bronze layer billing event data"
    columns:
      - name: event_id
        description: "Unique billing event identifier"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_type
        description: "Type of billing event"
        tests:
          - accepted_values:
              values: ['charge', 'refund', 'adjustment']
      - name: amount
        description: "Transaction amount"
        tests:
          - not_null
  
  - name: bz_licenses
    description: "Bronze layer license data"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "Type of license"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
  
  - name: bz_data_audit
    description: "Bronze layer audit trail"
    columns:
      - name: record_id
        description: "Auto-incrementing audit record ID"
        tests:
          - not_null
          - unique
      - name: source_table
        description: "Name of the source table"
        tests:
          - not_null
      - name: load_timestamp
        description: "When the operation occurred"
        tests:
          - not_null
      - name: status
        description: "Operation status"
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING']
```

### Custom SQL-based dbt Tests

#### 1. Data Deduplication Test

```sql
-- tests/test_deduplication_logic.sql
-- Test to ensure deduplication logic works correctly

SELECT 
    source_table,
    primary_key_field,
    COUNT(*) as duplicate_count
FROM (
    SELECT 'bz_users' as source_table, user_id as primary_key_field FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings' as source_table, meeting_id as primary_key_field FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants' as source_table, participant_id as primary_key_field FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_feature_usage' as source_table, usage_id as primary_key_field FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_support_tickets' as source_table, ticket_id as primary_key_field FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_billing_events' as source_table, event_id as primary_key_field FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_licenses' as source_table, license_id as primary_key_field FROM {{ ref('bz_licenses') }}
)
GROUP BY source_table, primary_key_field
HAVING COUNT(*) > 1
```

#### 2. Data Type Conversion Test

```sql
-- tests/test_data_type_conversions.sql
-- Test to validate TRY_CAST operations are working correctly

WITH conversion_tests AS (
    SELECT 
        'bz_meetings' as table_name,
        'duration_minutes' as column_name,
        COUNT(CASE WHEN TRY_CAST(duration_minutes AS NUMBER) IS NULL AND duration_minutes IS NOT NULL THEN 1 END) as failed_conversions
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        'amount' as column_name,
        COUNT(CASE WHEN TRY_CAST(amount AS NUMBER(10,2)) IS NULL AND amount IS NOT NULL THEN 1 END) as failed_conversions
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        'usage_count' as column_name,
        COUNT(CASE WHEN TRY_CAST(usage_count AS NUMBER) IS NULL AND usage_count IS NOT NULL THEN 1 END) as failed_conversions
    FROM {{ ref('bz_feature_usage') }}
)

SELECT *
FROM conversion_tests
WHERE failed_conversions > 0
```

#### 3. Audit Trail Completeness Test

```sql
-- tests/test_audit_trail_completeness.sql
-- Test to ensure all model executions are logged in audit table

WITH expected_tables AS (
    SELECT table_name
    FROM (
        VALUES 
        ('bz_users'),
        ('bz_meetings'),
        ('bz_participants'),
        ('bz_feature_usage'),
        ('bz_support_tickets'),
        ('bz_billing_events'),
        ('bz_licenses')
    ) AS t(table_name)
),

logged_tables AS (
    SELECT DISTINCT LOWER(source_table) as table_name
    FROM {{ ref('bz_data_audit') }}
    WHERE DATE(load_timestamp) = CURRENT_DATE()
)

SELECT e.table_name
FROM expected_tables e
LEFT JOIN logged_tables l ON e.table_name = l.table_name
WHERE l.table_name IS NULL
```

#### 4. Referential Integrity Test

```sql
-- tests/test_referential_integrity.sql
-- Test to validate foreign key relationships

WITH integrity_violations AS (
    -- Check meetings.host_id -> users.user_id
    SELECT 'meetings_host_id' as violation_type, COUNT(*) as violation_count
    FROM {{ ref('bz_meetings') }} m
    LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
    WHERE m.host_id IS NOT NULL AND u.user_id IS NULL
    
    UNION ALL
    
    -- Check participants.meeting_id -> meetings.meeting_id
    SELECT 'participants_meeting_id' as violation_type, COUNT(*) as violation_count
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE p.meeting_id IS NOT NULL AND m.meeting_id IS NULL
    
    UNION ALL
    
    -- Check participants.user_id -> users.user_id
    SELECT 'participants_user_id' as violation_type, COUNT(*) as violation_count
    FROM {{ ref('bz_participants') }} p
    LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
    WHERE p.user_id IS NOT NULL AND u.user_id IS NULL
    
    UNION ALL
    
    -- Check feature_usage.meeting_id -> meetings.meeting_id
    SELECT 'feature_usage_meeting_id' as violation_type, COUNT(*) as violation_count
    FROM {{ ref('bz_feature_usage') }} f
    LEFT JOIN {{ ref('bz_meetings') }} m ON f.meeting_id = m.meeting_id
    WHERE f.meeting_id IS NOT NULL AND m.meeting_id IS NULL
    
    UNION ALL
    
    -- Check support_tickets.user_id -> users.user_id
    SELECT 'support_tickets_user_id' as violation_type, COUNT(*) as violation_count
    FROM {{ ref('bz_support_tickets') }} s
    LEFT JOIN {{ ref('bz_users') }} u ON s.user_id = u.user_id
    WHERE s.user_id IS NOT NULL AND u.user_id IS NULL
    
    UNION ALL
    
    -- Check billing_events.user_id -> users.user_id
    SELECT 'billing_events_user_id' as violation_type, COUNT(*) as violation_count
    FROM {{ ref('bz_billing_events') }} b
    LEFT JOIN {{ ref('bz_users') }} u ON b.user_id = u.user_id
    WHERE b.user_id IS NOT NULL AND u.user_id IS NULL
    
    UNION ALL
    
    -- Check licenses.assigned_to_user_id -> users.user_id
    SELECT 'licenses_assigned_to_user_id' as violation_type, COUNT(*) as violation_count
    FROM {{ ref('bz_licenses') }} l
    LEFT JOIN {{ ref('bz_users') }} u ON l.assigned_to_user_id = u.user_id
    WHERE l.assigned_to_user_id IS NOT NULL AND u.user_id IS NULL
)

SELECT *
FROM integrity_violations
WHERE violation_count > 0
```

#### 5. Data Freshness Test

```sql
-- tests/test_data_freshness.sql
-- Test to ensure data is being loaded within acceptable timeframes

WITH freshness_check AS (
    SELECT 
        'bz_users' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_users') }}
    
    UNION ALL
    
    SELECT 
        'bz_meetings' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_meetings') }}
    
    UNION ALL
    
    SELECT 
        'bz_participants' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_participants') }}
    
    UNION ALL
    
    SELECT 
        'bz_feature_usage' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_feature_usage') }}
    
    UNION ALL
    
    SELECT 
        'bz_support_tickets' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_support_tickets') }}
    
    UNION ALL
    
    SELECT 
        'bz_billing_events' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'bz_licenses' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('bz_licenses') }}
)

SELECT *
FROM freshness_check
WHERE hours_since_load > 24  -- Alert if data is older than 24 hours
```

#### 6. Performance Monitoring Test

```sql
-- tests/test_performance_monitoring.sql
-- Test to monitor processing times and identify performance issues

WITH performance_metrics AS (
    SELECT 
        source_table,
        AVG(processing_time) as avg_processing_time,
        MAX(processing_time) as max_processing_time,
        COUNT(*) as execution_count,
        COUNT(CASE WHEN status = 'FAILED' THEN 1 END) as failed_executions
    FROM {{ ref('bz_data_audit') }}
    WHERE DATE(load_timestamp) >= CURRENT_DATE() - 7  -- Last 7 days
    GROUP BY source_table
)

SELECT *
FROM performance_metrics
WHERE 
    avg_processing_time > 300  -- Alert if average processing time > 5 minutes
    OR max_processing_time > 600  -- Alert if max processing time > 10 minutes
    OR failed_executions > 0  -- Alert if any failures
```

## Test Execution Guidelines

### 1. Pre-deployment Testing
- Run all schema tests: `dbt test`
- Execute custom SQL tests: `dbt test --select test_type:custom`
- Validate data quality: `dbt test --select tag:data_quality`

### 2. Post-deployment Monitoring
- Schedule daily test runs for critical tests
- Monitor audit table for processing metrics
- Set up alerts for test failures

### 3. Performance Testing
- Execute performance tests weekly
- Monitor processing times and resource usage
- Optimize models based on performance metrics

### 4. Data Quality Monitoring
- Run referential integrity tests daily
- Monitor data freshness continuously
- Validate business rule compliance

## Expected Test Results

### Success Criteria
- All schema tests pass with 0 failures
- Custom SQL tests return 0 rows (indicating no issues)
- Audit table shows 'SUCCESS' status for all recent executions
- Processing times remain within acceptable thresholds
- Data freshness meets SLA requirements

### Failure Handling
- Test failures should trigger immediate alerts
- Failed model executions should be logged in audit table
- Retry mechanisms should be implemented for transient failures
- Data quality issues should prevent downstream processing

## Maintenance and Updates

### Regular Maintenance
- Review and update test cases monthly
- Add new tests for schema changes
- Monitor test performance and optimize as needed
- Update domain value lists as business rules change

### Version Control
- All test scripts should be version controlled
- Test changes should follow code review process
- Test results should be tracked and analyzed
- Documentation should be kept up to date

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics Bronze layer dbt models in Snowflake, providing confidence in the data pipeline's operation and supporting effective downstream analytics and reporting.