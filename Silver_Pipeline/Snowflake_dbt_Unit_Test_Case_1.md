# Snowflake dbt Unit Test Cases - Silver Layer
## Zoom Platform Analytics System

## 1. Overview

This document provides comprehensive unit test cases for the Silver layer models in the Zoom Platform Analytics System following the Medallion architecture. The test cases cover data quality validations, business rule enforcement, edge case handling, and referential integrity checks using dbt-compatible testing frameworks.

### Test Coverage Areas:
- **Happy Path Scenarios**: Valid data transformations and business logic
- **Edge Cases**: Null values, boundary conditions, and format variations
- **Exception Cases**: Data quality violations, referential integrity failures
- **Performance Tests**: Large dataset handling and optimization validation

### Testing Framework:
- **YAML-based Schema Tests**: Built-in dbt tests (unique, not_null, relationships, accepted_values)
- **Custom SQL Tests**: Complex business logic and data quality validations
- **Expression Tests**: Field-level validations and calculations

## 2. SI_USERS Table Test Cases

### 2.1 YAML Schema Tests

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
          - unique:
              severity: error
          - not_null:
              severity: error
              
      - name: email
        description: "Validated and standardized email address"
        tests:
          - not_null:
              severity: error
          - unique:
              severity: warn
              
      - name: plan_type
        description: "Standardized subscription tier"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
              severity: error
              
      - name: account_status
        description: "Current status of user account"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
              severity: error
              
      - name: data_quality_score
        description: "Overall data quality score for the record"
        tests:
          - not_null:
              severity: warn
```

### 2.2 Custom SQL Tests

#### Test Case 2.2.1: Email Format Validation
```sql
-- tests/silver/test_si_users_email_format.sql
-- Test: Validate email format using REGEXP_LIKE
-- Expected: All emails should match valid email pattern

SELECT 
    user_id,
    email,
    'Invalid email format' as test_failure_reason
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test Case 2.2.2: Data Quality Score Range Validation
```sql
-- tests/silver/test_si_users_data_quality_score_range.sql
-- Test: Validate data quality score is between 0.00 and 1.00
-- Expected: All scores should be within valid range

SELECT 
    user_id,
    data_quality_score,
    'Data quality score out of range' as test_failure_reason
FROM {{ ref('si_users') }}
WHERE data_quality_score IS NOT NULL 
  AND (data_quality_score < 0.00 OR data_quality_score > 1.00)
```

## 3. SI_MEETINGS Table Test Cases

### 3.1 YAML Schema Tests

```yaml
# models/silver/schema.yml (continued)
  - name: si_meetings
    description: "Silver layer cleaned and enriched meeting data"
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
              severity: error
```

### 3.2 Custom SQL Tests

#### Test Case 3.2.1: Temporal Logic Validation
```sql
-- tests/silver/test_si_meetings_temporal_logic.sql
-- Test: End time should be >= start time
-- Expected: No meetings with end time before start time

SELECT 
    meeting_id,
    start_time,
    end_time,
    'End time before start time' as test_failure_reason
FROM {{ ref('si_meetings') }}
WHERE end_time IS NOT NULL 
  AND start_time IS NOT NULL
  AND end_time < start_time
```

## 4. Cross-Table Referential Integrity Tests

### 4.1 Orphaned Records Detection

#### Test Case 4.1.1: Orphaned Meeting Participants
```sql
-- tests/silver/test_cross_table_orphaned_participants.sql
-- Test: All participants should reference valid meetings
-- Expected: No orphaned participant records

SELECT 
    p.participant_id,
    p.meeting_id,
    'Orphaned participant - meeting not found' as test_failure_reason
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
```

## 5. Test Execution Framework

### 5.1 dbt Test Configuration

```yaml
# dbt_project.yml
name: 'zoom_analytics'
version: '1.0.0'
config-version: 2

model-paths: ["models"]
test-paths: ["tests"]

models:
  zoom_analytics:
    silver:
      +materialized: table
      +tags: ["silver"]
      
tests:
  zoom_analytics:
    +severity: warn
    +tags: ["data_quality"]
```

### 5.2 Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific models
dbt test --models si_users
dbt test --models tag:silver

# Run tests with specific severity
dbt test --severity error
```