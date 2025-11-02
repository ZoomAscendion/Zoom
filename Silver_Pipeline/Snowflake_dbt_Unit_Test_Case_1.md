_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Test Coverage Overview

The test suite covers the following Silver Layer models:
- `si_users` - User account data with validation and standardization
- `si_meetings` - Meeting data with enrichments and participant counts
- `si_participants` - Participant attendance data with calculated metrics
- `si_feature_usage` - Feature usage tracking with categorization
- `si_support_tickets` - Support ticket data with resolution metrics
- `si_billing_events` - Billing transaction data with financial validations
- `si_licenses` - License management data with status calculations
- `si_webinars` - Webinar data with engagement metrics
- `audit_log` - Pipeline execution audit trail

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate unique user_id constraint | All user_id values are unique, no duplicates |
| TC_USR_002 | Validate not_null constraint on user_id | No NULL values in user_id column |
| TC_USR_003 | Validate not_null constraint on email | No NULL values in email column |
| TC_USR_004 | Validate email format using regex | All emails follow valid format pattern |
| TC_USR_005 | Validate plan_type accepted values | Only valid plan types: Free, Pro, Business, Enterprise, UNKNOWN_PLAN |
| TC_USR_006 | Validate account_status accepted values | Only valid statuses: Active, Inactive, Suspended |
| TC_USR_007 | Test data quality score calculation | Scores range from 0.00 to 1.00 based on validation flags |
| TC_USR_008 | Test user_name standardization | Names are trimmed and converted to uppercase |
| TC_USR_009 | Test email standardization | Emails are trimmed and converted to lowercase |
| TC_USR_010 | Test company name standardization | Company names are trimmed and title-cased |
| TC_USR_011 | Test duplicate removal logic | Only latest record per user_id is retained |
| TC_USR_012 | Test invalid email rejection | Records with invalid email formats are blocked |
| TC_USR_013 | Test missing user_id rejection | Records with NULL user_id are blocked |
| TC_USR_014 | Test future timestamp handling | Future load_timestamp records are flagged appropriately |
| TC_USR_015 | Test account status derivation | Status correctly derived from plan_type |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate unique meeting_id constraint | All meeting_id values are unique |
| TC_MTG_002 | Validate not_null constraint on meeting_id | No NULL values in meeting_id column |
| TC_MTG_003 | Validate not_null constraint on host_id | No NULL values in host_id column |
| TC_MTG_004 | Validate not_null constraint on start_time | No NULL values in start_time column |
| TC_MTG_005 | Validate not_null constraint on end_time | No NULL values in end_time column |
| TC_MTG_006 | Validate meeting_type accepted values | Only valid types: Scheduled, Instant, Webinar, Personal |
| TC_MTG_007 | Validate meeting_status accepted values | Only valid statuses: Scheduled, In Progress, Completed, Cancelled |
| TC_MTG_008 | Validate recording_status accepted values | Only valid values: Yes, No |
| TC_MTG_009 | Test meeting type derivation logic | Type correctly derived from duration_minutes |
| TC_MTG_010 | Test duration calculation | Duration matches difference between start and end times |
| TC_MTG_011 | Test invalid time sequence correction | End_time corrected when less than start_time |
| TC_MTG_012 | Test negative duration correction | Negative durations converted to absolute values |
| TC_MTG_013 | Test host name enrichment | Host names populated from user lookup |
| TC_MTG_014 | Test participant count calculation | Counts match aggregated participant data |
| TC_MTG_015 | Test meeting status derivation | Status correctly derived from timestamps vs current time |
| TC_MTG_016 | Test recording status logic | Recording status based on duration > 60 minutes |
| TC_MTG_017 | Test data quality score calculation | Scores reflect validation flag results |
| TC_MTG_018 | Test duplicate removal | Latest record per meeting_id retained |
| TC_MTG_019 | Test missing meeting_id rejection | Records with NULL meeting_id blocked |
| TC_MTG_020 | Test missing host_id rejection | Records with NULL host_id blocked |

### 3. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate unique participant_id constraint | All participant_id values are unique |
| TC_PRT_002 | Validate not_null constraint on participant_id | No NULL values in participant_id column |
| TC_PRT_003 | Test attendance duration calculation | Duration correctly calculated from join/leave times |
| TC_PRT_004 | Test missing leave_time handling | Average duration used when leave_time is NULL |
| TC_PRT_005 | Test invalid time sequence correction | Leave_time corrected when less than join_time |
| TC_PRT_006 | Test connection quality derivation | Quality correctly categorized based on duration |
| TC_PRT_007 | Test participant role assignment | Default role 'Participant' assigned |
| TC_PRT_008 | Test future timestamp flagging | Future timestamps flagged appropriately |
| TC_PRT_009 | Test data quality score calculation | Scores reflect validation results |
| TC_PRT_010 | Test duplicate removal | Latest record per participant_id retained |
| TC_PRT_011 | Test missing participant_id rejection | Records with NULL participant_id blocked |
| TC_PRT_012 | Test missing meeting_id rejection | Records with NULL meeting_id blocked |
| TC_PRT_013 | Test missing user_id rejection | Records with NULL user_id blocked |
| TC_PRT_014 | Test average duration calculation | Average calculated correctly from valid records |
| TC_PRT_015 | Test connection quality categories | Poor, Fair, Good, Excellent assigned correctly |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate unique usage_id constraint | All usage_id values are unique |
| TC_FTR_002 | Validate not_null constraint on usage_id | No NULL values in usage_id column |
| TC_FTR_003 | Test feature categorization logic | Features correctly categorized: Audio, Video, Collaboration, Security, Other |
| TC_FTR_004 | Test negative usage count handling | Negative counts set to NULL |
| TC_FTR_005 | Test outlier usage count correction | Outliers capped at mean + 3*stddev |
| TC_FTR_006 | Test usage duration calculation | Duration calculated as usage_count * 2 |
| TC_FTR_007 | Test feature name standardization | Names trimmed and converted to uppercase |
| TC_FTR_008 | Test data quality score calculation | Scores reflect validation flag results |
| TC_FTR_009 | Test duplicate removal | Latest record per usage_id retained |
| TC_FTR_010 | Test missing usage_id rejection | Records with NULL usage_id blocked |
| TC_FTR_011 | Test missing meeting_id rejection | Records with NULL meeting_id blocked |
| TC_FTR_012 | Test missing feature_name rejection | Records with NULL/empty feature_name blocked |
| TC_FTR_013 | Test outlier detection logic | Statistical outliers identified correctly |
| TC_FTR_014 | Test audio feature categorization | Audio-related features categorized correctly |
| TC_FTR_015 | Test video feature categorization | Video-related features categorized correctly |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate unique ticket_id constraint | All ticket_id values are unique |
| TC_TKT_002 | Validate not_null constraint on ticket_id | No NULL values in ticket_id column |
| TC_TKT_003 | Test ticket type validation | Only valid types: Technical, Billing, Feature Request, Bug Report, Other |
| TC_TKT_004 | Test priority level derivation | Priority correctly derived from ticket type |
| TC_TKT_005 | Test resolution status validation | Only valid statuses: Open, In Progress, Resolved, Closed |
| TC_TKT_006 | Test future open_date correction | Future dates corrected to current date |
| TC_TKT_007 | Test close_date calculation | Close date estimated for resolved/closed tickets |
| TC_TKT_008 | Test resolution time calculation | Time calculated correctly in hours |
| TC_TKT_009 | Test issue description generation | Descriptions generated based on ticket type |
| TC_TKT_010 | Test resolution notes generation | Notes generated based on status |
| TC_TKT_011 | Test data quality score calculation | Scores reflect validation results |
| TC_TKT_012 | Test duplicate removal | Latest record per ticket_id retained |
| TC_TKT_013 | Test missing ticket_id rejection | Records with NULL ticket_id blocked |
| TC_TKT_014 | Test missing user_id rejection | Records with NULL user_id blocked |
| TC_TKT_015 | Test invalid ticket type handling | Invalid types converted to 'Other' |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate unique event_id constraint | All event_id values are unique |
| TC_BIL_002 | Validate not_null constraint on event_id | No NULL values in event_id column |
| TC_BIL_003 | Test event type validation | Only valid types: Subscription, Upgrade, Downgrade, Refund, Other |
| TC_BIL_004 | Test negative amount handling | Negative amounts for non-refund events corrected |
| TC_BIL_005 | Test excessive amount detection | Amounts > 99th percentile * 10 flagged |
| TC_BIL_006 | Test payment method derivation | Method derived based on amount ranges |
| TC_BIL_007 | Test currency code assignment | All records assigned 'USD' currency |
| TC_BIL_008 | Test invoice number generation | Invoice numbers generated with 'INV-' prefix |
| TC_BIL_009 | Test transaction status derivation | Status derived from amount and event type |
| TC_BIL_010 | Test data quality score calculation | Scores reflect validation results |
| TC_BIL_011 | Test duplicate removal | Latest record per event_id retained |
| TC_BIL_012 | Test missing event_id rejection | Records with NULL event_id blocked |
| TC_BIL_013 | Test missing user_id rejection | Records with NULL user_id blocked |
| TC_BIL_014 | Test refund handling | Refunds processed correctly with negative amounts |
| TC_BIL_015 | Test amount validation | Zero amounts result in 'Pending' status |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate unique license_id constraint | All license_id values are unique |
| TC_LIC_002 | Validate not_null constraint on license_id | No NULL values in license_id column |
| TC_LIC_003 | Test license type validation | Only valid types: Basic, Pro, Enterprise, Add-on, Other |
| TC_LIC_004 | Test license status derivation | Status correctly derived from date ranges |
| TC_LIC_005 | Test invalid date range correction | End_date and start_date swapped when invalid |
| TC_LIC_006 | Test license cost assignment | Costs correctly assigned based on license type |
| TC_LIC_007 | Test renewal status calculation | Renewal flagged when expiring within 30 days |
| TC_LIC_008 | Test utilization percentage assignment | Utilization assigned based on license type |
| TC_LIC_009 | Test assigned user name enrichment | User names populated from user lookup |
| TC_LIC_010 | Test data quality score calculation | Scores reflect validation results |
| TC_LIC_011 | Test duplicate removal | Latest record per license_id retained |
| TC_LIC_012 | Test missing license_id rejection | Records with NULL license_id blocked |
| TC_LIC_013 | Test missing user_id rejection | Records with NULL assigned_to_user_id blocked |
| TC_LIC_014 | Test future start date handling | Future start dates flagged appropriately |
| TC_LIC_015 | Test license status categories | Expired, Pending, Active assigned correctly |

### 8. SI_WEBINARS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_WEB_001 | Validate unique webinar_id constraint | All webinar_id values are unique |
| TC_WEB_002 | Validate not_null constraint on webinar_id | No NULL values in webinar_id column |
| TC_WEB_003 | Test missing end_time handling | Default 1-hour duration applied |
| TC_WEB_004 | Test invalid time sequence correction | End_time corrected when less than start_time |
| TC_WEB_005 | Test negative registrants correction | Negative values corrected to 0 |
| TC_WEB_006 | Test attendees calculation | Attendees estimated as 75% of registrants |
| TC_WEB_007 | Test attendance rate calculation | Rate calculated as attendees/registrants * 100 |
| TC_WEB_008 | Test webinar topic handling | Missing topics replaced with default message |
| TC_WEB_009 | Test duration calculation | Duration calculated correctly in minutes |
| TC_WEB_010 | Test data quality score calculation | Scores reflect validation results |
| TC_WEB_011 | Test duplicate removal | Latest record per webinar_id retained |
| TC_WEB_012 | Test missing webinar_id rejection | Records with NULL webinar_id blocked |
| TC_WEB_013 | Test missing host_id rejection | Records with NULL host_id blocked |
| TC_WEB_014 | Test zero registrants handling | Zero registrants result in 0% attendance rate |
| TC_WEB_015 | Test topic standardization | Topics trimmed and validated |

### 9. AUDIT_LOG Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Validate audit log structure | All required columns present with correct data types |
| TC_AUD_002 | Test execution_id generation | Unique execution IDs generated for each run |
| TC_AUD_003 | Test pipeline tracking | All pipeline executions logged |
| TC_AUD_004 | Test status tracking | Success/failure status captured |
| TC_AUD_005 | Test duration calculation | Execution duration calculated correctly |
| TC_AUD_006 | Test record count tracking | Processed record counts captured |
| TC_AUD_007 | Test error message capture | Error messages logged for failed executions |
| TC_AUD_008 | Test data lineage tracking | Source and target tables tracked |
| TC_AUD_009 | Test timestamp accuracy | Start and end times captured accurately |
| TC_AUD_010 | Test environment tracking | Execution environment information captured |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer users table with cleaned and standardized user data"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: email
        description: "Validated and standardized email address"
        tests:
          - not_null:
              severity: error
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
              severity: warn
      - name: plan_type
        description: "Standardized subscription tier"
        tests:
          - accepted_values:
              values: ['Free', 'Pro', 'Business', 'Enterprise', 'UNKNOWN_PLAN']
              severity: error
      - name: account_status
        description: "Current status of user account"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
              severity: error
      - name: data_quality_score
        description: "Overall data quality score for the record (0.00 to 1.00)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 1.00
              severity: warn

  - name: si_meetings
    description: "Silver layer meetings table with cleaned and enriched meeting data"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: warn
      - name: meeting_type
        description: "Standardized meeting category"
        tests:
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
              severity: error
      - name: start_time
        description: "Validated meeting start timestamp"
        tests:
          - not_null:
              severity: error
      - name: end_time
        description: "Validated meeting end timestamp"
        tests:
          - not_null:
              severity: error
      - name: meeting_status
        description: "Current state of the meeting"
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
              severity: error
      - name: recording_status
        description: "Whether the meeting was recorded"
        tests:
          - accepted_values:
              values: ['Yes', 'No']
              severity: error
      - name: duration_minutes
        description: "Calculated and validated meeting duration"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max
              severity: warn

  - name: si_participants
    description: "Silver layer participants table with cleaned attendance data"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant record"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
              severity: warn
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: warn
      - name: attendance_duration
        description: "Calculated attendance duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
              severity: warn
      - name: connection_quality
        description: "Derived connection quality rating"
        tests:
          - accepted_values:
              values: ['Poor', 'Fair', 'Good', 'Excellent']
              severity: error

  - name: si_feature_usage
    description: "Silver layer feature usage table with categorization"
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
              severity: warn
      - name: feature_category
        description: "Standardized feature category"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security', 'Other']
              severity: error
      - name: usage_count
        description: "Validated usage count"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
              severity: warn

  - name: si_support_tickets
    description: "Silver layer support tickets table with resolution metrics"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: warn
      - name: ticket_type
        description: "Standardized ticket category"
        tests:
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report', 'Other']
              severity: error
      - name: priority_level
        description: "Derived priority level"
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
              severity: error
      - name: resolution_status
        description: "Current resolution status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
              severity: error

  - name: si_billing_events
    description: "Silver layer billing events table with financial validations"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: warn
      - name: event_type
        description: "Standardized event type"
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund', 'Other']
              severity: error
      - name: transaction_status
        description: "Current transaction status"
        tests:
          - accepted_values:
              values: ['Completed', 'Refunded', 'Pending', 'Failed']
              severity: error
      - name: currency_code
        description: "Transaction currency"
        tests:
          - accepted_values:
              values: ['USD']
              severity: error

  - name: si_licenses
    description: "Silver layer licenses table with status calculations"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: warn
      - name: license_type
        description: "Standardized license type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-on', 'Other']
              severity: error
      - name: license_status
        description: "Current license status"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Pending']
              severity: error
      - name: renewal_status
        description: "Renewal requirement status"
        tests:
          - accepted_values:
              values: ['Yes', 'No']
              severity: error

  - name: si_webinars
    description: "Silver layer webinars table with engagement metrics"
    columns:
      - name: webinar_id
        description: "Unique identifier for each webinar"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      - name: host_id
        description: "User ID of the webinar host"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: warn
      - name: registrants
        description: "Number of registered participants"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
              severity: warn
      - name: attendees
        description: "Number of actual attendees"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
              severity: warn
      - name: attendance_rate
        description: "Calculated attendance percentage"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 100.00
              severity: warn
```

### Custom SQL-Based dbt Tests

#### 1. Test for Valid Time Sequences in Meetings

```sql
-- tests/assert_valid_meeting_time_sequence.sql
SELECT 
    meeting_id,
    start_time,
    end_time,
    'Invalid time sequence: end_time before start_time' as error_message
FROM {{ ref('si_meetings') }}
WHERE end_time < start_time
```

#### 2. Test for Data Quality Score Consistency

```sql
-- tests/assert_data_quality_score_consistency.sql
SELECT 
    'si_users' as table_name,
    COUNT(*) as records_with_invalid_scores
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.00 OR data_quality_score > 1.00

UNION ALL

SELECT 
    'si_meetings' as table_name,
    COUNT(*) as records_with_invalid_scores
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0.00 OR data_quality_score > 1.00

UNION ALL

SELECT 
    'si_participants' as table_name,
    COUNT(*) as records_with_invalid_scores
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0.00 OR data_quality_score > 1.00

HAVING records_with_invalid_scores > 0
```

#### 3. Test for Referential Integrity

```sql
-- tests/assert_referential_integrity.sql
-- Check for orphaned meeting records
SELECT 
    m.meeting_id,
    m.host_id,
    'Orphaned meeting: host_id not found in users table' as error_message
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL

UNION ALL

-- Check for orphaned participant records
SELECT 
    p.participant_id,
    p.meeting_id,
    'Orphaned participant: meeting_id not found in meetings table' as error_message
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
```

#### 4. Test for Business Rule Validation

```sql
-- tests/assert_business_rules.sql
-- Test: Meeting duration should not exceed 24 hours
SELECT 
    meeting_id,
    duration_minutes,
    'Meeting duration exceeds 24 hours' as error_message
FROM {{ ref('si_meetings') }}
WHERE duration_minutes > 1440

UNION ALL

-- Test: Participant attendance should not exceed meeting duration
SELECT 
    p.participant_id,
    p.attendance_duration,
    'Participant attendance exceeds meeting duration' as error_message
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.attendance_duration > m.duration_minutes

UNION ALL

-- Test: Webinar attendees should not exceed registrants
SELECT 
    webinar_id,
    registrants,
    attendees,
    'Attendees exceed registrants' as error_message
FROM {{ ref('si_webinars') }}
WHERE attendees > registrants
```

#### 5. Test for Data Freshness

```sql
-- tests/assert_data_freshness.sql
SELECT 
    'si_users' as table_name,
    MAX(load_date) as latest_load_date,
    CURRENT_DATE() as current_date,
    DATEDIFF('day', MAX(load_date), CURRENT_DATE()) as days_since_last_load
FROM {{ ref('si_users') }}
WHERE DATEDIFF('day', MAX(load_date), CURRENT_DATE()) > 1

UNION ALL

SELECT 
    'si_meetings' as table_name,
    MAX(load_date) as latest_load_date,
    CURRENT_DATE() as current_date,
    DATEDIFF('day', MAX(load_date), CURRENT_DATE()) as days_since_last_load
FROM {{ ref('si_meetings') }}
WHERE DATEDIFF('day', MAX(load_date), CURRENT_DATE()) > 1
```

#### 6. Test for Audit Log Completeness

```sql
-- tests/assert_audit_log_completeness.sql
SELECT 
    pipeline_name,
    COUNT(*) as incomplete_records
FROM {{ ref('audit_log') }}
WHERE execution_id IS NULL 
   OR pipeline_name IS NULL 
   OR start_time IS NULL 
   OR status IS NULL
GROUP BY pipeline_name
HAVING COUNT(*) > 0
```

### Parameterized Tests

#### 1. Generic Test for Email Validation

```sql
-- macros/test_email_format.sql
{% macro test_email_format(model, column_name) %}

SELECT 
    {{ column_name }},
    'Invalid email format' as error_message
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND NOT REGEXP_LIKE(LOWER(TRIM({{ column_name }})), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')

{% endmacro %}
```

#### 2. Generic Test for Date Range Validation

```sql
-- macros/test_date_range.sql
{% macro test_date_range(model, start_date_column, end_date_column) %}

SELECT 
    {{ start_date_column }},
    {{ end_date_column }},
    'End date is before start date' as error_message
FROM {{ model }}
WHERE {{ end_date_column }} < {{ start_date_column }}

{% endmacro %}
```

#### 3. Generic Test for Percentage Values

```sql
-- macros/test_percentage_range.sql
{% macro test_percentage_range(model, column_name) %}

SELECT 
    {{ column_name }},
    'Percentage value out of range (0-100)' as error_message
FROM {{ model }}
WHERE {{ column_name }} < 0.00 OR {{ column_name }} > 100.00

{% endmacro %}
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before deploying models
- Execute custom SQL tests to validate business rules
- Verify data quality scores meet minimum thresholds
- Check referential integrity across all models

### 2. Post-deployment Validation
- Validate record counts match expected ranges
- Check data freshness requirements
- Verify audit log completeness
- Monitor data quality score trends

### 3. Continuous Monitoring
- Schedule daily execution of critical tests
- Set up alerts for test failures
- Track data quality metrics over time
- Monitor pipeline performance metrics

### 4. Test Result Tracking
- All test results logged in dbt's run_results.json
- Critical failures logged to Snowflake audit schema
- Test execution metrics tracked in audit_log table
- Data quality trends monitored via dashboard

## Expected Test Outcomes

### Success Criteria
- All unique and not_null constraints pass with 100% success rate
- Referential integrity tests pass with < 1% failure rate
- Data quality scores maintain > 95% average across all models
- Business rule validations pass with < 2% exception rate
- Data freshness requirements met within 24-hour SLA

### Failure Handling
- Critical test failures block downstream processing
- Warning-level failures logged but allow processing to continue
- Failed records quarantined for manual review
- Automatic retry logic for transient failures
- Escalation procedures for persistent failures

## Maintenance and Updates

### Regular Review Schedule
- Weekly review of test results and failure patterns
- Monthly assessment of test coverage and effectiveness
- Quarterly update of test thresholds and business rules
- Annual comprehensive review of test strategy

### Test Evolution
- Add new tests as business requirements evolve
- Update acceptance criteria based on data quality trends
- Enhance test coverage for identified data quality gaps
- Optimize test performance for large data volumes

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Silver Layer dbt models in Snowflake, providing robust data quality validation and monitoring capabilities.