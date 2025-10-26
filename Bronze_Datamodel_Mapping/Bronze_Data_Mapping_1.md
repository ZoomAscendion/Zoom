_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Data Mapping for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping - Zoom Platform Analytics System

## Data Mapping for Bronze Layer

The mapping output is in tabular format with the following fields for each table and column:

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|
| Bronze | bz_billing_events | user_id | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | bz_billing_events | event_type | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | bz_billing_events | amount | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | bz_billing_events | event_date | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | bz_billing_events | load_timestamp | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | update_timestamp | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_billing_events | source_system | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_feature_usage | meeting_id | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | bz_feature_usage | feature_name | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | bz_feature_usage | usage_count | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | bz_feature_usage | usage_date | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | bz_feature_usage | load_timestamp | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | update_timestamp | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_feature_usage | source_system | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_licenses | license_type | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | bz_licenses | assigned_to_user_id | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | bz_licenses | start_date | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | bz_licenses | end_date | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | bz_licenses | load_timestamp | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | update_timestamp | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_licenses | source_system | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_meetings | host_id | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | bz_meetings | meeting_topic | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | bz_meetings | start_time | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | bz_meetings | end_time | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | bz_meetings | duration_minutes | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | bz_meetings | load_timestamp | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | update_timestamp | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_meetings | source_system | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_participants | meeting_id | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | bz_participants | user_id | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | bz_participants | join_time | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | bz_participants | leave_time | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | bz_participants | load_timestamp | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | update_timestamp | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_participants | source_system | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_support_tickets | user_id | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | bz_support_tickets | ticket_type | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | bz_support_tickets | resolution_status | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | bz_support_tickets | open_date | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | bz_support_tickets | load_timestamp | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | update_timestamp | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_support_tickets | source_system | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_users | user_name | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | bz_users | email | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | bz_users | company | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | bz_users | plan_type | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | bz_users | load_timestamp | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | update_timestamp | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_users | source_system | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |
| Bronze | bz_webinars | host_id | Source | WEBINARS | HOST_ID | 1-1 Mapping |
| Bronze | bz_webinars | webinar_topic | Source | WEBINARS | WEBINAR_TOPIC | 1-1 Mapping |
| Bronze | bz_webinars | start_time | Source | WEBINARS | START_TIME | 1-1 Mapping |
| Bronze | bz_webinars | end_time | Source | WEBINARS | END_TIME | 1-1 Mapping |
| Bronze | bz_webinars | registrants | Source | WEBINARS | REGISTRANTS | 1-1 Mapping |
| Bronze | bz_webinars | load_timestamp | Source | WEBINARS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_webinars | update_timestamp | Source | WEBINARS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | bz_webinars | source_system | Source | WEBINARS | SOURCE_SYSTEM | 1-1 Mapping |

## Mapping Summary

### Tables Mapped: 8
1. **bz_billing_events** - 7 fields mapped (excluding EVENT_ID primary key)
2. **bz_feature_usage** - 7 fields mapped (excluding USAGE_ID primary key)
3. **bz_licenses** - 7 fields mapped (excluding LICENSE_ID primary key)
4. **bz_meetings** - 8 fields mapped (excluding MEETING_ID primary key)
5. **bz_participants** - 7 fields mapped (excluding PARTICIPANT_ID primary key)
6. **bz_support_tickets** - 7 fields mapped (excluding TICKET_ID primary key)
7. **bz_users** - 7 fields mapped (excluding USER_ID primary key)
8. **bz_webinars** - 7 fields mapped (excluding WEBINAR_ID primary key)

### Total Fields Mapped: 57

### Key Design Principles:
- **1-1 Mapping:** All transformations preserve raw data structure with minimal changes
- **ID Field Exclusion:** Primary key ID fields are excluded from Bronze layer as per Medallion architecture best practices
- **Metadata Preservation:** All audit fields (load_timestamp, update_timestamp, source_system) are preserved
- **Naming Convention:** Bronze tables use 'bz_' prefix with lowercase naming convention
- **Data Lineage:** Clear mapping maintains traceability from RAW to BRONZE layer

### Data Validation Rules:
- All NOT NULL constraints from source tables should be preserved
- Data types remain consistent between RAW and BRONZE layers
- Foreign key relationships are maintained through business keys rather than surrogate keys
- Timestamp fields preserve original precision and timezone information

## Implementation Notes:
1. Bronze layer tables should be created with the same data types as RAW layer
2. ETL processes should implement 1-1 field mapping as specified
3. Data quality checks should validate successful field mapping
4. Audit trail should track all data movement from RAW to BRONZE
5. Error handling should capture and log any mapping failures