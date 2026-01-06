_____________________________________________
## *Author*: AAVA
## *Created on*: 2025-12-02
## *Description*: Bronze Layer Logical Data Model for Medallion Architecture
## *Version*: 4 
## *Updated on*: 2025-12-02
## *Changes*: Enhanced audit table with data quality tracking fields and improved column descriptions
## *Reason*: Updated as requested with Do_You_Need_Any_Changes = Yes to improve data governance and monitoring capabilities
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Identified PII Fields

| Table Name | Column Name | PII Classification | Reason |
|------------|-------------|-------------------|--------|
| Bz_Users | USER_NAME | PII | Contains personal identifiable name information that can identify an individual |
| Bz_Users | EMAIL | PII | Email addresses are direct personal identifiers that can be used to contact and identify individuals |
| Bz_Users | COMPANY | Sensitive | Company affiliation can be used to identify individuals in combination with other data |
| Bz_Meetings | MEETING_TOPIC | Sensitive | Meeting topics may contain confidential business information or personal discussions |
| Bz_Support_Tickets | TICKET_TYPE | Sensitive | Support ticket types may reveal personal issues or business-sensitive problems |
| Bz_Billing_Events | AMOUNT | Sensitive | Financial information that reveals spending patterns and financial status |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Billing_Events
**Description**: Stores raw billing event data from source systems without transformation, maintaining complete transaction history

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| EVENT_TYPE | Type of billing event that occurred (subscription, upgrade, refund, etc.) | VARCHAR(100) |
| AMOUNT | Monetary amount associated with the billing event in source currency | VARCHAR(100) |
| EVENT_DATE | Date when the billing event occurred in source system | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the Bronze layer | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated (billing system identifier) | VARCHAR(100) |

### 2.2 Bz_Feature_Usage
**Description**: Captures raw feature usage data from source systems, tracking platform feature adoption and utilization

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| FEATURE_NAME | Name of the feature that was used (screen share, recording, chat, etc.) | VARCHAR(100) |
| USAGE_COUNT | Number of times the feature was used during the session | NUMBER(38,0) |
| USAGE_DATE | Date when the feature usage occurred | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the Bronze layer | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated (platform system identifier) | VARCHAR(100) |

### 2.3 Bz_Licenses
**Description**: Stores raw license information from source systems, tracking license assignments and lifecycle

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| LICENSE_TYPE | Type or category of the license (basic, pro, enterprise, add-on) | VARCHAR(100) |
| ASSIGNED_TO_USER | User identifier to whom the license is assigned | VARCHAR(100) |
| START_DATE | Date when the license becomes active and usable | DATE |
| END_DATE | Date when the license expires or becomes inactive | VARCHAR(100) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the Bronze layer | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated (license management system) | VARCHAR(100) |

### 2.4 Bz_Meetings
**Description**: Contains raw meeting data from source systems, capturing all meeting activities and metadata

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| HOST | Identifier of the user hosting the meeting | VARCHAR(100) |
| MEETING_TOPIC | Subject or topic of the meeting as entered by host | VARCHAR(100) |
| START_TIME | Timestamp when the meeting started in source system timezone | TIMESTAMP_NTZ(9) |
| END_TIME | Timestamp when the meeting ended in source system timezone | VARCHAR(100) |
| DURATION_MINUTES | Duration of the meeting in minutes as calculated by source system | VARCHAR(100) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the Bronze layer | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated (meeting platform identifier) | VARCHAR(100) |

### 2.5 Bz_Participants
**Description**: Stores raw participant data for meetings from source systems, tracking attendance patterns

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| PARTICIPANT | Identifier of the participating user in the meeting | VARCHAR(100) |
| JOIN_TIME | Time when participant joined the meeting session | VARCHAR(100) |
| LEAVE_TIME | Time when participant left the meeting session | TIMESTAMP_NTZ(9) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the Bronze layer | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated (meeting platform identifier) | VARCHAR(100) |

### 2.6 Bz_Support_Tickets
**Description**: Contains raw support ticket data from source systems, maintaining complete support interaction history

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| TICKET_TYPE | Category or type of the support ticket (technical, billing, feature request) | VARCHAR(100) |
| RESOLUTION_STATUS | Current status of the ticket resolution (open, in progress, resolved, closed) | VARCHAR(100) |
| OPEN_DATE | Date when the support ticket was opened by user | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the Bronze layer | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated (support system identifier) | VARCHAR(100) |

### 2.7 Bz_Users
**Description**: Stores raw user account data from source systems, maintaining complete user profile information

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| USER_NAME | Display name of the user as registered in the system | VARCHAR(100) |
| EMAIL | Email address of the user for communication and authentication | VARCHAR(100) |
| COMPANY | Company or organization the user belongs to | VARCHAR(100) |
| PLAN_TYPE | Type of subscription plan the user has (free, basic, pro, enterprise) | VARCHAR(100) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the Bronze layer | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the data originated (user management system) | VARCHAR(100) |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Tracks data processing activities across all Bronze layer tables with enhanced monitoring capabilities

| Field Name | Description | Data Type |
|------------|-------------|----------|
| RECORD_ID | Unique identifier for each audit record | VARCHAR(100) |
| SOURCE_TABLE | Name of the source table being processed | VARCHAR(100) |
| LOAD_TIMESTAMP | Timestamp when the data processing occurred | TIMESTAMP_NTZ(9) |
| PROCESSED_BY | System or process that handled the data | VARCHAR(100) |
| PROCESSING_TIME | Duration taken to process the data in milliseconds | NUMBER(38,0) |
| STATUS | Status of the processing operation (SUCCESS, FAILED, PARTIAL) | VARCHAR(100) |
| RECORDS_PROCESSED | Number of records processed in the operation | NUMBER(38,0) |
| ERROR_MESSAGE | Error message if processing failed | VARCHAR(500) |
| DATA_QUALITY_SCORE | Quality score of the processed data (0-100) | NUMBER(3,0) |

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
└─────────────────┘       │ - DURATION_MIN  │
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
│   STATUS        │       └─────────────────┘
│ - OPEN_DATE     │                │
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
│ - END_DATE      │       └─────────────────┘
└─────────────────┘                │
                                   │
                                   │ (Connected via MEETING reference)
                                   │
                                   ▼
                          ┌─────────────────┐
                          │ Bz_Audit_Log    │
                          │                 │
                          │ - RECORD_ID     │
                          │ - SOURCE_TABLE  │
                          │ - LOAD_TIMESTAMP│
                          │ - PROCESSED_BY  │
                          │ - STATUS        │
                          └─────────────────┘
```

### 4.2 Key Relationships

1. **Bz_Users** connects to:
   - **Bz_Billing_Events** via USER reference field
   - **Bz_Support_Tickets** via USER reference field
   - **Bz_Licenses** via ASSIGNED_TO_USER field
   - **Bz_Meetings** via HOST field
   - **Bz_Participants** via PARTICIPANT field

2. **Bz_Meetings** connects to:
   - **Bz_Participants** via MEETING reference field
   - **Bz_Feature_Usage** via MEETING reference field

3. **Bz_Audit_Log** tracks all tables via SOURCE_TABLE field

## 5. Design Decisions and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for consistent identification
2. **Data Preservation**: All source data fields preserved except primary/foreign key fields as instructed
3. **Metadata Columns**: Standard metadata columns (LOAD_TIMESTAMP, UPDATE_TIMESTAMP, SOURCE_SYSTEM) included for data lineage
4. **PII Classification**: Implemented based on GDPR and common data privacy standards
5. **Audit Trail**: Enhanced audit table design for tracking all data processing activities with quality metrics
6. **Data Type Optimization**: VARCHAR fields sized at 100 characters for improved storage efficiency and performance
7. **Enhanced Monitoring**: Added data quality tracking and error handling capabilities

### 5.2 Assumptions Made

1. **Source System Integration**: Assumed multiple source systems will feed into Bronze layer
2. **Data Volume**: Designed for high-volume data processing with optimized data types
3. **Processing Patterns**: Assumed batch and real-time data ingestion patterns
4. **Compliance Requirements**: Assumed GDPR and similar data privacy regulations apply
5. **Scalability**: Designed for horizontal scaling in cloud environments
6. **Field Length Requirements**: Assumed 100 characters is sufficient for VARCHAR fields based on typical business data patterns
7. **Data Quality**: Assumed need for data quality monitoring and tracking

### 5.3 Rationale

1. **Bronze Layer Purpose**: Maintains raw data fidelity while adding essential metadata for downstream processing
2. **Relationship Preservation**: Logical relationships maintained through reference fields rather than formal foreign keys
3. **Flexibility**: Schema design allows for easy extension and modification as business requirements evolve
4. **Data Governance**: PII classification and audit capabilities support compliance and governance requirements
5. **Performance Optimization**: Reduced VARCHAR sizes improve query performance and reduce storage costs while maintaining data integrity
6. **Enhanced Monitoring**: Additional audit fields enable better data quality tracking and operational monitoring
7. **Error Handling**: Improved error tracking capabilities for better data pipeline management