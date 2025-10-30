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
- **Key transformations and business rules** implemented in each dbt model
- **Edge cases** including null values, empty datasets, invalid lookups, and schema mismatches
- **Error handling scenarios** for failed relationships, unexpected values, and data quality issues
- **Data integrity** through unique, not_null, relationships, accepted_values, and custom SQL tests
- **Performance and scalability** considerations for Snowflake environment

## Test Case Coverage

### Models Under Test:
1. **audit_log** - Pipeline execution tracking
2. **si_users** - User data transformation and validation
3. **si_meetings** - Meeting data enrichment and calculations
4. **si_participants** - Participant attendance processing
5. **si_feature_usage** - Feature usage categorization
6. **si_support_tickets** - Support ticket status tracking
7. **si_billing_events** - Financial transaction validation
8. **si_licenses** - License management processing
9. **si_webinars** - Webinar engagement metrics

---

## Test Case List

### 1. AUDIT_LOG Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| AL_001 | Validate execution_id uniqueness and not null | All execution_id values are unique and non-null |
| AL_002 | Verify pipeline_name is populated for all records | No null or empty pipeline_name values |
| AL_003 | Check status values are from accepted list | All status values in ('SUCCESS', 'FAILED', 'STARTED', 'COMPLETED') |
| AL_004 | Validate start_time and end_time logic | end_time >= start_time when both are not null |
| AL_005 | Test execution_duration_seconds calculation | Duration matches calculated difference between start and end times |
| AL_006 | Verify records_processed is non-negative | All records_processed values >= 0 |
| AL_007 | Check executed_by is populated | No null executed_by values |
| AL_008 | Validate source_system consistency | All source_system values are 'DBT_PIPELINE' |

### 2. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SU_001 | Validate user_id uniqueness and not null | All user_id values are unique and non-null |
| SU_002 | Check email format validation | All email values follow valid email regex pattern |
| SU_003 | Verify plan_type enumeration | All plan_type values in ('Free', 'Basic', 'Pro', 'Enterprise') |
| SU_004 | Test account_status derivation logic | Account status correctly derived from update_timestamp |
| SU_005 | Validate user_name standardization | User names are properly formatted with INITCAP |
| SU_006 | Check data_quality_score calculation | All scores between 0.00 and 1.00 |
| SU_007 | Test deduplication logic | No duplicate user_id after ROW_NUMBER() partitioning |
| SU_008 | Verify registration_date extraction | Registration dates extracted correctly from load_timestamp |
| SU_009 | Check company name standardization | Company names properly formatted and not 'Unknown Company' for valid data |
| SU_010 | Test incremental processing | Only new/updated records processed in incremental runs |

### 3. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SM_001 | Validate meeting_id uniqueness and not null | All meeting_id values are unique and non-null |
| SM_002 | Check host_id referential integrity | All host_id values exist in si_users.user_id |
| SM_003 | Verify meeting_type derivation | Meeting types correctly categorized based on duration |
| SM_004 | Test duration_minutes validation | All duration values between 0 and 1440 minutes |
| SM_005 | Validate start_time and end_time logic | end_time >= start_time for all records |
| SM_006 | Check meeting_status derivation | Status correctly derived from timestamps vs current time |
| SM_007 | Test participant_count calculation | Count matches actual participants from bz_participants |
| SM_008 | Verify host_name lookup | Host names correctly retrieved from si_users |
| SM_009 | Check recording_status logic | Recording status correctly derived from duration |
| SM_010 | Test deduplication and data quality | No duplicates and quality scores calculated correctly |

### 4. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SP_001 | Validate participant_id uniqueness | All participant_id values are unique and non-null |
| SP_002 | Check meeting_id referential integrity | All meeting_id values exist in si_meetings.meeting_id |
| SP_003 | Verify user_id referential integrity | All user_id values exist in si_users.user_id |
| SP_004 | Test attendance_duration calculation | Duration correctly calculated from join/leave times |
| SP_005 | Validate join_time and leave_time logic | leave_time >= join_time when both are not null |
| SP_006 | Check participant_role derivation | Roles correctly assigned based on host relationship |
| SP_007 | Verify connection_quality assignment | Quality levels assigned based on attendance duration |
| SP_008 | Test edge case handling for null leave_time | Default 1-minute duration assigned when leave_time is null |
| SP_009 | Check data_quality_score calculation | All scores between 0.00 and 1.00 |
| SP_010 | Test incremental processing logic | Only new/updated records processed |

### 5. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SF_001 | Validate usage_id uniqueness | All usage_id values are unique and non-null |
| SF_002 | Check meeting_id referential integrity | All meeting_id values exist in si_meetings.meeting_id |
| SF_003 | Verify feature_category mapping | Categories correctly assigned based on feature_name patterns |
| SF_004 | Test usage_count validation | All usage_count values >= 0 |
| SF_005 | Check usage_duration calculation | Duration calculated as usage_count * 2 |
| SF_006 | Validate feature_name standardization | Feature names converted to uppercase and trimmed |
| SF_007 | Test usage_date validation | All usage dates <= current_date |
| SF_008 | Verify default category assignment | Unknown features assigned to 'Collaboration' category |
| SF_009 | Check data_quality_score calculation | All scores between 0.00 and 1.00 |
| SF_010 | Test deduplication logic | No duplicate usage_id after processing |

### 6. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| ST_001 | Validate ticket_id uniqueness | All ticket_id values are unique and non-null |
| ST_002 | Check user_id referential integrity | All user_id values exist in si_users.user_id |
| ST_003 | Verify ticket_type enumeration | All ticket_type values in accepted list |
| ST_004 | Test priority_level derivation | Priority correctly assigned based on ticket_type |
| ST_005 | Check resolution_status validation | All status values in accepted enumeration |
| ST_006 | Validate open_date logic | All open_date values <= current_date |
| ST_007 | Test close_date calculation | Close dates calculated correctly for resolved tickets |
| ST_008 | Verify resolution_time_hours calculation | Resolution time calculated correctly in hours |
| ST_009 | Check issue_description generation | Descriptions generated based on ticket_type |
| ST_010 | Test data_quality_score calculation | All scores between 0.00 and 1.00 |

### 7. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SB_001 | Validate event_id uniqueness | All event_id values are unique and non-null |
| SB_002 | Check user_id referential integrity | All user_id values exist in si_users.user_id |
| SB_003 | Verify event_type enumeration | All event_type values in accepted list |
| SB_004 | Test transaction_amount validation | Amounts positive for non-refund events, negative for refunds |
| SB_005 | Check payment_method derivation | Payment methods correctly assigned based on amount |
| SB_006 | Validate currency_code assignment | All currency codes set to 'USD' |
| SB_007 | Test invoice_number generation | Invoice numbers generated with correct format |
| SB_008 | Verify transaction_status logic | Status correctly derived from event_type and amount |
| SB_009 | Check transaction_date validation | All transaction dates <= current_date |
| SB_010 | Test data_quality_score calculation | All scores between 0.00 and 1.00 |

### 8. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SL_001 | Validate license_id uniqueness | All license_id values are unique and non-null |
| SL_002 | Check assigned_to_user_id referential integrity | All user_id values exist in si_users.user_id when not null |
| SL_003 | Verify license_type enumeration | All license_type values in accepted list |
| SL_004 | Test license_status derivation | Status correctly derived from start/end dates vs current date |
| SL_005 | Check license_cost assignment | Costs correctly assigned based on license_type |
| SL_006 | Validate start_date and end_date logic | end_date >= start_date for all records |
| SL_007 | Test assigned_user_name lookup | User names correctly retrieved from si_users |
| SL_008 | Verify renewal_status logic | Renewal status correctly determined from end_date |
| SL_009 | Check utilization_percentage assignment | Utilization assigned based on license_type |
| SL_010 | Test data_quality_score calculation | All scores between 0.00 and 1.00 |

### 9. SI_WEBINARS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SW_001 | Validate webinar_id uniqueness | All webinar_id values are unique and non-null |
| SW_002 | Check host_id referential integrity | All host_id values exist in si_users.user_id |
| SW_003 | Verify duration_minutes calculation | Duration correctly calculated from start/end times |
| SW_004 | Test attendees calculation | Attendees calculated as 70% of registrants |
| SW_005 | Check attendance_rate calculation | Rate correctly calculated as (attendees/registrants)*100 |
| SW_006 | Validate start_time and end_time logic | end_time >= start_time for all records |
| SW_007 | Test registrants validation | All registrants values >= 0 |
| SW_008 | Verify webinar_topic standardization | Topics properly cleaned and formatted |
| SW_009 | Check data_quality_score calculation | All scores between 0.00 and 1.00 |
| SW_010 | Test deduplication logic | No duplicate webinar_id after processing |

---

## dbt Test Scripts

### YAML-based Schema Tests

#### models/silver/schema.yml
```yaml
version: 2

sources:
  - name: bronze
    description: "Bronze layer tables containing raw data from Zoom platform"
    tables:
      - name: bz_users
        description: "Raw user account information"
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
      - name: bz_meetings
        description: "Raw meeting session information"
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
      - name: bz_participants
        description: "Raw meeting participant information"
        columns:
          - name: participant_id
            description: "Unique identifier for each participant record"
            tests:
              - not_null
              - unique
      - name: bz_feature_usage
        description: "Raw platform feature usage tracking"
        columns:
          - name: usage_id
            description: "Unique identifier for each feature usage record"
            tests:
              - not_null
              - unique
      - name: bz_support_tickets
        description: "Raw customer support ticket information"
        columns:
          - name: ticket_id
            description: "Unique identifier for each support ticket"
            tests:
              - not_null
              - unique
      - name: bz_billing_events
        description: "Raw billing and financial transaction information"
        columns:
          - name: event_id
            description: "Unique identifier for each billing event"
            tests:
              - not_null
              - unique
      - name: bz_licenses
        description: "Raw license management information"
        columns:
          - name: license_id
            description: "Unique identifier for each license"
            tests:
              - not_null
              - unique
      - name: bz_webinars
        description: "Raw webinar session information"
        columns:
          - name: webinar_id
            description: "Unique identifier for each webinar"
            tests:
              - not_null
              - unique

models:
  - name: audit_log
    description: "Audit log table for Silver layer pipeline execution tracking"
    columns:
      - name: execution_id
        description: "Unique identifier for each pipeline execution"
        tests:
          - not_null
          - unique
      - name: pipeline_name
        description: "Name of the data pipeline or process"
        tests:
          - not_null
      - name: status
        description: "Status of execution"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'STARTED', 'COMPLETED']
      - name: executed_by
        description: "User or system that executed the pipeline"
        tests:
          - not_null
      - name: source_system
        description: "Source system identifier"
        tests:
          - not_null

  - name: si_users
    description: "Silver layer table storing cleaned and standardized user data"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "Standardized full name of the registered user"
        tests:
          - not_null
      - name: email
        description: "Validated and standardized email address"
        tests:
          - not_null
      - name: plan_type
        description: "Standardized subscription tier"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: account_status
        description: "Current status of user account"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        description: "Overall data quality score for the record"
        tests:
          - not_null

  - name: si_meetings
    description: "Silver layer table storing cleaned and enriched meeting data"
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
      - name: meeting_type
        description: "Standardized meeting category"
        tests:
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
      - name: duration_minutes
        description: "Calculated and validated meeting duration"
        tests:
          - not_null
      - name: meeting_status
        description: "Current state of meeting"
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']

  - name: si_participants
    description: "Silver layer table storing cleaned participant attendance data"
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
      - name: participant_role
        description: "Role of attendee"
        tests:
          - accepted_values:
              values: ['Host', 'Participant', 'Observer']
      - name: connection_quality
        description: "Network connection quality during participation"
        tests:
          - accepted_values:
              values: ['Excellent', 'Good', 'Fair', 'Poor']

  - name: si_feature_usage
    description: "Silver layer table storing standardized feature usage data"
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
      - name: feature_category
        description: "Classification of feature type"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']
      - name: usage_count
        description: "Validated number of times feature was utilized"
        tests:
          - not_null

  - name: si_support_tickets
    description: "Silver layer table storing standardized customer support ticket data"
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
              values: ['Low', 'Medium', 'High']
      - name: resolution_status
        description: "Current status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer table storing validated billing and financial transaction data"
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
              values: ['Completed', 'Failed', 'Refunded']
      - name: currency_code
        description: "ISO currency code for the transaction"
        tests:
          - not_null
          - accepted_values:
              values: ['USD']

  - name: si_licenses
    description: "Silver layer table storing validated license assignment and management data"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "Standardized category"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-on']
      - name: license_status
        description: "Current state"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: renewal_status
        description: "Whether license is set for automatic renewal"
        tests:
          - accepted_values:
              values: ['Yes', 'No']

  - name: si_webinars
    description: "Silver layer table storing cleaned webinar data with engagement metrics"
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
      - name: duration_minutes
        description: "Calculated webinar duration in minutes"
        tests:
          - not_null
      - name: registrants
        description: "Number of registered participants"
        tests:
          - not_null
      - name: attendees
        description: "Number of actual attendees who joined"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### tests/test_data_quality_scores.sql
```sql
-- Test that all data quality scores are within valid range (0.00 to 1.00)
SELECT 
    'si_users' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 
    'si_meetings' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 
    'si_participants' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 
    'si_feature_usage' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_feature_usage') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 
    'si_support_tickets' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_support_tickets') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 
    'si_billing_events' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_billing_events') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 
    'si_licenses' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_licenses') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

UNION ALL

SELECT 
    'si_webinars' as table_name,
    COUNT(*) as invalid_scores
FROM {{ ref('si_webinars') }}
WHERE data_quality_score < 0 OR data_quality_score > 1

HAVING invalid_scores > 0
```

#### tests/test_meeting_duration_logic.sql
```sql
-- Test that meeting duration is consistent with start and end times
SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('si_meetings') }}
WHERE ABS(DATEDIFF('minute', start_time, end_time) - duration_minutes) > 1
   OR end_time < start_time
   OR duration_minutes < 0
   OR duration_minutes > 1440
```

#### tests/test_participant_attendance_logic.sql
```sql
-- Test that participant attendance duration is calculated correctly
SELECT 
    participant_id,
    join_time,
    leave_time,
    attendance_duration,
    DATEDIFF('minute', join_time, leave_time) as calculated_duration
FROM {{ ref('si_participants') }}
WHERE leave_time IS NOT NULL
  AND (ABS(DATEDIFF('minute', join_time, leave_time) - attendance_duration) > 1
       OR leave_time < join_time
       OR attendance_duration < 0)
```

#### tests/test_email_format_validation.sql
```sql
-- Test that all email addresses follow valid format
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$')
```

#### tests/test_billing_amount_logic.sql
```sql
-- Test that billing amounts are logical based on event type
SELECT 
    event_id,
    event_type,
    transaction_amount
FROM {{ ref('si_billing_events') }}
WHERE (event_type = 'Refund' AND transaction_amount >= 0)
   OR (event_type != 'Refund' AND transaction_amount <= 0)
   OR transaction_amount IS NULL
```

#### tests/test_webinar_attendance_logic.sql
```sql
-- Test that webinar attendance logic is correct
SELECT 
    webinar_id,
    registrants,
    attendees,
    attendance_rate
FROM {{ ref('si_webinars') }}
WHERE attendees > registrants
   OR (registrants > 0 AND ABS((attendees::FLOAT / registrants * 100) - attendance_rate) > 0.01)
   OR registrants < 0
   OR attendees < 0
   OR attendance_rate < 0
   OR attendance_rate > 100
```

#### tests/test_license_date_logic.sql
```sql
-- Test that license start and end dates are logical
SELECT 
    license_id,
    start_date,
    end_date,
    license_status
FROM {{ ref('si_licenses') }}
WHERE start_date >= end_date
   OR start_date > CURRENT_DATE()
   OR (license_status = 'Active' AND end_date < CURRENT_DATE())
   OR (license_status = 'Expired' AND end_date >= CURRENT_DATE())
```

#### tests/test_feature_usage_validation.sql
```sql
-- Test that feature usage data is valid
SELECT 
    usage_id,
    feature_name,
    usage_count,
    usage_duration,
    feature_category
FROM {{ ref('si_feature_usage') }}
WHERE usage_count < 0
   OR usage_duration < 0
   OR feature_name IS NULL
   OR TRIM(feature_name) = ''
   OR feature_category NOT IN ('Audio', 'Video', 'Collaboration', 'Security')
```

#### tests/test_support_ticket_sla.sql
```sql
-- Test support ticket SLA compliance
SELECT 
    ticket_id,
    priority_level,
    open_date,
    close_date,
    resolution_time_hours
FROM {{ ref('si_support_tickets') }}
WHERE resolution_status = 'Resolved'
  AND (
    (priority_level = 'High' AND resolution_time_hours > 24)
    OR (priority_level = 'Medium' AND resolution_time_hours > 72)
    OR (priority_level = 'Low' AND resolution_time_hours > 168)
    OR resolution_time_hours < 0
    OR (close_date IS NOT NULL AND resolution_time_hours IS NULL)
  )
```

#### tests/test_incremental_processing.sql
```sql
-- Test that incremental processing works correctly
-- This test should be run after an incremental update
WITH latest_run AS (
  SELECT MAX(update_timestamp) as max_update_time
  FROM {{ ref('si_users') }}
),
bronze_updates AS (
  SELECT COUNT(*) as bronze_count
  FROM {{ source('bronze', 'bz_users') }}
  WHERE update_timestamp > (SELECT max_update_time FROM latest_run)
),
silver_updates AS (
  SELECT COUNT(*) as silver_count
  FROM {{ ref('si_users') }}
  WHERE update_timestamp > (SELECT max_update_time FROM latest_run)
)
SELECT 
  bronze_count,
  silver_count,
  CASE 
    WHEN bronze_count != silver_count THEN 'FAIL: Incremental processing mismatch'
    ELSE 'PASS: Incremental processing working correctly'
  END as test_result
FROM bronze_updates, silver_updates
WHERE bronze_count != silver_count
```

### Parameterized Tests

#### macros/test_referential_integrity.sql
```sql
{% macro test_referential_integrity(model, column_name, to_model, to_column) %}
  SELECT 
    {{ column_name }} as orphaned_key,
    COUNT(*) as orphaned_count
  FROM {{ model }}
  WHERE {{ column_name }} IS NOT NULL
    AND {{ column_name }} NOT IN (
      SELECT {{ to_column }}
      FROM {{ to_model }}
      WHERE {{ to_column }} IS NOT NULL
    )
  GROUP BY {{ column_name }}
  HAVING COUNT(*) > 0
{% endmacro %}
```

#### macros/test_data_freshness.sql
```sql
{% macro test_data_freshness(model, timestamp_column, max_age_hours=24) %}
  SELECT 
    COUNT(*) as stale_records
  FROM {{ model }}
  WHERE {{ timestamp_column }} < CURRENT_TIMESTAMP() - INTERVAL '{{ max_age_hours }} HOURS'
  HAVING COUNT(*) > 0
{% endmacro %}
```

#### macros/test_completeness.sql
```sql
{% macro test_completeness(model, required_columns) %}
  SELECT 
    'completeness_check' as test_type,
    {% for column in required_columns %}
    SUM(CASE WHEN {{ column }} IS NULL THEN 1 ELSE 0 END) as {{ column }}_nulls
    {%- if not loop.last -%},{%- endif -%}
    {% endfor %}
  FROM {{ model }}
  HAVING {% for column in required_columns %}
    {{ column }}_nulls > 0
    {%- if not loop.last %} OR {% endif -%}
  {% endfor %}
{% endmacro %}
```

### Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users

# Run specific test
dbt test --select test_data_quality_scores

# Run tests with specific tag
dbt test --select tag:data_quality

# Run tests in fail-fast mode
dbt test --fail-fast

# Generate test documentation
dbt docs generate
dbt docs serve
```

### Test Results Tracking

Test results are automatically tracked in:
- **dbt's run_results.json**: Contains detailed test execution results
- **Snowflake audit schema**: Custom logging for test results
- **SI_DATA_QUALITY_ERRORS table**: Failed test records for investigation
- **SI_PIPELINE_AUDIT table**: Overall pipeline execution status

### Performance Considerations

1. **Test Optimization**:
   - Use `LIMIT` clauses for large datasets during development
   - Implement sampling for performance-intensive tests
   - Schedule heavy tests during off-peak hours

2. **Snowflake-Specific Optimizations**:
   - Leverage clustering keys for test queries
   - Use appropriate warehouse sizes for test execution
   - Implement result caching where applicable

3. **Incremental Testing**:
   - Focus tests on incremental data changes
   - Use time-based partitioning for test efficiency
   - Implement delta testing for large tables

### Monitoring and Alerting

1. **Test Failure Notifications**:
   - Configure email alerts for critical test failures
   - Set up Slack notifications for team awareness
   - Implement escalation procedures for persistent failures

2. **Test Performance Monitoring**:
   - Track test execution times
   - Monitor resource usage during test runs
   - Identify and optimize slow-running tests

3. **Data Quality Dashboards**:
   - Create visualizations for test results trends
   - Implement data quality scorecards
   - Provide business stakeholder reporting

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver layer dbt models in the Snowflake environment.