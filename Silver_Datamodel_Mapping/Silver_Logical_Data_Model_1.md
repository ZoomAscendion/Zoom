_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer logical data model for Zoom Platform Analytics System following Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Logical Data Model - Zoom Platform Analytics System

## 1. Silver Layer Logical Model

### 1.1 Si_USERS
**Description**: Cleaned and standardized user profile and subscription information from Bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user (PII) |
| EMAIL | VARCHAR(16777216) | Email address of the user (PII) |
| COMPANY | VARCHAR(16777216) | Company or organization name |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type (Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 1.2 Si_MEETINGS
**Description**: Cleaned and standardized meeting information and session details from Bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting (Potential PII) |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp |
| END_TIME | TIMESTAMP_NTZ(9) | Meeting end timestamp |
| DURATION_MINUTES | NUMBER(38,0) | Meeting duration in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 1.3 Si_PARTICIPANTS
**Description**: Cleaned and standardized meeting participants and their session details from Bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant joined meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 1.4 Si_FEATURE_USAGE
**Description**: Cleaned and standardized usage of platform features during meetings from Bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the feature being tracked |
| USAGE_COUNT | NUMBER(38,0) | Number of times feature was used |
| USAGE_DATE | DATE | Date when feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 1.5 Si_SUPPORT_TICKETS
**Description**: Cleaned and standardized customer support requests and resolution tracking from Bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(16777216) | Type of support ticket |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of ticket resolution |
| OPEN_DATE | DATE | Date when ticket was opened |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 1.6 Si_BILLING_EVENTS
**Description**: Cleaned and standardized financial transactions and billing activities from Bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event |
| AMOUNT | NUMBER(10,2) | Monetary amount for the billing event |
| EVENT_DATE | DATE | Date when the billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 1.7 Si_LICENSES
**Description**: Cleaned and standardized license assignments and entitlements from Bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of license |
| START_DATE | DATE | License validity start date |
| END_DATE | DATE | License validity end date |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 1.8 Si_DATA_QUALITY_ERRORS
**Description**: Stores error data from data validation process and quality checks

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ERROR_TYPE | VARCHAR(16777216) | Type of data quality error (Format, Completeness, Consistency, Validity) |
| ERROR_DESCRIPTION | VARCHAR(16777216) | Detailed description of the data quality issue |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source table where error was detected |
| SOURCE_COLUMN | VARCHAR(16777216) | Name of the source column where error was detected |
| ERROR_VALUE | VARCHAR(16777216) | The actual value that caused the error |
| EXPECTED_VALUE | VARCHAR(16777216) | The expected value or format |
| SEVERITY_LEVEL | VARCHAR(16777216) | Severity of the error (Critical, High, Medium, Low) |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when error was detected |
| VALIDATION_RULE | VARCHAR(16777216) | Name of the validation rule that failed |
| ERROR_COUNT | NUMBER(38,0) | Number of records affected by this error |
| RESOLUTION_STATUS | VARCHAR(16777216) | Status of error resolution (Open, In Progress, Resolved, Ignored) |
| RESOLVED_BY | VARCHAR(16777216) | User or process that resolved the error |
| RESOLUTION_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when error was resolved |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when error record was created |

### 1.9 Si_PIPELINE_AUDIT
**Description**: Stores audit details from pipeline execution and processing activities

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| PIPELINE_NAME | VARCHAR(16777216) | Name of the data pipeline or process |
| PIPELINE_RUN_ID | VARCHAR(16777216) | Unique identifier for the pipeline execution |
| EXECUTION_STATUS | VARCHAR(16777216) | Status of pipeline execution (Started, Running, Completed, Failed, Cancelled) |
| START_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when pipeline execution started |
| END_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when pipeline execution completed |
| EXECUTION_DURATION | NUMBER(38,3) | Duration of pipeline execution in seconds |
| RECORDS_PROCESSED | NUMBER(38,0) | Total number of records processed |
| RECORDS_SUCCESS | NUMBER(38,0) | Number of records successfully processed |
| RECORDS_FAILED | NUMBER(38,0) | Number of records that failed processing |
| RECORDS_SKIPPED | NUMBER(38,0) | Number of records skipped during processing |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system being processed |
| TARGET_TABLE | VARCHAR(16777216) | Target table where data was loaded |
| PIPELINE_VERSION | VARCHAR(16777216) | Version of the pipeline code |
| EXECUTED_BY | VARCHAR(16777216) | User or service account that executed the pipeline |
| ERROR_MESSAGE | VARCHAR(16777216) | Error message if pipeline failed |
| CONFIGURATION_PARAMS | VARIANT | JSON object containing pipeline configuration parameters |
| PERFORMANCE_METRICS | VARIANT | JSON object containing performance metrics and statistics |
| DATA_LINEAGE_INFO | VARIANT | JSON object containing data lineage information |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when audit record was created |

## 2. Conceptual Data Model Diagram

### Block Diagram Format - Table Relationships

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Si_USERS      │────▶│  Si_MEETINGS    │────▶│ Si_PARTICIPANTS │
│                 │     │                 │     │                 │
│ Connected by:   │     │ Connected by:   │     │ Connected by:   │
│ USER_NAME       │     │ MEETING_TOPIC   │     │ JOIN_TIME       │
│ EMAIL           │     │ START_TIME      │     │ LEAVE_TIME      │
│ COMPANY         │     │ END_TIME        │     │                 │
│ PLAN_TYPE       │     │ DURATION_MIN    │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                        │                       
         │                        ▼                       
         │               ┌─────────────────┐              
         │               │ Si_FEATURE_USAGE│              
         │               │                 │              
         │               │ Connected by:   │              
         │               │ FEATURE_NAME    │              
         │               │ USAGE_COUNT     │              
         │               │ USAGE_DATE      │              
         │               └─────────────────┘              
         │                                                 
         ├─────────────────┐                              
         │                 │                              
         ▼                 ▼                              
┌─────────────────┐ ┌─────────────────┐                 
│Si_SUPPORT_TICKETS│ │ Si_BILLING_EVENTS│                
│                 │ │                 │                 
│ Connected by:   │ │ Connected by:   │                 
│ TICKET_TYPE     │ │ EVENT_TYPE      │                 
│ RESOLUTION_ST   │ │ AMOUNT          │                 
│ OPEN_DATE       │ │ EVENT_DATE      │                 
└─────────────────┘ └─────────────────┘                 
         │                                                 
         ▼                                                 
┌─────────────────┐                                      
│   Si_LICENSES   │                                      
│                 │                                      
│ Connected by:   │                                      
│ LICENSE_TYPE    │                                      
│ START_DATE      │                                      
│ END_DATE        │                                      
└─────────────────┘                                      

┌─────────────────┐     ┌─────────────────┐
│Si_DATA_QUALITY_ │     │ Si_PIPELINE_    │
│ERRORS           │     │ AUDIT           │
│                 │     │                 │
│ Connected by:   │     │ Connected by:   │
│ ERROR_TYPE      │     │ PIPELINE_NAME   │
│ SOURCE_TABLE    │     │ EXECUTION_STATUS│
│ ERROR_TIMESTAMP │     │ START_TIMESTAMP │
│ SEVERITY_LEVEL  │     │ RECORDS_PROCESSED│
└─────────────────┘     └─────────────────┘
```

### Key Field Connections:

1. **Si_USERS → Si_MEETINGS**: Connected through user context via USER_NAME and EMAIL fields
2. **Si_MEETINGS → Si_PARTICIPANTS**: Connected through meeting context via START_TIME and END_TIME alignment with JOIN_TIME and LEAVE_TIME
3. **Si_MEETINGS → Si_FEATURE_USAGE**: Connected through meeting context via START_TIME alignment with USAGE_DATE
4. **Si_USERS → Si_SUPPORT_TICKETS**: Connected through user context via USER_NAME and EMAIL fields
5. **Si_USERS → Si_BILLING_EVENTS**: Connected through user context via USER_NAME and EMAIL fields
6. **Si_USERS → Si_LICENSES**: Connected through user context via USER_NAME and EMAIL fields
7. **Si_DATA_QUALITY_ERRORS**: Standalone table tracking data quality issues across all Silver tables via SOURCE_TABLE field
8. **Si_PIPELINE_AUDIT**: Standalone table tracking pipeline execution details across all Silver tables via TARGET_TABLE field

### Relationship Types:
- **One-to-Many**: Si_USERS to Si_MEETINGS, Si_SUPPORT_TICKETS, Si_BILLING_EVENTS, Si_LICENSES
- **One-to-Many**: Si_MEETINGS to Si_PARTICIPANTS, Si_FEATURE_USAGE
- **Many-to-One**: All tables to Si_DATA_QUALITY_ERRORS (via SOURCE_TABLE)
- **Many-to-One**: All tables to Si_PIPELINE_AUDIT (via TARGET_TABLE)

## 3. Design Rationale and Key Decisions

### 3.1 Naming Convention
- **Table Prefix**: All Silver layer tables use 'Si_' prefix for clear layer identification
- **Consistency**: Maintains consistent naming pattern across the medallion architecture

### 3.2 Data Type Standardization
- **VARCHAR Fields**: Standardized to VARCHAR(16777216) for flexibility in Snowflake
- **Numeric Fields**: Maintained precision from Bronze layer (NUMBER(38,0) for counts, NUMBER(10,2) for amounts)
- **Temporal Fields**: Standardized to TIMESTAMP_NTZ(9) for timestamps and DATE for date-only fields

### 3.3 Key Field Removal
- **Primary Keys**: Removed all primary key fields (USER_ID, MEETING_ID, PARTICIPANT_ID, etc.) as per Silver layer requirements
- **Foreign Keys**: Removed all foreign key fields (HOST_ID, ASSIGNED_TO_USER_ID, etc.) as per Silver layer requirements
- **Unique Identifiers**: Removed all ID fields to focus on business data attributes

### 3.4 Data Quality and Audit Framework
- **Error Tracking**: Si_DATA_QUALITY_ERRORS table captures comprehensive data validation errors
- **Pipeline Audit**: Si_PIPELINE_AUDIT table provides complete audit trail of data processing activities
- **Metadata Preservation**: Maintained load and update timestamps for data lineage

### 3.5 Business Value Focus
- **Content Over Structure**: Emphasis on business-relevant data attributes rather than technical identifiers
- **Analytics Ready**: Structure optimized for analytical queries and reporting
- **Data Quality**: Built-in error tracking and audit capabilities for data governance

## 4. Assumptions Made

1. **Data Relationships**: Logical relationships between tables are maintained through business context rather than foreign key constraints
2. **Data Quality**: All Silver layer data has passed basic validation and cleansing processes
3. **Temporal Alignment**: Time-based relationships (meetings to participants, features) are maintained through timestamp correlation
4. **User Context**: User-related data across tables can be correlated through USER_NAME and EMAIL fields
5. **Error Handling**: Data quality errors are captured and stored for analysis and resolution
6. **Pipeline Monitoring**: All data processing activities are audited and tracked for operational visibility
7. **Snowflake Platform**: All data types and structures are optimized for Snowflake cloud data platform
8. **PII Handling**: Personally identifiable information is clearly marked and will be subject to appropriate data governance policies

---

**Document Status**: Complete
**Implementation Ready**: Yes
**Next Phase**: Gold layer logical data model development