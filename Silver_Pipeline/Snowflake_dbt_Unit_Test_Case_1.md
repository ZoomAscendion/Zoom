_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics System Silver layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases
## Zoom Platform Analytics System - Silver Layer

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Silver layer dbt models in the Zoom Platform Analytics System. The tests ensure data quality, validate transformations, and verify business rules across all Silver layer models including `silver_meetings`, `silver_meeting_participants`, and `audit_log`.

## Test Coverage Overview

### Models Under Test:
- **silver_meetings.sql** - Clean meeting data with duration categorization and validation
- **silver_meeting_participants.sql** - Enriched participant data with calculated metrics
- **audit_log.sql** - Audit table structure for external orchestration

### Test Categories:
1. **Data Quality Tests** - Null checks, format validation, range validation
2. **Business Logic Tests** - Duration categorization, participation metrics, time logic
3. **Referential Integrity Tests** - Cross-table relationships and foreign key validation
4. **Edge Case Tests** - Boundary conditions, invalid data handling
5. **Performance Tests** - Data volume and processing efficiency validation

---

## Test Case List

### **Test Case ID: TC_SM_001**
**Test Case Description**: Validate silver_meetings model data quality and transformations
**Expected Outcome**: All meeting records pass validation with proper duration categorization and clean timestamps

### **Test Case ID: TC_SMP_001** 
**Test Case Description**: Validate silver_meeting_participants model enrichment and metrics calculation
**Expected Outcome**: All participant records have calculated participation percentages and late join/early leave detection

### **Test Case ID: TC_AL_001**
**Test Case Description**: Validate audit_log model structure and data capture
**Expected Outcome**: Audit records properly capture all pipeline execution details with timestamps

### **Test Case ID: TC_DQ_001**
**Test Case Description**: Comprehensive data quality validation across all Silver models
**Expected Outcome**: Data quality scores ≥ 70 for all records, validation status properly set

### **Test Case ID: TC_RI_001**
**Test Case Description**: Referential integrity validation between Silver models
**Expected Outcome**: All foreign key relationships maintained, no orphaned records

### **Test Case ID: TC_BL_001**
**Test Case Description**: Business logic validation for meeting classification and metrics
**Expected Outcome**: Meeting duration categories correctly assigned, participation metrics accurately calculated

### **Test Case ID: TC_EC_001**
**Test Case Description**: Edge case handling for invalid data and boundary conditions
**Expected Outcome**: Invalid records properly handled, error logging functional

### **Test Case ID: TC_TF_001**
**Test Case Description**: Timestamp format validation and conversion testing
**Expected Outcome**: All timestamp formats properly converted, EST and MM/DD/YYYY formats handled

---

## dbt Test Scripts

### **YAML-based Schema Tests**

#### **models/silver/schema.yml**

```yaml
version: 2

models:
  - name: silver_meetings
    description: "Clean meeting data with duration categorization and validation"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('silver_users')
              field: user_id
      - name: start_time
        description: "Meeting start timestamp (standardized)"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp (standardized)"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes (validated)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440
      - name: duration_category
        description: "Meeting duration classification"
        tests:
          - accepted_values:
              values: ['Short', 'Medium', 'Long', 'Extended']
      - name: meeting_hour
        description: "Hour component extracted from start time"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 23
      - name: meeting_day_of_week
        description: "Day of week (1=Monday, 7=Sunday)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 7
      - name: data_quality_score
        description: "Quality score from validation process (0-100)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Status of data validation"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']

  - name: silver_meeting_participants
    description: "Enriched participant data with calculated metrics"
    columns:
      - name: participant_id
        description: "Unique identifier for each meeting participant"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('silver_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - relationships:
              to: ref('silver_users')
              field: user_id
      - name: join_time
        description: "Timestamp when participant joined (standardized)"
        tests:
          - not_null
      - name: leave_time
        description: "Timestamp when participant left (standardized)"
        tests:
          - not_null
      - name: participation_duration_minutes
        description: "Duration of participation in minutes"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440
      - name: participation_percentage
        description: "Percentage of meeting attended"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
      - name: is_late_join
        description: "Boolean flag for late join detection"
        tests:
          - accepted_values:
              values: [true, false]
      - name: is_early_leave
        description: "Boolean flag for early leave detection"
        tests:
          - accepted_values:
              values: [true, false]
      - name: data_quality_score
        description: "Quality score from validation process (0-100)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Status of data validation"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']

  - name: audit_log
    description: "Audit table structure for external orchestration"
    columns:
      - name: execution_id
        description: "Unique identifier for each pipeline execution"
        tests:
          - unique
          - not_null
      - name: pipeline_name
        description: "Name of the executed pipeline"
        tests:
          - not_null
      - name: execution_status
        description: "Status of pipeline execution"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'RUNNING', 'CANCELLED']
      - name: execution_start_time
        description: "Pipeline execution start timestamp"
        tests:
          - not_null
      - name: records_processed
        description: "Number of records processed"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 999999999
```

### **Custom SQL-based dbt Tests**

#### **tests/silver_meetings_duration_logic.sql**

```sql
-- Test: Validate meeting duration logic consistency
-- Expected: End time should be after start time and duration should match calculated difference

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration
FROM {{ ref('silver_meetings') }}
WHERE 
    end_time <= start_time
    OR ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
    OR duration_minutes IS NULL
    OR start_time IS NULL
    OR end_time IS NULL
```

#### **tests/silver_meetings_duration_category.sql**

```sql
-- Test: Validate meeting duration categorization business rules
-- Expected: Duration categories should match business logic (Short ≤15, Medium ≤60, Long ≤180, Extended >180)

SELECT 
    meeting_id,
    duration_minutes,
    duration_category,
    CASE 
        WHEN duration_minutes <= 15 THEN 'Short'
        WHEN duration_minutes <= 60 THEN 'Medium'
        WHEN duration_minutes <= 180 THEN 'Long'
        ELSE 'Extended'
    END as expected_category
FROM {{ ref('silver_meetings') }}
WHERE 
    duration_category != CASE 
        WHEN duration_minutes <= 15 THEN 'Short'
        WHEN duration_minutes <= 60 THEN 'Medium'
        WHEN duration_minutes <= 180 THEN 'Long'
        ELSE 'Extended'
    END
    OR duration_category IS NULL
```

#### **tests/silver_participants_session_logic.sql**

```sql
-- Test: Validate participant session time logic
-- Expected: Leave time should be after join time and within meeting boundaries

SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time as meeting_start,
    m.end_time as meeting_end
FROM {{ ref('silver_meeting_participants') }} p
JOIN {{ ref('silver_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE 
    p.leave_time <= p.join_time
    OR p.join_time < m.start_time - INTERVAL '5 minutes'  -- Allow 5 min early join
    OR p.leave_time > m.end_time + INTERVAL '5 minutes'   -- Allow 5 min late leave
    OR p.join_time IS NULL
    OR p.leave_time IS NULL
```

#### **tests/silver_participants_metrics_validation.sql**

```sql
-- Test: Validate participant metrics calculations
-- Expected: Participation percentage should be accurate and late join/early leave flags correct

SELECT 
    p.participant_id,
    p.participation_duration_minutes,
    p.participation_percentage,
    p.is_late_join,
    p.is_early_leave,
    DATEDIFF('minute', p.join_time, p.leave_time) as calculated_duration,
    ROUND((DATEDIFF('minute', p.join_time, p.leave_time) * 100.0 / m.duration_minutes), 2) as calculated_percentage
FROM {{ ref('silver_meeting_participants') }} p
JOIN {{ ref('silver_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE 
    ABS(p.participation_duration_minutes - DATEDIFF('minute', p.join_time, p.leave_time)) > 1
    OR ABS(p.participation_percentage - ROUND((DATEDIFF('minute', p.join_time, p.leave_time) * 100.0 / m.duration_minutes), 2)) > 1
    OR p.participation_percentage < 0
    OR p.participation_percentage > 100
```

#### **tests/silver_referential_integrity.sql**

```sql
-- Test: Validate referential integrity across Silver models
-- Expected: No orphaned records, all foreign keys valid

WITH orphaned_participants AS (
    SELECT 'orphaned_participants' as error_type, COUNT(*) as error_count
    FROM {{ ref('silver_meeting_participants') }} p
    LEFT JOIN {{ ref('silver_meetings') }} m ON p.meeting_id = m.meeting_id
    WHERE m.meeting_id IS NULL
),
orphaned_meetings AS (
    SELECT 'orphaned_meetings' as error_type, COUNT(*) as error_count
    FROM {{ ref('silver_meetings') }} m
    LEFT JOIN {{ ref('silver_users') }} u ON m.host_id = u.user_id
    WHERE u.user_id IS NULL AND m.host_id IS NOT NULL
)
SELECT error_type, error_count
FROM orphaned_participants
WHERE error_count > 0
UNION ALL
SELECT error_type, error_count
FROM orphaned_meetings
WHERE error_count > 0
```

#### **tests/silver_data_quality_scores.sql**

```sql
-- Test: Validate data quality scores across all Silver models
-- Expected: Data quality scores should be ≥ 70 for production data

WITH quality_check AS (
    SELECT 
        'silver_meetings' as model_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN data_quality_score < 70 THEN 1 END) as low_quality_records,
        AVG(data_quality_score) as avg_quality_score
    FROM {{ ref('silver_meetings') }}
    WHERE data_quality_score IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'silver_meeting_participants' as model_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN data_quality_score < 70 THEN 1 END) as low_quality_records,
        AVG(data_quality_score) as avg_quality_score
    FROM {{ ref('silver_meeting_participants') }}
    WHERE data_quality_score IS NOT NULL
)
SELECT 
    model_name,
    total_records,
    low_quality_records,
    avg_quality_score,
    ROUND((low_quality_records * 100.0 / total_records), 2) as low_quality_percentage
FROM quality_check
WHERE low_quality_records > 0 OR avg_quality_score < 70
```

#### **tests/silver_timestamp_format_validation.sql**

```sql
-- Test: Validate timestamp format conversion and standardization
-- Expected: All timestamps should be in standard Snowflake format, no conversion failures

WITH timestamp_validation AS (
    SELECT 
        'silver_meetings' as model_name,
        'start_time' as column_name,
        meeting_id as record_id,
        start_time,
        CASE 
            WHEN start_time::STRING LIKE '%EST%' THEN 'EST_FORMAT_DETECTED'
            WHEN start_time IS NULL THEN 'NULL_VALUE'
            ELSE 'VALID_FORMAT'
        END as format_status
    FROM {{ ref('silver_meetings') }}
    
    UNION ALL
    
    SELECT 
        'silver_meeting_participants' as model_name,
        'join_time' as column_name,
        participant_id as record_id,
        join_time::STRING as timestamp_value,
        CASE 
            WHEN join_time::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 'MM_DD_YYYY_FORMAT_DETECTED'
            WHEN join_time IS NULL THEN 'NULL_VALUE'
            ELSE 'VALID_FORMAT'
        END as format_status
    FROM {{ ref('silver_meeting_participants') }}
)
SELECT 
    model_name,
    column_name,
    record_id,
    format_status,
    COUNT(*) as record_count
FROM timestamp_validation
WHERE format_status IN ('EST_FORMAT_DETECTED', 'MM_DD_YYYY_FORMAT_DETECTED')
GROUP BY model_name, column_name, record_id, format_status
```

#### **tests/silver_duration_text_cleaning.sql**

```sql
-- Test: Validate duration text unit cleaning (Critical P1 fix)
-- Expected: No text units like "mins" should remain in numeric duration fields

SELECT 
    meeting_id,
    duration_minutes,
    duration_minutes::STRING as duration_string,
    'TEXT_UNITS_DETECTED' as error_type
FROM {{ ref('silver_meetings') }}
WHERE duration_minutes::STRING REGEXP '[a-zA-Z]'
   OR duration_minutes::STRING LIKE '%mins%'
   OR duration_minutes::STRING LIKE '%minutes%'
   OR duration_minutes::STRING LIKE '%hrs%'
   OR duration_minutes::STRING LIKE '%hours%'
```

#### **tests/silver_date_format_validation.sql**

```sql
-- Test: Validate DD/MM/YYYY date format conversion (Critical P1 fix)
-- Expected: All dates should be in standard YYYY-MM-DD format

WITH date_validation AS (
    SELECT 
        'silver_licenses' as model_name,
        license_id as record_id,
        start_date,
        end_date,
        CASE 
            WHEN start_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 'DD_MM_YYYY_FORMAT_DETECTED'
            WHEN start_date IS NULL THEN 'NULL_VALUE'
            ELSE 'VALID_FORMAT'
        END as start_date_status,
        CASE 
            WHEN end_date::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 'DD_MM_YYYY_FORMAT_DETECTED'
            WHEN end_date IS NULL THEN 'NULL_VALUE'
            ELSE 'VALID_FORMAT'
        END as end_date_status
    FROM {{ ref('silver_licenses') }}
)
SELECT 
    model_name,
    record_id,
    start_date,
    end_date,
    start_date_status,
    end_date_status
FROM date_validation
WHERE start_date_status = 'DD_MM_YYYY_FORMAT_DETECTED'
   OR end_date_status = 'DD_MM_YYYY_FORMAT_DETECTED'
```

### **Parameterized Tests for Reusability**

#### **macros/test_data_freshness.sql**

```sql
{% macro test_data_freshness(model_name, timestamp_column, max_hours=24) %}
    SELECT 
        '{{ model_name }}' as model_name,
        MAX({{ timestamp_column }}) as latest_timestamp,
        DATEDIFF('hour', MAX({{ timestamp_column }}), CURRENT_TIMESTAMP()) as hours_since_last_update
    FROM {{ ref(model_name) }}
    WHERE DATEDIFF('hour', MAX({{ timestamp_column }}), CURRENT_TIMESTAMP()) > {{ max_hours }}
{% endmacro %}
```

#### **macros/test_record_count_stability.sql**

```sql
{% macro test_record_count_stability(model_name, min_expected_records=1) %}
    SELECT 
        '{{ model_name }}' as model_name,
        COUNT(*) as current_record_count,
        {{ min_expected_records }} as min_expected_records
    FROM {{ ref(model_name) }}
    WHERE COUNT(*) < {{ min_expected_records }}
{% endmacro %}
```

---

## Test Execution Strategy

### **Priority Levels**

1. **Critical (P1)**: 
   - Null value validation
   - Referential integrity
   - Business logic constraints
   - Timestamp format validation
   - Duration text cleaning
   - Date format conversion

2. **High (P2)**:
   - Data format validation
   - Range checks
   - Uniqueness constraints
   - Timezone conversion validation

3. **Medium (P3)**:
   - Business rule calculations
   - Cross-table consistency
   - Performance metrics

4. **Low (P4)**:
   - Data quality scoring
   - Audit trail validation

### **Automated Test Execution**

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --models silver_meetings

# Run tests by tag
dbt test --models tag:data_quality

# Run critical tests only
dbt test --models tag:critical
```

### **Test Results Tracking**

Test results are automatically tracked in:
- **dbt's run_results.json** - Detailed test execution results
- **Snowflake audit schema** - Test execution logs and metrics
- **SI_PIPELINE_EXECUTION_LOG** - Pipeline-level test summary
- **SI_DATA_QUALITY_ERRORS** - Failed test details and error tracking

---

## Error Handling and Remediation

### **Test Failure Response**

1. **Immediate Actions**:
   - Log failure details to audit tables
   - Send alerts to data engineering team
   - Quarantine failed records if applicable

2. **Investigation Process**:
   - Review test failure logs
   - Analyze source data quality
   - Identify root cause (data issue vs. logic issue)

3. **Remediation Steps**:
   - Fix data quality issues at source
   - Update transformation logic if needed
   - Re-run tests after fixes
   - Update test cases if business rules change

### **Monitoring and Alerting**

- **Daily Test Execution**: Automated runs with email alerts on failures
- **Data Quality Dashboard**: Real-time monitoring of test results
- **SLA Tracking**: Test execution time and success rate metrics
- **Escalation Procedures**: Defined escalation path for persistent failures

---

## Maintenance and Updates

### **Test Case Maintenance**

- **Monthly Review**: Assess test effectiveness and coverage
- **Quarterly Updates**: Add new tests for new business rules
- **Annual Audit**: Comprehensive review of all test cases

### **Performance Optimization**

- **Test Execution Time**: Monitor and optimize slow-running tests
- **Resource Usage**: Balance test coverage with compute costs
- **Parallel Execution**: Leverage dbt's parallel test execution capabilities

---

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics System Silver layer dbt models. The tests cover critical data quality aspects, business logic validation, and edge case handling, providing confidence in the data pipeline's output quality.

**Key Benefits**:
- ✅ **Comprehensive Coverage**: Tests all critical aspects of Silver layer models
- ✅ **Automated Execution**: Integrated with dbt's testing framework
- ✅ **Business Rule Validation**: Ensures compliance with business requirements
- ✅ **Error Detection**: Early identification of data quality issues
- ✅ **Audit Trail**: Complete tracking of test execution and results
- ✅ **Scalable Framework**: Easily extensible for new models and requirements

**Next Steps**:
1. Execute initial test run to establish baseline
2. Set up automated daily test execution
3. Configure monitoring and alerting
4. Train team on test maintenance procedures
5. Establish SLAs for test execution and remediation

---

**API Cost Consumed**: 0.003750 (USD)

**Note**: These unit test cases are designed to work with Snowflake's SQL dialect and dbt's testing framework, ensuring compatibility with the existing infrastructure and providing robust validation of the Silver layer data transformations.