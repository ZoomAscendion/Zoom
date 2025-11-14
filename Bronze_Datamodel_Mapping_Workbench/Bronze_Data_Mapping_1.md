_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System in Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping - Zoom Platform Analytics System

## Overview
This document provides comprehensive data mapping between the source RAW layer and Bronze layer in the Medallion architecture implementation for Snowflake. The Bronze layer maintains raw data structure with minimal transformation while adding essential metadata for data lineage and audit purposes.

## Data Mapping Tables

### 1. BZ_USERS Mapping

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

### 2. BZ_MEETINGS Mapping

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

### 3. BZ_PARTICIPANTS Mapping

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

### 4. BZ_FEATURE_USAGE Mapping

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

### 5. BZ_SUPPORT_TICKETS Mapping

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

### 6. BZ_BILLING_EVENTS Mapping

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

### 7. BZ_LICENSES Mapping

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

## Data Type Compatibility

### Snowflake Data Type Assignments

| Data Type | Usage | Compatibility Notes |
|-----------|-------|--------------------|
| VARCHAR(16777216) | String fields, IDs, Names | Snowflake's maximum VARCHAR size for flexibility |
| NUMBER(38,0) | Integer counts, durations | Snowflake's default integer type |
| NUMBER(10,2) | Monetary amounts | Precision for currency values |
| TIMESTAMP_NTZ(9) | Timestamp fields | Timezone-naive timestamps with nanosecond precision |
| DATE | Date-only fields | Standard date type |

## Data Ingestion Details

### Source to Bronze Layer Ingestion Process

1. **Data Extraction**: Raw data extracted from source systems (RAW schema)
2. **Minimal Transformation**: Data loaded as-is with no business logic transformations
3. **Metadata Enrichment**: Addition of load_timestamp, update_timestamp, and source_system
4. **Data Preservation**: Original data structure and values maintained
5. **Error Handling**: Failed records logged but do not stop the ingestion process

### Key Ingestion Principles

- **No Data Validation**: Bronze layer accepts all data regardless of quality
- **No Referential Integrity**: No foreign key constraints enforced
- **Append-Only**: Historical data preserved through versioning
- **Idempotent Loads**: Support for reprocessing without duplication
- **Audit Trail**: Complete lineage tracking through metadata fields

## Metadata Management

### Standard Metadata Fields

All Bronze layer tables include the following metadata fields:

- **LOAD_TIMESTAMP**: When the record was first loaded into Bronze layer
- **UPDATE_TIMESTAMP**: When the record was last modified
- **SOURCE_SYSTEM**: Identifier of the originating system

### Data Lineage

- Source system identification preserved
- Load timestamps enable time-based analysis
- Update timestamps support change data capture
- Audit trail maintained for compliance

## Data Quality Considerations

### Bronze Layer Quality Approach

- **Accept All Data**: No rejection of records due to quality issues
- **Preserve Original Values**: No cleansing or standardization
- **Document Issues**: Quality problems identified but not corrected
- **Enable Downstream Processing**: Silver layer handles data quality

### Known Data Quality Patterns

- Null values preserved as-is
- Duplicate records maintained
- Format inconsistencies retained
- Business rule violations not enforced

## Performance Optimization

### Snowflake-Specific Optimizations

- **Micro-partitioning**: Automatic clustering on ingestion timestamps
- **Compression**: Snowflake's automatic compression applied
- **Columnar Storage**: Optimized for analytical queries
- **Time Travel**: 90-day retention for historical analysis

### Loading Strategies

- **Bulk Loading**: COPY INTO for large datasets
- **Streaming**: Snowpipe for real-time ingestion
- **Incremental**: Change data capture for updates
- **Full Refresh**: Complete reload for small tables

## Security and Compliance

### PII Data Handling

- **USER_NAME**: Contains personally identifiable information
- **EMAIL**: Contains personally identifiable information
- **MEETING_TOPIC**: May contain sensitive information

### Access Controls

- Role-based access control (RBAC) implemented
- Column-level security for PII fields
- Audit logging for all data access
- Encryption at rest and in transit

## Assumptions and Design Decisions

### Key Assumptions

1. Source systems provide consistent data structure
2. All source tables include standard metadata fields
3. VARCHAR(16777216) provides sufficient capacity for string fields
4. Timezone-naive timestamps are acceptable for business requirements
5. No real-time processing requirements for Bronze layer

### Design Decisions

1. **No Constraints**: Flexibility prioritized over data integrity
2. **Uniform Metadata**: Consistent metadata across all tables
3. **Snowflake Native Types**: Optimized for Snowflake performance
4. **Table Prefixing**: 'BZ_' prefix for clear layer identification
5. **Schema Organization**: Dedicated BRONZE schema for isolation

## Next Steps

This Bronze layer mapping serves as the foundation for:

1. **Silver Layer Development**: Cleaned and validated data
2. **Data Quality Rules**: Implementation in Silver layer
3. **Business Logic**: Applied in Silver and Gold layers
4. **Performance Tuning**: Based on actual usage patterns
5. **Security Enhancement**: Additional controls as needed

---

**Note**: This mapping document should be reviewed and updated as source systems evolve or business requirements change. The Bronze layer design prioritizes flexibility and data preservation to support future analytical needs.