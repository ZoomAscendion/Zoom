_____________________________________________
## *Author*: AAVA
## *Created on*:   10-11-2025
## *Description*: Silver layer logical data model for Zoom Platform Analytics System following Medallion architecture
## *Version*: 1 
## *Updated on*: 10-11-2025
_____________________________________________

# Silver Layer Logical Data Model - Zoom Platform Analytics System

## 1. Overview

This document defines the Silver layer logical data model for the Zoom Platform Analytics System following the Medallion architecture pattern. The Silver layer serves as the cleaned and standardized data layer, transforming Bronze layer raw data into business-ready datasets with consistent data types, standardized naming conventions, and enhanced data quality.

### Key Principles:
- **Data Standardization**: Consistent data types and formats across all tables
- **Business-Ready Structure**: Optimized for analytics and reporting use cases
- **Data Quality Enhancement**: Includes error tracking and validation results
- **Audit Trail**: Comprehensive pipeline execution tracking
- **No Primary/Foreign Keys**: Removes technical identifiers for analytical focus

## 2. Silver Layer Schema Design

### Schema Naming Convention
- **Target Database**: DB_POC_ZOOM
- **Target Schema**: SILVER
- **Table Prefix**: Si_ (Silver layer identifier)

### Standard Metadata Columns
All Silver layer tables include the following standard metadata columns:
- `LOAD_TIMESTAMP` - Timestamp when record was processed into Silver layer
- `UPDATE_TIMESTAMP` - Timestamp when record was last updated
- `SOURCE_SYSTEM` - Source system identifier for data lineage
- `DATA_QUALITY_SCORE` - Quality score from validation process (0-100)
- `VALIDATION_STATUS` - Status of data validation (PASSED, FAILED, WARNING)

## 3. Silver Layer Table Definitions

### 3.1 Si_USERS
**Purpose**: Stores cleaned and standardized user profile and subscription information
**Source Mapping**: BRONZE.Bz_USERS → SILVER.Si_USERS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user (standardized format) |
| EMAIL | VARCHAR(16777216) | Email address of the user (validated and standardized) |
| COMPANY | VARCHAR(16777216) | Company or organization name (cleaned and standardized) |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type (standardized values: Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |
| DATA_QUALITY_SCORE | NUMBER(3,0) | Quality score from validation process (0-100) |
| VALIDATION_STATUS | VARCHAR(50) | Status of data validation (PASSED, FAILED, WARNING) |

### 3.2 Si_MEETINGS
**Purpose**: Stores cleaned and standardized meeting information and session details
**Source Mapping**: BRONZE.Bz_MEETINGS → SILVER.Si_MEETINGS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting (cleaned and standardized) |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp (standardized timezone) |
| END_TIME | TIMESTAMP_NTZ(9) | Meeting end timestamp (standardized timezone) |
| DURATION_MINUTES | NUMBER(38,0) | Meeting duration in minutes (validated and calculated) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |
| DATA_QUALITY_SCORE | NUMBER(3,0) | Quality score from validation process (0-100) |
| VALIDATION_STATUS | VARCHAR(50) | Status of data validation (PASSED, FAILED, WARNING) |

### 3.3 Si_PARTICIPANTS
**Purpose**: Stores cleaned and standardized meeting participants and their session details
**Source Mapping**: BRONZE.Bz_PARTICIPANTS → SILVER.Si_PARTICIPANTS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant joined meeting (standardized timezone) |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left meeting (standardized timezone) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |
| DATA_QUALITY_SCORE | NUMBER(3,0) | Quality score from validation process (0-100) |
| VALIDATION_STATUS | VARCHAR(50) | Status of data validation (PASSED, FAILED, WARNING) |

### 3.4 Si_FEATURE_USAGE
**Purpose**: Stores cleaned and standardized platform feature usage during meetings
**Source Mapping**: BRONZE.Bz_FEATURE_USAGE → SILVER.Si_FEATURE_USAGE

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the feature being tracked (standardized naming) |
| USAGE_COUNT | NUMBER(38,0) | Number of times feature was used (validated) |
| USAGE_DATE | DATE | Date when feature usage occurred (standardized format) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |
| DATA_QUALITY_SCORE | NUMBER(3,0) | Quality score from validation process (0-100) |
| VALIDATION_STATUS | VARCHAR(50) | Status of data validation (PASSED, FAILED, WARNING) |

### 3.5 Si_SUPPORT_TICKETS
**Purpose**: Stores cleaned and standardized customer support requests and resolution tracking
**Source Mapping**: BRONZE.Bz_SUPPORT_TICKETS → SILVER.Si_SUPPORT_TICKETS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| TICKET_TYPE | VARCHAR(16777216) | Type of support ticket (standardized categories) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of ticket resolution (standardized values) |
| OPEN_DATE | DATE | Date when ticket was opened (standardized format) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |
| DATA_QUALITY_SCORE | NUMBER(3,0) | Quality score from validation process (0-100) |
| VALIDATION_STATUS | VARCHAR(50) | Status of data validation (PASSED, FAILED, WARNING) |

### 3.6 Si_BILLING_EVENTS
**Purpose**: Stores cleaned and standardized financial transactions and billing activities
**Source Mapping**: BRONZE.Bz_BILLING_EVENTS → SILVER.Si_BILLING_EVENTS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (standardized categories) |
| AMOUNT | NUMBER(10,2) | Monetary amount for the billing event (validated and standardized) |
| EVENT_DATE | DATE | Date when the billing event occurred (standardized format) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |
| DATA_QUALITY_SCORE | NUMBER(3,0) | Quality score from validation process (0-100) |
| VALIDATION_STATUS | VARCHAR(50) | Status of data validation (PASSED, FAILED, WARNING) |

### 3.7 Si_LICENSES
**Purpose**: Stores cleaned and standardized license assignments and entitlements
**Source Mapping**: BRONZE.Bz_LICENSES → SILVER.Si_LICENSES

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of license (standardized categories) |
| START_DATE | DATE | License validity start date (standardized format) |
| END_DATE | DATE | License validity end date (standardized format) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |
| DATA_QUALITY_SCORE | NUMBER(3,0) | Quality score from validation process (0-100) |
| VALIDATION_STATUS | VARCHAR(50) | Status of data validation (PASSED, FAILED, WARNING) |

## 4. Data Quality and Error Management Tables

### 4.1 Si_DATA_QUALITY_ERRORS
**Purpose**: Stores error data from data validation process across all Silver layer tables

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| ERROR_ID | VARCHAR(16777216) | Unique identifier for each error record |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the Silver layer table where error occurred |
| SOURCE_RECORD_KEY | VARCHAR(16777216) | Key identifier of the source record with error |
| ERROR_TYPE | VARCHAR(100) | Type of error (VALIDATION_FAILED, FORMAT_ERROR, BUSINESS_RULE_VIOLATION) |
| ERROR_CATEGORY | VARCHAR(100) | Category of error (DATA_TYPE, RANGE, FORMAT, COMPLETENESS, CONSISTENCY) |
| ERROR_DESCRIPTION | VARCHAR(16777216) | Detailed description of the error |
| ERROR_COLUMN | VARCHAR(16777216) | Column name where error was detected |
| ERROR_VALUE | VARCHAR(16777216) | Value that caused the error |
| ERROR_SEVERITY | VARCHAR(50) | Severity level (CRITICAL, HIGH, MEDIUM, LOW) |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when error was detected |
| RESOLUTION_STATUS | VARCHAR(50) | Status of error resolution (OPEN, IN_PROGRESS, RESOLVED, IGNORED) |
| RESOLUTION_NOTES | VARCHAR(16777216) | Notes about error resolution |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when error record was created |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when error record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system from which data originated |

### 4.2 Si_DATA_VALIDATION_RULES
**Purpose**: Stores validation rules applied during Silver layer processing

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| RULE_ID | VARCHAR(16777216) | Unique identifier for each validation rule |
| RULE_NAME | VARCHAR(16777216) | Name of the validation rule |
| TARGET_TABLE | VARCHAR(16777216) | Silver layer table to which rule applies |
| TARGET_COLUMN | VARCHAR(16777216) | Column to which rule applies |
| RULE_TYPE | VARCHAR(100) | Type of validation rule (FORMAT, RANGE, COMPLETENESS, CONSISTENCY) |
| RULE_EXPRESSION | VARCHAR(16777216) | SQL expression or logic for the rule |
| RULE_DESCRIPTION | VARCHAR(16777216) | Description of what the rule validates |
| ERROR_MESSAGE | VARCHAR(16777216) | Error message to display when rule fails |
| RULE_SEVERITY | VARCHAR(50) | Severity level when rule fails (CRITICAL, HIGH, MEDIUM, LOW) |
| IS_ACTIVE | BOOLEAN | Whether the rule is currently active |
| CREATED_DATE | DATE | Date when rule was created |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when rule record was created |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when rule record was last updated |

## 5. Pipeline Audit and Execution Tracking Tables

### 5.1 Si_PIPELINE_EXECUTION_LOG
**Purpose**: Comprehensive audit trail for all Silver layer pipeline executions

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| EXECUTION_ID | VARCHAR(16777216) | Unique identifier for each pipeline execution |
| PIPELINE_NAME | VARCHAR(16777216) | Name of the executed pipeline |
| PIPELINE_TYPE | VARCHAR(100) | Type of pipeline (BATCH, STREAMING, INCREMENTAL) |
| EXECUTION_START_TIME | TIMESTAMP_NTZ(9) | Timestamp when pipeline execution started |
| EXECUTION_END_TIME | TIMESTAMP_NTZ(9) | Timestamp when pipeline execution completed |
| EXECUTION_DURATION_SECONDS | NUMBER(10,2) | Total execution time in seconds |
| EXECUTION_STATUS | VARCHAR(50) | Status of execution (SUCCESS, FAILED, PARTIAL_SUCCESS, CANCELLED) |
| SOURCE_TABLE | VARCHAR(16777216) | Bronze layer source table processed |
| TARGET_TABLE | VARCHAR(16777216) | Silver layer target table created/updated |
| RECORDS_PROCESSED | NUMBER(38,0) | Total number of records processed |
| RECORDS_SUCCESS | NUMBER(38,0) | Number of records successfully processed |
| RECORDS_FAILED | NUMBER(38,0) | Number of records that failed processing |
| RECORDS_SKIPPED | NUMBER(38,0) | Number of records skipped during processing |
| DATA_QUALITY_SCORE_AVG | NUMBER(5,2) | Average data quality score for processed records |
| ERROR_COUNT | NUMBER(38,0) | Total number of errors encountered |
| WARNING_COUNT | NUMBER(38,0) | Total number of warnings generated |
| EXECUTION_TRIGGER | VARCHAR(100) | What triggered the execution (SCHEDULED, MANUAL, EVENT_DRIVEN) |
| EXECUTED_BY | VARCHAR(16777216) | User or system that executed the pipeline |
| CONFIGURATION_USED | VARIANT | JSON configuration used for execution |
| ERROR_DETAILS | VARIANT | JSON details of errors encountered |
| PERFORMANCE_METRICS | VARIANT | JSON performance metrics (CPU, memory, I/O) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when execution log was created |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when execution log was last updated |

### 5.2 Si_DATA_LINEAGE_TRACKING
**Purpose**: Tracks data lineage from Bronze to Silver layer transformations

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| LINEAGE_ID | VARCHAR(16777216) | Unique identifier for each lineage record |
| SOURCE_SYSTEM | VARCHAR(16777216) | Original source system |
| SOURCE_TABLE | VARCHAR(16777216) | Bronze layer source table |
| SOURCE_RECORD_KEY | VARCHAR(16777216) | Key of source record |
| TARGET_TABLE | VARCHAR(16777216) | Silver layer target table |
| TARGET_RECORD_KEY | VARCHAR(16777216) | Key of target record |
| TRANSFORMATION_TYPE | VARCHAR(100) | Type of transformation applied |
| TRANSFORMATION_RULES | VARIANT | JSON details of transformation rules applied |
| PROCESSING_TIMESTAMP | TIMESTAMP_NTZ(9) | When the transformation occurred |
| PIPELINE_EXECUTION_ID | VARCHAR(16777216) | Reference to pipeline execution |
| DATA_QUALITY_IMPACT | VARCHAR(16777216) | Impact on data quality during transformation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when lineage record was created |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when lineage record was last updated |

## 6. Data Type Standardization Rules

### 6.1 Standardization Applied
1. **Timestamps**: All timestamps converted to TIMESTAMP_NTZ(9) with UTC timezone
2. **Dates**: All dates standardized to DATE format (YYYY-MM-DD)
3. **Text Fields**: Trimmed, case-standardized where applicable
4. **Numeric Fields**: Validated ranges and precision
5. **Categorical Fields**: Standardized to predefined domain values

### 6.2 Data Quality Enhancements
1. **Email Validation**: Format validation and standardization
2. **Duration Calculations**: Validated against start/end times
3. **Status Standardization**: Consistent status values across tables
4. **Amount Validation**: Currency formatting and range validation

## 7. Conceptual Data Model Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Si_USERS      │────▶│  Si_MEETINGS    │────▶│ Si_PARTICIPANTS │
│                 │     │                 │     │                 │
│ • USER_NAME     │     │ • MEETING_TOPIC │     │ • JOIN_TIME     │
│ • EMAIL         │     │ • START_TIME    │     │ • LEAVE_TIME    │
│ • COMPANY       │     │ • END_TIME      │     │ • LOAD_TS       │
│ • PLAN_TYPE     │     │ • DURATION_MIN  │     │ • UPDATE_TS     │
│ • LOAD_TS       │     │ • LOAD_TS       │     │ • SOURCE_SYS    │
│ • UPDATE_TS     │     │ • UPDATE_TS     │     │ • DQ_SCORE      │
│ • SOURCE_SYS    │     │ • SOURCE_SYS    │     │ • VALIDATION_ST │
│ • DQ_SCORE      │     │ • DQ_SCORE      │     └─────────────────┘
│ • VALIDATION_ST │     │ • VALIDATION_ST │              
└─────────────────┘     └─────────────────┘              
         │                        │                       
         │                        ▼                       
         │               ┌─────────────────┐              
         │               │ Si_FEATURE_USAGE│              
         │               │                 │              
         │               │ • FEATURE_NAME  │              
         │               │ • USAGE_COUNT   │              
         │               │ • USAGE_DATE    │              
         │               │ • LOAD_TS       │              
         │               │ • UPDATE_TS     │              
         │               │ • SOURCE_SYS    │              
         │               │ • DQ_SCORE      │              
         │               │ • VALIDATION_ST │              
         │               └─────────────────┘              
         │                                                 
         ├─────────────────┐                              
         │                 │                              
         ▼                 ▼                              
┌─────────────────┐ ┌─────────────────┐                 
│Si_SUPPORT_TICKETS│ │ Si_BILLING_EVENTS│                
│                 │ │                 │                 
│ • TICKET_TYPE   │ │ • EVENT_TYPE    │                 
│ • RESOLUTION_ST │ │ • AMOUNT        │                 
│ • OPEN_DATE     │ │ • EVENT_DATE    │                 
│ • LOAD_TS       │ │ • LOAD_TS       │                 
│ • UPDATE_TS     │ │ • UPDATE_TS     │                 
│ • SOURCE_SYS    │ │ • SOURCE_SYS    │                 
│ • DQ_SCORE      │ │ • DQ_SCORE      │                 
│ • VALIDATION_ST │ │ • VALIDATION_ST │                 
└─────────────────┘ └─────────────────┘                 
         │                                                 
         ▼                                                 
┌─────────────────┐                                      
│   Si_LICENSES   │                                      
│                 │                                      
│ • LICENSE_TYPE  │                                      
│ • START_DATE    │                                      
│ • END_DATE      │                                      
│ • LOAD_TS       │                                      
│ • UPDATE_TS     │                                      
│ • SOURCE_SYS    │                                      
│ • DQ_SCORE      │                                      
│ • VALIDATION_ST │                                      
└─────────────────┘                                      

┌─────────────────────────────────────────────────────────┐
│                 DATA QUALITY & AUDIT LAYER             │
├─────────────────┬─────────────────┬─────────────────────┤
│Si_DATA_QUALITY_ │Si_DATA_VALIDATION│Si_PIPELINE_EXECUTION│
│ERRORS           │_RULES           │_LOG                 │
│                 │                 │                     │
│ • ERROR_ID      │ • RULE_ID       │ • EXECUTION_ID      │
│ • SOURCE_TABLE  │ • RULE_NAME     │ • PIPELINE_NAME     │
│ • ERROR_TYPE    │ • TARGET_TABLE  │ • EXECUTION_STATUS  │
│ • ERROR_DESC    │ • RULE_TYPE     │ • RECORDS_PROCESSED │
│ • RESOLUTION_ST │ • RULE_EXPR     │ • ERROR_COUNT       │
└─────────────────┴─────────────────┴─────────────────────┘

┌─────────────────┐
│Si_DATA_LINEAGE_ │
│TRACKING         │
│                 │
│ • LINEAGE_ID    │
│ • SOURCE_TABLE  │
│ • TARGET_TABLE  │
│ • TRANSFORM_TYPE│
│ • PIPELINE_EXEC │
└─────────────────┘

Connections:
- Si_USERS connects to Si_MEETINGS via user context
- Si_MEETINGS connects to Si_PARTICIPANTS via meeting context  
- Si_MEETINGS connects to Si_FEATURE_USAGE via meeting context
- Si_USERS connects to Si_SUPPORT_TICKETS via user context
- Si_USERS connects to Si_BILLING_EVENTS via user context
- Si_USERS connects to Si_LICENSES via user context
- All tables connect to Data Quality & Audit layer for error tracking and lineage
```

## 8. Key Design Decisions and Rationale

### 8.1 Removal of Primary and Foreign Keys
**Decision**: Removed all primary key and foreign key fields from Bronze layer tables
**Rationale**: 
- Silver layer focuses on analytical use cases rather than transactional integrity
- Enables more flexible data modeling for analytics
- Reduces complexity in data transformation processes
- Allows for handling of duplicate or near-duplicate records

### 8.2 Addition of Data Quality Metadata
**Decision**: Added DATA_QUALITY_SCORE and VALIDATION_STATUS to all tables
**Rationale**:
- Enables data quality monitoring and reporting
- Supports data governance requirements
- Allows downstream consumers to make informed decisions about data usage
- Facilitates continuous improvement of data quality

### 8.3 Comprehensive Error and Audit Framework
**Decision**: Implemented dedicated tables for error tracking and pipeline auditing
**Rationale**:
- Supports operational monitoring and troubleshooting
- Enables data lineage tracking for compliance
- Provides detailed audit trail for all transformations
- Supports data quality improvement initiatives

### 8.4 Standardized Naming Convention
**Decision**: Used 'Si_' prefix for all Silver layer tables
**Rationale**:
- Clear identification of data layer in multi-layer architecture
- Consistent with Medallion architecture best practices
- Enables easy navigation and understanding of data structure
- Supports automated tooling and processes

## 9. Assumptions Made

1. **Data Volume**: Assumed moderate to high data volumes requiring optimization for analytical queries
2. **Update Frequency**: Assumed batch processing with periodic updates rather than real-time streaming
3. **Data Quality**: Assumed need for comprehensive data quality monitoring and error tracking
4. **Compliance**: Assumed need for detailed audit trails and data lineage tracking
5. **Analytics Focus**: Assumed primary use case is analytical reporting and business intelligence
6. **Snowflake Platform**: Assumed deployment on Snowflake cloud data platform
7. **UTC Timezone**: Assumed all timestamps should be standardized to UTC timezone
8. **English Language**: Assumed all text data is in English for standardization purposes

## 10. Summary

This Silver layer logical data model provides:

1. **7 Core Business Tables**: Cleaned and standardized versions of Bronze layer tables without primary/foreign keys
2. **4 Data Quality Tables**: Comprehensive error tracking and validation rule management
3. **2 Audit Tables**: Pipeline execution logging and data lineage tracking
4. **Standardized Structure**: Consistent naming conventions and data types across all tables
5. **Enhanced Metadata**: Data quality scores and validation status for all records
6. **Comprehensive Audit Trail**: Complete tracking of transformations and pipeline executions

The model supports the three key reporting areas identified in the conceptual model:
- **Platform Usage & Adoption**: Through Si_USERS, Si_MEETINGS, Si_PARTICIPANTS, and Si_FEATURE_USAGE tables
- **Service Reliability & Support**: Through Si_SUPPORT_TICKETS and comprehensive error tracking
- **Revenue & License Management**: Through Si_BILLING_EVENTS and Si_LICENSES tables

All tables are optimized for analytical queries while maintaining comprehensive data quality and audit capabilities required for enterprise data governance.
