_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Zoom Platform Analytics System following Medallion architecture standards
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping for Zoom Platform Analytics System

## Data Mapping for Bronze Layer

The mapping output shows the detailed field-level mapping between the Source (RAW) layer and the Bronze layer tables. This follows the Medallion architecture principles where the Bronze layer preserves raw data with minimal transformation while removing primary keys and foreign keys.

### 1. BILLING_EVENTS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_billing_events | EVENT_TYPE | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | bz_billing_events | AMOUNT | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | bz_billing_events | EVENT_DATE | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | bz_billing_events | LOAD_TIMESTAMP | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | UPDATE_TIMESTAMP | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | SOURCE_SYSTEM | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** EVENT_ID (Primary Key), USER_ID (Foreign Key)

### 2. FEATURE_USAGE Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_feature_usage | FEATURE_NAME | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | bz_feature_usage | USAGE_COUNT | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | bz_feature_usage | USAGE_DATE | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | bz_feature_usage | LOAD_TIMESTAMP | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | UPDATE_TIMESTAMP | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | SOURCE_SYSTEM | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** USAGE_ID (Primary Key), MEETING_ID (Foreign Key)

### 3. LICENSES Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_licenses | LICENSE_TYPE | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | bz_licenses | START_DATE | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | bz_licenses | END_DATE | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | bz_licenses | LOAD_TIMESTAMP | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | UPDATE_TIMESTAMP | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | SOURCE_SYSTEM | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** LICENSE_ID (Primary Key), ASSIGNED_TO_USER_ID (Foreign Key)

### 4. MEETINGS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_meetings | MEETING_TOPIC | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | bz_meetings | START_TIME | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | bz_meetings | END_TIME | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | bz_meetings | DURATION_MINUTES | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | bz_meetings | LOAD_TIMESTAMP | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | UPDATE_TIMESTAMP | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | SOURCE_SYSTEM | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** MEETING_ID (Primary Key), HOST_ID (Foreign Key)

### 5. PARTICIPANTS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_participants | JOIN_TIME | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | bz_participants | LEAVE_TIME | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | bz_participants | LOAD_TIMESTAMP | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | UPDATE_TIMESTAMP | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | SOURCE_SYSTEM | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** PARTICIPANT_ID (Primary Key), MEETING_ID (Foreign Key), USER_ID (Foreign Key)

### 6. SUPPORT_TICKETS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_support_tickets | TICKET_TYPE | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | bz_support_tickets | RESOLUTION_STATUS | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | bz_support_tickets | OPEN_DATE | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | bz_support_tickets | LOAD_TIMESTAMP | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | UPDATE_TIMESTAMP | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | SOURCE_SYSTEM | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** TICKET_ID (Primary Key), USER_ID (Foreign Key)

### 7. USERS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Bronze | bz_users | USER_NAME | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | bz_users | EMAIL | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | bz_users | COMPANY | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | bz_users | PLAN_TYPE | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | bz_users | LOAD_TIMESTAMP | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | UPDATE_TIMESTAMP | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | SOURCE_SYSTEM | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |

**Excluded Fields:** USER_ID (Primary Key)

## Summary

### Mapping Statistics
- **Total Source Tables:** 7
- **Total Bronze Tables:** 7
- **Total Field Mappings:** 42
- **Transformation Type:** 1-1 Mapping (No transformations)
- **Excluded Fields:** Primary Keys and Foreign Keys removed as per Bronze layer design

### Key Design Principles
1. **Data Preservation:** All business data from source tables is preserved in Bronze layer
2. **Key Removal:** Primary keys and foreign keys are excluded to follow Medallion architecture
3. **Minimal Transformation:** Bronze layer maintains raw data structure with 1-1 field mapping
4. **Audit Trail:** All tables retain LOAD_TIMESTAMP, UPDATE_TIMESTAMP, and SOURCE_SYSTEM for data lineage
5. **Naming Convention:** Bronze tables use 'bz_' prefix followed by source table name in lowercase

### Data Quality Considerations
- Bronze layer retains raw data with minimal transformation
- No data cleansing, validations, or business rules applied at this layer
- Data quality improvements will be handled in downstream Silver layer
- Maintains compatibility with Snowflake SQL and data types

This mapping ensures that the Bronze layer serves as a reliable foundation for the Medallion architecture, preserving all source data while preparing it for further transformation in the Silver and Gold layers.