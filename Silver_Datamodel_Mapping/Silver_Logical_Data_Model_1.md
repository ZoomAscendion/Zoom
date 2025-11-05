_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer logical data model for Zoom Platform Analytics System supporting cleaned and standardized data with error tracking and audit capabilities
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Silver Layer Logical Data Model

## 1. Silver Layer Logical Model

### 1.1 Si_Users
**Description:** Cleaned and standardized user account information with validated personal details and subscription plans, processed from Bronze layer with data quality checks applied.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Standardized display name of the user account with consistent formatting |
| EMAIL | VARCHAR(16777216) | Validated email address associated with the user account in lowercase format |
| COMPANY | VARCHAR(16777216) | Standardized company or organization name the user is affiliated with |
| PLAN_TYPE | VARCHAR(16777216) | Standardized subscription plan type (Basic, Pro, Business, Enterprise, Education) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 1.2 Si_Meetings
**Description:** Cleaned and validated meeting information with standardized duration calculations and time zone normalization, processed from Bronze layer with business rule validation.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Cleaned and standardized subject or topic of the meeting |
| START_TIME | TIMESTAMP_NTZ(9) | Standardized timestamp when the meeting started in UTC format |
| END_TIME | TIMESTAMP_NTZ(9) | Standardized timestamp when the meeting ended in UTC format |
| DURATION_MINUTES | NUMBER(38,0) | Calculated and validated total duration of the meeting in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 1.3 Si_Participants
**Description:** Cleaned participant data with validated join/leave times and calculated attendance duration, processed from Bronze layer with temporal consistency checks.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Validated timestamp when the participant joined the meeting in UTC format |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Validated timestamp when the participant left the meeting in UTC format |
| ATTENDANCE_DURATION | NUMBER(38,0) | Calculated duration of participant attendance in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 1.4 Si_Feature_Usage
**Description:** Standardized feature usage data with validated feature names and usage counts, processed from Bronze layer with feature catalog validation.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Standardized name of the Zoom feature (screen_share, recording, chat, breakout_rooms, whiteboard) |
| USAGE_COUNT | NUMBER(38,0) | Validated number of times the feature was used in the meeting |
| USAGE_DATE | DATE | Standardized date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 1.5 Si_Support_Tickets
**Description:** Cleaned support ticket information with standardized ticket types and resolution status, processed from Bronze layer with business rule validation.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Standardized category of the support ticket (technical_issue, billing_inquiry, feature_request, account_access) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Standardized status of the ticket resolution (open, in_progress, resolved, closed, escalated) |
| OPEN_DATE | DATE | Validated date when the support ticket was created |
| RESOLUTION_TIME_HOURS | NUMBER(10,2) | Calculated resolution time in hours for closed tickets |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 1.6 Si_Billing_Events
**Description:** Validated billing event information with standardized amounts and event types, processed from Bronze layer with financial data validation.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Standardized type of billing event (charge, credit, refund, adjustment) |
| AMOUNT | NUMBER(10,2) | Validated monetary amount of the billing event in USD |
| EVENT_DATE | DATE | Validated date when the billing event occurred |
| CURRENCY_CODE | VARCHAR(3) | Standardized currency code for the billing amount |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 1.7 Si_Licenses
**Description:** Cleaned license information with validated license types and date ranges, processed from Bronze layer with license validity checks.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Standardized type of Zoom license (Basic, Pro, Business, Enterprise, Education) |
| START_DATE | DATE | Validated date when the license becomes active |
| END_DATE | DATE | Validated date when the license expires |
| LICENSE_STATUS | VARCHAR(50) | Calculated license status (active, expired, expiring_soon, suspended) |
| DAYS_TO_EXPIRY | NUMBER(38,0) | Calculated number of days until license expiration |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which the data originated |

### 1.8 Si_Data_Quality_Errors
**Description:** Comprehensive error tracking table to capture data validation failures and quality issues identified during Bronze to Silver layer processing.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| ERROR_ID | VARCHAR(16777216) | Unique identifier for each data quality error record |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the Bronze layer table where the error was detected |
| SOURCE_RECORD_ID | VARCHAR(16777216) | Identifier of the specific record that failed validation |
| ERROR_TYPE | VARCHAR(100) | Type of data quality error (missing_value, invalid_format, constraint_violation, referential_integrity) |
| ERROR_COLUMN | VARCHAR(16777216) | Column name where the error was detected |
| ERROR_VALUE | VARCHAR(16777216) | The actual value that caused the validation failure |
| ERROR_DESCRIPTION | VARCHAR(16777216) | Detailed description of the validation error |
| VALIDATION_RULE | VARCHAR(16777216) | The specific validation rule that was violated |
| ERROR_SEVERITY | VARCHAR(50) | Severity level of the error (critical, high, medium, low) |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the error was detected |
| PROCESSING_BATCH_ID | VARCHAR(16777216) | Batch identifier for the processing run that detected the error |
| RESOLUTION_STATUS | VARCHAR(50) | Status of error resolution (open, in_progress, resolved, ignored) |
| RESOLUTION_NOTES | VARCHAR(16777216) | Notes about how the error was resolved or handled |

### 1.9 Si_Pipeline_Audit
**Description:** Comprehensive audit table to track all pipeline execution details, performance metrics, and processing statistics for Silver layer operations.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| AUDIT_ID | VARCHAR(16777216) | Unique identifier for each pipeline audit record |
| PIPELINE_NAME | VARCHAR(16777216) | Name of the data pipeline that was executed |
| PIPELINE_RUN_ID | VARCHAR(16777216) | Unique identifier for the specific pipeline execution run |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source Bronze layer table being processed |
| TARGET_TABLE | VARCHAR(16777216) | Name of the target Silver layer table being populated |
| EXECUTION_START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the pipeline execution started |
| EXECUTION_END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the pipeline execution completed |
| EXECUTION_DURATION_SECONDS | NUMBER(10,2) | Total execution time in seconds |
| RECORDS_READ | NUMBER(38,0) | Number of records read from the source table |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records successfully processed |
| RECORDS_INSERTED | NUMBER(38,0) | Number of records inserted into the target table |
| RECORDS_UPDATED | NUMBER(38,0) | Number of records updated in the target table |
| RECORDS_REJECTED | NUMBER(38,0) | Number of records rejected due to validation failures |
| ERROR_COUNT | NUMBER(38,0) | Total number of errors encountered during processing |
| WARNING_COUNT | NUMBER(38,0) | Total number of warnings generated during processing |
| EXECUTION_STATUS | VARCHAR(50) | Overall status of the pipeline execution (success, failed, partial_success, cancelled) |
| ERROR_MESSAGE | VARCHAR(16777216) | Detailed error message if the pipeline execution failed |
| PROCESSED_BY | VARCHAR(16777216) | System or user identifier that executed the pipeline |
| PROCESSING_MODE | VARCHAR(50) | Type of processing performed (full_load, incremental, delta) |
| DATA_FRESHNESS_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of the most recent data processed in this run |
| RESOURCE_UTILIZATION | VARCHAR(16777216) | JSON string containing resource usage metrics (CPU, memory, storage) |

## 2. Conceptual Data Model Diagram

### 2.1 Table Relationships in Block Diagram Format

```
┌─────────────────┐
│   Si_Users      │
│                 │
│ - USER_NAME     │
│ - EMAIL         │
│ - COMPANY       │
│ - PLAN_TYPE     │
└─────────────────┘
         │
         │ (User Reference)
         ▼
┌─────────────────┐       ┌─────────────────┐
│   Si_Meetings   │◄──────┤ Si_Participants │
│                 │       │                 │
│ - MEETING_TOPIC │       │ - JOIN_TIME     │
│ - START_TIME    │       │ - LEAVE_TIME    │
│ - END_TIME      │       │ - ATTENDANCE_DUR│
│ - DURATION_MIN  │       └─────────────────┘
└─────────────────┘       (Meeting Reference)
         │
         │ (Meeting Reference)
         ▼
┌─────────────────┐
│Si_Feature_Usage │
│                 │
│ - FEATURE_NAME  │
│ - USAGE_COUNT   │
│ - USAGE_DATE    │
└─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│   Si_Users      │◄──────┤Si_Support_Tickets│
│                 │       │                 │
│ (User Reference)│       │ - TICKET_TYPE   │
└─────────────────┘       │ - RESOLUTION_ST │
                          │ - OPEN_DATE     │
                          │ - RESOLUTION_TM │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│   Si_Users      │◄──────┤Si_Billing_Events│
│                 │       │                 │
│ (User Reference)│       │ - EVENT_TYPE    │
└─────────────────┘       │ - AMOUNT        │
                          │ - EVENT_DATE    │
                          │ - CURRENCY_CODE │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│   Si_Users      │◄──────┤   Si_Licenses   │
│                 │       │                 │
│ (User Reference)│       │ - LICENSE_TYPE  │
└─────────────────┘       │ - START_DATE    │
                          │ - END_DATE      │
                          │ - LICENSE_STATUS│
                          │ - DAYS_TO_EXPIRY│
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│ All Si_ Tables  │◄──────┤Si_Data_Quality_ │
│                 │       │     Errors      │
│ (Table Reference│       │                 │
│  via SOURCE_    │       │ - ERROR_TYPE    │
│  TABLE field)   │       │ - ERROR_COLUMN  │
└─────────────────┘       │ - ERROR_VALUE   │
                          │ - VALIDATION_RL │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│ All Si_ Tables  │◄──────┤ Si_Pipeline_    │
│                 │       │     Audit       │
│ (Table Reference│       │                 │
│  via SOURCE_    │       │ - PIPELINE_NAME │
│  TABLE and      │       │ - RECORDS_READ  │
│  TARGET_TABLE)  │       │ - RECORDS_PROC  │
└─────────────────┘       │ - EXECUTION_ST  │
                          └─────────────────┘
```

### 2.2 Key Relationships

1. **Si_Users → Si_Meetings**: One-to-Many relationship via User Reference (Host)
2. **Si_Meetings → Si_Participants**: One-to-Many relationship via Meeting Reference
3. **Si_Meetings → Si_Feature_Usage**: One-to-Many relationship via Meeting Reference
4. **Si_Users → Si_Support_Tickets**: One-to-Many relationship via User Reference
5. **Si_Users → Si_Billing_Events**: One-to-Many relationship via User Reference
6. **Si_Users → Si_Licenses**: One-to-Many relationship via User Reference
7. **Si_Participants → Si_Users**: Many-to-One relationship via User Reference (Attendee)
8. **All Si_ Tables → Si_Data_Quality_Errors**: One-to-Many relationship via SOURCE_TABLE field
9. **All Si_ Tables → Si_Pipeline_Audit**: One-to-Many relationship via SOURCE_TABLE and TARGET_TABLE fields

## 3. Design Decisions and Rationale

### 3.1 Key Design Decisions

1. **Naming Convention**: All Silver layer tables follow the 'Si_' prefix to maintain consistency and clearly identify Silver layer entities, distinguishing them from Bronze layer 'Bz_' tables.

2. **Data Standardization**: All data types are standardized and validated, with consistent formatting applied (e.g., email addresses in lowercase, standardized plan types).

3. **Calculated Fields**: Added calculated fields such as ATTENDANCE_DURATION, RESOLUTION_TIME_HOURS, LICENSE_STATUS, and DAYS_TO_EXPIRY to provide business value.

4. **Error Tracking**: Comprehensive error tracking table (Si_Data_Quality_Errors) to capture all validation failures and data quality issues for monitoring and resolution.

5. **Pipeline Audit**: Detailed audit table (Si_Pipeline_Audit) to track pipeline performance, execution statistics, and operational metrics.

6. **Data Quality Enhancement**: Applied business rules and constraints from the requirements to ensure data quality and consistency.

### 3.2 Assumptions Made

1. **Data Cleansing**: Assumed that data cleansing rules are applied consistently across all tables during Bronze to Silver transformation.

2. **Business Rules**: Applied business logic constraints as specified in the requirements document for validation and standardization.

3. **Time Zone Standardization**: All timestamp fields are standardized to UTC format for consistency.

4. **Currency Standardization**: All monetary amounts are standardized to USD with currency code tracking.

5. **Error Handling**: Comprehensive error handling and logging is implemented to ensure data quality and operational visibility.

### 3.3 Data Quality Improvements

1. **Validation Rules**: Applied validation rules for email formats, date ranges, numeric constraints, and categorical values.

2. **Referential Integrity**: Logical referential integrity checks are performed during processing.

3. **Business Logic**: Applied business rules such as meeting duration calculations, license status determination, and resolution time calculations.

4. **Data Standardization**: Consistent formatting and standardization applied to all text fields and categorical values.

5. **Completeness Checks**: Mandatory field validation and completeness checks implemented for critical business data.

## 4. Implementation Guidelines

### 4.1 Data Processing Strategy

1. **Incremental Processing**: Use LOAD_TIMESTAMP and UPDATE_TIMESTAMP for efficient incremental data processing from Bronze to Silver layer.

2. **Error Handling**: Comprehensive error logging in Si_Data_Quality_Errors table with detailed error descriptions and resolution tracking.

3. **Audit Trail**: Complete audit trail in Si_Pipeline_Audit table for all processing activities, performance monitoring, and operational insights.

4. **Data Validation**: Multi-level validation including format checks, business rule validation, and referential integrity verification.

### 4.2 Performance Optimization

1. **Partitioning**: Consider partitioning large tables by date fields for improved query performance.

2. **Indexing**: Implement appropriate indexing strategies for frequently queried fields.

3. **Clustering**: Use clustering keys for tables with high query volumes and specific access patterns.

4. **Resource Management**: Monitor and optimize resource utilization through pipeline audit metrics.

### 4.3 Data Governance

1. **Data Lineage**: Maintain complete data lineage from Bronze to Silver layer through audit tables.

2. **Quality Monitoring**: Continuous monitoring of data quality through error tracking and pipeline audit metrics.

3. **Compliance**: Ensure compliance with data protection regulations through proper PII handling and access controls.

4. **Documentation**: Maintain comprehensive documentation of all transformation rules and business logic applied.