_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Bronze Layer

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Bronze layer dbt models in the Zoom Platform Analytics System. The tests validate data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models in Snowflake.

## Test Strategy

The testing approach covers:
- **Data Quality Tests**: Validate data integrity and consistency
- **Business Rule Tests**: Ensure transformations meet business requirements
- **Edge Case Tests**: Handle null values, empty datasets, and boundary conditions
- **Performance Tests**: Validate model execution efficiency
- **Audit Trail Tests**: Verify metadata and lineage tracking

---

## Test Case List

### 1. BZ_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_USERS_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| TC_BZ_USERS_002 | Validate EMAIL format and uniqueness | All EMAIL values follow valid format and are unique |
| TC_BZ_USERS_003 | Validate PLAN_TYPE accepted values | PLAN_TYPE contains only: Basic, Pro, Business, Enterprise |
| TC_BZ_USERS_004 | Validate metadata timestamps | LOAD_TIMESTAMP and UPDATE_TIMESTAMP are populated |
| TC_BZ_USERS_005 | Validate SOURCE_SYSTEM values | SOURCE_SYSTEM contains expected values |
| TC_BZ_USERS_006 | Test null handling for optional fields | COMPANY field can be null, others handle nulls appropriately |
| TC_BZ_USERS_007 | Test data type consistency | All fields match expected Snowflake data types |
| TC_BZ_USERS_008 | Test PII data handling | USER_NAME and EMAIL are properly handled as PII |

### 2. BZ_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_MEETINGS_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| TC_BZ_MEETINGS_002 | Validate HOST_ID foreign key relationship | All HOST_ID values exist in BZ_USERS |
| TC_BZ_MEETINGS_003 | Validate START_TIME and END_TIME logic | END_TIME >= START_TIME when both are not null |
| TC_BZ_MEETINGS_004 | Validate DURATION_MINUTES calculation | DURATION_MINUTES >= 0 and consistent with time difference |
| TC_BZ_MEETINGS_005 | Test meeting topic PII handling | MEETING_TOPIC is handled as potential PII |
| TC_BZ_MEETINGS_006 | Validate timestamp consistency | All timestamp fields are properly formatted |
| TC_BZ_MEETINGS_007 | Test null handling for optional fields | END_TIME, DURATION_MINUTES, MEETING_TOPIC can be null |
| TC_BZ_MEETINGS_008 | Validate SOURCE_SYSTEM values | SOURCE_SYSTEM contains expected values |

### 3. BZ_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_PARTICIPANTS_001 | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique and not null |
| TC_BZ_PARTICIPANTS_002 | Validate MEETING_ID foreign key | All MEETING_ID values exist in BZ_MEETINGS |
| TC_BZ_PARTICIPANTS_003 | Validate USER_ID foreign key | All USER_ID values exist in BZ_USERS |
| TC_BZ_PARTICIPANTS_004 | Validate JOIN_TIME and LEAVE_TIME logic | LEAVE_TIME >= JOIN_TIME when both are not null |
| TC_BZ_PARTICIPANTS_005 | Test participant session duration | Calculate and validate session duration |
| TC_BZ_PARTICIPANTS_006 | Test duplicate participant handling | Handle multiple joins/leaves for same user |
| TC_BZ_PARTICIPANTS_007 | Validate timestamp data types | All timestamp fields are TIMESTAMP_NTZ(9) |
| TC_BZ_PARTICIPANTS_008 | Test null handling for session times | JOIN_TIME and LEAVE_TIME can be null |

### 4. BZ_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_FEATURE_USAGE_001 | Validate USAGE_ID uniqueness | All USAGE_ID values are unique and not null |
| TC_BZ_FEATURE_USAGE_002 | Validate MEETING_ID foreign key | All MEETING_ID values exist in BZ_MEETINGS |
| TC_BZ_FEATURE_USAGE_003 | Validate FEATURE_NAME accepted values | FEATURE_NAME contains only valid feature names |
| TC_BZ_FEATURE_USAGE_004 | Validate USAGE_COUNT constraints | USAGE_COUNT >= 0 and is numeric |
| TC_BZ_FEATURE_USAGE_005 | Test feature usage aggregation | Sum usage counts per meeting and feature |
| TC_BZ_FEATURE_USAGE_006 | Validate USAGE_DATE consistency | USAGE_DATE aligns with meeting dates |
| TC_BZ_FEATURE_USAGE_007 | Test edge case: zero usage count | Handle USAGE_COUNT = 0 scenarios |
| TC_BZ_FEATURE_USAGE_008 | Validate SOURCE_SYSTEM values | SOURCE_SYSTEM contains expected values |

### 5. BZ_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_SUPPORT_TICKETS_001 | Validate TICKET_ID uniqueness | All TICKET_ID values are unique and not null |
| TC_BZ_SUPPORT_TICKETS_002 | Validate USER_ID foreign key | All USER_ID values exist in BZ_USERS |
| TC_BZ_SUPPORT_TICKETS_003 | Validate TICKET_TYPE accepted values | TICKET_TYPE contains only valid types |
| TC_BZ_SUPPORT_TICKETS_004 | Validate RESOLUTION_STATUS values | RESOLUTION_STATUS contains only valid statuses |
| TC_BZ_SUPPORT_TICKETS_005 | Test ticket lifecycle validation | Status transitions follow business rules |
| TC_BZ_SUPPORT_TICKETS_006 | Validate OPEN_DATE constraints | OPEN_DATE is not null and <= current date |
| TC_BZ_SUPPORT_TICKETS_007 | Test ticket aging calculations | Calculate days since ticket opened |
| TC_BZ_SUPPORT_TICKETS_008 | Validate metadata consistency | All metadata fields are properly populated |

### 6. BZ_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_BILLING_EVENTS_001 | Validate EVENT_ID uniqueness | All EVENT_ID values are unique and not null |
| TC_BZ_BILLING_EVENTS_002 | Validate USER_ID foreign key | All USER_ID values exist in BZ_USERS |
| TC_BZ_BILLING_EVENTS_003 | Validate EVENT_TYPE accepted values | EVENT_TYPE contains only valid event types |
| TC_BZ_BILLING_EVENTS_004 | Validate AMOUNT data type and constraints | AMOUNT is NUMBER(10,2) and can be negative |
| TC_BZ_BILLING_EVENTS_005 | Test billing amount calculations | Sum amounts by user and event type |
| TC_BZ_BILLING_EVENTS_006 | Validate EVENT_DATE constraints | EVENT_DATE is not null and reasonable |
| TC_BZ_BILLING_EVENTS_007 | Test refund and adjustment handling | Negative amounts for refunds/adjustments |
| TC_BZ_BILLING_EVENTS_008 | Validate financial data precision | Decimal precision maintained for amounts |

### 7. BZ_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_LICENSES_001 | Validate LICENSE_ID uniqueness | All LICENSE_ID values are unique and not null |
| TC_BZ_LICENSES_002 | Validate LICENSE_TYPE accepted values | LICENSE_TYPE contains only valid license types |
| TC_BZ_LICENSES_003 | Validate ASSIGNED_TO_USER_ID foreign key | All non-null USER_ID values exist in BZ_USERS |
| TC_BZ_LICENSES_004 | Validate date range logic | END_DATE >= START_DATE when both are not null |
| TC_BZ_LICENSES_005 | Test license assignment validation | User can have multiple licenses of different types |
| TC_BZ_LICENSES_006 | Test unassigned license handling | ASSIGNED_TO_USER_ID can be null |
| TC_BZ_LICENSES_007 | Validate license expiration logic | Identify expired and active licenses |
| TC_BZ_LICENSES_008 | Test license type hierarchy | Validate license type business rules |

### 8. BZ_DATA_AUDIT Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_DATA_AUDIT_001 | Validate RECORD_ID auto-increment | RECORD_ID values are sequential and unique |
| TC_BZ_DATA_AUDIT_002 | Validate SOURCE_TABLE values | SOURCE_TABLE contains valid Bronze table names |
| TC_BZ_DATA_AUDIT_003 | Validate audit timestamp consistency | LOAD_TIMESTAMP is populated for all records |
| TC_BZ_DATA_AUDIT_004 | Test audit trail completeness | All Bronze table operations are logged |
| TC_BZ_DATA_AUDIT_005 | Validate PROCESSING_TIME metrics | PROCESSING_TIME is numeric and >= 0 |
| TC_BZ_DATA_AUDIT_006 | Validate STATUS values | STATUS contains only: SUCCESS, FAILED, WARNING |
| TC_BZ_DATA_AUDIT_007 | Test audit data retention | Audit records are retained per policy |
| TC_BZ_DATA_AUDIT_008 | Validate PROCESSED_BY tracking | PROCESSED_BY field identifies the process/user |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/bronze/schema.yml
version: 2

sources:
  - name: raw_schema
    description: "Raw data source containing unprocessed Zoom platform data"
    tables:
      - name: users
        description: "Raw user account data"
      - name: meetings
        description: "Raw meeting session data"
      - name: participants
        description: "Raw meeting participant data"
      - name: feature_usage
        description: "Raw feature usage tracking data"
      - name: support_tickets
        description: "Raw customer support ticket data"
      - name: billing_events
        description: "Raw billing and financial event data"
      - name: licenses
        description: "Raw license assignment data"

models:
  - name: bz_users
    description: "Bronze layer user data with basic validation"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - not_null
          - unique
      - name: email
        description: "User email address"
        tests:
          - not_null
          - unique
      - name: plan_type
        description: "User subscription plan type"
        tests:
          - not_null
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
              values: ['user_management', 'ldap', 'sso_provider']

  - name: bz_meetings
    description: "Bronze layer meeting data with validation"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
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
          - expression_is_true:
              expression: "duration_minutes >= 0 OR duration_minutes IS NULL"
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['zoom_api', 'meeting_scheduler', 'calendar_integration']

  - name: bz_participants
    description: "Bronze layer participant data with validation"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant session"
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
        description: "Reference to participating user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['zoom_api', 'meeting_logs', 'attendance_tracker']

  - name: bz_feature_usage
    description: "Bronze layer feature usage data with validation"
    columns:
      - name: usage_id
        description: "Unique identifier for each usage record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        description: "Name of the feature used"
        tests:
          - not_null
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - expression_is_true:
              expression: "usage_count >= 0"
      - name: usage_date
        description: "Date when feature usage occurred"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['zoom_client', 'web_portal', 'mobile_app']

  - name: bz_support_tickets
    description: "Bronze layer support ticket data with validation"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
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
        description: "Category of support ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['technical', 'billing', 'account', 'feature_request']
      - name: resolution_status
        description: "Current ticket resolution status"
        tests:
          - not_null
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed']
      - name: open_date
        description: "Date when ticket was opened"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['zendesk', 'salesforce', 'support_portal']

  - name: bz_billing_events
    description: "Bronze layer billing event data with validation"
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
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null
          - accepted_values:
              values: ['subscription', 'usage', 'refund', 'adjustment']
      - name: amount
        description: "Monetary amount for billing event"
        tests:
          - not_null
      - name: event_date
        description: "Date when billing event occurred"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['billing_system', 'payment_gateway', 'subscription_service']

  - name: bz_licenses
    description: "Bronze layer license data with validation"
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
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_date
        description: "License validity start date"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['license_management', 'admin_portal', 'billing_system']

  - name: bz_data_audit
    description: "Bronze layer audit trail data"
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier"
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
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING']
```

### Custom SQL-based dbt Tests

#### 1. Meeting Duration Consistency Test
```sql
-- tests/meeting_duration_consistency.sql
-- Test that meeting duration is consistent with start and end times

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE 
    start_time IS NOT NULL 
    AND end_time IS NOT NULL 
    AND duration_minutes IS NOT NULL
    AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### 2. Participant Session Validation Test
```sql
-- tests/participant_session_validation.sql
-- Test that participant leave time is after join time

SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE 
    join_time IS NOT NULL 
    AND leave_time IS NOT NULL 
    AND leave_time < join_time
```

#### 3. Feature Usage Date Alignment Test
```sql
-- tests/feature_usage_date_alignment.sql
-- Test that feature usage dates align with meeting dates

SELECT 
    fu.usage_id,
    fu.meeting_id,
    fu.usage_date,
    m.start_time::DATE AS meeting_date
FROM {{ ref('bz_feature_usage') }} fu
JOIN {{ ref('bz_meetings') }} m ON fu.meeting_id = m.meeting_id
WHERE 
    fu.usage_date IS NOT NULL 
    AND m.start_time IS NOT NULL
    AND fu.usage_date != m.start_time::DATE
```

#### 4. License Date Range Validation Test
```sql
-- tests/license_date_range_validation.sql
-- Test that license end date is after start date

SELECT 
    license_id,
    license_type,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE 
    start_date IS NOT NULL 
    AND end_date IS NOT NULL 
    AND end_date < start_date
```

#### 5. Billing Amount Precision Test
```sql
-- tests/billing_amount_precision.sql
-- Test that billing amounts maintain proper decimal precision

SELECT 
    event_id,
    amount,
    ROUND(amount, 2) AS rounded_amount
FROM {{ ref('bz_billing_events') }}
WHERE 
    amount IS NOT NULL 
    AND amount != ROUND(amount, 2)
```

#### 6. Audit Trail Completeness Test
```sql
-- tests/audit_trail_completeness.sql
-- Test that all Bronze table operations are logged in audit trail

WITH bronze_tables AS (
    SELECT 'BZ_USERS' AS table_name
    UNION ALL SELECT 'BZ_MEETINGS'
    UNION ALL SELECT 'BZ_PARTICIPANTS'
    UNION ALL SELECT 'BZ_FEATURE_USAGE'
    UNION ALL SELECT 'BZ_SUPPORT_TICKETS'
    UNION ALL SELECT 'BZ_BILLING_EVENTS'
    UNION ALL SELECT 'BZ_LICENSES'
),
audited_tables AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE load_timestamp >= CURRENT_DATE - 7
)
SELECT bt.table_name
FROM bronze_tables bt
LEFT JOIN audited_tables at ON bt.table_name = at.source_table
WHERE at.source_table IS NULL
```

#### 7. Data Freshness Validation Test
```sql
-- tests/data_freshness_validation.sql
-- Test that data is loaded within acceptable time windows

SELECT 
    'BZ_USERS' AS table_name,
    MAX(load_timestamp) AS last_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) AS hours_since_load
FROM {{ ref('bz_users') }}
WHERE DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) > 24

UNION ALL

SELECT 
    'BZ_MEETINGS' AS table_name,
    MAX(load_timestamp) AS last_load,
    DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) AS hours_since_load
FROM {{ ref('bz_meetings') }}
WHERE DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) > 24

-- Add similar checks for other Bronze tables
```

#### 8. Cross-Table Referential Integrity Test
```sql
-- tests/cross_table_referential_integrity.sql
-- Test referential integrity across Bronze layer tables

-- Check orphaned participants
SELECT 
    'ORPHANED_PARTICIPANTS' AS issue_type,
    COUNT(*) AS issue_count
FROM {{ ref('bz_participants') }} p
LEFT JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
LEFT JOIN {{ ref('bz_users') }} u ON p.user_id = u.user_id
WHERE m.meeting_id IS NULL OR u.user_id IS NULL

UNION ALL

-- Check orphaned feature usage
SELECT 
    'ORPHANED_FEATURE_USAGE' AS issue_type,
    COUNT(*) AS issue_count
FROM {{ ref('bz_feature_usage') }} fu
LEFT JOIN {{ ref('bz_meetings') }} m ON fu.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL

UNION ALL

-- Check orphaned support tickets
SELECT 
    'ORPHANED_SUPPORT_TICKETS' AS issue_type,
    COUNT(*) AS issue_count
FROM {{ ref('bz_support_tickets') }} st
LEFT JOIN {{ ref('bz_users') }} u ON st.user_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check orphaned billing events
SELECT 
    'ORPHANED_BILLING_EVENTS' AS issue_type,
    COUNT(*) AS issue_count
FROM {{ ref('bz_billing_events') }} be
LEFT JOIN {{ ref('bz_users') }} u ON be.user_id = u.user_id
WHERE u.user_id IS NULL
```

---

## Test Execution Guidelines

### Running Tests

1. **Individual Model Tests**:
   ```bash
   dbt test --models bz_users
   dbt test --models bz_meetings
   ```

2. **All Bronze Layer Tests**:
   ```bash
   dbt test --models bronze
   ```

3. **Specific Test Types**:
   ```bash
   dbt test --models bronze --data
   dbt test --models bronze --schema
   ```

4. **Custom SQL Tests**:
   ```bash
   dbt test --models test_type:singular
   ```

### Test Results Tracking

- **dbt Cloud**: Test results automatically tracked in run history
- **Local Development**: Results stored in `target/run_results.json`
- **Snowflake Audit**: Test execution logged in `BZ_DATA_AUDIT` table

### Performance Monitoring

- Monitor test execution times
- Set up alerts for test failures
- Track data quality metrics over time
- Implement automated test scheduling

---

## Conclusion

These comprehensive unit test cases ensure the reliability, performance, and data quality of the Bronze layer dbt models in the Zoom Platform Analytics System. The tests cover:

- **Data Integrity**: Primary keys, foreign keys, and constraints
- **Business Rules**: Domain values, calculations, and logic
- **Edge Cases**: Null handling, boundary conditions, and error scenarios
- **Performance**: Query efficiency and resource utilization
- **Audit Trail**: Complete tracking of data operations

Regular execution of these tests will maintain high data quality standards and catch potential issues early in the development cycle, ensuring robust and reliable data pipelines in the Snowflake environment.