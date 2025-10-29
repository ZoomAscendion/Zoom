_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Data Mapping for Zoom Platform Analytics System - Medallion Architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping

## Overview
This document provides the detailed data mapping between the RAW source layer and the Bronze layer in the Medallion architecture for the Zoom Platform Analytics System. The Bronze layer maintains raw data with minimal transformation, preserving the original structure while adding metadata for data lineage and processing.

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

## Data Type Mapping Summary

| Source Data Type | Target Data Type | Compatibility Notes |
|------------------|------------------|--------------------|
| VARCHAR(16777216) | VARCHAR(16777216) | Direct mapping - Snowflake compatible |
| NUMBER(10,2) | NUMBER(10,2) | Direct mapping - Monetary amounts |
| NUMBER(38,0) | NUMBER(38,0) | Direct mapping - Integer values |
| DATE | DATE | Direct mapping - Date fields |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ(9) | Direct mapping - Timestamp fields |

## Mapping Rules and Guidelines

### Bronze Layer Principles
1. **Raw Data Preservation**: All source data is preserved without transformation
2. **Metadata Addition**: Load and update timestamps maintained for data lineage
3. **Schema Consistency**: Source schema structure is maintained in Bronze layer
4. **Data Type Compatibility**: All data types are Snowflake-compatible
5. **Naming Convention**: Bronze tables use 'bz_' prefix for identification

### Transformation Rules
- **1-1 Mapping**: Direct field-to-field mapping with no data transformation
- **No Data Cleansing**: Raw data quality issues are preserved for Silver layer processing
- **No Business Rules**: Business logic transformations are deferred to Silver layer
- **Metadata Preservation**: All source system metadata fields are maintained

### Data Ingestion Specifications
- **Source Schema**: RAW
- **Target Schema**: BRONZE
- **Database**: DB_POC_ZOOM
- **Load Strategy**: Full load with incremental updates based on UPDATE_TIMESTAMP
- **Data Lineage**: Maintained through LOAD_TIMESTAMP and SOURCE_SYSTEM fields

## Quality Assurance Notes

### Data Validation
- Source-to-target field count validation
- Data type compatibility verification
- Null value handling as per source system
- Referential integrity preservation (without constraints)

### Assumptions
1. Source data in RAW layer is already validated for basic structure
2. All source tables contain the standard metadata fields (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM)
3. Bronze layer will not implement data quality rules or constraints
4. Data transformation and cleansing will be handled in Silver layer

### Dependencies
- RAW layer tables must exist and be populated
- Bronze layer physical data model must be deployed
- Appropriate Snowflake permissions for data movement between schemas

## Summary

This Bronze layer data mapping provides a complete 1-1 field mapping between the RAW source layer and Bronze target layer for the Zoom Platform Analytics System. The mapping covers all 8 core business entities:

1. **bz_billing_events** - Financial transaction data
2. **bz_feature_usage** - Platform feature utilization tracking
3. **bz_licenses** - License management and assignment
4. **bz_meetings** - Meeting session information
5. **bz_participants** - Meeting attendance details
6. **bz_support_tickets** - Customer support tracking
7. **bz_users** - User account information
8. **bz_webinars** - Webinar session data

The mapping ensures data lineage preservation, maintains raw data integrity, and provides the foundation for Silver layer transformations in the Medallion architecture implementation.