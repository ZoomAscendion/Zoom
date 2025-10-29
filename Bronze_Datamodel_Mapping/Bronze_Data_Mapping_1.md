_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping Document

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
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_billing_events | event_id | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | bz_billing_events | user_id | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | bz_billing_events | event_type | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | bz_billing_events | amount | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | bz_billing_events | event_date | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | bz_billing_events | load_timestamp | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | update_timestamp | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | source_system | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_billing_events | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_billing_events | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_billing_events | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 2. FEATURE_USAGE Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_feature_usage | usage_id | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | bz_feature_usage | meeting_id | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | bz_feature_usage | feature_name | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | bz_feature_usage | usage_count | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | bz_feature_usage | usage_date | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | bz_feature_usage | load_timestamp | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | update_timestamp | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | source_system | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_feature_usage | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_feature_usage | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_feature_usage | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 3. LICENSES Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_licenses | license_id | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | bz_licenses | license_type | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | bz_licenses | assigned_to_user_id | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | bz_licenses | start_date | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | bz_licenses | end_date | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | bz_licenses | load_timestamp | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | update_timestamp | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | source_system | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_licenses | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_licenses | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_licenses | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 4. MEETINGS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_meetings | meeting_id | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | bz_meetings | host_id | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | bz_meetings | meeting_topic | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | bz_meetings | start_time | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | bz_meetings | end_time | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | bz_meetings | duration_minutes | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | bz_meetings | load_timestamp | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | update_timestamp | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | source_system | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_meetings | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_meetings | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_meetings | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 5. PARTICIPANTS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_participants | participant_id | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | bz_participants | meeting_id | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | bz_participants | user_id | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | bz_participants | join_time | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | bz_participants | leave_time | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | bz_participants | load_timestamp | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | update_timestamp | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | source_system | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_participants | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_participants | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_participants | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 6. SUPPORT_TICKETS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_support_tickets | ticket_id | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | bz_support_tickets | user_id | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | bz_support_tickets | ticket_type | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | bz_support_tickets | resolution_status | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | bz_support_tickets | open_date | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | bz_support_tickets | load_timestamp | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | update_timestamp | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | source_system | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_support_tickets | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_support_tickets | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_support_tickets | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 7. USERS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_users | user_id | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | bz_users | user_name | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | bz_users | email | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | bz_users | company | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | bz_users | plan_type | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | bz_users | load_timestamp | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | update_timestamp | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | source_system | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_users | bronze_load_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_users | bronze_update_timestamp | Bronze | System Generated | CURRENT_TIMESTAMP() | System Generated |
| Bronze | bz_users | record_hash | Bronze | System Generated | SHA2(CONCAT_WS('|', columns)) | System Generated |

### 8. WEBINARS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_webinars | webinar_id | Source | WEBINARS | WEBINAR_ID | 1-1 Mapping |
| Bronze | bz_webinars | host_id | Source | WEBINARS | HOST_ID | 1-1 Mapping |
| Bronze | bz_webinars | webinar_topic | Source | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| Bronze | bz_webinars | start_time | Source | WEBINARS | START_TIME | 1-1 Mapping |
| Bronze | bz_webinars | end_time | Source | WEBINARS | END_TIME | 1-1 Mapping |
| Bronze | bz_webinars | registrants | Source | WEBINARS | REGISTRANTS | 1-1 Mapping |
| Bronze | bz_webinars | load_timestamp | Source | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_webinars | update_timestamp | Source | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_webinars | source_system | Source | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |
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