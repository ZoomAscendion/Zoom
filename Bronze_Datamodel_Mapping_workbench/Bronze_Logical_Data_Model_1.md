_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason for PII Classification** |
|----------------|-----------------|------------------------|-----------------------------------|
| Bz_Users | USER_NAME | **High Sensitivity PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **High Sensitivity PII** | Email addresses are direct personal identifiers and can be used to contact individuals, regulated under GDPR and other privacy laws |
| Bz_Users | COMPANY | **Medium Sensitivity PII** | Company affiliation can be used to identify individuals in smaller organizations or specific roles |
| Bz_Meetings | MEETING_TOPIC | **Low Sensitivity PII** | Meeting topics may contain sensitive business information or personal references that could identify participants |
| Bz_Support_Tickets | TICKET_TYPE | **Low Sensitivity PII** | Support ticket types may reveal personal issues or business-sensitive information about users |
| Bz_Billing_Events | AMOUNT | **Medium Sensitivity PII** | Financial information that can reveal personal spending patterns and business financial details |
| Bz_Licenses | LICENSE_TYPE | **Low Sensitivity PII** | License information may reveal business size, role, or organizational structure of individuals |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Bronze layer table storing raw user profile information and subscription details from source systems

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and personalization purposes |
| EMAIL | VARCHAR(16777216) | Primary email address used for user authentication, communication, and account management |
| COMPANY | VARCHAR(16777216) | Organization or company name associated with the user for business analytics and segmentation |
| PLAN_TYPE | VARCHAR(16777216) | Current subscription plan category (Basic, Pro, Business, Enterprise) for usage analysis and revenue tracking |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the record was initially loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the record was last modified or updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the user data originated for data lineage tracking |

### 2.2 Bz_Meetings
**Description**: Bronze layer table containing raw meeting data including scheduling, duration, and host information

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Subject or title of the meeting as specified by the host for meeting identification and categorization |
| START_TIME | TIMESTAMP_NTZ(9) | Exact timestamp when the meeting session began for duration calculation and usage analytics |
| END_TIME | TIMESTAMP_NTZ(9) | Exact timestamp when the meeting session concluded for duration calculation and resource utilization |
| DURATION_MINUTES | NUMBER(38,0) | Total meeting duration in minutes calculated from start and end times for usage reporting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the meeting record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the meeting record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage and integration tracking |

### 2.3 Bz_Participants
**Description**: Bronze layer table tracking meeting participation details and attendance patterns

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Exact timestamp when participant joined the meeting for attendance tracking and engagement analysis |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Exact timestamp when participant left the meeting for participation duration calculation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the participant record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the participant record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage and integration tracking |

### 2.4 Bz_Feature_Usage
**Description**: Bronze layer table storing raw feature utilization data during meetings for adoption analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the specific platform feature used (Screen Share, Recording, Chat, etc.) for adoption tracking |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was activated or utilized during the meeting session |
| USAGE_DATE | DATE | Date when the feature usage occurred for temporal analysis and trend identification |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the feature usage record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the feature usage record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage and integration tracking |

### 2.5 Bz_Support_Tickets
**Description**: Bronze layer table containing raw customer support request data for service quality analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of support request (Technical, Billing, Feature Request, etc.) for issue classification |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current state of ticket resolution (Open, In Progress, Resolved, Closed) for tracking support efficiency |
| OPEN_DATE | DATE | Date when the support ticket was initially created for resolution time calculation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the support ticket record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the support ticket record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage and integration tracking |

### 2.6 Bz_Billing_Events
**Description**: Bronze layer table storing raw financial transaction data for revenue analysis and billing tracking

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing transaction (Subscription, Upgrade, Refund, Usage Charge, etc.) for revenue categorization |
| AMOUNT | NUMBER(10,2) | Monetary value of the billing event in the specified currency for revenue calculation |
| EVENT_DATE | DATE | Date when the billing transaction occurred for financial reporting and trend analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the billing event record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the billing event record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage and integration tracking |

### 2.7 Bz_Licenses
**Description**: Bronze layer table containing raw license assignment and entitlement data for subscription management

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license (Basic, Pro, Enterprise, Add-on) for entitlement tracking and usage analysis |
| START_DATE | DATE | Date when the license becomes active and available for use by the assigned user |
| END_DATE | DATE | Date when the license expires and is no longer valid for usage tracking and renewal planning |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the license record was loaded into the bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp indicating when the license record was last updated |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for data lineage and integration tracking |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit table tracking all data processing activities across bronze layer tables

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit log entry for tracking individual processing events |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the bronze layer table being processed for source identification |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation was initiated |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the system, user, or process that performed the data operation |
| PROCESSING_TIME | NUMBER(10,2) | Duration in seconds required to complete the data processing operation |
| STATUS | VARCHAR(50) | Outcome status of the processing operation (SUCCESS, FAILED, PARTIAL, WARNING) |

## 4. Conceptual Data Model Diagram

### 4.1 Table Relationships in Block Diagram Format

```
┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to HOST_NAME)
         ▼
┌─────────────────┐
│   Bz_Meetings   │
│                 │
└─────────────────┘
         │
         │ (MEETING_TOPIC connects to MEETING_REFERENCE)
         ▼
┌─────────────────┐
│ Bz_Participants │
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Meetings   │
│                 │
└─────────────────┘
         │
         │ (MEETING_TOPIC connects to MEETING_REFERENCE)
         ▼
┌─────────────────┐
│Bz_Feature_Usage │
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to USER_REFERENCE)
         ▼
┌─────────────────┐
│Bz_Support_Tickets│
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to USER_REFERENCE)
         ▼
┌─────────────────┐
│Bz_Billing_Events│
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to ASSIGNED_USER_REFERENCE)
         ▼
┌─────────────────┐
│  Bz_Licenses    │
│                 │
└─────────────────┘

┌─────────────────┐
│   Bz_Users      │
│                 │
└─────────────────┘
         │
         │ (USER_NAME connects to ATTENDEE_USER_REFERENCE)
         ▼
┌─────────────────┐
│ Bz_Participants │
│                 │
└─────────────────┘
```

### 4.2 Relationship Summary

1. **Bz_Users → Bz_Meetings**: One-to-Many relationship where USER_NAME connects to HOST_NAME
2. **Bz_Meetings → Bz_Participants**: One-to-Many relationship where MEETING_TOPIC connects to MEETING_REFERENCE
3. **Bz_Meetings → Bz_Feature_Usage**: One-to-Many relationship where MEETING_TOPIC connects to MEETING_REFERENCE
4. **Bz_Users → Bz_Support_Tickets**: One-to-Many relationship where USER_NAME connects to USER_REFERENCE
5. **Bz_Users → Bz_Billing_Events**: One-to-Many relationship where USER_NAME connects to USER_REFERENCE
6. **Bz_Users → Bz_Licenses**: One-to-Many relationship where USER_NAME connects to ASSIGNED_USER_REFERENCE
7. **Bz_Users → Bz_Participants**: One-to-Many relationship where USER_NAME connects to ATTENDEE_USER_REFERENCE

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All bronze layer tables use 'Bz_' prefix to clearly identify them as part of the bronze layer in the medallion architecture

2. **Data Preservation**: All source data fields are preserved exactly as they exist in the raw layer, ensuring no data loss during bronze layer processing

3. **Metadata Enrichment**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) are included in all tables for data lineage and processing tracking

4. **PII Classification**: Comprehensive identification and classification of personally identifiable information to ensure compliance with data privacy regulations

5. **Audit Trail**: Dedicated audit table to track all data processing activities for compliance and troubleshooting purposes

### 5.2 Assumptions Made

1. **Data Quality**: Source data is assumed to be in valid format but may contain duplicates or inconsistencies that will be addressed in silver layer

2. **Relationship Mapping**: Logical relationships between entities are maintained through business key fields rather than technical foreign keys

3. **Temporal Consistency**: All timestamp fields are assumed to be in consistent timezone format from source systems

4. **Volume Scalability**: Table structures are designed to handle high-volume data ingestion typical of video conferencing platforms

5. **Source System Stability**: Source system identifiers are assumed to be consistent and reliable for data lineage tracking