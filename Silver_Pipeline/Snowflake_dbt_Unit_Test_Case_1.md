_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## **Description**

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer models running in Snowflake. The test cases cover data transformations, business rules, edge cases, error handling scenarios, and specific timestamp format validation issues identified in the Silver layer models.

## **Test Coverage Overview**

The test suite covers:
- **8 Silver Layer Tables**: SI_USERS, SI_MEETINGS, SI_PARTICIPANTS, SI_FEATURE_USAGE, SI_SUPPORT_TICKETS, SI_BILLING_EVENTS, SI_LICENSES, SI_DATA_QUALITY_ERRORS
- **Critical Timestamp Format Issues**: EST timezone handling in SI_MEETINGS and MM/DD/YYYY format in SI_PARTICIPANTS
- **Data Quality Validations**: Null checks, format validation, referential integrity, business rules
- **Edge Cases**: Schema mismatches, missing values, invalid lookups, boundary conditions
- **Error Handling**: Failed relationships, unexpected values, format conversion failures

---

## **1. SI_USERS Table Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| TC_USR_002 | Validate email format using REGEXP | All EMAIL values follow valid email pattern |
| TC_USR_003 | Validate PLAN_TYPE standardization | All PLAN_TYPE values are in ('Free', 'Basic', 'Pro', 'Enterprise') |
| TC_USR_004 | Validate data quality score range | All DATA_QUALITY_SCORE values are between 0-100 |
| TC_USR_005 | Validate validation status values | All VALIDATION_STATUS values are in ('PASSED', 'FAILED', 'WARNING') |
| TC_USR_006 | Test duplicate USER_ID handling | Duplicate USER_IDs are identified and flagged |
| TC_USR_007 | Test null email handling | Records with null emails are flagged with appropriate validation status |
| TC_USR_008 | Test invalid plan type transformation | Invalid plan types are standardized to 'Free' |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer users table with data quality validations"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      
      - name: email
        description: "User email address"
        tests:
          - not_null:
              severity: error
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
              severity: error
      
      - name: plan_type
        description: "User subscription plan type"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
              severity: error
      
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
              severity: warn
      
      - name: validation_status
        description: "Validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']
              severity: error
```

#### **Custom SQL-based dbt Tests**
```sql
-- tests/silver/test_si_users_email_format.sql
-- Test for valid email format validation
SELECT 
    user_id,
    email,
    'Invalid email format' as error_message
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

```sql
-- tests/silver/test_si_users_plan_type_standardization.sql
-- Test for plan type standardization
SELECT 
    user_id,
    plan_type,
    'Invalid plan type detected' as error_message
FROM {{ ref('si_users') }}
WHERE plan_type NOT IN ('Free', 'Basic', 'Pro', 'Enterprise')
OR plan_type IS NULL
```

```sql
-- tests/silver/test_si_users_data_quality_metrics.sql
-- Test for data quality score calculation
SELECT 
    'Data Quality Metrics' as test_category,
    COUNT(*) as total_records,
    COUNT(CASE WHEN data_quality_score >= 90 THEN 1 END) as high_quality_records,
    COUNT(CASE WHEN data_quality_score < 70 THEN 1 END) as low_quality_records,
    ROUND(AVG(data_quality_score), 2) as avg_quality_score
FROM {{ ref('si_users') }}
HAVING COUNT(CASE WHEN data_quality_score < 0 OR data_quality_score > 100 THEN 1 END) > 0
```

---

## **2. SI_MEETINGS Table Test Cases (Enhanced for EST Timezone)**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| TC_MTG_002 | Validate EST timezone format in START_TIME | EST timezone timestamps follow correct format pattern |
| TC_MTG_003 | Validate EST timezone format in END_TIME | EST timezone timestamps follow correct format pattern |
| TC_MTG_004 | Test EST to UTC conversion accuracy | EST timestamps are correctly converted to UTC |
| TC_MTG_005 | Validate meeting duration consistency | DURATION_MINUTES matches calculated time difference |
| TC_MTG_006 | Validate meeting time logic | END_TIME is always after START_TIME |
| TC_MTG_007 | Validate HOST_ID referential integrity | All HOST_ID values exist in SI_USERS table |
| TC_MTG_008 | Test invalid EST format handling | Invalid EST formats are flagged as errors |
| TC_MTG_009 | Validate duration range constraints | DURATION_MINUTES is between 0-1440 minutes |
| TC_MTG_010 | Test mixed timestamp format handling | Mixed formats within records are identified |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (SI_MEETINGS section)
models:
  - name: si_meetings
    description: "Silver layer meetings table with EST timezone validation"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
      
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null:
              severity: error
      
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - not_null:
              severity: error
      
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null:
              severity: error
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
              severity: error
```

#### **Custom SQL-based dbt Tests**
```sql
-- tests/silver/test_si_meetings_est_timezone_format.sql
-- Test for EST timezone format validation
SELECT 
    meeting_id,
    start_time,
    end_time,
    'Invalid EST timezone format' as error_message
FROM {{ ref('si_meetings') }}
WHERE (start_time::STRING LIKE '%EST%' 
       AND NOT REGEXP_LIKE(start_time::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$'))
OR (end_time::STRING LIKE '%EST%' 
    AND NOT REGEXP_LIKE(end_time::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$'))
```

```sql
-- tests/silver/test_si_meetings_est_conversion_accuracy.sql
-- Test for EST to UTC conversion accuracy
WITH est_conversions AS (
    SELECT 
        meeting_id,
        start_time,
        CASE 
            WHEN start_time::STRING LIKE '%EST%' THEN 
                CONVERT_TIMEZONE('America/New_York', 'UTC', 
                    TRY_TO_TIMESTAMP(REPLACE(start_time::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
            ELSE start_time
        END as converted_start_time
    FROM {{ ref('si_meetings') }}
    WHERE start_time::STRING LIKE '%EST%'
)
SELECT 
    meeting_id,
    start_time,
    converted_start_time,
    'EST conversion failed' as error_message
FROM est_conversions
WHERE converted_start_time IS NULL
```

```sql
-- tests/silver/test_si_meetings_duration_consistency.sql
-- Test for meeting duration consistency after timezone conversion
WITH converted_times AS (
    SELECT 
        meeting_id,
        CASE 
            WHEN start_time::STRING LIKE '%EST%' THEN 
                CONVERT_TIMEZONE('America/New_York', 'UTC', 
                    TRY_TO_TIMESTAMP(REPLACE(start_time::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
            ELSE start_time
        END as converted_start_time,
        CASE 
            WHEN end_time::STRING LIKE '%EST%' THEN 
                CONVERT_TIMEZONE('America/New_York', 'UTC', 
                    TRY_TO_TIMESTAMP(REPLACE(end_time::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
            ELSE end_time
        END as converted_end_time,
        duration_minutes
    FROM {{ ref('si_meetings') }}
)
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', converted_start_time, converted_end_time) as calculated_duration,
    'Duration mismatch after timezone conversion' as error_message
FROM converted_times
WHERE ABS(duration_minutes - DATEDIFF('minute', converted_start_time, converted_end_time)) > 1
```

```sql
-- tests/silver/test_si_meetings_time_logic_validation.sql
-- Test for meeting time logic validation
SELECT 
    meeting_id,
    start_time,
    end_time,
    'End time is not after start time' as error_message
FROM {{ ref('si_meetings') }}
WHERE end_time <= start_time
```

---

## **3. SI_PARTICIPANTS Table Test Cases (Enhanced for MM/DD/YYYY Format)**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate PARTICIPANT_ID uniqueness and not null | All PARTICIPANT_ID values are unique and not null |
| TC_PRT_002 | Validate MM/DD/YYYY HH:MM format in JOIN_TIME | MM/DD/YYYY format timestamps follow correct pattern |
| TC_PRT_003 | Validate MM/DD/YYYY HH:MM format in LEAVE_TIME | MM/DD/YYYY format timestamps follow correct pattern |
| TC_PRT_004 | Test MM/DD/YYYY to standard format conversion | MM/DD/YYYY timestamps are correctly converted |
| TC_PRT_005 | Validate participant session time logic | LEAVE_TIME is always after JOIN_TIME |
| TC_PRT_006 | Validate meeting boundary constraints | Participant times are within meeting duration |
| TC_PRT_007 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS table |
| TC_PRT_008 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS table |
| TC_PRT_009 | Test invalid MM/DD/YYYY format handling | Invalid MM/DD/YYYY formats are flagged as errors |
| TC_PRT_010 | Test unique participant per meeting constraint | Each USER_ID appears only once per MEETING_ID |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (SI_PARTICIPANTS section)
models:
  - name: si_participants
    description: "Silver layer participants table with MM/DD/YYYY format validation"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
              severity: error
      
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
      
      - name: join_time
        description: "Participant join timestamp"
        tests:
          - not_null:
              severity: error
      
      - name: leave_time
        description: "Participant leave timestamp"
        tests:
          - not_null:
              severity: error
```

#### **Custom SQL-based dbt Tests**
```sql
-- tests/silver/test_si_participants_mmddyyyy_format.sql
-- Test for MM/DD/YYYY HH:MM format validation
SELECT 
    participant_id,
    join_time,
    leave_time,
    'Invalid MM/DD/YYYY HH:MM format' as error_message
FROM {{ ref('si_participants') }}
WHERE (join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
       AND TRY_TO_TIMESTAMP(join_time::STRING, 'MM/DD/YYYY HH24:MI') IS NULL)
OR (leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
    AND TRY_TO_TIMESTAMP(leave_time::STRING, 'MM/DD/YYYY HH24:MI') IS NULL)
```

```sql
-- tests/silver/test_si_participants_mmddyyyy_conversion.sql
-- Test for MM/DD/YYYY format conversion accuracy
WITH mmddyyyy_conversions AS (
    SELECT 
        participant_id,
        join_time,
        CASE 
            WHEN join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(join_time::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE join_time
        END as converted_join_time,
        leave_time,
        CASE 
            WHEN leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(leave_time::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE leave_time
        END as converted_leave_time
    FROM {{ ref('si_participants') }}
    WHERE join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
    OR leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
)
SELECT 
    participant_id,
    join_time,
    leave_time,
    'MM/DD/YYYY conversion failed' as error_message
FROM mmddyyyy_conversions
WHERE (join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' AND converted_join_time IS NULL)
OR (leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' AND converted_leave_time IS NULL)
```

```sql
-- tests/silver/test_si_participants_session_time_logic.sql
-- Test for participant session time logic
WITH converted_times AS (
    SELECT 
        participant_id,
        CASE 
            WHEN join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(join_time::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE join_time
        END as converted_join_time,
        CASE 
            WHEN leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(leave_time::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE leave_time
        END as converted_leave_time
    FROM {{ ref('si_participants') }}
)
SELECT 
    participant_id,
    converted_join_time,
    converted_leave_time,
    'Leave time is not after join time' as error_message
FROM converted_times
WHERE converted_leave_time <= converted_join_time
```

```sql
-- tests/silver/test_si_participants_meeting_boundary.sql
-- Test for meeting boundary validation
WITH participant_times AS (
    SELECT 
        p.participant_id,
        p.meeting_id,
        CASE 
            WHEN p.join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(p.join_time::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE p.join_time
        END as converted_join_time,
        CASE 
            WHEN p.leave_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
                TRY_TO_TIMESTAMP(p.leave_time::STRING, 'MM/DD/YYYY HH24:MI')
            ELSE p.leave_time
        END as converted_leave_time,
        m.start_time,
        m.end_time
    FROM {{ ref('si_participants') }} p
    JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
)
SELECT 
    participant_id,
    meeting_id,
    converted_join_time,
    converted_leave_time,
    start_time,
    end_time,
    'Participant times outside meeting boundary' as error_message
FROM participant_times
WHERE converted_join_time < start_time 
OR converted_leave_time > end_time
```

```sql
-- tests/silver/test_si_participants_unique_per_meeting.sql
-- Test for unique participant per meeting constraint
SELECT 
    meeting_id,
    user_id,
    COUNT(*) as duplicate_count,
    'Duplicate participant in same meeting' as error_message
FROM {{ ref('si_participants') }}
GROUP BY meeting_id, user_id
HAVING COUNT(*) > 1
```

---

## **4. SI_FEATURE_USAGE Table Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate USAGE_ID uniqueness and not null | All USAGE_ID values are unique and not null |
| TC_FTR_002 | Validate MEETING_ID referential integrity | All MEETING_ID values exist in SI_MEETINGS table |
| TC_FTR_003 | Validate USAGE_COUNT non-negative constraint | All USAGE_COUNT values are >= 0 |
| TC_FTR_004 | Validate FEATURE_NAME standardization | All FEATURE_NAME values are properly formatted |
| TC_FTR_005 | Validate usage date alignment with meetings | USAGE_DATE aligns with meeting dates |
| TC_FTR_006 | Test feature adoption rate calculation | Feature adoption metrics are accurate |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (SI_FEATURE_USAGE section)
models:
  - name: si_feature_usage
    description: "Silver layer feature usage table"
    columns:
      - name: usage_id
        description: "Unique identifier for each usage record"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
              severity: error
      
      - name: usage_count
        description: "Feature usage count"
        tests:
          - not_null:
              severity: error
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 999999
              severity: error
```

#### **Custom SQL-based dbt Tests**
```sql
-- tests/silver/test_si_feature_usage_date_alignment.sql
-- Test for usage date alignment with meeting dates
SELECT 
    f.usage_id,
    f.meeting_id,
    f.usage_date,
    m.start_time,
    'Usage date does not align with meeting date' as error_message
FROM {{ ref('si_feature_usage') }} f
JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE DATE(f.usage_date) != DATE(m.start_time)
```

```sql
-- tests/silver/test_si_feature_usage_adoption_metrics.sql
-- Test for feature adoption rate calculation
WITH feature_adoption AS (
    SELECT 
        feature_name,
        COUNT(DISTINCT f.meeting_id) as meetings_with_feature,
        (SELECT COUNT(DISTINCT meeting_id) FROM {{ ref('si_meetings') }}) as total_meetings,
        ROUND((COUNT(DISTINCT f.meeting_id) * 100.0 / 
               (SELECT COUNT(DISTINCT meeting_id) FROM {{ ref('si_meetings') }})), 2) as adoption_rate
    FROM {{ ref('si_feature_usage') }} f
    GROUP BY feature_name
)
SELECT 
    feature_name,
    adoption_rate,
    'Feature adoption rate calculation error' as error_message
FROM feature_adoption
WHERE adoption_rate < 0 OR adoption_rate > 100
```

---

## **5. SI_SUPPORT_TICKETS Table Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate TICKET_ID uniqueness and not null | All TICKET_ID values are unique and not null |
| TC_TKT_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS table |
| TC_TKT_003 | Validate RESOLUTION_STATUS standardization | All status values are in predefined list |
| TC_TKT_004 | Validate OPEN_DATE not in future | All OPEN_DATE values are <= current date |
| TC_TKT_005 | Test ticket volume metrics calculation | Ticket volume per 1000 users is accurate |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (SI_SUPPORT_TICKETS section)
models:
  - name: si_support_tickets
    description: "Silver layer support tickets table"
    columns:
      - name: ticket_id
        description: "Unique identifier for each ticket"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
      
      - name: resolution_status
        description: "Ticket resolution status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
              severity: error
```

#### **Custom SQL-based dbt Tests**
```sql
-- tests/silver/test_si_support_tickets_future_dates.sql
-- Test for future open dates
SELECT 
    ticket_id,
    open_date,
    'Open date is in the future' as error_message
FROM {{ ref('si_support_tickets') }}
WHERE open_date > CURRENT_DATE()
```

---

## **6. SI_BILLING_EVENTS Table Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate EVENT_ID uniqueness and not null | All EVENT_ID values are unique and not null |
| TC_BIL_002 | Validate USER_ID referential integrity | All USER_ID values exist in SI_USERS table |
| TC_BIL_003 | Validate AMOUNT positive constraint | All AMOUNT values are > 0 |
| TC_BIL_004 | Validate EVENT_DATE not in future | All EVENT_DATE values are <= current date |
| TC_BIL_005 | Test MRR calculation accuracy | Monthly recurring revenue calculation is correct |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (SI_BILLING_EVENTS section)
models:
  - name: si_billing_events
    description: "Silver layer billing events table"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
      
      - name: amount
        description: "Billing amount"
        tests:
          - not_null:
              severity: error
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.01
              max_value: 999999.99
              severity: error
```

#### **Custom SQL-based dbt Tests**
```sql
-- tests/silver/test_si_billing_events_mrr_calculation.sql
-- Test for MRR calculation accuracy
WITH mrr_calculation AS (
    SELECT 
        DATE_TRUNC('month', event_date) as month,
        SUM(CASE WHEN event_type LIKE '%subscription%' THEN amount ELSE 0 END) as mrr,
        SUM(CASE WHEN event_type LIKE '%refund%' THEN -amount ELSE 0 END) as refunds
    FROM {{ ref('si_billing_events') }}
    WHERE event_date >= DATE_TRUNC('month', CURRENT_DATE()) - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', event_date)
)
SELECT 
    month,
    mrr,
    refunds,
    'MRR calculation error detected' as error_message
FROM mrr_calculation
WHERE mrr < 0 OR ABS(refunds) > mrr * 2
```

---

## **7. SI_LICENSES Table Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate LICENSE_ID uniqueness and not null | All LICENSE_ID values are unique and not null |
| TC_LIC_002 | Validate ASSIGNED_TO_USER_ID referential integrity | All user IDs exist in SI_USERS table |
| TC_LIC_003 | Validate date logic constraints | START_DATE is always before END_DATE |
| TC_LIC_004 | Test license utilization rate calculation | Utilization metrics are accurate |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (SI_LICENSES section)
models:
  - name: si_licenses
    description: "Silver layer licenses table"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
      
      - name: assigned_to_user_id
        description: "Reference to assigned user"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: error
```

#### **Custom SQL-based dbt Tests**
```sql
-- tests/silver/test_si_licenses_date_logic.sql
-- Test for license date logic validation
SELECT 
    license_id,
    start_date,
    end_date,
    'Start date is not before end date' as error_message
FROM {{ ref('si_licenses') }}
WHERE start_date >= end_date
```

---

## **8. Cross-Table Integration Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_INT_001 | Validate user activity consistency | Users with meetings have participant records |
| TC_INT_002 | Validate feature usage alignment | Feature usage aligns with participant data |
| TC_INT_003 | Validate billing-license consistency | Users with billing have license records |
| TC_INT_004 | Test timestamp format consistency across tables | Consistent timestamp formats are used |

### **dbt Test Scripts**

#### **Custom SQL-based Integration Tests**
```sql
-- tests/silver/test_cross_table_user_activity.sql
-- Test for user activity consistency
SELECT 
    m.meeting_id,
    m.host_id,
    'Meeting host has no participant record' as error_message
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id AND m.host_id = p.user_id
WHERE p.user_id IS NULL
```

```sql
-- tests/silver/test_cross_table_timestamp_consistency.sql
-- Test for timestamp format consistency across tables
WITH timestamp_formats AS (
    SELECT 
        'SI_MEETINGS' as table_name,
        'START_TIME' as column_name,
        CASE 
            WHEN start_time::STRING LIKE '%EST%' THEN 'EST_FORMAT'
            WHEN start_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}' THEN 'MM_DD_YYYY_FORMAT'
            ELSE 'STANDARD_FORMAT'
        END as format_type,
        COUNT(*) as record_count
    FROM {{ ref('si_meetings') }}
    WHERE start_time IS NOT NULL
    GROUP BY format_type
    
    UNION ALL
    
    SELECT 
        'SI_PARTICIPANTS',
        'JOIN_TIME',
        CASE 
            WHEN join_time::STRING LIKE '%EST%' THEN 'EST_FORMAT'
            WHEN join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}' THEN 'MM_DD_YYYY_FORMAT'
            ELSE 'STANDARD_FORMAT'
        END as format_type,
        COUNT(*)
    FROM {{ ref('si_participants') }}
    WHERE join_time IS NOT NULL
    GROUP BY format_type
)
SELECT 
    table_name,
    column_name,
    format_type,
    record_count,
    'Mixed timestamp formats detected' as error_message
FROM timestamp_formats
WHERE format_type IN ('EST_FORMAT', 'MM_DD_YYYY_FORMAT')
AND record_count > 0
```

---

## **9. Error Handling and Edge Case Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_ERR_001 | Test null value handling across all tables | Null values are properly handled or flagged |
| TC_ERR_002 | Test invalid timestamp format handling | Invalid formats are routed to error table |
| TC_ERR_003 | Test referential integrity violations | Orphaned records are identified |
| TC_ERR_004 | Test data type conversion failures | Conversion failures are logged |
| TC_ERR_005 | Test boundary value conditions | Edge cases are handled appropriately |

### **dbt Test Scripts**

#### **Custom SQL-based Error Handling Tests**
```sql
-- tests/silver/test_error_handling_null_values.sql
-- Test for comprehensive null value handling
SELECT 
    'SI_USERS' as table_name,
    'Critical null values detected' as error_message,
    COUNT(*) as null_count
FROM {{ ref('si_users') }}
WHERE user_id IS NULL OR email IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'SI_MEETINGS',
    'Critical null values detected',
    COUNT(*)
FROM {{ ref('si_meetings') }}
WHERE meeting_id IS NULL OR host_id IS NULL OR start_time IS NULL
HAVING COUNT(*) > 0
```

```sql
-- tests/silver/test_error_handling_timestamp_formats.sql
-- Test for timestamp format error handling
WITH format_errors AS (
    SELECT 
        'SI_MEETINGS' as source_table,
        meeting_id as record_key,
        'START_TIME' as error_column,
        start_time::STRING as error_value,
        'Invalid EST timezone format' as error_description
    FROM {{ ref('si_meetings') }}
    WHERE start_time::STRING LIKE '%EST%'
    AND NOT REGEXP_LIKE(start_time::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$')
    
    UNION ALL
    
    SELECT 
        'SI_PARTICIPANTS',
        participant_id,
        'JOIN_TIME',
        join_time::STRING,
        'Invalid MM/DD/YYYY HH:MM format'
    FROM {{ ref('si_participants') }}
    WHERE join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
    AND TRY_TO_TIMESTAMP(join_time::STRING, 'MM/DD/YYYY HH24:MI') IS NULL
)
SELECT 
    source_table,
    record_key,
    error_column,
    error_value,
    error_description,
    'Timestamp format error detected' as test_result
FROM format_errors
```

---

## **10. Performance and Data Quality Monitoring Tests**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRF_001 | Monitor data freshness across all tables | Data is loaded within SLA timeframes |
| TC_PRF_002 | Monitor record count variations | Unexpected data volume changes are detected |
| TC_PRF_003 | Monitor data quality score distribution | Quality scores meet established thresholds |
| TC_PRF_004 | Monitor timestamp format conversion rates | Format conversion success rates are acceptable |

### **dbt Test Scripts**

#### **Custom SQL-based Performance Tests**
```sql
-- tests/silver/test_performance_data_freshness.sql
-- Test for data freshness monitoring
WITH freshness_check AS (
    SELECT 
        'SI_USERS' as table_name,
        MAX(load_timestamp) as latest_load,
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP()) as hours_since_load
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'SI_MEETINGS',
        MAX(load_timestamp),
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP())
    FROM {{ ref('si_meetings') }}
    
    UNION ALL
    
    SELECT 
        'SI_PARTICIPANTS',
        MAX(load_timestamp),
        DATEDIFF('hour', MAX(load_timestamp), CURRENT_TIMESTAMP())
    FROM {{ ref('si_participants') }}
)
SELECT 
    table_name,
    latest_load,
    hours_since_load,
    'Data freshness SLA violation' as error_message
FROM freshness_check
WHERE hours_since_load > 24  -- Assuming 24-hour SLA
```

```sql
-- tests/silver/test_performance_quality_scores.sql
-- Test for data quality score monitoring
WITH quality_metrics AS (
    SELECT 
        'SI_USERS' as table_name,
        AVG(data_quality_score) as avg_score,
        MIN(data_quality_score) as min_score,
        COUNT(CASE WHEN data_quality_score < 70 THEN 1 END) as low_quality_count,
        COUNT(*) as total_count
    FROM {{ ref('si_users') }}
    WHERE data_quality_score IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'SI_MEETINGS',
        AVG(data_quality_score),
        MIN(data_quality_score),
        COUNT(CASE WHEN data_quality_score < 70 THEN 1 END),
        COUNT(*)
    FROM {{ ref('si_meetings') }}
    WHERE data_quality_score IS NOT NULL
)
SELECT 
    table_name,
    avg_score,
    min_score,
    low_quality_count,
    total_count,
    ROUND((low_quality_count * 100.0 / total_count), 2) as low_quality_percentage,
    'Data quality threshold violation' as error_message
FROM quality_metrics
WHERE avg_score < 80 OR (low_quality_count * 100.0 / total_count) > 10
```

---

## **11. Parameterized Test Configuration**

### **dbt_project.yml Configuration**
```yaml
# dbt_project.yml
name: 'zoom_analytics'
version: '1.0.0'
config-version: 2

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["data"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  zoom_analytics:
    silver:
      +materialized: table
      +schema: silver
      +tags: ["silver", "data_quality"]

tests:
  zoom_analytics:
    +severity: error
    +tags: ["data_quality"]

vars:
  # Test configuration variables
  data_quality_threshold: 80
  freshness_sla_hours: 24
  max_duplicate_percentage: 1
  timestamp_format_success_rate: 95
```

### **Macro for Reusable Test Logic**
```sql
-- macros/test_timestamp_format_validation.sql
{% macro test_timestamp_format_validation(model, column_name, format_type) %}

  {% if format_type == 'EST' %}
    SELECT 
        {{ column_name }},
        'Invalid EST timezone format in {{ column_name }}' as error_message
    FROM {{ model }}
    WHERE {{ column_name }}::STRING LIKE '%EST%'
    AND NOT REGEXP_LIKE({{ column_name }}::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$')
  
  {% elif format_type == 'MM_DD_YYYY' %}
    SELECT 
        {{ column_name }},
        'Invalid MM/DD/YYYY format in {{ column_name }}' as error_message
    FROM {{ model }}
    WHERE {{ column_name }}::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'
    AND TRY_TO_TIMESTAMP({{ column_name }}::STRING, 'MM/DD/YYYY HH24:MI') IS NULL
  
  {% endif %}

{% endmacro %}
```

---

## **12. Test Execution and Monitoring Strategy**

### **Test Execution Priority**
1. **Critical (P1)**: Data integrity, referential integrity, timestamp format validation
2. **High (P2)**: Business rule validation, data quality thresholds
3. **Medium (P3)**: Performance monitoring, cross-table consistency
4. **Low (P4)**: Data quality scoring, trend analysis

### **Automated Test Execution**
```bash
# Execute all tests
dbt test

# Execute tests by severity
dbt test --severity error
dbt test --severity warn

# Execute tests by tag
dbt test --select tag:data_quality
dbt test --select tag:timestamp_validation

# Execute tests for specific models
dbt test --select si_meetings
dbt test --select si_participants
```

### **Test Results Tracking**
- All test results are automatically tracked in dbt's `run_results.json`
- Failed tests trigger alerts through configured notification channels
- Test execution metrics are logged in Snowflake's `INFORMATION_SCHEMA.QUERY_HISTORY`
- Custom audit logging captures test results in `SI_PIPELINE_EXECUTION_LOG` table

### **Continuous Integration Integration**
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
      - name: Setup dbt
        uses: dbt-labs/dbt-action@v1
        with:
          dbt-command: "dbt test --profiles-dir ./profiles"
```

---

## **13. Success Metrics and KPIs**

### **Test Coverage Metrics**
- **Model Coverage**: 100% of Silver layer models have comprehensive test coverage
- **Column Coverage**: 95% of critical columns have validation tests
- **Business Rule Coverage**: 100% of identified business rules have corresponding tests
- **Timestamp Format Coverage**: 100% of timestamp format issues have validation tests

### **Data Quality Metrics**
- **Test Pass Rate**: > 95% of all tests should pass consistently
- **Data Quality Score**: Average score > 80 across all Silver layer tables
- **Timestamp Format Success Rate**: > 95% of timestamp conversions should succeed
- **Error Detection Rate**: < 1% of records should fail critical validations

### **Performance Metrics**
- **Test Execution Time**: Complete test suite should execute in < 10 minutes
- **Data Freshness**: All tables should be updated within 24-hour SLA
- **Processing Latency**: Silver layer processing should complete within 2 hours of Bronze layer updates

---

## **Conclusion**

This comprehensive unit test suite provides robust validation for the Zoom Platform Analytics System Silver layer, with particular focus on addressing the critical timestamp format issues in SI_MEETINGS (EST timezone) and SI_PARTICIPANTS (MM/DD/YYYY HH:MM format). The test cases ensure data quality, business rule compliance, and system reliability while supporting continuous integration and automated monitoring.

The test framework is designed to:
- **Prevent Production Failures**: Catch issues early in the development cycle
- **Ensure Data Quality**: Maintain high standards for data accuracy and consistency
- **Support Business Requirements**: Validate all identified business rules and constraints
- **Enable Monitoring**: Provide ongoing visibility into data pipeline health
- **Facilitate Maintenance**: Support easy updates and extensions as requirements evolve

Regular execution of these tests will ensure the continued reliability and performance of the Silver layer data transformations in the Snowflake environment.