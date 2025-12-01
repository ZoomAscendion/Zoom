_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Enhanced Bronze Layer Logical Data Model for Medallion Architecture with improved data lineage and governance
## *Version*: 3
## *Updated on*: 2024-12-19
## *Changes*: Added data lineage tracking, enhanced security classifications, improved audit capabilities, and standardized data types
## *Reason*: Strengthening data governance, security compliance, and operational monitoring for enterprise-grade data platform
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Identified PII Fields

| Table Name | Column Name | PII Classification | Reason | Security Level |
|------------|-------------|-------------------|--------|----------------|
| Bz_Users | USER_NAME | PII | Contains personal identifiable name information that can identify an individual | HIGH |
| Bz_Users | EMAIL | PII | Email addresses are direct personal identifiers that can be used to contact and identify individuals | HIGH |
| Bz_Users | COMPANY | Sensitive | Company affiliation can be used to identify individuals in combination with other data | MEDIUM |
| Bz_Users | PLAN_TYPE | Sensitive | Subscription information reveals business relationships and financial capacity | MEDIUM |
| Bz_Meetings | MEETING_TOPIC | Sensitive | Meeting topics may contain confidential business information or personal discussions | MEDIUM |
| Bz_Support_Tickets | TICKET_TYPE | Sensitive | Support ticket types may reveal personal issues or business-sensitive problems | MEDIUM |
| Bz_Billing_Events | AMOUNT | PII | Financial information that reveals spending patterns and financial status - classified as PII for enhanced protection | HIGH |
| Bz_Billing_Events | EVENT_TYPE | Sensitive | Billing event types can reveal business patterns and financial behavior | MEDIUM |
| Bz_Participants | JOIN_TIME | Sensitive | Participation timing can reveal personal schedules and behavior patterns | LOW |
| Bz_Participants | LEAVE_TIME | Sensitive | Participation timing can reveal personal schedules and behavior patterns | LOW |
| Bz_Feature_Usage | FEATURE_NAME | Sensitive | Feature usage patterns can reveal business processes and user behavior | LOW |
| Bz_Licenses | LICENSE_TYPE | Sensitive | License information reveals organizational capabilities and spending | MEDIUM |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Billing_Events
**Description**: Stores raw billing event data from source systems without transformation, maintaining complete audit trail for financial transactions

| Column Name | Description | Data Type | Business Rules |
|-------------|-------------|-----------|----------------|
| EVENT_TYPE | Type of billing event that occurred | VARCHAR(100) | Required, standardized values |
| AMOUNT | Monetary amount associated with the billing event | DECIMAL(15,2) | Required, positive values only |
| EVENT_DATE | Date when the billing event occurred | DATE | Required, cannot be future date |
| CURRENCY_CODE | ISO currency code for the transaction | VARCHAR(3) | Required, ISO 4217 standard |
| DATA_QUALITY_FLAG | Flag indicating data quality status | VARCHAR(20) | VALID, INVALID, SUSPECT, PENDING |
| DATA_LINEAGE_ID | Unique identifier for tracking data lineage | VARCHAR(50) | Required for audit trail |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | System generated |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | System generated |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(50) | Required, standardized values |
| BATCH_ID | Identifier for the data processing batch | VARCHAR(50) | Required for batch tracking |

### 2.2 Bz_Feature_Usage
**Description**: Captures raw feature usage data from source systems for analytics and product optimization

| Column Name | Description | Data Type | Business Rules |
|-------------|-------------|-----------|----------------|
| FEATURE_NAME | Name of the feature that was used | VARCHAR(100) | Required, standardized feature catalog |
| USAGE_COUNT | Number of times the feature was used | NUMBER(10,0) | Required, non-negative values |
| USAGE_DATE | Date when the feature usage occurred | DATE | Required, cannot be future date |
| SESSION_DURATION | Duration of feature usage session in seconds | NUMBER(10,0) | Optional, positive values only |
| DATA_QUALITY_FLAG | Flag indicating data quality status | VARCHAR(20) | VALID, INVALID, SUSPECT, PENDING |
| DATA_LINEAGE_ID | Unique identifier for tracking data lineage | VARCHAR(50) | Required for audit trail |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | System generated |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | System generated |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(50) | Required, standardized values |
| BATCH_ID | Identifier for the data processing batch | VARCHAR(50) | Required for batch tracking |

### 2.3 Bz_Licenses
**Description**: Stores raw license information from source systems for compliance and usage tracking

| Column Name | Description | Data Type | Business Rules |
|-------------|-------------|-----------|----------------|
| LICENSE_TYPE | Type or category of the license | VARCHAR(100) | Required, standardized license catalog |
| ASSIGNED_TO_USER | User to whom the license is assigned | VARCHAR(100) | Required, valid user reference |
| START_DATE | Date when the license becomes active | DATE | Required, cannot be future date |
| END_DATE | Date when the license expires | DATE | Optional, must be after start_date |
| LICENSE_STATUS | Current status of the license | VARCHAR(20) | ACTIVE, INACTIVE, EXPIRED, SUSPENDED |
| DATA_QUALITY_FLAG | Flag indicating data quality status | VARCHAR(20) | VALID, INVALID, SUSPECT, PENDING |
| DATA_LINEAGE_ID | Unique identifier for tracking data lineage | VARCHAR(50) | Required for audit trail |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | System generated |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | System generated |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(50) | Required, standardized values |
| BATCH_ID | Identifier for the data processing batch | VARCHAR(50) | Required for batch tracking |

### 2.4 Bz_Meetings
**Description**: Contains raw meeting data from source systems for analytics and platform optimization

| Column Name | Description | Data Type | Business Rules |
|-------------|-------------|-----------|----------------|
| HOST | Identifier of the user hosting the meeting | VARCHAR(100) | Required, valid user reference |
| MEETING_TOPIC | Subject or topic of the meeting | VARCHAR(500) | Optional, encrypted if sensitive |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) | Required, cannot be future timestamp |
| END_TIME | Timestamp when the meeting ended | TIMESTAMP_NTZ(9) | Optional, must be after start_time |
| DURATION_MINUTES | Duration of the meeting in minutes | NUMBER(8,0) | Calculated field, positive values |
| MEETING_TYPE | Type of meeting (scheduled, instant, recurring) | VARCHAR(50) | Required, standardized values |
| DATA_QUALITY_FLAG | Flag indicating data quality status | VARCHAR(20) | VALID, INVALID, SUSPECT, PENDING |
| DATA_LINEAGE_ID | Unique identifier for tracking data lineage | VARCHAR(50) | Required for audit trail |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | System generated |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | System generated |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(50) | Required, standardized values |
| BATCH_ID | Identifier for the data processing batch | VARCHAR(50) | Required for batch tracking |

### 2.5 Bz_Participants
**Description**: Stores raw participant data for meetings from source systems for engagement analytics

| Column Name | Description | Data Type | Business Rules |
|-------------|-------------|-----------|----------------|
| PARTICIPANT | Identifier of the participating user | VARCHAR(100) | Required, valid user reference |
| JOIN_TIME | Time when participant joined the meeting | TIMESTAMP_NTZ(9) | Required, within meeting timeframe |
| LEAVE_TIME | Time when participant left the meeting | TIMESTAMP_NTZ(9) | Optional, must be after join_time |
| PARTICIPATION_DURATION | Duration of participation in minutes | NUMBER(8,0) | Calculated field, positive values |
| CONNECTION_TYPE | Type of connection (audio, video, screen_share) | VARCHAR(50) | Required, standardized values |
| DATA_QUALITY_FLAG | Flag indicating data quality status | VARCHAR(20) | VALID, INVALID, SUSPECT, PENDING |
| DATA_LINEAGE_ID | Unique identifier for tracking data lineage | VARCHAR(50) | Required for audit trail |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | System generated |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | System generated |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(50) | Required, standardized values |
| BATCH_ID | Identifier for the data processing batch | VARCHAR(50) | Required for batch tracking |

### 2.6 Bz_Support_Tickets
**Description**: Contains raw support ticket data from source systems for customer service analytics

| Column Name | Description | Data Type | Business Rules |
|-------------|-------------|-----------|----------------|
| TICKET_TYPE | Category or type of the support ticket | VARCHAR(100) | Required, standardized ticket taxonomy |
| RESOLUTION_STATUS | Current status of the ticket resolution | VARCHAR(50) | Required, standardized status values |
| OPEN_DATE | Date when the support ticket was opened | DATE | Required, cannot be future date |
| PRIORITY_LEVEL | Priority level of the support ticket | VARCHAR(20) | LOW, MEDIUM, HIGH, CRITICAL |
| CATEGORY | Primary category of the support request | VARCHAR(100) | Required, standardized categories |
| SUB_CATEGORY | Detailed sub-category of the support request | VARCHAR(100) | Optional, standardized sub-categories |
| DATA_QUALITY_FLAG | Flag indicating data quality status | VARCHAR(20) | VALID, INVALID, SUSPECT, PENDING |
| DATA_LINEAGE_ID | Unique identifier for tracking data lineage | VARCHAR(50) | Required for audit trail |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | System generated |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | System generated |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(50) | Required, standardized values |
| BATCH_ID | Identifier for the data processing batch | VARCHAR(50) | Required for batch tracking |

### 2.7 Bz_Users
**Description**: Stores raw user account data from source systems with enhanced security and privacy controls

| Column Name | Description | Data Type | Business Rules |
|-------------|-------------|-----------|----------------|
| USER_NAME | Display name of the user | VARCHAR(200) | Required, encrypted for privacy |
| EMAIL | Email address of the user | VARCHAR(320) | Required, encrypted, valid email format |
| COMPANY | Company or organization the user belongs to | VARCHAR(200) | Optional, standardized company registry |
| PLAN_TYPE | Type of subscription plan the user has | VARCHAR(50) | Required, standardized plan catalog |
| ACCOUNT_STATUS | Current status of the user account | VARCHAR(20) | ACTIVE, INACTIVE, SUSPENDED, DELETED |
| REGISTRATION_DATE | Date when user account was created | DATE | Required, historical tracking |
| DATA_QUALITY_FLAG | Flag indicating data quality status | VARCHAR(20) | VALID, INVALID, SUSPECT, PENDING |
| DATA_LINEAGE_ID | Unique identifier for tracking data lineage | VARCHAR(50) | Required for audit trail |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the system | TIMESTAMP_NTZ(9) | System generated |
| UPDATE_TIMESTAMP | Timestamp when record was last updated | TIMESTAMP_NTZ(9) | System generated |
| SOURCE_SYSTEM | Source system from which the data originated | VARCHAR(50) | Required, standardized values |
| BATCH_ID | Identifier for the data processing batch | VARCHAR(50) | Required for batch tracking |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit table to track all data processing activities across Bronze layer tables with enhanced monitoring capabilities

| Field Name | Description | Data Type | Business Rules |
|------------|-------------|-----------|----------------|
| RECORD_ID | Unique identifier for each audit record | VARCHAR(50) | Required, UUID format |
| SOURCE_TABLE | Name of the source table being processed | VARCHAR(100) | Required, standardized table names |
| OPERATION_TYPE | Type of operation performed | VARCHAR(20) | INSERT, UPDATE, DELETE, MERGE |
| LOAD_TIMESTAMP | Timestamp when the data processing occurred | TIMESTAMP_NTZ(9) | Required, system generated |
| PROCESSED_BY | System or process that handled the data | VARCHAR(100) | Required, standardized process names |
| PROCESSING_TIME | Duration taken to process the data in milliseconds | NUMBER(15,0) | Required, performance monitoring |
| STATUS | Status of the processing operation | VARCHAR(20) | SUCCESS, FAILED, PARTIAL, WARNING |
| RECORDS_PROCESSED | Number of records processed in the operation | NUMBER(15,0) | Required, volume tracking |
| RECORDS_FAILED | Number of records that failed processing | NUMBER(15,0) | Required, error tracking |
| ERROR_MESSAGE | Detailed error message if processing failed | VARCHAR(4000) | Optional, troubleshooting support |
| ERROR_CODE | Standardized error code for categorization | VARCHAR(20) | Optional, error classification |
| DATA_QUALITY_SCORE | Overall data quality score for the batch (0-100) | NUMBER(5,2) | Required, quality monitoring |
| BATCH_ID | Identifier for the data processing batch | VARCHAR(50) | Required, batch correlation |
| SOURCE_SYSTEM | Source system that provided the data | VARCHAR(50) | Required, lineage tracking |
| DATA_LINEAGE_ID | Unique identifier for end-to-end data lineage | VARCHAR(50) | Required, lineage correlation |
| COMPLIANCE_FLAG | Flag indicating compliance validation status | VARCHAR(20) | COMPLIANT, NON_COMPLIANT, PENDING |
| RETENTION_DATE | Date when the audit record should be archived | DATE | Required, data retention policy |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationships (Block Diagram Format)

```
┌─────────────────┐
│   Bz_Users      │
│                 │
│ - USER_NAME     │
│ - EMAIL         │
│ - COMPANY       │
│ - PLAN_TYPE     │
│ - ACCOUNT_STATUS│
│ - REG_DATE      │
│ - DATA_QUALITY_ │
│   FLAG          │
│ - DATA_LINEAGE_ │
│   ID            │
└─────────────────┘
         │
         │ (Connected via USER reference)
         │
         ▼
┌─────────────────┐       ┌─────────────────┐
│ Bz_Billing_     │       │   Bz_Meetings   │
│ Events          │       │                 │
│                 │       │ - HOST          │
│ - EVENT_TYPE    │       │ - MEETING_TOPIC │
│ - AMOUNT        │       │ - START_TIME    │
│ - EVENT_DATE    │       │ - END_TIME      │
│ - CURRENCY_CODE │       │ - DURATION_MIN  │
│ - DATA_QUALITY_ │       │ - MEETING_TYPE  │
│   FLAG          │       │ - DATA_QUALITY_ │
│ - DATA_LINEAGE_ │       │   FLAG          │
│   ID            │       │ - DATA_LINEAGE_ │
└─────────────────┘       │   ID            │
                          └─────────────────┘
                                   │
                                   │ (Connected via MEETING reference)
                                   │
                                   ▼
┌─────────────────┐       ┌─────────────────┐
│ Bz_Support_     │       │ Bz_Participants │
│ Tickets         │       │                 │
│                 │       │ - PARTICIPANT   │
│ - TICKET_TYPE   │       │ - JOIN_TIME     │
│ - RESOLUTION_   │       │ - LEAVE_TIME    │
│   STATUS        │       │ - PARTICIPATION_│
│ - OPEN_DATE     │       │   DURATION      │
│ - PRIORITY_LEVEL│       │ - CONNECTION_   │
│ - CATEGORY      │       │   TYPE          │
│ - SUB_CATEGORY  │       │ - DATA_QUALITY_ │
│ - DATA_QUALITY_ │       │   FLAG          │
│   FLAG          │       │ - DATA_LINEAGE_ │
│ - DATA_LINEAGE_ │       │   ID            │
│   ID            │       └─────────────────┘
└─────────────────┘                │
         │                         │
         │ (Connected via USER reference)
         │                         │
         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐
│ Bz_Licenses     │       │ Bz_Feature_     │
│                 │       │ Usage           │
│ - LICENSE_TYPE  │       │                 │
│ - ASSIGNED_TO_  │       │ - FEATURE_NAME  │
│   USER          │       │ - USAGE_COUNT   │
│ - START_DATE    │       │ - USAGE_DATE    │
│ - END_DATE      │       │ - SESSION_      │
│ - LICENSE_      │       │   DURATION      │
│   STATUS        │       │ - DATA_QUALITY_ │
│ - DATA_QUALITY_ │       │   FLAG          │
│   FLAG          │       │ - DATA_LINEAGE_ │
│ - DATA_LINEAGE_ │       │   ID            │
│   ID            │       └─────────────────┘
└─────────────────┘
         │
         │
         ▼
┌─────────────────┐
│ Bz_Audit_Log    │
│                 │
│ - RECORD_ID     │
│ - SOURCE_TABLE  │
│ - OPERATION_TYPE│
│ - LOAD_TIMESTAMP│
│ - PROCESSED_BY  │
│ - PROCESSING_   │
│   TIME          │
│ - STATUS        │
│ - RECORDS_      │
│   PROCESSED     │
│ - RECORDS_FAILED│
│ - ERROR_MESSAGE │
│ - ERROR_CODE    │
│ - DATA_QUALITY_ │
│   SCORE         │
│ - BATCH_ID      │
│ - SOURCE_SYSTEM │
│ - DATA_LINEAGE_ │
│   ID            │
│ - COMPLIANCE_   │
│   FLAG          │
│ - RETENTION_DATE│
└─────────────────┘
```

### 4.2 Key Relationships

1. **Bz_Users** connects to:
   - **Bz_Billing_Events** via USER reference field (One-to-Many)
   - **Bz_Support_Tickets** via USER reference field (One-to-Many)
   - **Bz_Licenses** via ASSIGNED_TO_USER field (One-to-Many)
   - **Bz_Meetings** via HOST field (One-to-Many)
   - **Bz_Participants** via PARTICIPANT field (One-to-Many)

2. **Bz_Meetings** connects to:
   - **Bz_Participants** via MEETING reference field (One-to-Many)
   - **Bz_Feature_Usage** via MEETING reference field (One-to-Many)

3. **Bz_Audit_Log** tracks all tables via SOURCE_TABLE field (Many-to-One)

4. **Data Lineage** connects all tables via DATA_LINEAGE_ID field for end-to-end tracking

## 5. Design Decisions and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for consistent identification and namespace management
2. **Data Preservation**: All source data fields preserved except primary/foreign key fields as per requirements
3. **Enhanced Metadata**: Comprehensive metadata columns including data lineage, batch tracking, and quality flags
4. **Security Classification**: Multi-level PII classification with security levels for appropriate access controls
5. **Standardized Data Types**: Optimized data types for performance and storage efficiency
6. **Business Rules**: Comprehensive validation rules for data integrity and consistency
7. **Audit Enhancement**: Enterprise-grade audit capabilities with compliance and retention management

### 5.2 Assumptions Made

1. **Multi-Source Integration**: Multiple heterogeneous source systems feeding into Bronze layer
2. **High-Volume Processing**: Designed for enterprise-scale data volumes with batch and streaming patterns
3. **Regulatory Compliance**: GDPR, SOX, and industry-specific compliance requirements
4. **Cloud-Native Architecture**: Optimized for cloud data platforms with horizontal scaling
5. **Real-Time Monitoring**: Continuous data quality and operational monitoring requirements
6. **Data Retention**: Long-term data retention with archival and purging capabilities
7. **Security Requirements**: Enterprise-grade security with encryption and access controls

### 5.3 Rationale

1. **Bronze Layer Philosophy**: Maintains complete data fidelity while adding essential operational metadata
2. **Relationship Management**: Logical relationships preserved through standardized reference fields
3. **Extensibility**: Flexible schema design supporting future business requirements and data sources
4. **Governance Integration**: Comprehensive data governance capabilities supporting enterprise policies
5. **Operational Excellence**: Enhanced monitoring, alerting, and troubleshooting capabilities
6. **Performance Optimization**: Balanced design for query performance and storage efficiency

### 5.4 Version 3 Enhancements

1. **Data Lineage Integration**: Added comprehensive data lineage tracking across all tables
2. **Enhanced Security**: Multi-level security classification with granular access controls
3. **Standardized Data Types**: Optimized data types for better performance and storage
4. **Business Rules**: Comprehensive validation rules and constraints
5. **Operational Monitoring**: Enhanced audit capabilities with compliance and retention management
6. **Quality Assurance**: Advanced data quality monitoring with scoring and alerting
7. **Batch Correlation**: Complete batch tracking for operational transparency
8. **Error Management**: Comprehensive error handling and classification system
9. **Compliance Framework**: Built-in compliance validation and reporting capabilities
10. **Performance Optimization**: Improved schema design for better query performance

### 5.5 Implementation Considerations

1. **Encryption**: PII fields should be encrypted at rest and in transit
2. **Access Controls**: Role-based access controls based on security classifications
3. **Data Masking**: Dynamic data masking for non-production environments
4. **Monitoring**: Real-time monitoring of data quality scores and processing metrics
5. **Alerting**: Automated alerting for data quality issues and processing failures
6. **Archival**: Automated archival processes based on retention policies
7. **Backup**: Regular backup and disaster recovery procedures
8. **Performance**: Regular performance tuning and optimization reviews