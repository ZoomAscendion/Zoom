_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Bronze Layer Data Mapping for Zoom Platform Analytics System supporting medallion architecture data processing
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Bronze Layer Data Mapping - Zoom Platform Analytics System

## Overview
This document provides a comprehensive data mapping for the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer serves as the raw data ingestion layer, preserving the original structure and metadata from source systems while ensuring compatibility with Snowflake data types.

## Mapping Principles
- **1:1 Mapping**: Direct one-to-one mapping between source and target fields
- **No Transformations**: Raw data structure is preserved without any business logic or cleansing
- **Metadata Preservation**: All original metadata and audit fields are maintained
- **Snowflake Compatibility**: Data types are optimized for Snowflake SQL operations

## Data Mapping Tables

### 1. BILLING_EVENTS Mapping

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

### 2. FEATURE_USAGE Mapping

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

### 3. LICENSES Mapping

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

### 4. MEETINGS Mapping

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

### 5. PARTICIPANTS Mapping

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

### 6. SUPPORT_TICKETS Mapping

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

### 7. USERS Mapping

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

### 8. WEBINARS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_WEBINARS | WEBINAR_ID | Source | WEBINARS | WEBINAR_ID | 1-1 Mapping |
| Bronze | Bz_WEBINARS | HOST_ID | Source | WEBINARS | HOST_ID | 1-1 Mapping |
| Bronze | Bz_WEBINARS | WEBINAR_TOPIC | Source | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| Bronze | Bz_WEBINARS | START_TIME | Source | WEBINARS | START_TIME | 1-1 Mapping |
| Bronze | Bz_WEBINARS | END_TIME | Source | WEBINARS | END_TIME | 1-1 Mapping |
| Bronze | Bz_WEBINARS | REGISTRANTS | Source | WEBINARS | REGISTRANTS | 1-1 Mapping |
| Bronze | Bz_WEBINARS | LOAD_TIMESTAMP | Source | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_WEBINARS | UPDATE_TIMESTAMP | Source | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_WEBINARS | SOURCE_SYSTEM | Source | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |

## Data Type Specifications

### Snowflake Data Type Mapping

| Source Data Type | Target Data Type | Description |
|------------------|------------------|-------------|
| VARCHAR(16777216) | VARCHAR(16777216) | Maximum length string type in Snowflake |
| NUMBER(10,2) | NUMBER(10,2) | Decimal number with 10 digits, 2 decimal places |
| NUMBER(38,0) | NUMBER(38,0) | Integer number with up to 38 digits |
| DATE | DATE | Date type without time component |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ(9) | Timestamp without timezone, 9 precision |

## Data Ingestion Guidelines

### 1. Raw Data Preservation
- All source data fields are mapped directly without transformation
- Original data types are maintained for compatibility
- No data validation or cleansing rules applied at Bronze layer
- Null values and data quality issues are preserved for downstream processing

### 2. Metadata Management
- **LOAD_TIMESTAMP**: Captures when the record was first loaded into the system
- **UPDATE_TIMESTAMP**: Tracks the last modification time of the record
- **SOURCE_SYSTEM**: Identifies the originating system for data lineage

### 3. Primary Key Preservation
- All primary keys from source tables are maintained
- Foreign key relationships are preserved for referential integrity
- No surrogate keys are introduced at the Bronze layer

### 4. PII Data Handling
- PII fields (USER_NAME, EMAIL, COMPANY) are flagged but not masked at Bronze layer
- Raw PII data is preserved for downstream masking/encryption processes
- Data governance policies should be applied at Silver/Gold layers

## Data Loading Patterns

### 1. Initial Load
- Full extract from source systems
- Direct INSERT operations into Bronze tables
- Batch processing recommended for large datasets

### 2. Incremental Load
- Delta extraction based on UPDATE_TIMESTAMP
- MERGE operations for handling updates and inserts
- Change data capture (CDC) patterns supported

### 3. Error Handling
- Failed records logged but not rejected
- Data quality issues documented for downstream resolution
- Source system errors preserved in Bronze layer

## Assumptions and Constraints

### Assumptions
1. Source data follows the defined schema structure
2. All mandatory fields (Primary Keys) are populated in source
3. LOAD_TIMESTAMP and UPDATE_TIMESTAMP are system-generated
4. SOURCE_SYSTEM field identifies the data origin consistently

### Constraints
1. No business rule validations at Bronze layer
2. No data transformation or enrichment
3. No duplicate detection or removal
4. No data masking or encryption applied

## Implementation Notes

### Snowflake Specific Considerations
1. **Storage**: Use Snowflake's columnar storage for optimal performance
2. **Clustering**: Consider clustering on frequently queried fields (dates, IDs)
3. **Partitioning**: Leverage automatic micro-partitioning
4. **Compression**: Snowflake handles compression automatically

### Performance Optimization
1. **Batch Size**: Optimize batch sizes for efficient loading
2. **Parallel Processing**: Utilize Snowflake's parallel processing capabilities
3. **Resource Management**: Scale warehouse size based on data volume
4. **Monitoring**: Implement query performance monitoring

## Data Quality Considerations

### Bronze Layer Quality Checks
1. **Schema Validation**: Ensure incoming data matches expected schema
2. **Row Count Validation**: Verify expected number of records loaded
3. **Null Check**: Monitor critical fields for unexpected null values
4. **Data Type Validation**: Confirm data types match specifications

### Monitoring and Alerting
1. **Load Failures**: Alert on failed data loads
2. **Data Volume**: Monitor for significant changes in data volume
3. **Latency**: Track data freshness and loading times
4. **Schema Changes**: Detect and alert on source schema modifications

---

**Document Control:**
- **Created By**: AAVA
- **Review Status**: Draft
- **Approval Required**: Data Architecture Team
- **Next Review Date**: 2025-01-19