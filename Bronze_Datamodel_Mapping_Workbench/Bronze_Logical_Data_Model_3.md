_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 3 
## *Updated on*: 
## *Changes*: Updated VARCHAR(500) data types to VARCHAR(600) for all string columns
## *Reason*: Increased varchar size from 500 to 600 characters to accommodate larger data values and provide additional buffer for future requirements
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason** |
|----------------|-----------------|------------------------|------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information may indirectly identify individuals, especially in small organizations |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information or personal details |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | May reveal personal issues or business-sensitive problems |
| Bz_Support_Tickets | RESOLUTION_STATUS | **Non-Sensitive** | Status information alone doesn't identify individuals but combined with other data could be sensitive |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users Table
**Description**: Stores user profile information and subscription details for Zoom platform users

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(600) | Display name of the user for identification and personalization purposes |
| EMAIL | VARCHAR(600) | User's email address used for communication, login authentication, and account management |
| COMPANY | VARCHAR(600) | Company or organization name associated with the user for business analytics and segmentation |
| PLAN_TYPE | VARCHAR(600) | Subscription plan type (Basic, Pro, Business, Enterprise) for revenue analysis and feature access control |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(600) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.2 Bz_Meetings Table
**Description**: Contains comprehensive information about video meetings conducted on the Zoom platform

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(600) | Topic or title of the meeting for content categorization and analysis |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation and usage pattern analysis |
| END_TIME | TIMESTAMP_NTZ(9) | Meeting end timestamp for duration calculation and resource utilization tracking |
| DURATION_MINUTES | NUMBER(38,0) | Total meeting duration in minutes for usage analytics and billing calculations |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(600) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.3 Bz_Participants Table
**Description**: Tracks meeting participants and their engagement metrics for attendance analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant joined the meeting for engagement analysis |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for participation duration calculation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(600) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.4 Bz_Feature_Usage Table
**Description**: Records usage of specific platform features during meetings for feature adoption analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(600) | Name of the feature being tracked (Screen Share, Recording, Chat, etc.) for adoption analysis |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session for usage intensity measurement |
| USAGE_DATE | DATE | Date when feature usage occurred for temporal analysis and trend identification |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(600) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.5 Bz_Support_Tickets Table
**Description**: Manages customer support requests and their resolution process for service quality analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(600) | Type of support ticket (Technical, Billing, Feature Request, etc.) for issue categorization |
| RESOLUTION_STATUS | VARCHAR(600) | Current status of ticket resolution (Open, In Progress, Resolved, Closed) for tracking progress |
| OPEN_DATE | DATE | Date when the support ticket was created for response time calculation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(600) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.6 Bz_Billing_Events Table
**Description**: Tracks all financial transactions and billing activities for revenue analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(600) | Type of billing event (subscription, usage, upgrade, refund, etc.) for revenue categorization |
| AMOUNT | NUMBER(10,2) | Monetary amount for the billing event in the specified currency for financial analysis |
| EVENT_DATE | DATE | Date when the billing event occurred for revenue trend analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(600) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.7 Bz_Licenses Table
**Description**: Manages license assignments and entitlements for users across different subscription tiers

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(600) | Type of license (Basic, Pro, Enterprise, Add-on) for entitlement management and revenue analysis |
| START_DATE | DATE | License validity start date for active license tracking and utilization analysis |
| END_DATE | DATE | License validity end date for renewal tracking and churn analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(600) | Identifier of the source system from which the data originated for data lineage tracking |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log Table
**Description**: Comprehensive audit trail for tracking all data processing activities across Bronze layer tables

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(600) | Unique identifier for each audit record for tracking individual processing events |
| SOURCE_TABLE | VARCHAR(600) | Name of the source table being processed for identifying data lineage and processing scope |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation was initiated for temporal tracking |
| PROCESSED_BY | VARCHAR(600) | Identifier of the system, user, or process that performed the operation for accountability |
| PROCESSING_TIME | NUMBER(10,2) | Duration of the processing operation in seconds for performance monitoring |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL) for quality assurance |

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
│Bz_Support_Tickets│         │ Bz_Participants │
│                 │         │                 │
│ - TICKET_TYPE   │         │ - JOIN_TIME     │
│ - RESOLUTION_ST │         │ - LEAVE_TIME    │
│ - OPEN_DATE     │         └─────────────────┘
└─────────────────┘                   │
         │                           │
         │                           ▼
         │                 ┌─────────────────┐
         │                 │Bz_Feature_Usage │
         │                 │                 │
         │                 │ - FEATURE_NAME  │
         │                 │ - USAGE_COUNT   │
         │                 │ - USAGE_DATE    │
         │                 └─────────────────┘
         │
         ▼
┌─────────────────┐         ┌─────────────────┐
│Bz_Billing_Events│         │   Bz_Licenses   │
│                 │         │                 │
│ - EVENT_TYPE    │◀────────│ - LICENSE_TYPE  │
│ - AMOUNT        │         │ - START_DATE    │
│ - EVENT_DATE    │         │ - END_DATE      │
└─────────────────┘         └─────────────────┘
```

### 4.2 Table Relationships

| **Source Table** | **Target Table** | **Relationship Key Field** | **Relationship Type** |
|------------------|------------------|----------------------------|----------------------|
| Bz_Users | Bz_Meetings | User Reference (HOST_ID) | One-to-Many |
| Bz_Meetings | Bz_Participants | Meeting Reference (MEETING_ID) | One-to-Many |
| Bz_Meetings | Bz_Feature_Usage | Meeting Reference (MEETING_ID) | One-to-Many |
| Bz_Users | Bz_Support_Tickets | User Reference (USER_ID) | One-to-Many |
| Bz_Users | Bz_Billing_Events | User Reference (USER_ID) | One-to-Many |
| Bz_Users | Bz_Licenses | User Reference (ASSIGNED_TO_USER_ID) | One-to-Many |
| Bz_Users | Bz_Participants | User Reference (USER_ID) | One-to-Many |

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Table Naming Convention**: All Bronze layer tables use the "Bz_" prefix to clearly identify them as Bronze layer entities and maintain consistency across the medallion architecture.

2. **Primary and Foreign Key Exclusion**: As per Bronze layer principles, primary and foreign key fields have been removed to maintain the raw data structure while adding necessary metadata columns.

3. **Metadata Columns**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) are included in all tables to support data lineage, auditing, and change tracking.

4. **Data Type Optimization**: VARCHAR data types have been set to VARCHAR(600) to provide adequate capacity for expected data values while maintaining reasonable storage efficiency and performance.

5. **PII Classification**: Comprehensive PII classification has been implemented to support data governance and compliance requirements (GDPR, CCPA, etc.).

### 5.2 Assumptions Made

1. **Source System Reliability**: Assumed that source systems provide consistent data formats and the metadata columns are populated by the ingestion process.

2. **Data Volume**: The model assumes high-volume data ingestion requiring efficient storage and processing capabilities.

3. **Compliance Requirements**: Assumed that PII data will require additional security measures and access controls in downstream processing.

4. **Audit Requirements**: Assumed that comprehensive audit logging is required for regulatory compliance and operational monitoring.

5. **Relationship Preservation**: While key fields are removed, the logical relationships between entities are preserved through the conceptual model for Silver layer processing.

6. **String Length Requirements**: Assumed that VARCHAR(600) provides sufficient capacity for all string data fields based on business requirements while maintaining optimal storage and performance balance.