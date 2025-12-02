_____________________________________________
## *Author*: AAVA
## *Created on*: 2025-12-02
## *Description*: Bronze Layer Logical Data Model for Medallion Architecture
## *Version*: 4
## *Updated on*: 2025-12-02
## *Changes*: Created version 4 as requested
## *Reason*: User requested to create version 4 of the Bronze logical data model
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### Identified PII Fields:

| Column Name | Table | PII Classification | Reason |
|-------------|-------|-------------------|--------|
| EMAIL | Bz_USERS | High Sensitivity PII | Contains personal email addresses that can directly identify individuals |
| USER_NAME | Bz_USERS | Medium Sensitivity PII | Display names that may contain personal identifiable information |
| COMPANY | Bz_USERS | Low Sensitivity PII | Company affiliation can be used to identify individuals in smaller organizations |
| MEETING_TOPIC | Bz_MEETINGS | Low Sensitivity PII | May contain sensitive business or personal meeting information |

## 2. Bronze Layer Logical Model

### 2.1 Bz_BILLING_EVENTS
**Description**: Stores all billing events and transactions from source systems in raw format

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| EVENT_TYPE | Type of billing event that occurred | VARCHAR(16777216) |
| AMOUNT | Monetary amount associated with the billing event | VARCHAR(16777216) |
| EVENT_DATE | Date when the billing event occurred | DATE |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.2 Bz_FEATURE_USAGE
**Description**: Captures raw feature usage data from various source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| FEATURE_NAME | Name of the feature that was used | VARCHAR(16777216) |
| USAGE_COUNT | Number of times the feature was used | NUMBER(38,0) |
| USAGE_DATE | Date when the feature usage occurred | DATE |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.3 Bz_LICENSES
**Description**: Stores raw license information and assignments from source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| LICENSE_TYPE | Type or category of the license | VARCHAR(16777216) |
| START_DATE | Date when the license becomes active | DATE |
| END_DATE | Date when the license expires | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.4 Bz_MEETINGS
**Description**: Contains raw meeting data from various conferencing and collaboration systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| MEETING_TOPIC | Subject or topic of the meeting | VARCHAR(16777216) |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) |
| END_TIME | Timestamp when the meeting ended | VARCHAR(16777216) |
| DURATION_MINUTES | Duration of the meeting in minutes | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.5 Bz_PARTICIPANTS
**Description**: Raw participant data for meetings from source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| JOIN_TIME | Timestamp when the participant joined the meeting | VARCHAR(16777216) |
| LEAVE_TIME | Timestamp when the participant left the meeting | TIMESTAMP_NTZ(9) |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.6 Bz_SUPPORT_TICKETS
**Description**: Raw support ticket data from customer service systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| TICKET_TYPE | Category or type of the support ticket | VARCHAR(16777216) |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(16777216) |
| OPEN_DATE | Date when the support ticket was opened | DATE |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

### 2.7 Bz_USERS
**Description**: Raw user account information from various source systems

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| USER_NAME | Display name of the user | VARCHAR(16777216) |
| EMAIL | Email address of the user | VARCHAR(16777216) |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) |
| PLAN_TYPE | Type of subscription plan the user has | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when the record was loaded into the system | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when the record was last updated | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | System from which the data originated | VARCHAR(16777216) |

## 3. Audit Table Design

### 3.1 Bz_AUDIT_LOG
**Description**: Comprehensive audit trail for all Bronze layer data processing activities

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| RECORD_ID | Unique identifier for each audit record | VARCHAR(16777216) |
| SOURCE_TABLE | Name of the source table being audited | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when the data was loaded | TIMESTAMP_NTZ(9) |
| PROCESSED_BY | System or process that handled the data | VARCHAR(16777216) |
| PROCESSING_TIME | Duration of the processing operation | NUMBER(38,0) |
| STATUS | Status of the processing operation (SUCCESS, FAILED, PARTIAL) | VARCHAR(50) |

## 4. Conceptual Data Model Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bz_USERS      │    │  Bz_MEETINGS    │    │ Bz_PARTICIPANTS │
│                 │    │                 │    │                 │
│ - USER_NAME     │◄───┤ - MEETING_TOPIC │◄───┤ - JOIN_TIME     │
│ - EMAIL         │    │ - START_TIME    │    │ - LEAVE_TIME    │
│ - COMPANY       │    │ - END_TIME      │    │ - LOAD_TIMESTAMP│
│ - PLAN_TYPE     │    │ - DURATION_MIN  │    │ - UPDATE_TIMESTAMP│
│ - LOAD_TIMESTAMP│    │ - LOAD_TIMESTAMP│    │ - SOURCE_SYSTEM │
│ - UPDATE_TIMESTAMP│   │ - UPDATE_TIMESTAMP│   └─────────────────┘
│ - SOURCE_SYSTEM │    │ - SOURCE_SYSTEM │
└─────────────────┘    └─────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│ Bz_BILLING_EVENTS│   │ Bz_FEATURE_USAGE│
│                 │    │                 │
│ - EVENT_TYPE    │    │ - FEATURE_NAME  │
│ - AMOUNT        │    │ - USAGE_COUNT   │
│ - EVENT_DATE    │    │ - USAGE_DATE    │
│ - LOAD_TIMESTAMP│    │ - LOAD_TIMESTAMP│
│ - UPDATE_TIMESTAMP│   │ - UPDATE_TIMESTAMP│
│ - SOURCE_SYSTEM │    │ - SOURCE_SYSTEM │
└─────────────────┘    └─────────────────┘
         │
         │
         ▼
┌─────────────────┐    ┌─────────────────┐
│   Bz_LICENSES   │    │Bz_SUPPORT_TICKETS│
│                 │    │                 │
│ - LICENSE_TYPE  │    │ - TICKET_TYPE   │
│ - START_DATE    │    │ - RESOLUTION_STATUS│
│ - END_DATE      │    │ - OPEN_DATE     │
│ - LOAD_TIMESTAMP│    │ - LOAD_TIMESTAMP│
│ - UPDATE_TIMESTAMP│   │ - UPDATE_TIMESTAMP│
│ - SOURCE_SYSTEM │    │ - SOURCE_SYSTEM │
└─────────────────┘    └─────────────────┘

                ┌─────────────────┐
                │  Bz_AUDIT_LOG   │
                │                 │
                │ - RECORD_ID     │
                │ - SOURCE_TABLE  │
                │ - LOAD_TIMESTAMP│
                │ - PROCESSED_BY  │
                │ - PROCESSING_TIME│
                │ - STATUS        │
                └─────────────────┘
```

### Table Relationships:

1. **Bz_USERS** connects to **Bz_BILLING_EVENTS** via USER reference (business relationship)
2. **Bz_USERS** connects to **Bz_LICENSES** via USER assignment (business relationship)
3. **Bz_USERS** connects to **Bz_MEETINGS** via HOST relationship (business relationship)
4. **Bz_USERS** connects to **Bz_SUPPORT_TICKETS** via USER reference (business relationship)
5. **Bz_MEETINGS** connects to **Bz_PARTICIPANTS** via MEETING reference (business relationship)
6. **Bz_MEETINGS** connects to **Bz_FEATURE_USAGE** via MEETING reference (business relationship)
7. **Bz_AUDIT_LOG** tracks all tables via SOURCE_TABLE field

## 5. Design Decisions and Assumptions

### 5.1 Key Design Decisions:
1. **Naming Convention**: All Bronze tables prefixed with 'Bz_' for clear layer identification
2. **Data Preservation**: All source data types and structures maintained exactly as received
3. **Metadata Addition**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) added to all tables
4. **PII Identification**: Email addresses and user names classified as PII requiring special handling
5. **Audit Trail**: Comprehensive audit table designed to track all data processing activities

### 5.2 Assumptions Made:
1. Source systems provide consistent data formats
2. LOAD_TIMESTAMP and UPDATE_TIMESTAMP are system-generated
3. SOURCE_SYSTEM field will contain identifiable source system names
4. All VARCHAR fields sized as VARCHAR(16777216) to accommodate varying source data lengths
5. Business relationships exist between entities but are not enforced at Bronze layer
6. Data quality issues will be addressed in Silver layer transformation

### 5.3 Rationale:
- **Bronze Layer Philosophy**: Store data exactly as received from source systems
- **Scalability**: Design supports multiple source systems and data formats
- **Auditability**: Complete audit trail for compliance and debugging
- **Flexibility**: Loose schema allows for source system changes without immediate Bronze layer impact