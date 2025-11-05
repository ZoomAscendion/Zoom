_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer logical data model for Zoom Platform Analytics System supporting cleansed and standardized data with error handling and audit tracking
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Silver Layer Logical Data Model

## 1. Silver Layer Logical Model

### 1.1 Si_Users
**Description:** Cleansed and standardized user account information with validated personal details and subscription plans.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(255) | Standardized display name of the user account, cleansed for consistency |
| EMAIL | VARCHAR(320) | Validated email address associated with the user account in lowercase format |
| COMPANY | VARCHAR(500) | Standardized company or organization name the user is affiliated with |
| PLAN_TYPE | VARCHAR(50) | Standardized subscription plan type (Free, Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| RECORD_STATUS | VARCHAR(20) | Status of the record (ACTIVE, INACTIVE, ARCHIVED) |

### 1.2 Si_Meetings
**Description:** Cleansed and standardized meeting information with validated scheduling, duration, and host details.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(1000) | Standardized subject or topic of the meeting, cleansed for special characters |
| START_TIME | TIMESTAMP_NTZ | Validated timestamp when the meeting started in UTC format |
| END_TIME | TIMESTAMP_NTZ | Validated timestamp when the meeting ended in UTC format |
| DURATION_MINUTES | INTEGER | Calculated total duration of the meeting in minutes, validated for accuracy |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| RECORD_STATUS | VARCHAR(20) | Status of the record (ACTIVE, INACTIVE, ARCHIVED) |
| MEETING_TYPE | VARCHAR(50) | Standardized meeting type classification (Regular, Webinar, Personal, Recurring) |

### 1.3 Si_Participants
**Description:** Cleansed and standardized participant information with validated join/leave times and attendance duration.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ | Validated timestamp when the participant joined the meeting in UTC format |
| LEAVE_TIME | TIMESTAMP_NTZ | Validated timestamp when the participant left the meeting in UTC format |
| ATTENDANCE_DURATION | INTEGER | Calculated attendance duration in minutes, derived from join and leave times |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| RECORD_STATUS | VARCHAR(20) | Status of the record (ACTIVE, INACTIVE, ARCHIVED) |
| PARTICIPANT_ROLE | VARCHAR(30) | Standardized role of participant (Host, Co-host, Attendee, Panelist) |

### 1.4 Si_Feature_Usage
**Description:** Cleansed and standardized feature usage data with validated usage counts and standardized feature names.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(100) | Standardized name of the Zoom feature used (screen_share, recording, chat, breakout_rooms, whiteboard) |
| USAGE_COUNT | INTEGER | Validated number of times the feature was used, ensuring non-negative values |
| USAGE_DATE | DATE | Standardized date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| RECORD_STATUS | VARCHAR(20) | Status of the record (ACTIVE, INACTIVE, ARCHIVED) |
| FEATURE_CATEGORY | VARCHAR(50) | Standardized category grouping of features (Communication, Collaboration, Security, Recording) |

### 1.5 Si_Support_Tickets
**Description:** Cleansed and standardized support ticket information with validated ticket types and resolution status.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(100) | Standardized category of the support ticket (Technical_Issue, Billing_Inquiry, Feature_Request, Account_Access) |
| RESOLUTION_STATUS | VARCHAR(50) | Standardized current status of ticket resolution (Open, In_Progress, Resolved, Closed, Escalated) |
| OPEN_DATE | DATE | Validated date when the support ticket was created |
| CLOSE_DATE | DATE | Validated date when the support ticket was resolved or closed |
| RESOLUTION_TIME_HOURS | DECIMAL(10,2) | Calculated time taken to resolve the ticket in hours |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| RECORD_STATUS | VARCHAR(20) | Status of the record (ACTIVE, INACTIVE, ARCHIVED) |
| PRIORITY_LEVEL | VARCHAR(20) | Standardized priority level (Low, Medium, High, Critical) |

### 1.6 Si_Billing_Events
**Description:** Cleansed and standardized billing event information with validated amounts and event types.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(50) | Standardized type of billing event (Charge, Credit, Refund, Adjustment, Subscription) |
| AMOUNT | DECIMAL(12,2) | Validated monetary amount of the billing event in USD |
| EVENT_DATE | DATE | Standardized date when the billing event occurred |
| PAYMENT_METHOD | VARCHAR(50) | Standardized payment method used (Credit_Card, Bank_Transfer, PayPal, Invoice) |
| CURRENCY_CODE | VARCHAR(3) | Standardized ISO currency code (USD, EUR, GBP, etc.) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| RECORD_STATUS | VARCHAR(20) | Status of the record (ACTIVE, INACTIVE, ARCHIVED) |

### 1.7 Si_Licenses
**Description:** Cleansed and standardized license information with validated dates and license types.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(50) | Standardized type of Zoom license (Basic, Pro, Business, Enterprise, Education) |
| START_DATE | DATE | Validated date when the license becomes active |
| END_DATE | DATE | Validated date when the license expires |
| LICENSE_STATUS | VARCHAR(20) | Standardized current status of the license (Active, Expired, Suspended, Cancelled) |
| LICENSE_DURATION_DAYS | INTEGER | Calculated duration of the license in days |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| RECORD_STATUS | VARCHAR(20) | Status of the record (ACTIVE, INACTIVE, ARCHIVED) |

### 1.8 Si_Data_Quality_Errors
**Description:** Comprehensive error tracking table for data validation failures and quality issues identified during Silver layer processing.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| ERROR_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the data quality error was detected |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table where the error originated |
| TARGET_TABLE | VARCHAR(100) | Name of the Silver layer table being processed |
| ERROR_TYPE | VARCHAR(50) | Type of data quality error (Missing_Value, Invalid_Format, Constraint_Violation, Duplicate_Record) |
| ERROR_SEVERITY | VARCHAR(20) | Severity level of the error (Low, Medium, High, Critical) |
| ERROR_DESCRIPTION | VARCHAR(2000) | Detailed description of the data quality error encountered |
| AFFECTED_COLUMN | VARCHAR(100) | Name of the column where the error was detected |
| INVALID_VALUE | VARCHAR(1000) | The actual invalid value that caused the error |
| EXPECTED_FORMAT | VARCHAR(500) | Expected format or constraint that was violated |
| ERROR_COUNT | INTEGER | Number of records affected by this specific error |
| RESOLUTION_STATUS | VARCHAR(30) | Status of error resolution (Open, In_Progress, Resolved, Ignored) |
| RESOLUTION_ACTION | VARCHAR(1000) | Action taken to resolve the error |
| PROCESSED_BY | VARCHAR(100) | System or process that detected the error |

### 1.9 Si_Pipeline_Audit
**Description:** Comprehensive audit table tracking all pipeline execution details, performance metrics, and processing statistics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| PIPELINE_RUN_ID | VARCHAR(100) | Unique identifier for each pipeline execution run |
| PIPELINE_NAME | VARCHAR(200) | Name of the data pipeline being executed |
| EXECUTION_START_TIME | TIMESTAMP_NTZ | Timestamp when the pipeline execution started |
| EXECUTION_END_TIME | TIMESTAMP_NTZ | Timestamp when the pipeline execution completed |
| EXECUTION_DURATION_SECONDS | INTEGER | Total execution time of the pipeline in seconds |
| PIPELINE_STATUS | VARCHAR(30) | Overall status of pipeline execution (Running, Completed, Failed, Cancelled) |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table being processed |
| TARGET_TABLE | VARCHAR(100) | Name of the target Silver layer table |
| RECORDS_READ | INTEGER | Total number of records read from source |
| RECORDS_PROCESSED | INTEGER | Total number of records successfully processed |
| RECORDS_INSERTED | INTEGER | Number of new records inserted into Silver layer |
| RECORDS_UPDATED | INTEGER | Number of existing records updated in Silver layer |
| RECORDS_REJECTED | INTEGER | Number of records rejected due to quality issues |
| ERROR_COUNT | INTEGER | Total number of errors encountered during processing |
| WARNING_COUNT | INTEGER | Total number of warnings generated during processing |
| DATA_VOLUME_MB | DECIMAL(12,2) | Volume of data processed in megabytes |
| PROCESSING_RATE_RECORDS_PER_SECOND | DECIMAL(10,2) | Processing rate measured in records per second |
| MEMORY_USAGE_MB | DECIMAL(10,2) | Peak memory usage during pipeline execution in megabytes |
| CPU_USAGE_PERCENT | DECIMAL(5,2) | Average CPU usage percentage during execution |
| EXECUTED_BY | VARCHAR(100) | User or system that triggered the pipeline execution |
| EXECUTION_MODE | VARCHAR(30) | Mode of execution (Batch, Incremental, Full_Refresh, Real_Time) |
| ERROR_MESSAGE | VARCHAR(4000) | Detailed error message if pipeline failed |
| CONFIGURATION_HASH | VARCHAR(64) | Hash of pipeline configuration for change tracking |

## 2. Conceptual Data Model Diagram

### 2.1 Silver Layer Relationships in Block Diagram Format

```
┌─────────────────┐
│    Si_Users     │
│                 │
│ - USER_NAME     │
│ - EMAIL         │
│ - COMPANY       │
│ - PLAN_TYPE     │
│ - DATA_QUALITY_ │
│   SCORE         │
└─────────────────┘
         │
         │ (User Reference)
         ▼
┌─────────────────┐       ┌─────────────────┐
│   Si_Meetings   │◄──────┤ Si_Participants │
│                 │       │                 │
│ - MEETING_TOPIC │       │ - JOIN_TIME     │
│ - START_TIME    │       │ - LEAVE_TIME    │
│ - END_TIME      │       │ - ATTENDANCE_   │
│ - DURATION_MIN  │       │   DURATION      │
│ - MEETING_TYPE  │       │ - PARTICIPANT_  │
└─────────────────┘       │   ROLE          │
         │                 └─────────────────┘
         │ (Meeting Reference)
         ▼
┌─────────────────┐
│ Si_Feature_Usage│
│                 │
│ - FEATURE_NAME  │
│ - USAGE_COUNT   │
│ - USAGE_DATE    │
│ - FEATURE_      │
│   CATEGORY      │
└─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    Si_Users     │◄──────┤Si_Support_Tickets│
│                 │       │                 │
│ (User Reference)│       │ - TICKET_TYPE   │
└─────────────────┘       │ - RESOLUTION_   │
                          │   STATUS        │
                          │ - OPEN_DATE     │
                          │ - CLOSE_DATE    │
                          │ - PRIORITY_LEVEL│
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    Si_Users     │◄──────┤ Si_Billing_Events│
│                 │       │                 │
│ (User Reference)│       │ - EVENT_TYPE    │
└─────────────────┘       │ - AMOUNT        │
                          │ - EVENT_DATE    │
                          │ - PAYMENT_METHOD│
                          │ - CURRENCY_CODE │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    Si_Users     │◄──────┤   Si_Licenses   │
│                 │       │                 │
│ (User Reference)│       │ - LICENSE_TYPE  │
└─────────────────┘       │ - START_DATE    │
                          │ - END_DATE      │
                          │ - LICENSE_STATUS│
                          │ - LICENSE_      │
                          │   DURATION_DAYS │
                          └─────────────────┘

┌─────────────────┐
│Si_Data_Quality_ │
│    Errors       │
│                 │
│ - ERROR_        │
│   TIMESTAMP     │
│ - SOURCE_TABLE  │
│ - TARGET_TABLE  │
│ - ERROR_TYPE    │
│ - ERROR_        │
│   SEVERITY      │
│ - RESOLUTION_   │
│   STATUS        │
└─────────────────┘

┌─────────────────┐
│ Si_Pipeline_    │
│    Audit        │
│                 │
│ - PIPELINE_     │
│   RUN_ID        │
│ - PIPELINE_NAME │
│ - EXECUTION_    │
│   START_TIME    │
│ - EXECUTION_    │
│   END_TIME      │
│ - RECORDS_READ  │
│ - RECORDS_      │
│   PROCESSED     │
│ - ERROR_COUNT   │
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
8. **Si_Data_Quality_Errors**: Independent table tracking errors across all Silver tables
9. **Si_Pipeline_Audit**: Independent table tracking pipeline execution across all Silver tables

## 3. Design Decisions and Rationale

### 3.1 Key Design Decisions

1. **Naming Convention**: All Silver layer tables use the 'Si_' prefix to maintain consistency and clearly identify Silver layer entities, following the requirement to use the first 3 characters as 'Si_'.

2. **Data Type Standardization**: 
   - VARCHAR fields have defined maximum lengths for better performance and storage optimization
   - TIMESTAMP_NTZ used consistently for all timestamp fields
   - DECIMAL types used for monetary amounts and quality scores with appropriate precision
   - INTEGER used for count fields and duration calculations

3. **Data Quality Enhancement**:
   - Added DATA_QUALITY_SCORE to all main tables for tracking data completeness and accuracy
   - Added RECORD_STATUS for lifecycle management of records
   - Implemented calculated fields like ATTENDANCE_DURATION and RESOLUTION_TIME_HOURS

4. **Error and Audit Framework**:
   - Si_Data_Quality_Errors table provides comprehensive error tracking with detailed error descriptions and resolution tracking
   - Si_Pipeline_Audit table offers complete pipeline execution monitoring with performance metrics

5. **Removal of Key Fields**: As per requirements, all primary key, foreign key, unique identifier, and ID fields have been removed from the Silver layer tables.

### 3.2 Assumptions Made

1. **Data Cleansing**: Assumed that Silver layer processing includes data validation, standardization, and cleansing operations.

2. **UTC Standardization**: All timestamp fields are standardized to UTC format for consistency across different time zones.

3. **Quality Scoring**: Data quality scores are calculated based on completeness, accuracy, and conformity to business rules.

4. **Error Handling**: Comprehensive error handling is implemented with different severity levels and resolution tracking.

5. **Performance Monitoring**: Pipeline audit includes performance metrics for monitoring and optimization purposes.

## 4. Implementation Guidelines

### 4.1 Data Processing Strategy

1. **Data Validation**: Implement comprehensive data validation rules based on the constraints defined in the requirements.

2. **Standardization**: Apply consistent formatting and standardization rules for all text fields, dates, and numeric values.

3. **Quality Scoring**: Calculate data quality scores based on completeness, accuracy, and business rule compliance.

4. **Error Handling**: Capture and log all data quality issues in the Si_Data_Quality_Errors table with appropriate severity levels.

### 4.2 Monitoring and Auditing

1. **Pipeline Monitoring**: Track all pipeline executions with detailed performance metrics in Si_Pipeline_Audit table.

2. **Error Resolution**: Implement processes for reviewing and resolving data quality errors based on severity levels.

3. **Data Lineage**: Maintain clear data lineage from Bronze to Silver layer through audit trails.

4. **Performance Optimization**: Use pipeline performance metrics to identify bottlenecks and optimize processing.

### 4.3 Security and Compliance

1. **Data Masking**: Implement appropriate data masking for PII fields in non-production environments.

2. **Access Control**: Maintain role-based access control consistent with Bronze layer security requirements.

3. **Audit Trail**: Comprehensive audit trail through Si_Pipeline_Audit table for compliance requirements.

4. **Data Retention**: Implement appropriate data retention policies for error logs and audit records.