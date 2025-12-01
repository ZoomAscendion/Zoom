_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Enhanced Bronze layer logical data model for Zoom Platform Analytics System with improved data governance and security features
## *Version*: 4
## *Updated on*: 2024-12-19
## *Changes*: Added data masking requirements, enhanced security classifications, improved audit table with data lineage tracking, added data retention policies, and enhanced business descriptions
## *Reason*: To strengthen data governance, improve security compliance, and enhance audit capabilities for enterprise-grade data management
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason** | **Data Masking Required** | **Retention Policy** |
|----------------|-----------------|------------------------|------------|---------------------------|----------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person and is protected under GDPR Article 4 | Yes - Partial masking | 7 years |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals, classified as personal data under GDPR | Yes - Domain masking | 7 years |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information may indirectly identify individuals, especially in small organizations, and could be used for profiling purposes | No | 10 years |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information, personal details, or proprietary information that requires protection | Yes - Content filtering | 3 years |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | May reveal personal issues, business-sensitive problems, or technical vulnerabilities that could impact privacy | No | 5 years |
| Bz_Billing_Events | AMOUNT | **Sensitive Financial** | Financial transaction amounts are considered sensitive personal financial information under various privacy regulations | Yes - Amount ranges | 7 years |
| Bz_Licenses | LICENSE_TYPE | **Business Sensitive** | License information can reveal business structure, user privileges, and organizational hierarchy | No | 10 years |
| Bz_Participants | JOIN_TIME | **Behavioral PII** | Participation timestamps can create behavioral profiles and reveal personal patterns protected under privacy laws | Yes - Time rounding | 2 years |
| Bz_Participants | LEAVE_TIME | **Behavioral PII** | Meeting departure times contribute to behavioral profiling and personal activity tracking | Yes - Time rounding | 2 years |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users Table
**Description**: Comprehensive user profile repository storing authenticated user information, subscription details, and organizational affiliations for the Zoom platform with enhanced data governance and security controls

| **Column Name** | **Data Type** | **Description** | **Business Rules** | **Data Quality Checks** |
|-----------------|---------------|------------------|--------------------|-----------------------|
| USER_NAME | VARCHAR(100) | Display name of the user for identification and personalization purposes, subject to PII protection policies and masking requirements | Not null, Length > 2 characters | Validate against profanity filter |
| EMAIL | VARCHAR(100) | User's email address used for communication, login authentication, and account management - requires encryption at rest and domain validation | Valid email format, Unique per user | Email format validation, Domain verification |
| COMPANY | VARCHAR(100) | Company or organization name associated with the user for business analytics, segmentation, and enterprise reporting capabilities | Optional field | Company name standardization |
| PLAN_TYPE | VARCHAR(100) | Subscription plan type (Basic, Pro, Business, Enterprise) for revenue analysis, feature access control, and usage analytics | Must be valid plan type | Validate against master plan list |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data lineage tracking and audit purposes | Auto-generated, Not null | Timestamp validation |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change data capture and version control | Auto-updated on change | Timestamp validation |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage tracking and audit purposes | Not null | Validate against source system registry |

### 2.2 Bz_Meetings Table
**Description**: Comprehensive meeting repository containing detailed information about video conferences conducted on the Zoom platform with enhanced temporal tracking and content analysis capabilities

| **Column Name** | **Data Type** | **Description** | **Business Rules** | **Data Quality Checks** |
|-----------------|---------------|------------------|--------------------|-----------------------|
| MEETING_TOPIC | VARCHAR(100) | Topic or title of the meeting for content categorization, analysis, and business intelligence reporting with content filtering | Optional, Subject to content filtering | Content validation, Length check |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation, usage pattern analysis, and peak time identification | Not null, Must be valid timestamp | Timestamp range validation |
| END_TIME | VARCHAR(100) | Meeting end timestamp for duration calculation, resource utilization tracking, and session completion analysis | Must be after start_time | Logical time sequence validation |
| DURATION_MINUTES | VARCHAR(100) | Total meeting duration in minutes for usage analytics, billing calculations, and performance metrics | Calculated field, Non-negative | Duration consistency check |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing tracking | Auto-generated, Not null | Timestamp validation |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management | Auto-updated on change | Timestamp validation |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality assurance | Not null | Validate against source system registry |

### 2.3 Bz_Participants Table
**Description**: Detailed participant tracking system for meeting attendance and engagement metrics with comprehensive behavior analysis and privacy protection measures

| **Column Name** | **Data Type** | **Description** | **Business Rules** | **Data Quality Checks** |
|-----------------|---------------|------------------|--------------------|-----------------------|
| JOIN_TIME | VARCHAR(100) | Timestamp when participant joined the meeting for engagement analysis and attendance tracking with privacy rounding | Subject to time rounding for privacy | Time format validation |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for participation duration calculation and engagement metrics | Must be after join_time | Logical time sequence validation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit | Auto-generated, Not null | Timestamp validation |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data freshness tracking | Auto-updated on change | Timestamp validation |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and lineage | Not null | Validate against source system registry |

### 2.4 Bz_Feature_Usage Table
**Description**: Comprehensive feature utilization tracking system for platform capabilities during meetings with detailed adoption analysis and product development insights

| **Column Name** | **Data Type** | **Description** | **Business Rules** | **Data Quality Checks** |
|-----------------|---------------|------------------|--------------------|-----------------------|
| FEATURE_NAME | VARCHAR(100) | Name of the feature being tracked (Screen Share, Recording, Chat, Breakout Rooms) for adoption analysis and product development | Must be valid feature name | Validate against feature catalog |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session for usage intensity measurement and feature popularity tracking | Non-negative integer | Range validation (0-1000) |
| USAGE_DATE | DATE | Date when feature usage occurred for temporal analysis, trend identification, and usage pattern recognition | Valid date, Not future date | Date range validation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing audit | Auto-generated, Not null | Timestamp validation |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking | Auto-updated on change | Timestamp validation |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality control | Not null | Validate against source system registry |

### 2.5 Bz_Support_Tickets Table
**Description**: Comprehensive customer support management system for tracking service requests and resolution processes with enhanced service quality analysis and customer satisfaction metrics

| **Column Name** | **Data Type** | **Description** | **Business Rules** | **Data Quality Checks** |
|-----------------|---------------|------------------|--------------------|-----------------------|
| TICKET_TYPE | VARCHAR(100) | Type of support ticket (Technical, Billing, Feature Request, General Inquiry) for issue categorization and resource allocation | Must be valid ticket type | Validate against ticket type catalog |
| RESOLUTION_STATUS | VARCHAR(100) | Current status of ticket resolution (Open, In Progress, Resolved, Closed) for tracking progress and SLA compliance | Must be valid status | Validate against status workflow |
| OPEN_DATE | DATE | Date when the support ticket was created for response time calculation and performance metrics | Valid date, Not future date | Date validation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit trail | Auto-generated, Not null | Timestamp validation |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management | Auto-updated on change | Timestamp validation |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and traceability | Not null | Validate against source system registry |

### 2.6 Bz_Billing_Events Table
**Description**: Comprehensive financial transaction tracking system for all billing activities with enhanced revenue analysis, financial reporting, and compliance monitoring capabilities

| **Column Name** | **Data Type** | **Description** | **Business Rules** | **Data Quality Checks** |
|-----------------|---------------|------------------|--------------------|-----------------------|
| EVENT_TYPE | VARCHAR(100) | Type of billing event (charge, refund, adjustment, subscription) for revenue categorization and financial analysis | Must be valid event type | Validate against billing event catalog |
| AMOUNT | VARCHAR(100) | Monetary amount for the billing event in the specified currency for financial analysis and revenue tracking with masking | Non-negative for charges | Amount format validation |
| EVENT_DATE | DATE | Date when the billing event occurred for revenue trend analysis and financial reporting | Valid date, Not future date | Date validation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit purposes | Auto-generated, Not null | Timestamp validation |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data integrity tracking | Auto-updated on change | Timestamp validation |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for financial audit and compliance | Not null | Validate against source system registry |

### 2.7 Bz_Licenses Table
**Description**: Comprehensive license management system for user entitlements across subscription tiers with detailed lifecycle tracking and compliance monitoring

| **Column Name** | **Data Type** | **Description** | **Business Rules** | **Data Quality Checks** |
|-----------------|---------------|------------------|--------------------|-----------------------|
| LICENSE_TYPE | VARCHAR(100) | Type of license (Basic, Pro, Enterprise, Add-on) for entitlement management, revenue analysis, and feature access control | Must be valid license type | Validate against license catalog |
| START_DATE | DATE | License validity start date for active license tracking, utilization analysis, and subscription management | Valid date | Date validation |
| END_DATE | VARCHAR(100) | License validity end date for renewal tracking, churn analysis, and subscription lifecycle management | Must be after start_date | Date sequence validation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit | Auto-generated, Not null | Timestamp validation |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking | Auto-updated on change | Timestamp validation |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and governance | Not null | Validate against source system registry |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log Table
**Description**: Enterprise-grade audit trail system for comprehensive tracking of all data processing activities across Bronze layer tables with enhanced monitoring, security, and compliance capabilities

| **Column Name** | **Data Type** | **Description** | **Business Rules** | **Data Quality Checks** |
|-----------------|---------------|------------------|--------------------|-----------------------|
| RECORD_ID | VARCHAR(100) | Unique identifier for each audit record for tracking individual processing events and maintaining audit integrity | Auto-generated UUID | UUID format validation |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table being processed for identifying data lineage, processing scope, and impact analysis | Must be valid table name | Validate against table catalog |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation was initiated for temporal tracking and performance analysis | Auto-generated, Not null | Timestamp validation |
| PROCESSED_BY | VARCHAR(100) | Identifier of the system, user, or process that performed the operation for accountability and security auditing | Not null | Validate against user/system registry |
| PROCESSING_TIME | NUMBER(10,2) | Duration of the processing operation in seconds for performance monitoring, optimization, and SLA tracking | Non-negative | Range validation (0-3600) |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL, RETRY) for quality assurance and error handling | Must be valid status | Validate against status catalog |
| ERROR_MESSAGE | VARCHAR(100) | Detailed error message for failed operations to support troubleshooting and root cause analysis | Optional for success | Length validation |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records processed in the operation for volume tracking and performance metrics | Non-negative | Range validation |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the processed data (0-100) for data quality monitoring and improvement initiatives | Range 0-100 | Score range validation |
| DATA_LINEAGE_ID | VARCHAR(100) | Unique identifier linking to data lineage tracking system for comprehensive data flow monitoring | Auto-generated | UUID format validation |
| COMPLIANCE_FLAG | VARCHAR(10) | Flag indicating compliance status (PASS, FAIL, REVIEW) for regulatory and governance monitoring | Must be valid flag | Validate against compliance catalog |
| RETENTION_DATE | DATE | Date when the record should be archived or deleted based on retention policies | Calculated field | Date validation |

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
│ - DATA_LINEAGE_ID│
│ - COMPLIANCE_FLAG│
└─────────────────┘
```

### 4.2 Table Relationships

| **Source Table** | **Target Table** | **Relationship Key Field** | **Relationship Type** | **Business Context** |
|------------------|------------------|----------------------------|----------------------|---------------------|
| Bz_Users | Bz_Meetings | User Reference (HOST_ID) | One-to-Many | Users can host multiple meetings |
| Bz_Meetings | Bz_Participants | Meeting Reference (MEETING_ID) | One-to-Many | Meetings can have multiple participants |
| Bz_Meetings | Bz_Feature_Usage | Meeting Reference (MEETING_ID) | One-to-Many | Features can be used multiple times per meeting |
| Bz_Users | Bz_Support_Tickets | User Reference (USER_ID) | One-to-Many | Users can create multiple support tickets |
| Bz_Users | Bz_Billing_Events | User Reference (USER_ID) | One-to-Many | Users can have multiple billing events |
| Bz_Users | Bz_Licenses | User Reference (ASSIGNED_TO_USER_ID) | One-to-Many | Users can have multiple licenses |
| Bz_Users | Bz_Participants | User Reference (USER_ID) | One-to-Many | Users can participate in multiple meetings |
| All Tables | Bz_Audit_Log | Table Name Reference (SOURCE_TABLE) | Many-to-One | All tables generate audit records |

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Enhanced Security Framework**: Implemented comprehensive data masking requirements and retention policies to ensure compliance with privacy regulations and enterprise security standards.

2. **Advanced Audit Capabilities**: Enhanced audit table with data lineage tracking, compliance flags, and retention management for enterprise-grade monitoring and governance.

3. **Data Quality Framework**: Added business rules and data quality checks for each column to ensure data integrity and reliability throughout the data pipeline.

4. **Comprehensive PII Management**: Enhanced PII classification with specific masking requirements and retention policies to support GDPR, CCPA, and other privacy regulations.

5. **Enterprise Data Governance**: Implemented validation rules against master catalogs and registries to ensure data consistency and governance compliance.

6. **Performance Optimization**: Maintained VARCHAR(100) standardization while adding comprehensive metadata for improved query performance and storage efficiency.

7. **Compliance Monitoring**: Added compliance flags and retention dates to support automated compliance monitoring and data lifecycle management.

### 5.2 Assumptions Made

1. **Enterprise Security Requirements**: Assumed that enterprise-grade security measures including data masking, encryption, and access controls will be implemented.

2. **Regulatory Compliance**: Assumed compliance with multiple privacy regulations (GDPR, CCPA, HIPAA) requiring comprehensive data protection measures.

3. **Data Quality Standards**: Assumed that automated data quality validation and monitoring systems will be implemented to enforce business rules.

4. **Master Data Management**: Assumed that master catalogs and registries exist for validation of reference data and lookup values.

5. **Audit Requirements**: Assumed that comprehensive audit logging with data lineage tracking is required for regulatory compliance and operational monitoring.

6. **Retention Management**: Assumed that automated data retention and archival processes will be implemented based on defined retention policies.

7. **Performance Requirements**: Assumed that high-performance data processing capabilities are required to handle enterprise-scale data volumes.

### 5.3 Version 4 Enhancements

1. **Enhanced Security**: Added comprehensive data masking requirements and security classifications for all PII fields
2. **Advanced Audit Trail**: Enhanced audit table with data lineage tracking, compliance flags, and retention management
3. **Data Quality Framework**: Added business rules and data quality checks for all columns
4. **Retention Policies**: Implemented data retention policies for compliance and lifecycle management
5. **Compliance Monitoring**: Added compliance flags and automated monitoring capabilities
6. **Enhanced Business Context**: Provided detailed business descriptions and rules for all data elements
7. **Enterprise Governance**: Implemented validation against master catalogs and registries for data consistency
8. **Performance Optimization**: Enhanced metadata structure while maintaining performance optimization
9. **Comprehensive Documentation**: Added detailed business context and relationship descriptions
10. **Security Framework**: Implemented enterprise-grade security framework with comprehensive protection measures