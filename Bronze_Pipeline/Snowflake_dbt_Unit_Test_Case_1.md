_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Layer pipeline running in Snowflake. The tests validate data transformations, business rules, edge cases, and error handling across all Bronze layer models including audit functionality.

## Test Coverage Summary

| Model | Primary Tests | Edge Case Tests | Custom Tests | Total Tests |
|-------|---------------|-----------------|--------------|-------------|
| bz_users | 5 | 3 | 2 | 10 |
| bz_meetings | 6 | 4 | 3 | 13 |
| bz_participants | 5 | 3 | 2 | 10 |
| bz_feature_usage | 6 | 4 | 2 | 12 |
| bz_support_tickets | 5 | 3 | 2 | 10 |
| bz_billing_events | 6 | 4 | 3 | 13 |
| bz_licenses | 5 | 3 | 2 | 10 |
| bz_data_audit | 4 | 2 | 2 | 8 |
| **Total** | **42** | **26** | **18** | **86** |

---

## Test Case Specifications

### 1. BZ_USERS Model Tests

#### Test Case ID: BZ_USERS_001
**Test Case Description**: Validate primary key uniqueness and not null constraints
**Expected Outcome**: All USER_ID values are unique and not null

#### Test Case ID: BZ_USERS_002
**Test Case Description**: Validate email format and uniqueness
**Expected Outcome**: All EMAIL values follow valid email format and are unique

#### Test Case ID: BZ_USERS_003
**Test Case Description**: Validate plan type domain values
**Expected Outcome**: PLAN_TYPE contains only valid values (Basic, Pro, Business, Enterprise)

#### Test Case ID: BZ_USERS_004
**Test Case Description**: Validate timestamp consistency
**Expected Outcome**: LOAD_TIMESTAMP and UPDATE_TIMESTAMP are properly populated

#### Test Case ID: BZ_USERS_005
**Test Case Description**: Validate source system tracking
**Expected Outcome**: SOURCE_SYSTEM contains valid source identifiers

#### Test Case ID: BZ_USERS_006 (Edge Case)
**Test Case Description**: Handle null company values
**Expected Outcome**: Records with null COMPANY are processed correctly

#### Test Case ID: BZ_USERS_007 (Edge Case)
**Test Case Description**: Handle duplicate user records
**Expected Outcome**: Deduplication logic retains latest record based on timestamp

#### Test Case ID: BZ_USERS_008 (Edge Case)
**Test Case Description**: Handle invalid email formats
**Expected Outcome**: Invalid emails are flagged but not rejected

#### Test Case ID: BZ_USERS_009 (Custom)
**Test Case Description**: Validate PII data handling
**Expected Outcome**: USER_NAME and EMAIL are properly tracked as PII

#### Test Case ID: BZ_USERS_010 (Custom)
**Test Case Description**: Validate audit trail integration
**Expected Outcome**: Each user record processing is logged in audit table

---

### 2. BZ_MEETINGS Model Tests

#### Test Case ID: BZ_MEETINGS_001
**Test Case Description**: Validate meeting ID uniqueness
**Expected Outcome**: All MEETING_ID values are unique and not null

#### Test Case ID: BZ_MEETINGS_002
**Test Case Description**: Validate host ID foreign key relationship
**Expected Outcome**: All HOST_ID values reference valid users

#### Test Case ID: BZ_MEETINGS_003
**Test Case Description**: Validate meeting duration calculation
**Expected Outcome**: DURATION_MINUTES matches calculated difference between START_TIME and END_TIME

#### Test Case ID: BZ_MEETINGS_004
**Test Case Description**: Validate timestamp logical consistency
**Expected Outcome**: END_TIME is always after START_TIME when both are present

#### Test Case ID: BZ_MEETINGS_005
**Test Case Description**: Validate meeting topic PII handling
**Expected Outcome**: MEETING_TOPIC is flagged as potential PII

#### Test Case ID: BZ_MEETINGS_006
**Test Case Description**: Validate source system tracking
**Expected Outcome**: SOURCE_SYSTEM contains valid source identifiers

#### Test Case ID: BZ_MEETINGS_007 (Edge Case)
**Test Case Description**: Handle ongoing meetings (null end time)
**Expected Outcome**: Records with null END_TIME are processed correctly

#### Test Case ID: BZ_MEETINGS_008 (Edge Case)
**Test Case Description**: Handle zero duration meetings
**Expected Outcome**: Meetings with DURATION_MINUTES = 0 are handled appropriately

#### Test Case ID: BZ_MEETINGS_009 (Edge Case)
**Test Case Description**: Handle meetings with null topics
**Expected Outcome**: Records with null MEETING_TOPIC are processed correctly

#### Test Case ID: BZ_MEETINGS_010 (Edge Case)
**Test Case Description**: Handle invalid duration values
**Expected Outcome**: Negative duration values are flagged for review

#### Test Case ID: BZ_MEETINGS_011 (Custom)
**Test Case Description**: Validate meeting overlap detection
**Expected Outcome**: Overlapping meetings for same host are identified

#### Test Case ID: BZ_MEETINGS_012 (Custom)
**Test Case Description**: Validate meeting duration thresholds
**Expected Outcome**: Meetings exceeding 24 hours are flagged for review

#### Test Case ID: BZ_MEETINGS_013 (Custom)
**Test Case Description**: Validate audit trail for meeting operations
**Expected Outcome**: All meeting record operations are logged in audit table

---

### 3. BZ_PARTICIPANTS Model Tests

#### Test Case ID: BZ_PARTICIPANTS_001
**Test Case Description**: Validate participant ID uniqueness
**Expected Outcome**: All PARTICIPANT_ID values are unique and not null

#### Test Case ID: BZ_PARTICIPANTS_002
**Test Case Description**: Validate meeting and user foreign key relationships
**Expected Outcome**: MEETING_ID and USER_ID reference valid records

#### Test Case ID: BZ_PARTICIPANTS_003
**Test Case Description**: Validate join/leave time consistency
**Expected Outcome**: LEAVE_TIME is after JOIN_TIME when both are present

#### Test Case ID: BZ_PARTICIPANTS_004
**Test Case Description**: Validate participant session duration
**Expected Outcome**: Calculated session duration is reasonable

#### Test Case ID: BZ_PARTICIPANTS_005
**Test Case Description**: Validate source system tracking
**Expected Outcome**: SOURCE_SYSTEM contains valid source identifiers

#### Test Case ID: BZ_PARTICIPANTS_006 (Edge Case)
**Test Case Description**: Handle participants still in meeting (null leave time)
**Expected Outcome**: Records with null LEAVE_TIME are processed correctly

#### Test Case ID: BZ_PARTICIPANTS_007 (Edge Case)
**Test Case Description**: Handle multiple participant sessions per meeting
**Expected Outcome**: Multiple sessions for same user in same meeting are handled

#### Test Case ID: BZ_PARTICIPANTS_008 (Edge Case)
**Test Case Description**: Handle invalid join/leave time combinations
**Expected Outcome**: Invalid time combinations are flagged for review

#### Test Case ID: BZ_PARTICIPANTS_009 (Custom)
**Test Case Description**: Validate participant count per meeting
**Expected Outcome**: Participant counts align with meeting capacity limits

#### Test Case ID: BZ_PARTICIPANTS_010 (Custom)
**Test Case Description**: Validate audit trail for participant operations
**Expected Outcome**: All participant record operations are logged in audit table

---

### 4. BZ_FEATURE_USAGE Model Tests

#### Test Case ID: BZ_FEATURE_USAGE_001
**Test Case Description**: Validate usage ID uniqueness
**Expected Outcome**: All USAGE_ID values are unique and not null

#### Test Case ID: BZ_FEATURE_USAGE_002
**Test Case Description**: Validate meeting foreign key relationship
**Expected Outcome**: All MEETING_ID values reference valid meetings

#### Test Case ID: BZ_FEATURE_USAGE_003
**Test Case Description**: Validate feature name domain values
**Expected Outcome**: FEATURE_NAME contains only valid feature types

#### Test Case ID: BZ_FEATURE_USAGE_004
**Test Case Description**: Validate usage count constraints
**Expected Outcome**: USAGE_COUNT is non-negative integer

#### Test Case ID: BZ_FEATURE_USAGE_005
**Test Case Description**: Validate usage date consistency
**Expected Outcome**: USAGE_DATE aligns with meeting dates

#### Test Case ID: BZ_FEATURE_USAGE_006
**Test Case Description**: Validate source system tracking
**Expected Outcome**: SOURCE_SYSTEM contains valid source identifiers

#### Test Case ID: BZ_FEATURE_USAGE_007 (Edge Case)
**Test Case Description**: Handle zero usage count
**Expected Outcome**: Records with USAGE_COUNT = 0 are processed appropriately

#### Test Case ID: BZ_FEATURE_USAGE_008 (Edge Case)
**Test Case Description**: Handle unknown feature names
**Expected Outcome**: Unknown features are flagged but not rejected

#### Test Case ID: BZ_FEATURE_USAGE_009 (Edge Case)
**Test Case Description**: Handle extremely high usage counts
**Expected Outcome**: Unusually high usage counts are flagged for review

#### Test Case ID: BZ_FEATURE_USAGE_010 (Edge Case)
**Test Case Description**: Handle feature usage without corresponding meeting
**Expected Outcome**: Orphaned feature usage records are identified

#### Test Case ID: BZ_FEATURE_USAGE_011 (Custom)
**Test Case Description**: Validate feature usage patterns
**Expected Outcome**: Feature usage patterns align with meeting duration

#### Test Case ID: BZ_FEATURE_USAGE_012 (Custom)
**Test Case Description**: Validate audit trail for feature usage operations
**Expected Outcome**: All feature usage operations are logged in audit table

---

### 5. BZ_SUPPORT_TICKETS Model Tests

#### Test Case ID: BZ_SUPPORT_TICKETS_001
**Test Case Description**: Validate ticket ID uniqueness
**Expected Outcome**: All TICKET_ID values are unique and not null

#### Test Case ID: BZ_SUPPORT_TICKETS_002
**Test Case Description**: Validate user foreign key relationship
**Expected Outcome**: All USER_ID values reference valid users

#### Test Case ID: BZ_SUPPORT_TICKETS_003
**Test Case Description**: Validate ticket type domain values
**Expected Outcome**: TICKET_TYPE contains only valid types

#### Test Case ID: BZ_SUPPORT_TICKETS_004
**Test Case Description**: Validate resolution status domain values
**Expected Outcome**: RESOLUTION_STATUS contains only valid statuses

#### Test Case ID: BZ_SUPPORT_TICKETS_005
**Test Case Description**: Validate source system tracking
**Expected Outcome**: SOURCE_SYSTEM contains valid source identifiers

#### Test Case ID: BZ_SUPPORT_TICKETS_006 (Edge Case)
**Test Case Description**: Handle tickets without user assignment
**Expected Outcome**: Unassigned tickets are processed correctly

#### Test Case ID: BZ_SUPPORT_TICKETS_007 (Edge Case)
**Test Case Description**: Handle invalid ticket types
**Expected Outcome**: Invalid ticket types are flagged but not rejected

#### Test Case ID: BZ_SUPPORT_TICKETS_008 (Edge Case)
**Test Case Description**: Handle future open dates
**Expected Outcome**: Future OPEN_DATE values are flagged for review

#### Test Case ID: BZ_SUPPORT_TICKETS_009 (Custom)
**Test Case Description**: Validate ticket lifecycle consistency
**Expected Outcome**: Ticket status transitions follow logical progression

#### Test Case ID: BZ_SUPPORT_TICKETS_010 (Custom)
**Test Case Description**: Validate audit trail for support ticket operations
**Expected Outcome**: All support ticket operations are logged in audit table

---

### 6. BZ_BILLING_EVENTS Model Tests

#### Test Case ID: BZ_BILLING_EVENTS_001
**Test Case Description**: Validate event ID uniqueness
**Expected Outcome**: All EVENT_ID values are unique and not null

#### Test Case ID: BZ_BILLING_EVENTS_002
**Test Case Description**: Validate user foreign key relationship
**Expected Outcome**: All USER_ID values reference valid users

#### Test Case ID: BZ_BILLING_EVENTS_003
**Test Case Description**: Validate event type domain values
**Expected Outcome**: EVENT_TYPE contains only valid event types

#### Test Case ID: BZ_BILLING_EVENTS_004
**Test Case Description**: Validate amount constraints
**Expected Outcome**: AMOUNT values are properly formatted and reasonable

#### Test Case ID: BZ_BILLING_EVENTS_005
**Test Case Description**: Validate event date consistency
**Expected Outcome**: EVENT_DATE is within reasonable business date range

#### Test Case ID: BZ_BILLING_EVENTS_006
**Test Case Description**: Validate source system tracking
**Expected Outcome**: SOURCE_SYSTEM contains valid source identifiers

#### Test Case ID: BZ_BILLING_EVENTS_007 (Edge Case)
**Test Case Description**: Handle zero amount transactions
**Expected Outcome**: Zero amount events are processed appropriately

#### Test Case ID: BZ_BILLING_EVENTS_008 (Edge Case)
**Test Case Description**: Handle negative amounts (refunds)
**Expected Outcome**: Negative amounts are handled correctly for refunds

#### Test Case ID: BZ_BILLING_EVENTS_009 (Edge Case)
**Test Case Description**: Handle extremely large amounts
**Expected Outcome**: Large amounts are flagged for review

#### Test Case ID: BZ_BILLING_EVENTS_010 (Edge Case)
**Test Case Description**: Handle invalid event types
**Expected Outcome**: Invalid event types are flagged but not rejected

#### Test Case ID: BZ_BILLING_EVENTS_011 (Custom)
**Test Case Description**: Validate billing event patterns
**Expected Outcome**: Billing patterns align with user subscription types

#### Test Case ID: BZ_BILLING_EVENTS_012 (Custom)
**Test Case Description**: Validate currency and amount formatting
**Expected Outcome**: Amount values follow proper decimal formatting

#### Test Case ID: BZ_BILLING_EVENTS_013 (Custom)
**Test Case Description**: Validate audit trail for billing operations
**Expected Outcome**: All billing event operations are logged in audit table

---

### 7. BZ_LICENSES Model Tests

#### Test Case ID: BZ_LICENSES_001
**Test Case Description**: Validate license ID uniqueness
**Expected Outcome**: All LICENSE_ID values are unique and not null

#### Test Case ID: BZ_LICENSES_002
**Test Case Description**: Validate license type domain values
**Expected Outcome**: LICENSE_TYPE contains only valid license types

#### Test Case ID: BZ_LICENSES_003
**Test Case Description**: Validate user assignment relationship
**Expected Outcome**: ASSIGNED_TO_USER_ID references valid users when not null

#### Test Case ID: BZ_LICENSES_004
**Test Case Description**: Validate date range consistency
**Expected Outcome**: END_DATE is after START_DATE when both are present

#### Test Case ID: BZ_LICENSES_005
**Test Case Description**: Validate source system tracking
**Expected Outcome**: SOURCE_SYSTEM contains valid source identifiers

#### Test Case ID: BZ_LICENSES_006 (Edge Case)
**Test Case Description**: Handle unassigned licenses
**Expected Outcome**: Licenses with null ASSIGNED_TO_USER_ID are processed correctly

#### Test Case ID: BZ_LICENSES_007 (Edge Case)
**Test Case Description**: Handle perpetual licenses (null end date)
**Expected Outcome**: Licenses with null END_DATE are handled appropriately

#### Test Case ID: BZ_LICENSES_008 (Edge Case)
**Test Case Description**: Handle expired licenses
**Expected Outcome**: Licenses with past END_DATE are identified correctly

#### Test Case ID: BZ_LICENSES_009 (Custom)
**Test Case Description**: Validate license allocation limits
**Expected Outcome**: License assignments don't exceed organizational limits

#### Test Case ID: BZ_LICENSES_010 (Custom)
**Test Case Description**: Validate audit trail for license operations
**Expected Outcome**: All license operations are logged in audit table

---

### 8. BZ_DATA_AUDIT Model Tests

#### Test Case ID: BZ_DATA_AUDIT_001
**Test Case Description**: Validate audit record ID uniqueness
**Expected Outcome**: All RECORD_ID values are unique and auto-incrementing

#### Test Case ID: BZ_DATA_AUDIT_002
**Test Case Description**: Validate audit completeness
**Expected Outcome**: All Bronze layer operations generate audit records

#### Test Case ID: BZ_DATA_AUDIT_003
**Test Case Description**: Validate processing time accuracy
**Expected Outcome**: PROCESSING_TIME values are reasonable and non-negative

#### Test Case ID: BZ_DATA_AUDIT_004
**Test Case Description**: Validate status domain values
**Expected Outcome**: STATUS contains only valid values (SUCCESS, FAILED, WARNING)

#### Test Case ID: BZ_DATA_AUDIT_005 (Edge Case)
**Test Case Description**: Handle failed operations
**Expected Outcome**: Failed operations are properly logged with error details

#### Test Case ID: BZ_DATA_AUDIT_006 (Edge Case)
**Test Case Description**: Handle concurrent operations
**Expected Outcome**: Concurrent operations are logged without conflicts

#### Test Case ID: BZ_DATA_AUDIT_007 (Custom)
**Test Case Description**: Validate audit data retention
**Expected Outcome**: Audit records are retained according to policy

#### Test Case ID: BZ_DATA_AUDIT_008 (Custom)
**Test Case Description**: Validate audit performance impact
**Expected Outcome**: Audit logging doesn't significantly impact pipeline performance

---

## dbt Test Scripts

### Schema Tests (models/bronze/schema.yml)

```yaml
version: 2

sources:
  - name: raw
    description: "Raw data layer containing unprocessed data from source systems"
    tables:
      - name: users
        description: "Raw user account data from user management systems"
      - name: meetings
        description: "Raw meeting data including scheduling and basic meeting information"
      - name: participants
        description: "Raw participant data tracking meeting attendance"
      - name: feature_usage
        description: "Raw feature usage data tracking user interactions"
      - name: support_tickets
        description: "Raw support ticket data from customer service systems"
      - name: billing_events
        description: "Raw billing events data from source systems"
      - name: licenses
        description: "Raw license assignment and management data"

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
      - name: processing_time
        description: "Time taken to process the operation in seconds"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: status
        description: "Status of the operation (SUCCESS, FAILED, WARNING)"
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING', 'STARTED']
        
  - name: bz_users
    description: "Bronze layer table storing user profile and subscription information"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "Display name of the user (PII)"
        tests:
          - not_null
      - name: email
        description: "Email address of the user (PII)"
        tests:
          - not_null
          - unique
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
          - accepted_values:
              values: ['user_management', 'ldap', 'sso_provider']

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
              condition: "duration_minutes is not null"
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['zoom_api', 'meeting_scheduler', 'calendar_integration']

  - name: bz_participants
    description: "Bronze layer table tracking meeting participants and their session details"
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
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: load_timestamp
        description: "Timestamp when record was loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null
          - accepted_values:
              values: ['zoom_api', 'meeting_logs', 'attendance_tracker']

  - name: bz_feature_usage
    description: "Bronze layer table recording usage of platform features during meetings"
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
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        description: "Name of the feature being tracked"
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
          - accepted_values:
              values: ['zoom_client', 'web_portal', 'mobile_app']

  - name: bz_support_tickets
    description: "Bronze layer table managing customer support requests and resolution tracking"
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
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['technical', 'billing', 'account', 'feature_request']
      - name: resolution_status
        description: "Current status of ticket resolution"
        tests:
          - not_null
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed']
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
          - accepted_values:
              values: ['zendesk', 'salesforce', 'support_portal']

  - name: bz_billing_events
    description: "Bronze layer table tracking financial transactions and billing activities"
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
        description: "Monetary amount for the billing event"
        tests:
          - not_null
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
          - accepted_values:
              values: ['billing_system', 'payment_gateway', 'subscription_service']

  - name: bz_licenses
    description: "Bronze layer table managing license assignments and entitlements"
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
              config:
                where: "assigned_to_user_id is not null"
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
          - accepted_values:
              values: ['license_management', 'admin_portal', 'billing_system']
```

### Custom SQL Tests

#### 1. Email Format Validation Test
**File**: `tests/test_email_format.sql`
```sql
-- Test to validate email format in bz_users table
SELECT 
    user_id,
    email
FROM {{ ref('bz_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```

#### 2. Meeting Duration Consistency Test
**File**: `tests/test_meeting_duration_consistency.sql`
```sql
-- Test to validate meeting duration calculation consistency
SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) AS calculated_duration
FROM {{ ref('bz_meetings') }}
WHERE end_time IS NOT NULL 
  AND start_time IS NOT NULL
  AND duration_minutes IS NOT NULL
  AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### 3. Participant Session Validation Test
**File**: `tests/test_participant_session_validation.sql`
```sql
-- Test to validate participant join/leave time consistency
SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time
FROM {{ ref('bz_participants') }}
WHERE join_time IS NOT NULL 
  AND leave_time IS NOT NULL
  AND leave_time <= join_time
```

#### 4. Feature Usage Date Alignment Test
**File**: `tests/test_feature_usage_date_alignment.sql`
```sql
-- Test to validate feature usage dates align with meeting dates
SELECT 
    fu.usage_id,
    fu.meeting_id,
    fu.usage_date,
    m.start_time::DATE as meeting_date
FROM {{ ref('bz_feature_usage') }} fu
JOIN {{ ref('bz_meetings') }} m ON fu.meeting_id = m.meeting_id
WHERE fu.usage_date != m.start_time::DATE
```

#### 5. Billing Amount Validation Test
**File**: `tests/test_billing_amount_validation.sql`
```sql
-- Test to validate billing amounts are within reasonable ranges
SELECT 
    event_id,
    user_id,
    event_type,
    amount
FROM {{ ref('bz_billing_events') }}
WHERE (event_type IN ('subscription', 'usage') AND amount < 0)
   OR (event_type = 'refund' AND amount > 0)
   OR ABS(amount) > 10000  -- Flag amounts over $10,000
```

#### 6. License Date Range Validation Test
**File**: `tests/test_license_date_range_validation.sql`
```sql
-- Test to validate license date ranges are logical
SELECT 
    license_id,
    license_type,
    start_date,
    end_date
FROM {{ ref('bz_licenses') }}
WHERE end_date IS NOT NULL 
  AND end_date <= start_date
```

#### 7. Audit Trail Completeness Test
**File**: `tests/test_audit_trail_completeness.sql`
```sql
-- Test to ensure all Bronze layer operations are audited
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
audited_tables AS (
    SELECT DISTINCT source_table
    FROM {{ ref('bz_data_audit') }}
    WHERE status = 'SUCCESS'
)
SELECT table_name
FROM expected_tables
WHERE table_name NOT IN (SELECT source_table FROM audited_tables)
```

#### 8. Data Freshness Validation Test
**File**: `tests/test_data_freshness_validation.sql`
```sql
-- Test to validate data freshness across all Bronze tables
WITH freshness_check AS (
    SELECT 'bz_users' as table_name, MAX(load_timestamp) as last_load FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT 'bz_meetings' as table_name, MAX(load_timestamp) as last_load FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT 'bz_participants' as table_name, MAX(load_timestamp) as last_load FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT 'bz_feature_usage' as table_name, MAX(load_timestamp) as last_load FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT 'bz_support_tickets' as table_name, MAX(load_timestamp) as last_load FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT 'bz_billing_events' as table_name, MAX(load_timestamp) as last_load FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT 'bz_licenses' as table_name, MAX(load_timestamp) as last_load FROM {{ ref('bz_licenses') }}
)
SELECT 
    table_name,
    last_load,
    DATEDIFF('hour', last_load, CURRENT_TIMESTAMP()) as hours_since_last_load
FROM freshness_check
WHERE DATEDIFF('hour', last_load, CURRENT_TIMESTAMP()) > 24  -- Flag tables not updated in 24 hours
```

### Parameterized Tests

#### 1. Generic Timestamp Validation Macro
**File**: `macros/test_timestamp_validation.sql`
```sql
{% macro test_timestamp_validation(model, timestamp_column) %}
    SELECT 
        *
    FROM {{ model }}
    WHERE {{ timestamp_column }} IS NULL
       OR {{ timestamp_column }} > CURRENT_TIMESTAMP()
       OR {{ timestamp_column }} < '2020-01-01'::TIMESTAMP
{% endmacro %}
```

#### 2. Generic Foreign Key Validation Macro
**File**: `macros/test_foreign_key_validation.sql`
```sql
{% macro test_foreign_key_validation(model, column_name, parent_model, parent_column) %}
    SELECT 
        {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
      AND {{ column_name }} NOT IN (
          SELECT {{ parent_column }}
          FROM {{ parent_model }}
          WHERE {{ parent_column }} IS NOT NULL
      )
{% endmacro %}
```

## Test Execution Strategy

### 1. Test Execution Order
1. **Schema Tests**: Run basic schema validation tests first
2. **Custom SQL Tests**: Execute custom business logic tests
3. **Parameterized Tests**: Run reusable validation tests
4. **Integration Tests**: Validate cross-table relationships
5. **Performance Tests**: Validate query performance and resource usage

### 2. Test Environment Configuration
```yaml
# profiles.yml configuration for testing
zoom_bronze_pipeline:
  target: test
  outputs:
    test:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      private_key_path: "{{ env_var('SNOWFLAKE_PRIVATE_KEY_PATH') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE') }}"
      database: DB_POC_ZOOM_TEST
      warehouse: WH_POC_ZOOM_TEST_XSMALL
      schema: BRONZE_TEST
      threads: 4
      keepalives_idle: 240
```

### 3. Continuous Integration Setup
```yaml
# .github/workflows/dbt_tests.yml
name: dbt Tests
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.8'
      - name: Install dbt
        run: pip install dbt-snowflake
      - name: Run dbt tests
        run: |
          dbt deps
          dbt seed
          dbt run
          dbt test
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PRIVATE_KEY: ${{ secrets.SNOWFLAKE_PRIVATE_KEY }}
          SNOWFLAKE_ROLE: ${{ secrets.SNOWFLAKE_ROLE }}
```

## Test Results Tracking

### 1. Test Results Schema
```sql
-- Test results tracking table
CREATE TABLE IF NOT EXISTS BRONZE.DBT_TEST_RESULTS (
    test_execution_id VARCHAR(16777216),
    test_name VARCHAR(16777216),
    model_name VARCHAR(16777216),
    test_type VARCHAR(16777216),
    status VARCHAR(16777216),
    execution_time NUMBER(10,3),
    error_message VARCHAR(16777216),
    executed_at TIMESTAMP_NTZ(9),
    executed_by VARCHAR(16777216)
);
```

### 2. Test Monitoring Dashboard Queries
```sql
-- Test success rate by model
SELECT 
    model_name,
    COUNT(*) as total_tests,
    SUM(CASE WHEN status = 'PASS' THEN 1 ELSE 0 END) as passed_tests,
    ROUND(passed_tests / total_tests * 100, 2) as success_rate
FROM BRONZE.DBT_TEST_RESULTS
WHERE executed_at >= CURRENT_DATE - 7
GROUP BY model_name
ORDER BY success_rate DESC;

-- Test execution trends
SELECT 
    DATE(executed_at) as test_date,
    COUNT(*) as total_tests,
    SUM(CASE WHEN status = 'PASS' THEN 1 ELSE 0 END) as passed_tests,
    AVG(execution_time) as avg_execution_time
FROM BRONZE.DBT_TEST_RESULTS
WHERE executed_at >= CURRENT_DATE - 30
GROUP BY DATE(executed_at)
ORDER BY test_date DESC;
```

## Summary

This comprehensive unit testing framework for the Zoom Bronze Layer dbt models provides:

- **86 Total Test Cases** covering all Bronze layer models
- **Schema-based Tests** for data type and constraint validation
- **Custom SQL Tests** for business logic validation
- **Parameterized Tests** for reusable validation patterns
- **Edge Case Handling** for robust data quality assurance
- **Audit Trail Validation** ensuring complete operation tracking
- **Performance Monitoring** for pipeline optimization
- **CI/CD Integration** for automated testing workflows

The testing framework ensures data reliability, validates business rules, handles edge cases, and provides comprehensive monitoring capabilities for the Bronze layer pipeline in Snowflake.
