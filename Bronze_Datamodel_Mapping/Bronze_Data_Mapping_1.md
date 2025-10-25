_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Data Mapping for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping Document

**Author:** AAVA  
**Version:** 1.0  
**Description:** Bronze Layer Data Mapping for Zoom Platform Analytics System  
**Database:** DB_POC_ZOOM  
**Source Schema:** RAW  
**Target Schema:** BRONZE  
**Generated Date:** 2024  

---

## Overview

This document provides a comprehensive data mapping between the RAW layer and the Bronze layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Bronze layer preserves the original data structure from the RAW layer with minimal transformation, maintaining data lineage and ensuring data governance.

## Mapping Principles

- **1:1 Field Mapping**: Each source field maps directly to a corresponding target field
- **No Data Transformation**: Data is ingested as-is from the RAW layer
- **Naming Convention**: Bronze tables use 'bz_' prefix with lowercase naming
- **Data Preservation**: Original data types and structures are maintained
- **Metadata Retention**: All audit fields are preserved for data lineage

---

## Data Mapping Tables

### Table 1: USERS Mapping

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

### Table 2: MEETINGS Mapping

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

### Table 3: PARTICIPANTS Mapping

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

### Table 4: FEATURE_USAGE Mapping

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

### Table 5: SUPPORT_TICKETS Mapping

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

### Table 6: BILLING_EVENTS Mapping

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

### Table 7: LICENSES Mapping

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

### Table 8: WEBINARS Mapping

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

---

## Data Ingestion Process

### Raw Data Ingestion Rules

1. **Data Preservation**: All data from RAW layer is preserved without modification
2. **Field Mapping**: Direct 1:1 mapping between source and target fields
3. **Data Types**: Original data types are maintained in Bronze layer
4. **Null Handling**: NULL values are preserved as-is
5. **Timestamp Preservation**: All timestamp fields maintain original precision

### Metadata Management

1. **Load Timestamp**: Tracks when data was initially loaded into RAW layer
2. **Update Timestamp**: Tracks when data was last modified in RAW layer
3. **Source System**: Identifies the originating system for data lineage
4. **Data Lineage**: Full traceability from source system through RAW to Bronze

### Initial Data Validation Rules

1. **Schema Validation**: Ensure source schema matches expected structure
2. **Data Type Validation**: Verify data types align with target schema
3. **Primary Key Validation**: Ensure primary key fields are not null
4. **Referential Integrity**: Validate foreign key relationships where applicable
5. **Audit Field Validation**: Ensure all audit fields are populated

---

## Snowflake Implementation Details

### Bronze Layer Schema Structure

```sql
-- Bronze Schema Creation
CREATE SCHEMA IF NOT EXISTS BRONZE;

-- Example Bronze Table Creation (bz_users)
CREATE OR REPLACE TABLE BRONZE.bz_users (
    user_id VARCHAR(16777216) NOT NULL,
    user_name VARCHAR(16777216) NOT NULL,
    email VARCHAR(16777216) NOT NULL,
    company VARCHAR(16777216),
    plan_type VARCHAR(16777216) NOT NULL,
    load_timestamp TIMESTAMP_NTZ(9) NOT NULL,
    update_timestamp TIMESTAMP_NTZ(9) NOT NULL,
    source_system VARCHAR(16777216) NOT NULL
);
```

### Data Loading Pattern

```sql
-- Example Bronze Layer Insert Pattern
INSERT INTO BRONZE.bz_users
SELECT 
    USER_ID as user_id,
    USER_NAME as user_name,
    EMAIL as email,
    COMPANY as company,
    PLAN_TYPE as plan_type,
    LOAD_TIMESTAMP as load_timestamp,
    UPDATE_TIMESTAMP as update_timestamp,
    SOURCE_SYSTEM as source_system
FROM RAW.USERS;
```

---

## Summary

This Bronze Layer Data Mapping document provides:

- **Complete Field Mapping**: All 64 fields across 8 tables mapped 1:1
- **Data Preservation**: Original structure and data types maintained
- **Audit Trail**: Full metadata and lineage information preserved
- **Snowflake Compatibility**: SQL patterns optimized for Snowflake
- **Governance Framework**: Clear validation rules and data quality checks

The Bronze layer serves as the foundation for the Medallion architecture, ensuring raw data is preserved while providing a clean, governed entry point for downstream Silver and Gold layer transformations.

---

**Document Control**
- **Created By**: AAVA
- **Review Status**: Draft
- **Approval Status**: Pending
- **Next Review Date**: TBD
- **Version History**: v1.0 - Initial Creation