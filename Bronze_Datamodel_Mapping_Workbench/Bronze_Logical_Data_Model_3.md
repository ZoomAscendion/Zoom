_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Updated Bronze layer logical data model for Zoom Platform Analytics System with standardized VARCHAR data types
## *Version*: 3 
## *Updated on*: 
## *Changes*: Replaced all VARCHAR(16777216) data types with VARCHAR(100) for improved performance and storage optimization
## *Reason*: To standardize data types and optimize storage usage while maintaining data integrity and improving query performance
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason** |
|----------------|-----------------|------------------------|------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person and is protected under GDPR Article 4 |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals, classified as personal data under GDPR |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information may indirectly identify individuals, especially in small organizations, and could be used for profiling purposes |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information, personal details, or proprietary information that requires protection |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | May reveal personal issues, business-sensitive problems, or technical vulnerabilities that could impact privacy |
| Bz_Billing_Events | AMOUNT | **Sensitive Financial** | Financial transaction amounts are considered sensitive personal financial information under various privacy regulations |
| Bz_Licenses | LICENSE_TYPE | **Business Sensitive** | License information can reveal business structure, user privileges, and organizational hierarchy |
| Bz_Participants | JOIN_TIME | **Behavioral PII** | Participation timestamps can create behavioral profiles and reveal personal patterns protected under privacy laws |
| Bz_Participants | LEAVE_TIME | **Behavioral PII** | Meeting departure times contribute to behavioral profiling and personal activity tracking |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users Table
**Description**: Stores comprehensive user profile information and subscription details for Zoom platform users with enhanced data governance

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| USER_NAME | VARCHAR(100) | Display name of the user for identification and personalization purposes, subject to PII protection policies |
| EMAIL | VARCHAR(100) | User's email address used for communication, login authentication, and account management - requires encryption at rest |
| COMPANY | VARCHAR(100) | Company or organization name associated with the user for business analytics, segmentation, and enterprise reporting |
| PLAN_TYPE | VARCHAR(100) | Subscription plan type (Basic, Pro, Business, Enterprise) for revenue analysis, feature access control, and usage analytics |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data lineage tracking |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change data capture |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage tracking and audit purposes |

### 2.2 Bz_Meetings Table
**Description**: Contains comprehensive information about video meetings conducted on the Zoom platform with enhanced temporal tracking

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| MEETING_TOPIC | VARCHAR(100) | Topic or title of the meeting for content categorization, analysis, and business intelligence reporting |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation, usage pattern analysis, and peak time identification |
| END_TIME | VARCHAR(100) | Meeting end timestamp for duration calculation, resource utilization tracking, and session completion analysis |
| DURATION_MINUTES | VARCHAR(100) | Total meeting duration in minutes for usage analytics, billing calculations, and performance metrics |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing tracking |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality assurance |

### 2.3 Bz_Participants Table
**Description**: Tracks meeting participants and their engagement metrics for comprehensive attendance and behavior analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| JOIN_TIME | VARCHAR(100) | Timestamp when participant joined the meeting for engagement analysis and attendance tracking |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for participation duration calculation and engagement metrics |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data freshness tracking |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and lineage |

### 2.4 Bz_Feature_Usage Table
**Description**: Records usage of specific platform features during meetings for comprehensive feature adoption and utilization analysis

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| FEATURE_NAME | VARCHAR(100) | Name of the feature being tracked (Screen Share, Recording, Chat, Breakout Rooms) for adoption analysis and product development |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session for usage intensity measurement and feature popularity tracking |
| USAGE_DATE | DATE | Date when feature usage occurred for temporal analysis, trend identification, and usage pattern recognition |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing audit |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality control |

### 2.5 Bz_Support_Tickets Table
**Description**: Manages customer support requests and their resolution process for comprehensive service quality analysis and customer satisfaction tracking

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| TICKET_TYPE | VARCHAR(100) | Type of support ticket (Technical, Billing, Feature Request, General Inquiry) for issue categorization and resource allocation |
| RESOLUTION_STATUS | VARCHAR(100) | Current status of ticket resolution (Open, In Progress, Resolved, Closed) for tracking progress and SLA compliance |
| OPEN_DATE | DATE | Date when the support ticket was created for response time calculation and performance metrics |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit trail |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and traceability |

### 2.6 Bz_Billing_Events Table
**Description**: Tracks all financial transactions and billing activities for comprehensive revenue analysis and financial reporting

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| EVENT_TYPE | VARCHAR(100) | Type of billing event (charge, refund, adjustment, subscription) for revenue categorization and financial analysis |
| AMOUNT | VARCHAR(100) | Monetary amount for the billing event in the specified currency for financial analysis and revenue tracking |
| EVENT_DATE | DATE | Date when the billing event occurred for revenue trend analysis and financial reporting |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit purposes |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data integrity tracking |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for financial audit and compliance |

### 2.7 Bz_Licenses Table
**Description**: Manages license assignments and entitlements for users across different subscription tiers with comprehensive lifecycle tracking

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| LICENSE_TYPE | VARCHAR(100) | Type of license (Basic, Pro, Enterprise, Add-on) for entitlement management, revenue analysis, and feature access control |
| START_DATE | DATE | License validity start date for active license tracking, utilization analysis, and subscription management |
| END_DATE | VARCHAR(100) | License validity end date for renewal tracking, churn analysis, and subscription lifecycle management |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and governance |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log Table
**Description**: Comprehensive audit trail for tracking all data processing activities across Bronze layer tables with enhanced monitoring capabilities

| **Column Name** | **Data Type** | **Description** |
|-----------------|---------------|------------------|
| RECORD_ID | VARCHAR(100) | Unique identifier for each audit record for tracking individual processing events and maintaining audit integrity |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table being processed for identifying data lineage, processing scope, and impact analysis |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation was initiated for temporal tracking and performance analysis |
| PROCESSED_BY | VARCHAR(100) | Identifier of the system, user, or process that performed the operation for accountability and security auditing |
| PROCESSING_TIME | NUMBER(10,2) | Duration of the processing operation in seconds for performance monitoring, optimization, and SLA tracking |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL, RETRY) for quality assurance and error handling |
| ERROR_MESSAGE | VARCHAR(100) | Detailed error message for failed operations to support troubleshooting and root cause analysis |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records processed in the operation for volume tracking and performance metrics |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the processed data (0-100) for data quality monitoring and improvement initiatives |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationship Block Diagram

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Bz_Users      │────────▶│   Bz_Meetings   │────────▶│ Bz_Participants │
│                 │         │                 │         │                 │
│ - USER_NAME     │         │ - MEETING_TOPIC │         │ - JOIN_TIME     │
│ - EMAIL         │         │ - START_TIME    │         │ - LEAVE_TIME    │
│ - COMPANY       │         │ - END_TIME      │         └─────────────────┘
│ - PLAN_TYPE     │         │ - DURATION_MIN  │                   │
└─────────────────┘         └─────────────────┘                   │
         │                           │                           │
         │                           │                           ▼
         │                           │                 ┌─────────────────┐
         │                           └────────────────▶│Bz_Feature_Usage │
         │                                             │                 │
         │                                             │ - FEATURE_NAME  │
         │                                             │ - USAGE_COUNT   │
         │                                             │ - USAGE_DATE    │
         │                                             └─────────────────┘
         │
         ├─────────────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐ ┌─────────────────┐
│Bz_Support_Tickets│ │Bz_Billing_Events│
│                 │ │                 │
│ - TICKET_TYPE   │ │ - EVENT_TYPE    │
│ - RESOLUTION_ST │ │ - AMOUNT        │
│ - OPEN_DATE     │ │ - EVENT_DATE    │
└─────────────────┘ └─────────────────┘
         │                 │
         │                 │
         │                 ▼
         │         ┌─────────────────┐
         │         │   Bz_Licenses   │
         │         │                 │
         │         │ - LICENSE_TYPE  │
         │         │ - START_DATE    │
         │         │ - END_DATE      │
         │         └─────────────────┘
         │
         ▼
┌─────────────────┐
│  Bz_Audit_Log   │
│                 │
│ - RECORD_ID     │
│ - SOURCE_TABLE  │
│ - LOAD_TIMESTAMP│
│ - PROCESSED_BY  │
│ - PROCESSING_TIME│
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
| All Tables | Bz_Audit_Log | Table Name Reference (SOURCE_TABLE) | Many-to-One |

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Enhanced Table Naming Convention**: All Bronze layer tables use the "Bz_" prefix to clearly identify them as Bronze layer entities and maintain consistency across the medallion architecture while supporting automated processing.

2. **Complete Source Coverage**: All tables from the source schema are now represented in the Bronze layer to ensure no data loss and complete data lineage tracking.

3. **Primary and Foreign Key Exclusion**: As per Bronze layer principles, primary and foreign key fields have been removed to maintain the raw data structure while adding necessary metadata columns for processing.

4. **Enhanced Metadata Columns**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) are included in all tables to support comprehensive data lineage, auditing, and change tracking.

5. **Optimized Data Types**: VARCHAR data types have been standardized to VARCHAR(100) to optimize storage usage and improve query performance while maintaining data integrity.

6. **Comprehensive PII Classification**: Enhanced PII classification has been implemented to support data governance, compliance requirements (GDPR, CCPA, HIPAA), and privacy protection.

7. **Enhanced Audit Capabilities**: Expanded audit table with additional fields for comprehensive monitoring, error tracking, and data quality assessment.

### 5.2 Assumptions Made

1. **Source System Reliability**: Assumed that source systems provide consistent data formats and the metadata columns are populated by the ingestion process with proper error handling.

2. **High-Volume Data Processing**: The model assumes high-volume data ingestion requiring efficient storage, processing capabilities, and scalable architecture.

3. **Regulatory Compliance**: Assumed that PII data will require additional security measures, access controls, encryption, and audit trails in downstream processing.

4. **Comprehensive Audit Requirements**: Assumed that detailed audit logging is required for regulatory compliance, operational monitoring, and data quality assurance.

5. **Relationship Preservation**: While key fields are removed, the logical relationships between entities are preserved through the conceptual model for Silver layer processing and analytics.

6. **Data Quality Monitoring**: Assumed that data quality scoring and monitoring will be implemented to ensure data reliability and trustworthiness.

7. **Error Handling and Recovery**: Assumed that comprehensive error handling, logging, and recovery mechanisms will be implemented for production reliability.

8. **Data Length Optimization**: Assumed that VARCHAR(100) provides sufficient length for most text fields while optimizing storage and performance.

### 5.3 Version 3 Enhancements

1. **Data Type Standardization**: Replaced all VARCHAR(16777216) with VARCHAR(100) for improved storage efficiency and query performance
2. **Performance Optimization**: Standardized data types reduce storage overhead and improve indexing capabilities
3. **Maintained Data Integrity**: Ensured all functional requirements are preserved while optimizing technical implementation
4. **Storage Efficiency**: Reduced storage footprint while maintaining all necessary functionality
5. **Query Performance**: Improved query execution times through optimized data type usage
6. **Consistency**: Standardized VARCHAR lengths across all tables for better maintainability