_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Enhanced Bronze layer logical data model for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 2 
## *Updated on*: 
## *Changes*: Enhanced PII classification, improved data type alignment with source schema, added missing fields from source data structure, refined audit table design
## *Reason*: Alignment with actual source data structure and enhanced data governance requirements
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System (Enhanced)

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason** |
|----------------|-----------------|------------------------|------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person and is protected under GDPR Article 4 |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals, classified as personal data under GDPR |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information may indirectly identify individuals, especially in small organizations or unique business contexts |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information, personal details, or proprietary information requiring data classification |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | May reveal personal issues, business-sensitive problems, or technical vulnerabilities that require confidential handling |
| Bz_Support_Tickets | RESOLUTION_STATUS | **Non-Sensitive** | Status information alone doesn't identify individuals but combined with other data could reveal business patterns |
| Bz_Participants | JOIN_TIME | **Non-Sensitive PII** | Temporal data that when combined with other fields could reveal individual behavior patterns |
| Bz_Participants | LEAVE_TIME | **Non-Sensitive PII** | Temporal data that when combined with other fields could reveal individual engagement patterns |
| Bz_Billing_Events | AMOUNT | **Sensitive Business Data** | Financial information that reveals business revenue patterns and individual spending behavior |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users Table
**Description**: Stores user profile information and subscription details for Zoom platform users

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user for identification and personalization purposes |
| EMAIL | VARCHAR(16777216) | User's email address used for communication, login authentication, and account management (Unique constraint applied) |
| COMPANY | VARCHAR(16777216) | Company or organization name associated with the user for business analytics and segmentation |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan type (Free, Basic, Pro, Business, Enterprise) for revenue analysis and feature access control |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.2 Bz_Meetings Table
**Description**: Contains comprehensive information about video meetings conducted on the Zoom platform

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting for content categorization and analysis |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation and usage pattern analysis |
| END_TIME | VARCHAR(16777216) | Meeting end timestamp for duration calculation and resource utilization tracking (nullable) |
| DURATION_MINUTES | VARCHAR(16777216) | Total meeting duration in minutes for usage analytics and billing calculations (nullable) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.3 Bz_Participants Table
**Description**: Tracks meeting participants and their engagement metrics for attendance analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | VARCHAR(16777216) | Timestamp when participant joined the meeting for engagement analysis (nullable) |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for participation duration calculation (nullable) |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.4 Bz_Feature_Usage Table
**Description**: Records usage of specific platform features during meetings for feature adoption analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the feature being tracked (Screen Share, Recording, Chat, Breakout Rooms, etc.) for adoption analysis |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session for usage intensity measurement |
| USAGE_DATE | DATE | Date when feature usage occurred for temporal analysis and trend identification |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.5 Bz_Support_Tickets Table
**Description**: Manages customer support requests and their resolution process for service quality analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(16777216) | Type of support ticket (Technical, Billing, Feature Request, Account Issues, etc.) for issue categorization |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current status of ticket resolution (Open, In Progress, Resolved, Closed, Escalated) for tracking progress |
| OPEN_DATE | DATE | Date when the support ticket was created for response time calculation and SLA monitoring |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.6 Bz_Billing_Events Table
**Description**: Tracks all financial transactions and billing activities for revenue analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing event (Subscription, Usage, Upgrade, Downgrade, Refund, Credit) for revenue categorization |
| AMOUNT | VARCHAR(16777216) | Monetary amount for the billing event in the specified currency for financial analysis |
| EVENT_DATE | DATE | Date when the billing event occurred for revenue trend analysis and financial reporting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer |
| SOURCE_SYSTEM | VARCHAR(16777216) | Identifier of the source system from which the data originated for data lineage tracking |

### 2.7 Bz_Licenses Table
**Description**: Manages license assignments and entitlements for users across different subscription tiers

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(16777216) | Type of license (Basic, Pro, Business, Enterprise, Add-on, Webinar, Phone) for entitlement management |
| START_DATE | DATE | License validity start date for active license tracking and utilization analysis |
| END_DATE | VARCHAR(16777216) | License validity end date for renewal tracking and churn analysis (nullable) |
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
| PROCESSING_TIME | NUMBER(10,2) | Duration of the processing operation in seconds for performance monitoring and optimization |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL, RETRY_REQUIRED) for quality assurance |
| ERROR_MESSAGE | VARCHAR(16777216) | Detailed error message for failed operations to support troubleshooting and data quality monitoring |
| RECORDS_PROCESSED | NUMBER(38,0) | Count of records processed in the operation for volume tracking and performance analysis |
| OPERATION_TYPE | VARCHAR(100) | Type of operation performed (INSERT, UPDATE, DELETE, MERGE, VALIDATION) for audit categorization |

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
                    │
                    ▼
            ┌─────────────────┐
            │  Bz_Audit_Log   │
            │                 │
            │ - RECORD_ID     │
            │ - SOURCE_TABLE  │
            │ - LOAD_TIMESTAMP│
            │ - PROCESSED_BY  │
            │ - STATUS        │
            └─────────────────┘
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
| All Tables | Bz_Audit_Log | Table Name Reference (SOURCE_TABLE) | Many-to-Many |

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Enhanced Table Naming Convention**: All Bronze layer tables use the "Bz_" prefix to clearly identify them as Bronze layer entities and maintain consistency across the medallion architecture.

2. **Source Schema Alignment**: Data types and nullable constraints have been aligned with the actual source data structure to ensure accurate data representation.

3. **Primary and Foreign Key Exclusion**: As per Bronze layer principles, primary and foreign key fields have been removed to maintain the raw data structure while adding necessary metadata columns.

4. **Enhanced Metadata Columns**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) are included in all tables to support data lineage, auditing, and change tracking.

5. **Comprehensive PII Classification**: Enhanced PII classification has been implemented to support data governance and compliance requirements (GDPR, CCPA, HIPAA, etc.).

6. **Enhanced Audit Table**: The audit table has been expanded with additional fields for comprehensive monitoring and troubleshooting capabilities.

### 5.2 Assumptions Made

1. **Source System Reliability**: Assumed that source systems provide consistent data formats and the metadata columns are populated by the ingestion process.

2. **Data Volume Scalability**: The model assumes high-volume data ingestion requiring efficient storage and processing capabilities with potential for horizontal scaling.

3. **Enhanced Compliance Requirements**: Assumed that PII data will require additional security measures, encryption, and access controls in downstream processing.

4. **Comprehensive Audit Requirements**: Assumed that detailed audit logging is required for regulatory compliance, operational monitoring, and data quality assurance.

5. **Relationship Preservation**: While key fields are removed, the logical relationships between entities are preserved through the conceptual model for Silver layer processing.

6. **Data Quality Monitoring**: Assumed that data quality checks and validation processes will be implemented using the audit table for monitoring data integrity.

### 5.3 Version 2 Enhancements

1. **Improved PII Classification**: Added more comprehensive PII classification including business data sensitivity levels.

2. **Source Schema Alignment**: Aligned data types and constraints with the actual source data structure from Schema_Raw_output.md.

3. **Enhanced Audit Capabilities**: Expanded audit table with additional fields for error tracking, operation types, and performance monitoring.

4. **Data Governance Improvements**: Enhanced descriptions and added specific compliance framework references.

5. **Operational Monitoring**: Added fields and structures to support better operational monitoring and troubleshooting capabilities.