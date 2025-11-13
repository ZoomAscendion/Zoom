_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System following Medallion architecture
## *Version*: 2 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping - Zoom Platform Analytics System

## Overview
This document provides comprehensive data mapping between the source RAW layer and Bronze layer in the Medallion architecture implementation for Snowflake. The mapping ensures raw data ingestion processes preserve original structure while adding necessary metadata for downstream processing. This version aligns with the Bronze layer physical data model DDL scripts and maintains one-to-one mapping with no transformations.

## Target Architecture
- **Target Database**: DB_POC_ZOOM
- **Source Schema**: RAW
- **Target Schema**: BRONZE
- **Table Prefix**: Bz_ (Bronze layer identifier)

## Source to Bronze Layer Mapping

### 1. USERS Table Mapping
**Source**: RAW.USERS → **Target**: BRONZE.Bz_USERS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_USERS | USER_ID | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | Bz_USERS | USER_NAME | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | Bz_USERS | EMAIL | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | Bz_USERS | COMPANY | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | Bz_USERS | PLAN_TYPE | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | Bz_USERS | LOAD_TIMESTAMP | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_USERS | UPDATE_TIMESTAMP | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_USERS | SOURCE_SYSTEM | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 2. MEETINGS Table Mapping
**Source**: RAW.MEETINGS → **Target**: BRONZE.Bz_MEETINGS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_MEETINGS | MEETING_ID | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | Bz_MEETINGS | HOST_ID | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | Bz_MEETINGS | MEETING_TOPIC | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | Bz_MEETINGS | START_TIME | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | Bz_MEETINGS | END_TIME | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | Bz_MEETINGS | DURATION_MINUTES | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | Bz_MEETINGS | LOAD_TIMESTAMP | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_MEETINGS | UPDATE_TIMESTAMP | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_MEETINGS | SOURCE_SYSTEM | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 3. PARTICIPANTS Table Mapping
**Source**: RAW.PARTICIPANTS → **Target**: BRONZE.Bz_PARTICIPANTS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_PARTICIPANTS | PARTICIPANT_ID | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | Bz_PARTICIPANTS | MEETING_ID | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | Bz_PARTICIPANTS | USER_ID | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | Bz_PARTICIPANTS | JOIN_TIME | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | Bz_PARTICIPANTS | LEAVE_TIME | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | Bz_PARTICIPANTS | LOAD_TIMESTAMP | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_PARTICIPANTS | UPDATE_TIMESTAMP | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_PARTICIPANTS | SOURCE_SYSTEM | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 4. FEATURE_USAGE Table Mapping
**Source**: RAW.FEATURE_USAGE → **Target**: BRONZE.Bz_FEATURE_USAGE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_FEATURE_USAGE | USAGE_ID | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | Bz_FEATURE_USAGE | MEETING_ID | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | Bz_FEATURE_USAGE | FEATURE_NAME | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | Bz_FEATURE_USAGE | USAGE_COUNT | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | Bz_FEATURE_USAGE | USAGE_DATE | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | Bz_FEATURE_USAGE | LOAD_TIMESTAMP | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_FEATURE_USAGE | UPDATE_TIMESTAMP | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_FEATURE_USAGE | SOURCE_SYSTEM | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 5. SUPPORT_TICKETS Table Mapping
**Source**: RAW.SUPPORT_TICKETS → **Target**: BRONZE.Bz_SUPPORT_TICKETS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_SUPPORT_TICKETS | TICKET_ID | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | Bz_SUPPORT_TICKETS | USER_ID | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | Bz_SUPPORT_TICKETS | TICKET_TYPE | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | Bz_SUPPORT_TICKETS | RESOLUTION_STATUS | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | Bz_SUPPORT_TICKETS | OPEN_DATE | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | Bz_SUPPORT_TICKETS | LOAD_TIMESTAMP | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_SUPPORT_TICKETS | SOURCE_SYSTEM | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 6. BILLING_EVENTS Table Mapping
**Source**: RAW.BILLING_EVENTS → **Target**: BRONZE.Bz_BILLING_EVENTS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_BILLING_EVENTS | EVENT_ID | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | Bz_BILLING_EVENTS | USER_ID | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | Bz_BILLING_EVENTS | EVENT_TYPE | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | Bz_BILLING_EVENTS | AMOUNT | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | Bz_BILLING_EVENTS | EVENT_DATE | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | Bz_BILLING_EVENTS | LOAD_TIMESTAMP | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_BILLING_EVENTS | UPDATE_TIMESTAMP | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_BILLING_EVENTS | SOURCE_SYSTEM | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 7. LICENSES Table Mapping
**Source**: RAW.LICENSES → **Target**: BRONZE.Bz_LICENSES

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_LICENSES | LICENSE_ID | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | Bz_LICENSES | LICENSE_TYPE | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | Bz_LICENSES | ASSIGNED_TO_USER_ID | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | Bz_LICENSES | START_DATE | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | Bz_LICENSES | END_DATE | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | Bz_LICENSES | LOAD_TIMESTAMP | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_LICENSES | UPDATE_TIMESTAMP | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_LICENSES | SOURCE_SYSTEM | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

## Data Type Compatibility Matrix

| Source Data Type | Bronze Data Type | Snowflake Compatibility | Notes |
|------------------|------------------|------------------------|-------|
| VARCHAR(16777216) | STRING | ✅ Native Support | Snowflake STRING equivalent to VARCHAR |
| NUMBER(38,0) | NUMBER | ✅ Native Support | Integer values preserved |
| NUMBER(10,2) | NUMBER(10,2) | ✅ Native Support | Decimal precision maintained |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ | ✅ Native Support | Timezone-naive timestamps |
| DATE | DATE | ✅ Native Support | Date values preserved |

## Bronze Layer Physical Schema Alignment

The Bronze layer tables are created using the following Snowflake-compatible data types as per the physical data model:

- **STRING**: Used for all VARCHAR fields (Snowflake native type)
- **NUMBER**: Used for numeric fields with appropriate precision
- **TIMESTAMP_NTZ**: Used for timestamp fields without timezone
- **DATE**: Used for date-only fields

## Data Ingestion Requirements

### Metadata Management
- **LOAD_TIMESTAMP**: Automatically populated during ingestion process using CURRENT_TIMESTAMP()
- **UPDATE_TIMESTAMP**: Updated on each record modification using CURRENT_TIMESTAMP()
- **SOURCE_SYSTEM**: Identifies originating system for data lineage tracking

### Data Validation Rules
1. **Null Handling**: Preserve null values from source without transformation
2. **Data Type Validation**: Ensure source data types are compatible with Snowflake STRING, NUMBER, TIMESTAMP_NTZ, and DATE types
3. **Primary Key Preservation**: Maintain unique identifiers from source systems
4. **Referential Integrity**: Preserve foreign key relationships without constraint enforcement

### PII Data Identification and Handling

#### Direct PII Fields
- **USER_NAME** (Bz_USERS): Direct PII - requires masking policy implementation
- **EMAIL** (Bz_USERS): Direct PII - requires masking policy implementation

#### Potential PII Fields
- **MEETING_TOPIC** (Bz_MEETINGS): Potential PII - monitor for sensitive content and classify appropriately

#### PII Protection Recommendations
1. **Implement Masking Policies**: Apply data masking for direct PII fields
2. **Access Control**: Restrict access to PII fields based on user roles
3. **Audit Logging**: Monitor access to PII-containing tables
4. **Data Classification**: Tag PII fields for automated governance

## Bronze Layer Design Principles

### 1. Raw Data Preservation
- No data transformations applied during ingestion
- Original data structure and values maintained
- All source columns mapped directly to Bronze layer

### 2. Metadata Enrichment
- Standard metadata columns added to all tables for audit trail
- Data lineage tracking enabled through SOURCE_SYSTEM field
- Load and update timestamps for change tracking

### 3. Snowflake Optimization
- Native Snowflake data types utilized (STRING instead of VARCHAR)
- Micro-partitioning leveraged for performance
- Time travel capabilities enabled
- No constraints defined for maximum flexibility

### 4. Schema Flexibility
- No primary key or foreign key constraints enforced
- Schema evolution supported
- Backward compatibility maintained

## Data Pipeline Configuration

### Source Configuration
- **Database**: DB_POC_ZOOM
- **Schema**: RAW
- **Tables**: 7 source tables (USERS, MEETINGS, PARTICIPANTS, FEATURE_USAGE, SUPPORT_TICKETS, BILLING_EVENTS, LICENSES)

### Target Configuration
- **Database**: DB_POC_ZOOM
- **Schema**: BRONZE
- **Tables**: 7 Bronze layer tables with Bz_ prefix + 1 audit table (Bz_DATA_AUDIT)

### Processing Requirements
- **Batch Processing**: Recommended for initial loads
- **Incremental Processing**: Supported via LOAD_TIMESTAMP and UPDATE_TIMESTAMP columns
- **Error Handling**: Failed records logged to Bz_DATA_AUDIT table
- **Monitoring**: Data quality metrics tracked through audit table

## Sample Data Ingestion Pattern

```sql
-- Example batch ingestion from RAW to Bronze
INSERT INTO BRONZE.Bz_USERS (
    USER_ID, USER_NAME, EMAIL, COMPANY, PLAN_TYPE,
    LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM
)
SELECT 
    USER_ID, USER_NAME, EMAIL, COMPANY, PLAN_TYPE,
    CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM RAW.USERS
WHERE UPDATE_TIMESTAMP > COALESCE(
    (SELECT MAX(UPDATE_TIMESTAMP) FROM BRONZE.Bz_USERS), 
    '1900-01-01'::TIMESTAMP_NTZ
);
```

## Data Quality and Monitoring

### Data Completeness Checks
- Monitor record counts between source and target tables
- Track null value percentages for critical fields
- Validate data type compatibility during ingestion

### Audit Trail Requirements
- All data operations logged to Bz_DATA_AUDIT table
- Processing statistics tracked (processing time, record counts, status)
- Data lineage maintained through SOURCE_SYSTEM field

### Performance Monitoring
- Clustering recommendations for large tables based on query patterns
- Monitoring of ingestion performance and optimization opportunities
- Regular maintenance of clustering keys for optimal performance

## Summary

This Bronze layer data mapping provides a comprehensive 1-1 mapping between the RAW source layer and Bronze layer tables following Medallion architecture principles. The mapping ensures:

- **Data Integrity**: All source data preserved without transformation
- **Metadata Tracking**: Complete audit trail and lineage information
- **Snowflake Compatibility**: Optimized for Snowflake cloud data platform using native data types
- **Scalability**: Designed to handle large volumes of raw data efficiently
- **Compliance**: PII fields identified and protection mechanisms outlined
- **Flexibility**: No constraints enforced to allow maximum schema evolution

The Bronze layer serves as the foundation for downstream Silver and Gold layer transformations while maintaining the raw data in its original form for complete data lineage, recovery capabilities, and regulatory compliance requirements.

## Next Steps

1. **Implementation**: Execute Bronze layer DDL scripts to create physical tables
2. **Data Pipeline Development**: Implement ETL processes from RAW to Bronze using the mapping specifications
3. **Security Implementation**: Deploy masking policies for PII fields
4. **Monitoring Setup**: Implement data quality and performance monitoring
5. **Testing**: Comprehensive testing of data ingestion and validation processes