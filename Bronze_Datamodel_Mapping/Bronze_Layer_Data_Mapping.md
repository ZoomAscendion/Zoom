# Bronze Layer Data Mapping Document

## Metadata Header

| Field | Value |
|-------|-------|
| **Author** | AAVA |
| **Description** | Bronze layer data mapping for Zoom Platform Analytics System |
| **Version** | 1 |
| **Created on** | |
| **Updated on** | |

---

## Overview

This document provides comprehensive data mapping for the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer serves as the raw data ingestion layer, preserving the original structure while adding essential metadata for data governance and lineage tracking.

### Architecture Principles
- **Data Preservation**: Raw data structure is maintained with minimal transformation
- **Metadata Enhancement**: Additional Bronze-specific metadata columns for tracking and governance
- **1:1 Mapping**: Direct field-to-field mapping from Source (RAW) to Bronze layer
- **Data Lineage**: Clear traceability from source to Bronze layer

---

## Data Mapping Tables

### 1. BILLING_EVENTS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_billing_events | EVENT_ID | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | bz_billing_events | USER_ID | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | bz_billing_events | EVENT_TYPE | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | bz_billing_events | AMOUNT | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | bz_billing_events | EVENT_DATE | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | bz_billing_events | LOAD_TIMESTAMP | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | UPDATE_TIMESTAMP | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | SOURCE_SYSTEM | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_billing_events | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_billing_events | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_billing_events | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 2. FEATURE_USAGE Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_feature_usage | USAGE_ID | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | bz_feature_usage | MEETING_ID | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | bz_feature_usage | FEATURE_NAME | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | bz_feature_usage | USAGE_COUNT | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | bz_feature_usage | USAGE_DATE | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | bz_feature_usage | LOAD_TIMESTAMP | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | UPDATE_TIMESTAMP | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | SOURCE_SYSTEM | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_feature_usage | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_feature_usage | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_feature_usage | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 3. LICENSES Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_licenses | LICENSE_ID | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | bz_licenses | LICENSE_TYPE | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | bz_licenses | ASSIGNED_TO_USER_ID | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | bz_licenses | START_DATE | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | bz_licenses | END_DATE | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | bz_licenses | LOAD_TIMESTAMP | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | UPDATE_TIMESTAMP | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | SOURCE_SYSTEM | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_licenses | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_licenses | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_licenses | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 4. MEETINGS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_meetings | MEETING_ID | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | bz_meetings | HOST_ID | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | bz_meetings | MEETING_TOPIC | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | bz_meetings | START_TIME | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | bz_meetings | END_TIME | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | bz_meetings | DURATION_MINUTES | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | bz_meetings | LOAD_TIMESTAMP | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | UPDATE_TIMESTAMP | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | SOURCE_SYSTEM | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_meetings | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_meetings | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_meetings | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 5. PARTICIPANTS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_participants | PARTICIPANT_ID | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | bz_participants | MEETING_ID | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | bz_participants | USER_ID | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | bz_participants | JOIN_TIME | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | bz_participants | LEAVE_TIME | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | bz_participants | LOAD_TIMESTAMP | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | UPDATE_TIMESTAMP | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | SOURCE_SYSTEM | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_participants | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_participants | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_participants | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 6. SUPPORT_TICKETS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_support_tickets | TICKET_ID | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | bz_support_tickets | USER_ID | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | bz_support_tickets | TICKET_TYPE | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | bz_support_tickets | RESOLUTION_STATUS | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | bz_support_tickets | OPEN_DATE | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | bz_support_tickets | LOAD_TIMESTAMP | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | UPDATE_TIMESTAMP | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | SOURCE_SYSTEM | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_support_tickets | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_support_tickets | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_support_tickets | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 7. USERS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_users | USER_ID | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | bz_users | USER_NAME | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | bz_users | EMAIL | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | bz_users | COMPANY | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | bz_users | PLAN_TYPE | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | bz_users | LOAD_TIMESTAMP | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | UPDATE_TIMESTAMP | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | SOURCE_SYSTEM | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_users | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_users | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_users | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 8. WEBINARS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_webinars | WEBINAR_ID | Source | WEBINARS | WEBINAR_ID | 1-1 Mapping |
| Bronze | bz_webinars | HOST_ID | Source | WEBINARS | HOST_ID | 1-1 Mapping |
| Bronze | bz_webinars | WEBINAR_TOPIC | Source | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| Bronze | bz_webinars | START_TIME | Source | WEBINARS | START_TIME | 1-1 Mapping |
| Bronze | bz_webinars | END_TIME | Source | WEBINARS | END_TIME | 1-1 Mapping |
| Bronze | bz_webinars | REGISTRANTS | Source | WEBINARS | REGISTRANTS | 1-1 Mapping |
| Bronze | bz_webinars | LOAD_TIMESTAMP | Source | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_webinars | UPDATE_TIMESTAMP | Source | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_webinars | SOURCE_SYSTEM | Source | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_webinars | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_webinars | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_webinars | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

---

## Bronze Layer Metadata Columns

### Additional Metadata Fields

| Column Name | Data Type | Purpose | Population Rule |
|-------------|-----------|---------|----------------|
| **bronze_load_timestamp** | TIMESTAMP_NTZ(9) | Tracks when record was loaded into Bronze layer | System generated using CURRENT_TIMESTAMP() |
| **bronze_update_timestamp** | TIMESTAMP_NTZ(9) | Tracks when record was last updated in Bronze layer | System generated using CURRENT_TIMESTAMP() |
| **record_hash** | VARCHAR(64) | Provides data integrity check and change detection | System generated using SHA2 hash of concatenated source columns |

---

## Data Validation Rules

### Initial Data Validation

1. **Null Validation**: Ensure primary key fields are not null
2. **Data Type Validation**: Verify data types match source schema definitions
3. **Referential Integrity**: Validate foreign key relationships where applicable
4. **Duplicate Detection**: Check for duplicate records based on primary keys
5. **Hash Validation**: Ensure record_hash is properly generated for each record

### Metadata Management

1. **Load Timestamp**: Must be populated for every record insertion
2. **Update Timestamp**: Must be updated on every record modification
3. **Record Hash**: Must be recalculated on any data change
4. **Source System**: Must retain original source system identifier

---

## Raw Data Ingestion Process

### Ingestion Pipeline

1. **Extract**: Pull data from RAW schema tables
2. **Validate**: Apply initial data validation rules
3. **Transform**: Apply minimal transformations (1:1 mapping)
4. **Enhance**: Add Bronze layer metadata columns
5. **Load**: Insert/Update records in Bronze schema tables
6. **Audit**: Log ingestion statistics and any data quality issues

### Data Lineage Tracking

- **Source Tracking**: Maintain SOURCE_SYSTEM from original data
- **Load Tracking**: Record bronze_load_timestamp for audit trail
- **Change Tracking**: Use record_hash for change detection
- **Update Tracking**: Maintain bronze_update_timestamp for modification history

---

## Summary

This Bronze Layer Data Mapping document establishes a comprehensive framework for ingesting raw data from the Source (RAW) layer into the Bronze layer of the Medallion architecture. The mapping ensures:

- **Data Preservation**: All source data is preserved without modification
- **Enhanced Metadata**: Additional tracking and governance capabilities
- **Data Quality**: Built-in validation and integrity checks
- **Audit Trail**: Complete lineage and change tracking
- **Scalability**: Consistent patterns across all entity types

The Bronze layer serves as the foundation for downstream Silver and Gold layer transformations while maintaining the integrity and traceability of the original raw data.