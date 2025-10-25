_____________________________________________
## *Author*: AAVA
## *Version*: 3
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System - Medallion Architecture Implementation
## *Created on*: 2024
## *Updated on*: 2024
_____________________________________________

# Bronze Layer Data Mapping - Zoom Platform Analytics System

## Overview

This document provides comprehensive data mapping for the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer serves as the raw data ingestion layer, preserving the original structure of source data while adding essential metadata for data governance and lineage tracking.

## Architecture Details

- **Source Layer**: RAW Schema (DB_POC_ZOOM.RAW)
- **Target Layer**: BRONZE Schema (DB_POC_ZOOM.BRONZE)
- **Mapping Type**: One-to-One (1:1) with metadata enhancement
- **Data Transformation**: No business logic transformations, raw data preservation

## Naming Conventions

- **Source Schema**: RAW
- **Target Schema**: BRONZE
- **Table Prefix**: BZ_ (Bronze layer identifier)
- **Metadata Fields**: LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM

## Data Mapping Tables

### 1. USERS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | BZ_USERS | USER_ID | RAW | USERS | USER_ID | 1-1 Mapping |
| BRONZE | BZ_USERS | USER_NAME | RAW | USERS | USER_NAME | 1-1 Mapping |
| BRONZE | BZ_USERS | EMAIL | RAW | USERS | EMAIL | 1-1 Mapping |
| BRONZE | BZ_USERS | COMPANY | RAW | USERS | COMPANY | 1-1 Mapping |
| BRONZE | BZ_USERS | PLAN_TYPE | RAW | USERS | PLAN_TYPE | 1-1 Mapping |
| BRONZE | BZ_USERS | LOAD_TIMESTAMP | RAW | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_USERS | UPDATE_TIMESTAMP | RAW | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_USERS | SOURCE_SYSTEM | RAW | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 2. MEETINGS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | BZ_MEETINGS | MEETING_ID | RAW | MEETINGS | MEETING_ID | 1-1 Mapping |
| BRONZE | BZ_MEETINGS | HOST_ID | RAW | MEETINGS | HOST_ID | 1-1 Mapping |
| BRONZE | BZ_MEETINGS | MEETING_TOPIC | RAW | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| BRONZE | BZ_MEETINGS | START_TIME | RAW | MEETINGS | START_TIME | 1-1 Mapping |
| BRONZE | BZ_MEETINGS | END_TIME | RAW | MEETINGS | END_TIME | 1-1 Mapping |
| BRONZE | BZ_MEETINGS | DURATION_MINUTES | RAW | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| BRONZE | BZ_MEETINGS | LOAD_TIMESTAMP | RAW | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_MEETINGS | UPDATE_TIMESTAMP | RAW | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_MEETINGS | SOURCE_SYSTEM | RAW | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 3. PARTICIPANTS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | BZ_PARTICIPANTS | PARTICIPANT_ID | RAW | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| BRONZE | BZ_PARTICIPANTS | MEETING_ID | RAW | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| BRONZE | BZ_PARTICIPANTS | USER_ID | RAW | PARTICIPANTS | USER_ID | 1-1 Mapping |
| BRONZE | BZ_PARTICIPANTS | JOIN_TIME | RAW | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| BRONZE | BZ_PARTICIPANTS | LEAVE_TIME | RAW | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| BRONZE | BZ_PARTICIPANTS | LOAD_TIMESTAMP | RAW | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | RAW | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_PARTICIPANTS | SOURCE_SYSTEM | RAW | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 4. FEATURE_USAGE Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | BZ_FEATURE_USAGE | USAGE_ID | RAW | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| BRONZE | BZ_FEATURE_USAGE | MEETING_ID | RAW | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| BRONZE | BZ_FEATURE_USAGE | FEATURE_NAME | RAW | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| BRONZE | BZ_FEATURE_USAGE | USAGE_COUNT | RAW | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| BRONZE | BZ_FEATURE_USAGE | USAGE_DATE | RAW | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| BRONZE | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | RAW | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | RAW | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_FEATURE_USAGE | SOURCE_SYSTEM | RAW | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 5. SUPPORT_TICKETS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | BZ_SUPPORT_TICKETS | TICKET_ID | RAW | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| BRONZE | BZ_SUPPORT_TICKETS | USER_ID | RAW | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| BRONZE | BZ_SUPPORT_TICKETS | TICKET_TYPE | RAW | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| BRONZE | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | RAW | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| BRONZE | BZ_SUPPORT_TICKETS | OPEN_DATE | RAW | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| BRONZE | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | RAW | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | RAW | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | RAW | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 6. BILLING_EVENTS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | BZ_BILLING_EVENTS | EVENT_ID | RAW | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| BRONZE | BZ_BILLING_EVENTS | USER_ID | RAW | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| BRONZE | BZ_BILLING_EVENTS | EVENT_TYPE | RAW | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| BRONZE | BZ_BILLING_EVENTS | AMOUNT | RAW | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| BRONZE | BZ_BILLING_EVENTS | EVENT_DATE | RAW | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| BRONZE | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | RAW | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | RAW | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_BILLING_EVENTS | SOURCE_SYSTEM | RAW | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 7. LICENSES Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | BZ_LICENSES | LICENSE_ID | RAW | LICENSES | LICENSE_ID | 1-1 Mapping |
| BRONZE | BZ_LICENSES | LICENSE_TYPE | RAW | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| BRONZE | BZ_LICENSES | ASSIGNED_TO_USER_ID | RAW | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| BRONZE | BZ_LICENSES | START_DATE | RAW | LICENSES | START_DATE | 1-1 Mapping |
| BRONZE | BZ_LICENSES | END_DATE | RAW | LICENSES | END_DATE | 1-1 Mapping |
| BRONZE | BZ_LICENSES | LOAD_TIMESTAMP | RAW | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_LICENSES | UPDATE_TIMESTAMP | RAW | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_LICENSES | SOURCE_SYSTEM | RAW | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

### 8. WEBINARS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | BZ_WEBINARS | WEBINAR_ID | RAW | WEBINARS | WEBINAR_ID | 1-1 Mapping |
| BRONZE | BZ_WEBINARS | HOST_ID | RAW | WEBINARS | HOST_ID | 1-1 Mapping |
| BRONZE | BZ_WEBINARS | WEBINAR_TOPIC | RAW | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| BRONZE | BZ_WEBINARS | START_TIME | RAW | WEBINARS | START_TIME | 1-1 Mapping |
| BRONZE | BZ_WEBINARS | END_TIME | RAW | WEBINARS | END_TIME | 1-1 Mapping |
| BRONZE | BZ_WEBINARS | REGISTRANTS | RAW | WEBINARS | REGISTRANTS | 1-1 Mapping |
| BRONZE | BZ_WEBINARS | LOAD_TIMESTAMP | RAW | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_WEBINARS | UPDATE_TIMESTAMP | RAW | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | BZ_WEBINARS | SOURCE_SYSTEM | RAW | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |

## Data Type Mapping

| Snowflake Raw Data Type | Bronze Layer Data Type | Notes |
|------------------------|------------------------|-------|
| VARCHAR(16777216) | VARCHAR(16777216) | No change - preserves original string data |
| NUMBER(38,0) | NUMBER(38,0) | No change - preserves integer precision |
| NUMBER(10,2) | NUMBER(10,2) | No change - preserves decimal precision for amounts |
| DATE | DATE | No change - preserves date format |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ(9) | No change - preserves timestamp precision |

## Metadata Management

### Standard Audit Fields

All Bronze layer tables include the following metadata fields inherited from the RAW layer:

1. **LOAD_TIMESTAMP**: Timestamp when the record was initially loaded into the system
2. **UPDATE_TIMESTAMP**: Timestamp when the record was last modified
3. **SOURCE_SYSTEM**: Identifier of the source system that provided the data

### Data Validation Rules

#### Primary Key Validation
- All primary key fields (IDs) must be NOT NULL and UNIQUE
- Referential integrity maintained through foreign key relationships

#### Data Quality Checks
- Email format validation for user records
- Date range validation (start_date <= end_date)
- Numeric field validation for amounts and counts
- Timestamp consistency checks (join_time <= leave_time)

#### Business Rule Validation
- Meeting duration must be positive
- License end date must be after start date
- Billing amounts must be non-negative for most event types
- Support ticket open date must be populated

## Data Lineage and Governance

### Source System Tracking
- Each record maintains SOURCE_SYSTEM identifier
- Load and update timestamps provide audit trail
- One-to-one mapping ensures data traceability

### Data Retention Policy
- Bronze layer retains all historical data
- No data purging at Bronze level
- Supports complete data reconstruction if needed

### Security and Access Control
- Bronze layer inherits security classifications from RAW layer
- Access controlled through Snowflake RBAC
- Sensitive fields (email, company) require appropriate permissions

## Implementation Notes

### ETL Process Requirements
1. **Incremental Loading**: Support for both full and incremental data loads
2. **Error Handling**: Robust error handling with detailed logging
3. **Data Validation**: Implement validation rules before Bronze layer insertion
4. **Monitoring**: Set up monitoring for data quality and load performance

### Performance Considerations
1. **Clustering Keys**: Implement appropriate clustering on date fields
2. **Partitioning**: Consider partitioning large tables by date
3. **Indexing**: Create indexes on frequently queried fields
4. **Compression**: Utilize Snowflake's automatic compression

### Future Extensibility
1. **Schema Evolution**: Design supports adding new fields without breaking existing processes
2. **New Source Systems**: Framework supports additional source system integration
3. **Metadata Enhancement**: Additional metadata fields can be added as needed

## Summary

This Bronze layer data mapping provides:
- Complete one-to-one mapping from RAW to BRONZE layer
- Preservation of original data structure and types
- Comprehensive metadata management
- Robust data validation framework
- Foundation for Silver layer transformations
- Full data lineage and audit capabilities

The Bronze layer serves as the reliable, auditable foundation for the Zoom Platform Analytics System's data pipeline, ensuring data integrity while preparing for downstream analytical transformations in the Silver and Gold layers.