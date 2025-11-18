_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System preserving raw data structure with 1-to-1 mapping
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping for Zoom Platform Analytics System

## Overview
This document defines the data mapping between the source RAW layer and the Bronze layer in the Medallion architecture for the Zoom Platform Analytics System. The Bronze layer preserves the original structure of raw data with minimal transformation, ensuring data lineage and maintaining audit capabilities.

## Data Mapping Tables

### 1. USERS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_USERS | USER_ID | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | BRZ_USERS | USER_NAME | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | BRZ_USERS | EMAIL | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | BRZ_USERS | COMPANY | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | BRZ_USERS | PLAN_TYPE | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | BRZ_USERS | LOAD_TIMESTAMP | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_USERS | UPDATE_TIMESTAMP | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_USERS | SOURCE_SYSTEM | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 2. MEETINGS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_MEETINGS | MEETING_ID | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | HOST_ID | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | MEETING_TOPIC | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | START_TIME | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | END_TIME | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | DURATION_MINUTES | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | LOAD_TIMESTAMP | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | UPDATE_TIMESTAMP | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | SOURCE_SYSTEM | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 3. PARTICIPANTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_PARTICIPANTS | PARTICIPANT_ID | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | MEETING_ID | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | USER_ID | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | JOIN_TIME | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | LEAVE_TIME | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | LOAD_TIMESTAMP | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | UPDATE_TIMESTAMP | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | SOURCE_SYSTEM | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 4. FEATURE_USAGE Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_FEATURE_USAGE | USAGE_ID | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | MEETING_ID | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | FEATURE_NAME | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | USAGE_COUNT | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | USAGE_DATE | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | LOAD_TIMESTAMP | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | SOURCE_SYSTEM | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 5. SUPPORT_TICKETS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_SUPPORT_TICKETS | TICKET_ID | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | USER_ID | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | TICKET_TYPE | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | OPEN_DATE | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 6. BILLING_EVENTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_BILLING_EVENTS | EVENT_ID | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | USER_ID | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | EVENT_TYPE | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | AMOUNT | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | EVENT_DATE | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | LOAD_TIMESTAMP | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | SOURCE_SYSTEM | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 7. LICENSES Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_LICENSES | LICENSE_ID | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | BRZ_LICENSES | LICENSE_TYPE | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | BRZ_LICENSES | ASSIGNED_TO_USER_ID | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | BRZ_LICENSES | START_DATE | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | BRZ_LICENSES | END_DATE | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | BRZ_LICENSES | LOAD_TIMESTAMP | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_LICENSES | UPDATE_TIMESTAMP | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_LICENSES | SOURCE_SYSTEM | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

## Data Ingestion Details

### Data Type Compatibility
All data types from the source RAW layer are preserved in the Bronze layer:
- **VARCHAR(16777216)**: Maintained for all text fields to preserve original data without truncation
- **NUMBER(10,2)**: Preserved for monetary amounts with decimal precision
- **NUMBER(38,0)**: Maintained for integer values like counts and durations
- **DATE**: Preserved for date fields
- **TIMESTAMP_NTZ(9)**: Maintained for timestamp fields with nanosecond precision

### Metadata Management
- **LOAD_TIMESTAMP**: Tracks when each record was initially loaded into the system
- **UPDATE_TIMESTAMP**: Tracks the last modification time for each record
- **SOURCE_SYSTEM**: Identifies the originating system for data lineage

### Initial Data Validation Rules
1. **Primary Key Validation**: Ensure all primary key fields (IDs) are not null and unique
2. **Foreign Key Validation**: Validate referential integrity between related tables
3. **Data Type Validation**: Ensure all fields conform to their defined data types
4. **Timestamp Validation**: Verify LOAD_TIMESTAMP and UPDATE_TIMESTAMP are valid timestamps
5. **Source System Validation**: Ensure SOURCE_SYSTEM field is populated for all records

### Data Ingestion Process
1. **Extract**: Pull data from source systems into RAW layer
2. **Load**: Transfer data from RAW to Bronze layer with 1-to-1 mapping
3. **Validate**: Apply initial validation rules without transformation
4. **Audit**: Log all ingestion activities for data governance
5. **Monitor**: Track data quality metrics and ingestion performance

## Assumptions and Notes
- Bronze layer tables are prefixed with 'BRZ_' to distinguish from RAW layer
- No data cleansing or business rule transformations are applied at Bronze layer
- All source data structure and content are preserved for downstream processing
- Data validation focuses on technical integrity rather than business rules
- Incremental loading strategies will be implemented based on UPDATE_TIMESTAMP
- Error handling will quarantine invalid records for investigation

## Data Lineage
The Bronze layer serves as the foundation for:
- **Silver Layer**: Where data cleansing and business rule application will occur
- **Gold Layer**: Where aggregated and business-ready data will be stored
- **Data Governance**: Providing complete audit trail from source to consumption

## Snowflake Implementation Notes
- Tables will be created in the BRONZE schema within the DB_POC_ZOOM database
- Clustering keys will be applied on frequently queried fields like USER_ID and MEETING_ID
- Time travel features will be enabled for data recovery capabilities
- Secure views will be created for data access control
- Stream objects will be configured for change data capture to Silver layer