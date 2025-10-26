_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver Layer Logical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Logical Data Model - Zoom Platform Analytics System

## 1. Silver Layer Logical Model

### 1.1 Table: Si_BILLING_EVENTS
**Description**: Cleaned and standardized billing and payment event data with enhanced data quality and validation

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(50) | Standardized billing event type (SUBSCRIPTION, PAYMENT, REFUND, UPGRADE, DOWNGRADE) |
| AMOUNT | DECIMAL(12,2) | Validated monetary amount with currency conversion applied where necessary |
| EVENT_DATE | DATE | Standardized date format for billing event occurrence |
| CURRENCY_CODE | VARCHAR(3) | ISO 4217 currency code for the transaction amount |
| PAYMENT_METHOD | VARCHAR(50) | Standardized payment method classification |
| TRANSACTION_STATUS | VARCHAR(20) | Status of the transaction (COMPLETED, PENDING, FAILED, CANCELLED) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last update in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on completeness and validation rules |

### 1.2 Table: Si_FEATURE_USAGE
**Description**: Standardized platform feature utilization data with enhanced analytics capabilities

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(100) | Standardized feature name using consistent naming convention |
| USAGE_COUNT | INTEGER | Validated count of feature utilization instances |
| USAGE_DATE | DATE | Standardized date format for feature usage occurrence |
| USAGE_DURATION_SECONDS | INTEGER | Duration of feature usage in standardized seconds format |
| FEATURE_CATEGORY | VARCHAR(50) | Categorized grouping of features (COMMUNICATION, COLLABORATION, SECURITY, RECORDING) |
| USAGE_CONTEXT | VARCHAR(50) | Context of usage (MEETING, WEBINAR, PERSONAL_ROOM) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last update in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on completeness and validation rules |

### 1.3 Table: Si_LICENSES
**Description**: Standardized license management data with enhanced tracking and validation

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(50) | Standardized license category (BASIC, PRO, BUSINESS, ENTERPRISE, ADDON) |
| START_DATE | DATE | Validated license activation date |
| END_DATE | DATE | Validated license expiration date |
| LICENSE_STATUS | VARCHAR(20) | Current license status (ACTIVE, EXPIRED, SUSPENDED, CANCELLED) |
| LICENSE_CAPACITY | INTEGER | Maximum capacity or user count for the license |
| UTILIZATION_PERCENTAGE | DECIMAL(5,2) | Current utilization percentage of license capacity |
| RENEWAL_FLAG | BOOLEAN | Indicator if license is set for automatic renewal |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last update in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on completeness and validation rules |

### 1.4 Table: Si_MEETINGS
**Description**: Enhanced meeting data with standardized formats and calculated metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(500) | Cleaned and standardized meeting subject or title |
| START_TIME | TIMESTAMP_NTZ(9) | Validated meeting start timestamp in UTC |
| END_TIME | TIMESTAMP_NTZ(9) | Validated meeting end timestamp in UTC |
| DURATION_MINUTES | INTEGER | Calculated meeting duration in minutes with validation |
| MEETING_TYPE | VARCHAR(30) | Standardized meeting type (SCHEDULED, INSTANT, RECURRING, WEBINAR) |
| PARTICIPANT_COUNT | INTEGER | Total number of participants including host |
| TIMEZONE | VARCHAR(50) | Meeting timezone information |
| RECORDING_FLAG | BOOLEAN | Indicator if meeting was recorded |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last update in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on completeness and validation rules |

### 1.5 Table: Si_PARTICIPANTS
**Description**: Standardized participant attendance data with enhanced analytics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Validated participant join timestamp in UTC |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Validated participant leave timestamp in UTC |
| ATTENDANCE_DURATION_MINUTES | INTEGER | Calculated attendance duration in minutes |
| PARTICIPANT_TYPE | VARCHAR(30) | Type of participant (HOST, ATTENDEE, PANELIST, GUEST) |
| CONNECTION_TYPE | VARCHAR(30) | Connection method (COMPUTER_AUDIO, PHONE, SIP, H323) |
| DEVICE_TYPE | VARCHAR(50) | Device used for participation (DESKTOP, MOBILE, TABLET, ROOM_SYSTEM) |
| GEOGRAPHIC_REGION | VARCHAR(100) | Geographic region of participant connection |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last update in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on completeness and validation rules |

### 1.6 Table: Si_SUPPORT_TICKETS
**Description**: Enhanced support ticket data with standardized categorization and metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(50) | Standardized support category (TECHNICAL, BILLING, FEATURE_REQUEST, ACCOUNT_ISSUE) |
| RESOLUTION_STATUS | VARCHAR(30) | Current ticket status (OPEN, IN_PROGRESS, RESOLVED, CLOSED, ESCALATED) |
| PRIORITY_LEVEL | VARCHAR(20) | Ticket priority (LOW, MEDIUM, HIGH, CRITICAL) |
| OPEN_DATE | DATE | Date when support ticket was created |
| CLOSE_DATE | DATE | Date when support ticket was resolved or closed |
| RESOLUTION_TIME_HOURS | DECIMAL(8,2) | Calculated resolution time in business hours |
| FIRST_RESPONSE_TIME_HOURS | DECIMAL(8,2) | Time to first response in business hours |
| ESCALATION_FLAG | BOOLEAN | Indicator if ticket was escalated |
| CUSTOMER_SATISFACTION_SCORE | INTEGER | Customer satisfaction rating (1-5 scale) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last update in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on completeness and validation rules |

### 1.7 Table: Si_USERS
**Description**: Standardized user profile data with enhanced attributes and validation

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(200) | Standardized display name with data masking applied |
| EMAIL_DOMAIN | VARCHAR(100) | Email domain for organizational analysis (PII removed) |
| COMPANY | VARCHAR(200) | Standardized company name with data cleansing applied |
| PLAN_TYPE | VARCHAR(30) | Standardized subscription plan (FREE, BASIC, PRO, BUSINESS, ENTERPRISE) |
| ACCOUNT_STATUS | VARCHAR(20) | Current account status (ACTIVE, INACTIVE, SUSPENDED, CANCELLED) |
| REGISTRATION_DATE | DATE | Date when user first registered |
| LAST_LOGIN_DATE | DATE | Date of most recent platform access |
| GEOGRAPHIC_REGION | VARCHAR(100) | User's geographic region for analytics |
| INDUSTRY_SECTOR | VARCHAR(100) | Industry classification of user's organization |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last update in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on completeness and validation rules |

### 1.8 Table: Si_WEBINARS
**Description**: Enhanced webinar data with standardized metrics and analytics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| WEBINAR_TOPIC | VARCHAR(500) | Cleaned and standardized webinar subject or title |
| START_TIME | TIMESTAMP_NTZ(9) | Validated webinar start timestamp in UTC |
| END_TIME | TIMESTAMP_NTZ(9) | Validated webinar end timestamp in UTC |
| DURATION_MINUTES | INTEGER | Calculated webinar duration in minutes |
| REGISTRANTS | INTEGER | Total number of users who registered |
| ATTENDEES | INTEGER | Actual number of participants who joined |
| ATTENDANCE_RATE | DECIMAL(5,2) | Calculated attendance rate percentage |
| WEBINAR_TYPE | VARCHAR(30) | Type of webinar (LIVE, SIMULIVE, ON_DEMAND) |
| RECORDING_VIEWS | INTEGER | Number of recording views post-webinar |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last update in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on completeness and validation rules |

## 2. Data Quality and Error Management Tables

### 2.1 Table: Si_DATA_QUALITY_ERRORS
**Description**: Comprehensive error tracking for data validation and quality issues

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ERROR_ID | VARCHAR(50) | Unique identifier for each data quality error |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table where error occurred |
| ERROR_TYPE | VARCHAR(50) | Type of data quality error (MISSING_VALUE, INVALID_FORMAT, CONSTRAINT_VIOLATION, DUPLICATE) |
| ERROR_DESCRIPTION | VARCHAR(1000) | Detailed description of the data quality issue |
| AFFECTED_COLUMN | VARCHAR(100) | Column name where the error was detected |
| ERROR_VALUE | VARCHAR(500) | The actual value that caused the error |
| ERROR_SEVERITY | VARCHAR(20) | Severity level (LOW, MEDIUM, HIGH, CRITICAL) |
| ERROR_DATE | DATE | Date when the error was detected |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ(9) | Precise timestamp of error detection |
| RESOLUTION_STATUS | VARCHAR(30) | Status of error resolution (OPEN, IN_PROGRESS, RESOLVED, IGNORED) |
| RESOLUTION_ACTION | VARCHAR(500) | Action taken to resolve the error |
| RESOLVED_BY | VARCHAR(100) | Process or user who resolved the error |
| RESOLVED_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when error was resolved |
| BUSINESS_IMPACT | VARCHAR(20) | Impact level on business processes (LOW, MEDIUM, HIGH) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when error record was created |

### 2.2 Table: Si_VALIDATION_RULES
**Description**: Repository of data validation rules and their execution results

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| RULE_ID | VARCHAR(50) | Unique identifier for each validation rule |
| RULE_NAME | VARCHAR(200) | Descriptive name of the validation rule |
| RULE_DESCRIPTION | VARCHAR(1000) | Detailed description of what the rule validates |
| TARGET_TABLE | VARCHAR(100) | Table to which the validation rule applies |
| TARGET_COLUMN | VARCHAR(100) | Specific column being validated |
| RULE_TYPE | VARCHAR(50) | Type of validation (COMPLETENESS, ACCURACY, CONSISTENCY, VALIDITY) |
| RULE_EXPRESSION | VARCHAR(2000) | SQL expression or logic for the validation rule |
| RULE_STATUS | VARCHAR(20) | Status of the rule (ACTIVE, INACTIVE, DEPRECATED) |
| EXECUTION_FREQUENCY | VARCHAR(30) | How often the rule is executed (REAL_TIME, HOURLY, DAILY, WEEKLY) |
| LAST_EXECUTION_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last rule execution |
| PASS_COUNT | INTEGER | Number of records that passed the validation |
| FAIL_COUNT | INTEGER | Number of records that failed the validation |
| PASS_RATE | DECIMAL(5,2) | Percentage of records passing validation |
| CREATED_BY | VARCHAR(100) | User or process who created the rule |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when rule was created |
| MODIFIED_BY | VARCHAR(100) | User or process who last modified the rule |
| MODIFIED_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of last rule modification |

## 3. Pipeline Audit and Process Management Tables

### 3.1 Table: Si_PIPELINE_AUDIT
**Description**: Comprehensive audit trail for all data pipeline execution activities

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| AUDIT_ID | VARCHAR(50) | Unique identifier for each pipeline execution audit record |
| PIPELINE_NAME | VARCHAR(200) | Name of the data pipeline or ETL process |
| PIPELINE_TYPE | VARCHAR(50) | Type of pipeline (BATCH, STREAMING, REAL_TIME, SCHEDULED) |
| EXECUTION_ID | VARCHAR(100) | Unique identifier for the specific pipeline execution |
| START_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when pipeline execution began |
| END_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when pipeline execution completed |
| EXECUTION_DURATION_SECONDS | INTEGER | Total execution time in seconds |
| EXECUTION_STATUS | VARCHAR(30) | Final status of pipeline execution (SUCCESS, FAILED, PARTIAL_SUCCESS, CANCELLED) |
| SOURCE_SYSTEM | VARCHAR(100) | Source system from which data was extracted |
| TARGET_SYSTEM | VARCHAR(100) | Target system where data was loaded |
| RECORDS_PROCESSED | INTEGER | Total number of records processed |
| RECORDS_INSERTED | INTEGER | Number of new records inserted |
| RECORDS_UPDATED | INTEGER | Number of existing records updated |
| RECORDS_DELETED | INTEGER | Number of records deleted |
| RECORDS_REJECTED | INTEGER | Number of records rejected due to quality issues |
| ERROR_COUNT | INTEGER | Total number of errors encountered |
| WARNING_COUNT | INTEGER | Total number of warnings generated |
| DATA_VOLUME_MB | DECIMAL(12,2) | Volume of data processed in megabytes |
| EXECUTED_BY | VARCHAR(100) | User, service, or scheduler that initiated the pipeline |
| SERVER_NAME | VARCHAR(100) | Server or compute resource where pipeline executed |
| CONFIGURATION_VERSION | VARCHAR(50) | Version of pipeline configuration used |
| DEPENDENCIES_MET | BOOLEAN | Indicator if all pipeline dependencies were satisfied |
| QUALITY_SCORE | DECIMAL(5,2) | Overall data quality score for the execution |
| BUSINESS_DATE | DATE | Business date for which the pipeline processed data |
| RETRY_COUNT | INTEGER | Number of retry attempts for failed executions |
| PARENT_EXECUTION_ID | VARCHAR(100) | Reference to parent pipeline if this is a sub-process |
| NOTIFICATION_SENT | BOOLEAN | Indicator if execution notifications were sent |
| LOG_FILE_PATH | VARCHAR(500) | Path to detailed execution log file |
| CREATED_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when audit record was created |

### 3.2 Table: Si_PROCESS_MONITORING
**Description**: Real-time monitoring and alerting for data pipeline processes

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MONITOR_ID | VARCHAR(50) | Unique identifier for each monitoring record |
| PROCESS_NAME | VARCHAR(200) | Name of the monitored process or pipeline |
| MONITOR_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp of the monitoring check |
| PROCESS_STATUS | VARCHAR(30) | Current status of the process (RUNNING, IDLE, FAILED, STOPPED) |
| CPU_UTILIZATION | DECIMAL(5,2) | CPU utilization percentage |
| MEMORY_UTILIZATION | DECIMAL(5,2) | Memory utilization percentage |
| DISK_UTILIZATION | DECIMAL(5,2) | Disk space utilization percentage |
| NETWORK_IO_MBPS | DECIMAL(10,2) | Network I/O in megabits per second |
| QUEUE_LENGTH | INTEGER | Number of items in processing queue |
| ACTIVE_CONNECTIONS | INTEGER | Number of active database connections |
| THROUGHPUT_RECORDS_PER_MINUTE | INTEGER | Processing throughput in records per minute |
| LATENCY_MILLISECONDS | INTEGER | Processing latency in milliseconds |
| ERROR_RATE | DECIMAL(5,2) | Error rate percentage |
| ALERT_THRESHOLD_BREACHED | BOOLEAN | Indicator if any monitoring threshold was exceeded |
| ALERT_TYPE | VARCHAR(50) | Type of alert if threshold was breached |
| ALERT_MESSAGE | VARCHAR(1000) | Detailed alert message |
| HEALTH_SCORE | DECIMAL(3,2) | Overall health score of the process (0-1 scale) |
| LAST_SUCCESSFUL_RUN | TIMESTAMP_NTZ(9) | Timestamp of last successful execution |
| NEXT_SCHEDULED_RUN | TIMESTAMP_NTZ(9) | Timestamp of next scheduled execution |
| MONITORING_AGENT | VARCHAR(100) | Name of the monitoring agent or tool |

## 4. Conceptual Data Model Diagram

### 4.1 Block Diagram Format - Silver Layer Table Relationships

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│     Si_USERS        │────│    Si_MEETINGS      │────│   Si_PARTICIPANTS   │
│                     │    │                     │    │                     │
│ - USER_NAME         │    │ - MEETING_TOPIC     │    │ - JOIN_TIME         │
│ - EMAIL_DOMAIN      │    │ - START_TIME        │    │ - LEAVE_TIME        │
│ - COMPANY           │    │ - END_TIME          │    │ - ATTENDANCE_DURATION│
│ - PLAN_TYPE         │    │ - DURATION_MINUTES  │    │ - PARTICIPANT_TYPE  │
│ - ACCOUNT_STATUS    │    │ - MEETING_TYPE      │    │ - CONNECTION_TYPE   │
│ - REGISTRATION_DATE │    │ - PARTICIPANT_COUNT │    │ - DEVICE_TYPE       │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
         │                           │
         │                           │
         ▼                           ▼
┌─────────────────────┐    ┌─────────────────────┐
│    Si_LICENSES      │    │  Si_FEATURE_USAGE   │
│                     │    │                     │
│ - LICENSE_TYPE      │    │ - FEATURE_NAME      │
│ - START_DATE        │    │ - USAGE_COUNT       │
│ - END_DATE          │    │ - USAGE_DATE        │
│ - LICENSE_STATUS    │    │ - USAGE_DURATION    │
│ - LICENSE_CAPACITY  │    │ - FEATURE_CATEGORY  │
│ - UTILIZATION_%     │    │ - USAGE_CONTEXT     │
└─────────────────────┘    └─────────────────────┘
         │
         │
         ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│  Si_BILLING_EVENTS  │    │ Si_SUPPORT_TICKETS  │    │    Si_WEBINARS      │
│                     │    │                     │    │                     │
│ - EVENT_TYPE        │    │ - TICKET_TYPE       │    │ - WEBINAR_TOPIC     │
│ - AMOUNT            │    │ - RESOLUTION_STATUS │    │ - START_TIME        │
│ - EVENT_DATE        │    │ - PRIORITY_LEVEL    │    │ - END_TIME          │
│ - CURRENCY_CODE     │    │ - OPEN_DATE         │    │ - DURATION_MINUTES  │
│ - PAYMENT_METHOD    │    │ - CLOSE_DATE        │    │ - REGISTRANTS       │
│ - TRANSACTION_STATUS│    │ - RESOLUTION_TIME   │    │ - ATTENDEES         │
└─────────────────────┘    └─────────────────────┘    │ - ATTENDANCE_RATE   │
                                                      └─────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                        DATA QUALITY & AUDIT LAYER                          │
├─────────────────────┬─────────────────────┬─────────────────────────────────┤
│ Si_DATA_QUALITY_    │  Si_VALIDATION_     │     Si_PIPELINE_AUDIT           │
│      ERRORS         │      RULES          │                                 │
│                     │                     │                                 │
│ - ERROR_ID          │ - RULE_ID           │ - AUDIT_ID                      │
│ - SOURCE_TABLE      │ - RULE_NAME         │ - PIPELINE_NAME                 │
│ - ERROR_TYPE        │ - RULE_DESCRIPTION  │ - EXECUTION_ID                  │
│ - ERROR_DESCRIPTION │ - TARGET_TABLE      │ - START_TIMESTAMP               │
│ - AFFECTED_COLUMN   │ - TARGET_COLUMN     │ - END_TIMESTAMP                 │
│ - ERROR_VALUE       │ - RULE_TYPE         │ - EXECUTION_STATUS              │
│ - ERROR_SEVERITY    │ - RULE_EXPRESSION   │ - RECORDS_PROCESSED             │
│ - RESOLUTION_STATUS │ - EXECUTION_FREQ    │ - RECORDS_INSERTED/UPDATED      │
└─────────────────────┴─────────────────────┴─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                         PROCESS MONITORING LAYER                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                      Si_PROCESS_MONITORING                                  │
│                                                                             │
│ - MONITOR_ID                    - THROUGHPUT_RECORDS_PER_MINUTE             │
│ - PROCESS_NAME                  - LATENCY_MILLISECONDS                      │
│ - MONITOR_TIMESTAMP             - ERROR_RATE                                │
│ - PROCESS_STATUS                - ALERT_THRESHOLD_BREACHED                  │
│ - CPU_UTILIZATION               - HEALTH_SCORE                              │
│ - MEMORY_UTILIZATION            - LAST_SUCCESSFUL_RUN                       │
│ - NETWORK_IO_MBPS               - NEXT_SCHEDULED_RUN                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Relationship Descriptions

1. **Si_USERS ↔ Si_MEETINGS**: Users host meetings (One-to-Many relationship via USER reference)
2. **Si_MEETINGS ↔ Si_PARTICIPANTS**: Meetings have multiple participants (One-to-Many relationship via MEETING reference)
3. **Si_MEETINGS ↔ Si_FEATURE_USAGE**: Features are used within meetings (One-to-Many relationship via MEETING reference)
4. **Si_USERS ↔ Si_LICENSES**: Users are assigned licenses (One-to-Many relationship via USER reference)
5. **Si_USERS ↔ Si_BILLING_EVENTS**: Users generate billing events (One-to-Many relationship via USER reference)
6. **Si_USERS ↔ Si_SUPPORT_TICKETS**: Users create support tickets (One-to-Many relationship via USER reference)
7. **Si_USERS ↔ Si_WEBINARS**: Users host webinars (One-to-Many relationship via USER reference)
8. **All Tables ↔ Si_DATA_QUALITY_ERRORS**: Quality errors can occur in any table (Many-to-One relationship via SOURCE_TABLE)
9. **All Tables ↔ Si_VALIDATION_RULES**: Validation rules apply to any table (Many-to-Many relationship via TARGET_TABLE)
10. **All Processes ↔ Si_PIPELINE_AUDIT**: All pipeline processes generate audit records (One-to-Many relationship)
11. **All Processes ↔ Si_PROCESS_MONITORING**: All processes are monitored (One-to-Many relationship)

## 5. Design Rationale and Key Decisions

### 5.1 Data Type Standardization
- **VARCHAR Sizing**: Implemented appropriate sizing based on expected data volumes and business requirements
- **DECIMAL Precision**: Used consistent precision for monetary and percentage values
- **TIMESTAMP Format**: Standardized on TIMESTAMP_NTZ for consistent timezone handling
- **Boolean Fields**: Added for clear binary indicators and flags

### 5.2 Data Quality Framework
- **Quality Scores**: Added DATA_QUALITY_SCORE to all main tables for monitoring
- **Error Management**: Comprehensive error tracking with severity levels and resolution tracking
- **Validation Rules**: Configurable validation framework for ongoing data quality management

### 5.3 Audit and Monitoring
- **Pipeline Audit**: Complete execution tracking with performance metrics
- **Process Monitoring**: Real-time monitoring capabilities with alerting thresholds
- **Lineage Tracking**: Maintained source system references for data lineage

### 5.4 Enhanced Analytics Capabilities
- **Calculated Fields**: Added derived metrics like attendance rates, utilization percentages
- **Categorization**: Implemented standardized categorization for better analytics
- **Geographic and Temporal**: Enhanced with geographic and timezone information

### 5.5 Privacy and Security
- **PII Handling**: Removed direct PII fields, kept domain-level information for analytics
- **Data Masking**: Applied appropriate masking while preserving analytical value
- **Access Control**: Structure supports role-based access control implementation

---

**Note**: This Silver layer logical data model enhances the Bronze layer structure by adding data quality controls, standardization, and comprehensive audit capabilities. The model supports both operational reporting and advanced analytics while maintaining data governance and quality standards required for a production medallion architecture.