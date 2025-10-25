_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Data Mapping for Zoom Platform Analytics System following medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping - Zoom Platform Analytics System

## Overview

This document provides comprehensive data mapping from the RAW layer to the BRONZE layer for the Zoom Platform Analytics System following medallion architecture principles. The Bronze layer serves as the first transformation layer that preserves raw data structure while removing primary keys and foreign keys as per medallion architecture standards.

## Architecture Principles

- **1-to-1 Field Mapping**: Bronze layer maintains direct field mapping from RAW layer
- **Data Preservation**: Raw data structure and values are preserved without transformation
- **Key Removal**: Primary keys and foreign keys are excluded from Bronze layer
- **Metadata Retention**: All audit fields (load_timestamp, update_timestamp, source_system) are preserved
- **Naming Convention**: Bronze tables use 'bz_' prefix with lowercase field names

## Source and Target Layer Information

**Source Layer**: DB_POC_ZOOM.RAW  
**Target Layer**: DB_POC_ZOOM.BRONZE

## Data Mapping Tables

### 1. BILLING_EVENTS → bz_billing_events

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| BRONZE | bz_billing_events | event_type | RAW | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| BRONZE | bz_billing_events | amount | RAW | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| BRONZE | bz_billing_events | event_date | RAW | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| BRONZE | bz_billing_events | load_timestamp | RAW | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_billing_events | update_timestamp | RAW | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_billing_events | source_system | RAW | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 2. FEATURE_USAGE → bz_feature_usage

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| BRONZE | bz_feature_usage | feature_name | RAW | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| BRONZE | bz_feature_usage | usage_count | RAW | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| BRONZE | bz_feature_usage | usage_date | RAW | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| BRONZE | bz_feature_usage | load_timestamp | RAW | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_feature_usage | update_timestamp | RAW | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_feature_usage | source_system | RAW | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 3. LICENSES → bz_licenses

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| BRONZE | bz_licenses | license_type | RAW | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| BRONZE | bz_licenses | start_date | RAW | LICENSES | START_DATE | 1-1 Mapping |
| BRONZE | bz_licenses | end_date | RAW | LICENSES | END_DATE | 1-1 Mapping |
| BRONZE | bz_licenses | load_timestamp | RAW | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_licenses | update_timestamp | RAW | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_licenses | source_system | RAW | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

### 4. MEETINGS → bz_meetings

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| BRONZE | bz_meetings | meeting_topic | RAW | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| BRONZE | bz_meetings | start_time | RAW | MEETINGS | START_TIME | 1-1 Mapping |
| BRONZE | bz_meetings | end_time | RAW | MEETINGS | END_TIME | 1-1 Mapping |
| BRONZE | bz_meetings | duration_minutes | RAW | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| BRONZE | bz_meetings | load_timestamp | RAW | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_meetings | update_timestamp | RAW | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_meetings | source_system | RAW | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 5. PARTICIPANTS → bz_participants

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| BRONZE | bz_participants | join_time | RAW | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| BRONZE | bz_participants | leave_time | RAW | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| BRONZE | bz_participants | load_timestamp | RAW | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_participants | update_timestamp | RAW | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_participants | source_system | RAW | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 6. SUPPORT_TICKETS → bz_support_tickets

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| BRONZE | bz_support_tickets | ticket_type | RAW | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| BRONZE | bz_support_tickets | resolution_status | RAW | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| BRONZE | bz_support_tickets | open_date | RAW | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| BRONZE | bz_support_tickets | load_timestamp | RAW | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_support_tickets | update_timestamp | RAW | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_support_tickets | source_system | RAW | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 7. USERS → bz_users

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| BRONZE | bz_users | user_name | RAW | USERS | USER_NAME | 1-1 Mapping |
| BRONZE | bz_users | email | RAW | USERS | EMAIL | 1-1 Mapping |
| BRONZE | bz_users | company | RAW | USERS | COMPANY | 1-1 Mapping |
| BRONZE | bz_users | plan_type | RAW | USERS | PLAN_TYPE | 1-1 Mapping |
| BRONZE | bz_users | load_timestamp | RAW | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_users | update_timestamp | RAW | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_users | source_system | RAW | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 8. WEBINARS → bz_webinars

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| BRONZE | bz_webinars | webinar_topic | RAW | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| BRONZE | bz_webinars | start_time | RAW | WEBINARS | START_TIME | 1-1 Mapping |
| BRONZE | bz_webinars | end_time | RAW | WEBINARS | END_TIME | 1-1 Mapping |
| BRONZE | bz_webinars | registrants | RAW | WEBINARS | REGISTRANTS | 1-1 Mapping |
| BRONZE | bz_webinars | load_timestamp | RAW | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_webinars | update_timestamp | RAW | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_webinars | source_system | RAW | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |

## Excluded Fields (As Per Medallion Architecture)

The following fields from the RAW layer are **NOT** mapped to the Bronze layer as they represent primary keys and foreign keys, which are excluded per medallion architecture principles:

### Primary Keys (Excluded)
- BILLING_EVENTS.EVENT_ID
- FEATURE_USAGE.USAGE_ID
- LICENSES.LICENSE_ID
- MEETINGS.MEETING_ID
- PARTICIPANTS.PARTICIPANT_ID
- SUPPORT_TICKETS.TICKET_ID
- USERS.USER_ID
- WEBINARS.WEBINAR_ID

### Foreign Keys (Excluded)
- BILLING_EVENTS.USER_ID
- FEATURE_USAGE.MEETING_ID
- LICENSES.ASSIGNED_TO_USER_ID
- MEETINGS.HOST_ID
- PARTICIPANTS.MEETING_ID, USER_ID
- SUPPORT_TICKETS.USER_ID
- WEBINARS.HOST_ID

## Data Validation Rules

### Initial Data Validation Rules for Bronze Layer

1. **Data Completeness**: Ensure all non-null fields from RAW layer maintain their non-null constraint in Bronze layer
2. **Data Type Consistency**: Maintain original data types from RAW layer
3. **Timestamp Validation**: Ensure load_timestamp and update_timestamp are valid timestamps
4. **Source System Tracking**: Verify source_system field is populated for all records
5. **Date Range Validation**: Ensure date fields contain valid date values within expected ranges
6. **Numeric Validation**: Validate numeric fields (amount, usage_count, duration_minutes, registrants) are non-negative where applicable

## Metadata Management

### Audit Fields Preserved
All Bronze layer tables maintain the following audit fields from the RAW layer:
- **load_timestamp**: Timestamp when record was initially loaded
- **update_timestamp**: Timestamp when record was last modified
- **source_system**: Identifier of the originating system

### Data Lineage
- **Source Database**: DB_POC_ZOOM
- **Source Schema**: RAW
- **Target Database**: DB_POC_ZOOM
- **Target Schema**: BRONZE
- **Transformation Type**: 1-to-1 Field Mapping (No Business Logic Applied)
- **Data Retention**: Bronze layer retains all business data from RAW layer (excluding keys)

## Summary

This Bronze layer data mapping document establishes the foundation for the medallion architecture implementation by:

1. **Preserving Raw Data**: Maintaining data integrity and original values from source systems
2. **Standardizing Structure**: Implementing consistent naming conventions and removing architectural constraints
3. **Enabling Downstream Processing**: Providing clean, key-free data structure for Silver layer transformations
4. **Maintaining Audit Trail**: Preserving all metadata fields for data governance and lineage tracking

The Bronze layer serves as the reliable foundation for all downstream analytics and reporting requirements in the Zoom Platform Analytics System.