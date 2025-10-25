_____________________________________________
## *Author*: AAVA
## *Version*: 4
## *Description*: Updated schema naming conventions to align with raw schema - Bronze layer data mapping for Zoom Platform Analytics System - Medallion Architecture Implementation
## *Created on*: 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping - Zoom Platform Analytics System

## Overview

This document provides comprehensive data mapping for the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer serves as the raw data ingestion layer, preserving the original structure of source data while adding essential metadata for data governance and lineage tracking.

## Architecture Details

- **Source Layer**: zoom_raw_schema Schema (DB_POC_ZOOM.zoom_raw_schema)
- **Target Layer**: zoom_bronze_schema Schema (DB_POC_ZOOM.zoom_bronze_schema)
- **Mapping Type**: One-to-One (1:1) with metadata enhancement
- **Data Transformation**: No business logic transformations, raw data preservation

## Naming Conventions

- **Source Schema**: zoom_raw_schema
- **Target Schema**: zoom_bronze_schema
- **Table Prefix**: BZ_ (Bronze layer identifier)
- **Metadata Fields**: LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM

## Data Mapping Tables

### 1. USERS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| zoom_bronze_schema | BZ_USERS | USER_ID | zoom_raw_schema | USERS | USER_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_USERS | USER_NAME | zoom_raw_schema | USERS | USER_NAME | 1-1 Mapping |
| zoom_bronze_schema | BZ_USERS | EMAIL | zoom_raw_schema | USERS | EMAIL | 1-1 Mapping |
| zoom_bronze_schema | BZ_USERS | COMPANY | zoom_raw_schema | USERS | COMPANY | 1-1 Mapping |
| zoom_bronze_schema | BZ_USERS | PLAN_TYPE | zoom_raw_schema | USERS | PLAN_TYPE | 1-1 Mapping |
| zoom_bronze_schema | BZ_USERS | LOAD_TIMESTAMP | zoom_raw_schema | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_USERS | UPDATE_TIMESTAMP | zoom_raw_schema | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_USERS | SOURCE_SYSTEM | zoom_raw_schema | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 2. MEETINGS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| zoom_bronze_schema | BZ_MEETINGS | MEETING_ID | zoom_raw_schema | MEETINGS | MEETING_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_MEETINGS | HOST_ID | zoom_raw_schema | MEETINGS | HOST_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_MEETINGS | MEETING_TOPIC | zoom_raw_schema | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| zoom_bronze_schema | BZ_MEETINGS | START_TIME | zoom_raw_schema | MEETINGS | START_TIME | 1-1 Mapping |
| zoom_bronze_schema | BZ_MEETINGS | END_TIME | zoom_raw_schema | MEETINGS | END_TIME | 1-1 Mapping |
| zoom_bronze_schema | BZ_MEETINGS | DURATION_MINUTES | zoom_raw_schema | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| zoom_bronze_schema | BZ_MEETINGS | LOAD_TIMESTAMP | zoom_raw_schema | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_MEETINGS | UPDATE_TIMESTAMP | zoom_raw_schema | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_MEETINGS | SOURCE_SYSTEM | zoom_raw_schema | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 3. PARTICIPANTS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| zoom_bronze_schema | BZ_PARTICIPANTS | PARTICIPANT_ID | zoom_raw_schema | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_PARTICIPANTS | MEETING_ID | zoom_raw_schema | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_PARTICIPANTS | USER_ID | zoom_raw_schema | PARTICIPANTS | USER_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_PARTICIPANTS | JOIN_TIME | zoom_raw_schema | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| zoom_bronze_schema | BZ_PARTICIPANTS | LEAVE_TIME | zoom_raw_schema | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| zoom_bronze_schema | BZ_PARTICIPANTS | LOAD_TIMESTAMP | zoom_raw_schema | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | zoom_raw_schema | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_PARTICIPANTS | SOURCE_SYSTEM | zoom_raw_schema | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 4. FEATURE_USAGE Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| zoom_bronze_schema | BZ_FEATURE_USAGE | USAGE_ID | zoom_raw_schema | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_FEATURE_USAGE | MEETING_ID | zoom_raw_schema | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_FEATURE_USAGE | FEATURE_NAME | zoom_raw_schema | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| zoom_bronze_schema | BZ_FEATURE_USAGE | USAGE_COUNT | zoom_raw_schema | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| zoom_bronze_schema | BZ_FEATURE_USAGE | USAGE_DATE | zoom_raw_schema | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| zoom_bronze_schema | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | zoom_raw_schema | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | zoom_raw_schema | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_FEATURE_USAGE | SOURCE_SYSTEM | zoom_raw_schema | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 5. SUPPORT_TICKETS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| zoom_bronze_schema | BZ_SUPPORT_TICKETS | TICKET_ID | zoom_raw_schema | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_SUPPORT_TICKETS | USER_ID | zoom_raw_schema | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_SUPPORT_TICKETS | TICKET_TYPE | zoom_raw_schema | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| zoom_bronze_schema | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | zoom_raw_schema | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| zoom_bronze_schema | BZ_SUPPORT_TICKETS | OPEN_DATE | zoom_raw_schema | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| zoom_bronze_schema | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | zoom_raw_schema | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | zoom_raw_schema | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | zoom_raw_schema | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 6. BILLING_EVENTS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| zoom_bronze_schema | BZ_BILLING_EVENTS | EVENT_ID | zoom_raw_schema | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_BILLING_EVENTS | USER_ID | zoom_raw_schema | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_BILLING_EVENTS | EVENT_TYPE | zoom_raw_schema | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| zoom_bronze_schema | BZ_BILLING_EVENTS | AMOUNT | zoom_raw_schema | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| zoom_bronze_schema | BZ_BILLING_EVENTS | EVENT_DATE | zoom_raw_schema | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| zoom_bronze_schema | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | zoom_raw_schema | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | zoom_raw_schema | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_BILLING_EVENTS | SOURCE_SYSTEM | zoom_raw_schema | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 7. LICENSES Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| zoom_bronze_schema | BZ_LICENSES | LICENSE_ID | zoom_raw_schema | LICENSES | LICENSE_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_LICENSES | LICENSE_TYPE | zoom_raw_schema | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| zoom_bronze_schema | BZ_LICENSES | ASSIGNED_TO_USER_ID | zoom_raw_schema | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_LICENSES | START_DATE | zoom_raw_schema | LICENSES | START_DATE | 1-1 Mapping |
| zoom_bronze_schema | BZ_LICENSES | END_DATE | zoom_raw_schema | LICENSES | END_DATE | 1-1 Mapping |
| zoom_bronze_schema | BZ_LICENSES | LOAD_TIMESTAMP | zoom_raw_schema | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_LICENSES | UPDATE_TIMESTAMP | zoom_raw_schema | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_LICENSES | SOURCE_SYSTEM | zoom_raw_schema | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

### 8. WEBINARS Entity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| zoom_bronze_schema | BZ_WEBINARS | WEBINAR_ID | zoom_raw_schema | WEBINARS | WEBINAR_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_WEBINARS | HOST_ID | zoom_raw_schema | WEBINARS | HOST_ID | 1-1 Mapping |
| zoom_bronze_schema | BZ_WEBINARS | WEBINAR_TOPIC | zoom_raw_schema | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| zoom_bronze_schema | BZ_WEBINARS | START_TIME | zoom_raw_schema | WEBINARS | START_TIME | 1-1 Mapping |
| zoom_bronze_schema | BZ_WEBINARS | END_TIME | zoom_raw_schema | WEBINARS | END_TIME | 1-1 Mapping |
| zoom_bronze_schema | BZ_WEBINARS | REGISTRANTS | zoom_raw_schema | WEBINARS | REGISTRANTS | 1-1 Mapping |
| zoom_bronze_schema | BZ_WEBINARS | LOAD_TIMESTAMP | zoom_raw_schema | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_WEBINARS | UPDATE_TIMESTAMP | zoom_raw_schema | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| zoom_bronze_schema | BZ_WEBINARS | SOURCE_SYSTEM | zoom_raw_schema | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |

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

All Bronze layer tables include the following metadata fields inherited from the zoom_raw_schema layer:

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
- Bronze layer inherits security classifications from zoom_raw_schema layer
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
- Complete one-to-one mapping from zoom_raw_schema to zoom_bronze_schema layer
- Preservation of original data structure and types
- Comprehensive metadata management
- Robust data validation framework
- Foundation for Silver layer transformations
- Full data lineage and audit capabilities

The Bronze layer serves as the reliable, auditable foundation for the Zoom Platform Analytics System's data pipeline, ensuring data integrity while preparing for downstream analytical transformations in the Silver and Gold layers.