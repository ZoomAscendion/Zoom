_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive Silver layer data mapping for Zoom Platform Analytics System with cleansing, validations, and business rules
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer in the Medallion architecture for the Zoom Platform Analytics System. The mapping incorporates necessary data cleansing, validation rules, and business transformations to ensure high-quality, consistent data for downstream analytics and reporting.

**Key Mapping Principles:**
- All Bronze layer tables are mapped to corresponding Silver layer tables with cleansing and validation
- Data quality checks are implemented based on business rules and constraints
- Referential integrity is validated across related tables
- Error records are captured in the Silver error table for monitoring and resolution
- Audit trail is maintained through the Silver pipeline audit table
- Transformation rules ensure data consistency and business rule compliance

## 2. Data Mapping for the Silver Layer

### 2.1 Si_USERS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_USERS | USER_ID | Bronze | BZ_USERS | USER_ID | Not null, Unique | TRIM(UPPER(USER_ID)) |
| Silver | Si_USERS | USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null, Length <= 255 | TRIM(USER_NAME) |
| Silver | Si_USERS | EMAIL | Bronze | BZ_USERS | EMAIL | Valid email format, Not null | TRIM(LOWER(EMAIL)) |
| Silver | Si_USERS | COMPANY | Bronze | BZ_USERS | COMPANY | Length <= 255 | TRIM(COMPANY) |
| Silver | Si_USERS | PLAN_TYPE | Bronze | BZ_USERS | PLAN_TYPE | Must be in ('Free', 'Basic', 'Pro', 'Enterprise') | TRIM(UPPER(PLAN_TYPE)) |
| Silver | Si_USERS | LOAD_TIMESTAMP | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_USERS | UPDATE_TIMESTAMP | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_USERS | SOURCE_SYSTEM | Bronze | BZ_USERS | SOURCE_SYSTEM | Not null, Not empty | TRIM(SOURCE_SYSTEM) |
| Silver | Si_USERS | LOAD_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_USERS | UPDATE_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |

### 2.2 Si_MEETINGS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_MEETINGS | MEETING_ID | Bronze | BZ_MEETINGS | MEETING_ID | Not null, Unique | TRIM(UPPER(MEETING_ID)) |
| Silver | Si_MEETINGS | HOST_ID | Bronze | BZ_MEETINGS | HOST_ID | Not null, Must exist in Si_USERS.USER_ID | TRIM(UPPER(HOST_ID)) |
| Silver | Si_MEETINGS | MEETING_TOPIC | Bronze | BZ_MEETINGS | MEETING_TOPIC | Length <= 500 | TRIM(MEETING_TOPIC) |
| Silver | Si_MEETINGS | START_TIME | Bronze | BZ_MEETINGS | START_TIME | Not null, Valid timestamp | Direct mapping |
| Silver | Si_MEETINGS | END_TIME | Bronze | BZ_MEETINGS | END_TIME | Not null, Valid timestamp, Must be > START_TIME | Direct mapping |
| Silver | Si_MEETINGS | DURATION_MINUTES | Bronze | BZ_MEETINGS | DURATION_MINUTES | Not null, >= 0, Must equal DATEDIFF('minute', START_TIME, END_TIME) | DATEDIFF('minute', START_TIME, END_TIME) |
| Silver | Si_MEETINGS | LOAD_TIMESTAMP | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_MEETINGS | UPDATE_TIMESTAMP | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_MEETINGS | SOURCE_SYSTEM | Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Not null, Not empty | TRIM(SOURCE_SYSTEM) |
| Silver | Si_MEETINGS | LOAD_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_MEETINGS | UPDATE_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |

### 2.3 Si_PARTICIPANTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_PARTICIPANTS | PARTICIPANT_ID | Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Not null, Unique | TRIM(UPPER(PARTICIPANT_ID)) |
| Silver | Si_PARTICIPANTS | MEETING_ID | Bronze | BZ_PARTICIPANTS | MEETING_ID | Not null, Must exist in Si_MEETINGS.MEETING_ID | TRIM(UPPER(MEETING_ID)) |
| Silver | Si_PARTICIPANTS | USER_ID | Bronze | BZ_PARTICIPANTS | USER_ID | Not null, Must exist in Si_USERS.USER_ID | TRIM(UPPER(USER_ID)) |
| Silver | Si_PARTICIPANTS | JOIN_TIME | Bronze | BZ_PARTICIPANTS | JOIN_TIME | Not null, Valid timestamp, Must be >= meeting START_TIME | Direct mapping |
| Silver | Si_PARTICIPANTS | LEAVE_TIME | Bronze | BZ_PARTICIPANTS | LEAVE_TIME | Not null, Valid timestamp, Must be > JOIN_TIME and <= meeting END_TIME | Direct mapping |
| Silver | Si_PARTICIPANTS | LOAD_TIMESTAMP | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_PARTICIPANTS | UPDATE_TIMESTAMP | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_PARTICIPANTS | SOURCE_SYSTEM | Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Not null, Not empty | TRIM(SOURCE_SYSTEM) |
| Silver | Si_PARTICIPANTS | LOAD_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_PARTICIPANTS | UPDATE_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |

### 2.4 Si_FEATURE_USAGE Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_FEATURE_USAGE | USAGE_ID | Bronze | BZ_FEATURE_USAGE | USAGE_ID | Not null, Unique | TRIM(UPPER(USAGE_ID)) |
| Silver | Si_FEATURE_USAGE | MEETING_ID | Bronze | BZ_FEATURE_USAGE | MEETING_ID | Not null, Must exist in Si_MEETINGS.MEETING_ID | TRIM(UPPER(MEETING_ID)) |
| Silver | Si_FEATURE_USAGE | FEATURE_NAME | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Not null, Length <= 100, Standardized naming | TRIM(UPPER(FEATURE_NAME)) |
| Silver | Si_FEATURE_USAGE | USAGE_COUNT | Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | Not null, >= 0 | Direct mapping |
| Silver | Si_FEATURE_USAGE | USAGE_DATE | Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Not null, Valid date, Must align with meeting date | Direct mapping |
| Silver | Si_FEATURE_USAGE | LOAD_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_FEATURE_USAGE | UPDATE_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_FEATURE_USAGE | SOURCE_SYSTEM | Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Not null, Not empty | TRIM(SOURCE_SYSTEM) |
| Silver | Si_FEATURE_USAGE | LOAD_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_FEATURE_USAGE | UPDATE_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |

### 2.5 Si_SUPPORT_TICKETS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_SUPPORT_TICKETS | TICKET_ID | Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Not null, Unique | TRIM(UPPER(TICKET_ID)) |
| Silver | Si_SUPPORT_TICKETS | USER_ID | Bronze | BZ_SUPPORT_TICKETS | USER_ID | Not null, Must exist in Si_USERS.USER_ID | TRIM(UPPER(USER_ID)) |
| Silver | Si_SUPPORT_TICKETS | TICKET_TYPE | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Not null, Standardized categories | TRIM(UPPER(TICKET_TYPE)) |
| Silver | Si_SUPPORT_TICKETS | RESOLUTION_STATUS | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Not null, Must be in ('Open', 'In Progress', 'Resolved', 'Closed') | TRIM(UPPER(RESOLUTION_STATUS)) |
| Silver | Si_SUPPORT_TICKETS | OPEN_DATE | Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Not null, Valid date, Not in future | Direct mapping |
| Silver | Si_SUPPORT_TICKETS | LOAD_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_SUPPORT_TICKETS | SOURCE_SYSTEM | Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Not null, Not empty | TRIM(SOURCE_SYSTEM) |
| Silver | Si_SUPPORT_TICKETS | LOAD_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_SUPPORT_TICKETS | UPDATE_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |

### 2.6 Si_BILLING_EVENTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_BILLING_EVENTS | EVENT_ID | Bronze | BZ_BILLING_EVENTS | EVENT_ID | Not null, Unique | TRIM(UPPER(EVENT_ID)) |
| Silver | Si_BILLING_EVENTS | USER_ID | Bronze | BZ_BILLING_EVENTS | USER_ID | Not null, Must exist in Si_USERS.USER_ID | TRIM(UPPER(USER_ID)) |
| Silver | Si_BILLING_EVENTS | EVENT_TYPE | Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Not null, Standardized billing categories, Length <= 100 | TRIM(UPPER(EVENT_TYPE)) |
| Silver | Si_BILLING_EVENTS | AMOUNT | Bronze | BZ_BILLING_EVENTS | AMOUNT | Not null, > 0, Decimal precision = 2 | ROUND(AMOUNT, 2) |
| Silver | Si_BILLING_EVENTS | EVENT_DATE | Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Not null, Valid date, Not in future | Direct mapping |
| Silver | Si_BILLING_EVENTS | LOAD_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_BILLING_EVENTS | UPDATE_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_BILLING_EVENTS | SOURCE_SYSTEM | Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Not null, Not empty | TRIM(SOURCE_SYSTEM) |
| Silver | Si_BILLING_EVENTS | LOAD_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_BILLING_EVENTS | UPDATE_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |

### 2.7 Si_LICENSES Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_LICENSES | LICENSE_ID | Bronze | BZ_LICENSES | LICENSE_ID | Not null, Unique | TRIM(UPPER(LICENSE_ID)) |
| Silver | Si_LICENSES | ASSIGNED_TO_USER_ID | Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Not null, Must exist in Si_USERS.USER_ID | TRIM(UPPER(ASSIGNED_TO_USER_ID)) |
| Silver | Si_LICENSES | LICENSE_TYPE | Bronze | BZ_LICENSES | LICENSE_TYPE | Not null, Predefined license categories, Length <= 100 | TRIM(UPPER(LICENSE_TYPE)) |
| Silver | Si_LICENSES | START_DATE | Bronze | BZ_LICENSES | START_DATE | Not null, Valid date | Direct mapping |
| Silver | Si_LICENSES | END_DATE | Bronze | BZ_LICENSES | END_DATE | Not null, Valid date, Must be > START_DATE | Direct mapping |
| Silver | Si_LICENSES | LOAD_TIMESTAMP | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_LICENSES | UPDATE_TIMESTAMP | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not null, Valid timestamp | Direct mapping |
| Silver | Si_LICENSES | SOURCE_SYSTEM | Bronze | BZ_LICENSES | SOURCE_SYSTEM | Not null, Not empty | TRIM(SOURCE_SYSTEM) |
| Silver | Si_LICENSES | LOAD_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_LICENSES | UPDATE_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |

### 2.8 Si_DATA_QUALITY_ERRORS Table Mapping (Error Data Table)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_DATA_QUALITY_ERRORS | ERROR_ID | Silver | - | - | Not null, Unique | GENERATE_UUID() |
| Silver | Si_DATA_QUALITY_ERRORS | ERROR_TYPE | Silver | - | - | Not null, Predefined error types | Error classification logic |
| Silver | Si_DATA_QUALITY_ERRORS | ERROR_DESCRIPTION | Silver | - | - | Not null, Descriptive message | Error description generation |
| Silver | Si_DATA_QUALITY_ERRORS | SOURCE_TABLE | Silver | - | - | Not null, Valid table name | Source table identification |
| Silver | Si_DATA_QUALITY_ERRORS | SOURCE_COLUMN | Silver | - | - | Valid column name | Source column identification |
| Silver | Si_DATA_QUALITY_ERRORS | ERROR_VALUE | Silver | - | - | Actual error value | CAST(error_value AS VARCHAR) |
| Silver | Si_DATA_QUALITY_ERRORS | EXPECTED_VALUE | Silver | - | - | Expected value format | Expected value specification |
| Silver | Si_DATA_QUALITY_ERRORS | SEVERITY_LEVEL | Silver | - | - | Must be in ('Critical', 'High', 'Medium', 'Low') | Error severity classification |
| Silver | Si_DATA_QUALITY_ERRORS | ERROR_TIMESTAMP | Silver | - | - | Not null, Valid timestamp | CURRENT_TIMESTAMP() |
| Silver | Si_DATA_QUALITY_ERRORS | VALIDATION_RULE | Silver | - | - | Not null, Rule name | Validation rule identification |
| Silver | Si_DATA_QUALITY_ERRORS | ERROR_COUNT | Silver | - | - | >= 1 | COUNT(*) of affected records |
| Silver | Si_DATA_QUALITY_ERRORS | RESOLUTION_STATUS | Silver | - | - | Must be in ('Open', 'In Progress', 'Resolved', 'Ignored') | Default: 'Open' |
| Silver | Si_DATA_QUALITY_ERRORS | RESOLVED_BY | Silver | - | - | Valid user/process name | User/process resolution tracking |
| Silver | Si_DATA_QUALITY_ERRORS | RESOLUTION_TIMESTAMP | Silver | - | - | Valid timestamp when resolved | Resolution timestamp |
| Silver | Si_DATA_QUALITY_ERRORS | LOAD_TIMESTAMP | Silver | - | - | Not null, Valid timestamp | CURRENT_TIMESTAMP() |
| Silver | Si_DATA_QUALITY_ERRORS | LOAD_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_DATA_QUALITY_ERRORS | UPDATE_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_DATA_QUALITY_ERRORS | SOURCE_SYSTEM | Silver | - | - | Not null, Not empty | 'SILVER_LAYER_VALIDATION' |

### 2.9 Si_PIPELINE_AUDIT Table Mapping (Audit Table)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_PIPELINE_AUDIT | AUDIT_ID | Silver | - | - | Not null, Unique | GENERATE_UUID() |
| Silver | Si_PIPELINE_AUDIT | EXECUTION_ID | Silver | - | - | Not null, Unique per execution | Pipeline execution identifier |
| Silver | Si_PIPELINE_AUDIT | PIPELINE_NAME | Silver | - | - | Not null, Valid pipeline name | Pipeline name identification |
| Silver | Si_PIPELINE_AUDIT | PIPELINE_RUN_ID | Silver | - | - | Not null, Unique per run | Pipeline run identifier |
| Silver | Si_PIPELINE_AUDIT | EXECUTION_STATUS | Silver | - | - | Must be in ('Started', 'Running', 'Completed', 'Failed', 'Cancelled') | Pipeline execution status |
| Silver | Si_PIPELINE_AUDIT | START_TIMESTAMP | Silver | - | - | Not null, Valid timestamp | Pipeline start time |
| Silver | Si_PIPELINE_AUDIT | END_TIMESTAMP | Silver | - | - | Valid timestamp, Must be > START_TIMESTAMP | Pipeline end time |
| Silver | Si_PIPELINE_AUDIT | EXECUTION_DURATION | Silver | - | - | >= 0, In seconds | DATEDIFF('second', START_TIMESTAMP, END_TIMESTAMP) |
| Silver | Si_PIPELINE_AUDIT | RECORDS_PROCESSED | Silver | - | - | >= 0 | Total records processed count |
| Silver | Si_PIPELINE_AUDIT | RECORDS_SUCCESS | Silver | - | - | >= 0, <= RECORDS_PROCESSED | Successful records count |
| Silver | Si_PIPELINE_AUDIT | RECORDS_FAILED | Silver | - | - | >= 0, <= RECORDS_PROCESSED | Failed records count |
| Silver | Si_PIPELINE_AUDIT | RECORDS_SKIPPED | Silver | - | - | >= 0, <= RECORDS_PROCESSED | Skipped records count |
| Silver | Si_PIPELINE_AUDIT | SOURCE_SYSTEM | Silver | - | - | Not null, Not empty | Source system identification |
| Silver | Si_PIPELINE_AUDIT | TARGET_TABLE | Silver | - | - | Not null, Valid table name | Target table identification |
| Silver | Si_PIPELINE_AUDIT | PIPELINE_VERSION | Silver | - | - | Not null, Version format | Pipeline version tracking |
| Silver | Si_PIPELINE_AUDIT | EXECUTED_BY | Silver | - | - | Not null, Valid user/service | Execution user/service tracking |
| Silver | Si_PIPELINE_AUDIT | ERROR_MESSAGE | Silver | - | - | Error message when failed | Error message capture |
| Silver | Si_PIPELINE_AUDIT | CONFIGURATION_PARAMS | Silver | - | - | Valid JSON format | Pipeline configuration parameters |
| Silver | Si_PIPELINE_AUDIT | PERFORMANCE_METRICS | Silver | - | - | Valid JSON format | Performance metrics capture |
| Silver | Si_PIPELINE_AUDIT | DATA_LINEAGE_INFO | Silver | - | - | Valid JSON format | Data lineage information |
| Silver | Si_PIPELINE_AUDIT | LOAD_TIMESTAMP | Silver | - | - | Not null, Valid timestamp | CURRENT_TIMESTAMP() |
| Silver | Si_PIPELINE_AUDIT | LOAD_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |
| Silver | Si_PIPELINE_AUDIT | UPDATE_DATE | Silver | - | - | Not null | DATE(CURRENT_TIMESTAMP()) |

## 3. Data Quality and Validation Rules Summary

### 3.1 Critical Validation Rules

1. **Uniqueness Constraints:**
   - USER_ID must be unique in Si_USERS
   - MEETING_ID must be unique in Si_MEETINGS
   - PARTICIPANT_ID must be unique in Si_PARTICIPANTS
   - USAGE_ID must be unique in Si_FEATURE_USAGE
   - TICKET_ID must be unique in Si_SUPPORT_TICKETS
   - EVENT_ID must be unique in Si_BILLING_EVENTS
   - LICENSE_ID must be unique in Si_LICENSES

2. **Referential Integrity:**
   - HOST_ID in Si_MEETINGS must exist in Si_USERS.USER_ID
   - MEETING_ID in Si_PARTICIPANTS must exist in Si_MEETINGS.MEETING_ID
   - USER_ID in Si_PARTICIPANTS must exist in Si_USERS.USER_ID
   - MEETING_ID in Si_FEATURE_USAGE must exist in Si_MEETINGS.MEETING_ID
   - USER_ID in Si_SUPPORT_TICKETS must exist in Si_USERS.USER_ID
   - USER_ID in Si_BILLING_EVENTS must exist in Si_USERS.USER_ID
   - ASSIGNED_TO_USER_ID in Si_LICENSES must exist in Si_USERS.USER_ID

3. **Business Logic Constraints:**
   - Meeting END_TIME must be after START_TIME
   - DURATION_MINUTES must equal calculated difference between END_TIME and START_TIME
   - Participant LEAVE_TIME must be after JOIN_TIME
   - Participant session times must be within meeting duration boundaries
   - License END_DATE must be after START_DATE
   - AMOUNT in billing events must be positive with 2 decimal precision

4. **Data Format Validations:**
   - Email addresses must follow valid email format
   - PLAN_TYPE must be from enumerated values
   - RESOLUTION_STATUS must be from predefined status values
   - All timestamp fields must be valid timestamps
   - All date fields must be valid dates and not in the future

### 3.2 Error Handling and Logging

**Error Capture Strategy:**
- All validation failures are logged in Si_DATA_QUALITY_ERRORS table
- Error records include detailed information about the validation failure
- Severity levels are assigned based on business impact
- Resolution tracking is maintained for all errors

**Audit Trail:**
- All pipeline executions are logged in Si_PIPELINE_AUDIT table
- Performance metrics and data lineage information are captured
- Success and failure counts are tracked for monitoring
- Configuration parameters are stored for reproducibility

### 3.3 Data Cleansing Rules

1. **String Standardization:**
   - TRIM() applied to all string fields to remove leading/trailing spaces
   - UPPER() applied to ID fields for consistency
   - LOWER() applied to email addresses for standardization

2. **Data Type Conversions:**
   - Numeric fields are validated for proper data types
   - Timestamp fields are validated for proper format
   - Decimal precision is enforced for monetary amounts

3. **Null Handling:**
   - Critical fields are validated for NOT NULL constraints
   - Optional fields allow NULL values but are validated when present
   - Default values are applied where appropriate

## 4. Implementation Recommendations

### 4.1 ETL Process Design

1. **Staged Processing:**
   - Implement validation in stages: format validation, business rule validation, referential integrity
   - Use temporary staging tables for complex validations
   - Implement rollback mechanisms for failed batches

2. **Error Handling:**
   - Implement comprehensive error logging for all validation failures
   - Create alerting mechanisms for critical errors
   - Establish error resolution workflows

3. **Performance Optimization:**
   - Use Snowflake clustering keys for frequently queried columns
   - Implement incremental processing where possible
   - Optimize validation queries for large datasets

### 4.2 Monitoring and Alerting

1. **Data Quality Monitoring:**
   - Implement automated data quality checks
   - Create dashboards for error tracking and resolution
   - Establish SLAs for error resolution

2. **Pipeline Monitoring:**
   - Monitor pipeline execution times and success rates
   - Implement alerting for pipeline failures
   - Track data volume anomalies

### 4.3 Maintenance and Evolution

1. **Schema Evolution:**
   - Plan for schema changes and backward compatibility
   - Implement versioning for validation rules
   - Document all changes and their impact

2. **Rule Management:**
   - Maintain validation rules in configuration tables
   - Implement rule versioning and change tracking
   - Establish governance processes for rule changes

This comprehensive mapping ensures that the Silver layer provides high-quality, consistent, and reliable data for downstream Gold layer processing and analytics while maintaining full traceability and error handling capabilities.