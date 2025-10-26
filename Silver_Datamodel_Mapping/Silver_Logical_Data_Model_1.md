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
**Description**: Cleansed and standardized billing and payment event data with data quality validations applied

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(50) | Standardized billing event type (SUBSCRIPTION, PAYMENT, REFUND, UPGRADE, DOWNGRADE) |
| AMOUNT | DECIMAL(12,2) | Validated monetary amount with currency standardization applied |
| EVENT_DATE | DATE | Validated event date ensuring chronological consistency |
| CURRENCY_CODE | VARCHAR(3) | ISO 4217 currency code for international transactions |
| PAYMENT_METHOD | VARCHAR(50) | Standardized payment method (CREDIT_CARD, BANK_TRANSFER, PAYPAL, etc.) |
| TRANSACTION_STATUS | VARCHAR(20) | Processing status (COMPLETED, PENDING, FAILED, CANCELLED) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Silver layer ingestion timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Last modification timestamp in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on validation rules (0.00-1.00) |

### 1.2 Table: Si_FEATURE_USAGE
**Description**: Standardized platform feature utilization data with usage pattern analysis

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(100) | Standardized feature name using controlled vocabulary |
| USAGE_COUNT | INTEGER | Validated usage count with outlier detection applied |
| USAGE_DATE | DATE | Validated usage date with temporal consistency checks |
| USAGE_DURATION_MINUTES | INTEGER | Calculated feature usage duration in minutes |
| FEATURE_CATEGORY | VARCHAR(50) | Categorized feature type (COMMUNICATION, COLLABORATION, SECURITY, etc.) |
| USAGE_PATTERN | VARCHAR(30) | Derived usage pattern (FREQUENT, OCCASIONAL, RARE) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Silver layer ingestion timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Last modification timestamp in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on validation rules (0.00-1.00) |

### 1.3 Table: Si_LICENSES
**Description**: Validated license management data with lifecycle tracking and utilization metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(50) | Standardized license category (BASIC, PRO, BUSINESS, ENTERPRISE, ADDON) |
| START_DATE | DATE | Validated license activation date |
| END_DATE | DATE | Validated license expiration date with business rule checks |
| LICENSE_STATUS | VARCHAR(20) | Current license state (ACTIVE, EXPIRED, SUSPENDED, CANCELLED) |
| LICENSE_DURATION_DAYS | INTEGER | Calculated license validity period in days |
| RENEWAL_FLAG | BOOLEAN | Indicator for license renewal eligibility |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Silver layer ingestion timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Last modification timestamp in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on validation rules (0.00-1.00) |

### 1.4 Table: Si_MEETINGS
**Description**: Cleansed meeting data with standardized metrics and derived attributes for analytics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(500) | Cleansed meeting subject with PII masking applied |
| START_TIME | TIMESTAMP_NTZ(9) | Validated meeting start timestamp |
| END_TIME | TIMESTAMP_NTZ(9) | Validated meeting end timestamp with consistency checks |
| DURATION_MINUTES | INTEGER | Calculated meeting duration with business rule validation |
| MEETING_TYPE | VARCHAR(30) | Derived meeting type (SCHEDULED, INSTANT, RECURRING, WEBINAR) |
| TIME_ZONE | VARCHAR(50) | Standardized timezone information |
| MEETING_SIZE_CATEGORY | VARCHAR(20) | Categorized meeting size (SMALL, MEDIUM, LARGE, ENTERPRISE) |
| BUSINESS_HOURS_FLAG | BOOLEAN | Indicator for meetings during standard business hours |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Silver layer ingestion timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Last modification timestamp in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on validation rules (0.00-1.00) |

### 1.5 Table: Si_PARTICIPANTS
**Description**: Standardized participant data with attendance analytics and engagement metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Validated participant entry timestamp |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Validated participant exit timestamp |
| ATTENDANCE_DURATION_MINUTES | INTEGER | Calculated participant attendance duration |
| ATTENDANCE_PERCENTAGE | DECIMAL(5,2) | Percentage of meeting attended by participant |
| LATE_JOIN_FLAG | BOOLEAN | Indicator for participants joining after meeting start |
| EARLY_LEAVE_FLAG | BOOLEAN | Indicator for participants leaving before meeting end |
| ENGAGEMENT_SCORE | DECIMAL(3,2) | Calculated engagement score based on participation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Silver layer ingestion timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Last modification timestamp in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on validation rules (0.00-1.00) |

### 1.6 Table: Si_SUPPORT_TICKETS
**Description**: Standardized support ticket data with resolution analytics and performance metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(50) | Standardized ticket category (TECHNICAL, BILLING, FEATURE_REQUEST, ACCOUNT) |
| ISSUE_DESCRIPTION | VARCHAR(2000) | Cleansed issue description with sensitive data masked |
| PRIORITY_LEVEL | VARCHAR(20) | Standardized priority (LOW, MEDIUM, HIGH, CRITICAL) |
| RESOLUTION_STATUS | VARCHAR(30) | Current ticket status (OPEN, IN_PROGRESS, RESOLVED, CLOSED, ESCALATED) |
| OPEN_DATE | DATE | Validated ticket creation date |
| CLOSE_DATE | DATE | Validated ticket resolution date |
| RESOLUTION_TIME_HOURS | INTEGER | Calculated resolution time in business hours |
| FIRST_RESPONSE_TIME_HOURS | INTEGER | Time to first response in business hours |
| ESCALATION_FLAG | BOOLEAN | Indicator for escalated tickets |
| SLA_BREACH_FLAG | BOOLEAN | Indicator for SLA compliance breach |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Silver layer ingestion timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Last modification timestamp in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on validation rules (0.00-1.00) |

### 1.7 Table: Si_USERS
**Description**: Cleansed user profile data with standardized attributes and derived analytics fields

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(200) | Standardized user display name with PII protection |
| EMAIL_DOMAIN | VARCHAR(100) | Extracted email domain for organizational analysis |
| COMPANY | VARCHAR(200) | Standardized company name with data cleansing applied |
| PLAN_TYPE | VARCHAR(30) | Standardized subscription plan (FREE, BASIC, PRO, BUSINESS, ENTERPRISE) |
| REGISTRATION_DATE | DATE | Validated user registration date |
| ACCOUNT_AGE_DAYS | INTEGER | Calculated account age in days |
| USER_SEGMENT | VARCHAR(30) | Derived user segment (NEW, ACTIVE, POWER_USER, INACTIVE) |
| GEOGRAPHIC_REGION | VARCHAR(50) | Derived geographic region from user data |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Silver layer ingestion timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Last modification timestamp in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on validation rules (0.00-1.00) |

### 1.8 Table: Si_WEBINARS
**Description**: Standardized webinar data with registration analytics and performance metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| WEBINAR_TOPIC | VARCHAR(500) | Cleansed webinar title with sensitive information masked |
| START_TIME | TIMESTAMP_NTZ(9) | Validated webinar start timestamp |
| END_TIME | TIMESTAMP_NTZ(9) | Validated webinar end timestamp |
| DURATION_MINUTES | INTEGER | Calculated webinar duration |
| REGISTRANTS | INTEGER | Total number of registered participants |
| ACTUAL_ATTENDEES | INTEGER | Actual number of participants who joined |
| ATTENDANCE_RATE | DECIMAL(5,2) | Calculated attendance rate percentage |
| WEBINAR_CATEGORY | VARCHAR(50) | Categorized webinar type (TRAINING, MARKETING, PRODUCT_DEMO, etc.) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Silver layer ingestion timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Last modification timestamp in Silver layer |
| SOURCE_SYSTEM | VARCHAR(100) | Validated source system identifier |
| DATA_QUALITY_SCORE | DECIMAL(3,2) | Quality score based on validation rules (0.00-1.00) |

## 2. Data Quality and Error Management Tables

### 2.1 Table: Si_DATA_QUALITY_ERRORS
**Description**: Comprehensive error tracking for data validation failures and quality issues

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ERROR_ID | VARCHAR(50) | Unique identifier for each data quality error |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table where error occurred |
| ERROR_TYPE | VARCHAR(50) | Type of validation error (NULL_CHECK, FORMAT_ERROR, RANGE_ERROR, etc.) |
| ERROR_DESCRIPTION | VARCHAR(1000) | Detailed description of the data quality issue |
| AFFECTED_COLUMN | VARCHAR(100) | Column name where the error was detected |
| ERROR_VALUE | VARCHAR(500) | Actual value that caused the validation failure |
| ERROR_SEVERITY | VARCHAR(20) | Severity level (LOW, MEDIUM, HIGH, CRITICAL) |
| ERROR_DATE | DATE | Date when the error was detected |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ(9) | Precise timestamp of error detection |
| RESOLUTION_STATUS | VARCHAR(30) | Error resolution status (OPEN, IN_PROGRESS, RESOLVED, IGNORED) |
| RESOLUTION_ACTION | VARCHAR(500) | Action taken to resolve the error |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Silver layer ingestion timestamp |

### 2.2 Table: Si_VALIDATION_RULES
**Description**: Repository of data validation rules and quality checks applied to Silver layer data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| RULE_ID | VARCHAR(50) | Unique identifier for each validation rule |
| RULE_NAME | VARCHAR(200) | Descriptive name of the validation rule |
| TARGET_TABLE | VARCHAR(100) | Table to which the validation rule applies |
| TARGET_COLUMN | VARCHAR(100) | Column to which the validation rule applies |
| RULE_TYPE | VARCHAR(50) | Type of validation (NOT_NULL, RANGE_CHECK, FORMAT_CHECK, etc.) |
| RULE_EXPRESSION | VARCHAR(2000) | SQL expression or logic for the validation rule |
| ERROR_MESSAGE | VARCHAR(500) | Standard error message for rule violations |
| RULE_PRIORITY | VARCHAR(20) | Priority level of the validation rule |
| ACTIVE_FLAG | BOOLEAN | Indicator for active/inactive rules |
| CREATED_DATE | DATE | Date when the rule was created |
| LAST_MODIFIED_DATE | DATE | Date when the rule was last updated |

## 3. Pipeline Audit and Process Management Tables

### 3.1 Table: Si_PIPELINE_AUDIT
**Description**: Comprehensive audit trail for ETL pipeline execution and data processing activities

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| AUDIT_ID | VARCHAR(50) | Unique identifier for each pipeline execution |
| PIPELINE_NAME | VARCHAR(200) | Name of the ETL pipeline or process |
| EXECUTION_START_TIME | TIMESTAMP_NTZ(9) | Pipeline execution start timestamp |
| EXECUTION_END_TIME | TIMESTAMP_NTZ(9) | Pipeline execution completion timestamp |
| EXECUTION_DURATION_SECONDS | INTEGER | Total pipeline execution time in seconds |
| SOURCE_TABLE | VARCHAR(100) | Source table being processed |
| TARGET_TABLE | VARCHAR(100) | Target Silver layer table |
| RECORDS_PROCESSED | INTEGER | Total number of records processed |
| RECORDS_SUCCESS | INTEGER | Number of successfully processed records |
| RECORDS_FAILED | INTEGER | Number of records that failed processing |
| RECORDS_REJECTED | INTEGER | Number of records rejected due to quality issues |
| EXECUTION_STATUS | VARCHAR(30) | Pipeline execution status (SUCCESS, FAILED, PARTIAL, CANCELLED) |
| ERROR_MESSAGE | VARCHAR(2000) | Error details for failed executions |
| PROCESSED_BY | VARCHAR(100) | User or system that executed the pipeline |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Audit record creation timestamp |

### 3.2 Table: Si_DATA_LINEAGE
**Description**: Data lineage tracking for source-to-target mapping and transformation history

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LINEAGE_ID | VARCHAR(50) | Unique identifier for lineage record |
| SOURCE_SYSTEM | VARCHAR(100) | Origin system of the data |
| SOURCE_TABLE | VARCHAR(100) | Source table name |
| SOURCE_COLUMN | VARCHAR(100) | Source column name |
| TARGET_TABLE | VARCHAR(100) | Target Silver layer table |
| TARGET_COLUMN | VARCHAR(100) | Target Silver layer column |
| TRANSFORMATION_LOGIC | VARCHAR(2000) | Description of applied transformations |
| TRANSFORMATION_TYPE | VARCHAR(50) | Type of transformation (DIRECT_COPY, CALCULATED, DERIVED, etc.) |
| BUSINESS_RULE_APPLIED | VARCHAR(1000) | Business rules applied during transformation |
| CREATED_DATE | DATE | Date when lineage was established |
| LAST_UPDATED_DATE | DATE | Date when lineage was last modified |
| ACTIVE_FLAG | BOOLEAN | Indicator for active lineage mappings |

## 4. Conceptual Data Model Diagram

### 4.1 Block Diagram Format - Silver Layer Table Relationships

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Si_USERS      │────│   Si_MEETINGS   │────│ Si_PARTICIPANTS │
│                 │    │                 │    │                 │
│ - USER_NAME     │    │ - MEETING_TOPIC │    │ - JOIN_TIME     │
│ - EMAIL_DOMAIN  │    │ - START_TIME    │    │ - LEAVE_TIME    │
│ - COMPANY       │    │ - END_TIME      │    │ - ATTENDANCE_%  │
│ - PLAN_TYPE     │    │ - DURATION_MIN  │    │ - ENGAGEMENT    │
│ - USER_SEGMENT  │    │ - MEETING_TYPE  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│  Si_LICENSES    │    │Si_FEATURE_USAGE │
│                 │    │                 │
│ - LICENSE_TYPE  │    │ - FEATURE_NAME  │
│ - START_DATE    │    │ - USAGE_COUNT   │
│ - END_DATE      │    │ - USAGE_PATTERN │
│ - LICENSE_STATUS│    │ - FEATURE_CAT   │
└─────────────────┘    └─────────────────┘
         │
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Si_BILLING_EVENTS│    │Si_SUPPORT_TICKETS│   │   Si_WEBINARS   │
│                 │    │                 │    │                 │
│ - EVENT_TYPE    │    │ - TICKET_TYPE   │    │ - WEBINAR_TOPIC │
│ - AMOUNT        │    │ - PRIORITY_LEVEL│    │ - START_TIME    │
│ - CURRENCY_CODE │    │ - RESOLUTION_ST │    │ - REGISTRANTS   │
│ - PAYMENT_METHOD│    │ - SLA_BREACH    │    │ - ATTENDANCE_%  │
└─────────────────┘    └─────────────────┘    └─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Si_DATA_QUALITY_ │    │ Si_PIPELINE_    │    │ Si_DATA_LINEAGE │
│     ERRORS      │    │     AUDIT       │    │                 │
│                 │    │                 │    │                 │
│ - ERROR_ID      │    │ - AUDIT_ID      │    │ - LINEAGE_ID    │
│ - SOURCE_TABLE  │    │ - PIPELINE_NAME │    │ - SOURCE_TABLE  │
│ - ERROR_TYPE    │    │ - RECORDS_PROC  │    │ - TARGET_TABLE  │
│ - ERROR_SEVERITY│    │ - EXEC_STATUS   │    │ - TRANSFORM_LOG │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 4.2 Relationship Descriptions

1. **Si_USERS ↔ Si_MEETINGS**: Users host meetings (One-to-Many relationship via USER_NAME reference)
2. **Si_MEETINGS ↔ Si_PARTICIPANTS**: Meetings have multiple participants (One-to-Many relationship via MEETING reference)
3. **Si_MEETINGS ↔ Si_FEATURE_USAGE**: Features are used within meetings (One-to-Many relationship via MEETING reference)
4. **Si_USERS ↔ Si_LICENSES**: Users are assigned licenses (One-to-Many relationship via USER reference)
5. **Si_USERS ↔ Si_BILLING_EVENTS**: Users generate billing events (One-to-Many relationship via USER reference)
6. **Si_USERS ↔ Si_SUPPORT_TICKETS**: Users create support tickets (One-to-Many relationship via USER reference)
7. **Si_USERS ↔ Si_WEBINARS**: Users host webinars (One-to-Many relationship via USER reference)
8. **All Tables ↔ Si_DATA_QUALITY_ERRORS**: Quality errors can occur in any table (Many-to-One relationship)
9. **All Tables ↔ Si_PIPELINE_AUDIT**: All tables are processed by pipelines (Many-to-One relationship)
10. **All Tables ↔ Si_DATA_LINEAGE**: All tables have lineage tracking (Many-to-One relationship)

## 5. Design Rationale and Key Decisions

### 5.1 Data Standardization Approach
- **Consistent Naming Convention**: All Silver layer tables use 'Si_' prefix for clear identification
- **Data Type Standardization**: Implemented consistent data types across similar columns
- **Controlled Vocabularies**: Used standardized values for categorical fields to ensure consistency

### 5.2 Data Quality Framework
- **Quality Scoring**: Each record includes a data quality score (0.00-1.00) based on validation results
- **Error Tracking**: Comprehensive error management with detailed error classification and resolution tracking
- **Validation Rules**: Centralized repository of validation rules for maintainability

### 5.3 Analytics Enhancement
- **Derived Attributes**: Added calculated fields like duration, percentages, and categorizations
- **Business Flags**: Included boolean indicators for common business scenarios
- **Segmentation**: Added user and usage segmentation for advanced analytics

### 5.4 Audit and Governance
- **Pipeline Audit**: Complete tracking of ETL processes with performance metrics
- **Data Lineage**: Full source-to-target mapping for compliance and troubleshooting
- **Temporal Tracking**: Comprehensive timestamp management for data freshness monitoring

### 5.5 Key Assumptions
- Source data quality varies and requires validation at Silver layer
- Business users need both detailed and aggregated views of data
- Compliance requires complete audit trails and data lineage
- Performance optimization through pre-calculated derived attributes
- PII protection through masking and domain extraction techniques

---

**Note**: This Silver layer logical data model implements medallion architecture principles by providing cleansed, validated, and enriched data ready for analytics consumption. The model removes primary and foreign key constraints while maintaining referential relationships through business keys, includes comprehensive data quality management, and provides full audit capabilities for enterprise data governance requirements.