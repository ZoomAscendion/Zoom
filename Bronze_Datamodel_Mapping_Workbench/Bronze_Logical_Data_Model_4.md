_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 4
## *Changes*: Added registration date field to Bz_Users table and enhanced PII classification with additional sensitive fields
## *Reason*: Enhanced user tracking capabilities and improved data governance compliance by including registration date and expanding PII coverage
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason** |
|----------------|-----------------|------------------------|------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information may indirectly identify individuals, especially in small organizations |
| Bz_Users | REGISTRATION_DATE | **Non-Sensitive PII** | Registration date combined with other data could help identify user patterns and behavior |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information or personal details |
| Bz_Meetings | START_TIME | **Potentially Sensitive** | Meeting timestamps can reveal personal schedules and business patterns |
| Bz_Meetings | END_TIME | **Potentially Sensitive** | Meeting timestamps can reveal personal schedules and business patterns |
| Bz_Participants | JOIN_TIME | **Potentially Sensitive** | Participation timestamps can reveal individual attendance patterns and behavior |
| Bz_Participants | LEAVE_TIME | **Potentially Sensitive** | Participation timestamps can reveal individual attendance patterns and behavior |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | May reveal personal issues or business-sensitive problems |
| Bz_Support_Tickets | RESOLUTION_STATUS | **Non-Sensitive** | Status information alone doesn't identify individuals but combined with other data could be sensitive |
| Bz_Support_Tickets | OPEN_DATE | **Non-Sensitive PII** | Support request dates can reveal usage patterns when combined with user data |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users Table
**Description**: Stores user profile information and subscription details for Zoom platform users

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and personalization purposes |
| EMAIL | VARCHAR(16777216) | User's email address used for communication, login authentication, and account management |
| COMPANY | VARCHAR(16777216) | Company or organization name associated with the user for business analytics and segmentation |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type (Basic, Pro, Business, Enterprise) for revenue analysis and feature access control |
| REGISTRATION_DATE | DATE | Date when the user first registered on the platform for user lifecycle analysis and cohort tracking |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.2 Bz_Meetings Table
**Description**: Contains comprehensive information about video meetings conducted on the Zoom platform

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting for content categorization and analysis |
| MEETING_TYPE | VARCHAR(16777216) | Type of meeting (Scheduled, Instant, Webinar, etc.) for meeting pattern analysis |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation and usage pattern analysis |
| END_TIME | TIMESTAMP_NTZ(9) | Meeting end timestamp for duration calculation and resource utilization tracking |
| DURATION_MINUTES | NUMBER(38,0) | Total meeting duration in minutes for usage analytics and billing calculations |
| HOST_NAME | VARCHAR(16777216) | Name of the user who organized and hosted the meeting for host activity tracking |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.3 Bz_Participants Table
**Description**: Tracks meeting participants and their engagement metrics for attendance analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| PARTICIPANT_NAME | VARCHAR(16777216) | Name of the meeting attendee for participant identification and engagement tracking |
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant joined the meeting for engagement analysis |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for participation duration calculation |
| CONNECTION_QUALITY | VARCHAR(100) | Quality of the participant's connection during the meeting for technical performance analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.4 Bz_Support_Tickets Table
**Description**: Manages customer support requests and their resolution process for service quality analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Type of support ticket (Technical, Billing, Feature Request, etc.) for issue categorization |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of ticket resolution (Open, In Progress, Resolved, Closed) for tracking progress |
| PRIORITY_LEVEL | VARCHAR(50) | Urgency level of the support request (Low, Medium, High, Critical) for resource allocation |
| OPEN_DATE | DATE | Date when the support ticket was created for response time calculation |
| CLOSE_DATE | DATE | Date when the ticket was resolved and closed for resolution time analysis |
| DESCRIPTION | VARCHAR(16777216) | Detailed explanation of the issue or request for problem categorization and analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.5 Bz_Billing_Events Table
**Description**: Tracks all financial transactions and billing activities for revenue analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (subscription, usage, upgrade, refund, etc.) for revenue categorization |
| AMOUNT | NUMBER(10,2) | Monetary amount for the billing event in the specified currency for financial analysis |
| EVENT_DATE | DATE | Date when the billing event occurred for revenue trend analysis |
| PAYMENT_METHOD | VARCHAR(100) | Method used for payment (Credit Card, PayPal, Bank Transfer, etc.) for payment analysis |
| CURRENCY | VARCHAR(10) | Currency type for the transaction amount for multi-currency revenue tracking |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log Table
**Description**: Comprehensive audit trail for tracking all data processing activities across Bronze layer tables

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(16777216) | Unique identifier for each audit record for tracking individual processing events |
| SOURCE_TABLE | VARCHAR(16777216) | Name of the source table being processed for identifying data lineage and processing scope |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation was initiated for temporal tracking |
| PROCESSED_BY | VARCHAR(16777216) | Identifier of the system, user, or process that performed the operation for accountability |
| PROCESSING_TIME | NUMBER(10,2) | Duration of the processing operation in seconds for performance monitoring |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL) for quality assurance |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationship Block Diagram

```
┌─────────────────┐         ┌─────────────────┐
│   Bz_Users      │────────▶│   Bz_Meetings   │
│                 │         │                 │
│ - USER_NAME     │         │ - MEETING_TOPIC │
│ - EMAIL         │         │ - MEETING_TYPE  │
│ - COMPANY       │         │ - START_TIME    │
│ - PLAN_TYPE     │         │ - END_TIME      │
│ - REGISTRATION  │         │ - DURATION_MIN  │
│   _DATE         │         │ - HOST_NAME     │
└─────────────────┘         └─────────────────┘
         │                           │
         │                           │
         ▼                           ▼
┌─────────────────┐         ┌─────────────────┐
│Bz_Support_Tickets│         │ Bz_Participants │
│                 │         │                 │
│ - TICKET_TYPE   │         │ - PARTICIPANT   │
│ - RESOLUTION_ST │         │   _NAME         │
│ - PRIORITY_LVL  │         │ - JOIN_TIME     │
│ - OPEN_DATE     │         │ - LEAVE_TIME    │
│ - CLOSE_DATE    │         │ - CONNECTION    │
│ - DESCRIPTION   │         │   _QUALITY      │
└─────────────────┘         └─────────────────┘
         │
         │
         ▼
┌─────────────────┐
│Bz_Billing_Events│
│                 │
│ - EVENT_TYPE    │
│ - AMOUNT        │
│ - EVENT_DATE    │
│ - PAYMENT_METHOD│
│ - CURRENCY      │
└─────────────────┘
```

### 4.2 Table Relationships

| **Source Table** | **Target Table** | **Relationship Key Field** | **Relationship Type** |
|------------------|------------------|----------------------------|----------------------|
| Bz_Users | Bz_Meetings | User Reference (HOST_ID) | One-to-Many |
| Bz_Meetings | Bz_Participants | Meeting Reference (MEETING_ID) | One-to-Many |
| Bz_Users | Bz_Support_Tickets | User Reference (USER_ID) | One-to-Many |
| Bz_Users | Bz_Billing_Events | User Reference (USER_ID) | One-to-Many |
| Bz_Users | Bz_Participants | User Reference (USER_ID) | One-to-Many |

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Table Naming Convention**: All Bronze layer tables use the "Bz_" prefix to clearly identify them as Bronze layer entities and maintain consistency across the medallion architecture.

2. **Primary and Foreign Key Exclusion**: As per Bronze layer principles, primary and foreign key fields have been removed to maintain the raw data structure while adding necessary metadata columns.

3. **Metadata Columns**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) are included in all tables to support data lineage, auditing, and change tracking.

4. **Data Type Preservation**: Original data types from the source system are maintained to ensure data integrity during the Bronze layer ingestion process.

5. **PII Classification Enhancement**: Comprehensive PII classification has been expanded to include more fields and provide better data governance and compliance support (GDPR, CCPA, etc.).

6. **Field Enhancement**: Added missing fields from the conceptual model including REGISTRATION_DATE, MEETING_TYPE, HOST_NAME, PARTICIPANT_NAME, CONNECTION_QUALITY, PRIORITY_LEVEL, CLOSE_DATE, DESCRIPTION, PAYMENT_METHOD, and CURRENCY for more comprehensive data capture.

### 5.2 Assumptions Made

1. **Source System Reliability**: Assumed that source systems provide consistent data formats and the metadata columns are populated by the ingestion process.

2. **Data Volume**: The model assumes high-volume data ingestion requiring efficient storage and processing capabilities.

3. **Compliance Requirements**: Assumed that PII data will require additional security measures and access controls in downstream processing.

4. **Audit Requirements**: Assumed that comprehensive audit logging is required for regulatory compliance and operational monitoring.

5. **Relationship Preservation**: While key fields are removed, the logical relationships between entities are preserved through the conceptual model for Silver layer processing.

6. **Enhanced Data Capture**: Assumed that capturing additional fields from the conceptual model will provide better analytical capabilities and more comprehensive reporting in downstream layers.

7. **Multi-Currency Support**: Assumed that the platform operates in multiple currencies requiring currency tracking for accurate revenue analysis.