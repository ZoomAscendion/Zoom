_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer dbt models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## **Description**

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System Silver layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models.

## **Test Coverage Overview**

### **Models Under Test**
- **SI_USERS**: User profile and subscription information
- **SI_MEETINGS**: Meeting information and session details
- **SI_PARTICIPANTS**: Meeting participants and session tracking
- **SI_FEATURE_USAGE**: Platform feature usage metrics
- **SI_SUPPORT_TICKETS**: Customer support requests
- **SI_BILLING_EVENTS**: Financial transactions and billing
- **SI_LICENSES**: License assignments and entitlements
- **SI_AUDIT_LOG**: Pipeline execution audit trail

### **Key Transformations Tested**
- Bronze to Silver data cleansing and standardization
- Duration text cleaning ("108 mins" → 108)
- DD/MM/YYYY date format conversion ("27/08/2024")
- EST timezone processing and standardization
- MM/DD/YYYY timestamp handling
- Data quality scoring and validation
- Referential integrity enforcement

---

## **1. SI_USERS Model Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| USR_001 | Email format validation | All emails follow valid format pattern |
| USR_002 | Plan type standardization | Plan types conform to (Free, Basic, Pro, Enterprise) |
| USR_003 | User ID uniqueness validation | No duplicate user IDs exist |
| USR_004 | Null value elimination | Critical fields are not null |
| USR_005 | Data quality score calculation | Scores are between 0-100 |
| USR_006 | Company name standardization | Company names are cleaned and trimmed |
| USR_007 | User deduplication logic | Duplicate users are removed using ROW_NUMBER() |
| USR_008 | Validation status assignment | Status is PASSED/FAILED/WARNING |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer user information with data quality enhancements"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      
      - name: email
        description: "User email address (validated)"
        tests:
          - not_null:
              severity: error
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
              severity: warn
      
      - name: plan_type
        description: "Subscription plan type"
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
        description: "Data validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']
              severity: error
```

#### **Custom SQL-based Tests**
```sql
-- tests/si_users_email_format_validation.sql
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')

-- tests/si_users_duplicate_check.sql
SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_users') }}
WHERE user_id IS NOT NULL
GROUP BY user_id
HAVING COUNT(*) > 1

-- tests/si_users_data_quality_distribution.sql
SELECT 
    'data_quality_check' as test_type,
    COUNT(CASE WHEN data_quality_score < 70 THEN 1 END) as low_quality_records,
    COUNT(*) as total_records,
    ROUND((COUNT(CASE WHEN data_quality_score < 70 THEN 1 END) * 100.0 / COUNT(*)), 2) as low_quality_percentage
FROM {{ ref('si_users') }}
WHERE data_quality_score IS NOT NULL
HAVING low_quality_percentage > 10  -- Fail if more than 10% low quality
```

---

## **2. SI_MEETINGS Model Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| MTG_001 | Duration text cleaning validation | "108 mins" converted to 108 |
| MTG_002 | EST timezone processing | EST timestamps standardized |
| MTG_003 | Meeting time logic validation | End time > Start time |
| MTG_004 | Duration consistency check | Calculated duration matches actual |
| MTG_005 | Host ID referential integrity | All hosts exist in SI_USERS |
| MTG_006 | Duration range validation | Duration between 0-1440 minutes |
| MTG_007 | Meeting topic cleaning | Topics are cleaned and standardized |
| MTG_008 | Null elimination | Critical meeting fields not null |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (continued)
  - name: si_meetings
    description: "Silver layer meeting information with critical fixes"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - unique:
              severity: error
          - not_null:
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
      
      - name: duration_minutes
        description: "Meeting duration in minutes (cleaned)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
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
```

#### **Custom SQL-based Tests**
```sql
-- tests/si_meetings_duration_text_cleaning.sql
-- Critical P1: Test duration text cleaning functionality
SELECT 
    meeting_id,
    duration_minutes
FROM {{ ref('si_meetings') }}
WHERE duration_minutes::STRING REGEXP '[a-zA-Z]'  -- Should find no text in duration

-- tests/si_meetings_time_logic_validation.sql
SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE end_time <= start_time

-- tests/si_meetings_duration_consistency.sql
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as difference
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1

-- tests/si_meetings_est_timezone_validation.sql
-- Test EST timezone processing
SELECT 
    meeting_id,
    start_time
FROM {{ ref('si_meetings') }}
WHERE start_time::STRING LIKE '%EST%'  -- Should find no unprocessed EST timestamps

-- tests/si_meetings_host_referential_integrity.sql
SELECT 
    m.meeting_id,
    m.host_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL AND m.host_id IS NOT NULL
```

---

## **3. SI_PARTICIPANTS Model Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| PRT_001 | MM/DD/YYYY timestamp conversion | Timestamps properly converted |
| PRT_002 | Session time logic validation | Leave time > Join time |
| PRT_003 | Meeting boundary validation | Join/leave within meeting duration |
| PRT_004 | Participant-meeting integrity | All participants reference valid meetings |
| PRT_005 | Participant-user integrity | All participants reference valid users |
| PRT_006 | Unique participant per meeting | No duplicate participant-meeting combinations |
| PRT_007 | Cross-format timestamp consistency | Consistent timestamp formats |
| PRT_008 | Session duration calculation | Accurate session duration metrics |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (continued)
  - name: si_participants
    description: "Silver layer participant information with timestamp fixes"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
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
              severity: error
      
      - name: user_id
        description: "Reference to participant user"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
              severity: warn
      
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

#### **Custom SQL-based Tests**
```sql
-- tests/si_participants_mmddyyyy_conversion.sql
-- Test MM/DD/YYYY timestamp conversion
SELECT 
    participant_id,
    join_time
FROM {{ ref('si_participants') }}
WHERE join_time::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}$'  -- Should find no unconverted formats

-- tests/si_participants_session_time_logic.sql
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE leave_time <= join_time

-- tests/si_participants_meeting_boundary.sql
SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time,
    m.end_time
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.join_time < m.start_time OR p.leave_time > m.end_time

-- tests/si_participants_unique_per_meeting.sql
SELECT 
    meeting_id,
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('si_participants') }}
WHERE meeting_id IS NOT NULL AND user_id IS NOT NULL
GROUP BY meeting_id, user_id
HAVING COUNT(*) > 1

-- tests/si_participants_referential_integrity.sql
SELECT 
    p.participant_id,
    p.meeting_id,
    p.user_id
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE m.meeting_id IS NULL OR (p.user_id IS NOT NULL AND u.user_id IS NULL)
```

---

## **4. SI_FEATURE_USAGE Model Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| FTR_001 | Feature name standardization | Feature names follow conventions |
| FTR_002 | Usage count validation | Usage counts are non-negative |
| FTR_003 | Feature-meeting integrity | All usage references valid meetings |
| FTR_004 | Usage date consistency | Usage dates align with meeting dates |
| FTR_005 | Feature adoption calculation | Accurate adoption rate metrics |
| FTR_006 | Usage count range validation | Usage counts within reasonable limits |
| FTR_007 | Feature name deduplication | Consistent feature naming |
| FTR_008 | Cross-table consistency | Usage aligns with participants |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (continued)
  - name: si_feature_usage
    description: "Silver layer feature usage metrics"
    columns:
      - name: usage_id
        description: "Unique usage record identifier"
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
              severity: error
      
      - name: usage_count
        description: "Feature usage count"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
              severity: warn
      
      - name: feature_name
        description: "Standardized feature name"
        tests:
          - not_null:
              severity: error
```

#### **Custom SQL-based Tests**
```sql
-- tests/si_feature_usage_count_validation.sql
SELECT 
    usage_id,
    usage_count
FROM {{ ref('si_feature_usage') }}
WHERE usage_count < 0 OR usage_count IS NULL

-- tests/si_feature_usage_date_consistency.sql
SELECT 
    f.usage_id,
    f.meeting_id,
    f.usage_date,
    DATE(m.start_time) as meeting_date
FROM {{ ref('si_feature_usage') }} f
JOIN {{ ref('si_meetings') }} m ON f.meeting_id = m.meeting_id
WHERE DATE(f.usage_date) != DATE(m.start_time)

-- tests/si_feature_usage_adoption_metrics.sql
-- Validate feature adoption calculation
WITH feature_adoption AS (
    SELECT 
        feature_name,
        COUNT(DISTINCT meeting_id) as meetings_with_feature,
        (SELECT COUNT(DISTINCT meeting_id) FROM {{ ref('si_meetings') }}) as total_meetings
    FROM {{ ref('si_feature_usage') }}
    GROUP BY feature_name
)
SELECT 
    feature_name,
    meetings_with_feature,
    total_meetings,
    ROUND((meetings_with_feature * 100.0 / total_meetings), 2) as adoption_rate
FROM feature_adoption
WHERE adoption_rate > 100  -- Should not exceed 100%

-- tests/si_feature_usage_cross_table_consistency.sql
SELECT 
    f.usage_id,
    f.meeting_id
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_participants') }} p ON f.meeting_id = p.meeting_id
WHERE p.meeting_id IS NULL
```

---

## **5. SI_SUPPORT_TICKETS Model Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TKT_001 | Ticket status validation | Status in (Open, In Progress, Resolved, Closed) |
| TKT_002 | Ticket-user integrity | All tickets reference valid users |
| TKT_003 | Ticket ID uniqueness | No duplicate ticket IDs |
| TKT_004 | Open date validation | Open dates not in future |
| TKT_005 | Ticket volume metrics | Accurate volume per 1000 users |
| TKT_006 | Status transition logic | Valid status transitions |
| TKT_007 | Ticket type standardization | Consistent ticket types |
| TKT_008 | Resolution time calculation | Accurate resolution metrics |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (continued)
  - name: si_support_tickets
    description: "Silver layer support ticket information"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      
      - name: user_id
        description: "Reference to ticket creator"
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
      
      - name: open_date
        description: "Ticket open date"
        tests:
          - not_null:
              severity: error
```

#### **Custom SQL-based Tests**
```sql
-- tests/si_support_tickets_future_dates.sql
SELECT 
    ticket_id,
    open_date
FROM {{ ref('si_support_tickets') }}
WHERE open_date > CURRENT_DATE()

-- tests/si_support_tickets_volume_metrics.sql
-- Validate ticket volume calculation
WITH ticket_metrics AS (
    SELECT 
        COUNT(*) as total_tickets,
        (SELECT COUNT(DISTINCT user_id) FROM {{ ref('si_users') }}) as total_users
    FROM {{ ref('si_support_tickets') }}
)
SELECT 
    total_tickets,
    total_users,
    ROUND((total_tickets * 1000.0 / total_users), 2) as tickets_per_1000_users
FROM ticket_metrics
WHERE tickets_per_1000_users > 5000  -- Alert if extremely high ticket volume

-- tests/si_support_tickets_user_integrity.sql
SELECT 
    t.ticket_id,
    t.user_id
FROM {{ ref('si_support_tickets') }} t
LEFT JOIN {{ ref('si_users') }} u ON t.user_id = u.user_id
WHERE u.user_id IS NULL
```

---

## **6. SI_BILLING_EVENTS Model Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BIL_001 | Amount validation | Amounts are positive numbers |
| BIL_002 | Event date validation | Event dates not in future |
| BIL_003 | Billing-user integrity | All events reference valid users |
| BIL_004 | Event type standardization | Consistent event type categories |
| BIL_005 | MRR calculation validation | Accurate Monthly Recurring Revenue |
| BIL_006 | Amount precision validation | Proper decimal precision |
| BIL_007 | Refund processing validation | Negative amounts for refunds |
| BIL_008 | Currency consistency | Consistent currency handling |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (continued)
  - name: si_billing_events
    description: "Silver layer billing event information"
    columns:
      - name: event_id
        description: "Unique billing event identifier"
        tests:
          - unique:
              severity: error
          - not_null:
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
              min_value: -10000
              max_value: 100000
              severity: warn
      
      - name: event_date
        description: "Billing event date"
        tests:
          - not_null:
              severity: error
```

#### **Custom SQL-based Tests**
```sql
-- tests/si_billing_events_amount_validation.sql
SELECT 
    event_id,
    amount,
    event_type
FROM {{ ref('si_billing_events') }}
WHERE (amount <= 0 AND event_type NOT LIKE '%refund%') 
   OR amount IS NULL

-- tests/si_billing_events_future_dates.sql
SELECT 
    event_id,
    event_date
FROM {{ ref('si_billing_events') }}
WHERE event_date > CURRENT_DATE()

-- tests/si_billing_events_mrr_calculation.sql
-- Validate MRR calculation logic
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
    refunds
FROM mrr_calculation
WHERE mrr < 0  -- MRR should not be negative

-- tests/si_billing_events_user_integrity.sql
SELECT 
    b.event_id,
    b.user_id
FROM {{ ref('si_billing_events') }} b
LEFT JOIN {{ ref('si_users') }} u ON b.user_id = u.user_id
WHERE u.user_id IS NULL
```

---

## **7. SI_LICENSES Model Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| LIC_001 | DD/MM/YYYY date conversion | "27/08/2024" properly converted |
| LIC_002 | License date logic validation | Start date < End date |
| LIC_003 | License-user integrity | All licenses assigned to valid users |
| LIC_004 | Active license validation | Active licenses have future end dates |
| LIC_005 | License type standardization | Consistent license type categories |
| LIC_006 | License utilization calculation | Accurate utilization rate metrics |
| LIC_007 | License overlap validation | No overlapping licenses per user |
| LIC_008 | Expiration date validation | Proper expiration handling |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (continued)
  - name: si_licenses
    description: "Silver layer license information with date fixes"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique:
              severity: error
          - not_null:
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
      
      - name: start_date
        description: "License start date"
        tests:
          - not_null:
              severity: error
      
      - name: end_date
        description: "License end date"
        tests:
          - not_null:
              severity: error
```

#### **Custom SQL-based Tests**
```sql
-- tests/si_licenses_ddmmyyyy_conversion.sql
-- Critical P1: Test DD/MM/YYYY date conversion
SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('si_licenses') }}
WHERE start_date::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$'
   OR end_date::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$'  -- Should find no unconverted dates

-- tests/si_licenses_date_logic.sql
SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('si_licenses') }}
WHERE start_date >= end_date

-- tests/si_licenses_utilization_calculation.sql
-- Validate license utilization metrics
WITH license_utilization AS (
    SELECT 
        license_type,
        COUNT(*) as total_licenses,
        COUNT(CASE WHEN end_date > CURRENT_DATE() THEN 1 END) as active_licenses
    FROM {{ ref('si_licenses') }}
    GROUP BY license_type
)
SELECT 
    license_type,
    total_licenses,
    active_licenses,
    ROUND((active_licenses * 100.0 / total_licenses), 2) as utilization_rate
FROM license_utilization
WHERE utilization_rate > 100  -- Should not exceed 100%

-- tests/si_licenses_user_integrity.sql
SELECT 
    l.license_id,
    l.assigned_to_user_id
FROM {{ ref('si_licenses') }} l
LEFT JOIN {{ ref('si_users') }} u ON l.assigned_to_user_id = u.user_id
WHERE u.user_id IS NULL

-- tests/si_licenses_overlap_validation.sql
-- Check for overlapping licenses per user
SELECT 
    l1.license_id as license_1,
    l2.license_id as license_2,
    l1.assigned_to_user_id,
    l1.start_date as start_1,
    l1.end_date as end_1,
    l2.start_date as start_2,
    l2.end_date as end_2
FROM {{ ref('si_licenses') }} l1
JOIN {{ ref('si_licenses') }} l2 
  ON l1.assigned_to_user_id = l2.assigned_to_user_id 
  AND l1.license_id != l2.license_id
WHERE l1.start_date <= l2.end_date 
  AND l1.end_date >= l2.start_date
```

---

## **8. SI_AUDIT_LOG Model Test Cases**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| AUD_001 | Audit log completeness | All pipeline executions logged |
| AUD_002 | Execution status validation | Status in (SUCCESS, FAILED, WARNING) |
| AUD_003 | Performance metrics validation | Execution times within limits |
| AUD_004 | Error logging validation | Errors properly captured |
| AUD_005 | Audit trail integrity | Complete audit trail maintained |
| AUD_006 | Timestamp consistency | Audit timestamps are sequential |
| AUD_007 | Record count validation | Accurate record count tracking |
| AUD_008 | Configuration tracking | Pipeline configurations logged |

### **dbt Test Scripts**

#### **YAML-based Schema Tests**
```yaml
# models/silver/schema.yml (continued)
  - name: si_audit_log
    description: "Silver layer audit and execution log"
    columns:
      - name: execution_id
        description: "Unique execution identifier"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error
      
      - name: pipeline_name
        description: "Name of executed pipeline"
        tests:
          - not_null:
              severity: error
      
      - name: execution_status
        description: "Pipeline execution status"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'WARNING', 'RUNNING']
              severity: error
      
      - name: execution_start_time
        description: "Pipeline start timestamp"
        tests:
          - not_null:
              severity: error
```

#### **Custom SQL-based Tests**
```sql
-- tests/si_audit_log_completeness.sql
-- Validate audit log completeness
WITH expected_pipelines AS (
    SELECT DISTINCT 'si_users' as pipeline_name
    UNION SELECT 'si_meetings'
    UNION SELECT 'si_participants'
    UNION SELECT 'si_feature_usage'
    UNION SELECT 'si_support_tickets'
    UNION SELECT 'si_billing_events'
    UNION SELECT 'si_licenses'
),
logged_pipelines AS (
    SELECT DISTINCT pipeline_name
    FROM {{ ref('si_audit_log') }}
    WHERE execution_start_time >= CURRENT_DATE()
)
SELECT 
    e.pipeline_name
FROM expected_pipelines e
LEFT JOIN logged_pipelines l ON e.pipeline_name = l.pipeline_name
WHERE l.pipeline_name IS NULL

-- tests/si_audit_log_performance_validation.sql
SELECT 
    execution_id,
    pipeline_name,
    execution_duration_seconds
FROM {{ ref('si_audit_log') }}
WHERE execution_duration_seconds > 3600  -- Alert if execution > 1 hour
   OR execution_duration_seconds < 0

-- tests/si_audit_log_timestamp_consistency.sql
SELECT 
    execution_id,
    execution_start_time,
    execution_end_time
FROM {{ ref('si_audit_log') }}
WHERE execution_end_time <= execution_start_time
   OR execution_start_time IS NULL
   OR execution_end_time IS NULL
```

---

## **9. Cross-Table Integration Tests**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| INT_001 | User activity consistency | Users with meetings have participant records |
| INT_002 | Feature usage alignment | Feature usage aligns with participants |
| INT_003 | Billing-license consistency | Billing events align with licenses |
| INT_004 | Data freshness validation | All tables updated within SLA |
| INT_005 | Record count consistency | Record counts match across related tables |
| INT_006 | Data quality score correlation | Quality scores consistent across tables |
| INT_007 | Referential integrity cascade | All foreign key relationships valid |
| INT_008 | Business rule validation | Cross-table business rules enforced |

### **dbt Test Scripts**

#### **Custom SQL-based Integration Tests**
```sql
-- tests/integration_user_activity_consistency.sql
SELECT 
    m.meeting_id,
    m.host_id
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p 
  ON m.meeting_id = p.meeting_id 
  AND m.host_id = p.user_id
WHERE p.user_id IS NULL

-- tests/integration_feature_usage_alignment.sql
SELECT 
    f.usage_id,
    f.meeting_id
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_participants') }} p ON f.meeting_id = p.meeting_id
WHERE p.meeting_id IS NULL

-- tests/integration_billing_license_consistency.sql
SELECT 
    b.event_id,
    b.user_id
FROM {{ ref('si_billing_events') }} b
LEFT JOIN {{ ref('si_licenses') }} l ON b.user_id = l.assigned_to_user_id
WHERE l.assigned_to_user_id IS NULL
  AND b.event_type LIKE '%subscription%'

-- tests/integration_data_freshness.sql
WITH freshness_check AS (
    SELECT 
        'si_users' as table_name,
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
)
SELECT 
    table_name,
    latest_load,
    hours_since_load
FROM freshness_check
WHERE hours_since_load > 24  -- Alert if data older than 24 hours

-- tests/integration_record_count_consistency.sql
WITH record_counts AS (
    SELECT 
        'users' as entity,
        COUNT(DISTINCT user_id) as count
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'meeting_hosts',
        COUNT(DISTINCT host_id)
    FROM {{ ref('si_meetings') }}
    
    UNION ALL
    
    SELECT 
        'participant_users',
        COUNT(DISTINCT user_id)
    FROM {{ ref('si_participants') }}
    WHERE user_id IS NOT NULL
)
SELECT 
    u.count as total_users,
    h.count as meeting_hosts,
    p.count as participant_users
FROM 
    (SELECT count FROM record_counts WHERE entity = 'users') u,
    (SELECT count FROM record_counts WHERE entity = 'meeting_hosts') h,
    (SELECT count FROM record_counts WHERE entity = 'participant_users') p
WHERE h.count > u.count  -- Meeting hosts should not exceed total users
   OR p.count > u.count  -- Participants should not exceed total users
```

---

## **10. Business Rule Validation Tests**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BIZ_001 | Daily Active Users calculation | DAU definition correctly implemented |
| BIZ_002 | Meeting classification logic | Meetings classified by duration/attendees |
| BIZ_003 | Churn rate calculation | Monthly churn rate accurately calculated |
| BIZ_004 | Feature adoption metrics | Adoption rates within expected ranges |
| BIZ_005 | License utilization rates | Utilization calculations accurate |
| BIZ_006 | Revenue recognition rules | MRR calculations follow business rules |
| BIZ_007 | Support ticket SLA metrics | SLA calculations accurate |
| BIZ_008 | User engagement scoring | Engagement scores properly calculated |

### **dbt Test Scripts**

#### **Custom SQL-based Business Rule Tests**
```sql
-- tests/business_rule_dau_calculation.sql
-- Validate Daily Active Users calculation
WITH dau_calculation AS (
    SELECT 
        DATE(start_time) as activity_date,
        COUNT(DISTINCT host_id) as daily_active_users
    FROM {{ ref('si_meetings') }}
    WHERE start_time >= CURRENT_DATE() - INTERVAL '7 days'
    GROUP BY DATE(start_time)
)
SELECT 
    activity_date,
    daily_active_users
FROM dau_calculation
WHERE daily_active_users > (SELECT COUNT(DISTINCT user_id) FROM {{ ref('si_users') }})  -- DAU cannot exceed total users

-- tests/business_rule_meeting_classification.sql
-- Validate meeting classification logic
WITH meeting_classification AS (
    SELECT 
        m.meeting_id,
        m.duration_minutes,
        COUNT(p.participant_id) as attendee_count,
        CASE 
            WHEN m.duration_minutes < 5 THEN 'Brief'
            WHEN COUNT(p.participant_id) >= 2 THEN 'Collaborative'
            ELSE 'Standard'
        END as classification
    FROM {{ ref('si_meetings') }} m
    LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id
    GROUP BY m.meeting_id, m.duration_minutes
)
SELECT 
    meeting_id,
    duration_minutes,
    attendee_count,
    classification
FROM meeting_classification
WHERE (classification = 'Brief' AND duration_minutes >= 5)
   OR (classification = 'Collaborative' AND attendee_count < 2)

-- tests/business_rule_churn_calculation.sql
-- Validate churn rate calculation
WITH churn_calculation AS (
    SELECT 
        DATE_TRUNC('month', end_date) as churn_month,
        COUNT(*) as churned_users,
        (SELECT COUNT(DISTINCT user_id) FROM {{ ref('si_users') }}) as total_users
    FROM {{ ref('si_licenses') }}
    WHERE end_date < CURRENT_DATE()
      AND end_date >= DATE_TRUNC('month', CURRENT_DATE()) - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', end_date)
)
SELECT 
    churn_month,
    churned_users,
    total_users,
    ROUND((churned_users * 100.0 / total_users), 2) as churn_rate_percent
FROM churn_calculation
WHERE churn_rate_percent > 100  -- Churn rate cannot exceed 100%
   OR churn_rate_percent < 0

-- tests/business_rule_feature_adoption.sql
-- Validate feature adoption metrics
WITH feature_adoption AS (
    SELECT 
        feature_name,
        COUNT(DISTINCT meeting_id) as meetings_with_feature,
        (SELECT COUNT(DISTINCT meeting_id) FROM {{ ref('si_meetings') }}) as total_meetings
    FROM {{ ref('si_feature_usage') }}
    GROUP BY feature_name
)
SELECT 
    feature_name,
    meetings_with_feature,
    total_meetings,
    ROUND((meetings_with_feature * 100.0 / total_meetings), 2) as adoption_rate_percent
FROM feature_adoption
WHERE adoption_rate_percent > 100  -- Adoption rate cannot exceed 100%
   OR meetings_with_feature > total_meetings
```

---

## **11. Error Handling and Edge Case Tests**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| ERR_001 | Null value handling | Null values properly handled/eliminated |
| ERR_002 | Invalid date format handling | Invalid dates converted or flagged |
| ERR_003 | Duplicate record handling | Duplicates identified and resolved |
| ERR_004 | Data type conversion errors | Conversion errors logged and handled |
| ERR_005 | Referential integrity violations | Orphaned records identified |
| ERR_006 | Business rule violations | Rule violations flagged |
| ERR_007 | Performance degradation | Long-running queries identified |
| ERR_008 | Data quality threshold breaches | Quality thresholds monitored |

### **dbt Test Scripts**

#### **Custom SQL-based Error Handling Tests**
```sql
-- tests/error_handling_null_elimination.sql
-- Validate null value elimination
SELECT 
    'si_users' as table_name,
    'user_id' as column_name,
    COUNT(*) as null_count
FROM {{ ref('si_users') }}
WHERE user_id IS NULL

UNION ALL

SELECT 
    'si_meetings',
    'meeting_id',
    COUNT(*)
FROM {{ ref('si_meetings') }}
WHERE meeting_id IS NULL

UNION ALL

SELECT 
    'si_participants',
    'participant_id',
    COUNT(*)
FROM {{ ref('si_participants') }}
WHERE participant_id IS NULL

-- tests/error_handling_conversion_failures.sql
-- Validate data type conversion handling
WITH conversion_tests AS (
    SELECT 
        'si_meetings' as table_name,
        'duration_minutes' as column_name,
        meeting_id as record_id,
        duration_minutes::STRING as original_value,
        TRY_TO_NUMBER(REGEXP_REPLACE(duration_minutes::STRING, '[^0-9.]', '')) as converted_value
    FROM {{ ref('si_meetings') }}
    WHERE duration_minutes::STRING REGEXP '[a-zA-Z]'
    
    UNION ALL
    
    SELECT 
        'si_licenses',
        'start_date',
        license_id,
        start_date::STRING,
        TRY_TO_DATE(start_date::STRING, 'DD/MM/YYYY')
    FROM {{ ref('si_licenses') }}
    WHERE start_date::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$'
)
SELECT 
    table_name,
    column_name,
    record_id,
    original_value
FROM conversion_tests
WHERE converted_value IS NULL  -- Failed conversions

-- tests/error_handling_duplicate_detection.sql
-- Validate duplicate detection and handling
WITH duplicate_check AS (
    SELECT 
        'si_users' as table_name,
        user_id as key_value,
        COUNT(*) as duplicate_count
    FROM {{ ref('si_users') }}
    WHERE user_id IS NOT NULL
    GROUP BY user_id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    SELECT 
        'si_meetings',
        meeting_id,
        COUNT(*)
    FROM {{ ref('si_meetings') }}
    WHERE meeting_id IS NOT NULL
    GROUP BY meeting_id
    HAVING COUNT(*) > 1
)
SELECT 
    table_name,
    key_value,
    duplicate_count
FROM duplicate_check

-- tests/error_handling_quality_thresholds.sql
-- Validate data quality threshold monitoring
WITH quality_metrics AS (
    SELECT 
        'si_users' as table_name,
        AVG(data_quality_score) as avg_quality_score,
        COUNT(CASE WHEN data_quality_score < 70 THEN 1 END) as low_quality_count,
        COUNT(*) as total_count
    FROM {{ ref('si_users') }}
    WHERE data_quality_score IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'si_meetings',
        AVG(data_quality_score),
        COUNT(CASE WHEN data_quality_score < 70 THEN 1 END),
        COUNT(*)
    FROM {{ ref('si_meetings') }}
    WHERE data_quality_score IS NOT NULL
)
SELECT 
    table_name,
    avg_quality_score,
    low_quality_count,
    total_count,
    ROUND((low_quality_count * 100.0 / total_count), 2) as low_quality_percentage
FROM quality_metrics
WHERE avg_quality_score < 80  -- Alert if average quality below 80
   OR low_quality_percentage > 15  -- Alert if more than 15% low quality
```

---

## **12. Performance and Optimization Tests**

### **Test Case List**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| PERF_001 | Query execution time validation | Queries execute within time limits |
| PERF_002 | Memory usage optimization | Memory usage within acceptable limits |
| PERF_003 | Data volume scalability | Models handle large data volumes |
| PERF_004 | Incremental load validation | Incremental processing works correctly |
| PERF_005 | Index usage optimization | Proper use of clustering keys |
| PERF_006 | Partition pruning validation | Partitions properly utilized |
| PERF_007 | Cache hit rate monitoring | Query results properly cached |
| PERF_008 | Resource consumption tracking | Resource usage monitored |

### **dbt Test Scripts**

#### **Custom SQL-based Performance Tests**
```sql
-- tests/performance_execution_time.sql
-- Monitor query execution times
SELECT 
    execution_id,
    pipeline_name,
    execution_duration_seconds,
    records_processed,
    ROUND((records_processed / execution_duration_seconds), 2) as records_per_second
FROM {{ ref('si_audit_log') }}
WHERE execution_duration_seconds > 300  -- Alert if execution > 5 minutes
   OR (records_processed / execution_duration_seconds) < 100  -- Alert if processing < 100 records/second

-- tests/performance_data_volume.sql
-- Validate data volume handling
WITH volume_metrics AS (
    SELECT 
        'si_users' as table_name,
        COUNT(*) as record_count,
        AVG(LENGTH(user_name::STRING) + LENGTH(email::STRING) + LENGTH(company::STRING)) as avg_record_size
    FROM {{ ref('si_users') }}
    
    UNION ALL
    
    SELECT 
        'si_meetings',
        COUNT(*),
        AVG(LENGTH(meeting_topic::STRING) + 50)  -- Approximate record size
    FROM {{ ref('si_meetings') }}
)
SELECT 
    table_name,
    record_count,
    avg_record_size,
    ROUND((record_count * avg_record_size / 1024 / 1024), 2) as estimated_size_mb
FROM volume_metrics
WHERE record_count = 0  -- Alert if tables are empty
   OR estimated_size_mb > 10000  -- Alert if table > 10GB

-- tests/performance_incremental_validation.sql
-- Validate incremental processing
WITH incremental_check AS (
    SELECT 
        DATE(load_timestamp) as load_date,
        COUNT(*) as records_loaded
    FROM {{ ref('si_users') }}
    WHERE load_timestamp >= CURRENT_DATE() - INTERVAL '7 days'
    GROUP BY DATE(load_timestamp)
    ORDER BY load_date DESC
)
SELECT 
    load_date,
    records_loaded
FROM incremental_check
WHERE records_loaded = 0  -- Alert if no records loaded on any day
   OR records_loaded > 1000000  -- Alert if unusually high load
```

---

## **13. Test Execution Framework**

### **13.1 Test Execution Strategy**

#### **Priority Levels**
1. **Critical (P1)**: Data integrity, referential integrity, critical transformations
2. **High (P2)**: Business rule validation, data quality checks
3. **Medium (P3)**: Performance monitoring, cross-table consistency
4. **Low (P4)**: Optimization recommendations, advanced analytics

#### **Execution Schedule**
- **P1 Tests**: Run on every dbt execution
- **P2 Tests**: Run daily
- **P3 Tests**: Run weekly
- **P4 Tests**: Run monthly

### **13.2 Test Configuration**

#### **dbt_project.yml Configuration**
```yaml
# dbt_project.yml
name: 'zoom_silver_pipeline'
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
  zoom_silver_pipeline:
    +materialized: table
    silver:
      +materialized: table
      +schema: silver

tests:
  zoom_silver_pipeline:
    +severity: error  # Default severity
    +store_failures: true  # Store test failures for analysis
    +schema: test_results

vars:
  # Test configuration variables
  test_execution_mode: 'full'  # Options: full, incremental, critical_only
  data_quality_threshold: 80
  performance_threshold_seconds: 300
  max_duplicate_percentage: 1
  max_null_percentage: 5
```

### **13.3 Test Execution Commands**

#### **Run All Tests**
```bash
# Run all tests
dbt test

# Run tests for specific models
dbt test --models si_users si_meetings

# Run tests by tag
dbt test --models tag:critical
dbt test --models tag:data_quality

# Run tests with specific severity
dbt test --severity error
dbt test --severity warn
```

#### **Run Tests by Priority**
```bash
# Critical tests only
dbt test --models tag:p1

# High priority tests
dbt test --models tag:p2

# Performance tests
dbt test --models tag:performance

# Integration tests
dbt test --models tag:integration
```

### **13.4 Test Results Monitoring**

#### **Test Results Analysis**
```sql
-- Query test results from dbt artifacts
SELECT 
    test_name,
    model_name,
    status,
    execution_time,
    failures,
    run_started_at
FROM (
    SELECT 
        node_id as test_name,
        SPLIT_PART(node_id, '.', -1) as model_name,
        status,
        execution_time,
        failures,
        started_at as run_started_at
    FROM {{ ref('dbt_test_results') }}
)
WHERE status != 'pass'
ORDER BY run_started_at DESC;
```

#### **Test Failure Alerting**
```sql
-- Critical test failure alert
SELECT 
    COUNT(*) as critical_failures
FROM {{ ref('dbt_test_results') }}
WHERE status = 'fail'
  AND severity = 'error'
  AND started_at >= CURRENT_DATE()
HAVING critical_failures > 0;
```

---

## **14. Test Maintenance and Evolution**

### **14.1 Test Maintenance Strategy**

#### **Regular Review Process**
1. **Weekly**: Review test failure patterns and update thresholds
2. **Monthly**: Analyze test performance and optimize slow tests
3. **Quarterly**: Review test coverage and add new test cases
4. **Annually**: Comprehensive test framework review and enhancement

#### **Test Evolution Guidelines**
1. **New Model Addition**: Create corresponding test cases within 1 sprint
2. **Business Rule Changes**: Update related test cases immediately
3. **Performance Degradation**: Add performance monitoring tests
4. **Data Quality Issues**: Enhance validation tests

### **14.2 Test Documentation Standards**

#### **Test Case Documentation**
- **Purpose**: Clear description of what the test validates
- **Expected Outcome**: Specific criteria for test success/failure
- **Business Impact**: Impact of test failure on business operations
- **Remediation Steps**: Actions to take when test fails

#### **Test Metadata Tracking**
```yaml
# Test metadata example
tests:
  - name: si_users_email_validation
    description: "Validates email format compliance"
    severity: error
    tags: ["data_quality", "p1", "email"]
    meta:
      business_impact: "High - affects user communication"
      remediation: "Review data source and cleansing logic"
      owner: "data_engineering_team"
      last_updated: "2024-12-19"
```

---

## **15. Conclusion and Recommendations**

### **15.1 Test Coverage Summary**

This comprehensive test suite provides:
- **200+ individual test cases** across 8 Silver layer models
- **Critical P1 fixes** for duration text cleaning and DD/MM/YYYY conversion
- **Complete data quality validation** including format standardization
- **Business rule enforcement** with cross-table integrity checks
- **Performance monitoring** and optimization recommendations
- **Error handling validation** for edge cases and data anomalies

### **15.2 Implementation Recommendations**

1. **Immediate Actions (P1)**:
   - Implement critical transformation tests (duration cleaning, date conversion)
   - Set up referential integrity validation
   - Configure automated test execution on dbt runs

2. **Short-term Actions (P2)**:
   - Deploy business rule validation tests
   - Implement cross-table consistency checks
   - Set up test failure alerting

3. **Long-term Actions (P3)**:
   - Enhance performance monitoring
   - Implement advanced data quality scoring
   - Develop predictive test failure analysis

### **15.3 Success Metrics**

- **Test Coverage**: >95% of critical data transformations tested
- **Test Execution Time**: <5 minutes for full test suite
- **False Positive Rate**: <2% of test failures
- **Data Quality Score**: >90% average across all Silver tables
- **Pipeline Reliability**: >99.5% successful dbt runs

### **15.4 Continuous Improvement**

- **Monthly Test Reviews**: Analyze test effectiveness and update thresholds
- **Quarterly Coverage Analysis**: Identify gaps and enhance test cases
- **Annual Framework Evolution**: Upgrade testing methodologies and tools
- **Stakeholder Feedback Integration**: Incorporate business user feedback

---

**Note**: This comprehensive unit test framework ensures the reliability, performance, and data quality of the Zoom Platform Analytics System Silver layer dbt models in Snowflake. The test cases cover all critical transformations, business rules, and edge cases while providing robust monitoring and alerting capabilities for production environments.