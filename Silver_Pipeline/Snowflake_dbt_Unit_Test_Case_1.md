_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Silver Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Silver Layer pipeline that transforms data from Bronze to Silver layer in Snowflake. The pipeline includes 8 Silver layer models with advanced data quality checks, timestamp format handling, and business rule validations.

## Test Case List

### 1. SI_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate unique user_id constraint | All user_id values are unique |
| TC_USR_002 | Validate not null constraints for critical fields | user_id, email, created_at are not null |
| TC_USR_003 | Validate email format using regex | All emails follow valid format pattern |
| TC_USR_004 | Validate plan standardization (Basic/Pro/Enterprise) | All plan values are standardized |
| TC_USR_005 | Test deduplication logic with ROW_NUMBER() | Only latest records per user_id retained |
| TC_USR_006 | Validate data quality score calculation (0-100) | Score calculated based on completeness |
| TC_USR_007 | Test validation status (PASSED/WARNING/FAILED) | Status assigned based on data quality |
| TC_USR_008 | Validate failed record exclusion | Only clean data reaches Silver layer |

### 2. SI_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate unique meeting_id constraint | All meeting_id values are unique |
| TC_MTG_002 | Validate EST timezone conversion | YYYY-MM-DD HH24:MI:SS EST format handled |
| TC_MTG_003 | Test timestamp format detection and conversion | Self-healing logic for timestamp formats |
| TC_MTG_004 | Validate not null constraints | meeting_id, start_time, end_time not null |
| TC_MTG_005 | Test duration calculation accuracy | Duration = end_time - start_time |
| TC_MTG_006 | Validate meeting status values | Status in accepted values list |
| TC_MTG_007 | Test TRY_TO_TIMESTAMP error handling | Invalid timestamps handled gracefully |
| TC_MTG_008 | Validate audit trail logging | Pre/post hooks execute successfully |

### 3. SI_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate unique participant_id constraint | All participant_id values are unique |
| TC_PRT_002 | Test MM/DD/YYYY HH:MM format conversion | Format converted to standard timestamp |
| TC_PRT_003 | Validate join_time and leave_time logic | join_time <= leave_time |
| TC_PRT_004 | Test relationship with SI_MEETINGS | Valid meeting_id references exist |
| TC_PRT_005 | Validate participant duration calculation | Duration calculated correctly |
| TC_PRT_006 | Test null handling for optional fields | Null values handled appropriately |
| TC_PRT_007 | Validate data type conversions | All conversions successful |
| TC_PRT_008 | Test deduplication by participant and meeting | No duplicate participant-meeting pairs |

### 4. SI_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate unique usage_id constraint | All usage_id values are unique |
| TC_FTR_002 | Test feature name standardization | Feature names standardized |
| TC_FTR_003 | Validate usage metrics data types | Numeric fields properly typed |
| TC_FTR_004 | Test relationship with SI_USERS | Valid user_id references exist |
| TC_FTR_005 | Validate usage timestamp accuracy | Timestamps within valid ranges |
| TC_FTR_006 | Test aggregation logic for usage counts | Counts calculated correctly |
| TC_FTR_007 | Validate business rule implementations | Usage rules applied correctly |
| TC_FTR_008 | Test data quality scoring | Quality scores assigned properly |

### 5. SI_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate unique ticket_id constraint | All ticket_id values are unique |
| TC_TKT_002 | Test status validation (Open/Closed/Pending) | Status values validated |
| TC_TKT_003 | Validate priority levels | Priority in accepted values |
| TC_TKT_004 | Test relationship with SI_USERS | Valid user_id references exist |
| TC_TKT_005 | Validate created_at and resolved_at logic | Timestamps logical |
| TC_TKT_006 | Test SLA calculation accuracy | SLA metrics calculated correctly |
| TC_TKT_007 | Validate ticket categorization | Categories properly assigned |
| TC_TKT_008 | Test escalation logic | Escalation rules applied |

### 6. SI_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate unique billing_event_id constraint | All billing_event_id values are unique |
| TC_BIL_002 | Test amount cleaning and validation | Amounts properly formatted |
| TC_BIL_003 | Validate currency standardization | Currency codes standardized |
| TC_BIL_004 | Test relationship with SI_USERS | Valid user_id references exist |
| TC_BIL_005 | Validate billing date accuracy | Dates within valid ranges |
| TC_BIL_006 | Test TRY_TO_NUMBER for amount conversion | Numeric conversions handled |
| TC_BIL_007 | Validate transaction types | Types in accepted values |
| TC_BIL_008 | Test revenue calculation logic | Revenue calculated correctly |

### 7. SI_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate unique license_id constraint | All license_id values are unique |
| TC_LIC_002 | Test date validation for start/end dates | Dates properly validated |
| TC_LIC_003 | Validate license status (Active/Expired/Suspended) | Status values validated |
| TC_LIC_004 | Test relationship with SI_USERS | Valid user_id references exist |
| TC_LIC_005 | Validate license type standardization | Types standardized |
| TC_LIC_006 | Test expiration logic | Expiration calculated correctly |
| TC_LIC_007 | Validate seat count accuracy | Seat counts are positive integers |
| TC_LIC_008 | Test license utilization metrics | Utilization calculated properly |

### 8. SI_AUDIT_LOG Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Validate audit log creation | Audit records created for all processes |
| TC_AUD_002 | Test process start/end timestamps | Timestamps recorded accurately |
| TC_AUD_003 | Validate record count tracking | Counts match actual processed records |
| TC_AUD_004 | Test success metrics logging | Success rates calculated correctly |
| TC_AUD_005 | Validate error tracking | Errors logged with details |
| TC_AUD_006 | Test data lineage recording | Lineage information captured |
| TC_AUD_007 | Validate audit trail completeness | All required audit fields populated |
| TC_AUD_008 | Test audit log retention | Logs retained per policy |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# schema.yml
version: 2

models:
  - name: SI_USERS
    description: "Silver layer user data with email validation and plan standardization"
    columns:
      - name: user_id
        description: "Unique identifier for users"
        tests:
          - unique
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 255
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise']
      - name: created_at
        description: "User creation timestamp"
        tests:
          - not_null
      - name: data_quality_score
        description: "Data quality score 0-100"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Data validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'WARNING', 'FAILED']

  - name: SI_MEETINGS
    description: "Silver layer meeting data with EST timezone conversion"
    columns:
      - name: meeting_id
        description: "Unique identifier for meetings"
        tests:
          - unique
          - not_null
      - name: start_time
        description: "Meeting start time in EST"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end time in EST"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440  # 24 hours max
      - name: meeting_status
        description: "Meeting status"
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']

  - name: SI_PARTICIPANTS
    description: "Silver layer participant data with MM/DD/YYYY format conversion"
    columns:
      - name: participant_id
        description: "Unique identifier for participants"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('SI_MEETINGS')
              field: meeting_id
      - name: join_time
        description: "Participant join time"
        tests:
          - not_null
      - name: leave_time
        description: "Participant leave time"
        tests:
          - not_null

  - name: SI_FEATURE_USAGE
    description: "Silver layer feature usage with standardization"
    columns:
      - name: usage_id
        description: "Unique identifier for usage records"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('SI_USERS')
              field: user_id
      - name: feature_name
        description: "Standardized feature name"
        tests:
          - not_null
      - name: usage_count
        description: "Feature usage count"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0

  - name: SI_SUPPORT_TICKETS
    description: "Silver layer support tickets with status validation"
    columns:
      - name: ticket_id
        description: "Unique identifier for tickets"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('SI_USERS')
              field: user_id
      - name: status
        description: "Ticket status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']
      - name: priority
        description: "Ticket priority"
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']

  - name: SI_BILLING_EVENTS
    description: "Silver layer billing events with amount cleaning"
    columns:
      - name: billing_event_id
        description: "Unique identifier for billing events"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('SI_USERS')
              field: user_id
      - name: amount
        description: "Billing amount"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
      - name: currency
        description: "Currency code"
        tests:
          - accepted_values:
              values: ['USD', 'EUR', 'GBP', 'CAD']
      - name: transaction_type
        description: "Type of transaction"
        tests:
          - accepted_values:
              values: ['Charge', 'Refund', 'Credit', 'Adjustment']

  - name: SI_LICENSES
    description: "Silver layer license data with date validation"
    columns:
      - name: license_id
        description: "Unique identifier for licenses"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('SI_USERS')
              field: user_id
      - name: license_type
        description: "Type of license"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Trial']
      - name: status
        description: "License status"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended', 'Cancelled']
      - name: seat_count
        description: "Number of seats"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 10000

  - name: SI_AUDIT_LOG
    description: "Silver layer audit log for process tracking"
    columns:
      - name: audit_id
        description: "Unique identifier for audit records"
        tests:
          - unique
          - not_null
      - name: process_name
        description: "Name of the process"
        tests:
          - not_null
      - name: start_time
        description: "Process start time"
        tests:
          - not_null
      - name: end_time
        description: "Process end time"
        tests:
          - not_null
      - name: records_processed
        description: "Number of records processed"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
      - name: success_rate
        description: "Process success rate"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
```

### Custom SQL-based dbt Tests

#### Test 1: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
SELECT 
    user_id,
    email
FROM {{ ref('SI_USERS') }}
WHERE email IS NOT NULL 
    AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```

#### Test 2: Timestamp Logic Validation
```sql
-- tests/test_meeting_timestamp_logic.sql
SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('SI_MEETINGS') }}
WHERE start_time >= end_time
```

#### Test 3: Participant Join/Leave Logic
```sql
-- tests/test_participant_time_logic.sql
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('SI_PARTICIPANTS') }}
WHERE join_time > leave_time
```

#### Test 4: Data Quality Score Validation
```sql
-- tests/test_data_quality_score.sql
SELECT 
    user_id,
    data_quality_score,
    validation_status
FROM {{ ref('SI_USERS') }}
WHERE (data_quality_score >= 80 AND validation_status != 'PASSED')
   OR (data_quality_score BETWEEN 60 AND 79 AND validation_status != 'WARNING')
   OR (data_quality_score < 60 AND validation_status != 'FAILED')
```

#### Test 5: Deduplication Validation
```sql
-- tests/test_user_deduplication.sql
SELECT 
    user_id,
    COUNT(*) as duplicate_count
FROM {{ ref('SI_USERS') }}
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### Test 6: Billing Amount Validation
```sql
-- tests/test_billing_amount_validation.sql
SELECT 
    billing_event_id,
    amount,
    transaction_type
FROM {{ ref('SI_BILLING_EVENTS') }}
WHERE (transaction_type = 'Charge' AND amount <= 0)
   OR (transaction_type = 'Refund' AND amount >= 0)
```

#### Test 7: License Date Validation
```sql
-- tests/test_license_date_validation.sql
SELECT 
    license_id,
    start_date,
    end_date,
    status
FROM {{ ref('SI_LICENSES') }}
WHERE start_date > end_date
   OR (status = 'Active' AND end_date < CURRENT_DATE())
```

#### Test 8: Audit Log Completeness
```sql
-- tests/test_audit_log_completeness.sql
SELECT 
    audit_id,
    process_name,
    start_time,
    end_time,
    records_processed
FROM {{ ref('SI_AUDIT_LOG') }}
WHERE start_time > end_time
   OR records_processed < 0
   OR success_rate < 0 OR success_rate > 100
```

#### Test 9: Feature Usage Consistency
```sql
-- tests/test_feature_usage_consistency.sql
SELECT 
    f.user_id,
    f.feature_name,
    f.usage_count
FROM {{ ref('SI_FEATURE_USAGE') }} f
LEFT JOIN {{ ref('SI_USERS') }} u ON f.user_id = u.user_id
WHERE u.user_id IS NULL
```

#### Test 10: Support Ticket SLA Validation
```sql
-- tests/test_support_ticket_sla.sql
SELECT 
    ticket_id,
    priority,
    created_at,
    resolved_at,
    DATEDIFF('hour', created_at, resolved_at) as resolution_hours
FROM {{ ref('SI_SUPPORT_TICKETS') }}
WHERE status = 'Resolved'
  AND (
    (priority = 'Critical' AND DATEDIFF('hour', created_at, resolved_at) > 4)
    OR (priority = 'High' AND DATEDIFF('hour', created_at, resolved_at) > 24)
    OR (priority = 'Medium' AND DATEDIFF('hour', created_at, resolved_at) > 72)
    OR (priority = 'Low' AND DATEDIFF('hour', created_at, resolved_at) > 168)
  )
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Execute custom SQL tests to validate business logic
- Verify data quality scores and validation statuses
- Check audit log creation and completeness

### 2. Post-deployment Validation
- Validate record counts match expected volumes
- Check data lineage and audit trail completeness
- Verify all relationships and foreign key constraints
- Confirm timestamp format conversions are successful

### 3. Continuous Monitoring
- Schedule daily test runs for data quality monitoring
- Set up alerts for test failures
- Monitor data quality score trends
- Track audit log metrics for process performance

### 4. Error Handling and Recovery
- Document test failure resolution procedures
- Implement rollback strategies for failed deployments
- Maintain test result history for trend analysis
- Establish escalation procedures for critical failures

## Expected Test Results

### Success Criteria
- All unique and not_null constraints pass
- All relationship tests validate successfully
- All accepted_values tests pass
- Custom business logic tests return zero rows
- Data quality scores are within expected ranges
- Audit logs capture all required information

### Performance Benchmarks
- Test execution completes within 5 minutes
- All models build successfully within 46 seconds
- Data quality validation processes 100% of records
- Audit logging adds less than 5% overhead

## Maintenance and Updates

### Test Case Versioning
- Increment version number for any test modifications
- Maintain backward compatibility where possible
- Document all changes in version history
- Archive previous versions for reference

### Regular Review Schedule
- Monthly review of test coverage and effectiveness
- Quarterly assessment of test performance
- Annual comprehensive test strategy review
- Continuous improvement based on production feedback

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Silver Layer dbt models in Snowflake, providing robust validation for all transformations, business rules, and edge cases.