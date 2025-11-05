_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer logical data model for Zoom Platform Analytics System supporting cleaned and validated data with error handling and audit tracking
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Silver Layer Logical Data Model

## 1. Silver Layer Logical Model

### 1.1 Si_Users
**Description:** Cleaned and validated user account information with standardized data types and quality checks applied from Bronze layer.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(255) | Standardized display name of the user account, cleaned and validated |
| EMAIL | VARCHAR(320) | Validated email address associated with the user account following RFC standards |
| COMPANY | VARCHAR(255) | Standardized company or organization name the user is affiliated with |
| PLAN_TYPE | VARCHAR(50) | Standardized subscription plan type (Free, Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| IS_ACTIVE | BOOLEAN | Flag indicating if the user account is currently active |

### 1.2 Si_Meetings
**Description:** Cleaned and validated meeting information with calculated fields and standardized duration metrics from Bronze layer.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(500) | Cleaned and standardized meeting subject or topic |
| START_TIME | TIMESTAMP_NTZ | Validated timestamp when the meeting started |
| END_TIME | TIMESTAMP_NTZ | Validated timestamp when the meeting ended |
| DURATION_MINUTES | INTEGER | Calculated and validated total duration of the meeting in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| MEETING_STATUS | VARCHAR(50) | Derived meeting status (Completed, Cancelled, In Progress, Scheduled) |
| IS_VALID_DURATION | BOOLEAN | Flag indicating if the meeting duration is within acceptable business rules |

### 1.3 Si_Participants
**Description:** Cleaned participant data with calculated attendance metrics and validated join/leave times from Bronze layer.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ | Validated timestamp when the participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ | Validated timestamp when the participant left the meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| ATTENDANCE_DURATION_MINUTES | INTEGER | Calculated duration of participant attendance in minutes |
| ATTENDANCE_PERCENTAGE | DECIMAL(5,2) | Calculated percentage of meeting time the participant was present |
| IS_HOST | BOOLEAN | Flag indicating if the participant was the meeting host |

### 1.4 Si_Feature_Usage
**Description:** Standardized feature usage data with validated counts and categorized feature types from Bronze layer.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(100) | Standardized name of the Zoom feature used (screen_share, recording, chat, breakout_rooms, whiteboard) |
| USAGE_COUNT | INTEGER | Validated number of times the feature was used in the meeting |
| USAGE_DATE | DATE | Validated date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| FEATURE_CATEGORY | VARCHAR(50) | Categorized feature type (Communication, Collaboration, Recording, Security) |
| USAGE_INTENSITY | VARCHAR(20) | Derived usage intensity level (Low, Medium, High) based on usage count |

### 1.5 Si_Support_Tickets
**Description:** Cleaned support ticket information with standardized categories and calculated resolution metrics from Bronze layer.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(100) | Standardized category of the support ticket (Technical_Issue, Billing_Inquiry, Feature_Request, Account_Access) |
| RESOLUTION_STATUS | VARCHAR(50) | Standardized status of ticket resolution (Open, In_Progress, Resolved, Closed, Escalated) |
| OPEN_DATE | DATE | Validated date when the support ticket was created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| PRIORITY_LEVEL | VARCHAR(20) | Derived priority level (Low, Medium, High, Critical) based on ticket type and user plan |
| IS_FIRST_CONTACT_RESOLUTION | BOOLEAN | Flag indicating if ticket was resolved on first contact |

### 1.6 Si_Billing_Events
**Description:** Validated billing event information with standardized amounts and categorized event types from Bronze layer.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(50) | Standardized type of billing event (Charge, Credit, Refund, Adjustment) |
| AMOUNT | DECIMAL(12,2) | Validated monetary amount of the billing event |
| EVENT_DATE | DATE | Validated date when the billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| CURRENCY_CODE | VARCHAR(3) | Standardized ISO currency code for the transaction |
| IS_RECURRING | BOOLEAN | Flag indicating if this is a recurring billing event |
| REVENUE_CATEGORY | VARCHAR(50) | Categorized revenue type (Subscription, One_Time, Upgrade, Addon) |

### 1.7 Si_Licenses
**Description:** Cleaned license information with validated dates and standardized license types from Bronze layer.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(50) | Standardized type of Zoom license (Basic, Pro, Business, Enterprise, Education) |
| START_DATE | DATE | Validated date when the license becomes active |
| END_DATE | DATE | Validated date when the license expires |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into the Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in the Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier from which the data originated |
| LICENSE_STATUS | VARCHAR(20) | Derived license status (Active, Expired, Expiring_Soon, Suspended) |
| DAYS_TO_EXPIRY | INTEGER | Calculated number of days until license expiration |
| IS_UTILIZED | BOOLEAN | Flag indicating if the license is actively being used |

## 2. Error Data Structure

### 2.1 Si_Data_Quality_Errors
**Description:** Comprehensive error tracking table for data validation failures and quality issues identified during Bronze to Silver transformation.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| ERROR_ID | VARCHAR(50) | Unique identifier for each data quality error record |
| SOURCE_TABLE | VARCHAR(100) | Name of the source Bronze table where the error originated |
| SOURCE_RECORD_ID | VARCHAR(100) | Identifier of the specific record that failed validation |
| ERROR_TYPE | VARCHAR(50) | Category of error (Data_Type_Mismatch, Missing_Required_Field, Invalid_Format, Business_Rule_Violation) |
| ERROR_DESCRIPTION | VARCHAR(1000) | Detailed description of the validation error encountered |
| FIELD_NAME | VARCHAR(100) | Name of the specific field that failed validation |
| FIELD_VALUE | VARCHAR(500) | Actual value that caused the validation failure |
| EXPECTED_FORMAT | VARCHAR(200) | Expected format or constraint that was violated |
| ERROR_SEVERITY | VARCHAR(20) | Severity level of the error (Critical, High, Medium, Low) |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the error was detected |
| PROCESSING_BATCH_ID | VARCHAR(50) | Identifier of the processing batch where error occurred |
| IS_RESOLVED | BOOLEAN | Flag indicating if the error has been resolved |
| RESOLUTION_ACTION | VARCHAR(500) | Description of action taken to resolve the error |
| RESOLUTION_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the error was resolved |

### 2.2 Si_Validation_Rules
**Description:** Configuration table storing all data validation rules and business logic applied during Silver layer processing.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RULE_ID | VARCHAR(50) | Unique identifier for each validation rule |
| RULE_NAME | VARCHAR(200) | Descriptive name of the validation rule |
| TARGET_TABLE | VARCHAR(100) | Silver table to which the validation rule applies |
| TARGET_FIELD | VARCHAR(100) | Specific field to which the validation rule applies |
| RULE_TYPE | VARCHAR(50) | Type of validation (Format, Range, Business_Logic, Referential_Integrity) |
| RULE_EXPRESSION | VARCHAR(2000) | SQL expression or logic defining the validation rule |
| ERROR_MESSAGE | VARCHAR(500) | Standard error message to display when rule is violated |
| IS_ACTIVE | BOOLEAN | Flag indicating if the validation rule is currently active |
| CREATED_DATE | DATE | Date when the validation rule was created |
| LAST_MODIFIED_DATE | DATE | Date when the validation rule was last modified |

## 3. Audit Data Structure

### 3.1 Si_Pipeline_Audit
**Description:** Comprehensive audit table tracking all pipeline execution details, performance metrics, and processing statistics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| AUDIT_ID | VARCHAR(50) | Unique identifier for each pipeline execution audit record |
| PIPELINE_NAME | VARCHAR(200) | Name of the data pipeline that was executed |
| EXECUTION_ID | VARCHAR(100) | Unique identifier for the specific pipeline execution instance |
| START_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the pipeline execution started |
| END_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the pipeline execution completed |
| EXECUTION_STATUS | VARCHAR(50) | Status of pipeline execution (Success, Failed, Partial_Success, In_Progress) |
| SOURCE_TABLE | VARCHAR(100) | Name of the source Bronze table processed |
| TARGET_TABLE | VARCHAR(100) | Name of the target Silver table created or updated |
| RECORDS_PROCESSED | INTEGER | Total number of records processed from source |
| RECORDS_INSERTED | INTEGER | Number of new records inserted into target table |
| RECORDS_UPDATED | INTEGER | Number of existing records updated in target table |
| RECORDS_REJECTED | INTEGER | Number of records rejected due to validation failures |
| ERROR_COUNT | INTEGER | Total number of errors encountered during processing |
| WARNING_COUNT | INTEGER | Total number of warnings generated during processing |
| PROCESSING_TIME_SECONDS | DECIMAL(10,2) | Total time taken for pipeline execution in seconds |
| THROUGHPUT_RECORDS_PER_SECOND | DECIMAL(10,2) | Calculated processing throughput rate |
| DATA_VOLUME_MB | DECIMAL(10,2) | Volume of data processed in megabytes |
| EXECUTED_BY | VARCHAR(100) | System user or service account that executed the pipeline |
| EXECUTION_MODE | VARCHAR(50) | Mode of execution (Batch, Incremental, Full_Refresh, Real_Time) |
| ERROR_DETAILS | VARCHAR(2000) | Detailed error information if execution failed |
| PERFORMANCE_METRICS | VARCHAR(1000) | JSON string containing additional performance metrics |

### 3.2 Si_Data_Lineage
**Description:** Data lineage tracking table maintaining relationships between Bronze and Silver layer data for traceability and impact analysis.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LINEAGE_ID | VARCHAR(50) | Unique identifier for each data lineage record |
| SOURCE_SYSTEM | VARCHAR(100) | Original source system where data originated |
| SOURCE_TABLE | VARCHAR(100) | Bronze layer table name |
| SOURCE_RECORD_ID | VARCHAR(100) | Unique identifier of the source record |
| TARGET_TABLE | VARCHAR(100) | Silver layer table name |
| TARGET_RECORD_ID | VARCHAR(100) | Unique identifier of the target record |
| TRANSFORMATION_TYPE | VARCHAR(50) | Type of transformation applied (Cleansing, Validation, Enrichment, Aggregation) |
| TRANSFORMATION_RULES | VARCHAR(1000) | Description of transformation rules applied |
| PROCESSING_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the transformation was processed |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score of the transformed data |
| IS_CURRENT | BOOLEAN | Flag indicating if this is the current version of the record |
| VERSION_NUMBER | INTEGER | Version number of the data transformation |

## 4. Conceptual Data Model Diagram

### 4.1 Silver Layer Table Relationships in Block Diagram Format

```
┌─────────────────┐
│    Si_Users     │
│                 │
│ - USER_NAME     │
│ - EMAIL         │
│ - COMPANY       │
│ - PLAN_TYPE     │
│ - IS_ACTIVE     │
└─────────────────┘
         │
         │ (User Reference)
         ▼
┌─────────────────┐       ┌─────────────────┐
│   Si_Meetings   │◄──────┤ Si_Participants │
│                 │       │                 │
│ - MEETING_TOPIC │       │ - JOIN_TIME     │
│ - START_TIME    │       │ - LEAVE_TIME    │
│ - END_TIME      │       │ - ATTENDANCE_%  │
│ - DURATION_MIN  │       │ - IS_HOST       │
│ - MEETING_STATUS│       └─────────────────┘
└─────────────────┘       (Meeting Reference)
         │
         │ (Meeting Reference)
         ▼
┌─────────────────┐
│Si_Feature_Usage │
│                 │
│ - FEATURE_NAME  │
│ - USAGE_COUNT   │
│ - FEATURE_CAT   │
│ - USAGE_INTENS  │
└─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    Si_Users     │◄──────┤Si_Support_Tickets│
│                 │       │                 │
│ (User Reference)│       │ - TICKET_TYPE   │
└─────────────────┘       │ - RESOLUTION_ST │
                          │ - PRIORITY_LVL  │
                          │ - IS_FIRST_CONT │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    Si_Users     │◄──────┤Si_Billing_Events│
│                 │       │                 │
│ (User Reference)│       │ - EVENT_TYPE    │
└─────────────────┘       │ - AMOUNT        │
                          │ - CURRENCY_CODE │
                          │ - IS_RECURRING  │
                          │ - REVENUE_CAT   │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    Si_Users     │◄──────┤   Si_Licenses   │
│                 │       │                 │
│ (User Reference)│       │ - LICENSE_TYPE  │
└─────────────────┘       │ - START_DATE    │
                          │ - END_DATE      │
                          │ - LICENSE_STATUS│
                          │ - DAYS_TO_EXPIRY│
                          │ - IS_UTILIZED   │
                          └─────────────────┘
```

### 4.2 Error and Audit Structure Relationships

```
┌─────────────────┐       ┌─────────────────┐
│ Si_Pipeline_Audit│◄──────┤Si_Data_Quality_ │
│                 │       │     Errors      │
│ - PIPELINE_NAME │       │                 │
│ - EXECUTION_ID  │       │ - ERROR_TYPE    │
│ - START_TIME    │       │ - ERROR_DESC    │
│ - END_TIME      │       │ - FIELD_NAME    │
│ - EXEC_STATUS   │       │ - ERROR_SEVERITY│
│ - RECORDS_PROC  │       │ - IS_RESOLVED   │
│ - RECORDS_REJ   │       └─────────────────┘
│ - ERROR_COUNT   │       (Processing Batch Reference)
└─────────────────┘
         │
         │ (Execution Reference)
         ▼
┌─────────────────┐
│ Si_Data_Lineage │
│                 │
│ - SOURCE_TABLE  │
│ - TARGET_TABLE  │
│ - TRANSFORM_TYPE│
│ - QUALITY_SCORE │
│ - IS_CURRENT    │
│ - VERSION_NUM   │
└─────────────────┘

┌─────────────────┐
│Si_Validation_   │
│     Rules       │
│                 │
│ - RULE_NAME     │
│ - TARGET_TABLE  │
│ - TARGET_FIELD  │
│ - RULE_TYPE     │
│ - RULE_EXPR     │
│ - IS_ACTIVE     │
└─────────────────┘
```

### 4.3 Key Relationships Summary

1. **Si_Users → Si_Meetings**: One-to-Many relationship via User Reference (Host)
2. **Si_Meetings → Si_Participants**: One-to-Many relationship via Meeting Reference
3. **Si_Meetings → Si_Feature_Usage**: One-to-Many relationship via Meeting Reference
4. **Si_Users → Si_Support_Tickets**: One-to-Many relationship via User Reference
5. **Si_Users → Si_Billing_Events**: One-to-Many relationship via User Reference
6. **Si_Users → Si_Licenses**: One-to-Many relationship via User Reference
7. **Si_Participants → Si_Users**: Many-to-One relationship via User Reference (Attendee)
8. **Si_Pipeline_Audit → Si_Data_Quality_Errors**: One-to-Many relationship via Processing Batch Reference
9. **Si_Pipeline_Audit → Si_Data_Lineage**: One-to-Many relationship via Execution Reference
10. **Si_Validation_Rules → Si_Data_Quality_Errors**: One-to-Many relationship via Rule Reference

## 5. Design Decisions and Rationale

### 5.1 Key Design Decisions

1. **Naming Convention**: All Silver layer tables use the 'Si_' prefix to maintain consistency and clearly identify Silver layer entities, following the requirement to use the first 3 characters as 'Si_'.

2. **Data Type Standardization**: 
   - VARCHAR fields have been sized appropriately based on expected content
   - DECIMAL types use appropriate precision for financial and percentage calculations
   - TIMESTAMP_NTZ used consistently for all temporal data
   - BOOLEAN fields added for derived flags and status indicators

3. **Data Quality Enhancement**:
   - Added calculated fields like ATTENDANCE_PERCENTAGE, DAYS_TO_EXPIRY
   - Included derived status fields like MEETING_STATUS, LICENSE_STATUS
   - Added data quality score fields to track cleansing effectiveness

4. **Error Handling Structure**:
   - Comprehensive error tracking with detailed error descriptions
   - Validation rules configuration for maintainable business logic
   - Error severity classification for prioritized resolution

5. **Audit and Lineage**:
   - Complete pipeline execution tracking with performance metrics
   - Data lineage maintenance for impact analysis and traceability
   - Version control for data transformations

### 5.2 Assumptions Made

1. **Data Volume**: Designed for high-volume data processing with appropriate indexing considerations
2. **Business Rules**: Standard business validation rules applied based on Zoom platform requirements
3. **Data Quality**: Assumed Bronze layer data requires significant cleansing and validation
4. **Performance**: Optimized for analytical workloads with denormalized structure where appropriate
5. **Compliance**: PII handling follows data protection standards with audit trail maintenance

### 5.3 Implementation Guidelines

1. **Data Processing**: Implement incremental processing using LOAD_TIMESTAMP and UPDATE_TIMESTAMP
2. **Error Handling**: Use comprehensive error logging with automatic retry mechanisms
3. **Performance**: Consider partitioning on date fields for large tables
4. **Security**: Implement field-level security for PII data
5. **Monitoring**: Use audit tables for pipeline monitoring and alerting
