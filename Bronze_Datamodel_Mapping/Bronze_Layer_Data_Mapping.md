_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Bronze Layer Data Mapping for Zoom Platform Analytics System following medallion architecture principles
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Bronze Layer Data Mapping Document

## Overview
This document provides comprehensive data mapping between the RAW source system (DB_POC_ZOOM.RAW) and the Bronze layer (DB_POC_ZOOM.BRONZE) following the Medallion architecture principles. The Bronze layer maintains the original data structure with no transformations, ensuring data lineage and preserving raw data integrity.

## Mapping Methodology
- **Transformation Rule**: 1-1 Mapping (Direct field-to-field mapping with no data transformations)
- **Data Preservation**: All source data types and structures are maintained
- **Naming Convention**: Bronze tables use "BZ_" prefix followed by the source table name

---

## Data Mapping Tables

### 1. BILLING_EVENTS Mapping

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

### 2. FEATURE_USAGE Mapping

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

### 3. LICENSES Mapping

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

### 4. MEETINGS Mapping

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

### 5. PARTICIPANTS Mapping

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

### 6. SUPPORT_TICKETS Mapping

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

### 7. USERS Mapping

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

### 8. WEBINARS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_WEBINARS | WEBINAR_ID | Source | WEBINARS | WEBINAR_ID | 1-1 Mapping |
| Bronze | BZ_WEBINARS | HOST_ID | Source | WEBINARS | HOST_ID | 1-1 Mapping |
| Bronze | BZ_WEBINARS | WEBINAR_TOPIC | Source | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| Bronze | BZ_WEBINARS | START_TIME | Source | WEBINARS | START_TIME | 1-1 Mapping |
| Bronze | BZ_WEBINARS | END_TIME | Source | WEBINARS | END_TIME | 1-1 Mapping |
| Bronze | BZ_WEBINARS | REGISTRANTS | Source | WEBINARS | REGISTRANTS | 1-1 Mapping |
| Bronze | BZ_WEBINARS | LOAD_TIMESTAMP | Source | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_WEBINARS | UPDATE_TIMESTAMP | Source | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_WEBINARS | SOURCE_SYSTEM | Source | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |

---

## Data Type Specifications

All data types remain consistent between source and target layers to ensure Snowflake compatibility:

- **VARCHAR(16777216)**: Text fields (IDs, names, descriptions, etc.)
- **TIMESTAMP_NTZ(9)**: Timestamp fields without timezone
- **NUMBER(38,0)**: Integer fields (counts, durations)
- **NUMBER(10,2)**: Decimal fields (amounts)
- **DATE**: Date fields

## Metadata Management

### Standard Metadata Fields
All Bronze layer tables include the following metadata fields for data governance:

- **LOAD_TIMESTAMP**: Records when data was initially loaded into the system
- **UPDATE_TIMESTAMP**: Records when data was last updated
- **SOURCE_SYSTEM**: Identifies the originating source system

### Data Validation Rules

1. **Primary Key Validation**: All primary key fields (IDs) must be non-null and unique
2. **Foreign Key Validation**: Foreign key relationships are preserved from source
3. **Data Type Validation**: All fields must conform to specified Snowflake data types
4. **Timestamp Validation**: All timestamp fields must be valid timestamp formats
5. **Source System Validation**: SOURCE_SYSTEM field must be populated for all records

## Data Ingestion Process

### Raw Data Ingestion
1. Data is extracted from source systems in its original format
2. No transformations are applied during Bronze layer ingestion
3. All source data structure and content is preserved
4. Metadata fields are populated during the ingestion process

### Data Quality Checks
1. **Completeness Check**: Verify all expected fields are present
2. **Format Validation**: Ensure data types match specifications
3. **Duplicate Detection**: Identify and flag duplicate records
4. **Referential Integrity**: Validate foreign key relationships

## Summary

This Bronze Layer Data Mapping provides:
- **Complete Coverage**: All 8 source tables with 64 total field mappings
- **Data Integrity**: 1-1 mapping preserves original data structure
- **Metadata Governance**: Comprehensive metadata management
- **Validation Framework**: Robust data quality validation rules
- **Snowflake Optimization**: Native Snowflake data type compatibility

The Bronze layer serves as the foundation for the Medallion architecture, ensuring reliable data ingestion and storage while maintaining full data lineage and traceability for downstream Silver and Gold layer transformations.