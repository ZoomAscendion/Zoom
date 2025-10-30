_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Platform Analytics System Silver layer models. The tests validate key transformations, business rules, edge cases, and error handling scenarios to ensure data quality and reliability in the Snowflake environment.

**Scope**: 9 Silver layer dbt models with comprehensive data quality validations
**Environment**: Snowflake Data Warehouse
**Framework**: dbt (data build tool) with custom SQL tests
**Architecture**: Medallion (Bronze → Silver → Gold)

---

## Test Case List

### 1. SI_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_USR_001 | Validate email format and standardization | All emails follow valid format pattern |
| TC_USR_002 | Test plan type enumeration validation | Only valid plan types (Free, Basic, Pro, Enterprise) |
| TC_USR_003 | Verify account status derivation logic | Account status correctly derived from activity |
| TC_USR_004 | Test duplicate user removal | No duplicate USER_IDs in final dataset |
| TC_USR_005 | Validate data quality score calculation | DQ score between 0.00 and 1.00 |
| TC_USR_006 | Test null handling for required fields | No nulls in mandatory fields |
| TC_USR_007 | Verify timestamp consistency | UPDATE_TIMESTAMP >= LOAD_TIMESTAMP |
| TC_USR_008 | Test email case standardization | All emails converted to lowercase |
| TC_USR_009 | Validate company name standardization | Company names properly formatted |
| TC_USR_010 | Test edge case: empty string handling | Empty strings converted to NULL |

### 2. SI_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_MTG_001 | Validate meeting duration calculation | Duration = DATEDIFF(minutes, START_TIME, END_TIME) |
| TC_MTG_002 | Test temporal logic validation | END_TIME >= START_TIME |
| TC_MTG_003 | Verify host name lookup accuracy | HOST_NAME matches USER_NAME from SI_USERS |
| TC_MTG_004 | Test meeting type classification | Meeting types correctly categorized |
| TC_MTG_005 | Validate participant count aggregation | Count matches actual participants |
| TC_MTG_006 | Test meeting status derivation | Status correctly derived from timestamps |
| TC_MTG_007 | Verify referential integrity | All HOST_IDs exist in SI_USERS |
| TC_MTG_008 | Test null meeting topic handling | Default values applied for null topics |
| TC_MTG_009 | Validate incremental processing | Only new/updated records processed |
| TC_MTG_010 | Test edge case: zero duration meetings | Meetings with same start/end time handled |

### 3. SI_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_PRT_001 | Validate attendance duration calculation | Duration = DATEDIFF(minutes, JOIN_TIME, LEAVE_TIME) |
| TC_PRT_002 | Test temporal validation | LEAVE_TIME >= JOIN_TIME |
| TC_PRT_003 | Verify participant role assignment | Roles correctly assigned based on context |
| TC_PRT_004 | Test connection quality defaults | Default values applied when null |
| TC_PRT_005 | Validate referential integrity | All MEETING_IDs exist in SI_MEETINGS |
| TC_PRT_006 | Test user reference integrity | All USER_IDs exist in SI_USERS |
| TC_PRT_007 | Verify duplicate participant handling | No duplicate PARTICIPANT_IDs |
| TC_PRT_008 | Test null leave time handling | Active participants with null LEAVE_TIME |
| TC_PRT_009 | Validate data quality scoring | DQ score reflects completeness and validity |
| TC_PRT_010 | Test edge case: same join/leave time | Zero duration participation handled |

### 4. SI_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_FTR_001 | Validate feature categorization | Features correctly categorized by type |
| TC_FTR_002 | Test usage count validation | Usage counts are non-negative |
| TC_FTR_003 | Verify usage duration estimation | Duration calculated based on usage patterns |
| TC_FTR_004 | Test date validation | Usage dates not in future |
| TC_FTR_005 | Validate feature name standardization | Feature names consistently formatted |
| TC_FTR_006 | Test referential integrity | All MEETING_IDs exist in SI_MEETINGS |
| TC_FTR_007 | Verify duplicate usage handling | No duplicate USAGE_IDs |
| TC_FTR_008 | Test null feature name handling | Default values for missing feature names |
| TC_FTR_009 | Validate extreme usage count detection | Unusually high usage counts flagged |
| TC_FTR_010 | Test edge case: zero usage count | Zero usage records handled appropriately |

### 5. SI_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_TKT_001 | Validate ticket type standardization | Types match predefined categories |
| TC_TKT_002 | Test priority level derivation | Priority correctly assigned |
| TC_TKT_003 | Verify resolution time calculation | Time calculated in business hours |
| TC_TKT_004 | Test status normalization | Status values standardized |
| TC_TKT_005 | Validate referential integrity | All USER_IDs exist in SI_USERS |
| TC_TKT_006 | Test duplicate ticket handling | No duplicate TICKET_IDs |
| TC_TKT_007 | Verify date validation | OPEN_DATE not in future |
| TC_TKT_008 | Test null description handling | Default values for missing descriptions |
| TC_TKT_009 | Validate close date logic | CLOSE_DATE >= OPEN_DATE when not null |
| TC_TKT_010 | Test edge case: negative ticket IDs | Invalid ticket IDs handled |

### 6. SI_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BIL_001 | Validate amount standardization | Amounts properly formatted and validated |
| TC_BIL_002 | Test transaction status derivation | Status correctly derived from event type |
| TC_BIL_003 | Verify currency code defaults | Default currency applied when missing |
| TC_BIL_004 | Test invoice number generation | Unique invoice numbers generated |
| TC_BIL_005 | Validate payment method assignment | Payment methods correctly assigned |
| TC_BIL_006 | Test referential integrity | All USER_IDs exist in SI_USERS |
| TC_BIL_007 | Verify duplicate event handling | No duplicate EVENT_IDs |
| TC_BIL_008 | Test negative amount validation | Negative amounts only for refunds |
| TC_BIL_009 | Validate date constraints | EVENT_DATE not in future |
| TC_BIL_010 | Test edge case: zero amount transactions | Zero amounts handled appropriately |

### 7. SI_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_LIC_001 | Validate license status calculation | Status based on current date vs dates |
| TC_LIC_002 | Test cost assignment by type | Costs correctly assigned by license type |
| TC_LIC_003 | Verify user name lookups | Names correctly retrieved from SI_USERS |
| TC_LIC_004 | Test utilization percentage defaults | Default values applied when missing |
| TC_LIC_005 | Validate date logic | END_DATE >= START_DATE |
| TC_LIC_006 | Test referential integrity | All ASSIGNED_TO_USER_IDs exist in SI_USERS |
| TC_LIC_007 | Verify duplicate license handling | No duplicate LICENSE_IDs |
| TC_LIC_008 | Test license type validation | Only valid license types accepted |
| TC_LIC_009 | Validate renewal status derivation | Renewal status correctly determined |
| TC_LIC_010 | Test edge case: expired licenses | Expired licenses correctly identified |

### 8. SI_WEBINARS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_WBN_001 | Validate duration calculations | Duration = DATEDIFF(minutes, START_TIME, END_TIME) |
| TC_WBN_002 | Test attendance rate calculations | Rate = (ATTENDEES / REGISTRANTS) * 100 |
| TC_WBN_003 | Verify attendee estimation | Attendees estimated as 70% of registrants |
| TC_WBN_004 | Test temporal validation | END_TIME >= START_TIME |
| TC_WBN_005 | Validate referential integrity | All HOST_IDs exist in SI_USERS |
| TC_WBN_006 | Test duplicate webinar handling | No duplicate WEBINAR_IDs |
| TC_WBN_007 | Verify registrant validation | Registrants are non-negative |
| TC_WBN_008 | Test null topic handling | Default values for missing topics |
| TC_WBN_009 | Validate attendance logic | ATTENDEES <= REGISTRANTS |
| TC_WBN_010 | Test edge case: zero registrants | Zero registrant webinars handled |

### 9. Audit and Error Handling Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AUD_001 | Validate audit log completeness | All processing activities logged |
| TC_AUD_002 | Test error logging functionality | Data quality errors properly logged |
| TC_AUD_003 | Verify processing metrics | Accurate record counts and timing |
| TC_AUD_004 | Test error classification | Errors correctly categorized by severity |
| TC_AUD_005 | Validate lineage tracking | Complete data lineage information |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

sources:
  - name: bronze
    description: "Bronze layer source tables"
    tables:
      - name: bz_users
        description: "Raw user data from Zoom platform"
      - name: bz_meetings
        description: "Raw meeting data from Zoom platform"
      - name: bz_participants
        description: "Raw participant data from Zoom platform"
      - name: bz_feature_usage
        description: "Raw feature usage data from Zoom platform"
      - name: bz_support_tickets
        description: "Raw support ticket data from Zoom platform"
      - name: bz_billing_events
        description: "Raw billing event data from Zoom platform"
      - name: bz_licenses
        description: "Raw license data from Zoom platform"
      - name: bz_webinars
        description: "Raw webinar data from Zoom platform"

models:
  - name: si_users
    description: "Silver layer user data with data quality validations"
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
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
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
      - name: data_quality_score
        description: "Data quality score for the record"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 1.00

  - name: si_meetings
    description: "Silver layer meeting data with calculated metrics"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
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
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: meeting_type
        description: "Type of meeting"
        tests:
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']

  - name: si_participants
    description: "Silver layer participant data with attendance metrics"
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
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id

  - name: si_feature_usage
    description: "Silver layer feature usage data with categorization"
    columns:
      - name: usage_id
        description: "Unique usage identifier"
        tests:
          - unique
          - not_null
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: feature_category
        description: "Category of the feature"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']

  - name: si_support_tickets
    description: "Silver layer support ticket data with resolution metrics"
    columns:
      - name: ticket_id
        description: "Unique ticket identifier"
        tests:
          - unique
          - not_null
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

  - name: si_billing_events
    description: "Silver layer billing event data with transaction details"
    columns:
      - name: event_id
        description: "Unique event identifier"
        tests:
          - unique
          - not_null
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

  - name: si_licenses
    description: "Silver layer license data with assignment details"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
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

  - name: si_webinars
    description: "Silver layer webinar data with engagement metrics"
    columns:
      - name: webinar_id
        description: "Unique webinar identifier"
        tests:
          - unique
          - not_null
      - name: registrants
        description: "Number of registrants"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
      - name: attendance_rate
        description: "Attendance rate percentage"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 100.00
```

### Custom SQL-based dbt Tests

#### 1. Test for Temporal Logic Validation

**File**: `tests/test_temporal_logic_validation.sql`

```sql
-- Test to ensure END_TIME is always >= START_TIME across all time-based models

WITH temporal_violations AS (
    -- Check meetings
    SELECT 
        'si_meetings' as model_name,
        meeting_id as record_id,
        start_time,
        end_time
    FROM {{ ref('si_meetings') }}
    WHERE end_time < start_time
    
    UNION ALL
    
    -- Check webinars
    SELECT 
        'si_webinars' as model_name,
        webinar_id as record_id,
        start_time,
        end_time
    FROM {{ ref('si_webinars') }}
    WHERE end_time < start_time
    
    UNION ALL
    
    -- Check participants
    SELECT 
        'si_participants' as model_name,
        participant_id as record_id,
        join_time as start_time,
        leave_time as end_time
    FROM {{ ref('si_participants') }}
    WHERE leave_time < join_time
        AND leave_time IS NOT NULL
)

SELECT *
FROM temporal_violations
```

#### 2. Test for Data Quality Score Validation

**File**: `tests/test_data_quality_scores.sql`

```sql
-- Test to ensure all data quality scores are within valid range (0.00 to 1.00)

WITH quality_score_violations AS (
    SELECT 'si_users' as model_name, user_id as record_id, data_quality_score
    FROM {{ ref('si_users') }}
    WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
    
    UNION ALL
    
    SELECT 'si_meetings', meeting_id, data_quality_score
    FROM {{ ref('si_meetings') }}
    WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
    
    UNION ALL
    
    SELECT 'si_participants', participant_id, data_quality_score
    FROM {{ ref('si_participants') }}
    WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
)

SELECT *
FROM quality_score_violations
```

#### 3. Test for Referential Integrity

**File**: `tests/test_referential_integrity.sql`

```sql
-- Test to ensure all foreign key relationships are maintained

WITH referential_violations AS (
    -- Check meetings -> users relationship
    SELECT 
        'si_meetings' as child_table,
        'si_users' as parent_table,
        meeting_id as child_id,
        host_id as foreign_key
    FROM {{ ref('si_meetings') }} m
    LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
    WHERE u.user_id IS NULL
        AND m.host_id IS NOT NULL
    
    UNION ALL
    
    -- Check participants -> meetings relationship
    SELECT 
        'si_participants',
        'si_meetings',
        participant_id,
        meeting_id
    FROM {{ ref('si_participants') }} p
    LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL
        AND p.meeting_id IS NOT NULL
)

SELECT *
FROM referential_violations
```

#### 4. Test for Business Logic Validation

**File**: `tests/test_business_logic_validation.sql`

```sql
-- Test to validate key business logic rules

WITH business_logic_violations AS (
    -- Test: Webinar attendees should not exceed registrants
    SELECT 
        'webinar_attendance_logic' as test_name,
        webinar_id as record_id,
        'Attendees exceed registrants' as violation_description
    FROM {{ ref('si_webinars') }}
    WHERE attendees > registrants
    
    UNION ALL
    
    -- Test: License end date should be after start date
    SELECT 
        'license_date_logic',
        license_id,
        'End date before start date'
    FROM {{ ref('si_licenses') }}
    WHERE end_date < start_date
    
    UNION ALL
    
    -- Test: Billing amounts should be positive except for refunds
    SELECT 
        'billing_amount_logic',
        event_id,
        'Negative amount for non-refund event'
    FROM {{ ref('si_billing_events') }}
    WHERE transaction_amount < 0
        AND event_type != 'Refund'
)

SELECT *
FROM business_logic_violations
```

#### 5. Test for Data Completeness

**File**: `tests/test_data_completeness.sql`

```sql
-- Test to ensure critical fields are not null across all models

WITH completeness_violations AS (
    -- Check users critical fields
    SELECT 
        'si_users' as model_name,
        user_id as record_id,
        'Missing email' as violation_type
    FROM {{ ref('si_users') }}
    WHERE email IS NULL OR TRIM(email) = ''
    
    UNION ALL
    
    -- Check meetings critical fields
    SELECT 
        'si_meetings',
        meeting_id,
        'Missing host_id'
    FROM {{ ref('si_meetings') }}
    WHERE host_id IS NULL
    
    UNION ALL
    
    -- Check participants critical fields
    SELECT 
        'si_participants',
        participant_id,
        'Missing join_time'
    FROM {{ ref('si_participants') }}
    WHERE join_time IS NULL
)

SELECT *
FROM completeness_violations
```

---

## Test Execution Guidelines

### 1. Test Execution Order
1. **Schema Tests**: Run basic schema validation tests first
2. **Custom SQL Tests**: Execute custom business logic tests
3. **Data Quality Tests**: Run comprehensive data quality validations
4. **Performance Tests**: Execute performance and volume tests

### 2. Test Environment Setup
- **Development**: Run all tests on sample data
- **Staging**: Execute full test suite on production-like data
- **Production**: Run critical tests only with monitoring

### 3. Test Monitoring and Alerting
- **Critical Failures**: Immediate alerts for referential integrity violations
- **Warning Thresholds**: Alerts when >5% of records fail quality checks
- **Trend Analysis**: Monitor test failure rates over time

### 4. Test Maintenance
- **Regular Review**: Monthly review of test effectiveness
- **Threshold Updates**: Adjust validation thresholds based on business changes
- **New Test Cases**: Add tests for new business rules and edge cases

---

## Expected Outcomes Summary

### Data Quality Metrics
- **Completeness**: >95% of critical fields populated
- **Validity**: >98% of records pass format validations
- **Consistency**: >99% of records pass business rule validations
- **Uniqueness**: 100% unique primary keys across all models
- **Referential Integrity**: 100% valid foreign key relationships

### Performance Benchmarks
- **Test Execution Time**: <5 minutes for full test suite
- **Data Processing**: <30 seconds per 100K records
- **Error Detection**: <1% false positive rate

### Business Value
- **Data Reliability**: Consistent, trustworthy data for analytics
- **Early Issue Detection**: Proactive identification of data quality issues
- **Compliance**: Adherence to data governance standards
- **Operational Excellence**: Automated quality assurance processes

This comprehensive unit test framework ensures the reliability and performance of dbt models in Snowflake by validating key transformations, business rules, edge cases, and error handling scenarios across all Silver layer models in the Zoom Platform Analytics System.