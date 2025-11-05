_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Medallion architecture implementation in Snowflake
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping for Zoom Platform Analytics System

## Overview
This document provides a comprehensive data mapping between the Raw (source) layer and Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer maintains the original data structure with minimal transformation, ensuring raw data preservation while adding necessary metadata for data lineage and auditing.

## Schema Naming Convention
- **Source Layer**: RAW schema
- **Target Layer**: BRONZE schema

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

### Snowflake Data Type Mapping

| Source Data Type | Target Data Type | Description |
|------------------|------------------|-------------|
| VARCHAR(16777216) | STRING | Variable-length string data |
| NUMBER(38,0) | NUMBER | Integer numeric data |
| NUMBER(10,2) | NUMBER(10,2) | Decimal numeric data with precision |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ | Timestamp without timezone |
| DATE | DATE | Date only data |

## Data Ingestion Requirements

### 1. Raw Data Preservation
- **Principle**: Bronze layer maintains exact copy of source data structure
- **No Transformations**: Data cleansing, validations, and business rules are excluded
- **Original Format**: All source data types and formats are preserved

### 2. Metadata Management
- **Load Timestamp**: Tracks when data was first ingested into Bronze layer
- **Update Timestamp**: Tracks when data was last modified
- **Source System**: Identifies the originating system for data lineage

### 3. Data Validation Rules
- **Schema Validation**: Ensure source schema matches expected Bronze table structure
- **Data Type Validation**: Verify data types are compatible with Snowflake
- **Null Handling**: Preserve null values as they exist in source systems
- **Duplicate Detection**: Identify but do not remove duplicate records

## Data Lineage and Auditing

### 1. Source System Tracking
- Each record includes SOURCE_SYSTEM field for traceability
- Supported source systems:
  - Zoom_API
  - User_Management_System
  - Registration_Portal
  - Meeting_Dashboard
  - Participant_Tracking_System
  - Analytics_System
  - Support_Portal
  - CRM_System
  - Email_Integration
  - Billing_System
  - Manual_Entry
  - Zoom_Admin_API
  - License_Management_System

### 2. Temporal Tracking
- **LOAD_TIMESTAMP**: Initial data ingestion time
- **UPDATE_TIMESTAMP**: Last modification time
- Enables change data capture and historical analysis

## Data Quality Considerations

### 1. Bronze Layer Principles
- **Raw Data Storage**: No data transformation or cleansing
- **Complete Data Capture**: All source fields are mapped
- **Error Preservation**: Invalid data is stored for downstream analysis
- **Audit Trail**: Full lineage and timestamp tracking

### 2. Data Governance
- **PII Identification**: Personal data fields are preserved but flagged for downstream handling
- **Data Classification**: Sensitive data maintains original classification
- **Retention Policy**: Raw data retention follows organizational policies

## Implementation Notes

### 1. Naming Conventions
- **Bronze Tables**: Prefixed with 'BZ_' for clear identification
- **Field Names**: Maintain exact source field names for consistency
- **Schema**: BRONZE schema contains all Bronze layer tables

### 2. Performance Considerations
- **Partitioning**: Consider partitioning by LOAD_TIMESTAMP for large datasets
- **Clustering**: Cluster on frequently queried fields like USER_ID, MEETING_ID
- **Compression**: Leverage Snowflake's automatic compression

### 3. Data Loading Strategy
- **Batch Processing**: Recommended for initial loads and daily updates
- **Incremental Loading**: Use UPDATE_TIMESTAMP for change detection
- **Error Handling**: Log and preserve records that fail validation

## Assumptions and Dependencies

### 1. Source System Assumptions
- Source systems provide consistent data formats
- All required metadata fields are available
- Source systems support incremental data extraction

### 2. Technical Dependencies
- Snowflake database and warehouse availability
- Network connectivity to source systems
- Appropriate access permissions for data ingestion

### 3. Data Volume Assumptions
- Daily data volumes are within Snowflake processing capacity
- Historical data migration is planned in phases
- Peak usage periods are identified for resource scaling

---

**End of Bronze Layer Data Mapping Document**