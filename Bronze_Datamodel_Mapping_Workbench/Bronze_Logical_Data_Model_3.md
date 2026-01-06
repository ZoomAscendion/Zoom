_____________________________________________
## *Author*: AAVA
## *Created on*: 2026-01-06
## *Description*: Bronze Layer Logical Data Model for Medallion Architecture - Enhanced Version
## *Version*: 3
## *Updated on*: 2026-01-06
## *Changes*: Added missing REGISTRATION_DATE field, enhanced PII classification, improved data type consistency, and aligned field names with source schema
## *Reason*: Updated to ensure complete alignment with source schema structure and conceptual model requirements
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Identified PII Fields

| Table Name | Column Name | PII Classification | Reason |
|------------|-------------|-------------------|--------|
| Bz_Users | USER_NAME | PII | Contains personal identifiable name information that can directly identify an individual person and is considered direct personal identifier under GDPR |
| Bz_Users | EMAIL | PII | Email addresses are direct personal identifiers that can be used to contact and uniquely identify individuals, classified as personal data under privacy regulations |
| Bz_Users | COMPANY | Sensitive | Company affiliation can be used to identify individuals in combination with other data elements and may reveal business relationships |
| Bz_Meetings | MEETING_TOPIC | Sensitive | Meeting topics may contain confidential business information, personal discussions, proprietary content, or sensitive organizational matters |
| Bz_Support_Tickets | TICKET_TYPE | Sensitive | Support ticket types may reveal personal issues, business-sensitive problems, system vulnerabilities, or operational challenges |
| Bz_Billing_Events | AMOUNT | Sensitive | Financial information that reveals spending patterns, financial status, business transaction details, and economic behavior |
| Bz_Participants | JOIN_TIME | Sensitive | Participation timing can reveal personal schedules, behavioral patterns, and attendance habits that could be used for profiling |
| Bz_Participants | LEAVE_TIME | Sensitive | Participation timing can reveal personal schedules, behavioral patterns, and engagement levels that could be used for behavioral analysis |
| Bz_Feature_Usage | FEATURE_NAME | Sensitive | Feature usage patterns can reveal user behavior, preferences, and business processes that may be commercially sensitive |
| Bz_Feature_Usage | USAGE_COUNT | Sensitive | Usage frequency data can reveal user engagement patterns and business activity levels |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Stores raw user account data from source systems with complete user profile information and subscription details

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| USER_NAME | Display name of the user for identification and communication purposes | VARCHAR(16777216) |
| EMAIL | Email address of the user for communication, login, and unique identification | VARCHAR(16777216) |
| COMPANY | Company or organization the user belongs to for business context | VARCHAR(16777216) |
| PLAN_TYPE | Type of subscription plan the user has (Free, Basic, Pro, Enterprise) | VARCHAR(16777216) |
| REGISTRATION_DATE | Date when the user first signed up for the platform | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the user data originated | VARCHAR(16777216) |

### 2.2 Bz_Meetings
**Description**: Contains raw meeting data from source systems including scheduling, duration, and host information

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| MEETING_TYPE | Category of meeting (Scheduled, Instant, Webinar, etc.) | VARCHAR(16777216) |
| MEETING_TOPIC | Subject or topic of the meeting for identification | VARCHAR(16777216) |
| START_TIME | Timestamp when the meeting started | TIMESTAMP_NTZ(9) |
| END_TIME | Timestamp when the meeting ended | TIMESTAMP_NTZ(9) |
| DURATION_MINUTES | Duration of the meeting in minutes | NUMBER(38,0) |
| HOST_NAME | Name of the user who organized and hosted the meeting | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the meeting data originated | VARCHAR(16777216) |

### 2.3 Bz_Participants
**Description**: Stores raw participant data for meetings from source systems tracking attendance and engagement

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| PARTICIPANT_NAME | Name of the meeting attendee for identification | VARCHAR(16777216) |
| JOIN_TIME | Timestamp when participant joined the meeting | TIMESTAMP_NTZ(9) |
| LEAVE_TIME | Timestamp when participant left the meeting | TIMESTAMP_NTZ(9) |
| CONNECTION_QUALITY | Quality of the participant's connection during the meeting | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the participant data originated | VARCHAR(16777216) |

### 2.4 Bz_Feature_Usage
**Description**: Captures raw feature usage data from source systems for analytics and usage tracking

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| FEATURE_NAME | Name of the specific feature used (Screen Share, Recording, Chat, etc.) | VARCHAR(16777216) |
| USAGE_COUNT | Number of times the feature was utilized during the session | NUMBER(38,0) |
| USAGE_DURATION | Total time the feature was active during the meeting | NUMBER(38,0) |
| USAGE_TIMESTAMP | When the feature was first activated | TIMESTAMP_NTZ(9) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the feature usage data originated | VARCHAR(16777216) |

### 2.5 Bz_Support_Tickets
**Description**: Contains raw support ticket data from source systems for customer service tracking and resolution management

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| TICKET_TYPE | Category of the support issue (Technical, Billing, Feature Request, etc.) | VARCHAR(16777216) |
| RESOLUTION_STATUS | Current state of the ticket (Open, In Progress, Resolved, Closed) | VARCHAR(16777216) |
| OPEN_DATE | Date when the support ticket was created | DATE |
| CLOSE_DATE | Date when the ticket was resolved and closed | DATE |
| PRIORITY_LEVEL | Urgency level of the support request | VARCHAR(16777216) |
| DESCRIPTION | Detailed explanation of the issue or request | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the support ticket data originated | VARCHAR(16777216) |

### 2.6 Bz_Billing_Events
**Description**: Stores raw billing event data from source systems for financial tracking and revenue analysis

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| EVENT_TYPE | Type of billing transaction (Subscription, Upgrade, Refund, etc.) | VARCHAR(16777216) |
| AMOUNT | Monetary value of the transaction | NUMBER(38,2) |
| TRANSACTION_DATE | Date when the billing event occurred | DATE |
| PAYMENT_METHOD | Method used for payment (Credit Card, PayPal, etc.) | VARCHAR(16777216) |
| CURRENCY | Currency type for the transaction amount | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the billing data originated | VARCHAR(16777216) |

### 2.7 Bz_Licenses
**Description**: Stores raw license information from source systems for entitlement management and usage tracking

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| LICENSE_TYPE | Category of license (Basic, Pro, Enterprise, Add-on) | VARCHAR(16777216) |
| START_DATE | Date when the license becomes active | DATE |
| END_DATE | Date when the license expires | DATE |
| LICENSE_STATUS | Current state of the license (Active, Expired, Suspended) | VARCHAR(16777216) |
| ASSIGNED_USER_NAME | Name of the user to whom the license is assigned | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the license data originated | VARCHAR(16777216) |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Tracks data processing activities across all Bronze layer tables for compliance, monitoring, and operational oversight

| Field Name | Description | Data Type |
|------------|-------------|----------|
| RECORD_ID | Unique identifier for each audit record | VARCHAR(16777216) |
| SOURCE_TABLE | Name of the source table being processed | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when the data processing occurred | TIMESTAMP_NTZ(9) |
| PROCESSED_BY | System or process that handled the data | VARCHAR(16777216) |
| PROCESSING_TIME | Duration taken to process the data in milliseconds | NUMBER(38,0) |
| STATUS | Status of the processing operation (SUCCESS, FAILED, PARTIAL) | VARCHAR(16777216) |
| RECORDS_PROCESSED | Number of records processed in the operation | NUMBER(38,0) |
| ERROR_MESSAGE | Details of any errors encountered during processing | VARCHAR(16777216) |

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
│ - REGISTRATION_ │
│   DATE          │
└─────────────────┘
         │
         │ (Connected via USER_NAME reference)
         │
         ▼
┌─────────────────┐       ┌─────────────────┐
│ Bz_Billing_     │       │   Bz_Meetings   │
│ Events          │       │                 │
│                 │       │ - MEETING_TYPE  │
│ - EVENT_TYPE    │       │ - MEETING_TOPIC │
│ - AMOUNT        │       │ - START_TIME    │
│ - TRANSACTION_  │       │ - END_TIME      │
│   DATE          │       │ - DURATION_MIN  │
│ - PAYMENT_      │       │ - HOST_NAME     │
│   METHOD        │       └─────────────────┘
│ - CURRENCY      │                │
└─────────────────┘                │
         │                         │ (Connected via MEETING reference)
         │                         │
         │                         ▼
         │                ┌─────────────────┐
         │                │ Bz_Participants │
         │                │                 │
         │                │ - PARTICIPANT_  │
         │                │   NAME          │
         │                │ - JOIN_TIME     │
         │                │ - LEAVE_TIME    │
         │                │ - CONNECTION_   │
         │                │   QUALITY       │
         │                └─────────────────┘
         │                         │
         │                         │
         │ (Connected via USER_NAME reference)
         │                         │
         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐
│ Bz_Support_     │       │ Bz_Feature_     │
│ Tickets         │       │ Usage           │
│                 │       │                 │
│ - TICKET_TYPE   │       │ - FEATURE_NAME  │
│ - RESOLUTION_   │       │ - USAGE_COUNT   │
│   STATUS        │       │ - USAGE_        │
│ - OPEN_DATE     │       │   DURATION      │
│ - CLOSE_DATE    │       │ - USAGE_        │
│ - PRIORITY_     │       │   TIMESTAMP     │
│   LEVEL         │       └─────────────────┘
│ - DESCRIPTION   │                │
└─────────────────┘                │
         │                         │
         │                         │ (Connected via MEETING reference)
         │                         │
         │                         ▼
         │                ┌─────────────────┐
         │                │ Bz_Licenses     │
         │                │                 │
         │                │ - LICENSE_TYPE  │
         │                │ - START_DATE    │
         │                │ - END_DATE      │
         │                │ - LICENSE_      │
         │                │   STATUS        │
         │                │ - ASSIGNED_     │
         │                │   USER_NAME     │
         │                └─────────────────┘
         │                         │
         │                         │
         │ (Connected via USER_NAME reference)
         │                         │
         ▼                         ▼
┌─────────────────┐
│ Bz_Audit_Log    │
│                 │
│ - RECORD_ID     │
│ - SOURCE_TABLE  │
│ - LOAD_TIMESTAMP│
│ - PROCESSED_BY  │
│ - PROCESSING_   │
│   TIME          │
│ - STATUS        │
│ - RECORDS_      │
│   PROCESSED     │
│ - ERROR_MESSAGE │
└─────────────────┘
```

### 4.2 Key Relationships

1. **Bz_Users** connects to:
   - **Bz_Billing_Events** via USER_NAME reference field
   - **Bz_Support_Tickets** via USER_NAME reference field
   - **Bz_Licenses** via ASSIGNED_USER_NAME field
   - **Bz_Meetings** via HOST_NAME field
   - **Bz_Participants** via PARTICIPANT_NAME field

2. **Bz_Meetings** connects to:
   - **Bz_Participants** via MEETING reference field
   - **Bz_Feature_Usage** via MEETING reference field

3. **Bz_Audit_Log** tracks all tables via SOURCE_TABLE field

4. **Cross-Entity Relationships**:
   - Users can have multiple billing events, support tickets, licenses, and meetings
   - Meetings can have multiple participants and feature usage records
   - All entities are tracked through the audit log for compliance

## 5. Design Decisions and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for consistent identification and easy recognition across the data platform
2. **Data Preservation**: All source data fields preserved except primary/foreign key fields as per Bronze layer requirements
3. **Enhanced Metadata**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) included for comprehensive data lineage and governance
4. **Comprehensive PII Classification**: Enhanced classification based on GDPR, CCPA, and common data privacy standards with detailed reasoning for each field
5. **Improved Audit Trail**: Enhanced audit table design with additional fields for better tracking and error handling
6. **Data Type Optimization**: Improved data types for better performance and accuracy (e.g., NUMBER for amounts and durations)
7. **Complete Field Coverage**: Added missing fields from conceptual model to ensure complete data representation

### 5.2 Assumptions Made

1. **Multi-Source Integration**: Multiple source systems will feed into Bronze layer requiring comprehensive source tracking
2. **High-Volume Processing**: Designed for high-volume data processing with appropriate data types and structures
3. **Hybrid Processing**: Support for both batch and real-time data ingestion patterns
4. **Regulatory Compliance**: GDPR, CCPA, and similar data privacy regulations apply requiring detailed PII classification
5. **Cloud-Native Scalability**: Designed for horizontal scaling in cloud environments with Snowflake optimization
6. **Data Quality Variability**: Source data quality issues will be addressed in Silver layer, Bronze maintains raw fidelity
7. **Operational Monitoring**: Comprehensive audit and monitoring capabilities required for production operations

### 5.3 Rationale

1. **Bronze Layer Purpose**: Maintains complete raw data fidelity while adding essential metadata for downstream processing and governance
2. **Relationship Flexibility**: Logical relationships maintained through reference fields rather than formal foreign keys for maximum flexibility
3. **Schema Evolution**: Design allows for easy extension and modification as business requirements and source systems evolve
4. **Data Governance Excellence**: Enhanced PII classification and audit capabilities support comprehensive compliance and governance requirements
5. **Performance Optimization**: Structure optimized for Snowflake's columnar storage and processing capabilities
6. **Operational Excellence**: Comprehensive audit logging and error handling enable monitoring of data pipeline health and performance
7. **Business Alignment**: Complete field coverage ensures all business requirements from conceptual model are supported

### 5.4 Data Lineage and Governance

1. **Source Tracking**: SOURCE_SYSTEM field enables comprehensive tracking of data origin across multiple source systems
2. **Temporal Lineage**: LOAD_TIMESTAMP and UPDATE_TIMESTAMP provide complete temporal lineage for all data changes
3. **Processing Audit**: Enhanced Bz_Audit_Log table provides comprehensive processing audit trail with error handling
4. **PII Governance**: Detailed PII classification supports data privacy compliance and governance policies
5. **Change Management**: Version control and change tracking built into the model structure for operational excellence
6. **Quality Monitoring**: Audit fields enable monitoring of data quality and processing performance
7. **Compliance Reporting**: Structure supports automated compliance reporting and data governance dashboards

### 5.5 Performance and Scalability Considerations

1. **Columnar Optimization**: Table structure optimized for Snowflake's columnar storage format
2. **Partitioning Strategy**: Date fields positioned for effective partitioning strategies
3. **Compression Efficiency**: Data types selected for optimal compression in cloud storage
4. **Query Performance**: Field organization supports efficient analytical query patterns
5. **Scalability Design**: Structure supports horizontal scaling as data volumes grow
6. **Resource Optimization**: Designed to minimize compute and storage costs while maintaining performance