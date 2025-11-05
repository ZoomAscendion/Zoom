_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System supporting raw data ingestion from source to Bronze layer
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Bronze Layer Data Mapping

## 1. Overview

This document provides comprehensive data mapping for the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer serves as the raw data ingestion layer, preserving source data structure while adding essential metadata for data lineage and audit purposes.

## 2. Source to Bronze Layer Data Mapping

### 2.1 USERS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_USERS | USER_ID | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | BZ_USERS | USER_NAME | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | BZ_USERS | EMAIL | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | BZ_USERS | COMPANY | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | BZ_USERS | PLAN_TYPE | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | BZ_USERS | LOAD_TIMESTAMP | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_USERS | UPDATE_TIMESTAMP | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_USERS | SOURCE_SYSTEM | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 2.2 MEETINGS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_MEETINGS | MEETING_ID | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | BZ_MEETINGS | HOST_ID | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | BZ_MEETINGS | MEETING_TOPIC | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | BZ_MEETINGS | START_TIME | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | BZ_MEETINGS | END_TIME | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | BZ_MEETINGS | DURATION_MINUTES | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 2.3 PARTICIPANTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | MEETING_ID | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | USER_ID | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | JOIN_TIME | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | LEAVE_TIME | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 2.4 FEATURE_USAGE Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_FEATURE_USAGE | USAGE_ID | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | MEETING_ID | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 2.5 SUPPORT_TICKETS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | USER_ID | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 2.6 BILLING_EVENTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_BILLING_EVENTS | EVENT_ID | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | USER_ID | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | AMOUNT | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 2.7 LICENSES Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_LICENSES | LICENSE_ID | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | BZ_LICENSES | LICENSE_TYPE | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | BZ_LICENSES | START_DATE | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | BZ_LICENSES | END_DATE | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_LICENSES | SOURCE_SYSTEM | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

## 3. Data Type Mapping

### 3.1 Snowflake Data Type Compatibility

| Source Data Type | Bronze Layer Data Type | Justification |
|------------------|------------------------|---------------|
| VARCHAR(16777216) | STRING | Snowflake STRING type provides maximum flexibility for raw data ingestion |
| NUMBER(38,0) | NUMBER | Direct mapping for integer values |
| NUMBER(10,2) | NUMBER(10,2) | Preserves precision for monetary amounts |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ | Direct mapping for timestamp without timezone |
| DATE | DATE | Direct mapping for date values |

## 4. Data Ingestion Strategy

### 4.1 Raw Data Preservation Principles

1. **No Data Transformation**: All source data is ingested as-is without any cleansing or transformation
2. **Metadata Addition**: Standard metadata columns added for audit and lineage tracking
3. **Schema Flexibility**: Using Snowflake STRING type for maximum flexibility in handling varying data formats
4. **Error Handling**: Failed records are logged but do not stop the ingestion process

### 4.2 Ingestion Metadata

| Metadata Field | Purpose | Population Rule |
|----------------|---------|----------------|
| LOAD_TIMESTAMP | Data lineage tracking | System timestamp when record is first loaded |
| UPDATE_TIMESTAMP | Change tracking | System timestamp when record is modified |
| SOURCE_SYSTEM | Data source identification | Populated from source system identifier |

## 5. Data Validation Rules

### 5.1 Basic Validation Checks

| Validation Type | Description | Action on Failure |
|-----------------|-------------|------------------|
| Schema Validation | Verify column structure matches expected format | Log error, continue processing |
| Data Type Validation | Ensure data types are compatible with target | Log error, attempt type conversion |
| Null Value Check | Identify unexpected null values in required fields | Log warning, continue processing |
| Duplicate Detection | Identify potential duplicate records based on primary keys | Log warning, load all records |

### 5.2 Data Quality Metrics

| Metric | Description | Threshold |
|--------|-------------|----------|
| Load Success Rate | Percentage of successfully loaded records | > 95% |
| Schema Compliance | Percentage of records matching expected schema | > 99% |
| Data Completeness | Percentage of non-null values in key fields | > 90% |

## 6. Implementation Guidelines

### 6.1 Naming Conventions

- **Schema**: BRONZE (following RAW → BRONZE naming convention)
- **Table Prefix**: BZ_ (Bronze layer identifier)
- **Column Names**: Maintain source column names for traceability
- **Metadata Columns**: Standardized across all tables

### 6.2 Performance Considerations

1. **Micro-partitioning**: Leverage Snowflake's automatic micro-partitioning
2. **Clustering**: Consider clustering on date fields for large tables
3. **Compression**: Utilize Snowflake's automatic compression
4. **Incremental Loading**: Use LOAD_TIMESTAMP for incremental processing

### 6.3 Security and Compliance

1. **PII Handling**: Raw PII data preserved with access controls at role level
2. **Audit Trail**: Complete audit trail maintained through metadata columns
3. **Data Retention**: Implement retention policies based on compliance requirements
4. **Access Control**: Role-based access control for sensitive data

## 7. Data Pipeline Architecture

### 7.1 Ingestion Flow

```
Source Systems → Raw Data Files → Snowflake Stage → Bronze Tables → Audit Logging
```

### 7.2 Error Handling Strategy

1. **Validation Errors**: Log and continue processing
2. **System Errors**: Retry with exponential backoff
3. **Data Quality Issues**: Flag for review but continue ingestion
4. **Critical Failures**: Stop processing and alert operations team

## 8. Monitoring and Alerting

### 8.1 Key Metrics to Monitor

- Data ingestion volume and frequency
- Processing time and performance
- Error rates and data quality metrics
- Storage utilization and costs

### 8.2 Alert Conditions

- Load failure rate exceeds threshold
- Processing time exceeds SLA
- Data quality metrics fall below acceptable levels
- Storage costs exceed budget thresholds

## 9. Assumptions and Dependencies

### 9.1 Key Assumptions

1. Source systems provide consistent data formats
2. Network connectivity is reliable for data transfer
3. Snowflake warehouse capacity is adequate for processing volumes
4. Source system metadata is accurate and complete

### 9.2 Dependencies

1. Source system availability and performance
2. Snowflake platform availability and performance
3. Network infrastructure and bandwidth
4. Data pipeline orchestration tools

---

**Document Control:**
- This mapping document serves as the foundation for Bronze layer implementation
- All changes must be versioned and approved through change management process
- Regular reviews should be conducted to ensure alignment with source system changes