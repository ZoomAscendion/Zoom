_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Enhanced Bronze layer logical data model for Zoom Platform Analytics System with improved data governance and audit capabilities
## *Version*: 4
## *Updated on*: 2024-12-19
## *Changes*: Added data retention policies, enhanced security classifications, improved audit table with additional monitoring fields, added data lineage tracking, and implemented comprehensive data quality metrics
## *Reason*: To enhance data governance compliance, improve operational monitoring capabilities, and strengthen security posture for enterprise-grade data management
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason** | **Retention Policy** | **Security Level** |
|----------------|-----------------|------------------------|------------|---------------------|-------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person and is protected under GDPR Article 4 | 7 years | High |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals, classified as personal data under GDPR | 7 years | High |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information may indirectly identify individuals, especially in small organizations, and could be used for profiling purposes | 10 years | Medium |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information, personal details, or proprietary information that requires protection | 3 years | Medium |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | May reveal personal issues, business-sensitive problems, or technical vulnerabilities that could impact privacy | 5 years | Medium |
| Bz_Billing_Events | AMOUNT | **Sensitive Financial** | Financial transaction amounts are considered sensitive personal financial information under various privacy regulations | 7 years | High |
| Bz_Licenses | LICENSE_TYPE | **Business Sensitive** | License information can reveal business structure, user privileges, and organizational hierarchy | 7 years | Medium |
| Bz_Participants | JOIN_TIME | **Behavioral PII** | Participation timestamps can create behavioral profiles and reveal personal patterns protected under privacy laws | 2 years | Medium |
| Bz_Participants | LEAVE_TIME | **Behavioral PII** | Meeting departure times contribute to behavioral profiling and personal activity tracking | 2 years | Medium |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users Table
**Description**: Stores comprehensive user profile information and subscription details for Zoom platform users with enhanced data governance and security controls

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|----------------------|
| USER_NAME | VARCHAR(100) | Display name of the user for identification and personalization purposes, subject to PII protection policies | Not Null, Length > 2 |
| EMAIL | VARCHAR(100) | User's email address used for communication, login authentication, and account management - requires encryption at rest | Valid Email Format, Unique |
| COMPANY | VARCHAR(100) | Company or organization name associated with the user for business analytics, segmentation, and enterprise reporting | Optional, Length < 100 |
| PLAN_TYPE | VARCHAR(100) | Subscription plan type (Basic, Pro, Business, Enterprise) for revenue analysis, feature access control, and usage analytics | Enum Values Only |
| REGISTRATION_DATE | DATE | Date when user first registered on the platform for lifecycle analysis | Valid Date, Not Future |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data lineage tracking | Auto-generated |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change data capture | Auto-updated |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage tracking and audit purposes | Not Null |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the record (0-100) based on completeness and accuracy | 0-100 Range |
| RETENTION_DATE | DATE | Date when record should be archived or deleted based on retention policy | Calculated Field |

### 2.2 Bz_Meetings Table
**Description**: Contains comprehensive information about video meetings conducted on the Zoom platform with enhanced temporal tracking and quality metrics

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|----------------------|
| MEETING_TOPIC | VARCHAR(100) | Topic or title of the meeting for content categorization, analysis, and business intelligence reporting | Not Null, Length > 1 |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation, usage pattern analysis, and peak time identification | Valid Timestamp |
| END_TIME | VARCHAR(100) | Meeting end timestamp for duration calculation, resource utilization tracking, and session completion analysis | After Start Time |
| DURATION_MINUTES | VARCHAR(100) | Total meeting duration in minutes for usage analytics, billing calculations, and performance metrics | Positive Number |
| MEETING_TYPE | VARCHAR(50) | Type of meeting (Scheduled, Instant, Webinar, etc.) for categorization | Enum Values |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing tracking | Auto-generated |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management | Auto-updated |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality assurance | Not Null |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the record (0-100) based on completeness and accuracy | 0-100 Range |
| RETENTION_DATE | DATE | Date when record should be archived or deleted based on retention policy | Calculated Field |

### 2.3 Bz_Participants Table
**Description**: Tracks meeting participants and their engagement metrics for comprehensive attendance and behavior analysis with privacy controls

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|----------------------|
| JOIN_TIME | VARCHAR(100) | Timestamp when participant joined the meeting for engagement analysis and attendance tracking | Valid Timestamp |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for participation duration calculation and engagement metrics | After Join Time |
| PARTICIPANT_NAME | VARCHAR(100) | Name of the meeting participant for identification and engagement tracking | Not Null |
| CONNECTION_QUALITY | VARCHAR(50) | Quality of participant's connection (Excellent, Good, Fair, Poor) for technical analysis | Enum Values |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit | Auto-generated |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data freshness tracking | Auto-updated |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and lineage | Not Null |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the record (0-100) based on completeness and accuracy | 0-100 Range |
| RETENTION_DATE | DATE | Date when record should be archived or deleted based on retention policy | Calculated Field |

### 2.4 Bz_Feature_Usage Table
**Description**: Records usage of specific platform features during meetings for comprehensive feature adoption and utilization analysis with usage analytics

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|----------------------|
| FEATURE_NAME | VARCHAR(100) | Name of the feature being tracked (Screen Share, Recording, Chat, Breakout Rooms) for adoption analysis and product development | Not Null, Valid Feature |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session for usage intensity measurement and feature popularity tracking | Positive Integer |
| USAGE_DATE | DATE | Date when feature usage occurred for temporal analysis, trend identification, and usage pattern recognition | Valid Date |
| USAGE_DURATION | NUMBER(10,2) | Duration in minutes the feature was actively used for detailed usage analytics | Positive Number |
| USAGE_TIMESTAMP | TIMESTAMP_NTZ(9) | Exact timestamp when feature was first activated for precise tracking | Valid Timestamp |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing audit | Auto-generated |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking | Auto-updated |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality control | Not Null |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the record (0-100) based on completeness and accuracy | 0-100 Range |
| RETENTION_DATE | DATE | Date when record should be archived or deleted based on retention policy | Calculated Field |

### 2.5 Bz_Support_Tickets Table
**Description**: Manages customer support requests and their resolution process for comprehensive service quality analysis and customer satisfaction tracking with SLA monitoring

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|----------------------|
| TICKET_TYPE | VARCHAR(100) | Type of support ticket (Technical, Billing, Feature Request, General Inquiry) for issue categorization and resource allocation | Valid Category |
| RESOLUTION_STATUS | VARCHAR(100) | Current status of ticket resolution (Open, In Progress, Resolved, Closed) for tracking progress and SLA compliance | Valid Status |
| OPEN_DATE | DATE | Date when the support ticket was created for response time calculation and performance metrics | Valid Date |
| CLOSE_DATE | DATE | Date when the support ticket was resolved and closed for resolution time tracking | After Open Date |
| PRIORITY_LEVEL | VARCHAR(50) | Priority level of the support request (Low, Medium, High, Critical) for resource allocation | Valid Priority |
| DESCRIPTION | VARCHAR(500) | Detailed description of the issue or request for analysis and categorization | Not Null |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit trail | Auto-generated |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management | Auto-updated |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and traceability | Not Null |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the record (0-100) based on completeness and accuracy | 0-100 Range |
| RETENTION_DATE | DATE | Date when record should be archived or deleted based on retention policy | Calculated Field |

### 2.6 Bz_Billing_Events Table
**Description**: Tracks all financial transactions and billing activities for comprehensive revenue analysis and financial reporting with enhanced security

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|----------------------|
| EVENT_TYPE | VARCHAR(100) | Type of billing event (charge, refund, adjustment, subscription) for revenue categorization and financial analysis | Valid Event Type |
| AMOUNT | VARCHAR(100) | Monetary amount for the billing event in the specified currency for financial analysis and revenue tracking | Positive Number |
| EVENT_DATE | DATE | Date when the billing event occurred for revenue trend analysis and financial reporting | Valid Date |
| PAYMENT_METHOD | VARCHAR(100) | Method used for payment (Credit Card, PayPal, Bank Transfer) for payment analysis | Valid Method |
| CURRENCY | VARCHAR(10) | Currency code for the transaction amount (USD, EUR, GBP) for multi-currency support | Valid ISO Code |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit purposes | Auto-generated |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data integrity tracking | Auto-updated |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for financial audit and compliance | Not Null |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the record (0-100) based on completeness and accuracy | 0-100 Range |
| RETENTION_DATE | DATE | Date when record should be archived or deleted based on retention policy | Calculated Field |

### 2.7 Bz_Licenses Table
**Description**: Manages license assignments and entitlements for users across different subscription tiers with comprehensive lifecycle tracking and compliance monitoring

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|----------------------|
| LICENSE_TYPE | VARCHAR(100) | Type of license (Basic, Pro, Enterprise, Add-on) for entitlement management, revenue analysis, and feature access control | Valid License Type |
| START_DATE | DATE | License validity start date for active license tracking, utilization analysis, and subscription management | Valid Date |
| END_DATE | VARCHAR(100) | License validity end date for renewal tracking, churn analysis, and subscription lifecycle management | After Start Date |
| LICENSE_STATUS | VARCHAR(50) | Current status of the license (Active, Expired, Suspended, Cancelled) for lifecycle management | Valid Status |
| ASSIGNED_USER_NAME | VARCHAR(100) | Name of the user to whom the license is assigned for user management and analytics | Not Null |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit | Auto-generated |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking | Auto-updated |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and governance | Not Null |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the record (0-100) based on completeness and accuracy | 0-100 Range |
| RETENTION_DATE | DATE | Date when record should be archived or deleted based on retention policy | Calculated Field |

## 3. Enhanced Audit Table Design

### 3.1 Bz_Audit_Log Table
**Description**: Comprehensive audit trail for tracking all data processing activities across Bronze layer tables with enhanced monitoring capabilities and compliance features

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|----------------------|
| RECORD_ID | VARCHAR(100) | Unique identifier for each audit record for tracking individual processing events and maintaining audit integrity | UUID Format |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table being processed for identifying data lineage, processing scope, and impact analysis | Valid Table Name |
| OPERATION_TYPE | VARCHAR(50) | Type of operation performed (INSERT, UPDATE, DELETE, MERGE) for detailed audit tracking | Valid Operation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation was initiated for temporal tracking and performance analysis | Auto-generated |
| PROCESSED_BY | VARCHAR(100) | Identifier of the system, user, or process that performed the operation for accountability and security auditing | Not Null |
| PROCESSING_TIME | NUMBER(10,2) | Duration of the processing operation in seconds for performance monitoring, optimization, and SLA tracking | Positive Number |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL, RETRY) for quality assurance and error handling | Valid Status |
| ERROR_MESSAGE | VARCHAR(500) | Detailed error message for failed operations to support troubleshooting and root cause analysis | Optional |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records processed in the operation for volume tracking and performance metrics | Non-negative |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the processed data (0-100) for data quality monitoring and improvement initiatives | 0-100 Range |
| COMPLIANCE_FLAG | VARCHAR(10) | Flag indicating compliance status (PASS, FAIL, REVIEW) for regulatory monitoring | Valid Flag |
| RETENTION_APPLIED | VARCHAR(10) | Flag indicating if retention policy was applied (YES, NO) for governance tracking | Valid Flag |
| LINEAGE_ID | VARCHAR(100) | Unique identifier for data lineage tracking across the entire data pipeline | UUID Format |
| SECURITY_CLASSIFICATION | VARCHAR(50) | Security classification of the processed data (PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED) | Valid Classification |

## 4. Enhanced Conceptual Data Model Diagram

### 4.1 Entity Relationship Block Diagram

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Bz_Users      │────────▶│   Bz_Meetings   │────────▶│ Bz_Participants │
│                 │         │                 │         │                 │
│ - USER_NAME     │         │ - MEETING_TOPIC │         │ - JOIN_TIME     │
│ - EMAIL         │         │ - START_TIME    │         │ - LEAVE_TIME    │
│ - COMPANY       │         │ - END_TIME      │         │ - PARTICIPANT   │
│ - PLAN_TYPE     │         │ - DURATION_MIN  │         │ - CONNECTION_Q  │
│ - REG_DATE      │         │ - MEETING_TYPE  │         └─────────────────┘
└─────────────────┘         └─────────────────┘                   │
         │                           │                           │
         │                           │                           ▼
         │                           │                 ┌─────────────────┐
         │                           └────────────────▶│Bz_Feature_Usage │
         │                                             │                 │
         │                                             │ - FEATURE_NAME  │
         │                                             │ - USAGE_COUNT   │
         │                                             │ - USAGE_DATE    │
         │                                             │ - USAGE_DURATION│
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
│ - CLOSE_DATE    │ │ - PAYMENT_METHOD│
│ - PRIORITY      │ │ - CURRENCY      │
│ - DESCRIPTION   │ └─────────────────┘
└─────────────────┘         │
         │                 │
         │                 ▼
         │         ┌─────────────────┐
         │         │   Bz_Licenses   │
         │         │                 │
         │         │ - LICENSE_TYPE  │
         │         │ - START_DATE    │
         │         │ - END_DATE      │
         │         │ - LICENSE_STATUS│
         │         │ - ASSIGNED_USER │
         │         └─────────────────┘
         │
         ▼
┌─────────────────┐
│  Bz_Audit_Log   │
│                 │
│ - RECORD_ID     │
│ - SOURCE_TABLE  │
│ - OPERATION_TYPE│
│ - LOAD_TIMESTAMP│
│ - PROCESSED_BY  │
│ - STATUS        │
│ - COMPLIANCE    │
│ - LINEAGE_ID    │
└─────────────────┘
```

### 4.2 Enhanced Table Relationships

| **Source Table** | **Target Table** | **Relationship Key Field** | **Relationship Type** | **Business Rule** |
|------------------|------------------|----------------------------|----------------------|------------------|
| Bz_Users | Bz_Meetings | User Reference (HOST_ID) | One-to-Many | User can host multiple meetings |
| Bz_Meetings | Bz_Participants | Meeting Reference (MEETING_ID) | One-to-Many | Meeting can have multiple participants |
| Bz_Meetings | Bz_Feature_Usage | Meeting Reference (MEETING_ID) | One-to-Many | Meeting can have multiple feature usages |
| Bz_Users | Bz_Support_Tickets | User Reference (USER_ID) | One-to-Many | User can create multiple support tickets |
| Bz_Users | Bz_Billing_Events | User Reference (USER_ID) | One-to-Many | User can have multiple billing events |
| Bz_Users | Bz_Licenses | User Reference (ASSIGNED_TO_USER_ID) | One-to-Many | User can have multiple licenses |
| Bz_Users | Bz_Participants | User Reference (USER_ID) | One-to-Many | User can participate in multiple meetings |
| All Tables | Bz_Audit_Log | Table Name Reference (SOURCE_TABLE) | Many-to-One | All operations are audited |

## 5. Enhanced Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Enhanced Data Governance**: Added comprehensive data quality rules, retention policies, and security classifications for enterprise-grade data management.

2. **Improved Audit Capabilities**: Enhanced audit table with operation types, compliance flags, lineage tracking, and security classifications for regulatory compliance.

3. **Data Quality Integration**: Added data quality scores to all tables for continuous monitoring and improvement of data reliability.

4. **Retention Policy Implementation**: Added retention date fields to support automated data lifecycle management and compliance requirements.

5. **Enhanced Security**: Added security classifications and compliance flags to support data protection and regulatory requirements.

6. **Complete Field Coverage**: Added missing fields from conceptual model to ensure comprehensive data capture and analysis capabilities.

7. **Performance Optimization**: Maintained VARCHAR(100) standardization while adding necessary fields for operational excellence.

### 5.2 Assumptions Made

1. **Enterprise Requirements**: Assumed enterprise-grade data governance, security, and compliance requirements need to be supported.

2. **Automated Data Management**: Assumed that automated data quality monitoring, retention management, and compliance checking will be implemented.

3. **Regulatory Compliance**: Assumed compliance with GDPR, CCPA, SOX, and other relevant data protection regulations is required.

4. **Operational Monitoring**: Assumed comprehensive operational monitoring and alerting capabilities will be implemented.

5. **Data Lineage Tracking**: Assumed end-to-end data lineage tracking is required for impact analysis and compliance.

### 5.3 Version 4 Enhancements

1. **Data Governance Framework**: Implemented comprehensive data governance with retention policies and security classifications
2. **Enhanced Audit Capabilities**: Added operation types, compliance flags, and lineage tracking to audit table
3. **Data Quality Integration**: Added data quality scores and rules to all tables for continuous monitoring
4. **Complete Field Coverage**: Added missing fields from conceptual model (registration_date, close_date, priority_level, etc.)
5. **Security Enhancements**: Added security classifications and compliance monitoring capabilities
6. **Retention Management**: Implemented automated retention date calculation for lifecycle management
7. **Operational Excellence**: Enhanced monitoring and alerting capabilities through improved audit logging
8. **Compliance Ready**: Prepared model for regulatory compliance with comprehensive audit trails and data protection measures