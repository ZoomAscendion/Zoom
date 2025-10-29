_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data mapping for Silver Layer transformation from Bronze Layer in Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer for the Zoom Platform Analytics System following the Medallion architecture. The mapping incorporates necessary data cleansing, validations, and business rules to ensure high-quality, consistent data in the Silver layer.

**Key Mapping Approach:**
- **Data Cleansing**: Standardization of formats, removal of duplicates, and data type conversions
- **Data Validation**: Implementation of business rules, referential integrity checks, and constraint validations
- **Data Enhancement**: Addition of calculated fields, derived metrics, and data quality scores
- **Error Handling**: Comprehensive error tracking and data quality monitoring

**Assumptions:**
- All Bronze layer tables contain metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM)
- Data quality validations are applied during the transformation process
- Failed validations are logged in the error tracking table
- All transformations are compatible with Snowflake SQL

## 2. Data Mapping for the Silver Layer

### 2.1 SI_USERS - User Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_USERS | USER_ID | Bronze | BZ_USERS | USER_ID | Not null, Unique | Direct mapping with trimming |
| Silver | SI_USERS | USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null, Length > 0 | Standardize case formatting (INITCAP) |
| Silver | SI_USERS | EMAIL | Bronze | BZ_USERS | EMAIL | Not null, Valid email format | Lowercase and validate email pattern |
| Silver | SI_USERS | COMPANY | Bronze | BZ_USERS | COMPANY | Length validation | Standardize company name formatting |
| Silver | SI_USERS | PLAN_TYPE | Bronze | BZ_USERS | PLAN_TYPE | Must be in (Free, Basic, Pro, Enterprise) | Standardize enumerated values |
| Silver | SI_USERS | REGISTRATION_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null, Not future date | Extract date from load timestamp |
| Silver | SI_USERS | LAST_LOGIN_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not future date | Extract date from update timestamp |
| Silver | SI_USERS | ACCOUNT_STATUS | Bronze | BZ_USERS | - | Must be in (Active, Inactive, Suspended) | Derive from user activity and plan status |
| Silver | SI_USERS | LOAD_TIMESTAMP | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_USERS | UPDATE_TIMESTAMP | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_USERS | SOURCE_SYSTEM | Bronze | BZ_USERS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_USERS | DATA_QUALITY_SCORE | Bronze | BZ_USERS | - | Range 0.00 to 1.00 | Calculate based on completeness and validity |
| Silver | SI_USERS | LOAD_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_USERS | UPDATE_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not null | Extract date component |

### 2.2 SI_MEETINGS - Meeting Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_MEETINGS | MEETING_ID | Bronze | BZ_MEETINGS | MEETING_ID | Not null, Unique | Direct mapping with trimming |
| Silver | SI_MEETINGS | HOST_ID | Bronze | BZ_MEETINGS | HOST_ID | Not null, Exists in SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_MEETINGS | MEETING_TOPIC | Bronze | BZ_MEETINGS | MEETING_TOPIC | Length validation | Clean and standardize meeting topic |
| Silver | SI_MEETINGS | MEETING_TYPE | Bronze | BZ_MEETINGS | - | Must be in (Scheduled, Instant, Webinar, Personal) | Derive from meeting characteristics |
| Silver | SI_MEETINGS | START_TIME | Bronze | BZ_MEETINGS | START_TIME | Not null, Valid timestamp | Convert to UTC and validate format |
| Silver | SI_MEETINGS | END_TIME | Bronze | BZ_MEETINGS | END_TIME | Not null, >= START_TIME | Convert to UTC and validate logic |
| Silver | SI_MEETINGS | DURATION_MINUTES | Bronze | BZ_MEETINGS | DURATION_MINUTES | >= 0, <= 1440 | Validate and recalculate if inconsistent |
| Silver | SI_MEETINGS | HOST_NAME | Bronze | BZ_USERS | USER_NAME | Not null | Lookup from SI_USERS via HOST_ID |
| Silver | SI_MEETINGS | MEETING_STATUS | Bronze | BZ_MEETINGS | - | Must be in (Scheduled, In Progress, Completed, Cancelled) | Derive from timestamps and current time |
| Silver | SI_MEETINGS | RECORDING_STATUS | Bronze | BZ_MEETINGS | - | Must be in (Yes, No) | Derive from meeting metadata |
| Silver | SI_MEETINGS | PARTICIPANT_COUNT | Bronze | BZ_PARTICIPANTS | - | >= 0 | Count distinct participants per meeting |
| Silver | SI_MEETINGS | LOAD_TIMESTAMP | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_MEETINGS | UPDATE_TIMESTAMP | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_MEETINGS | SOURCE_SYSTEM | Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_MEETINGS | DATA_QUALITY_SCORE | Bronze | BZ_MEETINGS | - | Range 0.00 to 1.00 | Calculate based on completeness and validity |
| Silver | SI_MEETINGS | LOAD_DATE | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_MEETINGS | UPDATE_DATE | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not null | Extract date component |

### 2.3 SI_PARTICIPANTS - Participant Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PARTICIPANTS | PARTICIPANT_ID | Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Not null, Unique | Direct mapping with trimming |
| Silver | SI_PARTICIPANTS | MEETING_ID | Bronze | BZ_PARTICIPANTS | MEETING_ID | Not null, Exists in SI_MEETINGS | Direct mapping with referential integrity check |
| Silver | SI_PARTICIPANTS | USER_ID | Bronze | BZ_PARTICIPANTS | USER_ID | Not null, Exists in SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_PARTICIPANTS | JOIN_TIME | Bronze | BZ_PARTICIPANTS | JOIN_TIME | Not null, Valid timestamp | Convert to UTC and validate format |
| Silver | SI_PARTICIPANTS | LEAVE_TIME | Bronze | BZ_PARTICIPANTS | LEAVE_TIME | >= JOIN_TIME when not null | Convert to UTC and validate logic |
| Silver | SI_PARTICIPANTS | ATTENDANCE_DURATION | Bronze | BZ_PARTICIPANTS | - | >= 0 | Calculate DATEDIFF(minute, JOIN_TIME, LEAVE_TIME) |
| Silver | SI_PARTICIPANTS | PARTICIPANT_ROLE | Bronze | BZ_PARTICIPANTS | - | Must be in (Host, Co-host, Participant, Observer) | Derive from user role and meeting context |
| Silver | SI_PARTICIPANTS | CONNECTION_QUALITY | Bronze | BZ_PARTICIPANTS | - | Must be in (Excellent, Good, Fair, Poor) | Derive from connection metrics |
| Silver | SI_PARTICIPANTS | LOAD_TIMESTAMP | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_PARTICIPANTS | UPDATE_TIMESTAMP | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_PARTICIPANTS | SOURCE_SYSTEM | Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_PARTICIPANTS | DATA_QUALITY_SCORE | Bronze | BZ_PARTICIPANTS | - | Range 0.00 to 1.00 | Calculate based on completeness and validity |
| Silver | SI_PARTICIPANTS | LOAD_DATE | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_PARTICIPANTS | UPDATE_DATE | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not null | Extract date component |

### 2.4 SI_FEATURE_USAGE - Feature Usage Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_FEATURE_USAGE | USAGE_ID | Bronze | BZ_FEATURE_USAGE | USAGE_ID | Not null, Unique | Direct mapping with trimming |
| Silver | SI_FEATURE_USAGE | MEETING_ID | Bronze | BZ_FEATURE_USAGE | MEETING_ID | Not null, Exists in SI_MEETINGS | Direct mapping with referential integrity check |
| Silver | SI_FEATURE_USAGE | FEATURE_NAME | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Not null, Length > 0 | Standardize feature name formatting |
| Silver | SI_FEATURE_USAGE | USAGE_COUNT | Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | >= 0 | Direct mapping with non-negative validation |
| Silver | SI_FEATURE_USAGE | USAGE_DURATION | Bronze | BZ_FEATURE_USAGE | - | >= 0 | Calculate or derive from usage patterns |
| Silver | SI_FEATURE_USAGE | FEATURE_CATEGORY | Bronze | BZ_FEATURE_USAGE | - | Must be in (Audio, Video, Collaboration, Security) | Categorize based on feature name mapping |
| Silver | SI_FEATURE_USAGE | USAGE_DATE | Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Not null, Not future date | Direct mapping with date validation |
| Silver | SI_FEATURE_USAGE | LOAD_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_FEATURE_USAGE | UPDATE_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_FEATURE_USAGE | DATA_QUALITY_SCORE | Bronze | BZ_FEATURE_USAGE | - | Range 0.00 to 1.00 | Calculate based on completeness and validity |
| Silver | SI_FEATURE_USAGE | LOAD_DATE | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_FEATURE_USAGE | UPDATE_DATE | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not null | Extract date component |

### 2.5 SI_SUPPORT_TICKETS - Support Ticket Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_SUPPORT_TICKETS | TICKET_ID | Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Not null, Unique | Direct mapping with trimming |
| Silver | SI_SUPPORT_TICKETS | USER_ID | Bronze | BZ_SUPPORT_TICKETS | USER_ID | Not null, Exists in SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Must be in (Technical, Billing, Feature Request, Bug Report) | Standardize enumerated values |
| Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | Bronze | BZ_SUPPORT_TICKETS | - | Must be in (Low, Medium, High, Critical) | Derive from ticket type and content analysis |
| Silver | SI_SUPPORT_TICKETS | OPEN_DATE | Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Not null, Not future date | Direct mapping with date validation |
| Silver | SI_SUPPORT_TICKETS | CLOSE_DATE | Bronze | BZ_SUPPORT_TICKETS | - | >= OPEN_DATE when not null | Derive from resolution status and timestamps |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Must be in (Open, In Progress, Resolved, Closed) | Standardize enumerated values |
| Silver | SI_SUPPORT_TICKETS | ISSUE_DESCRIPTION | Bronze | BZ_SUPPORT_TICKETS | - | Length validation | Clean and standardize description text |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_NOTES | Bronze | BZ_SUPPORT_TICKETS | - | Length validation | Clean and standardize resolution text |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_TIME_HOURS | Bronze | BZ_SUPPORT_TICKETS | - | >= 0 | Calculate business hours between open and close |
| Silver | SI_SUPPORT_TICKETS | LOAD_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | DATA_QUALITY_SCORE | Bronze | BZ_SUPPORT_TICKETS | - | Range 0.00 to 1.00 | Calculate based on completeness and validity |
| Silver | SI_SUPPORT_TICKETS | LOAD_DATE | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_SUPPORT_TICKETS | UPDATE_DATE | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not null | Extract date component |

### 2.6 SI_BILLING_EVENTS - Billing Events Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_BILLING_EVENTS | EVENT_ID | Bronze | BZ_BILLING_EVENTS | EVENT_ID | Not null, Unique | Direct mapping with trimming |
| Silver | SI_BILLING_EVENTS | USER_ID | Bronze | BZ_BILLING_EVENTS | USER_ID | Not null, Exists in SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_BILLING_EVENTS | EVENT_TYPE | Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Must be in (Subscription, Upgrade, Downgrade, Refund) | Standardize enumerated values |
| Silver | SI_BILLING_EVENTS | TRANSACTION_AMOUNT | Bronze | BZ_BILLING_EVENTS | AMOUNT | > 0, Valid decimal | Direct mapping with amount validation |
| Silver | SI_BILLING_EVENTS | TRANSACTION_DATE | Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Not null, Not future date | Direct mapping with date validation |
| Silver | SI_BILLING_EVENTS | PAYMENT_METHOD | Bronze | BZ_BILLING_EVENTS | - | Must be in (Credit Card, Bank Transfer, PayPal) | Derive from transaction metadata |
| Silver | SI_BILLING_EVENTS | CURRENCY_CODE | Bronze | BZ_BILLING_EVENTS | - | Valid 3-character ISO code | Derive from transaction metadata or default to USD |
| Silver | SI_BILLING_EVENTS | INVOICE_NUMBER | Bronze | BZ_BILLING_EVENTS | - | Unique when not null | Generate or derive from event metadata |
| Silver | SI_BILLING_EVENTS | TRANSACTION_STATUS | Bronze | BZ_BILLING_EVENTS | - | Must be in (Completed, Pending, Failed, Refunded) | Derive from event type and processing status |
| Silver | SI_BILLING_EVENTS | LOAD_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_BILLING_EVENTS | UPDATE_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_BILLING_EVENTS | SOURCE_SYSTEM | Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_BILLING_EVENTS | DATA_QUALITY_SCORE | Bronze | BZ_BILLING_EVENTS | - | Range 0.00 to 1.00 | Calculate based on completeness and validity |
| Silver | SI_BILLING_EVENTS | LOAD_DATE | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_BILLING_EVENTS | UPDATE_DATE | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not null | Extract date component |

### 2.7 SI_LICENSES - License Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_LICENSES | LICENSE_ID | Bronze | BZ_LICENSES | LICENSE_ID | Not null, Unique | Direct mapping with trimming |
| Silver | SI_LICENSES | ASSIGNED_TO_USER_ID | Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Exists in SI_USERS when not null | Direct mapping with referential integrity check |
| Silver | SI_LICENSES | LICENSE_TYPE | Bronze | BZ_LICENSES | LICENSE_TYPE | Must be in (Basic, Pro, Enterprise, Add-on) | Standardize enumerated values |
| Silver | SI_LICENSES | START_DATE | Bronze | BZ_LICENSES | START_DATE | Not null, Not future date | Direct mapping with date validation |
| Silver | SI_LICENSES | END_DATE | Bronze | BZ_LICENSES | END_DATE | >= START_DATE | Direct mapping with date logic validation |
| Silver | SI_LICENSES | LICENSE_STATUS | Bronze | BZ_LICENSES | - | Must be in (Active, Expired, Suspended) | Derive from current date vs START_DATE/END_DATE |
| Silver | SI_LICENSES | ASSIGNED_USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null when assigned | Lookup from SI_USERS via ASSIGNED_TO_USER_ID |
| Silver | SI_LICENSES | LICENSE_COST | Bronze | BZ_LICENSES | - | >= 0 | Derive from license type and pricing table |
| Silver | SI_LICENSES | RENEWAL_STATUS | Bronze | BZ_LICENSES | - | Must be in (Yes, No) | Derive from license metadata |
| Silver | SI_LICENSES | UTILIZATION_PERCENTAGE | Bronze | BZ_LICENSES | - | Range 0.00 to 100.00 | Calculate from usage patterns |
| Silver | SI_LICENSES | LOAD_TIMESTAMP | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_LICENSES | UPDATE_TIMESTAMP | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_LICENSES | SOURCE_SYSTEM | Bronze | BZ_LICENSES | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_LICENSES | DATA_QUALITY_SCORE | Bronze | BZ_LICENSES | - | Range 0.00 to 1.00 | Calculate based on completeness and validity |
| Silver | SI_LICENSES | LOAD_DATE | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_LICENSES | UPDATE_DATE | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not null | Extract date component |

### 2.8 SI_WEBINARS - Webinar Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_WEBINARS | WEBINAR_ID | Bronze | BZ_WEBINARS | WEBINAR_ID | Not null, Unique | Direct mapping with trimming |
| Silver | SI_WEBINARS | HOST_ID | Bronze | BZ_WEBINARS | HOST_ID | Not null, Exists in SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_WEBINARS | WEBINAR_TOPIC | Bronze | BZ_WEBINARS | WEBINAR_TOPIC | Length validation | Clean and standardize webinar topic |
| Silver | SI_WEBINARS | START_TIME | Bronze | BZ_WEBINARS | START_TIME | Not null, Valid timestamp | Convert to UTC and validate format |
| Silver | SI_WEBINARS | END_TIME | Bronze | BZ_WEBINARS | END_TIME | Not null, >= START_TIME | Convert to UTC and validate logic |
| Silver | SI_WEBINARS | DURATION_MINUTES | Bronze | BZ_WEBINARS | - | >= 0 | Calculate DATEDIFF(minute, START_TIME, END_TIME) |
| Silver | SI_WEBINARS | REGISTRANTS | Bronze | BZ_WEBINARS | REGISTRANTS | >= 0 | Direct mapping with non-negative validation |
| Silver | SI_WEBINARS | ATTENDEES | Bronze | BZ_WEBINARS | - | >= 0, <= REGISTRANTS | Derive from actual attendance data |
| Silver | SI_WEBINARS | ATTENDANCE_RATE | Bronze | BZ_WEBINARS | - | Range 0.00 to 100.00 | Calculate (ATTENDEES / REGISTRANTS) * 100 |
| Silver | SI_WEBINARS | LOAD_TIMESTAMP | Bronze | BZ_WEBINARS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_WEBINARS | UPDATE_TIMESTAMP | Bronze | BZ_WEBINARS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_WEBINARS | SOURCE_SYSTEM | Bronze | BZ_WEBINARS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_WEBINARS | DATA_QUALITY_SCORE | Bronze | BZ_WEBINARS | - | Range 0.00 to 1.00 | Calculate based on completeness and validity |
| Silver | SI_WEBINARS | LOAD_DATE | Bronze | BZ_WEBINARS | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_WEBINARS | UPDATE_DATE | Bronze | BZ_WEBINARS | UPDATE_TIMESTAMP | Not null | Extract date component |

### 2.9 SI_DATA_QUALITY_ERRORS - Error Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_ID | Bronze | - | - | Not null, Unique | Generate UUID for each error record |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_TABLE | Bronze | - | - | Not null | Populate with source table name during validation |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_RECORD_ID | Bronze | - | - | Not null | Populate with source record identifier |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TYPE | Bronze | - | - | Must be in (Missing Value, Invalid Format, Constraint Violation, Duplicate) | Categorize based on validation failure type |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_COLUMN | Bronze | - | - | Not null | Populate with column name where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_DESCRIPTION | Bronze | - | - | Not null | Generate descriptive error message |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_SEVERITY | Bronze | - | - | Must be in (Critical, High, Medium, Low) | Assign based on business impact |
| Silver | SI_DATA_QUALITY_ERRORS | DETECTED_TIMESTAMP | Bronze | - | - | Not null | Set to current timestamp when error detected |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_STATUS | Bronze | - | - | Must be in (Open, In Progress, Resolved, Ignored) | Default to 'Open' for new errors |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_ACTION | Bronze | - | - | Length validation | Populate when resolution action is taken |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLVED_TIMESTAMP | Bronze | - | - | >= DETECTED_TIMESTAMP | Set when error is resolved |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLVED_BY | Bronze | - | - | Length validation | Populate with user/process that resolved error |
| Silver | SI_DATA_QUALITY_ERRORS | LOAD_DATE | Bronze | - | - | Not null | Set to current date |
| Silver | SI_DATA_QUALITY_ERRORS | UPDATE_DATE | Bronze | - | - | Not null | Set to current date |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_SYSTEM | Bronze | - | - | Not null | Set to 'Data Quality Engine' |

### 2.10 SI_PIPELINE_AUDIT - Audit Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PIPELINE_AUDIT | EXECUTION_ID | Bronze | BZ_AUDIT_RECORDS | RECORD_ID | Not null, Unique | Generate UUID for each pipeline execution |
| Silver | SI_PIPELINE_AUDIT | PIPELINE_NAME | Bronze | BZ_AUDIT_RECORDS | SOURCE_TABLE | Not null | Map to standardized pipeline names |
| Silver | SI_PIPELINE_AUDIT | START_TIME | Bronze | BZ_AUDIT_RECORDS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_PIPELINE_AUDIT | END_TIME | Bronze | BZ_AUDIT_RECORDS | - | >= START_TIME | Calculate from processing time |
| Silver | SI_PIPELINE_AUDIT | STATUS | Bronze | BZ_AUDIT_RECORDS | STATUS | Must be in (Success, Failed, Partial Success, Cancelled) | Standardize status values |
| Silver | SI_PIPELINE_AUDIT | ERROR_MESSAGE | Bronze | BZ_AUDIT_RECORDS | ERROR_MESSAGE | Length validation | Direct mapping |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_DURATION_SECONDS | Bronze | BZ_AUDIT_RECORDS | PROCESSING_TIME | >= 0 | Direct mapping |
| Silver | SI_PIPELINE_AUDIT | SOURCE_TABLES_PROCESSED | Bronze | BZ_AUDIT_RECORDS | SOURCE_TABLE | Not null | Aggregate source tables per execution |
| Silver | SI_PIPELINE_AUDIT | TARGET_TABLES_UPDATED | Bronze | BZ_AUDIT_RECORDS | - | Not null | Map to target Silver tables |
| Silver | SI_PIPELINE_AUDIT | RECORDS_PROCESSED | Bronze | BZ_AUDIT_RECORDS | RECORD_COUNT | >= 0 | Direct mapping |
| Silver | SI_PIPELINE_AUDIT | RECORDS_INSERTED | Bronze | BZ_AUDIT_RECORDS | - | >= 0 | Calculate from processing results |
| Silver | SI_PIPELINE_AUDIT | RECORDS_UPDATED | Bronze | BZ_AUDIT_RECORDS | - | >= 0 | Calculate from processing results |
| Silver | SI_PIPELINE_AUDIT | RECORDS_REJECTED | Bronze | BZ_AUDIT_RECORDS | - | >= 0 | Calculate from data quality errors |
| Silver | SI_PIPELINE_AUDIT | EXECUTED_BY | Bronze | BZ_AUDIT_RECORDS | PROCESSED_BY | Not null | Direct mapping |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_ENVIRONMENT | Bronze | BZ_AUDIT_RECORDS | - | Must be in (Dev, Test, Prod) | Derive from system environment |
| Silver | SI_PIPELINE_AUDIT | DATA_LINEAGE_INFO | Bronze | BZ_AUDIT_RECORDS | - | Length validation | Generate lineage information |
| Silver | SI_PIPELINE_AUDIT | LOAD_DATE | Bronze | BZ_AUDIT_RECORDS | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_PIPELINE_AUDIT | UPDATE_DATE | Bronze | BZ_AUDIT_RECORDS | LOAD_TIMESTAMP | Not null | Extract date component |
| Silver | SI_PIPELINE_AUDIT | SOURCE_SYSTEM | Bronze | BZ_AUDIT_RECORDS | - | Not null | Set to 'Pipeline Audit System' |

## 3. Data Quality and Validation Rules Summary

### 3.1 Critical Validation Rules

1. **Referential Integrity**
   - All HOST_ID references must exist in SI_USERS
   - All MEETING_ID references must exist in SI_MEETINGS
   - All USER_ID references must exist in SI_USERS
   - All ASSIGNED_TO_USER_ID references must exist in SI_USERS

2. **Data Type and Format Validation**
   - Email addresses must follow valid email format pattern
   - Timestamps must be in valid ISO 8601 format
   - Numeric fields must be within specified ranges
   - Enumerated values must be from predefined lists

3. **Business Logic Validation**
   - END_TIME must be >= START_TIME for meetings and webinars
   - LEAVE_TIME must be >= JOIN_TIME for participants
   - Duration calculations must be consistent with timestamps
   - Date fields cannot be future dates where specified

4. **Data Quality Scoring**
   - Completeness: Percentage of non-null required fields
   - Validity: Percentage of fields passing format validation
   - Consistency: Percentage of fields passing business rule validation
   - Overall Score: Weighted average of completeness, validity, and consistency

### 3.2 Error Handling and Logging

1. **Error Classification**
   - **Critical**: Data that prevents processing (missing primary keys, invalid references)
   - **High**: Data that affects business calculations (invalid amounts, dates)
   - **Medium**: Data that affects reporting quality (missing optional fields)
   - **Low**: Data that affects presentation (formatting issues)

2. **Error Resolution Process**
   - Critical and High errors: Reject record and log for manual review
   - Medium errors: Accept record with default values and log for review
   - Low errors: Accept record with corrections and log for monitoring

3. **Monitoring and Alerting**
   - Daily data quality reports generated automatically
   - Alerts triggered when error rates exceed thresholds
   - Trend analysis for proactive data quality management

## 4. Implementation Recommendations

### 4.1 ETL Process Design

1. **Staged Processing**
   - Stage 1: Data extraction and basic cleansing
   - Stage 2: Validation and business rule application
   - Stage 3: Data quality scoring and error logging
   - Stage 4: Final transformation and loading

2. **Performance Optimization**
   - Use Snowflake clustering keys for frequently queried columns
   - Implement incremental processing for large tables
   - Optimize joins using appropriate join strategies
   - Use materialized views for complex aggregations

3. **Error Recovery**
   - Implement retry logic for transient errors
   - Maintain processing checkpoints for restart capability
   - Provide manual override capabilities for data quality issues
   - Implement rollback procedures for failed processing

### 4.2 Data Governance

1. **Data Lineage Tracking**
   - Document all transformation rules and business logic
   - Maintain audit trail of all data changes
   - Implement impact analysis for schema changes
   - Provide data dictionary and documentation

2. **Quality Monitoring**
   - Establish data quality KPIs and thresholds
   - Implement automated data profiling
   - Provide data quality dashboards and reports
   - Conduct regular data quality assessments

3. **Change Management**
   - Version control for all mapping rules and transformations
   - Impact assessment for business rule changes
   - Testing procedures for mapping updates
   - Documentation of all changes and rationale

This comprehensive data mapping provides the foundation for reliable, high-quality data transformation from the Bronze to Silver layer, ensuring that downstream analytics and reporting are built on clean, validated, and well-governed data.