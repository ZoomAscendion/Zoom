# Bronze Layer Data Mapping for Zoom Platform Analytics System

**Author:** AAVA  
**Version:** 1  
**Description:** Bronze Layer Data Mapping for Zoom Platform Analytics System  
**Date:** 2024-12-19  
**Source Schema:** RAW  
**Target Schema:** BRONZE  

## Overview

This document provides a comprehensive data mapping between the source RAW schema and the Bronze layer tables in the Medallion architecture implementation for Snowflake. The Bronze layer preserves the original structure of raw data while enabling efficient data processing and governance.

## Data Mapping Tables

### 1. Users Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | bz_users | USER_ID | RAW | USERS | USER_ID | 1-1 Mapping |
| BRONZE | bz_users | USER_NAME | RAW | USERS | USER_NAME | 1-1 Mapping |
| BRONZE | bz_users | EMAIL | RAW | USERS | EMAIL | 1-1 Mapping |
| BRONZE | bz_users | COMPANY | RAW | USERS | COMPANY | 1-1 Mapping |
| BRONZE | bz_users | PLAN_TYPE | RAW | USERS | PLAN_TYPE | 1-1 Mapping |
| BRONZE | bz_users | LOAD_TIMESTAMP | RAW | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_users | UPDATE_TIMESTAMP | RAW | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_users | SOURCE_SYSTEM | RAW | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 2. Meetings Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | bz_meetings | MEETING_ID | RAW | MEETINGS | MEETING_ID | 1-1 Mapping |
| BRONZE | bz_meetings | HOST_ID | RAW | MEETINGS | HOST_ID | 1-1 Mapping |
| BRONZE | bz_meetings | MEETING_TOPIC | RAW | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| BRONZE | bz_meetings | START_TIME | RAW | MEETINGS | START_TIME | 1-1 Mapping |
| BRONZE | bz_meetings | END_TIME | RAW | MEETINGS | END_TIME | 1-1 Mapping |
| BRONZE | bz_meetings | DURATION_MINUTES | RAW | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| BRONZE | bz_meetings | LOAD_TIMESTAMP | RAW | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_meetings | UPDATE_TIMESTAMP | RAW | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_meetings | SOURCE_SYSTEM | RAW | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 3. Participants Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | bz_participants | PARTICIPANT_ID | RAW | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| BRONZE | bz_participants | MEETING_ID | RAW | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| BRONZE | bz_participants | USER_ID | RAW | PARTICIPANTS | USER_ID | 1-1 Mapping |
| BRONZE | bz_participants | JOIN_TIME | RAW | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| BRONZE | bz_participants | LEAVE_TIME | RAW | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| BRONZE | bz_participants | LOAD_TIMESTAMP | RAW | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_participants | UPDATE_TIMESTAMP | RAW | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_participants | SOURCE_SYSTEM | RAW | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 4. Feature Usage Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | bz_feature_usage | USAGE_ID | RAW | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| BRONZE | bz_feature_usage | MEETING_ID | RAW | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| BRONZE | bz_feature_usage | FEATURE_NAME | RAW | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| BRONZE | bz_feature_usage | USAGE_COUNT | RAW | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| BRONZE | bz_feature_usage | USAGE_DATE | RAW | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| BRONZE | bz_feature_usage | LOAD_TIMESTAMP | RAW | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_feature_usage | UPDATE_TIMESTAMP | RAW | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_feature_usage | SOURCE_SYSTEM | RAW | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 5. Support Tickets Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | bz_support_tickets | TICKET_ID | RAW | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| BRONZE | bz_support_tickets | USER_ID | RAW | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| BRONZE | bz_support_tickets | TICKET_TYPE | RAW | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| BRONZE | bz_support_tickets | RESOLUTION_STATUS | RAW | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| BRONZE | bz_support_tickets | OPEN_DATE | RAW | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| BRONZE | bz_support_tickets | LOAD_TIMESTAMP | RAW | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_support_tickets | UPDATE_TIMESTAMP | RAW | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_support_tickets | SOURCE_SYSTEM | RAW | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 6. Billing Events Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | bz_billing_events | EVENT_ID | RAW | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| BRONZE | bz_billing_events | USER_ID | RAW | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| BRONZE | bz_billing_events | EVENT_TYPE | RAW | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| BRONZE | bz_billing_events | AMOUNT | RAW | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| BRONZE | bz_billing_events | EVENT_DATE | RAW | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| BRONZE | bz_billing_events | LOAD_TIMESTAMP | RAW | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_billing_events | UPDATE_TIMESTAMP | RAW | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_billing_events | SOURCE_SYSTEM | RAW | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 7. Licenses Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| BRONZE | bz_licenses | LICENSE_ID | RAW | LICENSES | LICENSE_ID | 1-1 Mapping |
| BRONZE | bz_licenses | LICENSE_TYPE | RAW | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| BRONZE | bz_licenses | ASSIGNED_TO_USER_ID | RAW | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| BRONZE | bz_licenses | START_DATE | RAW | LICENSES | START_DATE | 1-1 Mapping |
| BRONZE | bz_licenses | END_DATE | RAW | LICENSES | END_DATE | 1-1 Mapping |
| BRONZE | bz_licenses | LOAD_TIMESTAMP | RAW | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_licenses | UPDATE_TIMESTAMP | RAW | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| BRONZE | bz_licenses | SOURCE_SYSTEM | RAW | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

## Data Ingestion Process

### Raw Data Ingestion Rules

1. **Data Preservation**: All source data fields are preserved in their original format and structure
2. **Metadata Management**: Each Bronze table maintains the original metadata fields (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM)
3. **Data Validation**: Basic data type validation is performed during ingestion
4. **Error Handling**: Invalid records are logged and stored in separate error tables for investigation

### Initial Data Validation Rules

#### 1. Primary Key Validation
- **bz_users**: USER_ID must be unique and not null
- **bz_meetings**: MEETING_ID must be unique and not null
- **bz_participants**: PARTICIPANT_ID must be unique and not null
- **bz_feature_usage**: USAGE_ID must be unique and not null
- **bz_support_tickets**: TICKET_ID must be unique and not null
- **bz_billing_events**: EVENT_ID must be unique and not null
- **bz_licenses**: LICENSE_ID must be unique and not null

#### 2. Foreign Key Validation
- **bz_meetings.HOST_ID** must exist in **bz_users.USER_ID**
- **bz_participants.MEETING_ID** must exist in **bz_meetings.MEETING_ID**
- **bz_participants.USER_ID** must exist in **bz_users.USER_ID**
- **bz_feature_usage.MEETING_ID** must exist in **bz_meetings.MEETING_ID**
- **bz_support_tickets.USER_ID** must exist in **bz_users.USER_ID**
- **bz_billing_events.USER_ID** must exist in **bz_users.USER_ID**
- **bz_licenses.ASSIGNED_TO_USER_ID** must exist in **bz_users.USER_ID**

#### 3. Data Type Validation
- **Timestamp fields**: Must be valid timestamp format (TIMESTAMP_NTZ)
- **Date fields**: Must be valid date format (DATE)
- **Numeric fields**: Must be valid numeric values
- **VARCHAR fields**: Must not exceed maximum length constraints

#### 4. Business Rule Validation
- **Meeting duration**: END_TIME must be greater than START_TIME when both are present
- **Participant timing**: LEAVE_TIME must be greater than JOIN_TIME when both are present
- **License validity**: END_DATE must be greater than START_DATE when both are present
- **Billing amounts**: AMOUNT must be greater than or equal to 0

## Metadata Management

### System Metadata Fields

All Bronze tables include the following metadata fields for data lineage and governance:

- **LOAD_TIMESTAMP**: Timestamp when the record was first loaded into the Bronze layer
- **UPDATE_TIMESTAMP**: Timestamp when the record was last updated in the Bronze layer
- **SOURCE_SYSTEM**: Identifier of the source system that provided the data

### Data Lineage Tracking

- Source-to-target field mapping is maintained in this document
- Data transformation rules are documented for each field
- Change history is tracked through UPDATE_TIMESTAMP fields
- Source system identification is preserved through SOURCE_SYSTEM fields

## Implementation Notes

1. **Schema Naming Convention**: RAW schema maps to BRONZE schema following the established naming pattern
2. **Table Naming Convention**: RAW tables are prefixed with 'bz_' in the Bronze layer (e.g., USERS → bz_users)
3. **Field Naming Convention**: All field names remain identical between RAW and Bronze layers
4. **Data Types**: All data types are preserved exactly as defined in the source RAW schema
5. **Constraints**: Primary key, foreign key, and null constraints are maintained in the Bronze layer

## Quality Assurance

### Data Quality Checks

1. **Completeness**: Verify all source records are successfully loaded
2. **Accuracy**: Validate data integrity through constraint checking
3. **Consistency**: Ensure referential integrity across related tables
4. **Timeliness**: Monitor data freshness through LOAD_TIMESTAMP tracking

### Monitoring and Alerting

- Failed data validation rules trigger alerts
- Data volume anomalies are monitored and reported
- Processing time metrics are tracked for performance optimization
- Data quality scorecards are generated for stakeholder reporting

---

**Document Control**
- **Created**: 2024-12-19
- **Last Modified**: 2024-12-19
- **Next Review**: 2025-01-19
- **Approved By**: AAVA
