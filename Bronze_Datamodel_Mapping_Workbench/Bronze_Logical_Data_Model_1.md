_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System in Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason for PII Classification** |
|----------------|-----------------|------------------------|-----------------------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals directly |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information can indirectly identify individuals, especially in small organizations, but is less sensitive than direct personal identifiers |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information or personal details that could be sensitive |
| Bz_Support_Tickets | TICKET_TYPE | **Non-Sensitive PII** | While not directly identifying, ticket types combined with user information could reveal personal issues or business problems |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Bronze layer table storing raw user account information from source systems

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|----------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and communication purposes |
| EMAIL | VARCHAR(16777216) | User's email address used for login authentication and communication |
| COMPANY | VARCHAR(16777216) | Company or organization name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type indicating service level (Basic, Pro, Business, Enterprise) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.2 Bz_Meetings
**Description**: Bronze layer table storing raw meeting information and session details

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|----------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting as specified by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting session began |
| END_TIME | TIMESTAMP_NTZ(9) | Timestamp when the meeting session concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total duration of the meeting calculated in minutes |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.3 Bz_Participants
**Description**: Bronze layer table storing raw participant attendance information for meetings

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|----------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting session |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting session |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.4 Bz_Feature_Usage
**Description**: Bronze layer table storing raw feature utilization data during meetings

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|----------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the specific platform feature that was utilized |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was activated or used during the session |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.5 Bz_Support_Tickets
**Description**: Bronze layer table storing raw customer support request information

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|----------------|
| TICKET_TYPE | VARCHAR(16777216) | Category classification of the support request (Technical, Billing, Feature Request, etc.) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current processing status of the support ticket (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was initially created and submitted |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.6 Bz_Billing_Events
**Description**: Bronze layer table storing raw financial transaction and billing activity data

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|----------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing transaction (subscription, upgrade, refund, usage charge, etc.) |
| AMOUNT | NUMBER(10,2) | Monetary value of the billing event in the specified currency |
| EVENT_DATE | DATE | Date when the billing transaction occurred |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

### 2.7 Bz_Licenses
**Description**: Bronze layer table storing raw license assignment and entitlement information

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|----------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license entitlement (Basic, Pro, Enterprise, Add-on features) |
| START_DATE | DATE | Date when the license becomes active and available for use |
| END_DATE | DATE | Date when the license expires and is no longer valid |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit trail table for tracking all data processing activities in the Bronze layer

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|----------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit log entry |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the Bronze layer table that was processed |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation began |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the system, process, or user that performed the operation |
| PROCESSING_TIME | NUMBER(10,3) | Duration in seconds that the processing operation took to complete |
| STATUS | VARCHAR(50) | Outcome status of the processing operation (SUCCESS, FAILED, PARTIAL, WARNING) |

## 4. Conceptual Data Model Diagram

### 4.1 Table Relationships in Block Diagram Format

```
┌─────────────────┐
│   Bz_Users      │
│                 │
│ - USER_NAME     │
│ - EMAIL         │
│ - COMPANY       │
│ - PLAN_TYPE     │
└─────────────────┘
         │
         │ (User Reference)
         ▼
┌─────────────────┐       ┌─────────────────┐
│   Bz_Meetings   │       │ Bz_Support_     │
│                 │       │ Tickets         │
│ - MEETING_TOPIC │       │                 │
│ - START_TIME    │       │ - TICKET_TYPE   │
│ - END_TIME      │       │ - RESOLUTION_   │
│ - DURATION_MIN  │       │   STATUS        │
└─────────────────┘       │ - OPEN_DATE     │
         │                 └─────────────────┘
         │ (Meeting Reference)
         ▼
┌─────────────────┐
│ Bz_Participants │
│                 │
│ - JOIN_TIME     │
│ - LEAVE_TIME    │
└─────────────────┘
         │
         │ (Meeting Reference)
         ▼
┌─────────────────┐
│ Bz_Feature_     │
│ Usage           │
│                 │
│ - FEATURE_NAME  │
│ - USAGE_COUNT   │
│ - USAGE_DATE    │
└─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│ Bz_Billing_     │       │ Bz_Licenses     │
│ Events          │       │                 │
│                 │       │ - LICENSE_TYPE  │
│ - EVENT_TYPE    │       │ - START_DATE    │
│ - AMOUNT        │       │ - END_DATE      │
│ - EVENT_DATE    │       └─────────────────┘
└─────────────────┘                │
         │                          │
         │ (User Reference)         │ (User Reference)
         └──────────────────────────┘
```

### 4.2 Relationship Connections

1. **Bz_Users → Bz_Meetings**: Connected via User Reference field (Host relationship)
2. **Bz_Meetings → Bz_Participants**: Connected via Meeting Reference field (One-to-Many)
3. **Bz_Meetings → Bz_Feature_Usage**: Connected via Meeting Reference field (One-to-Many)
4. **Bz_Users → Bz_Support_Tickets**: Connected via User Reference field (One-to-Many)
5. **Bz_Users → Bz_Billing_Events**: Connected via User Reference field (One-to-Many)
6. **Bz_Users → Bz_Licenses**: Connected via User Reference field (One-to-Many)
7. **Bz_Users → Bz_Participants**: Connected via User Reference field (Attendee relationship)

## 5. Design Rationale and Key Decisions

### 5.1 Naming Convention
- **Prefix 'Bz_'**: Applied to all Bronze layer tables to clearly identify the data layer and maintain consistency across the medallion architecture
- **Descriptive Names**: Table names reflect the business entities they represent for easy identification

### 5.2 Data Preservation Strategy
- **Complete Source Mirroring**: All non-key fields from source systems are preserved to maintain data lineage and enable future analysis
- **Metadata Enrichment**: Added standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) for data governance

### 5.3 PII Handling Approach
- **Classification Framework**: Applied GDPR-based classification to identify sensitive personal information
- **Documentation**: Clearly documented PII fields with rationale for downstream data protection measures

### 5.4 Audit Trail Implementation
- **Comprehensive Tracking**: Audit table captures all processing activities for compliance and troubleshooting
- **Performance Monitoring**: Processing time tracking enables optimization of data pipeline performance

### 5.5 Key Assumptions
- Source systems provide consistent data formats and structures
- Referential relationships exist between entities as defined in the conceptual model
- Data volume and velocity requirements support the chosen data types and structures
- Compliance requirements align with the implemented PII classification approach