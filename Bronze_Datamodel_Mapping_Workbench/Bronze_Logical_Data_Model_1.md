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
| Bz_Users | USER_NAME | High Sensitivity PII | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | High Sensitivity PII | Email addresses are direct personal identifiers that can be used to contact and identify individuals, regulated under GDPR and other privacy laws |
| Bz_Users | COMPANY | Medium Sensitivity PII | Company affiliation can be used to identify individuals in smaller organizations or specific roles |
| Bz_Participants | JOIN_TIME | Low Sensitivity PII | Timestamp data combined with other fields can create behavioral patterns for individual identification |
| Bz_Participants | LEAVE_TIME | Low Sensitivity PII | Timestamp data combined with other fields can create behavioral patterns for individual identification |
| Bz_Support_Tickets | TICKET_TYPE | Low Sensitivity PII | Support ticket types can reveal personal issues or business problems when combined with user data |
| Bz_Billing_Events | AMOUNT | Medium Sensitivity PII | Financial transaction amounts can reveal personal spending patterns and economic status |
| Bz_Meetings | MEETING_TOPIC | Low Sensitivity PII | Meeting topics may contain sensitive business or personal information |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Bronze layer table storing raw user profile information and subscription details from source systems

| **Column Name** | **Data Type** | **Business Description** |
|-----------------|---------------|-------------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and personalization |
| EMAIL | VARCHAR(16777216) | Email address of the user for communication and account management |
| COMPANY | VARCHAR(16777216) | Company or organization name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type indicating service level and features available |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer from source system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the user data originated |

### 2.2 Bz_Meetings
**Description**: Bronze layer table containing raw meeting information and session details

| **Column Name** | **Data Type** | **Business Description** |
|-----------------|---------------|-------------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting for identification and categorization |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation and scheduling analysis |
| END_TIME | TIMESTAMP_NTZ(9) | Meeting end timestamp for duration calculation and resource utilization |
| DURATION_MINUTES | NUMBER(38,0) | Meeting duration in minutes for usage analytics and billing purposes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer from source system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the meeting data originated |

### 2.3 Bz_Participants
**Description**: Bronze layer table tracking meeting participants and their session details

| **Column Name** | **Data Type** | **Business Description** |
|-----------------|---------------|-------------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant joined the meeting for attendance tracking |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for engagement analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer from source system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the participant data originated |

### 2.4 Bz_Feature_Usage
**Description**: Bronze layer table recording platform feature utilization during meetings

| **Column Name** | **Data Type** | **Business Description** |
|-----------------|---------------|-------------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the feature being tracked for adoption and usage analytics |
| USAGE_COUNT | NUMBER(38,0) | Number of times feature was used during the session for utilization metrics |
| USAGE_DATE | DATE | Date when feature usage occurred for trend analysis and reporting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer from source system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the feature usage data originated |

### 2.5 Bz_Support_Tickets
**Description**: Bronze layer table managing customer support requests and resolution tracking

| **Column Name** | **Data Type** | **Business Description** |
|-----------------|---------------|-------------------------|
| TICKET_TYPE | VARCHAR(16777216) | Type of support ticket for categorization and routing purposes |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of ticket resolution for tracking and SLA management |
| OPEN_DATE | DATE | Date when ticket was opened for response time calculation and aging analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer from source system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the support ticket data originated |

### 2.6 Bz_Billing_Events
**Description**: Bronze layer table tracking financial transactions and billing activities

| **Column Name** | **Data Type** | **Business Description** |
|-----------------|---------------|-------------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event for transaction categorization and revenue analysis |
| AMOUNT | NUMBER(10,2) | Monetary amount for the billing event for revenue calculation and financial reporting |
| EVENT_DATE | DATE | Date when the billing event occurred for financial period analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer from source system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the billing event data originated |

### 2.7 Bz_Licenses
**Description**: Bronze layer table managing license assignments and entitlements

| **Column Name** | **Data Type** | **Business Description** |
|-----------------|---------------|-------------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of license for entitlement management and feature access control |
| START_DATE | DATE | License validity start date for activation and billing cycle management |
| END_DATE | DATE | License validity end date for renewal tracking and expiration management |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the bronze layer from source system |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier from which the license data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit table to track all data processing activities across bronze layer tables

| **Column Name** | **Data Type** | **Business Description** |
|-----------------|---------------|-------------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit record for tracking and reference |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source table being processed for data lineage tracking |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation occurred |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the process or user that performed the operation |
| PROCESSING_TIME | NUMBER(10,3) | Time taken to process the operation in seconds for performance monitoring |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, PARTIAL) for quality assurance |
| ERROR_MESSAGE | VARCHAR(16777216) | Detailed error message if processing failed for troubleshooting |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records processed in the operation for volume tracking |
| SOURCE_SYSTEM | VARCHAR(16777216) | Source system identifier for audit trail and data lineage |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationship Block Diagram

```
┌─────────────────┐         ┌─────────────────┐
│   Bz_Users      │────────▶│   Bz_Meetings   │
│                 │         │                 │
│ - USER_NAME     │         │ - MEETING_TOPIC │
│ - EMAIL         │         │ - START_TIME    │
│ - COMPANY       │         │ - END_TIME      │
│ - PLAN_TYPE     │         │ - DURATION_MIN  │
└─────────────────┘         └─────────────────┘
         │                           │
         │                           │
         ▼                           ▼
┌─────────────────┐         ┌─────────────────┐
│ Bz_Participants │         │ Bz_Feature_Usage│
│                 │         │                 │
│ - JOIN_TIME     │         │ - FEATURE_NAME  │
│ - LEAVE_TIME    │         │ - USAGE_COUNT   │
│                 │         │ - USAGE_DATE    │
└─────────────────┘         └─────────────────┘
         │
         │
         ▼
┌─────────────────┐
│Bz_Support_Tickets│
│                 │
│ - TICKET_TYPE   │
│ - RESOLUTION_ST │
│ - OPEN_DATE     │
└─────────────────┘
         │
         │
         ▼
┌─────────────────┐         ┌─────────────────┐
│ Bz_Billing_Events│         │   Bz_Licenses   │
│                 │         │                 │
│ - EVENT_TYPE    │         │ - LICENSE_TYPE  │
│ - AMOUNT        │         │ - START_DATE    │
│ - EVENT_DATE    │         │ - END_DATE      │
└─────────────────┘         └─────────────────┘
```

### 4.2 Table Relationships

| **Source Table** | **Target Table** | **Relationship Key Field** | **Relationship Type** |
|------------------|------------------|----------------------------|----------------------|
| Bz_Users | Bz_Meetings | User Reference (HOST) | One-to-Many |
| Bz_Meetings | Bz_Participants | Meeting Reference | One-to-Many |
| Bz_Meetings | Bz_Feature_Usage | Meeting Reference | One-to-Many |
| Bz_Users | Bz_Support_Tickets | User Reference | One-to-Many |
| Bz_Users | Bz_Billing_Events | User Reference | One-to-Many |
| Bz_Users | Bz_Licenses | Assigned User Reference | One-to-Many |
| Bz_Users | Bz_Participants | Attendee User Reference | One-to-Many |

### 4.3 Design Rationale and Assumptions

1. **Bronze Layer Philosophy**: The bronze layer mirrors the source data structure exactly, preserving raw data integrity while removing primary and foreign key constraints to allow for flexible data processing.

2. **Naming Convention**: All bronze tables use the 'Bz_' prefix to clearly identify them as bronze layer entities within the medallion architecture.

3. **Metadata Columns**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) are included in all tables to support data lineage, auditing, and troubleshooting.

4. **PII Handling**: PII fields are identified and classified to ensure proper data governance and compliance with privacy regulations.

5. **Audit Strategy**: A comprehensive audit table tracks all processing activities to maintain data quality and provide operational visibility.

6. **Data Types**: VARCHAR(16777216) is used for text fields to accommodate varying data lengths from different source systems, while specific numeric and date types are preserved for analytical purposes.

7. **Relationship Preservation**: While primary/foreign key constraints are removed, the logical relationships between entities are documented to maintain data model integrity for downstream processing.

---

**End of Bronze Layer Logical Data Model**