_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer logical data model for Zoom Platform Analytics System following Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Logical Data Model - Zoom Platform Analytics System

## 1. Overview

This document defines the Silver layer logical data model for the Zoom Platform Analytics System following the Medallion architecture pattern. The Silver layer serves as the cleaned and standardized data layer, transforming Bronze layer raw data into business-ready datasets with consistent data types, standardized naming conventions, and enhanced data quality.

### Key Principles:
- **Data Standardization**: Consistent data types and formats across all tables
- **Business-Ready Data**: Cleaned and validated data suitable for analytics
- **Data Quality Enhancement**: Implementation of data validation and error handling
- **Audit Trail Integration**: Comprehensive process audit data from pipeline execution
- **No Primary/Foreign Keys**: Silver layer focuses on data transformation without key constraints

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
- `DATA_QUALITY_FLAG` - Flag indicating data quality status
- `PROCESSING_DATE` - Date when the record was processed

## 3. Silver Layer Table Definitions

### 3.1 Si_USERS
**Purpose**: Stores cleaned and standardized user profile and subscription information
**Source Mapping**: BRONZE.Bz_USERS → SILVER.Si_USERS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| USER_NAME | VARCHAR(16777216) | Standardized display name of the user |
| EMAIL | VARCHAR(16777216) | Validated and standardized email address |
| COMPANY | VARCHAR(16777216) | Cleaned company or organization name |
| PLAN_TYPE | VARCHAR(16777216) | Standardized subscription plan type |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage |
| DATA_QUALITY_FLAG | VARCHAR(50) | Data quality status indicator |
| PROCESSING_DATE | DATE | Date when the record was processed |

### 3.2 Si_MEETINGS
**Purpose**: Stores cleaned and standardized meeting information and session details
**Source Mapping**: BRONZE.Bz_MEETINGS → SILVER.Si_MEETINGS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Cleaned and standardized meeting topic |
| START_TIME | TIMESTAMP_NTZ(9) | Validated meeting start timestamp |
| END_TIME | TIMESTAMP_NTZ(9) | Validated meeting end timestamp |
| DURATION_MINUTES | NUMBER(38,0) | Calculated and validated meeting duration in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage |
| DATA_QUALITY_FLAG | VARCHAR(50) | Data quality status indicator |
| PROCESSING_DATE | DATE | Date when the record was processed |

### 3.3 Si_PARTICIPANTS
**Purpose**: Stores cleaned and standardized meeting participant information
**Source Mapping**: BRONZE.Bz_PARTICIPANTS → SILVER.Si_PARTICIPANTS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Validated timestamp when participant joined meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Validated timestamp when participant left meeting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage |
| DATA_QUALITY_FLAG | VARCHAR(50) | Data quality status indicator |
| PROCESSING_DATE | DATE | Date when the record was processed |

### 3.4 Si_FEATURE_USAGE
**Purpose**: Stores cleaned and standardized platform feature usage data
**Source Mapping**: BRONZE.Bz_FEATURE_USAGE → SILVER.Si_FEATURE_USAGE

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| FEATURE_NAME | VARCHAR(16777216) | Standardized name of the feature being tracked |
| USAGE_COUNT | NUMBER(38,0) | Validated number of times feature was used |
| USAGE_DATE | DATE | Validated date when feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage |
| DATA_QUALITY_FLAG | VARCHAR(50) | Data quality status indicator |
| PROCESSING_DATE | DATE | Date when the record was processed |

### 3.5 Si_SUPPORT_TICKETS
**Purpose**: Stores cleaned and standardized customer support request information
**Source Mapping**: BRONZE.Bz_SUPPORT_TICKETS → SILVER.Si_SUPPORT_TICKETS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| TICKET_TYPE | VARCHAR(16777216) | Standardized type of support ticket |
| RESOLUTION_STATUS | VARCHAR(16777216) | Standardized current status of ticket resolution |
| OPEN_DATE | DATE | Validated date when ticket was opened |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage |
| DATA_QUALITY_FLAG | VARCHAR(50) | Data quality status indicator |
| PROCESSING_DATE | DATE | Date when the record was processed |

### 3.6 Si_BILLING_EVENTS
**Purpose**: Stores cleaned and standardized financial transaction information
**Source Mapping**: BRONZE.Bz_BILLING_EVENTS → SILVER.Si_BILLING_EVENTS

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| EVENT_TYPE | VARCHAR(16777216) | Standardized type of billing event |
| AMOUNT | NUMBER(10,2) | Validated monetary amount for the billing event |
| EVENT_DATE | DATE | Validated date when the billing event occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage |
| DATA_QUALITY_FLAG | VARCHAR(50) | Data quality status indicator |
| PROCESSING_DATE | DATE | Date when the record was processed |

### 3.7 Si_LICENSES
**Purpose**: Stores cleaned and standardized license assignment information
**Source Mapping**: BRONZE.Bz_LICENSES → SILVER.Si_LICENSES

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Standardized type of license |
| START_DATE | DATE | Validated license validity start date |
| END_DATE | DATE | Validated license validity end date |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was processed into Silver layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage |
| DATA_QUALITY_FLAG | VARCHAR(50) | Data quality status indicator |
| PROCESSING_DATE | DATE | Date when the record was processed |

## 4. Data Quality and Error Management Tables

### 4.1 Si_DATA_QUALITY_ERRORS
**Purpose**: Stores error data from data validation process during Silver layer transformation

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| ERROR_ID | VARCHAR(16777216) | Unique identifier for each data quality error |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source Bronze table where error occurred |
| TARGET_TABLE | VARCHAR(16777216) | Name of the target Silver table |
| ERROR_TYPE | VARCHAR(16777216) | Type of data quality error (Validation, Format, Business Rule) |
| ERROR_DESCRIPTION | VARCHAR(16777216) | Detailed description of the error |
| ERROR_COLUMN | VARCHAR(16777216) | Column name where error was detected |
| ERROR_VALUE | VARCHAR(16777216) | Value that caused the error |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when error was detected |
| SEVERITY_LEVEL | VARCHAR(50) | Severity level of the error (Critical, High, Medium, Low) |
| RESOLUTION_STATUS | VARCHAR(50) | Status of error resolution (Open, In Progress, Resolved) |
| PROCESSING_DATE | DATE | Date when the error was logged |

### 4.2 Si_PIPELINE_AUDIT
**Purpose**: Stores comprehensive audit details from pipeline execution

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| AUDIT_ID | VARCHAR(16777216) | Unique identifier for each audit record |
| PIPELINE_NAME | VARCHAR(16777216) | Name of the data pipeline |
| PIPELINE_RUN_ID | VARCHAR(16777216) | Unique identifier for pipeline execution |
| SOURCE_TABLE | VARCHAR(16777216) | Source table name |
| TARGET_TABLE | VARCHAR(16777216) | Target table name |
| RECORDS_READ | NUMBER(38,0) | Number of records read from source |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records successfully processed |
| RECORDS_REJECTED | NUMBER(38,0) | Number of records rejected due to quality issues |
| RECORDS_INSERTED | NUMBER(38,0) | Number of records inserted into target |
| RECORDS_UPDATED | NUMBER(38,0) | Number of records updated in target |
| PIPELINE_START_TIME | TIMESTAMP_NTZ(9) | Pipeline execution start timestamp |
| PIPELINE_END_TIME | TIMESTAMP_NTZ(9) | Pipeline execution end timestamp |
| EXECUTION_DURATION_SECONDS | NUMBER(38,3) | Total execution time in seconds |
| PIPELINE_STATUS | VARCHAR(50) | Status of pipeline execution (Success, Failed, Warning) |
| ERROR_MESSAGE | VARCHAR(16777216) | Error message if pipeline failed |
| PROCESSED_BY | VARCHAR(16777216) | User or process that executed the pipeline |
| PROCESSING_DATE | DATE | Date when the pipeline was executed |

## 5. Data Type Standardization

### 5.1 Standardized Data Types
| Business Data Type | Silver Layer Data Type | Standardization Rules |
|-------------------|----------------------|----------------------|
| User Names | VARCHAR(16777216) | Trimmed, proper case formatting |
| Email Addresses | VARCHAR(16777216) | Lowercase, validated format |
| Timestamps | TIMESTAMP_NTZ(9) | UTC timezone, consistent format |
| Dates | DATE | YYYY-MM-DD format |
| Amounts | NUMBER(10,2) | Two decimal places for currency |
| Counts | NUMBER(38,0) | Non-negative integers |
| Status Fields | VARCHAR(16777216) | Standardized enumerated values |
| Flags | VARCHAR(50) | Standardized flag values |

### 5.2 Data Validation Rules
1. **Email Validation**: All email addresses must follow standard email format
2. **Date Validation**: End dates must be greater than or equal to start dates
3. **Amount Validation**: All monetary amounts must be non-negative
4. **Count Validation**: All count fields must be non-negative integers
5. **Status Validation**: All status fields must contain valid enumerated values
6. **Timestamp Validation**: All timestamps must be valid and within reasonable ranges

## 6. Conceptual Data Model Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Si_USERS      │────▶│  Si_MEETINGS    │────▶│ Si_PARTICIPANTS │
│                 │     │                 │     │                 │
│ • USER_NAME     │     │ • MEETING_TOPIC │     │ • JOIN_TIME     │
│ • EMAIL         │     │ • START_TIME    │     │ • LEAVE_TIME    │
│ • COMPANY       │     │ • END_TIME      │     │ • LOAD_TS       │
│ • PLAN_TYPE     │     │ • DURATION_MIN  │     │ • UPDATE_TS     │
│ • LOAD_TS       │     │ • LOAD_TS       │     │ • SOURCE_SYS    │
│ • UPDATE_TS     │     │ • UPDATE_TS     │     │ • DATA_QUAL_FLG │
│ • SOURCE_SYS    │     │ • SOURCE_SYS    │     │ • PROCESS_DATE  │
│ • DATA_QUAL_FLG │     │ • DATA_QUAL_FLG │     └─────────────────┘
│ • PROCESS_DATE  │     │ • PROCESS_DATE  │              
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
         │               │ • DATA_QUAL_FLG │              
         │               │ • PROCESS_DATE  │              
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
│ • DATA_QUAL_FLG │ │ • DATA_QUAL_FLG │                 
│ • PROCESS_DATE  │ │ • PROCESS_DATE  │                 
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
│ • DATA_QUAL_FLG │                                      
│ • PROCESS_DATE  │                                      
└─────────────────┘                                      

┌─────────────────┐     ┌─────────────────┐
│Si_DATA_QUALITY_ │     │ Si_PIPELINE_    │
│    ERRORS       │     │    AUDIT        │
│                 │     │                 │
│ • ERROR_ID      │     │ • AUDIT_ID      │
│ • SOURCE_TABLE  │     │ • PIPELINE_NAME │
│ • TARGET_TABLE  │     │ • PIPELINE_RUN  │
│ • ERROR_TYPE    │     │ • SOURCE_TABLE  │
│ • ERROR_DESC    │     │ • TARGET_TABLE  │
│ • ERROR_COLUMN  │     │ • RECORDS_READ  │
│ • ERROR_VALUE   │     │ • RECORDS_PROC  │
│ • ERROR_TS      │     │ • RECORDS_REJ   │
│ • SEVERITY_LVL  │     │ • RECORDS_INS   │
│ • RESOLUTION_ST │     │ • RECORDS_UPD   │
│ • PROCESS_DATE  │     │ • START_TIME    │
└─────────────────┘     │ • END_TIME      │
                        │ • DURATION_SEC  │
                        │ • PIPELINE_STAT │
                        │ • ERROR_MESSAGE │
                        │ • PROCESSED_BY  │
                        │ • PROCESS_DATE  │
                        └─────────────────┘

Connection Key Fields:
• Si_USERS connects to Si_MEETINGS via USER_NAME field
• Si_MEETINGS connects to Si_PARTICIPANTS via MEETING_TOPIC field
• Si_MEETINGS connects to Si_FEATURE_USAGE via MEETING_TOPIC field
• Si_USERS connects to Si_SUPPORT_TICKETS via USER_NAME field
• Si_USERS connects to Si_BILLING_EVENTS via USER_NAME field
• Si_USERS connects to Si_LICENSES via USER_NAME field
• Si_USERS connects to Si_PARTICIPANTS via USER_NAME field
```

## 7. Data Transformation Rules

### 7.1 Data Cleansing Rules
1. **Null Value Handling**: Replace null values with appropriate defaults or flags
2. **Data Type Conversion**: Convert all data types to standardized Silver layer formats
3. **String Standardization**: Trim whitespace, standardize case formatting
4. **Date Standardization**: Convert all dates to consistent YYYY-MM-DD format
5. **Amount Standardization**: Round all monetary amounts to 2 decimal places

### 7.2 Business Rule Implementation
1. **Meeting Duration Calculation**: Ensure duration matches start/end time difference
2. **Status Standardization**: Map all status values to standardized enumerations
3. **Email Validation**: Validate and standardize email address formats
4. **Plan Type Standardization**: Map plan types to standard categories
5. **Feature Name Standardization**: Standardize feature names across all records

## 8. Data Quality Framework

### 8.1 Data Quality Checks
1. **Completeness**: Check for required fields and null values
2. **Validity**: Validate data formats and ranges
3. **Consistency**: Ensure data consistency across related fields
4. **Accuracy**: Verify data accuracy through business rule validation
5. **Uniqueness**: Check for duplicate records where appropriate

### 8.2 Error Handling Process
1. **Error Detection**: Identify data quality issues during transformation
2. **Error Logging**: Log all errors to Si_DATA_QUALITY_ERRORS table
3. **Error Classification**: Classify errors by type and severity
4. **Error Resolution**: Track error resolution status and actions
5. **Error Reporting**: Generate data quality reports for stakeholders

## 9. Pipeline Audit Framework

### 9.1 Audit Data Collection
1. **Pipeline Execution Metrics**: Track records processed, success/failure rates
2. **Performance Metrics**: Monitor execution time and resource utilization
3. **Data Lineage**: Maintain complete data lineage from source to target
4. **Error Tracking**: Log all pipeline errors and exceptions
5. **User Activity**: Track who executed pipelines and when

### 9.2 Audit Reporting
1. **Pipeline Performance Reports**: Daily/weekly pipeline performance summaries
2. **Data Quality Reports**: Regular data quality assessment reports
3. **Error Analysis Reports**: Analysis of common errors and trends
4. **SLA Monitoring**: Track pipeline execution against SLA requirements
5. **Compliance Reports**: Generate reports for regulatory compliance

## 10. Implementation Guidelines

### 10.1 Data Processing Approach
1. **Incremental Processing**: Process only changed records from Bronze layer
2. **Batch Processing**: Process data in manageable batch sizes
3. **Error Recovery**: Implement robust error recovery mechanisms
4. **Data Validation**: Validate all data before loading to Silver layer
5. **Performance Optimization**: Optimize queries and transformations for performance

### 10.2 Monitoring and Alerting
1. **Data Quality Monitoring**: Monitor data quality metrics continuously
2. **Pipeline Monitoring**: Track pipeline execution status and performance
3. **Error Alerting**: Send alerts for critical data quality issues
4. **Performance Alerting**: Alert on pipeline performance degradation
5. **SLA Monitoring**: Monitor and alert on SLA breaches

## 11. Summary

This Silver layer logical data model provides:

1. **Comprehensive Data Structure**: All Bronze layer tables transformed to Silver with standardized naming (Si_ prefix)
2. **Data Quality Enhancement**: Built-in data validation and error handling capabilities
3. **Audit Trail**: Complete pipeline execution audit and data lineage tracking
4. **Business-Ready Data**: Cleaned and standardized data suitable for analytics
5. **Error Management**: Comprehensive error data structure for data quality monitoring
6. **Performance Optimization**: Designed for efficient data processing and querying
7. **Scalability**: Architecture supports growing data volumes and complexity
8. **Compliance**: Framework supports regulatory compliance and data governance

The Silver layer serves as the foundation for downstream Gold layer analytics and reporting, providing clean, validated, and business-ready data for the Zoom Platform Analytics System.