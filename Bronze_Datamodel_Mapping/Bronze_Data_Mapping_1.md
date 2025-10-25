_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Data Mapping for Zoom Platform Analytics System - Medallion Architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping - Zoom Platform Analytics System

## Overview

This document provides a comprehensive data mapping between the RAW source layer and the Bronze layer in the Medallion architecture for the Zoom Platform Analytics System. The Bronze layer serves as the first transformation layer, maintaining raw data structure while adding standardized metadata and audit fields.

## Source and Target Layer Information

- **Source Database**: DB_POC_ZOOM
- **Source Schema**: RAW
- **Target Database**: DB_POC_ZOOM
- **Target Schema**: BRONZE
- **Architecture Pattern**: Medallion Architecture - RAW to Bronze Layer Mapping
- **Transformation Type**: 1-1 Mapping with minimal transformation

## Data Mapping Tables

### 1. Users Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_users | user_id | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | bz_users | user_name | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | bz_users | email | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | bz_users | company | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | bz_users | plan_type | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | bz_users | registration_date | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping (Derived from load timestamp) |
| Bronze | bz_users | load_timestamp | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | update_timestamp | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | source_system | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 2. Meetings Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_meetings | meeting_id | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | bz_meetings | host_id | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | bz_meetings | meeting_title | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | bz_meetings | duration_minutes | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | bz_meetings | start_time | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | bz_meetings | end_time | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | bz_meetings | meeting_type | Source | MEETINGS | N/A | Derived field (Default: 'Scheduled') |
| Bronze | bz_meetings | host_name | Source | MEETINGS | HOST_ID | Lookup from USERS table |
| Bronze | bz_meetings | load_timestamp | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | update_timestamp | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | source_system | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 3. Attendees Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_attendees | participant_id | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | bz_attendees | meeting_id | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | bz_attendees | user_id | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | bz_attendees | participant_name | Source | PARTICIPANTS | USER_ID | Lookup from USERS table |
| Bronze | bz_attendees | join_time | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | bz_attendees | leave_time | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | bz_attendees | attendance_duration | Source | PARTICIPANTS | LEAVE_TIME - JOIN_TIME | Calculated field (minutes) |
| Bronze | bz_attendees | load_timestamp | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_attendees | update_timestamp | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_attendees | source_system | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 4. Feature Usage Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_feature_usage | usage_id | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | bz_feature_usage | meeting_id | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | bz_feature_usage | feature_name | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | bz_feature_usage | usage_count | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | bz_feature_usage | usage_duration | Source | FEATURE_USAGE | N/A | Derived field (Default: NULL) |
| Bronze | bz_feature_usage | usage_date | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | bz_feature_usage | load_timestamp | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | update_timestamp | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | source_system | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 5. Support Tickets Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_support_tickets | ticket_id | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | bz_support_tickets | user_id | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | bz_support_tickets | ticket_type | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | bz_support_tickets | issue_description | Source | SUPPORT_TICKETS | N/A | Derived field (Default: 'Issue details pending') |
| Bronze | bz_support_tickets | priority_level | Source | SUPPORT_TICKETS | N/A | Derived field (Default: 'Medium') |
| Bronze | bz_support_tickets | resolution_status | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | bz_support_tickets | open_date | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | bz_support_tickets | close_date | Source | SUPPORT_TICKETS | N/A | Derived field (Default: NULL) |
| Bronze | bz_support_tickets | assigned_agent | Source | SUPPORT_TICKETS | N/A | Derived field (Default: 'Unassigned') |
| Bronze | bz_support_tickets | load_timestamp | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | update_timestamp | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | source_system | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 6. Billing Events Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_billing_events | event_id | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | bz_billing_events | user_id | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | bz_billing_events | event_type | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | bz_billing_events | amount | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | bz_billing_events | currency | Source | BILLING_EVENTS | N/A | Derived field (Default: 'USD') |
| Bronze | bz_billing_events | transaction_date | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | bz_billing_events | payment_method | Source | BILLING_EVENTS | N/A | Derived field (Default: 'Credit Card') |
| Bronze | bz_billing_events | load_timestamp | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | update_timestamp | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | source_system | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 7. Licenses Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_licenses | license_id | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | bz_licenses | license_type | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | bz_licenses | assigned_to_user_id | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | bz_licenses | assigned_user_name | Source | LICENSES | ASSIGNED_TO_USER_ID | Lookup from USERS table |
| Bronze | bz_licenses | start_date | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | bz_licenses | end_date | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | bz_licenses | license_status | Source | LICENSES | N/A | Derived field (Default: 'Active') |
| Bronze | bz_licenses | load_timestamp | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | update_timestamp | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | source_system | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

### 8. Webinars Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_webinars | webinar_id | Source | WEBINARS | WEBINAR_ID | 1-1 Mapping |
| Bronze | bz_webinars | host_id | Source | WEBINARS | HOST_ID | 1-1 Mapping |
| Bronze | bz_webinars | webinar_topic | Source | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| Bronze | bz_webinars | start_time | Source | WEBINARS | START_TIME | 1-1 Mapping |
| Bronze | bz_webinars | end_time | Source | WEBINARS | END_TIME | 1-1 Mapping |
| Bronze | bz_webinars | registrants | Source | WEBINARS | REGISTRANTS | 1-1 Mapping |
| Bronze | bz_webinars | load_timestamp | Source | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_webinars | update_timestamp | Source | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_webinars | source_system | Source | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |

### 9. Audit Log Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_audit_log | record_id | Source | N/A | N/A | Auto-generated (AUTOINCREMENT) |
| Bronze | bz_audit_log | source_table | Source | N/A | N/A | Derived from processing context |
| Bronze | bz_audit_log | operation_type | Source | N/A | N/A | Derived from processing context |
| Bronze | bz_audit_log | record_count | Source | N/A | N/A | Calculated during processing |
| Bronze | bz_audit_log | load_timestamp | Source | N/A | N/A | Current timestamp |
| Bronze | bz_audit_log | processed_by | Source | N/A | N/A | System identifier |
| Bronze | bz_audit_log | processing_time | Source | N/A | N/A | Calculated processing duration |
| Bronze | bz_audit_log | status | Source | N/A | N/A | Processing result status |
| Bronze | bz_audit_log | error_message | Source | N/A | N/A | Error details if applicable |
| Bronze | bz_audit_log | source_system | Source | N/A | N/A | 'BRONZE_LAYER_PROCESSOR' |

## Data Transformation Rules Summary

### 1-1 Mapping Rules
- **Direct Copy**: Most fields are directly copied from source to target with no transformation
- **Data Type Preservation**: All source data types are maintained in Bronze layer
- **Null Handling**: Null values are preserved as-is from source

### Derived Field Rules
- **registration_date**: Derived from LOAD_TIMESTAMP in USERS table
- **meeting_type**: Default value 'Scheduled' for all meetings
- **host_name**: Lookup from USERS table using HOST_ID
- **participant_name**: Lookup from USERS table using USER_ID
- **attendance_duration**: Calculated as LEAVE_TIME - JOIN_TIME in minutes
- **usage_duration**: Default NULL (to be enhanced in Silver layer)
- **issue_description**: Default 'Issue details pending'
- **priority_level**: Default 'Medium'
- **close_date**: Default NULL
- **assigned_agent**: Default 'Unassigned'
- **currency**: Default 'USD'
- **payment_method**: Default 'Credit Card'
- **license_status**: Default 'Active'

### Lookup Rules
- **User Name Lookups**: Join with USERS table on USER_ID to get USER_NAME
- **Host Name Resolution**: Join MEETINGS.HOST_ID with USERS.USER_ID to get USER_NAME

## Data Quality Considerations

### Source Data Assumptions
- All primary keys (IDs) are unique and not null
- Timestamp fields follow consistent format
- Foreign key relationships are maintained
- Source system field is populated for all records

### Bronze Layer Enhancements
- Added audit trail fields for data lineage
- Standardized naming conventions with 'bz_' prefix
- Enhanced metadata for better data governance
- Prepared structure for Silver layer transformations

## Implementation Notes

### ETL Process
1. **Extract**: Read from RAW schema tables
2. **Transform**: Apply 1-1 mappings and derive calculated fields
3. **Load**: Insert/Update Bronze schema tables
4. **Audit**: Log processing statistics in bz_audit_log

### Performance Considerations
- Use MERGE statements for upsert operations
- Implement incremental loading based on UPDATE_TIMESTAMP
- Consider partitioning large tables by date fields
- Index on frequently joined fields (USER_ID, MEETING_ID)

### Data Lineage
- All records maintain source_system field
- Load and update timestamps preserved
- Audit log tracks all processing activities
- Full traceability from RAW to Bronze layer

---

**Document Information**
- **Created**: 2024
- **Author**: AAVA
- **Version**: 1.0
- **Purpose**: Bronze Layer Data Mapping for Medallion Architecture
- **Next Layer**: Silver Layer (Business Rules and Data Quality)

---

*This mapping document serves as the definitive guide for implementing the Bronze layer data transformation pipeline in the Zoom Platform Analytics System.*