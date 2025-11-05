_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer logical data model for Zoom Platform Analytics System supporting cleaned and validated data with error tracking and audit capabilities
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Silver Layer Logical Data Model

## 1. Silver Layer Logical Model

### 1.1 Si_Users
**Description:** Cleaned and validated user account information with standardized data types and quality checks applied.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(255) | Standardized display name of the user account, cleaned and validated |
| EMAIL | VARCHAR(320) | Validated email address following RFC 5322 standards |
| COMPANY | VARCHAR(255) | Standardized company or organization name with consistent formatting |
| PLAN_TYPE | VARCHAR(50) | Standardized subscription plan type (Free, Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| IS_ACTIVE | BOOLEAN | Flag indicating if the user account is currently active |

### 1.2 Si_Meetings
**Description:** Cleaned meeting information with validated timestamps, duration calculations, and standardized meeting categorization.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(500) | Cleaned and standardized meeting topic with consistent formatting |
| START_TIME | TIMESTAMP_NTZ | Validated meeting start timestamp in UTC timezone |
| END_TIME | TIMESTAMP_NTZ | Validated meeting end timestamp in UTC timezone |
| DURATION_MINUTES | INTEGER | Calculated meeting duration in minutes, validated for consistency |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| MEETING_TYPE | VARCHAR(50) | Standardized meeting type classification (Regular, Webinar, Personal) |
| IS_VALID_DURATION | BOOLEAN | Flag indicating if meeting duration is within acceptable business rules |

### 1.3 Si_Participants
**Description:** Validated participant information with cleaned join/leave times and attendance duration calculations.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ | Validated timestamp when participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ | Validated timestamp when participant left the meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| ATTENDANCE_DURATION_MINUTES | INTEGER | Calculated attendance duration in minutes |
| IS_FULL_ATTENDANCE | BOOLEAN | Flag indicating if participant attended the entire meeting |

### 1.4 Si_Feature_Usage
**Description:** Standardized feature usage data with validated usage counts and consistent feature naming conventions.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(100) | Standardized feature name (screen_share, recording, chat, breakout_rooms, whiteboard) |
| USAGE_COUNT | INTEGER | Validated count of feature usage, ensuring non-negative values |
| USAGE_DATE | DATE | Validated date when feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| FEATURE_CATEGORY | VARCHAR(50) | Categorized feature type (Communication, Collaboration, Recording, Security) |
| IS_PREMIUM_FEATURE | BOOLEAN | Flag indicating if the feature requires premium subscription |

### 1.5 Si_Support_Tickets
**Description:** Cleaned support ticket information with standardized categorization and validated resolution tracking.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(100) | Standardized ticket type (technical_issue, billing_inquiry, feature_request, account_access) |
| RESOLUTION_STATUS | VARCHAR(50) | Standardized resolution status (open, in_progress, resolved, closed, escalated) |
| OPEN_DATE | DATE | Validated date when support ticket was created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| PRIORITY_LEVEL | VARCHAR(20) | Standardized priority level (Low, Medium, High, Critical) |
| CLOSE_DATE | DATE | Validated date when ticket was resolved or closed |
| RESOLUTION_TIME_HOURS | DECIMAL(10,2) | Calculated resolution time in hours |

### 1.6 Si_Billing_Events
**Description:** Validated billing event information with standardized amounts and consistent event categorization.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(50) | Standardized billing event type (charge, credit, refund, adjustment) |
| AMOUNT | DECIMAL(12,2) | Validated monetary amount with proper currency formatting |
| EVENT_DATE | DATE | Validated date when billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| CURRENCY_CODE | VARCHAR(3) | ISO 4217 currency code for the transaction |
| PAYMENT_METHOD | VARCHAR(50) | Standardized payment method (Credit Card, Bank Transfer, PayPal) |
| IS_RECURRING | BOOLEAN | Flag indicating if this is a recurring billing event |

### 1.7 Si_Licenses
**Description:** Validated license information with standardized license types and validated date ranges.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(50) | Standardized license type (Basic, Pro, Business, Enterprise, Education) |
| START_DATE | DATE | Validated license activation date |
| END_DATE | DATE | Validated license expiration date |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the record was last updated in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| LICENSE_STATUS | VARCHAR(20) | Current license status (Active, Expired, Suspended, Cancelled) |
| DAYS_TO_EXPIRY | INTEGER | Calculated days remaining until license expiration |
| IS_AUTO_RENEWAL | BOOLEAN | Flag indicating if license has auto-renewal enabled |

### 1.8 Si_Data_Quality_Errors
**Description:** Comprehensive error tracking table for data validation issues and quality control in the Silver layer.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| ERROR_ID | VARCHAR(50) | Unique identifier for each data quality error |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table where error was detected |
| ERROR_TYPE | VARCHAR(100) | Type of data quality error (Missing Value, Invalid Format, Constraint Violation, Referential Integrity) |
| ERROR_DESCRIPTION | VARCHAR(1000) | Detailed description of the data quality issue |
| AFFECTED_COLUMN | VARCHAR(100) | Column name where the error was detected |
| ERROR_VALUE | VARCHAR(500) | The actual value that caused the error |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the error was detected |
| SEVERITY_LEVEL | VARCHAR(20) | Error severity (Low, Medium, High, Critical) |
| RESOLUTION_STATUS | VARCHAR(50) | Status of error resolution (Open, In Progress, Resolved, Ignored) |
| RESOLUTION_ACTION | VARCHAR(500) | Action taken to resolve the error |
| RESOLVED_BY | VARCHAR(100) | System or user that resolved the error |
| RESOLVED_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when error was resolved |

### 1.9 Si_Pipeline_Audit
**Description:** Comprehensive audit table tracking all pipeline execution details, performance metrics, and processing statistics.

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| AUDIT_ID | VARCHAR(50) | Unique identifier for each pipeline execution audit record |
| PIPELINE_NAME | VARCHAR(200) | Name of the data pipeline that was executed |
| EXECUTION_START_TIME | TIMESTAMP_NTZ | Timestamp when pipeline execution started |
| EXECUTION_END_TIME | TIMESTAMP_NTZ | Timestamp when pipeline execution completed |
| EXECUTION_DURATION_SECONDS | INTEGER | Total execution time in seconds |
| SOURCE_TABLE | VARCHAR(100) | Source table being processed |
| TARGET_TABLE | VARCHAR(100) | Target table where data was loaded |
| RECORDS_PROCESSED | INTEGER | Total number of records processed |
| RECORDS_INSERTED | INTEGER | Number of new records inserted |
| RECORDS_UPDATED | INTEGER | Number of existing records updated |
| RECORDS_REJECTED | INTEGER | Number of records rejected due to quality issues |
| EXECUTION_STATUS | VARCHAR(50) | Overall pipeline execution status (Success, Failed, Partial Success, Warning) |
| ERROR_MESSAGE | VARCHAR(2000) | Detailed error message if pipeline failed |
| PROCESSED_BY | VARCHAR(100) | System or user that executed the pipeline |
| PIPELINE_VERSION | VARCHAR(20) | Version of the pipeline that was executed |
| DATA_FRESHNESS_HOURS | DECIMAL(10,2) | Hours between source data creation and processing |
| MEMORY_USAGE_MB | INTEGER | Peak memory usage during pipeline execution |
| CPU_USAGE_PERCENT | DECIMAL(5,2) | Average CPU usage during pipeline execution |

## 2. Conceptual Data Model Diagram

### 2.1 Table Relationships in Block Diagram Format

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
│ - END_TIME      │       │ - ATTENDANCE_   │
│ - DURATION_MIN  │       │   DURATION_MIN  │
│ - MEETING_TYPE  │       └─────────────────┘
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
│ - IS_PREMIUM    │
└─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    Si_Users     │◄──────┤Si_Support_Tickets│
│                 │       │                 │
│ (User Reference)│       │ - TICKET_TYPE   │
└─────────────────┘       │ - RESOLUTION_ST │
                          │ - PRIORITY_LVL  │
                          │ - RESOLUTION_   │
                          │   TIME_HOURS    │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    Si_Users     │◄──────┤Si_Billing_Events│
│                 │       │                 │
│ (User Reference)│       │ - EVENT_TYPE    │
└─────────────────┘       │ - AMOUNT        │
                          │ - CURRENCY_CODE │
                          │ - PAYMENT_METHOD│
                          │ - IS_RECURRING  │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    Si_Users     │◄──────┤   Si_Licenses   │
│                 │       │                 │
│ (User Reference)│       │ - LICENSE_TYPE  │
└─────────────────┘       │ - START_DATE    │
                          │ - END_DATE      │
                          │ - LICENSE_STATUS│
                          │ - DAYS_TO_EXPIRY│
                          │ - IS_AUTO_RENEWAL│
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│  All Si_Tables  │◄──────┤Si_Data_Quality_ │
│                 │       │     Errors      │
│ (Table Reference│       │                 │
│  via SOURCE_    │       │ - ERROR_TYPE    │
│  TABLE field)   │       │ - ERROR_DESC    │
└─────────────────┘       │ - SEVERITY_LVL  │
                          │ - RESOLUTION_ST │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│  All Si_Tables  │◄──────┤ Si_Pipeline_    │
│                 │       │     Audit       │
│ (Table Reference│       │                 │
│  via SOURCE_    │       │ - PIPELINE_NAME │
│  TABLE and      │       │ - EXECUTION_ST  │
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
8. **All Si_Tables → Si_Data_Quality_Errors**: One-to-Many relationship via SOURCE_TABLE field
9. **All Si_Tables → Si_Pipeline_Audit**: One-to-Many relationship via SOURCE_TABLE and TARGET_TABLE fields

## 3. Design Decisions and Rationale

### 3.1 Key Design Decisions

1. **Naming Convention**: All Silver layer tables use the 'Si_' prefix to maintain consistency and clearly identify Silver layer entities, following the medallion architecture standards.

2. **Data Type Standardization**: 
   - VARCHAR fields have been sized appropriately based on expected data ranges
   - DECIMAL types used for monetary amounts with proper precision
   - BOOLEAN flags added for business logic indicators
   - TIMESTAMP_NTZ used consistently for all temporal data

3. **Data Quality Enhancement**:
   - Added calculated fields like ATTENDANCE_DURATION_MINUTES and RESOLUTION_TIME_HOURS
   - Included data quality score and validation flags
   - Standardized categorical values with controlled vocabularies

4. **Error and Audit Framework**:
   - Comprehensive error tracking table for data validation issues
   - Detailed pipeline audit table for operational monitoring
   - Severity levels and resolution tracking for data quality management

5. **Business Logic Integration**:
   - Added derived fields that support KPI calculations
   - Included flags for business rules (IS_ACTIVE, IS_PREMIUM_FEATURE, IS_RECURRING)
   - Enhanced categorization for better analytics capabilities

### 3.2 Assumptions Made

1. **Data Cleansing**: Assumed that Silver layer processing includes comprehensive data cleansing and validation routines.

2. **Business Rules**: Applied standard business rules for data validation while preserving the ability to track and resolve data quality issues.

3. **Performance Optimization**: Designed with appropriate data types and structures to support efficient querying and analytics.

4. **Compliance**: Structure supports data governance requirements with comprehensive audit trails and error tracking.

5. **Scalability**: Model designed to handle high-volume data processing with efficient storage and retrieval patterns.

## 4. Implementation Guidelines

### 4.1 Data Processing Strategy

1. **Data Validation**: Implement comprehensive validation rules based on the constraints defined in the requirements.

2. **Error Handling**: All validation failures should be logged in Si_Data_Quality_Errors table with appropriate severity levels.

3. **Audit Tracking**: Every pipeline execution should be logged in Si_Pipeline_Audit table with detailed performance metrics.

4. **Data Standardization**: Apply consistent formatting and standardization rules across all text fields.

### 4.2 Quality Control Measures

1. **Data Quality Scoring**: Implement scoring algorithms to assess data completeness and accuracy.

2. **Referential Integrity**: Validate all logical relationships between tables during processing.

3. **Business Rule Validation**: Ensure all business rules from the constraints document are properly implemented.

4. **Performance Monitoring**: Track processing times and resource usage for optimization opportunities.
