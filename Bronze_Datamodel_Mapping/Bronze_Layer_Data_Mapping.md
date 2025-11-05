# Bronze Layer Data Mapping Document

## Metadata
- **Author:** AAVA
- **Version:** 1.0
- **Description:** Bronze layer data mapping for Zoom Platform Analytics System following Medallion architecture standards
- **Creation Date:** 2024-12-19
- **Database:** DB_POC_ZOOM
- **Source Schema:** RAW
- **Target Schema:** BRONZE

## Overview

This document defines the comprehensive data mapping from the RAW layer to the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer serves as the first transformation layer that ingests raw data while preserving its original structure, removing primary keys and foreign keys but retaining all business data.

## Architecture Principles

- **Data Preservation:** All business-relevant data from RAW layer is preserved
- **Key Removal:** Primary keys and foreign keys are removed in Bronze layer
- **Minimal Transformation:** Bronze layer applies minimal transformations (1-1 mapping)
- **Metadata Retention:** Load timestamps, update timestamps, and source system information are maintained
- **Data Quality:** Initial data validation rules are applied during ingestion

## Data Mapping Tables

### 1. BILLING_EVENTS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_billing_events | EVENT_TYPE | RAW | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | bz_billing_events | AMOUNT | RAW | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | bz_billing_events | EVENT_DATE | RAW | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | bz_billing_events | LOAD_TIMESTAMP | RAW | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | UPDATE_TIMESTAMP | RAW | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | SOURCE_SYSTEM | RAW | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** EVENT_ID (Primary Key), USER_ID (Foreign Key)

### 2. FEATURE_USAGE Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_feature_usage | FEATURE_NAME | RAW | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | bz_feature_usage | USAGE_COUNT | RAW | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | bz_feature_usage | USAGE_DATE | RAW | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | bz_feature_usage | LOAD_TIMESTAMP | RAW | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | UPDATE_TIMESTAMP | RAW | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | SOURCE_SYSTEM | RAW | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** USAGE_ID (Primary Key), MEETING_ID (Foreign Key)

### 3. LICENSES Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_licenses | LICENSE_TYPE | RAW | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | bz_licenses | START_DATE | RAW | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | bz_licenses | END_DATE | RAW | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | bz_licenses | LOAD_TIMESTAMP | RAW | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | UPDATE_TIMESTAMP | RAW | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | SOURCE_SYSTEM | RAW | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** LICENSE_ID (Primary Key), ASSIGNED_TO_USER_ID (Foreign Key)

### 4. MEETINGS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_meetings | MEETING_TOPIC | RAW | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | bz_meetings | START_TIME | RAW | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | bz_meetings | END_TIME | RAW | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | bz_meetings | DURATION_MINUTES | RAW | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | bz_meetings | LOAD_TIMESTAMP | RAW | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | UPDATE_TIMESTAMP | RAW | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | SOURCE_SYSTEM | RAW | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** MEETING_ID (Primary Key), HOST_ID (Foreign Key)

### 5. PARTICIPANTS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_participants | JOIN_TIME | RAW | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | bz_participants | LEAVE_TIME | RAW | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | bz_participants | LOAD_TIMESTAMP | RAW | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | UPDATE_TIMESTAMP | RAW | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | SOURCE_SYSTEM | RAW | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** PARTICIPANT_ID (Primary Key), MEETING_ID (Foreign Key), USER_ID (Foreign Key)

### 6. SUPPORT_TICKETS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_support_tickets | TICKET_TYPE | RAW | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | bz_support_tickets | RESOLUTION_STATUS | RAW | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | bz_support_tickets | OPEN_DATE | RAW | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | bz_support_tickets | LOAD_TIMESTAMP | RAW | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | UPDATE_TIMESTAMP | RAW | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | SOURCE_SYSTEM | RAW | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** TICKET_ID (Primary Key), USER_ID (Foreign Key)

### 7. USERS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | bz_users | USER_NAME | RAW | USERS | USER_NAME | 1-1 Mapping |
| Bronze | bz_users | EMAIL | RAW | USERS | EMAIL | 1-1 Mapping |
| Bronze | bz_users | COMPANY | RAW | USERS | COMPANY | 1-1 Mapping |
| Bronze | bz_users | PLAN_TYPE | RAW | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | bz_users | LOAD_TIMESTAMP | RAW | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | UPDATE_TIMESTAMP | RAW | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | SOURCE_SYSTEM | RAW | USERS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** USER_ID (Primary Key)

## Data Validation Rules

### Initial Data Validation Rules for Bronze Layer

1. **Null Value Validation:**
   - Ensure NOT NULL constraints are maintained for critical business fields
   - LOAD_TIMESTAMP must never be null
   - SOURCE_SYSTEM must never be null

2. **Data Type Validation:**
   - Validate date fields are in proper DATE format
   - Validate timestamp fields are in proper TIMESTAMP_NTZ format
   - Validate numeric fields (AMOUNT, USAGE_COUNT, DURATION_MINUTES) are numeric

3. **Domain Value Validation:**
   - EVENT_TYPE: Must be one of (charge, credit, refund, adjustment)
   - FEATURE_NAME: Must be one of (screen_share, recording, chat, breakout_rooms, whiteboard)
   - LICENSE_TYPE: Must be one of (Basic, Pro, Business, Enterprise, Education)
   - PLAN_TYPE: Must be one of (Basic, Pro, Business, Enterprise, Education)
   - TICKET_TYPE: Must be one of (technical_issue, billing_inquiry, feature_request, account_access)
   - RESOLUTION_STATUS: Must be one of (open, in_progress, resolved, closed, escalated)

4. **Business Logic Validation:**
   - END_TIME should be greater than START_TIME for meetings
   - LEAVE_TIME should be greater than JOIN_TIME for participants
   - END_DATE should be greater than START_DATE for licenses
   - AMOUNT should be a valid monetary value (can be negative for credits/refunds)

## Metadata Management

### Audit Fields
All Bronze layer tables maintain the following audit fields from the source:
- **LOAD_TIMESTAMP:** Preserves the original load timestamp from RAW layer
- **UPDATE_TIMESTAMP:** Preserves the last update timestamp from RAW layer
- **SOURCE_SYSTEM:** Maintains traceability to the originating system

### Data Lineage
- **Source Layer:** RAW
- **Target Layer:** Bronze
- **Transformation Type:** Minimal (1-1 Mapping with key removal)
- **Processing Frequency:** Real-time/Batch as per source system

## Implementation Notes

1. **Schema Naming Convention:** Bronze tables use 'bz_' prefix followed by the source table name in lowercase
2. **Data Types:** Maintain same data types as source RAW layer
3. **Constraints:** Remove all primary key and foreign key constraints
4. **Indexes:** No indexes required at Bronze layer for optimal ingestion performance
5. **Partitioning:** Consider partitioning by date fields for large tables (meetings, participants, billing_events)

## Quality Assurance

### Data Quality Checks
1. **Completeness:** Verify all expected records are loaded from RAW to Bronze
2. **Accuracy:** Validate data values match between RAW and Bronze layers
3. **Consistency:** Ensure data types and formats are consistent
4. **Timeliness:** Monitor data freshness and loading frequency

### Monitoring and Alerting
1. **Failed Validations:** Alert on validation rule failures
2. **Data Volume Anomalies:** Monitor for unexpected data volume changes
3. **Processing Delays:** Alert on delayed data processing
4. **Schema Changes:** Monitor for schema drift in source systems

## Summary

This Bronze layer data mapping ensures:
- **Complete Data Preservation:** All business data from RAW layer is preserved
- **Architectural Compliance:** Follows Medallion architecture principles
- **Data Quality:** Implements initial validation rules
- **Traceability:** Maintains full data lineage and audit trail
- **Scalability:** Designed for efficient data processing and storage

The Bronze layer serves as the foundation for downstream Silver and Gold layer transformations while maintaining the raw data integrity and providing a reliable source for analytics and reporting.