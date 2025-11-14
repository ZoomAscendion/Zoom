_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System in Medallion architecture
## *Version*: 2 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping for Zoom Platform Analytics System

## Overview
This document provides a comprehensive data mapping between the source RAW layer and the Bronze layer in the Medallion architecture implementation for Snowflake. The Bronze layer preserves the original structure of raw data while adding metadata for tracking and auditing purposes.

## Data Mapping Tables

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

## Data Type Compatibility

All data types in the Bronze layer are compatible with Snowflake and maintain the same structure as the source RAW layer:

- **VARCHAR(16777216)**: Used for all text fields including IDs, names, and descriptive fields
- **NUMBER(38,0)**: Used for integer values like usage counts and duration minutes
- **NUMBER(10,2)**: Used for monetary amounts with precision for currency
- **DATE**: Used for date-only fields like event dates and open dates
- **TIMESTAMP_NTZ(9)**: Used for timestamp fields without timezone

## Bronze Layer Design Principles

1. **Raw Data Preservation**: All source data is preserved without transformation
2. **Metadata Enrichment**: Standard metadata fields (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) are maintained
3. **No Data Validation**: Bronze layer accepts data as-is from source systems
4. **Snowflake Optimization**: Data types are optimized for Snowflake's cloud-native architecture
5. **Audit Trail Ready**: Structure supports comprehensive audit and lineage tracking

## Data Ingestion Process

1. **Extract**: Data is extracted from source systems (RAW layer)
2. **Load**: Data is loaded into Bronze tables with minimal transformation
3. **Metadata**: Load and update timestamps are captured during ingestion
4. **Source Tracking**: Source system information is preserved for lineage
5. **Audit**: All operations are logged for compliance and monitoring

## Raw Data Ingestion Details

### Source System Information
- **Database**: DB_POC_ZOOM
- **Schema**: RAW
- **Target Database**: DB_POC_ZOOM
- **Target Schema**: BRONZE

### Data Ingestion Specifications

#### 1. Users Table Ingestion
- **Source**: RAW.USERS
- **Target**: BRONZE.BZ_USERS
- **Primary Key**: USER_ID (preserved as-is, no constraints enforced)
- **Data Volume**: Variable based on user registrations
- **Ingestion Frequency**: Real-time or batch based on source system

#### 2. Meetings Table Ingestion
- **Source**: RAW.MEETINGS
- **Target**: BRONZE.BZ_MEETINGS
- **Primary Key**: MEETING_ID (preserved as-is, no constraints enforced)
- **Data Volume**: High volume based on meeting activities
- **Ingestion Frequency**: Near real-time for active meetings

#### 3. Participants Table Ingestion
- **Source**: RAW.PARTICIPANTS
- **Target**: BRONZE.BZ_PARTICIPANTS
- **Primary Key**: PARTICIPANT_ID (preserved as-is, no constraints enforced)
- **Data Volume**: High volume, multiple records per meeting
- **Ingestion Frequency**: Real-time during meeting sessions

#### 4. Feature Usage Table Ingestion
- **Source**: RAW.FEATURE_USAGE
- **Target**: BRONZE.BZ_FEATURE_USAGE
- **Primary Key**: USAGE_ID (preserved as-is, no constraints enforced)
- **Data Volume**: Variable based on feature adoption
- **Ingestion Frequency**: Event-driven based on feature usage

#### 5. Support Tickets Table Ingestion
- **Source**: RAW.SUPPORT_TICKETS
- **Target**: BRONZE.BZ_SUPPORT_TICKETS
- **Primary Key**: TICKET_ID (preserved as-is, no constraints enforced)
- **Data Volume**: Moderate based on support requests
- **Ingestion Frequency**: Real-time when tickets are created/updated

#### 6. Billing Events Table Ingestion
- **Source**: RAW.BILLING_EVENTS
- **Target**: BRONZE.BZ_BILLING_EVENTS
- **Primary Key**: EVENT_ID (preserved as-is, no constraints enforced)
- **Data Volume**: Moderate based on billing cycles
- **Ingestion Frequency**: Batch processing aligned with billing cycles

#### 7. Licenses Table Ingestion
- **Source**: RAW.LICENSES
- **Target**: BRONZE.BZ_LICENSES
- **Primary Key**: LICENSE_ID (preserved as-is, no constraints enforced)
- **Data Volume**: Moderate based on license assignments
- **Ingestion Frequency**: Event-driven based on license changes

## Metadata Management

### Standard Metadata Fields
All Bronze tables include the following metadata fields for comprehensive tracking:

1. **LOAD_TIMESTAMP**: Captures when the record was first loaded into the Bronze layer
2. **UPDATE_TIMESTAMP**: Tracks the last modification time of the record
3. **SOURCE_SYSTEM**: Identifies the originating system for data lineage

### Data Lineage Tracking
- Source system identification preserved from RAW layer
- Load timestamps enable temporal analysis
- Update timestamps support change data capture scenarios
- Audit trail preparation for downstream Silver layer processing

## Initial Data Validation Rules

### Bronze Layer Validation Principles
1. **No Business Rule Validation**: Bronze layer accepts all data as-is
2. **Schema Validation Only**: Ensures data types match target schema
3. **Null Value Acceptance**: Allows null values in non-critical fields
4. **Duplicate Record Handling**: Preserves duplicates for downstream analysis
5. **Data Quality Flagging**: Flags but does not reject poor quality data

### Validation Checks Applied
1. **Data Type Compatibility**: Ensures source data types can be cast to target types
2. **Field Length Validation**: Verifies text fields fit within VARCHAR limits
3. **Timestamp Format Validation**: Confirms timestamp fields are in expected format
4. **Numeric Range Validation**: Basic checks for numeric field reasonableness

## Key Assumptions

- Source data quality issues will be addressed in Silver layer
- All source tables have consistent metadata fields
- Data types are compatible between source and target systems
- No business rules or validations are applied at Bronze layer
- Historical data preservation is maintained through Snowflake's time travel feature
- Source systems provide reliable LOAD_TIMESTAMP and UPDATE_TIMESTAMP values
- SOURCE_SYSTEM field accurately identifies data origin for lineage tracking

## Performance Considerations

### Snowflake Optimization
1. **Micro-partitioning**: Leverages Snowflake's automatic micro-partitioning
2. **Clustering**: No clustering keys defined to maintain flexibility
3. **Compression**: Utilizes Snowflake's automatic compression
4. **Time Travel**: Supports Snowflake's time travel feature for historical analysis
5. **Zero-Copy Cloning**: Enables efficient data sharing and testing

### Ingestion Performance
1. **Batch Size Optimization**: Configurable based on source system capabilities
2. **Parallel Processing**: Supports concurrent ingestion from multiple sources
3. **Error Handling**: Implements robust error handling without stopping ingestion
4. **Monitoring**: Comprehensive logging for performance monitoring

---

**Note**: This mapping ensures a one-to-one relationship between source and Bronze layer fields, maintaining data integrity while preparing for downstream Silver layer transformations and business rule applications. The Bronze layer serves as the foundation for the Medallion architecture, preserving raw data fidelity while enabling scalable analytics processing.