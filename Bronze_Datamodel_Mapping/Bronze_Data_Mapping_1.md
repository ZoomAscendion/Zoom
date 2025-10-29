_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19   
## *Description*: Bronze Layer Data Mapping for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Bronze Layer Data Mapping for Zoom Platform Analytics System

## Overview
This document provides comprehensive data mapping specifications for the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer serves as the raw data ingestion layer that preserves the original structure and metadata from source systems while ensuring data lineage and traceability.

## Architecture Context
- **Source Layer**: RAW Schema (DB_POC_ZOOM.RAW)
- **Target Layer**: BRONZE Schema (DB_POC_ZOOM.BRONZE)
- **Mapping Type**: 1-to-1 Direct Mapping
- **Transformation Rule**: No transformations applied, preserving raw data structure

## Data Mapping Specifications

### 1. BILLING_EVENTS Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_Billing_Events | EVENT_ID | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | Bz_Billing_Events | USER_ID | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | Bz_Billing_Events | EVENT_TYPE | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | Bz_Billing_Events | AMOUNT | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | Bz_Billing_Events | EVENT_DATE | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | Bz_Billing_Events | LOAD_TIMESTAMP | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Billing_Events | UPDATE_TIMESTAMP | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Billing_Events | SOURCE_SYSTEM | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types:**
- EVENT_ID: VARCHAR(16777216)
- USER_ID: VARCHAR(16777216)
- EVENT_TYPE: VARCHAR(16777216)
- AMOUNT: NUMBER(10,2)
- EVENT_DATE: DATE
- LOAD_TIMESTAMP: TIMESTAMP_NTZ(9)
- UPDATE_TIMESTAMP: TIMESTAMP_NTZ(9)
- SOURCE_SYSTEM: VARCHAR(16777216)

### 2. FEATURE_USAGE Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_Feature_Usage | USAGE_ID | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | Bz_Feature_Usage | MEETING_ID | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | Bz_Feature_Usage | FEATURE_NAME | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | Bz_Feature_Usage | USAGE_COUNT | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | Bz_Feature_Usage | USAGE_DATE | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | Bz_Feature_Usage | LOAD_TIMESTAMP | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Feature_Usage | UPDATE_TIMESTAMP | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Feature_Usage | SOURCE_SYSTEM | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types:**
- USAGE_ID: VARCHAR(16777216)
- MEETING_ID: VARCHAR(16777216)
- FEATURE_NAME: VARCHAR(16777216)
- USAGE_COUNT: NUMBER(38,0)
- USAGE_DATE: DATE
- LOAD_TIMESTAMP: TIMESTAMP_NTZ(9)
- UPDATE_TIMESTAMP: TIMESTAMP_NTZ(9)
- SOURCE_SYSTEM: VARCHAR(16777216)

### 3. LICENSES Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_Licenses | LICENSE_ID | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | Bz_Licenses | LICENSE_TYPE | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | Bz_Licenses | ASSIGNED_TO_USER_ID | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | Bz_Licenses | START_DATE | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | Bz_Licenses | END_DATE | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | Bz_Licenses | LOAD_TIMESTAMP | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Licenses | UPDATE_TIMESTAMP | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Licenses | SOURCE_SYSTEM | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types:**
- LICENSE_ID: VARCHAR(16777216)
- LICENSE_TYPE: VARCHAR(16777216)
- ASSIGNED_TO_USER_ID: VARCHAR(16777216)
- START_DATE: DATE
- END_DATE: DATE
- LOAD_TIMESTAMP: TIMESTAMP_NTZ(9)
- UPDATE_TIMESTAMP: TIMESTAMP_NTZ(9)
- SOURCE_SYSTEM: VARCHAR(16777216)

### 4. MEETINGS Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_Meetings | MEETING_ID | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | Bz_Meetings | HOST_ID | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | Bz_Meetings | MEETING_TOPIC | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | Bz_Meetings | START_TIME | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | Bz_Meetings | END_TIME | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | Bz_Meetings | DURATION_MINUTES | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | Bz_Meetings | LOAD_TIMESTAMP | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Meetings | UPDATE_TIMESTAMP | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Meetings | SOURCE_SYSTEM | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types:**
- MEETING_ID: VARCHAR(16777216)
- HOST_ID: VARCHAR(16777216)
- MEETING_TOPIC: VARCHAR(16777216)
- START_TIME: TIMESTAMP_NTZ(9)
- END_TIME: TIMESTAMP_NTZ(9)
- DURATION_MINUTES: NUMBER(38,0)
- LOAD_TIMESTAMP: TIMESTAMP_NTZ(9)
- UPDATE_TIMESTAMP: TIMESTAMP_NTZ(9)
- SOURCE_SYSTEM: VARCHAR(16777216)

### 5. PARTICIPANTS Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_Participants | PARTICIPANT_ID | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | Bz_Participants | MEETING_ID | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | Bz_Participants | USER_ID | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | Bz_Participants | JOIN_TIME | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | Bz_Participants | LEAVE_TIME | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | Bz_Participants | LOAD_TIMESTAMP | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Participants | UPDATE_TIMESTAMP | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Participants | SOURCE_SYSTEM | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types:**
- PARTICIPANT_ID: VARCHAR(16777216)
- MEETING_ID: VARCHAR(16777216)
- USER_ID: VARCHAR(16777216)
- JOIN_TIME: TIMESTAMP_NTZ(9)
- LEAVE_TIME: TIMESTAMP_NTZ(9)
- LOAD_TIMESTAMP: TIMESTAMP_NTZ(9)
- UPDATE_TIMESTAMP: TIMESTAMP_NTZ(9)
- SOURCE_SYSTEM: VARCHAR(16777216)

### 6. SUPPORT_TICKETS Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_Support_Tickets | TICKET_ID | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | Bz_Support_Tickets | USER_ID | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | Bz_Support_Tickets | TICKET_TYPE | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | Bz_Support_Tickets | RESOLUTION_STATUS | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | Bz_Support_Tickets | OPEN_DATE | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | Bz_Support_Tickets | LOAD_TIMESTAMP | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Support_Tickets | UPDATE_TIMESTAMP | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Support_Tickets | SOURCE_SYSTEM | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types:**
- TICKET_ID: VARCHAR(16777216)
- USER_ID: VARCHAR(16777216)
- TICKET_TYPE: VARCHAR(16777216)
- RESOLUTION_STATUS: VARCHAR(16777216)
- OPEN_DATE: DATE
- LOAD_TIMESTAMP: TIMESTAMP_NTZ(9)
- UPDATE_TIMESTAMP: TIMESTAMP_NTZ(9)
- SOURCE_SYSTEM: VARCHAR(16777216)

### 7. USERS Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_Users | USER_ID | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | Bz_Users | USER_NAME | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | Bz_Users | EMAIL | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | Bz_Users | COMPANY | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | Bz_Users | PLAN_TYPE | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | Bz_Users | LOAD_TIMESTAMP | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Users | UPDATE_TIMESTAMP | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Users | SOURCE_SYSTEM | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types:**
- USER_ID: VARCHAR(16777216)
- USER_NAME: VARCHAR(16777216)
- EMAIL: VARCHAR(16777216)
- COMPANY: VARCHAR(16777216)
- PLAN_TYPE: VARCHAR(16777216)
- LOAD_TIMESTAMP: TIMESTAMP_NTZ(9)
- UPDATE_TIMESTAMP: TIMESTAMP_NTZ(9)
- SOURCE_SYSTEM: VARCHAR(16777216)

### 8. WEBINARS Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | Bz_Webinars | WEBINAR_ID | Source | WEBINARS | WEBINAR_ID | 1-1 Mapping |
| Bronze | Bz_Webinars | HOST_ID | Source | WEBINARS | HOST_ID | 1-1 Mapping |
| Bronze | Bz_Webinars | WEBINAR_TOPIC | Source | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| Bronze | Bz_Webinars | START_TIME | Source | WEBINARS | START_TIME | 1-1 Mapping |
| Bronze | Bz_Webinars | END_TIME | Source | WEBINARS | END_TIME | 1-1 Mapping |
| Bronze | Bz_Webinars | REGISTRANTS | Source | WEBINARS | REGISTRANTS | 1-1 Mapping |
| Bronze | Bz_Webinars | LOAD_TIMESTAMP | Source | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Webinars | UPDATE_TIMESTAMP | Source | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | Bz_Webinars | SOURCE_SYSTEM | Source | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types:**
- WEBINAR_ID: VARCHAR(16777216)
- HOST_ID: VARCHAR(16777216)
- WEBINAR_TOPIC: VARCHAR(16777216)
- START_TIME: TIMESTAMP_NTZ(9)
- END_TIME: TIMESTAMP_NTZ(9)
- REGISTRANTS: NUMBER(38,0)
- LOAD_TIMESTAMP: TIMESTAMP_NTZ(9)
- UPDATE_TIMESTAMP: TIMESTAMP_NTZ(9)
- SOURCE_SYSTEM: VARCHAR(16777216)

## Data Ingestion Specifications

### Ingestion Process Guidelines
1. **Data Preservation**: All source data fields are preserved without modification
2. **Metadata Retention**: Load timestamps, update timestamps, and source system information are maintained
3. **Data Type Compatibility**: All data types are Snowflake-compatible and match source specifications
4. **No Transformations**: Bronze layer maintains raw data structure with no business logic applied
5. **Schema Naming**: Bronze tables use 'Bz_' prefix following medallion architecture conventions

### Data Validation Rules
1. **Completeness Check**: Ensure all source fields are mapped to Bronze layer
2. **Data Type Validation**: Verify data type compatibility between source and target
3. **Null Handling**: Preserve null values as-is from source systems
4. **Timestamp Consistency**: Maintain original timestamp formats and precision

### Metadata Management
- **LOAD_TIMESTAMP**: Tracks when data was initially loaded into the system
- **UPDATE_TIMESTAMP**: Tracks when data was last modified
- **SOURCE_SYSTEM**: Identifies the originating system for data lineage

## Implementation Notes

### Assumptions
1. Source RAW schema exists in DB_POC_ZOOM.RAW
2. Target BRONZE schema will be created in DB_POC_ZOOM.BRONZE
3. All source tables are accessible and contain the specified structure
4. Data ingestion will be performed using Snowflake-compatible SQL operations

### Data Lineage
- **Source**: DB_POC_ZOOM.RAW.{TABLE_NAME}
- **Target**: DB_POC_ZOOM.BRONZE.Bz_{TABLE_NAME}
- **Mapping Type**: Direct 1-to-1 field mapping
- **Transformation**: None (raw data preservation)

### Quality Assurance
1. **Field Count Validation**: Ensure all source fields are mapped
2. **Data Type Verification**: Confirm Snowflake compatibility
3. **Naming Convention**: Verify 'Bz_' prefix usage
4. **Metadata Inclusion**: Confirm all metadata fields are preserved

## Summary
This Bronze Layer Data Mapping document provides comprehensive specifications for implementing the raw data ingestion layer in the Zoom Platform Analytics System's Medallion architecture. The mapping ensures complete preservation of source data structure while establishing a solid foundation for downstream Silver and Gold layer transformations.