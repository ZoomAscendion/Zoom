_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer Data Mapping for Zoom Platform Analytics System from Bronze to Silver layer with data quality validations and transformations
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The mapping incorporates necessary cleansing, validations, and business rules at the attribute level to ensure data quality, consistency, and usability across the organization.

### Key Considerations:
- **Data Quality Focus**: Implementation of comprehensive validation rules based on data quality recommendations
- **Business Rule Compliance**: Adherence to platform usage, support, and revenue analysis requirements
- **Snowflake Compatibility**: All transformations and validations are compatible with Snowflake SQL
- **Audit Trail**: Complete tracking of data lineage and processing activities
- **Error Handling**: Systematic approach to data quality issues and resolution

## 2. Data Mapping for the Silver Layer

### 2.1 SI_USERS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_USERS | USER_ID | Bronze | BZ_USERS | USER_ID | Not null, Unique | Direct copy - no transformation |
| Silver | SI_USERS | USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null, Length > 0 | TRIM(USER_NAME) - remove leading/trailing spaces |
| Silver | SI_USERS | EMAIL | Bronze | BZ_USERS | EMAIL | Not null, Valid email format | LOWER(TRIM(EMAIL)) - standardize to lowercase |
| Silver | SI_USERS | COMPANY | Bronze | BZ_USERS | COMPANY | Optional field | TRIM(COMPANY) - standardize spacing |
| Silver | SI_USERS | PLAN_TYPE | Bronze | BZ_USERS | PLAN_TYPE | Must be in ('Free', 'Basic', 'Pro', 'Business', 'Enterprise') | UPPER(TRIM(PLAN_TYPE)) - standardize to uppercase |
| Silver | SI_USERS | LOAD_TIMESTAMP | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy - no transformation |
| Silver | SI_USERS | UPDATE_TIMESTAMP | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy - no transformation |
| Silver | SI_USERS | SOURCE_SYSTEM | Bronze | BZ_USERS | SOURCE_SYSTEM | Not null | Direct copy - no transformation |
| Silver | SI_USERS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validity checks |
| Silver | SI_USERS | RECORD_STATUS | Calculated | N/A | N/A | Must be 'ACTIVE', 'INACTIVE', 'DELETED', 'QUARANTINED' | Set to 'ACTIVE' for valid records, 'QUARANTINED' for invalid |
| Silver | SI_USERS | PROCESSED_TIMESTAMP | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_USERS | PROCESSED_BY | System | N/A | N/A | Not null | 'SILVER_ETL_PIPELINE' |
| Silver | SI_USERS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be 'PASSED', 'FAILED', 'WARNING' | Based on validation rule results |
| Silver | SI_USERS | BUSINESS_KEY | Calculated | N/A | N/A | Not null, Unique | USER_ID (natural business key) |
| Silver | SI_USERS | EFFECTIVE_DATE | System | N/A | N/A | Not null | CURRENT_DATE() for new records |
| Silver | SI_USERS | EXPIRY_DATE | System | N/A | N/A | Must be >= EFFECTIVE_DATE | '9999-12-31' for current records |
| Silver | SI_USERS | IS_CURRENT | System | N/A | N/A | Boolean | TRUE for current version |
| Silver | SI_USERS | RECORD_HASH | Calculated | N/A | N/A | Not null | SHA2(CONCAT(USER_ID, USER_NAME, EMAIL, PLAN_TYPE)) |

### 2.2 SI_MEETINGS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_MEETINGS | MEETING_ID | Bronze | BZ_MEETINGS | MEETING_ID | Not null, Unique | Direct copy - no transformation |
| Silver | SI_MEETINGS | HOST_ID | Bronze | BZ_MEETINGS | HOST_ID | Not null, Must exist in SI_USERS | Direct copy - validate referential integrity |
| Silver | SI_MEETINGS | MEETING_TOPIC | Bronze | BZ_MEETINGS | MEETING_TOPIC | Optional field | TRIM(MEETING_TOPIC) - standardize spacing |
| Silver | SI_MEETINGS | START_TIME | Bronze | BZ_MEETINGS | START_TIME | Not null, Valid timestamp | Direct copy - validate chronological order |
| Silver | SI_MEETINGS | END_TIME | Bronze | BZ_MEETINGS | END_TIME | Valid timestamp, Must be >= START_TIME | Direct copy - validate chronological order |
| Silver | SI_MEETINGS | DURATION_MINUTES | Bronze | BZ_MEETINGS | DURATION_MINUTES | Non-negative, Must match calculated duration | Validate against DATEDIFF('minute', START_TIME, END_TIME) |
| Silver | SI_MEETINGS | LOAD_TIMESTAMP | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy - no transformation |
| Silver | SI_MEETINGS | UPDATE_TIMESTAMP | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy - no transformation |
| Silver | SI_MEETINGS | SOURCE_SYSTEM | Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Not null | Direct copy - no transformation |
| Silver | SI_MEETINGS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validity checks |
| Silver | SI_MEETINGS | RECORD_STATUS | Calculated | N/A | N/A | Must be 'ACTIVE', 'INACTIVE', 'DELETED', 'QUARANTINED' | Set based on validation results |
| Silver | SI_MEETINGS | PROCESSED_TIMESTAMP | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_MEETINGS | PROCESSED_BY | System | N/A | N/A | Not null | 'SILVER_ETL_PIPELINE' |
| Silver | SI_MEETINGS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be 'PASSED', 'FAILED', 'WARNING' | Based on validation rule results |
| Silver | SI_MEETINGS | BUSINESS_KEY | Calculated | N/A | N/A | Not null, Unique | MEETING_ID (natural business key) |
| Silver | SI_MEETINGS | EFFECTIVE_DATE | System | N/A | N/A | Not null | CURRENT_DATE() for new records |
| Silver | SI_MEETINGS | EXPIRY_DATE | System | N/A | N/A | Must be >= EFFECTIVE_DATE | '9999-12-31' for current records |
| Silver | SI_MEETINGS | IS_CURRENT | System | N/A | N/A | Boolean | TRUE for current version |
| Silver | SI_MEETINGS | RECORD_HASH | Calculated | N/A | N/A | Not null | SHA2(CONCAT(MEETING_ID, HOST_ID, START_TIME, DURATION_MINUTES)) |

### 2.3 SI_PARTICIPANTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PARTICIPANTS | PARTICIPANT_ID | Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Not null, Unique | Direct copy - no transformation |
| Silver | SI_PARTICIPANTS | MEETING_ID | Bronze | BZ_PARTICIPANTS | MEETING_ID | Not null, Must exist in SI_MEETINGS | Direct copy - validate referential integrity |
| Silver | SI_PARTICIPANTS | USER_ID | Bronze | BZ_PARTICIPANTS | USER_ID | Not null, Must exist in SI_USERS | Direct copy - validate referential integrity |
| Silver | SI_PARTICIPANTS | JOIN_TIME | Bronze | BZ_PARTICIPANTS | JOIN_TIME | Not null, Must be within meeting duration | Validate against meeting START_TIME and END_TIME |
| Silver | SI_PARTICIPANTS | LEAVE_TIME | Bronze | BZ_PARTICIPANTS | LEAVE_TIME | Must be >= JOIN_TIME, Must be within meeting duration | Validate chronological order and meeting bounds |
| Silver | SI_PARTICIPANTS | LOAD_TIMESTAMP | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy - no transformation |
| Silver | SI_PARTICIPANTS | UPDATE_TIMESTAMP | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy - no transformation |
| Silver | SI_PARTICIPANTS | SOURCE_SYSTEM | Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Not null | Direct copy - no transformation |
| Silver | SI_PARTICIPANTS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validity checks |
| Silver | SI_PARTICIPANTS | RECORD_STATUS | Calculated | N/A | N/A | Must be 'ACTIVE', 'INACTIVE', 'DELETED', 'QUARANTINED' | Set based on validation results |
| Silver | SI_PARTICIPANTS | PROCESSED_TIMESTAMP | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_PARTICIPANTS | PROCESSED_BY | System | N/A | N/A | Not null | 'SILVER_ETL_PIPELINE' |
| Silver | SI_PARTICIPANTS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be 'PASSED', 'FAILED', 'WARNING' | Based on validation rule results |
| Silver | SI_PARTICIPANTS | BUSINESS_KEY | Calculated | N/A | N/A | Not null, Unique | PARTICIPANT_ID (natural business key) |
| Silver | SI_PARTICIPANTS | EFFECTIVE_DATE | System | N/A | N/A | Not null | CURRENT_DATE() for new records |
| Silver | SI_PARTICIPANTS | EXPIRY_DATE | System | N/A | N/A | Must be >= EFFECTIVE_DATE | '9999-12-31' for current records |
| Silver | SI_PARTICIPANTS | IS_CURRENT | System | N/A | N/A | Boolean | TRUE for current version |
| Silver | SI_PARTICIPANTS | RECORD_HASH | Calculated | N/A | N/A | Not null | SHA2(CONCAT(PARTICIPANT_ID, MEETING_ID, USER_ID, JOIN_TIME)) |

### 2.4 SI_FEATURE_USAGE Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_FEATURE_USAGE | USAGE_ID | Bronze | BZ_FEATURE_USAGE | USAGE_ID | Not null, Unique | Direct copy - no transformation |
| Silver | SI_FEATURE_USAGE | MEETING_ID | Bronze | BZ_FEATURE_USAGE | MEETING_ID | Not null, Must exist in SI_MEETINGS | Direct copy - validate referential integrity |
| Silver | SI_FEATURE_USAGE | FEATURE_NAME | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Not null, Length > 0 | UPPER(TRIM(FEATURE_NAME)) - standardize to uppercase |
| Silver | SI_FEATURE_USAGE | USAGE_COUNT | Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | Non-negative integer, Not null | Direct copy - validate range |
| Silver | SI_FEATURE_USAGE | USAGE_DATE | Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Not null, Valid date, Not future date | Direct copy - validate date range |
| Silver | SI_FEATURE_USAGE | LOAD_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy - no transformation |
| Silver | SI_FEATURE_USAGE | UPDATE_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Valid timestamp | Direct copy - no transformation |
| Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Not null | Direct copy - no transformation |
| Silver | SI_FEATURE_USAGE | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validity checks |
| Silver | SI_FEATURE_USAGE | RECORD_STATUS | Calculated | N/A | N/A | Must be 'ACTIVE', 'INACTIVE', 'DELETED', 'QUARANTINED' | Set based on validation results |
| Silver | SI_FEATURE_USAGE | PROCESSED_TIMESTAMP | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_FEATURE_USAGE | PROCESSED_BY | System | N/A | N/A | Not null | 'SILVER_ETL_PIPELINE' |
| Silver | SI_FEATURE_USAGE | VALIDATION_STATUS | Calculated | N/A | N/A | Must be 'PASSED', 'FAILED', 'WARNING' | Based on validation rule results |
| Silver | SI_FEATURE_USAGE | BUSINESS_KEY | Calculated | N/A | N/A | Not null, Unique | USAGE_ID (natural business key) |
| Silver | SI_FEATURE_USAGE | EFFECTIVE_DATE | System | N/A | N/A | Not null | CURRENT_DATE() for new records |
| Silver | SI_FEATURE_USAGE | EXPIRY_DATE | System | N/A | N/A | Must be >= EFFECTIVE_DATE | '9999-12-31' for current records |
| Silver | SI_FEATURE_USAGE | IS_CURRENT | System | N/A | N/A | Boolean | TRUE for current version |
| Silver | SI_FEATURE_USAGE | RECORD_HASH | Calculated | N/A | N/A | Not null | SHA2(CONCAT(USAGE_ID, MEETING_ID, FEATURE_NAME, USAGE_COUNT)) |

### 2.5 SI_SUPPORT_TICKETS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_SUPPORT_TICKETS | TICKET_ID | Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Not null, Unique | Direct copy - no transformation |
| Silver | SI_SUPPORT_TICKETS | USER_ID | Bronze | BZ_SUPPORT_TICKETS | USER_ID | Not null, Must exist in SI_USERS | Direct copy - validate referential integrity |
| Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Not null, Length > 0 | UPPER(TRIM(TICKET_TYPE)) - standardize to uppercase |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Must be in ('Open', 'In Progress', 'Resolved', 'Closed') | UPPER(TRIM(RESOLUTION_STATUS)) - standardize format |
| Silver | SI_SUPPORT_TICKETS | OPEN_DATE | Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Not null, Valid date, Not future date | Direct copy - validate date range |
| Silver | SI_SUPPORT_TICKETS | LOAD_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy - no transformation |
| Silver | SI_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy - no transformation |
| Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Not null | Direct copy - no transformation |
| Silver | SI_SUPPORT_TICKETS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validity checks |
| Silver | SI_SUPPORT_TICKETS | RECORD_STATUS | Calculated | N/A | N/A | Must be 'ACTIVE', 'INACTIVE', 'DELETED', 'QUARANTINED' | Set based on validation results |
| Silver | SI_SUPPORT_TICKETS | PROCESSED_TIMESTAMP | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_SUPPORT_TICKETS | PROCESSED_BY | System | N/A | N/A | Not null | 'SILVER_ETL_PIPELINE' |
| Silver | SI_SUPPORT_TICKETS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be 'PASSED', 'FAILED', 'WARNING' | Based on validation rule results |
| Silver | SI_SUPPORT_TICKETS | BUSINESS_KEY | Calculated | N/A | N/A | Not null, Unique | TICKET_ID (natural business key) |
| Silver | SI_SUPPORT_TICKETS | EFFECTIVE_DATE | System | N/A | N/A | Not null | CURRENT_DATE() for new records |
| Silver | SI_SUPPORT_TICKETS | EXPIRY_DATE | System | N/A | N/A | Must be >= EFFECTIVE_DATE | '9999-12-31' for current records |
| Silver | SI_SUPPORT_TICKETS | IS_CURRENT | System | N/A | N/A | Boolean | TRUE for current version |
| Silver | SI_SUPPORT_TICKETS | RECORD_HASH | Calculated | N/A | N/A | Not null | SHA2(CONCAT(TICKET_ID, USER_ID, TICKET_TYPE, RESOLUTION_STATUS)) |

### 2.6 SI_BILLING_EVENTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_BILLING_EVENTS | EVENT_ID | Bronze | BZ_BILLING_EVENTS | EVENT_ID | Not null, Unique | Direct copy - no transformation |
| Silver | SI_BILLING_EVENTS | USER_ID | Bronze | BZ_BILLING_EVENTS | USER_ID | Not null, Must exist in SI_USERS | Direct copy - validate referential integrity |
| Silver | SI_BILLING_EVENTS | EVENT_TYPE | Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Not null, Length > 0 | UPPER(TRIM(EVENT_TYPE)) - standardize to uppercase |
| Silver | SI_BILLING_EVENTS | AMOUNT | Bronze | BZ_BILLING_EVENTS | AMOUNT | Positive decimal, Not null | ROUND(AMOUNT, 2) - standardize to 2 decimal places |
| Silver | SI_BILLING_EVENTS | EVENT_DATE | Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Not null, Valid date, Within business range | Direct copy - validate date range (>= '2020-01-01', <= CURRENT_DATE) |
| Silver | SI_BILLING_EVENTS | LOAD_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy - no transformation |
| Silver | SI_BILLING_EVENTS | UPDATE_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy - no transformation |
| Silver | SI_BILLING_EVENTS | SOURCE_SYSTEM | Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Not null | Direct copy - no transformation |
| Silver | SI_BILLING_EVENTS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validity checks |
| Silver | SI_BILLING_EVENTS | RECORD_STATUS | Calculated | N/A | N/A | Must be 'ACTIVE', 'INACTIVE', 'DELETED', 'QUARANTINED' | Set based on validation results |
| Silver | SI_BILLING_EVENTS | PROCESSED_TIMESTAMP | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_BILLING_EVENTS | PROCESSED_BY | System | N/A | N/A | Not null | 'SILVER_ETL_PIPELINE' |
| Silver | SI_BILLING_EVENTS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be 'PASSED', 'FAILED', 'WARNING' | Based on validation rule results |
| Silver | SI_BILLING_EVENTS | BUSINESS_KEY | Calculated | N/A | N/A | Not null, Unique | EVENT_ID (natural business key) |
| Silver | SI_BILLING_EVENTS | EFFECTIVE_DATE | System | N/A | N/A | Not null | CURRENT_DATE() for new records |
| Silver | SI_BILLING_EVENTS | EXPIRY_DATE | System | N/A | N/A | Must be >= EFFECTIVE_DATE | '9999-12-31' for current records |
| Silver | SI_BILLING_EVENTS | IS_CURRENT | System | N/A | N/A | Boolean | TRUE for current version |
| Silver | SI_BILLING_EVENTS | RECORD_HASH | Calculated | N/A | N/A | Not null | SHA2(CONCAT(EVENT_ID, USER_ID, EVENT_TYPE, AMOUNT)) |

### 2.7 SI_LICENSES Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_LICENSES | LICENSE_ID | Bronze | BZ_LICENSES | LICENSE_ID | Not null, Unique | Direct copy - no transformation |
| Silver | SI_LICENSES | LICENSE_TYPE | Bronze | BZ_LICENSES | LICENSE_TYPE | Not null, Length > 0 | UPPER(TRIM(LICENSE_TYPE)) - standardize to uppercase |
| Silver | SI_LICENSES | ASSIGNED_TO_USER_ID | Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Must exist in SI_USERS if not null | Direct copy - validate referential integrity |
| Silver | SI_LICENSES | START_DATE | Bronze | BZ_LICENSES | START_DATE | Not null, Valid date | Direct copy - validate date format |
| Silver | SI_LICENSES | END_DATE | Bronze | BZ_LICENSES | END_DATE | Valid date, Must be >= START_DATE | Direct copy - validate chronological order |
| Silver | SI_LICENSES | LOAD_TIMESTAMP | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy - no transformation |
| Silver | SI_LICENSES | UPDATE_TIMESTAMP | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Valid timestamp | Direct copy - no transformation |
| Silver | SI_LICENSES | SOURCE_SYSTEM | Bronze | BZ_LICENSES | SOURCE_SYSTEM | Not null | Direct copy - no transformation |
| Silver | SI_LICENSES | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validity checks |
| Silver | SI_LICENSES | RECORD_STATUS | Calculated | N/A | N/A | Must be 'ACTIVE', 'INACTIVE', 'DELETED', 'QUARANTINED' | Set based on validation results |
| Silver | SI_LICENSES | PROCESSED_TIMESTAMP | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_LICENSES | PROCESSED_BY | System | N/A | N/A | Not null | 'SILVER_ETL_PIPELINE' |
| Silver | SI_LICENSES | VALIDATION_STATUS | Calculated | N/A | N/A | Must be 'PASSED', 'FAILED', 'WARNING' | Based on validation rule results |
| Silver | SI_LICENSES | BUSINESS_KEY | Calculated | N/A | N/A | Not null, Unique | LICENSE_ID (natural business key) |
| Silver | SI_LICENSES | EFFECTIVE_DATE | System | N/A | N/A | Not null | CURRENT_DATE() for new records |
| Silver | SI_LICENSES | EXPIRY_DATE | System | N/A | N/A | Must be >= EFFECTIVE_DATE | '9999-12-31' for current records |
| Silver | SI_LICENSES | IS_CURRENT | System | N/A | N/A | Boolean | TRUE for current version |
| Silver | SI_LICENSES | RECORD_HASH | Calculated | N/A | N/A | Not null | SHA2(CONCAT(LICENSE_ID, LICENSE_TYPE, ASSIGNED_TO_USER_ID, START_DATE)) |

### 2.8 SI_DATA_QUALITY_ERRORS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_ID | System | N/A | N/A | Auto-increment, Unique | AUTOINCREMENT - system generated |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_TABLE | Calculated | N/A | N/A | Not null | Name of source Bronze table where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_RECORD_ID | Calculated | N/A | N/A | Not null | Primary key value of problematic record |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TYPE | Calculated | N/A | N/A | Must be valid error type | 'MISSING_VALUE', 'INVALID_FORMAT', 'CONSTRAINT_VIOLATION', 'REFERENTIAL_INTEGRITY' |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_DESCRIPTION | Calculated | N/A | N/A | Not null | Detailed description of the validation failure |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_COLUMN | Calculated | N/A | N/A | Not null | Column name where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_VALUE | Calculated | N/A | N/A | Optional | Actual value that caused the error |
| Silver | SI_DATA_QUALITY_ERRORS | VALIDATION_RULE | Calculated | N/A | N/A | Not null | Description of validation rule that was violated |
| Silver | SI_DATA_QUALITY_ERRORS | SEVERITY_LEVEL | Calculated | N/A | N/A | Must be 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW' | Based on business impact of the error |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TIMESTAMP | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() when error was detected |
| Silver | SI_DATA_QUALITY_ERRORS | PROCESSED_BY | System | N/A | N/A | Not null | 'SILVER_DATA_QUALITY_VALIDATOR' |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_STATUS | System | N/A | N/A | Must be 'OPEN', 'IN_PROGRESS', 'RESOLVED' | Default to 'OPEN' for new errors |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_TIMESTAMP | System | N/A | N/A | Optional | Timestamp when error was resolved |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_NOTES | System | N/A | N/A | Optional | Notes about how error was resolved |

### 2.9 SI_PIPELINE_AUDIT Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PIPELINE_AUDIT | AUDIT_ID | System | N/A | N/A | Auto-increment, Unique | AUTOINCREMENT - system generated |
| Silver | SI_PIPELINE_AUDIT | PIPELINE_NAME | System | N/A | N/A | Not null | Name of ETL pipeline (e.g., 'BRONZE_TO_SILVER_USERS') |
| Silver | SI_PIPELINE_AUDIT | PIPELINE_RUN_ID | System | N/A | N/A | Not null | Unique identifier for pipeline execution |
| Silver | SI_PIPELINE_AUDIT | SOURCE_TABLE | System | N/A | N/A | Not null | Bronze table being processed |
| Silver | SI_PIPELINE_AUDIT | TARGET_TABLE | System | N/A | N/A | Not null | Silver table being populated |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_START_TIME | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() at pipeline start |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_END_TIME | System | N/A | N/A | Not null | CURRENT_TIMESTAMP() at pipeline completion |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_DURATION_SECONDS | Calculated | N/A | N/A | Non-negative | DATEDIFF('second', EXECUTION_START_TIME, EXECUTION_END_TIME) |
| Silver | SI_PIPELINE_AUDIT | RECORDS_PROCESSED | Calculated | N/A | N/A | Non-negative | Count of records processed from Bronze |
| Silver | SI_PIPELINE_AUDIT | RECORDS_INSERTED | Calculated | N/A | N/A | Non-negative | Count of new records inserted into Silver |
| Silver | SI_PIPELINE_AUDIT | RECORDS_UPDATED | Calculated | N/A | N/A | Non-negative | Count of existing records updated in Silver |
| Silver | SI_PIPELINE_AUDIT | RECORDS_REJECTED | Calculated | N/A | N/A | Non-negative | Count of records that failed validation |
| Silver | SI_PIPELINE_AUDIT | PIPELINE_STATUS | System | N/A | N/A | Must be 'SUCCESS', 'FAILED', 'WARNING' | Based on pipeline execution result |
| Silver | SI_PIPELINE_AUDIT | ERROR_MESSAGE | System | N/A | N/A | Optional | Error details if pipeline failed |
| Silver | SI_PIPELINE_AUDIT | PROCESSED_BY | System | N/A | N/A | Not null | 'SILVER_ETL_PIPELINE' |
| Silver | SI_PIPELINE_AUDIT | PROCESSING_DATE | System | N/A | N/A | Not null | CURRENT_DATE() |
| Silver | SI_PIPELINE_AUDIT | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Overall data quality score for the pipeline run |
| Silver | SI_PIPELINE_AUDIT | PERFORMANCE_METRICS | System | N/A | N/A | Optional | JSON string with detailed performance metrics |

## 3. Data Quality Validation Rules Implementation

### 3.1 Critical Validation Rules (Priority 1)

1. **Referential Integrity Checks**
   - HOST_ID in SI_MEETINGS must exist in SI_USERS.USER_ID
   - MEETING_ID in SI_PARTICIPANTS must exist in SI_MEETINGS.MEETING_ID
   - USER_ID in SI_PARTICIPANTS must exist in SI_USERS.USER_ID
   - MEETING_ID in SI_FEATURE_USAGE must exist in SI_MEETINGS.MEETING_ID
   - USER_ID in SI_SUPPORT_TICKETS must exist in SI_USERS.USER_ID
   - USER_ID in SI_BILLING_EVENTS must exist in SI_USERS.USER_ID
   - ASSIGNED_TO_USER_ID in SI_LICENSES must exist in SI_USERS.USER_ID (when not null)

2. **Primary Key Validation**
   - All primary identifier fields (USER_ID, MEETING_ID, etc.) must be not null and unique
   - No duplicate records based on business keys

3. **Data Type Validation**
   - All timestamp fields must be valid timestamps
   - All numeric fields must be valid numbers within expected ranges
   - All date fields must be valid dates

### 3.2 High Priority Validation Rules (Priority 2)

1. **Business Rule Validation**
   - PLAN_TYPE must be in predefined list: ('Free', 'Basic', 'Pro', 'Business', 'Enterprise')
   - RESOLUTION_STATUS must be in predefined list: ('Open', 'In Progress', 'Resolved', 'Closed')
   - DURATION_MINUTES must be non-negative and match calculated duration
   - AMOUNT in billing events must be positive
   - START_TIME must be before END_TIME in meetings
   - JOIN_TIME must be before LEAVE_TIME in participants

2. **Format Validation**
   - EMAIL must follow valid email format pattern
   - Date fields must not be future dates (except where business appropriate)
   - Numeric fields must be within reasonable business ranges

### 3.3 Medium Priority Validation Rules (Priority 3)

1. **Completeness Checks**
   - Required fields must not be null or empty
   - USER_NAME, EMAIL, PLAN_TYPE must be populated for users
   - MEETING_ID, HOST_ID, START_TIME must be populated for meetings
   - FEATURE_NAME, USAGE_COUNT must be populated for feature usage

2. **Consistency Validation**
   - User PLAN_TYPE should be consistent with LICENSE_TYPE
   - Meeting duration should align with participant join/leave times
   - Feature usage dates should align with meeting dates

### 3.4 Low Priority Validation Rules (Priority 4)

1. **Anomaly Detection**
   - Meetings with unusually long duration (> 24 hours)
   - Meetings with very short duration (< 1 minute)
   - Excessive feature usage counts (> 1000)
   - Future dates in historical data

2. **Data Quality Scoring**
   - Calculate overall data quality score based on validation results
   - Track data quality trends over time
   - Provide data quality dashboards for monitoring

## 4. Error Handling and Logging Mechanisms

### 4.1 Error Categorization

1. **Critical Errors (SEVERITY_LEVEL = 'CRITICAL')**
   - Missing primary keys
   - Referential integrity violations
   - Data type mismatches
   - **Action**: Quarantine record, halt processing, alert data stewards

2. **High Priority Errors (SEVERITY_LEVEL = 'HIGH')**
   - Business rule violations
   - Invalid format data
   - **Action**: Quarantine record, continue processing, log for review

3. **Medium Priority Errors (SEVERITY_LEVEL = 'MEDIUM')**
   - Completeness issues
   - Consistency warnings
   - **Action**: Flag record, continue processing, schedule for cleanup

4. **Low Priority Errors (SEVERITY_LEVEL = 'LOW')**
   - Anomaly detection alerts
   - Data quality score impacts
   - **Action**: Log for analysis, continue processing

### 4.2 Error Resolution Workflow

1. **Automatic Resolution**
   - Data standardization (trim spaces, case conversion)
   - Default value assignment for optional fields
   - Format corrections where possible

2. **Manual Resolution**
   - Data steward review and correction
   - Business rule exception approval
   - Source system data correction

3. **Escalation Process**
   - Critical errors escalated immediately
   - High priority errors escalated within 4 hours
   - Medium priority errors reviewed daily
   - Low priority errors reviewed weekly

### 4.3 Audit and Compliance

1. **Complete Audit Trail**
   - All data processing activities logged
   - Error detection and resolution tracked
   - Performance metrics captured
   - Data lineage maintained

2. **Compliance Reporting**
   - Data quality metrics dashboard
   - Error trend analysis
   - Processing performance reports
   - Regulatory compliance documentation

## 5. Implementation Recommendations

### 5.1 ETL Pipeline Design

1. **Incremental Processing**
   - Use MERGE statements for upsert operations
   - Implement change data capture using STREAM objects
   - Process only changed records to optimize performance

2. **Parallel Processing**
   - Process independent tables in parallel
   - Use Snowflake's multi-cluster warehouses for scalability
   - Implement proper dependency management

3. **Error Recovery**
   - Implement checkpoint and restart capabilities
   - Maintain processing state for recovery
   - Provide manual intervention points for critical errors

### 5.2 Performance Optimization

1. **Clustering Strategy**
   - Cluster tables on frequently queried columns
   - Consider date-based clustering for time-series data
   - Monitor and adjust clustering keys based on usage patterns

2. **Materialized Views**
   - Create materialized views for complex aggregations
   - Implement automatic refresh schedules
   - Monitor view usage and performance

3. **Query Optimization**
   - Use result caching for dashboard queries
   - Implement proper indexing strategies
   - Monitor query performance and optimize as needed

### 5.3 Monitoring and Alerting

1. **Real-time Monitoring**
   - Pipeline execution status
   - Data quality score trends
   - Error rate monitoring
   - Performance metrics tracking

2. **Automated Alerting**
   - Critical error notifications
   - Pipeline failure alerts
   - Data quality degradation warnings
   - Performance threshold breaches

3. **Dashboard and Reporting**
   - Executive data quality dashboard
   - Operational monitoring console
   - Detailed error analysis reports
   - Performance trend analysis

## 6. Conclusion

This Silver Layer Data Mapping provides a comprehensive framework for transforming raw Bronze layer data into high-quality, validated, and enriched Silver layer data. The implementation ensures:

- **Data Quality**: Comprehensive validation rules and error handling
- **Auditability**: Complete tracking of all data processing activities
- **Scalability**: Designed for Snowflake's cloud-native architecture
- **Maintainability**: Clear documentation and structured approach
- **Compliance**: Adherence to data governance and regulatory requirements

The mapping serves as the foundation for reliable analytics and reporting, enabling the organization to make data-driven decisions with confidence in data quality and consistency.