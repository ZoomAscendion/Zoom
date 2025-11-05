_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer logical data model for Zoom Platform Analytics System supporting cleaned and standardized data for analytics
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Silver Layer Logical Data Model

## 1. Silver Layer Logical Model

### 1.1 Si_Users
**Description:** Cleaned and standardized user account information with validated data types and consistent formatting for analytics processing.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Standardized display name of the user account with consistent formatting |
| EMAIL | VARCHAR(16777216) | Validated email address associated with the user account in lowercase format |
| COMPANY | VARCHAR(16777216) | Standardized company or organization name with consistent capitalization |
| PLAN_TYPE | VARCHAR(50) | Standardized subscription plan type (Free, Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |

### 1.2 Si_Meetings
**Description:** Cleaned meeting information with validated timestamps, calculated durations, and standardized meeting categorization for analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Cleaned and standardized meeting topic with consistent formatting |
| START_TIME | TIMESTAMP_NTZ(9) | Validated timestamp when the meeting started in UTC timezone |
| END_TIME | TIMESTAMP_NTZ(9) | Validated timestamp when the meeting ended in UTC timezone |
| DURATION_MINUTES | NUMBER(10,2) | Calculated and validated meeting duration in minutes with decimal precision |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |

### 1.3 Si_Participants
**Description:** Cleaned participant data with validated join/leave times and calculated attendance duration for meeting analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Validated timestamp when the participant joined the meeting in UTC |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Validated timestamp when the participant left the meeting in UTC |
| ATTENDANCE_DURATION | NUMBER(10,2) | Calculated attendance duration in minutes derived from join and leave times |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |

### 1.4 Si_Feature_Usage
**Description:** Standardized feature usage data with validated feature names and usage metrics for platform analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(100) | Standardized Zoom feature name (screen_share, recording, chat, breakout_rooms, whiteboard) |
| USAGE_COUNT | NUMBER(10,0) | Validated number of times the feature was used in the meeting |
| USAGE_DATE | DATE | Standardized date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |

### 1.5 Si_Support_Tickets
**Description:** Cleaned support ticket data with standardized ticket types, status values, and validated dates for support analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(100) | Standardized support ticket category (technical_issue, billing_inquiry, feature_request, account_access) |
| RESOLUTION_STATUS | VARCHAR(50) | Standardized ticket status (open, in_progress, resolved, closed, escalated) |
| OPEN_DATE | DATE | Validated date when the support ticket was created |
| CLOSE_DATE | DATE | Calculated date when the support ticket was resolved or closed |
| RESOLUTION_TIME_HOURS | NUMBER(10,2) | Calculated time to resolution in hours for performance metrics |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |

### 1.6 Si_Billing_Events
**Description:** Cleaned billing event data with validated amounts, standardized event types, and currency normalization for revenue analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(100) | Standardized billing event type (charge, credit, refund, adjustment, subscription) |
| AMOUNT | NUMBER(15,2) | Validated and standardized monetary amount in USD currency |
| EVENT_DATE | DATE | Validated date when the billing event occurred |
| CURRENCY_CODE | VARCHAR(3) | Standardized three-letter currency code (USD, EUR, GBP, etc.) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |

### 1.7 Si_Licenses
**Description:** Cleaned license data with validated dates, standardized license types, and calculated license duration for license analytics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(50) | Standardized Zoom license type (Basic, Pro, Business, Enterprise, Education) |
| START_DATE | DATE | Validated date when the license becomes active |
| END_DATE | DATE | Validated date when the license expires |
| LICENSE_DURATION_DAYS | NUMBER(10,0) | Calculated license duration in days for utilization analysis |
| LICENSE_STATUS | VARCHAR(50) | Derived license status (active, expired, expiring_soon, suspended) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was first loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |

## 2. Data Quality and Error Management Tables

### 2.1 Si_Data_Quality_Errors
**Description:** Comprehensive error tracking table to capture data validation failures and quality issues during Silver layer processing.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| ERROR_RECORD_ID | VARCHAR(100) | Unique identifier for each error record |
| SOURCE_TABLE | VARCHAR(100) | Name of the source Bronze table where error originated |
| TARGET_TABLE | VARCHAR(100) | Name of the target Silver table being processed |
| ERROR_TYPE | VARCHAR(100) | Type of data quality error (validation_failure, format_error, constraint_violation, missing_data) |
| ERROR_DESCRIPTION | VARCHAR(1000) | Detailed description of the data quality issue |
| FAILED_COLUMN | VARCHAR(100) | Column name where the validation failed |
| FAILED_VALUE | VARCHAR(1000) | Original value that failed validation |
| EXPECTED_FORMAT | VARCHAR(500) | Expected data format or constraint |
| ERROR_SEVERITY | VARCHAR(50) | Severity level of the error (critical, high, medium, low) |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the error was detected |
| PROCESSING_BATCH_ID | VARCHAR(100) | Batch identifier for the processing run |
| RESOLUTION_STATUS | VARCHAR(50) | Status of error resolution (open, investigating, resolved, ignored) |
| RESOLUTION_NOTES | VARCHAR(1000) | Notes on how the error was resolved or handled |

### 2.2 Si_Data_Validation_Rules
**Description:** Configuration table storing data validation rules and constraints applied during Silver layer processing.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RULE_ID | VARCHAR(100) | Unique identifier for each validation rule |
| TABLE_NAME | VARCHAR(100) | Target table name where the rule applies |
| COLUMN_NAME | VARCHAR(100) | Column name where the rule is applied |
| RULE_TYPE | VARCHAR(100) | Type of validation rule (not_null, format_check, range_check, referential_integrity) |
| RULE_EXPRESSION | VARCHAR(1000) | SQL expression or regex pattern for the validation rule |
| ERROR_MESSAGE | VARCHAR(500) | Standard error message for rule violations |
| RULE_SEVERITY | VARCHAR(50) | Severity level for rule violations |
| IS_ACTIVE | BOOLEAN | Flag indicating if the rule is currently active |
| CREATED_DATE | DATE | Date when the validation rule was created |
| LAST_MODIFIED | TIMESTAMP_NTZ(9) | Timestamp when the rule was last modified |

## 3. Pipeline Audit and Execution Tracking Tables

### 3.1 Si_Pipeline_Execution_Log
**Description:** Comprehensive audit table tracking all Silver layer pipeline executions, performance metrics, and operational details.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EXECUTION_ID | VARCHAR(100) | Unique identifier for each pipeline execution |
| PIPELINE_NAME | VARCHAR(200) | Name of the data pipeline being executed |
| EXECUTION_START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the pipeline execution started |
| EXECUTION_END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the pipeline execution completed |
| EXECUTION_DURATION_SECONDS | NUMBER(10,2) | Total execution time in seconds |
| EXECUTION_STATUS | VARCHAR(50) | Status of pipeline execution (running, completed, failed, cancelled) |
| RECORDS_PROCESSED | NUMBER(15,0) | Total number of records processed in the execution |
| RECORDS_SUCCESS | NUMBER(15,0) | Number of records successfully processed |
| RECORDS_FAILED | NUMBER(15,0) | Number of records that failed processing |
| ERROR_COUNT | NUMBER(10,0) | Total number of errors encountered during execution |
| WARNING_COUNT | NUMBER(10,0) | Total number of warnings generated during execution |
| SOURCE_TABLES | VARCHAR(1000) | Comma-separated list of source tables processed |
| TARGET_TABLES | VARCHAR(1000) | Comma-separated list of target tables updated |
| EXECUTED_BY | VARCHAR(100) | User or system that initiated the pipeline execution |
| EXECUTION_MODE | VARCHAR(50) | Mode of execution (full_load, incremental, delta) |
| CONFIGURATION_VERSION | VARCHAR(50) | Version of pipeline configuration used |
| RESOURCE_USAGE_CPU | NUMBER(10,2) | CPU usage percentage during execution |
| RESOURCE_USAGE_MEMORY | NUMBER(10,2) | Memory usage in GB during execution |
| DATA_VOLUME_MB | NUMBER(15,2) | Total data volume processed in megabytes |

### 3.2 Si_Pipeline_Step_Details
**Description:** Detailed tracking of individual pipeline steps and transformations within each execution.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| STEP_ID | VARCHAR(100) | Unique identifier for each pipeline step |
| EXECUTION_ID | VARCHAR(100) | Reference to the parent pipeline execution |
| STEP_NAME | VARCHAR(200) | Name of the pipeline step or transformation |
| STEP_ORDER | NUMBER(5,0) | Sequential order of the step within the pipeline |
| STEP_START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the step started |
| STEP_END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the step completed |
| STEP_DURATION_SECONDS | NUMBER(10,2) | Duration of the step execution in seconds |
| STEP_STATUS | VARCHAR(50) | Status of the step (running, completed, failed, skipped) |
| INPUT_RECORD_COUNT | NUMBER(15,0) | Number of input records for the step |
| OUTPUT_RECORD_COUNT | NUMBER(15,0) | Number of output records from the step |
| TRANSFORMATION_TYPE | VARCHAR(100) | Type of transformation applied (cleansing, validation, aggregation, enrichment) |
| ERROR_MESSAGE | VARCHAR(1000) | Error message if the step failed |
| PERFORMANCE_METRICS | VARCHAR(2000) | JSON string containing detailed performance metrics |

## 4. Conceptual Data Model Diagram

### 4.1 Silver Layer Table Relationships in Block Diagram Format

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
                          │ - CLOSE_DATE    │
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
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│ All Si_Tables   │◄──────┤Si_Data_Quality_ │
│                 │       │     Errors      │
│ (Table Reference│       │ - ERROR_TYPE    │
└─────────────────┘       │ - ERROR_DESC    │
                          │ - FAILED_COLUMN │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│Si_Pipeline_Exec │◄──────┤Si_Pipeline_Step │
│    ution_Log    │       │    _Details     │
│ - PIPELINE_NAME │       │ - STEP_NAME     │
│ - EXEC_STATUS   │       │ - STEP_STATUS   │
│ - RECORDS_PROC  │       │ - TRANSFORM_TYPE│
└─────────────────┘       └─────────────────┘
                          (Execution Reference)
```

### 4.2 Key Relationships

1. **Si_Users → Si_Meetings**: One-to-Many relationship via User Reference (Host)
2. **Si_Meetings → Si_Participants**: One-to-Many relationship via Meeting Reference
3. **Si_Meetings → Si_Feature_Usage**: One-to-Many relationship via Meeting Reference
4. **Si_Users → Si_Support_Tickets**: One-to-Many relationship via User Reference
5. **Si_Users → Si_Billing_Events**: One-to-Many relationship via User Reference
6. **Si_Users → Si_Licenses**: One-to-Many relationship via User Reference
7. **Si_Participants → Si_Users**: Many-to-One relationship via User Reference (Attendee)
8. **All Si_Tables → Si_Data_Quality_Errors**: One-to-Many relationship via Table Reference
9. **Si_Pipeline_Execution_Log → Si_Pipeline_Step_Details**: One-to-Many relationship via Execution Reference
10. **Si_Data_Validation_Rules → Si_Data_Quality_Errors**: One-to-Many relationship via Rule Reference

## 5. Design Decisions and Rationale

### 5.1 Key Design Decisions

1. **Naming Convention**: All Silver layer tables use the 'Si_' prefix to maintain consistency and clearly identify Silver layer entities, following the medallion architecture standards.

2. **Data Type Standardization**: 
   - Standardized VARCHAR lengths for categorical fields (50-100 characters)
   - Consistent use of TIMESTAMP_NTZ(9) for all timestamp fields
   - NUMBER types with appropriate precision for calculations
   - Added calculated fields like ATTENDANCE_DURATION and RESOLUTION_TIME_HOURS

3. **Data Quality Framework**: 
   - Comprehensive error tracking with Si_Data_Quality_Errors table
   - Configurable validation rules through Si_Data_Validation_Rules table
   - Error severity classification for prioritized resolution

4. **Pipeline Audit Strategy**: 
   - Detailed execution tracking with Si_Pipeline_Execution_Log
   - Step-level monitoring through Si_Pipeline_Step_Details
   - Performance metrics and resource usage tracking

5. **Enhanced Analytics Fields**: 
   - Added calculated fields for better analytics (ATTENDANCE_DURATION, RESOLUTION_TIME_HOURS)
   - Standardized categorical values for consistent reporting
   - Currency normalization for global revenue analysis

### 5.2 Assumptions Made

1. **Data Cleansing**: Assumed that Silver layer will implement comprehensive data cleansing and validation processes.

2. **Timezone Standardization**: All timestamps are standardized to UTC timezone for consistent analysis.

3. **Currency Normalization**: Financial amounts are normalized to USD for consistent revenue reporting.

4. **Error Handling**: Comprehensive error handling framework is implemented to capture and track all data quality issues.

5. **Performance Requirements**: Design supports high-volume data processing with appropriate indexing strategies.

## 6. Implementation Guidelines

### 6.1 Data Transformation Strategy

1. **Data Cleansing**: Implement standardization of categorical values, email formatting, and company name normalization.

2. **Data Validation**: Apply comprehensive validation rules for data types, formats, and business logic constraints.

3. **Calculated Fields**: Generate derived fields like attendance duration, resolution time, and license status.

4. **Error Handling**: Capture all validation failures and data quality issues in the error management tables.

### 6.2 Performance Optimization

1. **Partitioning**: Consider partitioning large tables by date fields for improved query performance.

2. **Indexing**: Implement appropriate indexing strategies on frequently queried columns.

3. **Incremental Processing**: Use timestamp fields for efficient incremental data processing.

4. **Resource Monitoring**: Track resource usage and performance metrics for optimization.

### 6.3 Data Governance

1. **Audit Trail**: Maintain comprehensive audit trails for all data transformations and pipeline executions.

2. **Data Lineage**: Track data lineage from Bronze to Silver layer through audit tables.

3. **Quality Monitoring**: Implement continuous data quality monitoring and alerting.

4. **Compliance**: Ensure compliance with data protection regulations through proper error handling and audit trails.