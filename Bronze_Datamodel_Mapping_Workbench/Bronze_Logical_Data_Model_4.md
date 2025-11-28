_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Enhanced Bronze layer logical data model for Zoom Platform Analytics System with improved data governance and compliance features
## *Version*: 4 
## *Updated on*: 2024-12-19
## *Changes*: Added data retention policies, enhanced security classifications, improved audit capabilities, added data quality metrics, and standardized timestamp handling
## *Reason*: To enhance data governance, improve compliance with privacy regulations, and provide better data quality monitoring capabilities
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| **Table Name** | **Column Name** | **PII Classification** | **Reason** | **Retention Policy** |
|----------------|-----------------|------------------------|------------|---------------------|
| Bz_Users | USER_NAME | **Sensitive PII** | Contains personal identifiable information - individual's full name that can directly identify a person and is protected under GDPR Article 4 | 7 years after account closure |
| Bz_Users | EMAIL | **Sensitive PII** | Email addresses are personally identifiable information that can be used to contact and identify individuals, classified as personal data under GDPR | 7 years after account closure |
| Bz_Users | COMPANY | **Non-Sensitive PII** | Company information may indirectly identify individuals, especially in small organizations, and could be used for profiling purposes | 5 years after account closure |
| Bz_Meetings | MEETING_TOPIC | **Potentially Sensitive** | Meeting topics may contain confidential business information, personal details, or proprietary information that requires protection | 3 years after meeting date |
| Bz_Support_Tickets | TICKET_TYPE | **Potentially Sensitive** | May reveal personal issues, business-sensitive problems, or technical vulnerabilities that could impact privacy | 5 years after ticket closure |
| Bz_Billing_Events | AMOUNT | **Sensitive Financial** | Financial transaction amounts are considered sensitive personal financial information under various privacy regulations | 10 years for tax compliance |
| Bz_Licenses | LICENSE_TYPE | **Business Sensitive** | License information can reveal business structure, user privileges, and organizational hierarchy | 3 years after license expiry |
| Bz_Participants | JOIN_TIME | **Behavioral PII** | Participation timestamps can create behavioral profiles and reveal personal patterns protected under privacy laws | 2 years after meeting date |
| Bz_Participants | LEAVE_TIME | **Behavioral PII** | Meeting departure times contribute to behavioral profiling and personal activity tracking | 2 years after meeting date |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users Table
**Description**: Stores comprehensive user profile information and subscription details for Zoom platform users with enhanced data governance

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|-----------------------|
| USER_NAME | VARCHAR(100) | Display name of the user for identification and personalization purposes, subject to PII protection policies | Not null, length > 2 characters |
| EMAIL | VARCHAR(100) | User's email address used for communication, login authentication, and account management - requires encryption at rest | Valid email format, unique |
| COMPANY | VARCHAR(100) | Company or organization name associated with the user for business analytics, segmentation, and enterprise reporting | Optional, length < 100 characters |
| PLAN_TYPE | VARCHAR(100) | Subscription plan type (Basic, Pro, Business, Enterprise) for revenue analysis, feature access control, and usage analytics | Must be from predefined list |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data lineage tracking | Auto-generated, not null |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change data capture | Auto-updated on changes |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage tracking and audit purposes | Not null, from approved list |
| DATA_CLASSIFICATION | VARCHAR(50) | Security classification level for the record (PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED) | Default: CONFIDENTIAL |

### 2.2 Bz_Meetings Table
**Description**: Contains comprehensive information about video meetings conducted on the Zoom platform with enhanced temporal tracking

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|-----------------------|
| MEETING_TOPIC | VARCHAR(100) | Topic or title of the meeting for content categorization, analysis, and business intelligence reporting | Optional, sanitized content |
| START_TIME | TIMESTAMP_NTZ(9) | Meeting start timestamp for duration calculation, usage pattern analysis, and peak time identification | Not null, valid timestamp |
| END_TIME | TIMESTAMP_NTZ(9) | Meeting end timestamp for duration calculation, resource utilization tracking, and session completion analysis | Must be after START_TIME |
| DURATION_MINUTES | NUMBER(10,2) | Total meeting duration in minutes for usage analytics, billing calculations, and performance metrics | Calculated field, >= 0 |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing tracking | Auto-generated, not null |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management | Auto-updated on changes |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality assurance | Not null, from approved list |
| DATA_CLASSIFICATION | VARCHAR(50) | Security classification level for the record | Default: INTERNAL |

### 2.3 Bz_Participants Table
**Description**: Tracks meeting participants and their engagement metrics for comprehensive attendance and behavior analysis

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|-----------------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant joined the meeting for engagement analysis and attendance tracking | Not null, valid timestamp |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when participant left the meeting for participation duration calculation and engagement metrics | Must be after JOIN_TIME |
| PARTICIPATION_DURATION | NUMBER(10,2) | Calculated duration of participation in minutes | Derived from JOIN_TIME and LEAVE_TIME |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit | Auto-generated, not null |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data freshness tracking | Auto-updated on changes |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and lineage | Not null, from approved list |
| DATA_CLASSIFICATION | VARCHAR(50) | Security classification level for the record | Default: CONFIDENTIAL |

### 2.4 Bz_Feature_Usage Table
**Description**: Records usage of specific platform features during meetings for comprehensive feature adoption and utilization analysis

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|-----------------------|
| FEATURE_NAME | VARCHAR(100) | Name of the feature being tracked (Screen Share, Recording, Chat, Breakout Rooms) for adoption analysis and product development | Not null, from feature catalog |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session for usage intensity measurement and feature popularity tracking | >= 0, not null |
| USAGE_DATE | DATE | Date when feature usage occurred for temporal analysis, trend identification, and usage pattern recognition | Valid date, not future |
| USAGE_DURATION | NUMBER(10,2) | Duration of feature usage in minutes | >= 0, calculated field |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for data processing audit | Auto-generated, not null |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking | Auto-updated on changes |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and quality control | Not null, from approved list |
| DATA_CLASSIFICATION | VARCHAR(50) | Security classification level for the record | Default: INTERNAL |

### 2.5 Bz_Support_Tickets Table
**Description**: Manages customer support requests and their resolution process for comprehensive service quality analysis and customer satisfaction tracking

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|-----------------------|
| TICKET_TYPE | VARCHAR(100) | Type of support ticket (Technical, Billing, Feature Request, General Inquiry) for issue categorization and resource allocation | Not null, from predefined categories |
| RESOLUTION_STATUS | VARCHAR(100) | Current status of ticket resolution (Open, In Progress, Resolved, Closed) for tracking progress and SLA compliance | Not null, valid status |
| OPEN_DATE | DATE | Date when the support ticket was created for response time calculation and performance metrics | Not null, not future date |
| CLOSE_DATE | DATE | Date when the support ticket was resolved for SLA tracking | Must be after OPEN_DATE |
| PRIORITY_LEVEL | VARCHAR(20) | Priority level of the ticket (Low, Medium, High, Critical) | Default: Medium |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit trail | Auto-generated, not null |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change management | Auto-updated on changes |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data governance and traceability | Not null, from approved list |
| DATA_CLASSIFICATION | VARCHAR(50) | Security classification level for the record | Default: CONFIDENTIAL |

### 2.6 Bz_Billing_Events Table
**Description**: Tracks all financial transactions and billing activities for comprehensive revenue analysis and financial reporting

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|-----------------------|
| EVENT_TYPE | VARCHAR(100) | Type of billing event (charge, refund, adjustment, subscription) for revenue categorization and financial analysis | Not null, from billing event types |
| AMOUNT | NUMBER(15,2) | Monetary amount for the billing event in the specified currency for financial analysis and revenue tracking | Not null, >= 0 for charges |
| CURRENCY | VARCHAR(3) | Currency code for the transaction amount | ISO 4217 currency codes |
| EVENT_DATE | DATE | Date when the billing event occurred for revenue trend analysis and financial reporting | Not null, valid business date |
| PAYMENT_METHOD | VARCHAR(50) | Method of payment used for the transaction | From approved payment methods |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for audit purposes | Auto-generated, not null |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for data integrity tracking | Auto-updated on changes |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for financial audit and compliance | Not null, from approved list |
| DATA_CLASSIFICATION | VARCHAR(50) | Security classification level for the record | Default: RESTRICTED |

### 2.7 Bz_Licenses Table
**Description**: Manages license assignments and entitlements for users across different subscription tiers with comprehensive lifecycle tracking

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|-----------------------|
| LICENSE_TYPE | VARCHAR(100) | Type of license (Basic, Pro, Enterprise, Add-on) for entitlement management, revenue analysis, and feature access control | Not null, from license catalog |
| START_DATE | DATE | License validity start date for active license tracking, utilization analysis, and subscription management | Not null, valid date |
| END_DATE | DATE | License validity end date for renewal tracking, churn analysis, and subscription lifecycle management | Must be after START_DATE |
| LICENSE_STATUS | VARCHAR(20) | Current status of the license (Active, Expired, Suspended, Cancelled) | Not null, valid status |
| ASSIGNED_USER_NAME | VARCHAR(100) | Name of the user to whom the license is assigned | Not null when status is Active |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was initially loaded into the Bronze layer for processing audit | Auto-generated, not null |
| UPDATE_TIMESTAMP | TIMESTAMP_NTZ(9) | System timestamp when the record was last updated in the Bronze layer for change tracking | Auto-updated on changes |
| SOURCE_SYSTEM | VARCHAR(100) | Identifier of the source system from which the data originated for data lineage and governance | Not null, from approved list |
| DATA_CLASSIFICATION | VARCHAR(50) | Security classification level for the record | Default: CONFIDENTIAL |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log Table
**Description**: Comprehensive audit trail for tracking all data processing activities across Bronze layer tables with enhanced monitoring capabilities

| **Column Name** | **Data Type** | **Description** | **Data Quality Rule** |
|-----------------|---------------|------------------|-----------------------|
| RECORD_ID | VARCHAR(100) | Unique identifier for each audit record for tracking individual processing events and maintaining audit integrity | Not null, unique |
| SOURCE_TABLE | VARCHAR(100) | Name of the source table being processed for identifying data lineage, processing scope, and impact analysis | Not null, valid table name |
| OPERATION_TYPE | VARCHAR(20) | Type of operation performed (INSERT, UPDATE, DELETE, MERGE) | Not null, valid operation |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Timestamp when the data processing operation was initiated for temporal tracking and performance analysis | Auto-generated, not null |
| PROCESSED_BY | VARCHAR(100) | Identifier of the system, user, or process that performed the operation for accountability and security auditing | Not null, valid identifier |
| PROCESSING_TIME | NUMBER(10,2) | Duration of the processing operation in seconds for performance monitoring, optimization, and SLA tracking | >= 0, not null |
| STATUS | VARCHAR(50) | Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL, RETRY) for quality assurance and error handling | Not null, valid status |
| ERROR_MESSAGE | VARCHAR(500) | Detailed error message for failed operations to support troubleshooting and root cause analysis | Required when STATUS = FAILED |
| RECORDS_PROCESSED | NUMBER(38,0) | Number of records processed in the operation for volume tracking and performance metrics | >= 0, not null |
| RECORDS_FAILED | NUMBER(38,0) | Number of records that failed processing | >= 0, <= RECORDS_PROCESSED |
| DATA_QUALITY_SCORE | NUMBER(5,2) | Quality score of the processed data (0-100) for data quality monitoring and improvement initiatives | Between 0 and 100 |
| COMPLIANCE_FLAG | VARCHAR(10) | Flag indicating compliance with data governance policies (PASS, FAIL, WARNING) | Not null, valid flag |
| RETENTION_DATE | DATE | Date when the audit record should be archived or deleted based on retention policies | Calculated based on policies |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationship Block Diagram

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Bz_Users      │────────▶│   Bz_Meetings   │────────▶│ Bz_Participants │
│                 │         │                 │         │                 │
│ - USER_NAME     │         │ - MEETING_TOPIC │         │ - JOIN_TIME     │
│ - EMAIL         │         │ - START_TIME    │         │ - LEAVE_TIME    │
│ - COMPANY       │         │ - END_TIME      │         │ - PARTICIPATION │
│ - PLAN_TYPE     │         │ - DURATION_MIN  │         │   _DURATION     │
│ - DATA_CLASS    │         │ - DATA_CLASS    │         │ - DATA_CLASS    │
└─────────────────┘         └─────────────────┘         └─────────────────┘
         │                           │                           │
         │                           │                           │
         │                           │                           ▼
         │                           │                 ┌─────────────────┐
         │                           └────────────────▶│Bz_Feature_Usage │
         │                                             │                 │
         │                                             │ - FEATURE_NAME  │
         │                                             │ - USAGE_COUNT   │
         │                                             │ - USAGE_DATE    │
         │                                             │ - USAGE_DURATION│
         │                                             │ - DATA_CLASS    │
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
│ - OPEN_DATE     │ │ - CURRENCY      │
│ - CLOSE_DATE    │ │ - EVENT_DATE    │
│ - PRIORITY_LVL  │ │ - PAYMENT_METHOD│
│ - DATA_CLASS    │ │ - DATA_CLASS    │
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
         │         │ - LICENSE_STATUS│
         │         │ - ASSIGNED_USER │
         │         │ - DATA_CLASS    │
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
│ - PROCESSING_TIME│
│ - STATUS        │
│ - COMPLIANCE_FLAG│
│ - RETENTION_DATE│
└─────────────────┘
```

### 4.2 Table Relationships

| **Source Table** | **Target Table** | **Relationship Key Field** | **Relationship Type** | **Business Rule** |
|------------------|------------------|----------------------------|----------------------|-------------------|
| Bz_Users | Bz_Meetings | User Reference (HOST_ID) | One-to-Many | One user can host multiple meetings |
| Bz_Meetings | Bz_Participants | Meeting Reference (MEETING_ID) | One-to-Many | One meeting can have multiple participants |
| Bz_Meetings | Bz_Feature_Usage | Meeting Reference (MEETING_ID) | One-to-Many | Features can be used multiple times per meeting |
| Bz_Users | Bz_Support_Tickets | User Reference (USER_ID) | One-to-Many | One user can create multiple support tickets |
| Bz_Users | Bz_Billing_Events | User Reference (USER_ID) | One-to-Many | One user can have multiple billing events |
| Bz_Users | Bz_Licenses | User Reference (ASSIGNED_TO_USER_ID) | One-to-Many | One user can have multiple licenses |
| Bz_Users | Bz_Participants | User Reference (USER_ID) | One-to-Many | One user can participate in multiple meetings |
| All Tables | Bz_Audit_Log | Table Name Reference (SOURCE_TABLE) | Many-to-One | All tables generate audit records |

## 5. Data Quality Framework

### 5.1 Data Quality Dimensions

| **Dimension** | **Description** | **Measurement** | **Threshold** |
|---------------|-----------------|-----------------|---------------|
| **Completeness** | Percentage of non-null values in required fields | (Non-null records / Total records) × 100 | >= 95% |
| **Accuracy** | Percentage of records that conform to business rules | (Valid records / Total records) × 100 | >= 98% |
| **Consistency** | Percentage of records with consistent data formats | (Consistent records / Total records) × 100 | >= 99% |
| **Timeliness** | Percentage of records loaded within SLA timeframes | (On-time records / Total records) × 100 | >= 95% |
| **Validity** | Percentage of records that pass validation rules | (Valid records / Total records) × 100 | >= 97% |
| **Uniqueness** | Percentage of unique records where uniqueness is required | (Unique records / Total records) × 100 | >= 99% |

### 5.2 Data Quality Monitoring

1. **Automated Quality Checks**: Implemented during data ingestion process
2. **Quality Scorecards**: Daily quality reports for each table
3. **Anomaly Detection**: Statistical analysis to identify data anomalies
4. **Trend Analysis**: Historical quality trend monitoring
5. **Alert System**: Automated alerts when quality thresholds are breached

## 6. Security and Compliance Framework

### 6.1 Data Classification Levels

| **Classification** | **Description** | **Access Control** | **Encryption** |
|-------------------|-----------------|-------------------|----------------|
| **PUBLIC** | Non-sensitive data | Open access | Optional |
| **INTERNAL** | Internal business data | Employee access only | At rest |
| **CONFIDENTIAL** | Sensitive business/personal data | Role-based access | At rest and in transit |
| **RESTRICTED** | Highly sensitive data | Authorized personnel only | End-to-end encryption |

### 6.2 Compliance Requirements

1. **GDPR Compliance**: Right to be forgotten, data portability, consent management
2. **CCPA Compliance**: Consumer rights, data deletion, opt-out mechanisms
3. **SOX Compliance**: Financial data integrity, audit trails, access controls
4. **HIPAA Compliance**: Healthcare data protection (if applicable)
5. **Data Retention**: Automated retention policy enforcement

## 7. Design Rationale and Assumptions

### 7.1 Key Design Decisions

1. **Enhanced Table Naming Convention**: All Bronze layer tables use the "Bz_" prefix to clearly identify them as Bronze layer entities and maintain consistency across the medallion architecture.

2. **Complete Source Coverage**: All tables from the source schema are represented in the Bronze layer to ensure no data loss and complete data lineage tracking.

3. **Primary and Foreign Key Exclusion**: As per Bronze layer principles, primary and foreign key fields have been removed to maintain the raw data structure while adding necessary metadata columns.

4. **Enhanced Metadata Columns**: Standard metadata columns plus data classification for comprehensive governance.

5. **Data Quality Integration**: Built-in data quality rules and monitoring capabilities.

6. **Security by Design**: Data classification and security controls embedded in the model.

7. **Compliance Ready**: Built-in compliance features for major privacy regulations.

### 7.2 Assumptions Made

1. **Source System Reliability**: Source systems provide consistent data formats with proper error handling.

2. **High-Volume Processing**: The model supports high-volume data ingestion with scalable architecture.

3. **Regulatory Compliance**: PII data requires additional security measures and access controls.

4. **Comprehensive Auditing**: Detailed audit logging is required for compliance and monitoring.

5. **Data Quality Monitoring**: Automated data quality monitoring and alerting systems will be implemented.

6. **Security Controls**: Role-based access controls and encryption will be implemented based on data classification.

### 7.3 Version 4 Enhancements

1. **Data Retention Policies**: Added retention policies for each PII field based on regulatory requirements
2. **Enhanced Security Classifications**: Added DATA_CLASSIFICATION column to all tables for security governance
3. **Improved Audit Capabilities**: Enhanced audit table with operation types, compliance flags, and retention dates
4. **Data Quality Framework**: Comprehensive data quality rules and monitoring framework
5. **Compliance Features**: Built-in compliance features for GDPR, CCPA, SOX, and other regulations
6. **Enhanced Field Definitions**: Added calculated fields and improved data type specifications
7. **Security by Design**: Embedded security controls and access management features
8. **Automated Governance**: Built-in governance features for policy enforcement and monitoring

## 8. Implementation Recommendations

### 8.1 Technical Implementation

1. **Data Pipeline**: Implement CDC (Change Data Capture) for real-time data synchronization
2. **Storage Optimization**: Use columnar storage formats for better query performance
3. **Partitioning Strategy**: Implement date-based partitioning for large tables
4. **Indexing**: Create appropriate indexes based on query patterns
5. **Compression**: Use data compression to optimize storage costs

### 8.2 Operational Implementation

1. **Monitoring**: Implement comprehensive monitoring and alerting
2. **Backup and Recovery**: Establish robust backup and disaster recovery procedures
3. **Performance Tuning**: Regular performance monitoring and optimization
4. **Capacity Planning**: Proactive capacity planning based on growth projections
5. **Documentation**: Maintain comprehensive technical and business documentation

### 8.3 Governance Implementation

1. **Data Stewardship**: Assign data stewards for each domain
2. **Policy Enforcement**: Implement automated policy enforcement mechanisms
3. **Training**: Provide training on data governance and compliance requirements
4. **Regular Audits**: Conduct regular compliance and security audits
5. **Continuous Improvement**: Establish processes for continuous improvement of data quality and governance