_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive Silver Layer Data Mapping for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer for the Zoom Platform Analytics System following the Medallion architecture. The mapping incorporates necessary cleansing, validations, and business rules at the attribute level to ensure data quality, consistency, and usability across the organization.

The Silver Layer serves as the cleansed and conformed layer, transforming raw Bronze data into standardized, validated, and enriched datasets ready for analytical consumption. All transformations are designed to be compatible with Snowflake SQL and follow established data quality standards.

**Key Mapping Principles:**
- Data type standardization and validation
- Business rule enforcement through validation checks
- Data quality scoring and error tracking
- Referential integrity validation
- Comprehensive audit trail maintenance

## 2. Data Mapping for the Silver Layer

### 2.1 SI_USERS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_USERS | USER_ID | Bronze | BZ_USERS | USER_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_USERS | USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null, Valid format | TRIM and PROPER case formatting |
| Silver | SI_USERS | EMAIL | Bronze | BZ_USERS | EMAIL | Not null, Valid email format | LOWER case and email format validation |
| Silver | SI_USERS | COMPANY | Bronze | BZ_USERS | COMPANY | Valid format | TRIM and standardize company names |
| Silver | SI_USERS | PLAN_TYPE | Bronze | BZ_USERS | PLAN_TYPE | Not null, Valid enumeration (Free, Basic, Pro, Enterprise) | Standardize to predefined values |
| Silver | SI_USERS | REGISTRATION_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null, Valid date, Not future date | Extract date from load timestamp |
| Silver | SI_USERS | LAST_LOGIN_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Valid date, Not future date | Extract date from update timestamp |
| Silver | SI_USERS | ACCOUNT_STATUS | Bronze | BZ_USERS | - | Not null, Valid enumeration (Active, Inactive, Suspended) | Derived based on business logic |
| Silver | SI_USERS | LOAD_TIMESTAMP | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_USERS | UPDATE_TIMESTAMP | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_USERS | SOURCE_SYSTEM | Bronze | BZ_USERS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_USERS | DATA_QUALITY_SCORE | Bronze | BZ_USERS | - | Range 0.00-1.00 | Calculate based on validation results |
| Silver | SI_USERS | LOAD_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_USERS | UPDATE_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.2 SI_MEETINGS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_MEETINGS | MEETING_ID | Bronze | BZ_MEETINGS | MEETING_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_MEETINGS | HOST_ID | Bronze | BZ_MEETINGS | HOST_ID | Not null, Valid foreign key reference | Validate against SI_USERS.USER_ID |
| Silver | SI_MEETINGS | MEETING_TOPIC | Bronze | BZ_MEETINGS | MEETING_TOPIC | Valid format | TRIM and standardize topic |
| Silver | SI_MEETINGS | MEETING_TYPE | Bronze | BZ_MEETINGS | - | Not null, Valid enumeration (Scheduled, Instant, Webinar, Personal) | Derive based on meeting characteristics |
| Silver | SI_MEETINGS | START_TIME | Bronze | BZ_MEETINGS | START_TIME | Not null, Valid timestamp | Convert to UTC and validate |
| Silver | SI_MEETINGS | END_TIME | Bronze | BZ_MEETINGS | END_TIME | Not null, Valid timestamp, >= START_TIME | Convert to UTC and validate logic |
| Silver | SI_MEETINGS | DURATION_MINUTES | Bronze | BZ_MEETINGS | DURATION_MINUTES | Not null, Range 1-1440 minutes | Validate and recalculate if needed |
| Silver | SI_MEETINGS | HOST_NAME | Bronze | BZ_USERS | USER_NAME | Not null | Join with BZ_USERS on HOST_ID |
| Silver | SI_MEETINGS | MEETING_STATUS | Bronze | BZ_MEETINGS | - | Not null, Valid enumeration (Scheduled, In Progress, Completed, Cancelled) | Derive based on timestamps |
| Silver | SI_MEETINGS | RECORDING_STATUS | Bronze | BZ_MEETINGS | - | Valid enumeration (Yes, No) | Derive from meeting metadata |
| Silver | SI_MEETINGS | PARTICIPANT_COUNT | Bronze | BZ_PARTICIPANTS | - | Non-negative integer | Count participants per meeting |
| Silver | SI_MEETINGS | LOAD_TIMESTAMP | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_MEETINGS | UPDATE_TIMESTAMP | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_MEETINGS | SOURCE_SYSTEM | Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_MEETINGS | DATA_QUALITY_SCORE | Bronze | BZ_MEETINGS | - | Range 0.00-1.00 | Calculate based on validation results |
| Silver | SI_MEETINGS | LOAD_DATE | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_MEETINGS | UPDATE_DATE | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.3 SI_PARTICIPANTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PARTICIPANTS | PARTICIPANT_ID | Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_PARTICIPANTS | MEETING_ID | Bronze | BZ_PARTICIPANTS | MEETING_ID | Not null, Valid foreign key reference | Validate against SI_MEETINGS.MEETING_ID |
| Silver | SI_PARTICIPANTS | USER_ID | Bronze | BZ_PARTICIPANTS | USER_ID | Not null, Valid foreign key reference | Validate against SI_USERS.USER_ID |
| Silver | SI_PARTICIPANTS | JOIN_TIME | Bronze | BZ_PARTICIPANTS | JOIN_TIME | Not null, Valid timestamp | Convert to UTC and validate |
| Silver | SI_PARTICIPANTS | LEAVE_TIME | Bronze | BZ_PARTICIPANTS | LEAVE_TIME | Valid timestamp, >= JOIN_TIME | Convert to UTC and validate logic |
| Silver | SI_PARTICIPANTS | ATTENDANCE_DURATION | Bronze | BZ_PARTICIPANTS | - | Non-negative, <= meeting duration | Calculate DATEDIFF(minute, JOIN_TIME, LEAVE_TIME) |
| Silver | SI_PARTICIPANTS | PARTICIPANT_ROLE | Bronze | BZ_PARTICIPANTS | - | Valid enumeration (Host, Co-host, Participant, Observer) | Derive based on participant metadata |
| Silver | SI_PARTICIPANTS | CONNECTION_QUALITY | Bronze | BZ_PARTICIPANTS | - | Valid enumeration (Excellent, Good, Fair, Poor) | Derive from connection metrics |
| Silver | SI_PARTICIPANTS | LOAD_TIMESTAMP | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_PARTICIPANTS | UPDATE_TIMESTAMP | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_PARTICIPANTS | SOURCE_SYSTEM | Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_PARTICIPANTS | DATA_QUALITY_SCORE | Bronze | BZ_PARTICIPANTS | - | Range 0.00-1.00 | Calculate based on validation results |
| Silver | SI_PARTICIPANTS | LOAD_DATE | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_PARTICIPANTS | UPDATE_DATE | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.4 SI_FEATURE_USAGE Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_FEATURE_USAGE | USAGE_ID | Bronze | BZ_FEATURE_USAGE | USAGE_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_FEATURE_USAGE | MEETING_ID | Bronze | BZ_FEATURE_USAGE | MEETING_ID | Not null, Valid foreign key reference | Validate against SI_MEETINGS.MEETING_ID |
| Silver | SI_FEATURE_USAGE | FEATURE_NAME | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Not null, Valid format | TRIM and standardize feature names |
| Silver | SI_FEATURE_USAGE | USAGE_COUNT | Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | Not null, Non-negative integer | Validate count >= 0 |
| Silver | SI_FEATURE_USAGE | USAGE_DURATION | Bronze | BZ_FEATURE_USAGE | - | Non-negative, <= meeting duration | Calculate based on feature activation time |
| Silver | SI_FEATURE_USAGE | FEATURE_CATEGORY | Bronze | BZ_FEATURE_USAGE | - | Not null, Valid enumeration (Audio, Video, Collaboration, Security) | Map feature names to categories |
| Silver | SI_FEATURE_USAGE | USAGE_DATE | Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Not null, Valid date | Direct mapping with validation |
| Silver | SI_FEATURE_USAGE | LOAD_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_FEATURE_USAGE | UPDATE_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_FEATURE_USAGE | DATA_QUALITY_SCORE | Bronze | BZ_FEATURE_USAGE | - | Range 0.00-1.00 | Calculate based on validation results |
| Silver | SI_FEATURE_USAGE | LOAD_DATE | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_FEATURE_USAGE | UPDATE_DATE | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.5 SI_SUPPORT_TICKETS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_SUPPORT_TICKETS | TICKET_ID | Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_SUPPORT_TICKETS | USER_ID | Bronze | BZ_SUPPORT_TICKETS | USER_ID | Not null, Valid foreign key reference | Validate against SI_USERS.USER_ID |
| Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Not null, Valid enumeration (Technical, Billing, Feature Request, Bug Report) | Standardize to predefined values |
| Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | Bronze | BZ_SUPPORT_TICKETS | - | Not null, Valid enumeration (Low, Medium, High, Critical) | Derive based on ticket characteristics |
| Silver | SI_SUPPORT_TICKETS | OPEN_DATE | Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Not null, Valid date, Not future date | Direct mapping with validation |
| Silver | SI_SUPPORT_TICKETS | CLOSE_DATE | Bronze | BZ_SUPPORT_TICKETS | - | Valid date, >= OPEN_DATE | Derive from resolution status |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Not null, Valid enumeration (Open, In Progress, Resolved, Closed) | Standardize to predefined values |
| Silver | SI_SUPPORT_TICKETS | ISSUE_DESCRIPTION | Bronze | BZ_SUPPORT_TICKETS | - | Valid format | Clean and standardize description text |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_NOTES | Bronze | BZ_SUPPORT_TICKETS | - | Valid format | Clean and standardize resolution text |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_TIME_HOURS | Bronze | BZ_SUPPORT_TICKETS | - | Non-negative | Calculate business hours between open and close |
| Silver | SI_SUPPORT_TICKETS | LOAD_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | DATA_QUALITY_SCORE | Bronze | BZ_SUPPORT_TICKETS | - | Range 0.00-1.00 | Calculate based on validation results |
| Silver | SI_SUPPORT_TICKETS | LOAD_DATE | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_SUPPORT_TICKETS | UPDATE_DATE | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.6 SI_BILLING_EVENTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_BILLING_EVENTS | EVENT_ID | Bronze | BZ_BILLING_EVENTS | EVENT_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_BILLING_EVENTS | USER_ID | Bronze | BZ_BILLING_EVENTS | USER_ID | Not null, Valid foreign key reference | Validate against SI_USERS.USER_ID |
| Silver | SI_BILLING_EVENTS | EVENT_TYPE | Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Not null, Valid enumeration (Subscription, Upgrade, Downgrade, Refund) | Standardize to predefined values |
| Silver | SI_BILLING_EVENTS | TRANSACTION_AMOUNT | Bronze | BZ_BILLING_EVENTS | AMOUNT | Not null, Positive number | Validate amount > 0 |
| Silver | SI_BILLING_EVENTS | TRANSACTION_DATE | Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Not null, Valid date, Not future date | Direct mapping with validation |
| Silver | SI_BILLING_EVENTS | PAYMENT_METHOD | Bronze | BZ_BILLING_EVENTS | - | Valid enumeration (Credit Card, Bank Transfer, PayPal) | Derive from transaction metadata |
| Silver | SI_BILLING_EVENTS | CURRENCY_CODE | Bronze | BZ_BILLING_EVENTS | - | Not null, Valid 3-character ISO code | Default to 'USD' or derive from region |
| Silver | SI_BILLING_EVENTS | INVOICE_NUMBER | Bronze | BZ_BILLING_EVENTS | - | Unique when not null | Generate or derive from event metadata |
| Silver | SI_BILLING_EVENTS | TRANSACTION_STATUS | Bronze | BZ_BILLING_EVENTS | - | Not null, Valid enumeration (Completed, Pending, Failed, Refunded) | Derive from transaction metadata |
| Silver | SI_BILLING_EVENTS | LOAD_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_BILLING_EVENTS | UPDATE_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_BILLING_EVENTS | SOURCE_SYSTEM | Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_BILLING_EVENTS | DATA_QUALITY_SCORE | Bronze | BZ_BILLING_EVENTS | - | Range 0.00-1.00 | Calculate based on validation results |
| Silver | SI_BILLING_EVENTS | LOAD_DATE | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_BILLING_EVENTS | UPDATE_DATE | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.7 SI_LICENSES Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_LICENSES | LICENSE_ID | Bronze | BZ_LICENSES | LICENSE_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_LICENSES | ASSIGNED_TO_USER_ID | Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Not null, Valid foreign key reference | Validate against SI_USERS.USER_ID |
| Silver | SI_LICENSES | LICENSE_TYPE | Bronze | BZ_LICENSES | LICENSE_TYPE | Not null, Valid enumeration (Basic, Pro, Enterprise, Add-on) | Standardize to predefined values |
| Silver | SI_LICENSES | START_DATE | Bronze | BZ_LICENSES | START_DATE | Not null, Valid date | Direct mapping with validation |
| Silver | SI_LICENSES | END_DATE | Bronze | BZ_LICENSES | END_DATE | Not null, Valid date, >= START_DATE | Validate date logic |
| Silver | SI_LICENSES | LICENSE_STATUS | Bronze | BZ_LICENSES | - | Not null, Valid enumeration (Active, Expired, Suspended) | Derive based on current date vs END_DATE |
| Silver | SI_LICENSES | ASSIGNED_USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null | Join with BZ_USERS on ASSIGNED_TO_USER_ID |
| Silver | SI_LICENSES | LICENSE_COST | Bronze | BZ_LICENSES | - | Non-negative number | Derive from license type and billing data |
| Silver | SI_LICENSES | RENEWAL_STATUS | Bronze | BZ_LICENSES | - | Valid enumeration (Yes, No) | Derive from license metadata |
| Silver | SI_LICENSES | UTILIZATION_PERCENTAGE | Bronze | BZ_LICENSES | - | Range 0-100 | Calculate based on usage metrics |
| Silver | SI_LICENSES | LOAD_TIMESTAMP | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_LICENSES | UPDATE_TIMESTAMP | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_LICENSES | SOURCE_SYSTEM | Bronze | BZ_LICENSES | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_LICENSES | DATA_QUALITY_SCORE | Bronze | BZ_LICENSES | - | Range 0.00-1.00 | Calculate based on validation results |
| Silver | SI_LICENSES | LOAD_DATE | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_LICENSES | UPDATE_DATE | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.8 SI_WEBINARS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_WEBINARS | WEBINAR_ID | Bronze | BZ_WEBINARS | WEBINAR_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_WEBINARS | HOST_ID | Bronze | BZ_WEBINARS | HOST_ID | Not null, Valid foreign key reference | Validate against SI_USERS.USER_ID |
| Silver | SI_WEBINARS | WEBINAR_TOPIC | Bronze | BZ_WEBINARS | WEBINAR_TOPIC | Valid format | TRIM and standardize topic |
| Silver | SI_WEBINARS | START_TIME | Bronze | BZ_WEBINARS | START_TIME | Not null, Valid timestamp | Convert to UTC and validate |
| Silver | SI_WEBINARS | END_TIME | Bronze | BZ_WEBINARS | END_TIME | Not null, Valid timestamp, >= START_TIME | Convert to UTC and validate logic |
| Silver | SI_WEBINARS | DURATION_MINUTES | Bronze | BZ_WEBINARS | - | Not null, Non-negative | Calculate DATEDIFF(minute, START_TIME, END_TIME) |
| Silver | SI_WEBINARS | REGISTRANTS | Bronze | BZ_WEBINARS | REGISTRANTS | Not null, Non-negative integer | Direct mapping with validation |
| Silver | SI_WEBINARS | ATTENDEES | Bronze | BZ_WEBINARS | - | Non-negative integer, <= REGISTRANTS | Count actual attendees from participant data |
| Silver | SI_WEBINARS | ATTENDANCE_RATE | Bronze | BZ_WEBINARS | - | Range 0-100 | Calculate (ATTENDEES / REGISTRANTS) * 100 |
| Silver | SI_WEBINARS | LOAD_TIMESTAMP | Bronze | BZ_WEBINARS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_WEBINARS | UPDATE_TIMESTAMP | Bronze | BZ_WEBINARS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_WEBINARS | SOURCE_SYSTEM | Bronze | BZ_WEBINARS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_WEBINARS | DATA_QUALITY_SCORE | Bronze | BZ_WEBINARS | - | Range 0.00-1.00 | Calculate based on validation results |
| Silver | SI_WEBINARS | LOAD_DATE | Bronze | BZ_WEBINARS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_WEBINARS | UPDATE_DATE | Bronze | BZ_WEBINARS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.9 SI_DATA_QUALITY_ERRORS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_ID | Bronze | - | - | Not null, Unique | Generate UUID for each error record |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_TABLE | Bronze | - | - | Not null | Populate with source table name during validation |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_RECORD_ID | Bronze | - | - | Not null | Populate with source record identifier |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TYPE | Bronze | - | - | Not null, Valid enumeration | Categorize error type during validation |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_COLUMN | Bronze | - | - | Not null | Populate with column name where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_DESCRIPTION | Bronze | - | - | Not null | Generate detailed error description |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_SEVERITY | Bronze | - | - | Not null, Valid enumeration (Critical, High, Medium, Low) | Assign severity based on error type |
| Silver | SI_DATA_QUALITY_ERRORS | DETECTED_TIMESTAMP | Bronze | - | - | Not null | Set to current timestamp when error detected |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_STATUS | Bronze | - | - | Not null, Valid enumeration (Open, In Progress, Resolved, Ignored) | Default to 'Open' |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_ACTION | Bronze | - | - | Valid format | Populate when resolution action is taken |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLVED_TIMESTAMP | Bronze | - | - | Valid timestamp | Set when error is resolved |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLVED_BY | Bronze | - | - | Valid format | Populate with resolver identifier |
| Silver | SI_DATA_QUALITY_ERRORS | LOAD_DATE | Bronze | - | - | Not null | Set to current date |
| Silver | SI_DATA_QUALITY_ERRORS | UPDATE_DATE | Bronze | - | - | Not null | Set to current date |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_SYSTEM | Bronze | - | - | Not null | Set to 'Silver Layer Validation' |

### 2.10 SI_PIPELINE_AUDIT Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PIPELINE_AUDIT | EXECUTION_ID | Bronze | - | - | Not null, Unique | Generate UUID for each pipeline execution |
| Silver | SI_PIPELINE_AUDIT | PIPELINE_NAME | Bronze | - | - | Not null | Set to specific pipeline name |
| Silver | SI_PIPELINE_AUDIT | START_TIME | Bronze | - | - | Not null | Set to pipeline start timestamp |
| Silver | SI_PIPELINE_AUDIT | END_TIME | Bronze | - | - | Valid timestamp, >= START_TIME | Set to pipeline completion timestamp |
| Silver | SI_PIPELINE_AUDIT | STATUS | Bronze | - | - | Not null, Valid enumeration (Success, Failed, Partial Success, Cancelled) | Set based on pipeline execution result |
| Silver | SI_PIPELINE_AUDIT | ERROR_MESSAGE | Bronze | - | - | Valid format | Populate if pipeline encounters errors |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_DURATION_SECONDS | Bronze | - | - | Non-negative | Calculate END_TIME - START_TIME in seconds |
| Silver | SI_PIPELINE_AUDIT | SOURCE_TABLES_PROCESSED | Bronze | - | - | Valid format | List all Bronze tables processed |
| Silver | SI_PIPELINE_AUDIT | TARGET_TABLES_UPDATED | Bronze | - | - | Valid format | List all Silver tables updated |
| Silver | SI_PIPELINE_AUDIT | RECORDS_PROCESSED | Bronze | - | - | Non-negative integer | Count total records processed |
| Silver | SI_PIPELINE_AUDIT | RECORDS_INSERTED | Bronze | - | - | Non-negative integer | Count new records inserted |
| Silver | SI_PIPELINE_AUDIT | RECORDS_UPDATED | Bronze | - | - | Non-negative integer | Count existing records updated |
| Silver | SI_PIPELINE_AUDIT | RECORDS_REJECTED | Bronze | - | - | Non-negative integer | Count records rejected due to quality issues |
| Silver | SI_PIPELINE_AUDIT | EXECUTED_BY | Bronze | - | - | Not null | Set to user or system executing pipeline |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_ENVIRONMENT | Bronze | - | - | Not null, Valid enumeration (Dev, Test, Prod) | Set based on execution environment |
| Silver | SI_PIPELINE_AUDIT | DATA_LINEAGE_INFO | Bronze | - | - | Valid format | Document data transformation lineage |
| Silver | SI_PIPELINE_AUDIT | LOAD_DATE | Bronze | - | - | Not null | Set to current date |
| Silver | SI_PIPELINE_AUDIT | UPDATE_DATE | Bronze | - | - | Not null | Set to current date |
| Silver | SI_PIPELINE_AUDIT | SOURCE_SYSTEM | Bronze | - | - | Not null | Set to 'Silver Layer Pipeline' |

## 3. Data Quality and Validation Rules

### 3.1 Primary Validation Rules

1. **Referential Integrity Checks**
   - All foreign key references must exist in target tables
   - HOST_ID in meetings must exist in users table
   - USER_ID in all dependent tables must exist in users table
   - MEETING_ID in participants and feature usage must exist in meetings table

2. **Data Type and Format Validations**
   - Email addresses must follow valid email format pattern
   - Dates must be valid and not in the future (where applicable)
   - Numeric values must be within specified ranges
   - Enumerated values must match predefined lists

3. **Business Logic Validations**
   - End times must be greater than or equal to start times
   - Duration calculations must be consistent with start/end times
   - Attendance duration cannot exceed meeting duration
   - Attendees cannot exceed registrants for webinars

4. **Data Quality Scoring**
   - Calculate quality score based on validation results
   - Score range: 0.00 (poor quality) to 1.00 (excellent quality)
   - Consider completeness, accuracy, consistency, and validity

### 3.2 Error Handling and Logging

1. **Error Classification**
   - Critical: Data that prevents processing (missing required fields)
   - High: Data that affects business logic (invalid references)
   - Medium: Data that affects quality (format issues)
   - Low: Data that affects completeness (missing optional fields)

2. **Error Resolution Process**
   - Log all validation errors in SI_DATA_QUALITY_ERRORS table
   - Implement automated correction for common issues
   - Flag records requiring manual review
   - Track resolution status and actions taken

3. **Audit Trail Maintenance**
   - Record all pipeline executions in SI_PIPELINE_AUDIT table
   - Track processing statistics and performance metrics
   - Maintain data lineage information
   - Enable troubleshooting and performance optimization

## 4. Implementation Guidelines

### 4.1 ETL Process Flow

1. **Extract Phase**
   - Read data from Bronze layer tables
   - Apply initial data type conversions
   - Handle null values and missing data

2. **Transform Phase**
   - Apply validation rules and business logic
   - Perform data cleansing and standardization
   - Calculate derived fields and metrics
   - Generate data quality scores

3. **Load Phase**
   - Insert/update records in Silver layer tables
   - Log validation errors and processing statistics
   - Update audit trail and metadata

### 4.2 Performance Optimization

1. **Incremental Processing**
   - Process only changed records based on update timestamps
   - Implement change data capture (CDC) where possible
   - Use clustering keys for frequently queried columns

2. **Parallel Processing**
   - Process independent tables in parallel
   - Use Snowflake's multi-cluster warehouses for scalability
   - Implement proper error handling for concurrent operations

### 4.3 Monitoring and Alerting

1. **Data Quality Monitoring**
   - Set up alerts for data quality score thresholds
   - Monitor error rates and resolution times
   - Track data freshness and processing delays

2. **Pipeline Monitoring**
   - Monitor pipeline execution times and success rates
   - Set up alerts for pipeline failures
   - Track resource utilization and performance metrics

This comprehensive data mapping provides the foundation for a robust Silver layer implementation that ensures data quality, consistency, and usability across the Zoom Platform Analytics System.