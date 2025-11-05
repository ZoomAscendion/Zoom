_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver Logical Data Model for Zoom Platform Analytics System following medallion architecture principles
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Logical Data Model - Zoom Platform Analytics System

## 1. Silver Layer Logical Model

### 1.1 Si_Users
**Description**: Silver layer table containing cleaned and standardized user data with data type standardization and quality checks applied

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(255) | Standardized full name of the registered user, cleaned and validated |
| EMAIL | VARCHAR(320) | Standardized email address following RFC 5322 format, validated for proper email structure |
| COMPANY | VARCHAR(500) | Standardized organization or company affiliation, cleaned and normalized |
| PLAN_TYPE | VARCHAR(50) | Standardized subscription tier (Free, Basic, Pro, Enterprise) with consistent casing |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was loaded into the silver layer with timezone normalization |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was last updated in the silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score between 0.00 and 1.00 indicating data completeness and accuracy |
| IS_ACTIVE | BOOLEAN | Flag indicating if the user account is currently active |

### 1.2 Si_Meetings
**Description**: Silver layer table containing cleaned meeting data with standardized duration calculations and time zone normalization

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(1000) | Standardized meeting topic with special characters cleaned and length validated |
| START_TIME | TIMESTAMP_NTZ | Standardized meeting start time converted to UTC timezone |
| END_TIME | TIMESTAMP_NTZ | Standardized meeting end time converted to UTC timezone |
| DURATION_MINUTES | INTEGER | Calculated meeting duration in minutes, validated for logical consistency |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was loaded into the silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was last updated in the silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| MEETING_STATUS | VARCHAR(50) | Standardized meeting status (Completed, Cancelled, In Progress) |
| IS_VALID_DURATION | BOOLEAN | Flag indicating if meeting duration passes business rule validation |

### 1.3 Si_Participants
**Description**: Silver layer table containing cleaned participant data with calculated attendance metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ | Standardized participant join time converted to UTC timezone |
| LEAVE_TIME | TIMESTAMP_NTZ | Standardized participant leave time converted to UTC timezone |
| ATTENDANCE_DURATION_MINUTES | INTEGER | Calculated attendance duration in minutes derived from join and leave times |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was loaded into the silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was last updated in the silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| PARTICIPATION_STATUS | VARCHAR(50) | Standardized participation status (Full, Partial, Brief) |
| IS_VALID_ATTENDANCE | BOOLEAN | Flag indicating if attendance times pass validation rules |

### 1.4 Si_Feature_Usage
**Description**: Silver layer table containing standardized feature usage data with usage pattern analysis

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(200) | Standardized feature name with consistent naming convention |
| USAGE_COUNT | INTEGER | Validated usage count ensuring non-negative values |
| USAGE_DATE | DATE | Standardized usage date with proper date validation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was loaded into the silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was last updated in the silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| FEATURE_CATEGORY | VARCHAR(100) | Categorized feature type (Audio, Video, Collaboration, Security) |
| USAGE_INTENSITY | VARCHAR(20) | Calculated usage intensity (Low, Medium, High) based on usage count |

### 1.5 Si_Support_Tickets
**Description**: Silver layer table containing standardized support ticket data with resolution time calculations

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(100) | Standardized ticket category (Technical, Billing, Feature Request, Bug Report) |
| RESOLUTION_STATUS | VARCHAR(50) | Standardized resolution status (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Validated ticket creation date |
| CLOSE_DATE | DATE | Validated ticket closure date (null if still open) |
| RESOLUTION_TIME_HOURS | DECIMAL(10,2) | Calculated resolution time in hours for closed tickets |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was loaded into the silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was last updated in the silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| PRIORITY_LEVEL | VARCHAR(20) | Standardized priority (Low, Medium, High, Critical) |
| SLA_COMPLIANCE | BOOLEAN | Flag indicating if ticket resolution met SLA requirements |

### 1.6 Si_Billing_Events
**Description**: Silver layer table containing standardized billing data with currency normalization and amount validation

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(50) | Standardized billing event type (Subscription, Upgrade, Downgrade, Refund) |
| AMOUNT | DECIMAL(15,2) | Validated monetary amount with proper decimal precision |
| AMOUNT_USD | DECIMAL(15,2) | Amount converted to USD for standardized reporting |
| EVENT_DATE | DATE | Validated billing event date |
| CURRENCY_CODE | VARCHAR(3) | Standardized ISO currency code |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was loaded into the silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was last updated in the silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| REVENUE_CATEGORY | VARCHAR(50) | Categorized revenue type (Recurring, One-time, Refund) |
| IS_VALID_AMOUNT | BOOLEAN | Flag indicating if amount passes validation rules |

### 1.7 Si_Licenses
**Description**: Silver layer table containing standardized license data with lifecycle status calculations

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(100) | Standardized license category (Basic, Pro, Enterprise, Add-on) |
| START_DATE | DATE | Validated license activation date |
| END_DATE | DATE | Validated license expiration date |
| LICENSE_DURATION_DAYS | INTEGER | Calculated license duration in days |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was loaded into the silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was last updated in the silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| LICENSE_STATUS | VARCHAR(50) | Calculated license status (Active, Expired, Expiring Soon) |
| DAYS_TO_EXPIRY | INTEGER | Calculated days remaining until license expiration |
| IS_RENEWABLE | BOOLEAN | Flag indicating if license is eligible for renewal |

### 1.8 Si_Webinars
**Description**: Silver layer table containing standardized webinar data with attendance metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| WEBINAR_TOPIC | VARCHAR(1000) | Standardized webinar topic with cleaned formatting |
| START_TIME | TIMESTAMP_NTZ | Standardized webinar start time converted to UTC |
| END_TIME | TIMESTAMP_NTZ | Standardized webinar end time converted to UTC |
| DURATION_MINUTES | INTEGER | Calculated webinar duration in minutes |
| REGISTRANTS | INTEGER | Validated number of registered participants |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was loaded into the silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when record was last updated in the silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Standardized source system identifier |
| WEBINAR_STATUS | VARCHAR(50) | Standardized webinar status (Completed, Cancelled, Scheduled) |
| ATTENDANCE_RATE | DECIMAL(5,2) | Calculated attendance rate as percentage of registrants |

### 1.9 Si_Data_Quality_Errors
**Description**: Silver layer table for storing data validation errors and quality issues identified during processing

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ERROR_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the data quality error was detected |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table where error was found |
| ERROR_TYPE | VARCHAR(100) | Type of data quality error (Missing Value, Invalid Format, Business Rule Violation) |
| ERROR_DESCRIPTION | VARCHAR(2000) | Detailed description of the data quality issue |
| AFFECTED_COLUMNS | VARCHAR(500) | List of columns affected by the data quality issue |
| ERROR_SEVERITY | VARCHAR(20) | Severity level of the error (Low, Medium, High, Critical) |
| RESOLUTION_STATUS | VARCHAR(50) | Status of error resolution (Open, In Progress, Resolved, Ignored) |
| RESOLUTION_ACTION | VARCHAR(1000) | Action taken to resolve the data quality issue |
| CREATED_BY | VARCHAR(100) | System or process that detected the error |
| RESOLVED_BY | VARCHAR(100) | System or user that resolved the error |
| RESOLVED_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when the error was resolved |

### 1.10 Si_Pipeline_Audit
**Description**: Silver layer table for tracking pipeline execution details and processing statistics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| PIPELINE_RUN_ID | VARCHAR(100) | Unique identifier for each pipeline execution |
| PIPELINE_NAME | VARCHAR(200) | Name of the data pipeline or transformation process |
| START_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when pipeline execution started |
| END_TIMESTAMP | TIMESTAMP_NTZ | Timestamp when pipeline execution completed |
| EXECUTION_DURATION_SECONDS | INTEGER | Total execution time in seconds |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table being processed |
| TARGET_TABLE | VARCHAR(100) | Name of the target table being populated |
| RECORDS_PROCESSED | INTEGER | Total number of records processed in the pipeline run |
| RECORDS_SUCCESS | INTEGER | Number of records successfully processed |
| RECORDS_FAILED | INTEGER | Number of records that failed processing |
| RECORDS_SKIPPED | INTEGER | Number of records skipped due to business rules |
| PIPELINE_STATUS | VARCHAR(50) | Overall status of pipeline execution (Success, Failed, Partial Success) |
| ERROR_MESSAGE | VARCHAR(2000) | Error message if pipeline execution failed |
| EXECUTED_BY | VARCHAR(100) | User or system that executed the pipeline |
| CONFIGURATION_HASH | VARCHAR(64) | Hash of pipeline configuration for change tracking |
| DATA_FRESHNESS_HOURS | DECIMAL(10,2) | Hours between source data creation and processing |

## 2. Conceptual Data Model Diagram

### 2.1 Block Diagram Representation

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Si_Users     │    │   Si_Meetings   │    │   Si_Licenses   │
│                 │    │                 │    │                 │
│ • USER_NAME     │    │ • MEETING_TOPIC │    │ • LICENSE_TYPE  │
│ • EMAIL         │    │ • START_TIME    │    │ • START_DATE    │
│ • COMPANY       │    │ • END_TIME      │    │ • END_DATE      │
│ • PLAN_TYPE     │    │ • DURATION_MIN  │    │ • LICENSE_STATUS│
│ • IS_ACTIVE     │    │ • IS_VALID_DUR  │    │ • DAYS_TO_EXPIRY│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Si_Participants │    │Si_Feature_Usage │    │Si_Support_Tickets│
│                 │    │                 │    │                 │
│ • JOIN_TIME     │    │ • FEATURE_NAME  │    │ • TICKET_TYPE   │
│ • LEAVE_TIME    │    │ • USAGE_COUNT   │    │ • RESOLUTION_ST │
│ • ATTENDANCE_DUR│    │ • USAGE_DATE    │    │ • OPEN_DATE     │
│ • IS_VALID_ATT  │    │ • FEATURE_CAT   │    │ • CLOSE_DATE    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Si_Billing_Events│   │   Si_Webinars   │    │Si_Data_Quality_ │
│                 │    │                 │    │     Errors      │
│ • EVENT_TYPE    │    │ • WEBINAR_TOPIC │    │ • ERROR_TYPE    │
│ • AMOUNT        │    │ • START_TIME    │    │ • SOURCE_TABLE  │
│ • AMOUNT_USD    │    │ • END_TIME      │    │ • ERROR_DESC    │
│ • CURRENCY_CODE │    │ • REGISTRANTS   │    │ • ERROR_SEVERITY│
│ • IS_VALID_AMT  │    │ • ATTENDANCE_RT │    │ • RESOLUTION_ST │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       │
                                                       ▼
                                              ┌─────────────────┐
                                              │ Si_Pipeline_    │
                                              │     Audit       │
                                              │ • PIPELINE_NAME │
                                              │ • START_TIME    │
                                              │ • END_TIME      │
                                              │ • RECORDS_PROC  │
                                              │ • PIPELINE_STAT │
                                              └─────────────────┘
```

### 2.2 Table Relationships

| Source Table | Target Table | Connection Field | Relationship Type | Description |
|--------------|--------------|------------------|-------------------|-------------|
| Si_Users | Si_Participants | Business Logic Connection | One-to-Many | Users participate in multiple meetings through participant records |
| Si_Meetings | Si_Participants | Business Logic Connection | One-to-Many | Each meeting can have multiple participants |
| Si_Meetings | Si_Feature_Usage | Business Logic Connection | One-to-Many | Features are used during specific meetings |
| Si_Users | Si_Support_Tickets | Business Logic Connection | One-to-Many | Users can create multiple support tickets |
| Si_Users | Si_Billing_Events | Business Logic Connection | One-to-Many | Users have multiple billing events over time |
| Si_Users | Si_Licenses | Business Logic Connection | One-to-Many | Users can have multiple licenses assigned |
| Si_Users | Si_Webinars | Business Logic Connection | One-to-Many | Users can host multiple webinars |
| Si_Data_Quality_Errors | All Tables | SOURCE_TABLE Field | Monitoring | Data quality errors reference any source table |
| Si_Pipeline_Audit | All Tables | SOURCE_TABLE/TARGET_TABLE | Monitoring | Pipeline audit tracks processing of all tables |

### 2.3 Design Rationale and Key Decisions

1. **Data Type Standardization**: 
   - Implemented consistent data types across all tables
   - VARCHAR fields sized appropriately based on expected content
   - DECIMAL types used for monetary amounts with proper precision
   - TIMESTAMP_NTZ used for consistent timezone handling

2. **Data Quality Framework**:
   - Added validation flags (IS_VALID_*) to track data quality
   - Implemented Si_Data_Quality_Errors table for comprehensive error tracking
   - Added data quality scores and validation indicators

3. **Audit and Lineage**:
   - Si_Pipeline_Audit table provides comprehensive processing tracking
   - Detailed execution metrics for performance monitoring
   - Configuration change tracking through hash values

4. **Business Logic Enhancement**:
   - Calculated fields added (duration, status, rates)
   - Standardized categorical values with consistent naming
   - Currency normalization to USD for consistent reporting

5. **Removed Fields from Bronze Layer**:
   - All primary key fields (USER_ID, MEETING_ID, etc.) removed as per Silver layer requirements
   - All foreign key fields (HOST_ID, ASSIGNED_TO_USER_ID, etc.) removed
   - Unique identifier fields removed to focus on business data

6. **Silver Layer Enhancements**:
   - Added calculated metrics and derived fields
   - Implemented data validation and quality scoring
   - Standardized naming conventions with 'Si_' prefix
   - Enhanced with business rule validation flags

This Silver layer logical data model provides a robust foundation for analytics while maintaining data quality, implementing comprehensive auditing, and supporting the business requirements outlined in the conceptual model and constraints documentation.