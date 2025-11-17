_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Silver Layer Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer dbt models running in Snowflake. The test suite covers data transformations, business rules, edge cases, and error handling scenarios for all 8 Silver models that transform data from Bronze to Silver layer.

## Models Under Test

1. **SI_Audit_Log.sql** - Central audit table for pipeline tracking
2. **SI_USERS.sql** - User data with quality enhancements
3. **SI_MEETINGS.sql** - Meeting data with duration and timestamp fixes
4. **SI_PARTICIPANTS.sql** - Participant data with session validation
5. **SI_FEATURE_USAGE.sql** - Feature usage tracking and standardization
6. **SI_SUPPORT_TICKETS.sql** - Support ticket data with status normalization
7. **SI_BILLING_EVENTS.sql** - Billing events with financial validation
8. **SI_LICENSES.sql** - License data with date format conversion

## Test Case List

### 1. SI_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate email format using regex pattern | All emails follow valid format or marked as invalid |
| TC_USR_002 | Test null handling for required fields | No null values in critical fields (user_id, email) |
| TC_USR_003 | Verify plan type standardization | Plan types normalized to standard values |
| TC_USR_004 | Test data quality scoring calculation | Quality scores between 0-100 based on completeness |
| TC_USR_005 | Validate name and email trimming | Leading/trailing spaces removed |
| TC_USR_006 | Test duplicate user handling | Latest record retained using ROW_NUMBER() |
| TC_USR_007 | Verify company name standardization | Company names cleaned and standardized |
| TC_USR_008 | Test edge case: empty email field | Records with empty emails handled gracefully |

### 2. SI_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Test duration text cleaning ("108 mins" issue) | Duration values converted to numeric, text removed |
| TC_MTG_002 | Validate EST timezone conversion | Timestamps properly converted to standard format |
| TC_MTG_003 | Test meeting time logic validation | Start time < End time validation |
| TC_MTG_004 | Verify duration consistency checks | Calculated duration matches provided duration |
| TC_MTG_005 | Test null meeting_id handling | No null meeting_id values in output |
| TC_MTG_006 | Validate meeting classification logic | Meetings properly classified by type/duration |
| TC_MTG_007 | Test edge case: zero duration meetings | Zero duration meetings handled appropriately |
| TC_MTG_008 | Verify timestamp format standardization | All timestamps in consistent format |

### 3. SI_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Test MM/DD/YYYY timestamp conversion | Date formats properly converted |
| TC_PRT_002 | Validate session time boundaries | Join time <= Leave time validation |
| TC_PRT_003 | Test deduplication logic | Latest participant record retained |
| TC_PRT_004 | Verify meeting boundary validation | Participant times within meeting duration |
| TC_PRT_005 | Test null participant_id handling | No null participant_id values |
| TC_PRT_006 | Validate join/leave time consistency | Logical time sequence maintained |
| TC_PRT_007 | Test edge case: same join/leave time | Zero session duration handled |
| TC_PRT_008 | Verify participant count accuracy | Accurate participant counting per meeting |

### 4. SI_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Test feature name normalization | Feature names standardized |
| TC_FTR_002 | Validate usage count validation | Usage counts are non-negative integers |
| TC_FTR_003 | Test date consistency validation | Usage dates within valid ranges |
| TC_FTR_004 | Verify feature adoption tracking | Adoption metrics calculated correctly |
| TC_FTR_005 | Test null feature_id handling | No null feature_id values |
| TC_FTR_006 | Validate usage aggregation logic | Usage counts properly aggregated |
| TC_FTR_007 | Test edge case: negative usage counts | Negative values handled/corrected |
| TC_FTR_008 | Verify feature categorization | Features properly categorized |

### 5. SI_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Test ticket type standardization | Ticket types normalized |
| TC_TKT_002 | Validate status normalization | Status values standardized |
| TC_TKT_003 | Test date validation logic | Created/resolved dates validated |
| TC_TKT_004 | Verify resolution tracking | Resolution times calculated correctly |
| TC_TKT_005 | Test null ticket_id handling | No null ticket_id values |
| TC_TKT_006 | Validate status consistency | Status progression logic maintained |
| TC_TKT_007 | Test edge case: future dates | Future dates handled appropriately |
| TC_TKT_008 | Verify priority assignment | Priority levels assigned correctly |

### 6. SI_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Test financial amount validation | Amounts are valid numeric values |
| TC_BIL_002 | Validate currency handling | Currency codes standardized |
| TC_BIL_003 | Test event type normalization | Event types normalized |
| TC_BIL_004 | Verify revenue tracking accuracy | Revenue calculations correct |
| TC_BIL_005 | Test null billing_id handling | No null billing_id values |
| TC_BIL_006 | Validate financial data integrity | Financial totals balance correctly |
| TC_BIL_007 | Test edge case: zero amounts | Zero amount transactions handled |
| TC_BIL_008 | Verify transaction categorization | Transactions properly categorized |

### 7. SI_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Test DD/MM/YYYY date conversion ("27/08/2024" issue) | European date formats converted correctly |
| TC_LIC_002 | Validate license date logic | Start date <= End date validation |
| TC_LIC_003 | Test assignment validation | License assignments validated |
| TC_LIC_004 | Verify license type normalization | License types standardized |
| TC_LIC_005 | Test null license_id handling | No null license_id values |
| TC_LIC_006 | Validate utilization tracking | License usage tracked accurately |
| TC_LIC_007 | Test edge case: expired licenses | Expired licenses handled correctly |
| TC_LIC_008 | Verify license capacity checks | Capacity limits enforced |

### 8. SI_Audit_Log Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Test process status tracking | Status updates recorded correctly |
| TC_AUD_002 | Validate error logging functionality | Errors captured with details |
| TC_AUD_003 | Test execution metrics recording | Metrics recorded accurately |
| TC_AUD_004 | Verify audit trail completeness | Complete audit trail maintained |
| TC_AUD_005 | Test null process_id handling | No null process_id values |
| TC_AUD_006 | Validate timestamp accuracy | Timestamps recorded correctly |
| TC_AUD_007 | Test circular dependency handling | Circular dependencies avoided |
| TC_AUD_008 | Verify audit data integrity | Audit data remains consistent |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/schema.yml
version: 2

models:
  - name: SI_USERS
    description: "Silver layer users table with data quality enhancements"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - unique
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "email RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' OR email IS NULL"
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'UNKNOWN']
      - name: data_quality_score
        description: "Data quality score 0-100"
        tests:
          - dbt_utils.expression_is_true:
              expression: "data_quality_score >= 0 AND data_quality_score <= 100"

  - name: SI_MEETINGS
    description: "Silver layer meetings table with duration and timestamp fixes"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - unique
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes (numeric)"
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes >= 0"
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - dbt_utils.expression_is_true:
              expression: "end_time >= start_time OR end_time IS NULL"

  - name: SI_PARTICIPANTS
    description: "Silver layer participants with session validation"
    columns:
      - name: participant_id
        description: "Unique participant identifier"
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
          - dbt_utils.expression_is_true:
              expression: "leave_time >= join_time OR leave_time IS NULL"

  - name: SI_FEATURE_USAGE
    description: "Silver layer feature usage with standardization"
    columns:
      - name: usage_id
        description: "Unique usage identifier"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Standardized feature name"
        tests:
          - not_null
      - name: usage_count
        description: "Feature usage count"
        tests:
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"

  - name: SI_SUPPORT_TICKETS
    description: "Silver layer support tickets with status normalization"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
      - name: ticket_status
        description: "Normalized ticket status"
        tests:
          - accepted_values:
              values: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'UNKNOWN']
      - name: created_date
        description: "Ticket creation date"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "created_date <= CURRENT_DATE()"

  - name: SI_BILLING_EVENTS
    description: "Silver layer billing events with financial validation"
    columns:
      - name: billing_id
        description: "Unique billing identifier"
        tests:
          - unique
          - not_null
      - name: amount
        description: "Billing amount"
        tests:
          - dbt_utils.expression_is_true:
              expression: "amount >= 0"
      - name: currency_code
        description: "Currency code"
        tests:
          - accepted_values:
              values: ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'UNKNOWN']

  - name: SI_LICENSES
    description: "Silver layer licenses with date format conversion"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - dbt_utils.expression_is_true:
              expression: "end_date >= start_date OR end_date IS NULL"
      - name: license_type
        description: "Standardized license type"
        tests:
          - accepted_values:
              values: ['BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'TRIAL', 'UNKNOWN']

  - name: SI_AUDIT_LOG
    description: "Central audit table for pipeline tracking"
    columns:
      - name: process_id
        description: "Unique process identifier"
        tests:
          - unique
          - not_null
      - name: process_status
        description: "Process execution status"
        tests:
          - accepted_values:
              values: ['STARTED', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'UNKNOWN']
      - name: start_time
        description: "Process start timestamp"
        tests:
          - not_null
```

### Custom SQL-based dbt Tests

#### Test 1: Duration Text Cleaning Validation
```sql
-- tests/test_duration_cleaning.sql
-- Test that duration fields are properly cleaned of text
SELECT 
    meeting_id,
    duration_minutes,
    original_duration
FROM {{ ref('SI_MEETINGS') }}
WHERE 
    duration_minutes IS NOT NULL 
    AND (
        REGEXP_LIKE(CAST(duration_minutes AS STRING), '[a-zA-Z]') 
        OR duration_minutes < 0
    )
```

#### Test 2: Date Format Conversion Validation
```sql
-- tests/test_date_format_conversion.sql
-- Test that DD/MM/YYYY dates are properly converted
SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('SI_LICENSES') }}
WHERE 
    start_date IS NOT NULL
    AND (
        NOT REGEXP_LIKE(CAST(start_date AS STRING), '^\\d{4}-\\d{2}-\\d{2}') 
        OR start_date > CURRENT_DATE()
        OR start_date < '1990-01-01'
    )
```

#### Test 3: Email Format Validation
```sql
-- tests/test_email_format.sql
-- Test email format validation
SELECT 
    user_id,
    email
FROM {{ ref('SI_USERS') }}
WHERE 
    email IS NOT NULL
    AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test 4: Data Quality Score Validation
```sql
-- tests/test_data_quality_score.sql
-- Test data quality score calculation
SELECT 
    user_id,
    data_quality_score,
    validation_status
FROM {{ ref('SI_USERS') }}
WHERE 
    data_quality_score IS NOT NULL
    AND (
        data_quality_score < 0 
        OR data_quality_score > 100
        OR (validation_status = 'PASSED' AND data_quality_score < 70)
    )
```

#### Test 5: Timestamp Consistency Validation
```sql
-- tests/test_timestamp_consistency.sql
-- Test timestamp logical consistency across models
SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time,
    m.end_time
FROM {{ ref('SI_PARTICIPANTS') }} p
JOIN {{ ref('SI_MEETINGS') }} m ON p.meeting_id = m.meeting_id
WHERE 
    p.join_time < m.start_time
    OR p.leave_time > m.end_time
    OR p.join_time > p.leave_time
```

#### Test 6: Financial Data Integrity
```sql
-- tests/test_financial_integrity.sql
-- Test financial data integrity and consistency
SELECT 
    billing_id,
    amount,
    currency_code,
    event_type
FROM {{ ref('SI_BILLING_EVENTS') }}
WHERE 
    amount IS NOT NULL
    AND (
        amount < 0
        OR (event_type = 'REFUND' AND amount > 0)
        OR (event_type = 'PAYMENT' AND amount <= 0)
        OR currency_code IS NULL
    )
```

#### Test 7: Audit Trail Completeness
```sql
-- tests/test_audit_completeness.sql
-- Test audit trail completeness for all models
WITH model_runs AS (
    SELECT DISTINCT 
        table_name,
        process_status,
        COUNT(*) as run_count
    FROM {{ ref('SI_AUDIT_LOG') }}
    WHERE process_date >= CURRENT_DATE() - 7
    GROUP BY table_name, process_status
),
expected_models AS (
    SELECT unnest([
        'SI_USERS', 'SI_MEETINGS', 'SI_PARTICIPANTS', 
        'SI_FEATURE_USAGE', 'SI_SUPPORT_TICKETS', 
        'SI_BILLING_EVENTS', 'SI_LICENSES'
    ]) as model_name
)
SELECT 
    e.model_name
FROM expected_models e
LEFT JOIN model_runs m ON e.model_name = m.table_name AND m.process_status = 'COMPLETED'
WHERE m.table_name IS NULL
```

#### Test 8: Deduplication Validation
```sql
-- tests/test_deduplication.sql
-- Test that deduplication logic works correctly
WITH duplicate_check AS (
    SELECT 
        user_id,
        COUNT(*) as record_count
    FROM {{ ref('SI_USERS') }}
    GROUP BY user_id
    HAVING COUNT(*) > 1
)
SELECT 
    user_id,
    record_count
FROM duplicate_check
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests using `dbt test`
- Execute custom SQL tests for critical business rules
- Validate data quality scores and validation statuses
- Check audit log completeness

### 2. Post-deployment Monitoring
- Schedule daily test runs for ongoing validation
- Monitor test results in dbt Cloud or run_results.json
- Set up alerts for test failures
- Track test performance and execution times

### 3. Edge Case Testing
- Test with empty source tables
- Validate behavior with all-null records
- Test with extreme date values
- Validate with special characters in text fields

### 4. Performance Testing
- Monitor test execution times
- Validate memory usage during test runs
- Check Snowflake warehouse utilization
- Optimize slow-running tests

## Expected Test Results

### Success Criteria
- All unique and not_null tests pass
- All relationship tests maintain referential integrity
- All custom validation tests return zero failed records
- Data quality scores are within expected ranges (70-100 for PASSED records)
- All date format conversions complete successfully
- Financial data integrity maintained
- Audit trail captures all model executions

### Failure Scenarios and Remediation
- **Duration text not cleaned**: Review REGEXP_REPLACE logic in SI_MEETINGS
- **Date conversion failures**: Check TRY_TO_DATE functions in SI_LICENSES
- **Email format violations**: Validate email cleaning logic in SI_USERS
- **Referential integrity failures**: Check source data quality and join conditions
- **Audit log gaps**: Verify pre/post hooks are properly configured

## Maintenance and Updates

### Regular Maintenance
- Review and update test cases monthly
- Add new tests for new business rules
- Optimize test performance quarterly
- Update expected values based on business changes

### Version Control
- All test changes tracked in Git
- Test documentation updated with each release
- Backward compatibility maintained for existing tests
- Test results archived for historical analysis

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics Silver Layer dbt models in Snowflake, providing robust validation for all critical data transformations and business rules.