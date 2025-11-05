_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System supporting raw data ingestion from RAW schema to BRONZE schema
## *Version*: 2 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Bronze Layer Data Mapping

## 1. Overview

This document provides comprehensive data mapping for the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer serves as the raw data ingestion layer, preserving source data structure while adding essential metadata for data lineage and audit purposes. This mapping aligns with the RAW schema structure and follows the naming convention where RAW schema maps to BRONZE schema.

## 2. Schema Naming Convention

- **Source Schema**: RAW
- **Target Schema**: BRONZE
- **Table Prefix**: BZ_ (Bronze layer identifier)
- **Naming Pattern**: RAW.{TABLE_NAME} → BRONZE.BZ_{TABLE_NAME}

## 3. Source to Bronze Layer Data Mapping

### 3.1 USERS Table Mapping

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

### 3.2 MEETINGS Table Mapping

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

### 3.3 PARTICIPANTS Table Mapping

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

### 3.4 FEATURE_USAGE Table Mapping

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

### 3.5 SUPPORT_TICKETS Table Mapping

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

### 3.6 BILLING_EVENTS Table Mapping

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

### 3.7 LICENSES Table Mapping

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

## 4. Data Type Mapping and Compatibility

### 4.1 Snowflake Data Type Mapping

| Source Data Type | Bronze Layer Data Type | Justification | Compatibility Notes |
|------------------|------------------------|---------------|--------------------|
| VARCHAR(16777216) | STRING | Snowflake STRING type provides maximum flexibility for raw data ingestion | Direct compatibility, no conversion needed |
| NUMBER(38,0) | NUMBER | Direct mapping for integer values | Preserves precision and scale |
| NUMBER(10,2) | NUMBER(10,2) | Preserves precision for monetary amounts | Exact precision match for financial data |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ | Direct mapping for timestamp without timezone | Maintains nanosecond precision |
| DATE | DATE | Direct mapping for date values | No conversion required |

### 4.2 Domain Value Preservation

| Table | Field | Domain Values | Preservation Strategy |
|-------|-------|---------------|----------------------|
| USERS | PLAN_TYPE | Basic, Pro, Business, Enterprise, Education | Preserve as-is, validate in Silver layer |
| BILLING_EVENTS | EVENT_TYPE | charge, credit, refund, adjustment | Preserve as-is, validate in Silver layer |
| FEATURE_USAGE | FEATURE_NAME | screen_share, recording, chat, breakout_rooms, whiteboard | Preserve as-is, validate in Silver layer |
| SUPPORT_TICKETS | TICKET_TYPE | technical_issue, billing_inquiry, feature_request, account_access | Preserve as-is, validate in Silver layer |
| SUPPORT_TICKETS | RESOLUTION_STATUS | open, in_progress, resolved, closed, escalated | Preserve as-is, validate in Silver layer |
| LICENSES | LICENSE_TYPE | Basic, Pro, Business, Enterprise, Education | Preserve as-is, validate in Silver layer |

## 5. Data Ingestion Strategy

### 5.1 Raw Data Preservation Principles

1. **No Data Transformation**: All source data is ingested as-is without any cleansing or transformation
2. **Metadata Preservation**: All source metadata columns are preserved exactly as received
3. **Schema Flexibility**: Using Snowflake STRING type for maximum flexibility in handling varying data formats
4. **Error Handling**: Failed records are logged but do not stop the ingestion process
5. **Audit Trail**: Complete lineage from RAW to BRONZE layer maintained

### 5.2 Ingestion Metadata Strategy

| Metadata Field | Source | Purpose | Population Rule |
|----------------|--------|---------|----------------|
| LOAD_TIMESTAMP | Source System | Data lineage tracking | Preserve original timestamp from source |
| UPDATE_TIMESTAMP | Source System | Change tracking | Preserve original timestamp from source |
| SOURCE_SYSTEM | Source System | Data source identification | Preserve original source identifier |

## 6. Data Validation Rules for Bronze Layer

### 6.1 Minimal Validation Checks

| Validation Type | Description | Action on Failure | Bronze Layer Approach |
|-----------------|-------------|-------------------|----------------------|
| Schema Validation | Verify column structure matches expected format | Log error, continue processing | Preserve raw structure, flag discrepancies |
| Data Type Validation | Ensure data types are compatible with target | Log error, attempt type conversion | Use flexible STRING types where possible |
| Null Value Check | Identify unexpected null values | Log warning, continue processing | Preserve nulls as-is, document in audit |
| Duplicate Detection | Identify potential duplicate records | Log warning, load all records | Load all records, handle in Silver layer |

### 6.2 Data Quality Metrics (Monitoring Only)

| Metric | Description | Threshold | Action |
|--------|-------------|-----------|--------|
| Load Success Rate | Percentage of successfully loaded records | > 95% | Monitor and alert only |
| Schema Compliance | Percentage of records matching expected schema | > 99% | Monitor and alert only |
| Data Completeness | Percentage of non-null values in key fields | > 90% | Monitor and alert only |
| Source System Connectivity | Availability of source systems | > 99% | Monitor and alert only |

## 7. Implementation Guidelines

### 7.1 Naming Conventions

- **Database**: DB_POC_ZOOM (as per source configuration)
- **Source Schema**: RAW
- **Target Schema**: BRONZE
- **Table Prefix**: BZ_ (Bronze layer identifier)
- **Column Names**: Maintain exact source column names for traceability
- **Metadata Columns**: Standardized across all tables

### 7.2 Performance Considerations

1. **Micro-partitioning**: Leverage Snowflake's automatic micro-partitioning on LOAD_TIMESTAMP
2. **Clustering**: Consider clustering on frequently queried date fields
3. **Compression**: Utilize Snowflake's automatic compression for STRING fields
4. **Incremental Loading**: Use LOAD_TIMESTAMP and UPDATE_TIMESTAMP for incremental processing
5. **Parallel Processing**: Leverage Snowflake's parallel processing capabilities

### 7.3 Security and Compliance

1. **PII Handling**: Raw PII data preserved with access controls at role level
2. **Audit Trail**: Complete audit trail maintained through preserved metadata columns
3. **Data Retention**: Implement retention policies based on compliance requirements
4. **Access Control**: Role-based access control using FR__POC__ADMIN__ZOOM role
5. **Encryption**: Leverage Snowflake's automatic encryption at rest and in transit

## 8. Data Pipeline Architecture

### 8.1 Ingestion Flow

```
RAW Schema Tables → Data Validation → BRONZE Schema Tables → Audit Logging → Silver Layer Ready
```

### 8.2 Processing Steps

1. **Extract**: Read data from RAW schema tables
2. **Validate**: Perform minimal validation checks
3. **Load**: Insert data into BRONZE schema tables with BZ_ prefix
4. **Audit**: Log processing metrics and data quality statistics
5. **Monitor**: Track performance and data quality metrics

### 8.3 Error Handling Strategy

1. **Validation Errors**: Log detailed error information, continue processing
2. **System Errors**: Implement retry logic with exponential backoff
3. **Data Quality Issues**: Flag for review but continue ingestion to preserve raw data
4. **Critical Failures**: Stop processing and alert operations team immediately

## 9. Monitoring and Alerting

### 9.1 Key Metrics to Monitor

- **Data Volume**: Number of records processed per table per batch
- **Processing Time**: Time taken for each table ingestion
- **Error Rates**: Percentage of records with validation errors
- **Data Quality**: Completeness and consistency metrics
- **Storage Utilization**: Bronze layer storage consumption
- **Performance**: Query performance and warehouse utilization

### 9.2 Alert Conditions

- Load failure rate exceeds 5%
- Processing time exceeds defined SLA (to be determined based on volume)
- Data quality metrics fall below 90% threshold
- Storage costs exceed budget thresholds
- Source system connectivity issues

## 10. Data Lineage and Traceability

### 10.1 Lineage Tracking

| Level | Component | Tracking Method | Purpose |
|-------|-----------|-----------------|----------|
| Table Level | RAW → BRONZE | Table mapping documentation | Schema evolution tracking |
| Column Level | Field-by-field mapping | 1-1 mapping tables | Data transformation tracking |
| Record Level | LOAD_TIMESTAMP preservation | Metadata columns | Individual record lineage |
| Batch Level | Processing logs | Audit table entries | Batch processing tracking |

### 10.2 Audit Trail Components

1. **Source Metadata**: Preserved from RAW layer
2. **Processing Metadata**: Added during Bronze ingestion
3. **Quality Metrics**: Data validation results
4. **Performance Metrics**: Processing time and resource utilization

## 11. Assumptions and Dependencies

### 11.1 Key Assumptions

1. **Source Schema Stability**: RAW schema structure remains consistent
2. **Data Format Consistency**: Source systems provide data in expected formats
3. **Network Reliability**: Stable connectivity between RAW and BRONZE layers
4. **Resource Availability**: Adequate Snowflake warehouse capacity (WH_POC_ZOOM_DEV_XSMALL)
5. **Access Permissions**: FR__POC__ADMIN__ZOOM role has necessary permissions

### 11.2 Dependencies

1. **RAW Layer Availability**: Bronze processing depends on RAW layer data availability
2. **Snowflake Platform**: Platform availability and performance
3. **Database Infrastructure**: DB_POC_ZOOM database accessibility
4. **Security Framework**: Role-based access control implementation
5. **Monitoring Tools**: Availability of monitoring and alerting infrastructure

## 12. Future Considerations

### 12.1 Schema Evolution

- **Backward Compatibility**: Maintain compatibility with existing Silver layer processes
- **New Fields**: Strategy for handling new fields added to source tables
- **Data Type Changes**: Approach for handling source data type modifications
- **Table Additions**: Process for adding new tables to the Bronze layer

### 12.2 Performance Optimization

- **Clustering Strategy**: Implement clustering keys based on query patterns
- **Partitioning**: Consider manual partitioning for very large tables
- **Compression**: Optimize compression settings for different data types
- **Caching**: Implement result caching for frequently accessed data

---

**Document Control:**
- Version 2 incorporates alignment with RAW schema structure and naming conventions
- All changes must be versioned and approved through change management process
- Regular reviews should be conducted to ensure alignment with source system changes
- This mapping serves as the foundation for automated Bronze layer data pipeline implementation