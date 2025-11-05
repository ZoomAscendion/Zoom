_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer Data Mapping for Zoom Platform Analytics System from Bronze to Silver layer transformation
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Mapping for Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The mapping incorporates necessary cleansing, validations, and business rules at the attribute level to ensure data quality, consistency, and usability across the organization.

### Key Considerations:
- **Data Quality**: Implementation of 30 comprehensive data quality checks as recommended by the previous agent
- **Business Rules**: Application of platform usage, support, and revenue analysis business rules
- **Referential Integrity**: Maintenance of relationships between entities while ensuring data consistency
- **Snowflake Compatibility**: All transformations and validations are optimized for Snowflake SQL
- **Error Handling**: Comprehensive error tracking and logging mechanisms
- **Audit Trail**: Complete audit capabilities for data governance and compliance

## 2. Data Mapping for the Silver Layer

### 2.1 SI_USERS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_USERS | USER_ID | Bronze | BZ_USERS | USER_ID | Not Null, Unique | Direct mapping with null check |
| Silver | SI_USERS | USER_NAME | Bronze | BZ_USERS | USER_NAME | Not Null, Length > 0, Length <= 100 | TRIM(UPPER(USER_NAME)) - standardized formatting |
| Silver | SI_USERS | EMAIL | Bronze | BZ_USERS | EMAIL | Not Null, Valid Email Format | LOWER(TRIM(EMAIL)) - lowercase standardization |
| Silver | SI_USERS | COMPANY | Bronze | BZ_USERS | COMPANY | Optional | TRIM(COMPANY) - remove leading/trailing spaces |
| Silver | SI_USERS | PLAN_TYPE | Bronze | BZ_USERS | PLAN_TYPE | Must be in ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'EDUCATION') | CASE WHEN UPPER(PLAN_TYPE) IN valid list THEN UPPER(PLAN_TYPE) ELSE 'UNKNOWN' END |
| Silver | SI_USERS | LOAD_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not Null | DATE(LOAD_TIMESTAMP) - extract date component |
| Silver | SI_USERS | UPDATE_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not Null | DATE(UPDATE_TIMESTAMP) - extract date component |
| Silver | SI_USERS | SOURCE_SYSTEM | Bronze | BZ_USERS | SOURCE_SYSTEM | Not Null | Direct mapping |
| Silver | SI_USERS | LOAD_TIMESTAMP | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |
| Silver | SI_USERS | UPDATE_TIMESTAMP | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |

### 2.2 SI_MEETINGS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_MEETINGS | MEETING_ID | Bronze | BZ_MEETINGS | MEETING_ID | Not Null, Unique | Direct mapping with uniqueness validation |
| Silver | SI_MEETINGS | HOST_ID | Bronze | BZ_MEETINGS | HOST_ID | Not Null, Must exist in SI_USERS.USER_ID | Direct mapping with referential integrity check |
| Silver | SI_MEETINGS | MEETING_TOPIC | Bronze | BZ_MEETINGS | MEETING_TOPIC | Optional | TRIM(MEETING_TOPIC) - standardized formatting |
| Silver | SI_MEETINGS | START_TIME | Bronze | BZ_MEETINGS | START_TIME | Not Null, Valid Timestamp | Direct mapping with timestamp validation |
| Silver | SI_MEETINGS | END_TIME | Bronze | BZ_MEETINGS | END_TIME | Not Null, Must be >= START_TIME | Direct mapping with chronological validation |
| Silver | SI_MEETINGS | DURATION_MINUTES | Bronze | BZ_MEETINGS | DURATION_MINUTES | Not Null, >= 0, <= 1440 (24 hours) | COALESCE(DURATION_MINUTES, DATEDIFF('minute', START_TIME, END_TIME)) |
| Silver | SI_MEETINGS | LOAD_DATE | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not Null | DATE(LOAD_TIMESTAMP) - extract date component |
| Silver | SI_MEETINGS | UPDATE_DATE | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not Null | DATE(UPDATE_TIMESTAMP) - extract date component |
| Silver | SI_MEETINGS | SOURCE_SYSTEM | Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Not Null | Direct mapping |
| Silver | SI_MEETINGS | LOAD_TIMESTAMP | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |
| Silver | SI_MEETINGS | UPDATE_TIMESTAMP | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |

### 2.3 SI_PARTICIPANTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PARTICIPANTS | PARTICIPANT_ID | Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Not Null, Unique | Direct mapping with uniqueness validation |
| Silver | SI_PARTICIPANTS | MEETING_ID | Bronze | BZ_PARTICIPANTS | MEETING_ID | Not Null, Must exist in SI_MEETINGS.MEETING_ID | Direct mapping with referential integrity check |
| Silver | SI_PARTICIPANTS | USER_ID | Bronze | BZ_PARTICIPANTS | USER_ID | Optional, If not null must exist in SI_USERS.USER_ID | Direct mapping with optional referential integrity |
| Silver | SI_PARTICIPANTS | JOIN_TIME | Bronze | BZ_PARTICIPANTS | JOIN_TIME | Not Null, Must be >= corresponding meeting START_TIME | Direct mapping with meeting time boundary validation |
| Silver | SI_PARTICIPANTS | LEAVE_TIME | Bronze | BZ_PARTICIPANTS | LEAVE_TIME | Not Null, Must be <= corresponding meeting END_TIME, Must be >= JOIN_TIME | Direct mapping with meeting time boundary and chronological validation |
| Silver | SI_PARTICIPANTS | ATTENDANCE_DURATION | Bronze | BZ_PARTICIPANTS | Calculated | Must be >= 0 | CASE WHEN LEAVE_TIME IS NOT NULL AND JOIN_TIME IS NOT NULL THEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME) ELSE NULL END |
| Silver | SI_PARTICIPANTS | LOAD_DATE | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not Null | DATE(LOAD_TIMESTAMP) - extract date component |
| Silver | SI_PARTICIPANTS | UPDATE_DATE | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not Null | DATE(UPDATE_TIMESTAMP) - extract date component |
| Silver | SI_PARTICIPANTS | SOURCE_SYSTEM | Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Not Null | Direct mapping |
| Silver | SI_PARTICIPANTS | LOAD_TIMESTAMP | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |
| Silver | SI_PARTICIPANTS | UPDATE_TIMESTAMP | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |

### 2.4 SI_FEATURE_USAGE Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_FEATURE_USAGE | USAGE_ID | Bronze | BZ_FEATURE_USAGE | USAGE_ID | Not Null, Unique | Direct mapping with uniqueness validation |
| Silver | SI_FEATURE_USAGE | MEETING_ID | Bronze | BZ_FEATURE_USAGE | MEETING_ID | Not Null, Must exist in SI_MEETINGS.MEETING_ID | Direct mapping with referential integrity check |
| Silver | SI_FEATURE_USAGE | FEATURE_NAME | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Not Null, Must be in ('SCREEN_SHARE', 'CHAT', 'RECORDING', 'BREAKOUT_ROOMS', 'WHITEBOARD') | UPPER(TRIM(FEATURE_NAME)) - standardized feature names |
| Silver | SI_FEATURE_USAGE | USAGE_COUNT | Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | Not Null, >= 0 | Direct mapping with non-negative validation |
| Silver | SI_FEATURE_USAGE | USAGE_DATE | Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Not Null, >= '2020-01-01', <= CURRENT_DATE + 1 | Direct mapping with reasonable date range validation |
| Silver | SI_FEATURE_USAGE | LOAD_DATE | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not Null | DATE(LOAD_TIMESTAMP) - extract date component |
| Silver | SI_FEATURE_USAGE | UPDATE_DATE | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not Null | DATE(UPDATE_TIMESTAMP) - extract date component |
| Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Not Null | Direct mapping |
| Silver | SI_FEATURE_USAGE | LOAD_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |
| Silver | SI_FEATURE_USAGE | UPDATE_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |

### 2.5 SI_SUPPORT_TICKETS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_SUPPORT_TICKETS | TICKET_ID | Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Not Null, Unique | Direct mapping with uniqueness validation |
| Silver | SI_SUPPORT_TICKETS | USER_ID | Bronze | BZ_SUPPORT_TICKETS | USER_ID | Not Null, Must exist in SI_USERS.USER_ID | Direct mapping with referential integrity check |
| Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Not Null, Must be in ('TECHNICAL', 'BILLING', 'FEATURE_REQUEST', 'ACCOUNT', 'GENERAL') | UPPER(TRIM(TICKET_TYPE)) - standardized ticket types |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Not Null, Must be in ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED') | UPPER(TRIM(RESOLUTION_STATUS)) - standardized status values |
| Silver | SI_SUPPORT_TICKETS | OPEN_DATE | Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Not Null, >= '2020-01-01', <= CURRENT_DATE | Direct mapping with reasonable date range validation |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_TIME_HOURS | Bronze | BZ_SUPPORT_TICKETS | Calculated | Must be > 0 for RESOLVED/CLOSED tickets, NULL for others | CASE WHEN RESOLUTION_STATUS IN ('RESOLVED', 'CLOSED') THEN calculated_hours ELSE NULL END |
| Silver | SI_SUPPORT_TICKETS | LOAD_DATE | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not Null | DATE(LOAD_TIMESTAMP) - extract date component |
| Silver | SI_SUPPORT_TICKETS | UPDATE_DATE | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not Null | DATE(UPDATE_TIMESTAMP) - extract date component |
| Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Not Null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | LOAD_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |
| Silver | SI_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |

### 2.6 SI_BILLING_EVENTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_BILLING_EVENTS | EVENT_ID | Bronze | BZ_BILLING_EVENTS | EVENT_ID | Not Null, Unique | Direct mapping with uniqueness validation |
| Silver | SI_BILLING_EVENTS | USER_ID | Bronze | BZ_BILLING_EVENTS | USER_ID | Not Null, Must exist in SI_USERS.USER_ID | Direct mapping with referential integrity check |
| Silver | SI_BILLING_EVENTS | EVENT_TYPE | Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Not Null, Must be in ('SUBSCRIPTION', 'UPGRADE', 'DOWNGRADE', 'REFUND', 'CHARGEBACK', 'PAYMENT') | UPPER(TRIM(EVENT_TYPE)) - standardized event types |
| Silver | SI_BILLING_EVENTS | AMOUNT | Bronze | BZ_BILLING_EVENTS | AMOUNT | Not Null, > 0 | Direct mapping with positive amount validation |
| Silver | SI_BILLING_EVENTS | EVENT_DATE | Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Not Null, >= '2020-01-01', <= CURRENT_DATE + 30 | Direct mapping with reasonable business date range |
| Silver | SI_BILLING_EVENTS | CURRENCY_CODE | Bronze | BZ_BILLING_EVENTS | Calculated | Default 'USD' | COALESCE(source_currency, 'USD') - default currency assignment |
| Silver | SI_BILLING_EVENTS | LOAD_DATE | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not Null | DATE(LOAD_TIMESTAMP) - extract date component |
| Silver | SI_BILLING_EVENTS | UPDATE_DATE | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not Null | DATE(UPDATE_TIMESTAMP) - extract date component |
| Silver | SI_BILLING_EVENTS | SOURCE_SYSTEM | Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Not Null | Direct mapping |
| Silver | SI_BILLING_EVENTS | LOAD_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |
| Silver | SI_BILLING_EVENTS | UPDATE_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |

### 2.7 SI_LICENSES Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_LICENSES | LICENSE_ID | Bronze | BZ_LICENSES | LICENSE_ID | Not Null, Unique | Direct mapping with uniqueness validation |
| Silver | SI_LICENSES | LICENSE_TYPE | Bronze | BZ_LICENSES | LICENSE_TYPE | Not Null | UPPER(TRIM(LICENSE_TYPE)) - standardized license types |
| Silver | SI_LICENSES | ASSIGNED_TO_USER_ID | Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Optional, If not null must exist in SI_USERS.USER_ID | Direct mapping with optional referential integrity |
| Silver | SI_LICENSES | START_DATE | Bronze | BZ_LICENSES | START_DATE | Not Null, Must be < END_DATE | Direct mapping with date consistency validation |
| Silver | SI_LICENSES | END_DATE | Bronze | BZ_LICENSES | END_DATE | Not Null, Must be > START_DATE | Direct mapping with date consistency validation |
| Silver | SI_LICENSES | LICENSE_STATUS | Bronze | BZ_LICENSES | Calculated | Must be in ('EXPIRED', 'EXPIRING_SOON', 'FUTURE', 'ACTIVE') | CASE WHEN END_DATE < CURRENT_DATE THEN 'EXPIRED' WHEN END_DATE <= DATEADD('day', 30, CURRENT_DATE) THEN 'EXPIRING_SOON' WHEN START_DATE > CURRENT_DATE THEN 'FUTURE' ELSE 'ACTIVE' END |
| Silver | SI_LICENSES | DAYS_TO_EXPIRY | Bronze | BZ_LICENSES | Calculated | Must be >= 0 for active licenses | CASE WHEN END_DATE >= CURRENT_DATE THEN DATEDIFF('day', CURRENT_DATE, END_DATE) ELSE 0 END |
| Silver | SI_LICENSES | LOAD_DATE | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not Null | DATE(LOAD_TIMESTAMP) - extract date component |
| Silver | SI_LICENSES | UPDATE_DATE | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not Null | DATE(UPDATE_TIMESTAMP) - extract date component |
| Silver | SI_LICENSES | SOURCE_SYSTEM | Bronze | BZ_LICENSES | SOURCE_SYSTEM | Not Null | Direct mapping |
| Silver | SI_LICENSES | LOAD_TIMESTAMP | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |
| Silver | SI_LICENSES | UPDATE_TIMESTAMP | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not Null | Direct mapping - preserve original timestamp |

### 2.8 SI_DATA_QUALITY_ERRORS Table Mapping (Error Data Table)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_ID | Silver | Generated | UUID | Not Null, Unique | UUID() - system generated unique identifier |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_TABLE | Silver | Processing | Table Name | Not Null | Source table name where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_RECORD_ID | Silver | Processing | Record ID | Not Null | Primary key of source record with error |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TYPE | Silver | Processing | Error Category | Not Null, Must be in ('VALIDATION', 'TRANSFORMATION', 'REFERENTIAL_INTEGRITY', 'BUSINESS_RULE') | Categorized error type |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_COLUMN | Silver | Processing | Column Name | Not Null | Column name where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_VALUE | Silver | Processing | Actual Value | Optional | Actual value that caused the error |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_DESCRIPTION | Silver | Processing | Description | Not Null | Detailed error description |
| Silver | SI_DATA_QUALITY_ERRORS | VALIDATION_RULE | Silver | Processing | Rule Name | Not Null | Validation rule that was violated |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_SEVERITY | Silver | Processing | Severity Level | Not Null, Must be in ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') | Business impact classification |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TIMESTAMP | Silver | Processing | Current Time | Not Null | CURRENT_TIMESTAMP() - when error was detected |
| Silver | SI_DATA_QUALITY_ERRORS | PROCESSING_BATCH_ID | Silver | Processing | Batch ID | Not Null | ETL batch identifier for tracking |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_STATUS | Silver | Processing | Status | Not Null, Must be in ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'IGNORED') | Error resolution tracking |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_NOTES | Silver | Processing | Notes | Optional | Resolution details and notes |
| Silver | SI_DATA_QUALITY_ERRORS | LOAD_DATE | Silver | Processing | Current Date | Not Null | CURRENT_DATE - error detection date |
| Silver | SI_DATA_QUALITY_ERRORS | UPDATE_DATE | Silver | Processing | Current Date | Not Null | CURRENT_DATE - last update date |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_SYSTEM | Silver | Processing | System Name | Not Null | 'SILVER_ETL_PROCESS' - processing system identifier |

### 2.9 SI_PIPELINE_AUDIT Table Mapping (Audit Table)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PIPELINE_AUDIT | AUDIT_ID | Silver | Generated | UUID | Not Null, Unique | UUID() - system generated unique identifier |
| Silver | SI_PIPELINE_AUDIT | PIPELINE_NAME | Silver | Processing | Pipeline Name | Not Null | ETL pipeline name identifier |
| Silver | SI_PIPELINE_AUDIT | PIPELINE_RUN_ID | Silver | Processing | Run ID | Not Null | Unique run identifier for each execution |
| Silver | SI_PIPELINE_AUDIT | SOURCE_TABLE | Silver | Processing | Source Table | Not Null | Bronze layer source table name |
| Silver | SI_PIPELINE_AUDIT | TARGET_TABLE | Silver | Processing | Target Table | Not Null | Silver layer target table name |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_START_TIME | Silver | Processing | Start Time | Not Null | Pipeline execution start timestamp |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_END_TIME | Silver | Processing | End Time | Not Null, Must be >= EXECUTION_START_TIME | Pipeline execution end timestamp |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_DURATION_SECONDS | Silver | Processing | Calculated | Must be >= 0 | DATEDIFF('second', EXECUTION_START_TIME, EXECUTION_END_TIME) |
| Silver | SI_PIPELINE_AUDIT | RECORDS_READ | Silver | Processing | Count | Must be >= 0 | Count of records read from source |
| Silver | SI_PIPELINE_AUDIT | RECORDS_PROCESSED | Silver | Processing | Count | Must be >= 0, <= RECORDS_READ | Count of records successfully processed |
| Silver | SI_PIPELINE_AUDIT | RECORDS_INSERTED | Silver | Processing | Count | Must be >= 0 | Count of new records inserted |
| Silver | SI_PIPELINE_AUDIT | RECORDS_UPDATED | Silver | Processing | Count | Must be >= 0 | Count of existing records updated |
| Silver | SI_PIPELINE_AUDIT | RECORDS_REJECTED | Silver | Processing | Count | Must be >= 0 | Count of records rejected due to errors |
| Silver | SI_PIPELINE_AUDIT | ERROR_COUNT | Silver | Processing | Count | Must be >= 0 | Total number of errors encountered |
| Silver | SI_PIPELINE_AUDIT | WARNING_COUNT | Silver | Processing | Count | Must be >= 0 | Total number of warnings generated |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_STATUS | Silver | Processing | Status | Not Null, Must be in ('SUCCESS', 'FAILED', 'PARTIAL_SUCCESS', 'CANCELLED') | Pipeline execution outcome |
| Silver | SI_PIPELINE_AUDIT | ERROR_MESSAGE | Silver | Processing | Message | Optional | Detailed error message if execution failed |
| Silver | SI_PIPELINE_AUDIT | PROCESSED_BY | Silver | Processing | User/System | Not Null | User or system that executed the pipeline |
| Silver | SI_PIPELINE_AUDIT | PROCESSING_MODE | Silver | Processing | Mode | Not Null, Must be in ('FULL_LOAD', 'INCREMENTAL', 'DELTA') | Type of processing performed |
| Silver | SI_PIPELINE_AUDIT | DATA_FRESHNESS_TIMESTAMP | Silver | Processing | Timestamp | Not Null | Latest timestamp of processed data |
| Silver | SI_PIPELINE_AUDIT | RESOURCE_UTILIZATION | Silver | Processing | Metrics | Optional | JSON string with resource usage metrics |
| Silver | SI_PIPELINE_AUDIT | LOAD_DATE | Silver | Processing | Current Date | Not Null | CURRENT_DATE - audit record creation date |
| Silver | SI_PIPELINE_AUDIT | UPDATE_DATE | Silver | Processing | Current Date | Not Null | CURRENT_DATE - last update date |
| Silver | SI_PIPELINE_AUDIT | SOURCE_SYSTEM | Silver | Processing | System Name | Not Null | 'SILVER_ETL_PROCESS' - processing system identifier |

## 3. Implementation Notes

### 3.1 Data Quality Integration
The mapping incorporates all 30 data quality checks recommended by the previous agent:

1. **User Data Completeness and Validity Checks** (Checks 1-4)
2. **Meeting Data Integrity Checks** (Checks 5-8)
3. **Participant Data Validation Checks** (Checks 9-11)
4. **Feature Usage Data Quality Checks** (Checks 12-14)
5. **Support Ticket Data Validation Checks** (Checks 15-17)
6. **Billing and Financial Data Checks** (Checks 18-20)
7. **License Management Data Quality Checks** (Checks 21-23)
8. **Cross-Table Referential Integrity Checks** (Checks 24-25)
9. **Data Freshness and Completeness Checks** (Checks 26-27)
10. **Business Rule Compliance Checks** (Checks 28-30)

### 3.2 Error Handling and Logging Mechanisms

#### 3.2.1 Error Classification
- **CRITICAL**: Data integrity violations, referential integrity failures
- **HIGH**: Business rule violations, invalid data formats
- **MEDIUM**: Data quality issues that don't prevent processing
- **LOW**: Minor formatting or standardization issues

#### 3.2.2 Error Resolution Workflow
1. **Detection**: Automated validation during ETL process
2. **Logging**: All errors logged to SI_DATA_QUALITY_ERRORS table
3. **Notification**: Real-time alerts for CRITICAL and HIGH severity errors
4. **Resolution**: Manual or automated remediation based on error type
5. **Tracking**: Complete audit trail of resolution activities

#### 3.2.3 Audit Capabilities
- **Pipeline Monitoring**: Complete execution tracking in SI_PIPELINE_AUDIT
- **Performance Metrics**: Execution duration, throughput, resource utilization
- **Data Lineage**: Source-to-target mapping with transformation details
- **Compliance Reporting**: Automated generation of data governance reports

### 3.3 Business Rule Implementation

#### 3.3.1 Platform Usage & Adoption Rules
- Active user definition: Users who hosted at least one meeting
- Meeting categorization: Exclude meetings < 1 minute (test meetings)
- Feature adoption tracking: Standardized feature names and usage patterns

#### 3.3.2 Service Reliability & Support Rules
- Ticket classification: Predefined taxonomy enforcement
- Resolution time calculation: Business hours only, excluding weekends/holidays
- Priority assignment: Based on plan type and business impact

#### 3.3.3 Revenue and License Analysis Rules
- MRR calculation: Subscription-based recurring revenue only
- License utilization: Based on active user assignments
- Revenue recognition: Service delivery month attribution

### 3.4 Performance Optimization

#### 3.4.1 Incremental Processing
- Use LOAD_TIMESTAMP and UPDATE_TIMESTAMP for delta identification
- Implement change data capture (CDC) patterns where applicable
- Optimize for Snowflake's micro-partitioning capabilities

#### 3.4.2 Parallel Processing
- Independent table processing for improved throughput
- Batch processing optimization for large datasets
- Resource allocation based on data volume and complexity

#### 3.4.3 Query Optimization
- Clustering keys on frequently queried columns
- Proper indexing strategies for join operations
- Query result caching for repeated access patterns

### 3.5 Security and Compliance

#### 3.5.1 Data Privacy
- PII handling according to privacy regulations
- Data masking for non-production environments
- Access control based on role-based permissions

#### 3.5.2 Audit and Governance
- Complete data lineage tracking
- Automated compliance reporting
- Regular data quality assessments
- Change management documentation

## 4. Recommendations

### 4.1 Monitoring and Alerting
1. **Real-time Monitoring**: Implement dashboard for pipeline execution status
2. **Automated Alerts**: Configure notifications for data quality threshold breaches
3. **Performance Tracking**: Monitor execution times and resource utilization
4. **Data Freshness**: Alert on delayed or missing data loads

### 4.2 Continuous Improvement
1. **Regular Review**: Quarterly assessment of validation rules and thresholds
2. **Business Rule Updates**: Incorporate changing business requirements
3. **Performance Optimization**: Continuous tuning based on usage patterns
4. **Error Pattern Analysis**: Identify and address recurring data quality issues

### 4.3 Scalability Considerations
1. **Volume Growth**: Design for increasing data volumes and velocity
2. **Schema Evolution**: Support for new fields and table structures
3. **Integration Expansion**: Accommodate additional data sources
4. **Technology Upgrades**: Plan for Snowflake feature enhancements

This comprehensive Silver layer data mapping ensures robust data quality, maintains business rule compliance, and provides the foundation for reliable analytics and reporting in the Zoom Platform Analytics System.