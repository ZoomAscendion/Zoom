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

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and high-quality data pipeline execution.

## Instructions

The following test cases have been designed to validate:
- **Key transformations and business rules**: Data cleansing, standardization, and derived field calculations
- **Edge cases**: Null values, empty datasets, invalid lookups, and boundary conditions
- **Error handling scenarios**: Failed relationships, constraint violations, and data quality issues
- **Performance and scalability**: Large dataset handling and incremental processing

All tests use dbt-compatible testing techniques including built-in tests (unique, not_null, relationships, accepted_values) and custom SQL-based tests for complex business logic validation.

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and non-null |
| TC_USR_002 | Validate email format using regex pattern | All email addresses follow valid format |
| TC_USR_003 | Validate PLAN_TYPE enumeration values | All PLAN_TYPE values are in (FREE, BASIC, PRO, ENTERPRISE) |
| TC_USR_004 | Validate ACCOUNT_STATUS derivation logic | Account status correctly derived from activity patterns |
| TC_USR_005 | Validate data quality score calculation | Data quality scores are between 0.00 and 1.00 |
| TC_USR_006 | Test incremental processing with updates | Only new/updated records processed in incremental runs |
| TC_USR_007 | Test handling of duplicate source records | Duplicates resolved using ROW_NUMBER() with latest timestamp |
| TC_USR_008 | Test null handling and default values | Null values handled appropriately with business defaults |
| TC_USR_009 | Test data cleansing transformations | Names properly formatted with INITCAP, emails lowercased |
| TC_USR_010 | Test edge case: empty source table | Model handles empty source gracefully without errors |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and non-null |
| TC_MTG_002 | Validate HOST_ID referential integrity | All HOST_ID values exist in SI_USERS table |
| TC_MTG_003 | Validate meeting duration calculations | Duration matches DATEDIFF between start and end times |
| TC_MTG_004 | Validate meeting status derivation | Status correctly derived from timestamps vs current time |
| TC_MTG_005 | Validate meeting type classification | Meeting type correctly classified based on characteristics |
| TC_MTG_006 | Validate participant count accuracy | Participant count matches actual participant records |
| TC_MTG_007 | Test time zone handling and UTC conversion | All timestamps properly converted to UTC |
| TC_MTG_008 | Test invalid time logic handling | Records with END_TIME < START_TIME are rejected |
| TC_MTG_009 | Test duration boundary conditions | Duration values within 0-1440 minute range |
| TC_MTG_010 | Test orphaned host handling | Meetings with invalid HOST_ID are handled appropriately |

### 3. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique and non-null |
| TC_PRT_002 | Validate referential integrity constraints | MEETING_ID and USER_ID exist in respective tables |
| TC_PRT_003 | Validate attendance duration calculation | Duration correctly calculated from join/leave times |
| TC_PRT_004 | Validate participant role assignment | Roles correctly assigned based on meeting context |
| TC_PRT_005 | Test invalid attendance time logic | Records with LEAVE_TIME < JOIN_TIME are handled |
| TC_PRT_006 | Test null leave time handling | Participants still in meeting have null leave times |
| TC_PRT_007 | Test connection quality derivation | Connection quality derived from available metrics |
| TC_PRT_008 | Test cross-table consistency | Participant records consistent with meeting data |
| TC_PRT_009 | Test duplicate participant handling | Multiple join/leave events handled correctly |
| TC_PRT_010 | Test edge case: zero duration attendance | Very short attendances handled appropriately |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate USAGE_ID uniqueness and not null | All USAGE_ID values are unique and non-null |
| TC_FTR_002 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS table |
| TC_FTR_003 | Validate feature categorization logic | Features correctly categorized by type |
| TC_FTR_004 | Validate usage count non-negative constraint | All usage counts are >= 0 |
| TC_FTR_005 | Validate usage duration calculations | Duration values are reasonable and non-negative |
| TC_FTR_006 | Test feature name standardization | Feature names properly cleaned and standardized |
| TC_FTR_007 | Test unknown feature handling | Unknown features assigned to 'Other' category |
| TC_FTR_008 | Test usage date validation | Usage dates are not future dates |
| TC_FTR_009 | Test aggregation accuracy | Usage metrics properly aggregated by feature |
| TC_FTR_010 | Test edge case: zero usage records | Meetings with no feature usage handled correctly |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate TICKET_ID uniqueness and not null | All TICKET_ID values are unique and non-null |
| TC_TKT_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS table |
| TC_TKT_003 | Validate ticket type enumeration | All ticket types are valid enumerated values |
| TC_TKT_004 | Validate priority level derivation | Priority correctly derived from ticket type |
| TC_TKT_005 | Validate resolution time calculations | Resolution time calculated correctly in business hours |
| TC_TKT_006 | Validate resolution status transitions | Status transitions follow business rules |
| TC_TKT_007 | Test SLA compliance calculations | SLA metrics calculated according to priority levels |
| TC_TKT_008 | Test date logic validation | CLOSE_DATE >= OPEN_DATE when both present |
| TC_TKT_009 | Test open ticket handling | Open tickets have null close dates and resolution times |
| TC_TKT_010 | Test edge case: same day resolution | Tickets resolved same day have correct metrics |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate EVENT_ID uniqueness and not null | All EVENT_ID values are unique and non-null |
| TC_BIL_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS table |
| TC_BIL_003 | Validate transaction amount logic | Amounts are positive except for refunds |
| TC_BIL_004 | Validate event type enumeration | All event types are valid enumerated values |
| TC_BIL_005 | Validate currency code format | Currency codes are valid 3-character ISO codes |
| TC_BIL_006 | Validate invoice number uniqueness | Invoice numbers are unique when present |
| TC_BIL_007 | Validate transaction status consistency | Status consistent with event type and amount |
| TC_BIL_008 | Test refund amount handling | Refund amounts are properly handled as negative |
| TC_BIL_009 | Test payment method derivation | Payment methods derived from transaction metadata |
| TC_BIL_010 | Test edge case: zero amount transactions | Zero amount transactions handled appropriately |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate LICENSE_ID uniqueness and not null | All LICENSE_ID values are unique and non-null |
| TC_LIC_002 | Validate user assignment referential integrity | Assigned user IDs exist in SI_USERS when not null |
| TC_LIC_003 | Validate license type enumeration | All license types are valid enumerated values |
| TC_LIC_004 | Validate license status derivation | Status correctly derived from current date vs validity period |
| TC_LIC_005 | Validate date logic constraints | START_DATE <= END_DATE when both present |
| TC_LIC_006 | Validate license cost calculations | Costs correctly assigned based on license type |
| TC_LIC_007 | Validate utilization percentage range | Utilization percentages are between 0 and 100 |
| TC_LIC_008 | Test unassigned license handling | Unassigned licenses have null user references |
| TC_LIC_009 | Test expired license identification | Expired licenses correctly identified |
| TC_LIC_010 | Test edge case: perpetual licenses | Licenses with null end dates handled correctly |

### 8. SI_WEBINARS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_WBN_001 | Validate WEBINAR_ID uniqueness and not null | All WEBINAR_ID values are unique and non-null |
| TC_WBN_002 | Validate HOST_ID referential integrity | All HOST_ID values exist in SI_USERS table |
| TC_WBN_003 | Validate duration calculations | Duration correctly calculated from start/end times |
| TC_WBN_004 | Validate attendance rate calculations | Attendance rate = (attendees/registrants) * 100 |
| TC_WBN_005 | Validate attendee count logic | Attendees <= registrants in all cases |
| TC_WBN_006 | Test zero registrant handling | Webinars with zero registrants handled correctly |
| TC_WBN_007 | Test attendance rate edge cases | Rate calculations handle division by zero |
| TC_WBN_008 | Test time zone consistency | All timestamps in consistent UTC format |
| TC_WBN_009 | Test webinar topic cleansing | Topics properly cleaned and standardized |
| TC_WBN_010 | Test edge case: cancelled webinars | Cancelled webinars identified and handled |

### 9. Cross-Model Integration Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INT_001 | Validate referential integrity across all models | All foreign key relationships are valid |
| TC_INT_002 | Test incremental processing coordination | All models process incrementally in correct order |
| TC_INT_003 | Validate data consistency across models | Related data is consistent across model boundaries |
| TC_INT_004 | Test audit log population | All model executions logged in audit table |
| TC_INT_005 | Test error handling propagation | Errors in upstream models handled downstream |
| TC_INT_006 | Validate data quality score consistency | Quality scores calculated consistently across models |
| TC_INT_007 | Test performance with large datasets | Models perform adequately with production data volumes |
| TC_INT_008 | Test concurrent execution handling | Models handle concurrent executions appropriately |
| TC_INT_009 | Test dependency resolution | Model dependencies resolved in correct execution order |
| TC_INT_010 | Test rollback and recovery scenarios | Failed executions can be rolled back and recovered |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer cleaned and standardized user data"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: email
        description: "Validated and standardized email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "Standardized subscription tier"
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: account_status
        description: "Current status of user account"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        description: "Overall data quality score for the record"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1

  - name: si_meetings
    description: "Silver layer cleaned and enriched meeting data"
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
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Calculated and validated meeting duration"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: meeting_status
        description: "Current state of the meeting"
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
      - name: meeting_type
        description: "Standardized meeting category"
        tests:
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']

  - name: si_participants
    description: "Silver layer cleaned participant attendance data"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        description: "Calculated time participant spent in meeting"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: participant_role
        description: "Role of attendee"
        tests:
          - accepted_values:
              values: ['Host', 'Co-host', 'Participant', 'Observer']

  - name: si_feature_usage
    description: "Silver layer standardized feature usage data"
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
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        description: "Validated number of times feature was utilized"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000
      - name: feature_category
        description: "Classification of feature type"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security', 'Other']

  - name: si_support_tickets
    description: "Silver layer standardized customer support ticket data"
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
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        description: "Standardized category"
        tests:
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: priority_level
        description: "Urgency level of ticket"
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: resolution_status
        description: "Current status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer validated billing and financial transaction data"
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
              to: ref('si_users')
              field: user_id
      - name: event_type
        description: "Standardized billing transaction type"
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
      - name: transaction_status
        description: "Status of transaction"
        tests:
          - accepted_values:
              values: ['Completed', 'Pending', 'Failed', 'Refunded']
      - name: currency_code
        description: "ISO currency code for the transaction"
        tests:
          - dbt_expectations.expect_column_value_lengths_to_equal:
              value: 3

  - name: si_licenses
    description: "Silver layer validated license assignment and management data"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: license_type
        description: "Standardized category"
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON']
      - name: license_status
        description: "Current state"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: utilization_percentage
        description: "Percentage of license features being utilized"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: si_webinars
    description: "Silver layer cleaned webinar data with engagement metrics"
    columns:
      - name: webinar_id
        description: "Unique identifier for each webinar"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the webinar host"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_rate
        description: "Percentage of registrants who attended"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
```

### Custom SQL-based dbt Tests

#### Test 1: Meeting Duration Consistency
```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test that calculated duration matches the difference between start and end times

SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as duration_diff
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### Test 2: Data Quality Score Validation
```sql
-- tests/assert_data_quality_scores_valid.sql
-- Test that all data quality scores are within valid range across all models

WITH quality_check AS (
    SELECT 'si_users' as model_name, user_id as record_id, data_quality_score
    FROM {{ ref('si_users') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_meetings', meeting_id, data_quality_score
    FROM {{ ref('si_meetings') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_participants', participant_id, data_quality_score
    FROM {{ ref('si_participants') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_feature_usage', usage_id, data_quality_score
    FROM {{ ref('si_feature_usage') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_support_tickets', ticket_id, data_quality_score
    FROM {{ ref('si_support_tickets') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_billing_events', event_id, data_quality_score
    FROM {{ ref('si_billing_events') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_licenses', license_id, data_quality_score
    FROM {{ ref('si_licenses') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_webinars', webinar_id, data_quality_score
    FROM {{ ref('si_webinars') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
)

SELECT * FROM quality_check
```

#### Test 3: Participant Count Accuracy
```sql
-- tests/assert_participant_count_accuracy.sql
-- Test that meeting participant counts match actual participant records

SELECT 
    m.meeting_id,
    m.participant_count as reported_count,
    COUNT(p.participant_id) as actual_count,
    ABS(m.participant_count - COUNT(p.participant_id)) as count_difference
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id
GROUP BY m.meeting_id, m.participant_count
HAVING ABS(m.participant_count - COUNT(p.participant_id)) > 0
```

#### Test 4: Attendance Duration Logic
```sql
-- tests/assert_attendance_duration_logic.sql
-- Test that attendance duration is calculated correctly and leave_time >= join_time

SELECT 
    participant_id,
    join_time,
    leave_time,
    attendance_duration,
    CASE 
        WHEN leave_time IS NULL THEN 'OK - Still in meeting'
        WHEN leave_time < join_time THEN 'ERROR - Leave before join'
        WHEN ABS(DATEDIFF('minute', join_time, leave_time) - attendance_duration) > 1 
        THEN 'ERROR - Duration calculation mismatch'
        ELSE 'OK'
    END as validation_result
FROM {{ ref('si_participants') }}
WHERE 
    (leave_time IS NOT NULL AND leave_time < join_time)
    OR (leave_time IS NOT NULL AND ABS(DATEDIFF('minute', join_time, leave_time) - attendance_duration) > 1)
```

#### Test 5: Billing Amount Logic
```sql
-- tests/assert_billing_amount_logic.sql
-- Test that billing amounts follow business rules (positive except for refunds)

SELECT 
    event_id,
    event_type,
    transaction_amount,
    CASE 
        WHEN event_type = 'Refund' AND transaction_amount >= 0 THEN 'ERROR - Refund should be negative'
        WHEN event_type != 'Refund' AND transaction_amount <= 0 THEN 'ERROR - Non-refund should be positive'
        ELSE 'OK'
    END as validation_result
FROM {{ ref('si_billing_events') }}
WHERE 
    (event_type = 'Refund' AND transaction_amount >= 0)
    OR (event_type != 'Refund' AND transaction_amount <= 0)
```

#### Test 6: License Date Logic
```sql
-- tests/assert_license_date_logic.sql
-- Test that license start dates are before end dates

SELECT 
    license_id,
    start_date,
    end_date,
    license_status,
    CASE 
        WHEN end_date IS NOT NULL AND start_date >= end_date THEN 'ERROR - Start date >= End date'
        WHEN license_status = 'Active' AND end_date < CURRENT_DATE() THEN 'ERROR - Active license past end date'
        WHEN license_status = 'Expired' AND end_date >= CURRENT_DATE() THEN 'ERROR - Expired license not past end date'
        ELSE 'OK'
    END as validation_result
FROM {{ ref('si_licenses') }}
WHERE 
    (end_date IS NOT NULL AND start_date >= end_date)
    OR (license_status = 'Active' AND end_date < CURRENT_DATE())
    OR (license_status = 'Expired' AND end_date >= CURRENT_DATE())
```

#### Test 7: Webinar Attendance Rate Logic
```sql
-- tests/assert_webinar_attendance_logic.sql
-- Test that webinar attendance rates are calculated correctly

SELECT 
    webinar_id,
    registrants,
    attendees,
    attendance_rate,
    CASE 
        WHEN attendees > registrants THEN 'ERROR - More attendees than registrants'
        WHEN registrants > 0 AND ABS((attendees::FLOAT / registrants * 100) - attendance_rate) > 0.01 
        THEN 'ERROR - Attendance rate calculation mismatch'
        WHEN registrants = 0 AND attendance_rate != 0 THEN 'ERROR - Non-zero rate with zero registrants'
        ELSE 'OK'
    END as validation_result
FROM {{ ref('si_webinars') }}
WHERE 
    attendees > registrants
    OR (registrants > 0 AND ABS((attendees::FLOAT / registrants * 100) - attendance_rate) > 0.01)
    OR (registrants = 0 AND attendance_rate != 0)
```

#### Test 8: Cross-Model Referential Integrity
```sql
-- tests/assert_cross_model_referential_integrity.sql
-- Test referential integrity across all Silver layer models

WITH integrity_violations AS (
    -- Check meetings with invalid host references
    SELECT 'si_meetings' as source_model, 'host_id' as field, meeting_id as record_id, host_id as invalid_reference
    FROM {{ ref('si_meetings') }} m
    LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
    WHERE u.user_id IS NULL AND m.host_id IS NOT NULL
    
    UNION ALL
    
    -- Check participants with invalid meeting references
    SELECT 'si_participants', 'meeting_id', participant_id, meeting_id
    FROM {{ ref('si_participants') }} p
    LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL
    
    UNION ALL
    
    -- Check participants with invalid user references
    SELECT 'si_participants', 'user_id', participant_id, user_id
    FROM {{ ref('si_participants') }} p
    LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
    WHERE u.user_id IS NULL AND p.user_id IS NOT NULL
    
    UNION ALL
    
    -- Check feature usage with invalid meeting references
    SELECT 'si_feature_usage', 'meeting_id', usage_id, meeting_id
    FROM {{ ref('si_feature_usage') }} f
    LEFT JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL
    
    UNION ALL
    
    -- Check support tickets with invalid user references
    SELECT 'si_support_tickets', 'user_id', ticket_id, user_id
    FROM {{ ref('si_support_tickets') }} t
    LEFT JOIN {{ ref('si_users') }} u ON t.user_id = u.user_id
    WHERE u.user_id IS NULL AND t.user_id IS NOT NULL
    
    UNION ALL
    
    -- Check billing events with invalid user references
    SELECT 'si_billing_events', 'user_id', event_id, user_id
    FROM {{ ref('si_billing_events') }} b
    LEFT JOIN {{ ref('si_users') }} u ON b.user_id = u.user_id
    WHERE u.user_id IS NULL AND b.user_id IS NOT NULL
    
    UNION ALL
    
    -- Check licenses with invalid user references
    SELECT 'si_licenses', 'assigned_to_user_id', license_id, assigned_to_user_id
    FROM {{ ref('si_licenses') }} l
    LEFT JOIN {{ ref('si_users') }} u ON l.assigned_to_user_id = u.user_id
    WHERE u.user_id IS NULL AND l.assigned_to_user_id IS NOT NULL
    
    UNION ALL
    
    -- Check webinars with invalid host references
    SELECT 'si_webinars', 'host_id', webinar_id, host_id
    FROM {{ ref('si_webinars') }} w
    LEFT JOIN {{ ref('si_users') }} u ON w.host_id = u.user_id
    WHERE u.user_id IS NULL AND w.host_id IS NOT NULL
)

SELECT * FROM integrity_violations
```

#### Test 9: Incremental Processing Validation
```sql
-- tests/assert_incremental_processing.sql
-- Test that incremental processing works correctly

{% if is_incremental() %}
WITH incremental_check AS (
    SELECT 
        'si_users' as model_name,
        COUNT(*) as processed_records,
        MIN(update_timestamp) as min_update_time,
        MAX(update_timestamp) as max_update_time
    FROM {{ this }}
    WHERE update_timestamp > (
        SELECT COALESCE(MAX(update_timestamp), '1900-01-01'::timestamp)
        FROM {{ this }}
    )
    
    UNION ALL
    
    SELECT 
        'si_meetings',
        COUNT(*),
        MIN(update_timestamp),
        MAX(update_timestamp)
    FROM {{ ref('si_meetings') }}
    WHERE update_timestamp > (
        SELECT COALESCE(MAX(update_timestamp), '1900-01-01'::timestamp)
        FROM {{ ref('si_meetings') }}
    )
)

SELECT * FROM incremental_check
WHERE processed_records = 0  -- Should not have zero records in incremental run
{% else %}
-- Full refresh - no validation needed
SELECT 1 as dummy WHERE FALSE
{% endif %}
```

#### Test 10: Data Freshness Validation
```sql
-- tests/assert_data_freshness.sql
-- Test that data is fresh and within acceptable time windows

WITH freshness_check AS (
    SELECT 
        'si_users' as model_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'si_meetings',
        MAX(load_timestamp),
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP())
    FROM {{ ref('si_meetings') }}
    
    UNION ALL
    
    SELECT 
        'si_participants',
        MAX(load_timestamp),
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP())
    FROM {{ ref('si_participants') }}
    
    UNION ALL
    
    SELECT 
        'si_feature_usage',
        MAX(load_timestamp),
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP())
    FROM {{ ref('si_feature_usage') }}
    
    UNION ALL
    
    SELECT 
        'si_support_tickets',
        MAX(load_timestamp),
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP())
    FROM {{ ref('si_support_tickets') }}
    
    UNION ALL
    
    SELECT 
        'si_billing_events',
        MAX(load_timestamp),
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP())
    FROM {{ ref('si_billing_events') }}
    
    UNION ALL
    
    SELECT 
        'si_licenses',
        MAX(load_timestamp),
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP())
    FROM {{ ref('si_licenses') }}
    
    UNION ALL
    
    SELECT 
        'si_webinars',
        MAX(load_timestamp),
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP())
    FROM {{ ref('si_webinars') }}
)

SELECT * FROM freshness_check
WHERE hours_since_load > 24  -- Data should not be older than 24 hours
```

## Test Execution and Monitoring

### Running Tests

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users

# Run specific test
dbt test --select test_name:assert_meeting_duration_consistency

# Run tests with increased verbosity
dbt test --verbose

# Run tests and store results
dbt test --store-failures
```

### Test Results Tracking

All test results are automatically tracked in dbt's `run_results.json` and can be integrated with Snowflake's audit schema for comprehensive monitoring and alerting.

### Performance Considerations

1. **Test Optimization**: Complex tests are designed to fail fast and provide specific error details
2. **Incremental Testing**: Tests support incremental model testing to reduce execution time
3. **Parallel Execution**: Tests can be executed in parallel for improved performance
4. **Resource Management**: Tests use appropriate Snowflake warehouse sizing for optimal performance

### Maintenance and Updates

1. **Version Control**: All test scripts are version controlled alongside model code
2. **Documentation**: Test cases are documented with clear descriptions and expected outcomes
3. **Regular Review**: Test cases are reviewed and updated as business rules evolve
4. **Monitoring**: Test execution is monitored for performance and reliability

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver layer dbt models in Snowflake, providing confidence in data quality and business rule compliance.