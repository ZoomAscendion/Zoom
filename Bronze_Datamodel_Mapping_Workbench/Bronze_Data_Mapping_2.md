_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive Bronze layer data mapping for Zoom Platform Analytics System in Medallion architecture
## *Version*: 2 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping for Zoom Platform Analytics System

## Overview
This document provides a comprehensive data mapping between the source RAW layer and the Bronze layer in the Medallion architecture implementation for Snowflake. The Bronze layer preserves the original structure of raw data while adding metadata for tracking and auditing purposes. This mapping ensures one-to-one field mapping with no transformations applied.

## Source to Bronze Layer Mapping Summary

**Source Database**: DB_POC_ZOOM  
**Source Schema**: RAW  
**Target Database**: DB_POC_ZOOM  
**Target Schema**: BRONZE  

## Detailed Data Mapping Tables

### 1. Users Data Mapping

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

**Data Types**: All VARCHAR(16777216) except LOAD_TIMESTAMP and UPDATE_TIMESTAMP which are TIMESTAMP_NTZ(9)

### 2. Meetings Data Mapping

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

**Data Types**: VARCHAR(16777216) for text fields, TIMESTAMP_NTZ(9) for time fields, NUMBER(38,0) for DURATION_MINUTES

### 3. Participants Data Mapping

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

**Data Types**: VARCHAR(16777216) for ID fields, TIMESTAMP_NTZ(9) for all time-related fields

### 4. Feature Usage Data Mapping

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

**Data Types**: VARCHAR(16777216) for text fields, NUMBER(38,0) for USAGE_COUNT, DATE for USAGE_DATE, TIMESTAMP_NTZ(9) for timestamps

### 5. Support Tickets Data Mapping

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

**Data Types**: VARCHAR(16777216) for text fields, DATE for OPEN_DATE, TIMESTAMP_NTZ(9) for timestamps  
**Domain Values**: RESOLUTION_STATUS has values: Open, In Progress, Resolved, Closed

### 6. Billing Events Data Mapping

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

**Data Types**: VARCHAR(16777216) for text fields, NUMBER(10,2) for AMOUNT, DATE for EVENT_DATE, TIMESTAMP_NTZ(9) for timestamps

### 7. Licenses Data Mapping

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

**Data Types**: VARCHAR(16777216) for text fields, DATE for START_DATE and END_DATE, TIMESTAMP_NTZ(9) for timestamps

## Data Type Compatibility Matrix

| Source Data Type | Bronze Data Type | Snowflake Compatible | Notes |
|------------------|------------------|---------------------|-------|
| VARCHAR(16777216) | VARCHAR(16777216) | ✓ | Maximum varchar length in Snowflake |
| NUMBER(38,0) | NUMBER(38,0) | ✓ | Integer values with maximum precision |
| NUMBER(10,2) | NUMBER(10,2) | ✓ | Decimal values for monetary amounts |
| DATE | DATE | ✓ | Date-only values |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ(9) | ✓ | Timestamp without timezone |

## Bronze Layer Design Principles

### 1. Raw Data Preservation
- All source data is preserved exactly as received
- No data cleansing or transformation applied
- Original data types maintained
- NULL values preserved as-is

### 2. Metadata Enrichment
- **LOAD_TIMESTAMP**: When record was first loaded into Bronze
- **UPDATE_TIMESTAMP**: When record was last modified
- **SOURCE_SYSTEM**: Identifies the originating system

### 3. Snowflake Optimization
- Uses Snowflake-native data types
- Leverages micro-partitioning for performance
- Supports time travel and zero-copy cloning
- No constraints for maximum flexibility

### 4. Audit and Lineage
- Complete audit trail through metadata fields
- Source system tracking for data lineage
- Processing timestamps for monitoring

## Data Ingestion Process Flow

1. **Source Extraction**: Data extracted from RAW layer tables
2. **Metadata Addition**: Load timestamp and source system added
3. **Bronze Loading**: Data loaded into Bronze tables with BZ_ prefix
4. **Audit Logging**: All operations logged in BZ_DATA_AUDIT table
5. **Quality Monitoring**: Basic data quality checks for completeness

## Key Business Rules (Applied in Silver Layer)

- **Data Validation**: Applied in Silver layer, not Bronze
- **Business Logic**: Implemented downstream in Silver/Gold layers
- **Data Quality**: Quality issues flagged but data preserved
- **Referential Integrity**: Enforced in Silver layer transformations

## Data Volume and Performance Considerations

- **Partitioning**: Automatic micro-partitioning by Snowflake
- **Clustering**: Can be applied on frequently queried columns
- **Compression**: Automatic compression by Snowflake
- **Storage**: Optimized for cloud-native storage

## Security and Compliance

- **PII Fields Identified**: USER_NAME, EMAIL, MEETING_TOPIC
- **Access Control**: Role-based access through Snowflake RBAC
- **Data Masking**: Applied at query time, not storage
- **Audit Trail**: Complete audit through metadata fields

## Monitoring and Alerting

- **Load Monitoring**: Track load times and volumes
- **Data Quality**: Monitor for completeness and consistency
- **Performance**: Track query performance and optimization
- **Error Handling**: Log and alert on ingestion failures

## Key Assumptions and Constraints

### Assumptions
- Source systems provide consistent data structure
- Metadata fields are populated by source systems
- Data types are compatible between source and Snowflake
- Historical data preservation through Snowflake time travel

### Constraints
- No primary key constraints in Bronze layer
- No foreign key relationships enforced
- No check constraints on data values
- No data transformation or cleansing rules

## Next Steps for Silver Layer

1. **Data Quality Rules**: Implement validation and cleansing
2. **Business Logic**: Apply business rules and calculations
3. **Data Standardization**: Standardize formats and values
4. **Referential Integrity**: Establish and enforce relationships
5. **Performance Optimization**: Add clustering and indexing strategies

---

**Document Status**: This mapping document serves as the foundation for Bronze layer implementation and provides the blueprint for raw data ingestion in the Medallion architecture. All transformations and business logic will be applied in subsequent Silver and Gold layers.

**Validation**: This mapping has been validated against source schema documentation and Bronze layer physical data model to ensure complete alignment and compatibility.

**outputURL**: https://github.com/ZoomAscendion/Zoom/tree/Agent_Output/Bronze_Datamodel_Mapping_Workbench  
**pipelineID**: 8289