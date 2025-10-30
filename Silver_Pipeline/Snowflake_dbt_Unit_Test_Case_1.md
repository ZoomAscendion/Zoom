_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Silver Layer models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Platform Analytics Silver Layer models running in Snowflake. The tests validate key data transformations, business rules, edge cases, and error handling to ensure reliable and high-quality data processing.

**Scope**: All Silver Layer models (SI_USERS, SI_MEETINGS, SI_PARTICIPANTS, SI_FEATURE_USAGE, SI_SUPPORT_TICKETS, SI_BILLING_EVENTS, SI_LICENSES, SI_WEBINARS)

**Testing Framework**: dbt with Snowflake-compatible SQL

**Test Categories**:
- Data Quality Tests
- Business Rule Validation
- Referential Integrity Tests
- Edge Case Handling
- Performance and Error Handling

---

## Test Case List

### 1. SI_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate USER_ID uniqueness and non-null constraint | All USER_ID values are unique and not null |
| TC_USR_002 | Validate email format using regex pattern | All EMAIL values follow valid email format |
| TC_USR_003 | Validate PLAN_TYPE enumeration values | All PLAN_TYPE values are in (Free, Basic, Pro, Enterprise) |
| TC_USR_004 | Validate ACCOUNT_STATUS enumeration values | All ACCOUNT_STATUS values are in (Active, Inactive, Suspended) |
| TC_USR_005 | Validate REGISTRATION_DATE logic | No future dates, reasonable date range |
| TC_USR_006 | Validate DATA_QUALITY_SCORE range | All scores between 0.00 and 1.00 |
| TC_USR_007 | Test user name standardization | USER_NAME properly formatted with INITCAP |
| TC_USR_008 | Test email standardization | EMAIL converted to lowercase |
| TC_USR_009 | Test account status derivation logic | ACCOUNT_STATUS correctly derived from user activity |
| TC_USR_010 | Test edge case: null company field | Handles null COMPANY values gracefully |

### 2. SI_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate MEETING_ID uniqueness and non-null constraint | All MEETING_ID values are unique and not null |
| TC_MTG_002 | Validate HOST_ID referential integrity | All HOST_ID values exist in SI_USERS |
| TC_MTG_003 | Validate meeting time logic (END_TIME >= START_TIME) | All meetings have valid time relationships |
| TC_MTG_004 | Validate DURATION_MINUTES calculation | Duration matches calculated time difference |
| TC_MTG_005 | Validate DURATION_MINUTES range (0-1440) | All durations within valid range |
| TC_MTG_006 | Validate MEETING_TYPE enumeration | All values in (Scheduled, Instant, Webinar, Personal) |
| TC_MTG_007 | Validate MEETING_STATUS enumeration | All values in (Scheduled, In Progress, Completed, Cancelled) |
| TC_MTG_008 | Validate PARTICIPANT_COUNT accuracy | Count matches actual participants in SI_PARTICIPANTS |
| TC_MTG_009 | Test meeting status derivation logic | Status correctly derived from timestamps |
| TC_MTG_010 | Test edge case: zero duration meetings | Handles very short meetings appropriately |

### 3. SI_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique |
| TC_PRT_002 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS |
| TC_PRT_003 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS |
| TC_PRT_004 | Validate attendance time logic (LEAVE_TIME >= JOIN_TIME) | All participants have valid time relationships |
| TC_PRT_005 | Validate ATTENDANCE_DURATION calculation | Duration matches calculated time difference |
| TC_PRT_006 | Validate PARTICIPANT_ROLE enumeration | All values in (Host, Co-host, Participant, Observer) |
| TC_PRT_007 | Validate CONNECTION_QUALITY enumeration | All values in (Excellent, Good, Fair, Poor) |
| TC_PRT_008 | Test role assignment logic | Roles correctly assigned based on meeting context |
| TC_PRT_009 | Test connection quality derivation | Quality correctly derived from connection metrics |
| TC_PRT_010 | Test edge case: null leave time (ongoing participation) | Handles ongoing participation gracefully |

### 4. SI_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate USAGE_ID uniqueness | All USAGE_ID values are unique |
| TC_FTR_002 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS |
| TC_FTR_003 | Validate USAGE_COUNT non-negative constraint | All USAGE_COUNT values >= 0 |
| TC_FTR_004 | Validate USAGE_DURATION non-negative constraint | All USAGE_DURATION values >= 0 |
| TC_FTR_005 | Validate FEATURE_CATEGORY enumeration | All values in (Audio, Video, Collaboration, Security) |
| TC_FTR_006 | Validate USAGE_DATE not future date | No future dates in USAGE_DATE |
| TC_FTR_007 | Test feature name standardization | FEATURE_NAME properly formatted |
| TC_FTR_008 | Test feature categorization logic | Categories correctly assigned based on feature names |
| TC_FTR_009 | Test usage duration calculation | Duration correctly calculated from usage patterns |
| TC_FTR_010 | Test edge case: zero usage count | Handles zero usage appropriately |

### 5. SI_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate TICKET_ID uniqueness | All TICKET_ID values are unique |
| TC_TKT_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS |
| TC_TKT_003 | Validate TICKET_TYPE enumeration | All values in (Technical, Billing, Feature Request, Bug Report) |
| TC_TKT_004 | Validate PRIORITY_LEVEL enumeration | All values in (Low, Medium, High, Critical) |
| TC_TKT_005 | Validate RESOLUTION_STATUS enumeration | All values in (Open, In Progress, Resolved, Closed) |
| TC_TKT_006 | Validate date logic (CLOSE_DATE >= OPEN_DATE) | All tickets have valid date relationships |
| TC_TKT_007 | Validate OPEN_DATE not future date | No future dates in OPEN_DATE |
| TC_TKT_008 | Validate RESOLUTION_TIME_HOURS calculation | Resolution time correctly calculated |
| TC_TKT_009 | Test priority level assignment logic | Priority correctly derived from ticket characteristics |
| TC_TKT_010 | Test SLA compliance validation | Resolution times meet SLA requirements |

### 6. SI_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate EVENT_ID uniqueness | All EVENT_ID values are unique |
| TC_BIL_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS |
| TC_BIL_003 | Validate EVENT_TYPE enumeration | All values in (Subscription, Upgrade, Downgrade, Refund) |
| TC_BIL_004 | Validate TRANSACTION_AMOUNT logic | Positive amounts except for refunds |
| TC_BIL_005 | Validate CURRENCY_CODE format | All codes are valid 3-character ISO codes |
| TC_BIL_006 | Validate TRANSACTION_STATUS enumeration | All values in (Completed, Pending, Failed, Refunded) |
| TC_BIL_007 | Validate INVOICE_NUMBER uniqueness | All INVOICE_NUMBER values are unique when not null |
| TC_BIL_008 | Validate TRANSACTION_DATE not future date | No future dates in TRANSACTION_DATE |
| TC_BIL_009 | Test payment method derivation | Payment methods correctly derived from metadata |
| TC_BIL_010 | Test transaction status logic | Status correctly derived from event processing |

### 7. SI_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate LICENSE_ID uniqueness | All LICENSE_ID values are unique |
| TC_LIC_002 | Validate ASSIGNED_TO_USER_ID referential integrity | All assigned user IDs exist in SI_USERS |
| TC_LIC_003 | Validate LICENSE_TYPE enumeration | All values in (Basic, Pro, Enterprise, Add-on) |
| TC_LIC_004 | Validate LICENSE_STATUS enumeration | All values in (Active, Expired, Suspended) |
| TC_LIC_005 | Validate date logic (END_DATE >= START_DATE) | All licenses have valid date relationships |
| TC_LIC_006 | Validate LICENSE_COST non-negative constraint | All LICENSE_COST values >= 0 |
| TC_LIC_007 | Validate UTILIZATION_PERCENTAGE range (0-100) | All utilization values within valid range |
| TC_LIC_008 | Test license status derivation | Status correctly derived from current date vs dates |
| TC_LIC_009 | Test cost calculation logic | Costs correctly derived from license type |
| TC_LIC_010 | Test utilization calculation | Utilization correctly calculated from usage patterns |

### 8. SI_WEBINARS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_WBN_001 | Validate WEBINAR_ID uniqueness | All WEBINAR_ID values are unique |
| TC_WBN_002 | Validate HOST_ID referential integrity | All HOST_ID values exist in SI_USERS |
| TC_WBN_003 | Validate webinar time logic (END_TIME >= START_TIME) | All webinars have valid time relationships |
| TC_WBN_004 | Validate DURATION_MINUTES calculation | Duration matches calculated time difference |
| TC_WBN_005 | Validate attendance logic (ATTENDEES <= REGISTRANTS) | Attendees cannot exceed registrants |
| TC_WBN_006 | Validate ATTENDANCE_RATE calculation | Rate correctly calculated as (ATTENDEES/REGISTRANTS)*100 |
| TC_WBN_007 | Validate REGISTRANTS non-negative constraint | All REGISTRANTS values >= 0 |
| TC_WBN_008 | Validate ATTENDEES non-negative constraint | All ATTENDEES values >= 0 |
| TC_WBN_009 | Test attendance rate edge cases | Handles zero registrants appropriately |
| TC_WBN_010 | Test webinar topic standardization | Topics properly cleaned and formatted |

### 9. Cross-Table Integration Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INT_001 | Validate user activity consistency | Users in meetings/tickets exist in users table |
| TC_INT_002 | Validate meeting participant count accuracy | Meeting counts match participant records |
| TC_INT_003 | Validate billing-license correlation | Billing events correlate with license assignments |
| TC_INT_004 | Validate feature usage attribution | Feature usage properly attributed to valid meetings |
| TC_INT_005 | Validate host consistency across tables | Host information consistent between meetings and users |

### 10. Data Quality and Metadata Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_DQ_001 | Validate DATA_QUALITY_SCORE range across all tables | All scores between 0.00 and 1.00 |
| TC_DQ_002 | Validate LOAD_TIMESTAMP not null and reasonable | All load timestamps valid and not future |
| TC_DQ_003 | Validate SOURCE_SYSTEM not null | All source system values populated |
| TC_DQ_004 | Validate metadata consistency | Load and update dates consistent |
| TC_DQ_005 | Test data quality score calculation | Scores correctly calculated based on completeness |

---

## dbt Test Scripts

### YAML-based Schema Tests

#### models/silver/schema.yml

```yaml
version: 2

models:
  # SI_USERS Tests
  - name: si_users
    description: "Silver layer user data with data quality validations"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - unique
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1
              where: "email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'"
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: account_status
        description: "Current account status"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: registration_date
        description: "User registration date"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "<= current_date()"
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0.00
              max_value: 1.00

  # SI_MEETINGS Tests
  - name: si_meetings
    description: "Silver layer meeting data with validations"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: meeting_type
        description: "Type of meeting"
        tests:
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
      - name: meeting_status
        description: "Current meeting status"
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0.00
              max_value: 1.00

  # SI_PARTICIPANTS Tests
  - name: si_participants
    description: "Silver layer participant data with validations"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: participant_role
        description: "Role in meeting"
        tests:
          - accepted_values:
              values: ['Host', 'Co-host', 'Participant', 'Observer']
      - name: connection_quality
        description: "Connection quality during meeting"
        tests:
          - accepted_values:
              values: ['Excellent', 'Good', 'Fair', 'Poor']
      - name: attendance_duration
        description: "Time spent in meeting"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440

  # SI_FEATURE_USAGE Tests
  - name: si_feature_usage
    description: "Silver layer feature usage data with validations"
    columns:
      - name: usage_id
        description: "Unique identifier for each usage record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: feature_category
        description: "Category of feature"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 999999
      - name: usage_duration
        description: "Duration feature was active"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440

  # SI_SUPPORT_TICKETS Tests
  - name: si_support_tickets
    description: "Silver layer support ticket data with validations"
    columns:
      - name: ticket_id
        description: "Unique identifier for each ticket"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "User who created the ticket"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: priority_level
        description: "Priority level of ticket"
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: resolution_status
        description: "Current resolution status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
      - name: resolution_time_hours
        description: "Time to resolve in hours"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 8760  # Max 1 year

  # SI_BILLING_EVENTS Tests
  - name: si_billing_events
    description: "Silver layer billing event data with validations"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "User associated with billing event"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: event_type
        description: "Type of billing event"
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
      - name: transaction_status
        description: "Status of transaction"
        tests:
          - accepted_values:
              values: ['Completed', 'Pending', 'Failed', 'Refunded']
      - name: currency_code
        description: "ISO currency code"
        tests:
          - dbt_utils.expression_is_true:
              expression: "length(currency_code) = 3"
      - name: invoice_number
        description: "Unique invoice identifier"
        tests:
          - unique:
              where: "invoice_number is not null"

  # SI_LICENSES Tests
  - name: si_licenses
    description: "Silver layer license data with validations"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              where: "assigned_to_user_id is not null"
      - name: license_type
        description: "Type of license"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-on']
      - name: license_status
        description: "Current license status"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: license_cost
        description: "Cost of license"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 99999.99
      - name: utilization_percentage
        description: "License utilization percentage"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0.00
              max_value: 100.00

  # SI_WEBINARS Tests
  - name: si_webinars
    description: "Silver layer webinar data with validations"
    columns:
      - name: webinar_id
        description: "Unique identifier for each webinar"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Webinar host user ID"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Webinar duration in minutes"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440
      - name: registrants
        description: "Number of registrants"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 999999
      - name: attendees
        description: "Number of attendees"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 999999
      - name: attendance_rate
        description: "Attendance rate percentage"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0.00
              max_value: 100.00
```

### Custom SQL-based dbt Tests

#### tests/business_rules/test_meeting_time_logic.sql

```sql
-- Test that meeting end time is always >= start time
SELECT 
    meeting_id,
    start_time,
    end_time,
    'End time before start time' as error_message
FROM {{ ref('si_meetings') }}
WHERE end_time < start_time
```

#### tests/business_rules/test_participant_time_logic.sql

```sql
-- Test that participant leave time is always >= join time
SELECT 
    participant_id,
    join_time,
    leave_time,
    'Leave time before join time' as error_message
FROM {{ ref('si_participants') }}
WHERE leave_time < join_time
```

#### tests/business_rules/test_webinar_attendance_logic.sql

```sql
-- Test that webinar attendees never exceed registrants
SELECT 
    webinar_id,
    registrants,
    attendees,
    'Attendees exceed registrants' as error_message
FROM {{ ref('si_webinars') }}
WHERE attendees > registrants
```

#### tests/business_rules/test_billing_amount_logic.sql

```sql
-- Test billing amount logic based on event type
SELECT 
    event_id,
    event_type,
    transaction_amount,
    'Invalid amount for event type' as error_message
FROM {{ ref('si_billing_events') }}
WHERE 
    (event_type != 'Refund' AND transaction_amount <= 0)
    OR (event_type = 'Refund' AND transaction_amount >= 0)
```

#### tests/business_rules/test_license_date_logic.sql

```sql
-- Test that license end date is always >= start date
SELECT 
    license_id,
    start_date,
    end_date,
    'End date before start date' as error_message
FROM {{ ref('si_licenses') }}
WHERE end_date < start_date
```

#### tests/data_quality/test_email_format.sql

```sql
-- Test email format validation
SELECT 
    user_id,
    email,
    'Invalid email format' as error_message
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### tests/data_quality/test_future_dates.sql

```sql
-- Test for future dates where not allowed
SELECT 
    'si_users' as table_name,
    user_id as record_id,
    registration_date as date_field,
    'Future registration date' as error_message
FROM {{ ref('si_users') }}
WHERE registration_date > CURRENT_DATE()

UNION ALL

SELECT 
    'si_support_tickets',
    ticket_id,
    open_date,
    'Future open date'
FROM {{ ref('si_support_tickets') }}
WHERE open_date > CURRENT_DATE()

UNION ALL

SELECT 
    'si_billing_events',
    event_id,
    transaction_date,
    'Future transaction date'
FROM {{ ref('si_billing_events') }}
WHERE transaction_date > CURRENT_DATE()
```

#### tests/referential_integrity/test_orphaned_records.sql

```sql
-- Test for orphaned records across tables
SELECT 
    'si_meetings' as table_name,
    meeting_id as record_id,
    host_id as foreign_key,
    'Orphaned meeting host' as error_message
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL AND m.host_id IS NOT NULL

UNION ALL

SELECT 
    'si_participants',
    participant_id,
    meeting_id,
    'Orphaned participant meeting'
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL

UNION ALL

SELECT 
    'si_feature_usage',
    usage_id,
    meeting_id,
    'Orphaned feature usage meeting'
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
```

#### tests/cross_table/test_meeting_participant_count.sql

```sql
-- Test meeting participant count accuracy
WITH meeting_counts AS (
    SELECT 
        m.meeting_id,
        m.participant_count as reported_count,
        COUNT(p.participant_id) as actual_count
    FROM {{ ref('si_meetings') }} m
    LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id
    GROUP BY m.meeting_id, m.participant_count
)
SELECT 
    meeting_id,
    reported_count,
    actual_count,
    'Participant count mismatch' as error_message
FROM meeting_counts
WHERE reported_count != actual_count
```

#### tests/performance/test_data_quality_scores.sql

```sql
-- Test data quality score calculations and thresholds
SELECT 
    'si_users' as table_name,
    COUNT(*) as total_records,
    AVG(data_quality_score) as avg_quality_score,
    COUNT(CASE WHEN data_quality_score < 0.8 THEN 1 END) as low_quality_records
FROM {{ ref('si_users') }}
HAVING AVG(data_quality_score) < 0.9  -- Alert if average quality below 90%

UNION ALL

SELECT 
    'si_meetings',
    COUNT(*),
    AVG(data_quality_score),
    COUNT(CASE WHEN data_quality_score < 0.8 THEN 1 END)
FROM {{ ref('si_meetings') }}
HAVING AVG(data_quality_score) < 0.9

UNION ALL

SELECT 
    'si_participants',
    COUNT(*),
    AVG(data_quality_score),
    COUNT(CASE WHEN data_quality_score < 0.8 THEN 1 END)
FROM {{ ref('si_participants') }}
HAVING AVG(data_quality_score) < 0.9
```

#### tests/sla/test_support_ticket_sla.sql

```sql
-- Test SLA compliance for support tickets
SELECT 
    ticket_id,
    priority_level,
    resolution_time_hours,
    CASE 
        WHEN priority_level = 'Critical' THEN 4
        WHEN priority_level = 'High' THEN 24
        WHEN priority_level = 'Medium' THEN 72
        WHEN priority_level = 'Low' THEN 168
    END as sla_hours,
    'SLA violation' as error_message
FROM {{ ref('si_support_tickets') }}
WHERE resolution_status = 'Resolved'
AND (
    (priority_level = 'Critical' AND resolution_time_hours > 4)
    OR (priority_level = 'High' AND resolution_time_hours > 24)
    OR (priority_level = 'Medium' AND resolution_time_hours > 72)
    OR (priority_level = 'Low' AND resolution_time_hours > 168)
)
```

### Parameterized Tests

#### macros/test_data_quality_threshold.sql

```sql
{% macro test_data_quality_threshold(model, column_name, threshold=0.8) %}

SELECT 
    '{{ model }}' as model_name,
    '{{ column_name }}' as column_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN {{ column_name }} < {{ threshold }} THEN 1 END) as below_threshold,
    ROUND(COUNT(CASE WHEN {{ column_name }} < {{ threshold }} THEN 1 END)::FLOAT / COUNT(*) * 100, 2) as below_threshold_pct
FROM {{ ref(model) }}
HAVING COUNT(CASE WHEN {{ column_name }} < {{ threshold }} THEN 1 END) > 0

{% endmacro %}
```

#### macros/test_enum_values.sql

```sql
{% macro test_enum_values(model, column_name, valid_values) %}

SELECT 
    {{ column_name }},
    COUNT(*) as invalid_count,
    'Invalid enum value' as error_message
FROM {{ ref(model) }}
WHERE {{ column_name }} NOT IN ({{ valid_values | join(', ') }})
GROUP BY {{ column_name }}

{% endmacro %}
```

### Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --models si_users

# Run specific test types
dbt test --models tag:data_quality
dbt test --models tag:business_rules
dbt test --models tag:referential_integrity

# Run tests with specific configurations
dbt test --vars '{"test_threshold": 0.9}'

# Generate test documentation
dbt docs generate
dbt docs serve
```

### Test Results Monitoring

#### models/monitoring/test_results_summary.sql

```sql
-- Summary of test results for monitoring dashboard
WITH test_results AS (
    SELECT 
        test_name,
        model_name,
        status,
        execution_time,
        failures,
        run_started_at
    FROM {{ ref('dbt_test_results') }}  -- Assuming test results are captured
    WHERE DATE(run_started_at) = CURRENT_DATE()
)
SELECT 
    model_name,
    COUNT(*) as total_tests,
    SUM(CASE WHEN status = 'pass' THEN 1 ELSE 0 END) as passed_tests,
    SUM(CASE WHEN status = 'fail' THEN 1 ELSE 0 END) as failed_tests,
    ROUND(SUM(CASE WHEN status = 'pass' THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100, 2) as pass_rate,
    MAX(run_started_at) as last_run
FROM test_results
GROUP BY model_name
ORDER BY pass_rate ASC, failed_tests DESC
```

---

## Test Implementation Guidelines

### 1. Test Organization
- **Schema Tests**: Use for basic constraints (unique, not_null, relationships, accepted_values)
- **Custom SQL Tests**: Use for complex business logic and cross-table validations
- **Parameterized Tests**: Use for reusable test patterns across multiple models

### 2. Test Execution Strategy
- **Development**: Run tests after each model change
- **CI/CD**: Include all tests in deployment pipeline
- **Production**: Schedule regular test runs (daily/hourly)
- **Monitoring**: Set up alerts for test failures

### 3. Performance Considerations
- **Incremental Testing**: Test only changed data when possible
- **Sampling**: Use data sampling for large datasets in development
- **Parallel Execution**: Leverage dbt's parallel test execution
- **Resource Management**: Configure appropriate warehouse sizes

### 4. Error Handling
- **Graceful Failures**: Tests should not break the pipeline
- **Detailed Logging**: Capture specific error details for debugging
- **Retry Logic**: Implement retry for transient failures
- **Escalation**: Define escalation paths for critical test failures

### 5. Maintenance
- **Regular Review**: Review and update tests as business rules change
- **Performance Monitoring**: Monitor test execution times
- **Coverage Analysis**: Ensure comprehensive test coverage
- **Documentation**: Keep test documentation up to date

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Silver Layer models in Snowflake. The combination of schema tests, custom SQL tests, and parameterized tests provides robust validation of data transformations, business rules, and data quality standards.

**Key Benefits**:
- **Early Detection**: Catch data quality issues before they impact downstream processes
- **Business Rule Compliance**: Ensure all transformations follow defined business logic
- **Data Integrity**: Maintain referential integrity across all Silver layer tables
- **Performance Monitoring**: Track data quality trends and pipeline performance
- **Automated Validation**: Reduce manual testing effort through automation

**Next Steps**:
1. Implement tests in dbt project structure
2. Configure test execution in CI/CD pipeline
3. Set up monitoring and alerting for test results
4. Establish regular test maintenance schedule
5. Train team on test interpretation and troubleshooting

This testing framework provides a solid foundation for maintaining high-quality data in the Silver layer and ensuring reliable analytics for the Zoom Platform Analytics System.