_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping - Zoom Platform Analytics System

## 1. Overview

This document provides comprehensive data mapping for the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer serves as the raw data ingestion layer, preserving the original structure and content of source data while adding essential metadata for data lineage and governance.

## 2. Schema Mapping Convention

- **Source Schema**: RAW
- **Target Schema**: BRONZE
- **Mapping Type**: 1-1 Direct mapping with metadata enhancement
- **Data Preservation**: Complete preservation of source data structure and content

## 3. Bronze Layer Data Mapping Tables

### 3.1 Table: USERS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | USERS | USER_ID | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | USERS | USER_NAME | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | USERS | EMAIL | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | USERS | COMPANY | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | USERS | PLAN_TYPE | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | USERS | LOAD_TIMESTAMP | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | USERS | UPDATE_TIMESTAMP | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | USERS | SOURCE_SYSTEM | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 3.2 Table: MEETINGS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | MEETINGS | MEETING_ID | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | MEETINGS | HOST_ID | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | MEETINGS | MEETING_TOPIC | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | MEETINGS | START_TIME | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | MEETINGS | END_TIME | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | MEETINGS | DURATION_MINUTES | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | MEETINGS | LOAD_TIMESTAMP | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | MEETINGS | UPDATE_TIMESTAMP | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | MEETINGS | SOURCE_SYSTEM | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 3.3 Table: PARTICIPANTS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | PARTICIPANTS | PARTICIPANT_ID | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | PARTICIPANTS | MEETING_ID | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | PARTICIPANTS | USER_ID | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | PARTICIPANTS | JOIN_TIME | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | PARTICIPANTS | LEAVE_TIME | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | PARTICIPANTS | LOAD_TIMESTAMP | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | PARTICIPANTS | UPDATE_TIMESTAMP | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | PARTICIPANTS | SOURCE_SYSTEM | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 3.4 Table: FEATURE_USAGE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | FEATURE_USAGE | USAGE_ID | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | FEATURE_USAGE | MEETING_ID | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | FEATURE_USAGE | FEATURE_NAME | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | FEATURE_USAGE | USAGE_COUNT | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | FEATURE_USAGE | USAGE_DATE | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | FEATURE_USAGE | LOAD_TIMESTAMP | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | FEATURE_USAGE | UPDATE_TIMESTAMP | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | FEATURE_USAGE | SOURCE_SYSTEM | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 3.5 Table: SUPPORT_TICKETS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | SUPPORT_TICKETS | TICKET_ID | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | SUPPORT_TICKETS | USER_ID | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | SUPPORT_TICKETS | TICKET_TYPE | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | SUPPORT_TICKETS | RESOLUTION_STATUS | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | SUPPORT_TICKETS | OPEN_DATE | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | SUPPORT_TICKETS | LOAD_TIMESTAMP | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | SUPPORT_TICKETS | UPDATE_TIMESTAMP | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | SUPPORT_TICKETS | SOURCE_SYSTEM | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 3.6 Table: BILLING_EVENTS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BILLING_EVENTS | EVENT_ID | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | BILLING_EVENTS | USER_ID | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | BILLING_EVENTS | EVENT_TYPE | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | BILLING_EVENTS | AMOUNT | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | BILLING_EVENTS | EVENT_DATE | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | BILLING_EVENTS | LOAD_TIMESTAMP | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BILLING_EVENTS | UPDATE_TIMESTAMP | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BILLING_EVENTS | SOURCE_SYSTEM | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 3.7 Table: LICENSES

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | LICENSES | LICENSE_ID | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | LICENSES | LICENSE_TYPE | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | LICENSES | ASSIGNED_TO_USER_ID | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | LICENSES | START_DATE | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | LICENSES | END_DATE | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | LICENSES | LOAD_TIMESTAMP | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | LICENSES | UPDATE_TIMESTAMP | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | LICENSES | SOURCE_SYSTEM | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

## 4. Data Ingestion Specifications

### 4.1 Data Type Compatibility

| Source Data Type | Bronze Data Type | Snowflake Compatibility | Notes |
|------------------|------------------|-------------------------|-------|
| VARCHAR(16777216) | VARCHAR(16777216) | Native Support | Maximum string length in Snowflake |
| NUMBER(38,0) | NUMBER(38,0) | Native Support | Integer with maximum precision |
| NUMBER(10,2) | NUMBER(10,2) | Native Support | Decimal with 2 decimal places |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ(9) | Native Support | Timestamp without timezone |
| DATE | DATE | Native Support | Date only format |

### 4.2 Data Loading Strategy

- **Loading Method**: COPY INTO commands for bulk data ingestion
- **File Format**: Parquet, JSON, or CSV depending on source system
- **Error Handling**: ON_ERROR = 'CONTINUE' to skip malformed records
- **Validation**: Minimal validation at Bronze layer - preserve raw data integrity

### 4.3 Metadata Management

- **LOAD_TIMESTAMP**: Automatically populated during data ingestion
- **UPDATE_TIMESTAMP**: Updated when records are modified
- **SOURCE_SYSTEM**: Identifies the originating system for data lineage

## 5. Data Governance and Quality

### 5.1 PII Data Handling

| Field Name | PII Classification | Handling Requirements |
|------------|-------------------|----------------------|
| USER_NAME | Sensitive PII | Requires masking policies in higher environments |
| EMAIL | Sensitive PII | Requires masking policies in higher environments |
| COMPANY | Non-Sensitive PII | Standard data governance applies |
| MEETING_TOPIC | Potentially Sensitive | Content-based classification required |

### 5.2 Data Retention

- **Bronze Layer Retention**: 7 years for compliance requirements
- **Time Travel**: Snowflake default 1 day for data recovery
- **Fail-safe**: Snowflake default 7 days for disaster recovery

### 5.3 Data Lineage Tracking

- **SOURCE_SYSTEM**: Tracks origin of each record
- **LOAD_TIMESTAMP**: Tracks when data entered Bronze layer
- **UPDATE_TIMESTAMP**: Tracks data modification history

## 6. Initial Data Validation Rules

### 6.1 Mandatory Field Validation

- **Primary Keys**: Must not be NULL (USER_ID, MEETING_ID, etc.)
- **Timestamps**: LOAD_TIMESTAMP must be populated for all records
- **Source System**: SOURCE_SYSTEM must be populated for data lineage

### 6.2 Data Format Validation

- **Email Format**: Basic format validation for EMAIL fields
- **Date Ranges**: Ensure dates are within reasonable business ranges
- **Numeric Values**: Ensure AMOUNT and COUNT fields are non-negative where applicable

### 6.3 Referential Integrity (Informational Only)

- **Foreign Key Relationships**: Documented but not enforced in Bronze layer
- **Cross-Table Dependencies**: Identified for Silver layer processing
- **Data Consistency**: Monitored through data quality metrics

## 7. Implementation Notes

### 7.1 Snowflake Specific Considerations

- **Clustering**: No clustering keys defined at Bronze layer
- **Partitioning**: Leverages Snowflake's automatic micro-partitioning
- **Compression**: Automatic compression applied by Snowflake
- **Security**: Row-level security and column masking to be implemented

### 7.2 Performance Optimization

- **Bulk Loading**: Use COPY INTO for efficient data ingestion
- **Parallel Processing**: Leverage Snowflake's automatic parallelization
- **Resource Management**: Use appropriate warehouse sizing for data loads

### 7.3 Monitoring and Alerting

- **Load Monitoring**: Track data ingestion success/failure rates
- **Data Volume Monitoring**: Monitor daily data volumes for anomalies
- **Quality Metrics**: Track data quality scores and trends

## 8. Assumptions and Dependencies

### 8.1 Source System Assumptions

- Source systems provide data in consistent formats
- Source system timestamps are in UTC or clearly documented timezone
- Source systems maintain referential integrity in their data

### 8.2 Infrastructure Dependencies

- Snowflake warehouse availability for data processing
- Network connectivity to source systems
- Appropriate IAM roles and permissions configured

### 8.3 Data Processing Assumptions

- Bronze layer processes raw data without business transformations
- Data cleansing and business rules applied in Silver layer
- Historical data backfill requirements are documented separately

---

**Document Status**: Active  
**Next Review Date**: Quarterly  
**Approval Required**: Data Architecture Team