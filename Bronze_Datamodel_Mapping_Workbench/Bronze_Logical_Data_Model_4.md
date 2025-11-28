_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Enhanced Bronze layer logical data model for Zoom Platform Analytics System with improved data governance and compliance features
## *Version*: 4 
## *Updated on*: 2024-12-19
## *Changes*: Added data retention policies, enhanced security classifications, improved audit trail capabilities, added data quality validation rules, and enhanced compliance framework
## *Reason*: To strengthen data governance, improve compliance with privacy regulations, and enhance data quality monitoring capabilities
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason** | **Retention Policy** | **Security Level** |
|----------------|-----------------|------------------------|------------|---------------------|-------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person and is protected under GDPR Article 4 | 7 years | High Encryption |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals, classified as personal data under GDPR | 7 years | High Encryption |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information may indirectly identify individuals, especially in small organizations, and could be used for profiling purposes | 10 years | Standard Encryption |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information, personal details, or proprietary information that requires protection | 3 years | Standard Encryption |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | May reveal personal issues, business-sensitive problems, or technical vulnerabilities that could impact privacy | 5 years | Standard Encryption |
| Bz_Billing_Events | AMOUNT | **Sensitive Financial** | Financial transaction amounts are considered sensitive personal financial information under various privacy regulations | 7 years | High Encryption |
| Bz_Licenses | LICENSE_TYPE | **Business Sensitive** | License information can reveal business structure, user privileges, and organizational hierarchy | 7 years | Standard Encryption |
| Bz_Participants | JOIN_TIME | **Behavioral PII** | Participation timestamps can create behavioral profiles and reveal personal patterns protected under privacy laws | 2 years | Standard Encryption |
| Bz_Participants | LEAVE_TIME | **Behavioral PII** | Meeting departure times contribute to behavioral profiling and personal activity tracking | 2 years | Standard Encryption |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users Table
**Description**: Stores comprehensive user profile information and subscription details for Zoom platform users with enhanced data governance
**Data Quality Rules**: Email format validation, Plan type enumeration validation, Company name length validation
**Compliance Framework**: GDPR, CCPA, SOX compliant

| **Column Name** | **Data Type** | **Description** | **Validation Rules** |
|-----------------|---------------|------------------|---------------------|
| USER_NAME | VARCHAR(100) | Display name of the user for identification and personalization purposes, subject to PII protection policies | NOT NULL, Length 2-100 characters |
| EMAIL | VARCHAR(100) | User's email address used for communication, login authentication, and account management - requires encryption at rest | NOT NULL, Valid email format, Unique |
| COMPANY | VARCHAR(100) | Company or organization name associated with the user for business analytics, segmentation, and enterprise reporting | Length 1-100 characters |
| PLAN_TYPE | VARCHAR(100) | Subscription plan type (Basic, Pro, Business, Enterprise) for revenue analysis, feature access control, and usage analytics | NOT NULL, Valid plan enumeration |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data lineage tracking | NOT NULL, Valid timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change data capture | NOT NULL, >= LOAD_TIMESTAMP |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage tracking and audit purposes | NOT NULL, Valid system identifier |

### 2.2 Bz_Meetings Table
**Description**: Contains comprehensive information about video meetings conducted on the Zoom platform with enhanced temporal tracking
**Data Quality Rules**: Duration validation, Start/End time consistency, Meeting topic length validation
**Compliance Framework**: Business data retention compliant

| **Column Name** | **Data Type** | **Description** | **Validation Rules** |
|-----------------|---------------|------------------|---------------------|
| MEETING_TOPIC | VARCHAR(100) | Topic or title of the meeting for content categorization, analysis, and business intelligence reporting | Length 1-100 characters |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation, usage pattern analysis, and peak time identification | NOT NULL, Valid timestamp |
| END_TIME | VARCHAR(100) | Meeting end timestamp for duration calculation, resource utilization tracking, and session completion analysis | Valid timestamp format if provided |
| DURATION_MINUTES | VARCHAR(100) | Total meeting duration in minutes for usage analytics, billing calculations, and performance metrics | Numeric value >= 0 |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing tracking | NOT NULL, Valid timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management | NOT NULL, >= LOAD_TIMESTAMP |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality assurance | NOT NULL, Valid system identifier |

### 2.3 Bz_Participants Table
**Description**: Tracks meeting participants and their engagement metrics for comprehensive attendance and behavior analysis
**Data Quality Rules**: Join/Leave time consistency, Participation duration validation
**Compliance Framework**: Privacy-focused with behavioral data protection

| **Column Name** | **Data Type** | **Description** | **Validation Rules** |
|-----------------|---------------|------------------|---------------------|
| JOIN_TIME | VARCHAR(100) | Timestamp when participant joined the meeting for engagement analysis and attendance tracking | Valid timestamp format |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for participation duration calculation and engagement metrics | Valid timestamp, >= JOIN_TIME |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit | NOT NULL, Valid timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data freshness tracking | NOT NULL, >= LOAD_TIMESTAMP |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and lineage | NOT NULL, Valid system identifier |

### 2.4 Bz_Feature_Usage Table
**Description**: Records usage of specific platform features during meetings for comprehensive feature adoption and utilization analysis
**Data Quality Rules**: Feature name enumeration, Usage count validation, Date consistency
**Compliance Framework**: Product analytics compliant

| **Column Name** | **Data Type** | **Description** | **Validation Rules** |
|-----------------|---------------|------------------|---------------------|
| FEATURE_NAME | VARCHAR(100) | Name of the feature being tracked (Screen Share, Recording, Chat, Breakout Rooms) for adoption analysis and product development | NOT NULL, Valid feature enumeration |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session for usage intensity measurement and feature popularity tracking | NOT NULL, >= 0 |
| USAGE_DATE | DATE | Date when feature usage occurred for temporal analysis, trend identification, and usage pattern recognition | NOT NULL, Valid date |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing audit | NOT NULL, Valid timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking | NOT NULL, >= LOAD_TIMESTAMP |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality control | NOT NULL, Valid system identifier |

### 2.5 Bz_Support_Tickets Table
**Description**: Manages customer support requests and their resolution process for comprehensive service quality analysis and customer satisfaction tracking
**Data Quality Rules**: Ticket type enumeration, Status validation, Date consistency
**Compliance Framework**: Customer service data protection compliant

| **Column Name** | **Data Type** | **Description** | **Validation Rules** |
|-----------------|---------------|------------------|---------------------|
| TICKET_TYPE | VARCHAR(100) | Type of support ticket (Technical, Billing, Feature Request, General Inquiry) for issue categorization and resource allocation | NOT NULL, Valid ticket type enumeration |
| RESOLUTION_STATUS | VARCHAR(100) | Current status of ticket resolution (Open, In Progress, Resolved, Closed) for tracking progress and SLA compliance | NOT NULL, Valid status enumeration |
| OPEN_DATE | DATE | Date when the support ticket was created for response time calculation and performance metrics | NOT NULL, Valid date |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit trail | NOT NULL, Valid timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management | NOT NULL, >= LOAD_TIMESTAMP |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and traceability | NOT NULL, Valid system identifier |

### 2.6 Bz_Billing_Events Table
**Description**: Tracks all financial transactions and billing activities for comprehensive revenue analysis and financial reporting
**Data Quality Rules**: Amount validation, Event type enumeration, Date consistency
**Compliance Framework**: Financial data protection and SOX compliant

| **Column Name** | **Data Type** | **Description** | **Validation Rules** |
|-----------------|---------------|------------------|---------------------|
| EVENT_TYPE | VARCHAR(100) | Type of billing event (charge, refund, adjustment, subscription) for revenue categorization and financial analysis | NOT NULL, Valid event type enumeration |
| AMOUNT | VARCHAR(100) | Monetary amount for the billing event in the specified currency for financial analysis and revenue tracking | NOT NULL, Valid currency format |
| EVENT_DATE | DATE | Date when the billing event occurred for revenue trend analysis and financial reporting | NOT NULL, Valid date |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit purposes | NOT NULL, Valid timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data integrity tracking | NOT NULL, >= LOAD_TIMESTAMP |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for financial audit and compliance | NOT NULL, Valid system identifier |

### 2.7 Bz_Licenses Table
**Description**: Manages license assignments and entitlements for users across different subscription tiers with comprehensive lifecycle tracking
**Data Quality Rules**: License type enumeration, Date range validation, Status consistency
**Compliance Framework**: License management and compliance tracking

| **Column Name** | **Data Type** | **Description** | **Validation Rules** |
|-----------------|---------------|------------------|---------------------|
| LICENSE_TYPE | VARCHAR(100) | Type of license (Basic, Pro, Enterprise, Add-on) for entitlement management, revenue analysis, and feature access control | NOT NULL, Valid license type enumeration |
| START_DATE | DATE | License validity start date for active license tracking, utilization analysis, and subscription management | NOT NULL, Valid date |
| END_DATE | VARCHAR(100) | License validity end date for renewal tracking, churn analysis, and subscription lifecycle management | Valid date format, >= START_DATE |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit | NOT NULL, Valid timestamp |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking | NOT NULL, >= LOAD_TIMESTAMP |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and governance | NOT NULL, Valid system identifier |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log Table
**Description**: Comprehensive audit trail for tracking all data processing activities across Bronze layer tables with enhanced monitoring capabilities
**Data Quality Rules**: Status enumeration, Processing time validation, Record count validation
**Compliance Framework**: Full audit trail for regulatory compliance

| **Column Name** | **Data Type** | **Description** | **Validation Rules** |
|-----------------|---------------|------------------|---------------------|
| RECORD_ID | VARCHAR(100) | Unique identifier for each audit record for tracking individual processing events and maintaining audit integrity | NOT NULL, Unique identifier |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table being processed for identifying data lineage, processing scope, and impact analysis | NOT NULL, Valid table name |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation was initiated for temporal tracking and performance analysis | NOT NULL, Valid timestamp |
| PROCESSED_BY | VARCHAR(100) | Identifier of the system, user, or process that performed the operation for accountability and security auditing | NOT NULL, Valid process identifier |
| PROCESSING_TIME | NUMBER(10,2) | Duration of the processing operation in seconds for performance monitoring, optimization, and SLA tracking | NOT NULL, >= 0 |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL, RETRY) for quality assurance and error handling | NOT NULL, Valid status enumeration |
| ERROR_MESSAGE | VARCHAR(100) | Detailed error message for failed operations to support troubleshooting and root cause analysis | Length <= 100 characters |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records processed in the operation for volume tracking and performance metrics | >= 0 |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the processed data (0-100) for data quality monitoring and improvement initiatives | Between 0 and 100 |
| COMPLIANCE_FLAG | VARCHAR(10) | Flag indicating compliance status (COMPLIANT, NON_COMPLIANT, PENDING) for regulatory tracking | Valid compliance enumeration |
| RETENTION_DATE | DATE | Date when the record should be archived or deleted based on retention policies | Valid future date |

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
│ - COMPLIANCE_FLAG│
│ - RETENTION_DATE│
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

## 5. Data Governance Framework

### 5.1 Data Retention Policies

| **Data Category** | **Retention Period** | **Archival Strategy** | **Deletion Policy** |
|-------------------|---------------------|----------------------|--------------------|
| User PII Data | 7 years | Encrypted archive after 3 years | Secure deletion after retention period |
| Financial Data | 7 years | Encrypted archive after 5 years | Secure deletion with audit trail |
| Meeting Data | 3 years | Standard archive after 1 year | Standard deletion |
| Support Data | 5 years | Standard archive after 2 years | Standard deletion |
| Behavioral Data | 2 years | No archival | Automatic deletion |
| Audit Logs | 10 years | Compressed archive after 3 years | Secure deletion with compliance verification |

### 5.2 Security Classifications

| **Security Level** | **Encryption** | **Access Control** | **Monitoring** |
|-------------------|----------------|-------------------|----------------|
| High Encryption | AES-256 at rest and in transit | Role-based with MFA | Real-time monitoring and alerting |
| Standard Encryption | AES-128 at rest | Role-based access | Daily monitoring |
| Basic Protection | Standard database encryption | Standard access controls | Weekly monitoring |

## 6. Design Rationale and Assumptions

### 6.1 Key Design Decisions

1. **Enhanced Data Governance**: Added comprehensive data retention policies, security classifications, and compliance frameworks to support regulatory requirements.

2. **Data Quality Validation**: Implemented validation rules for each column to ensure data integrity and quality at the Bronze layer.

3. **Compliance Framework**: Enhanced PII classification with retention policies and security levels to support GDPR, CCPA, and SOX compliance.

4. **Audit Trail Enhancement**: Added compliance flags and retention dates to the audit table for comprehensive regulatory tracking.

5. **Security-First Approach**: Implemented multi-level security classifications to protect sensitive data appropriately.

6. **Performance Optimization**: Maintained VARCHAR(100) standardization while adding validation rules for data quality.

### 6.2 Version 4 Enhancements

1. **Data Retention Policies**: Added comprehensive retention policies for different data categories
2. **Enhanced Security Classifications**: Implemented multi-level security framework with encryption requirements
3. **Data Quality Validation Rules**: Added validation rules for each column to ensure data integrity
4. **Compliance Framework**: Enhanced compliance tracking with flags and monitoring
5. **Audit Trail Improvements**: Added compliance flags and retention dates to audit logs
6. **Governance Framework**: Implemented comprehensive data governance policies and procedures
7. **Privacy Protection**: Enhanced privacy protection measures for PII and behavioral data
8. **Regulatory Compliance**: Strengthened compliance with GDPR, CCPA, SOX, and other regulations

### 6.3 Assumptions Made

1. **Regulatory Environment**: Assumed operation in a multi-jurisdictional environment requiring compliance with various privacy and financial regulations.

2. **Data Volume and Velocity**: Assumed high-volume, high-velocity data processing requiring efficient governance and quality controls.

3. **Security Requirements**: Assumed enterprise-level security requirements with multi-level data classification needs.

4. **Audit Requirements**: Assumed comprehensive audit requirements for regulatory compliance and operational monitoring.

5. **Data Quality Standards**: Assumed need for robust data quality validation and monitoring capabilities.

6. **Retention Compliance**: Assumed need for automated data retention and deletion capabilities to support compliance requirements.

7. **Performance Requirements**: Assumed need to balance data governance requirements with performance optimization needs.