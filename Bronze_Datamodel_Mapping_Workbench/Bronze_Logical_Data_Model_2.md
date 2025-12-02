_____________________________________________
## *Author*: AAVA
## *Created on*: 2025-01-02
## *Description*: Updated Bronze Layer Logical Data Model for Medallion Architecture
## *Version*: 2
## *Updated on*: 2025-01-02
## *Changes*: Enhanced PII classification, improved table relationships, added missing reference fields, corrected data types alignment
## *Reason*: Update requested to improve data model accuracy and completeness based on source schema analysis
_____________________________________________

# Bronze Layer Logical Data Model

## 1. PII Classification

### 1.1 Identified PII Fields

| Table Name | Column Name | PII Classification | Reason |
|------------|-------------|-------------------|--------|
| Bz_Users | USER_NAME | PII | Contains personal identifiable name information that can directly identify an individual |
| Bz_Users | EMAIL | PII | Email addresses are direct personal identifiers that can be used to contact and identify individuals uniquely |
| Bz_Users | COMPANY | Sensitive | Company affiliation can be used to identify individuals in combination with other data elements |
| Bz_Meetings | MEETING_TOPIC | Sensitive | Meeting topics may contain confidential business information, personal discussions, or proprietary content |
| Bz_Support_Tickets | TICKET_TYPE | Sensitive | Support ticket types may reveal personal issues, technical problems, or business-sensitive information |
| Bz_Billing_Events | AMOUNT | Sensitive | Financial information that reveals spending patterns, financial status, and business transaction details |
| Bz_Participants | JOIN_TIME | Sensitive | Participation timing can reveal personal schedules and behavioral patterns |
| Bz_Participants | LEAVE_TIME | Sensitive | Meeting departure times can indicate personal availability and engagement patterns |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Billing_Events
**Description**: Stores raw billing event data from source systems without transformation, maintaining complete audit trail of financial transactions

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| USER_REFERENCE | Reference to the user who triggered the billing event | VARCHAR(16777216) |
| EVENT_TYPE | Type or category of the billing event (subscription, usage, penalty, etc.) | VARCHAR(16777216) |
| AMOUNT | Monetary amount associated with the billing event | VARCHAR(16777216) |
| EVENT_DATE | Date when the billing event occurred | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the billing data originated | VARCHAR(16777216) |

### 2.2 Bz_Feature_Usage
**Description**: Captures raw feature usage data from source systems, tracking platform feature adoption and utilization patterns

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| MEETING_REFERENCE | Reference to the meeting where the feature was used | VARCHAR(16777216) |
| FEATURE_NAME | Name of the platform feature that was utilized | VARCHAR(16777216) |
| USAGE_COUNT | Number of times the feature was used during the session | NUMBER(38,0) |
| USAGE_DATE | Date when the feature usage occurred | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the feature usage data originated | VARCHAR(16777216) |

### 2.3 Bz_Licenses
**Description**: Stores raw license information from source systems, tracking license assignments and lifecycle management

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| LICENSE_TYPE | Type or category of the license (basic, premium, enterprise, etc.) | VARCHAR(16777216) |
| ASSIGNED_TO_USER_REFERENCE | Reference to the user to whom the license is assigned | VARCHAR(16777216) |
| START_DATE | Date when the license becomes active and usable | DATE |
| END_DATE | Date when the license expires or becomes inactive | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the license data originated | VARCHAR(16777216) |

### 2.4 Bz_Meetings
**Description**: Contains raw meeting data from source systems, capturing comprehensive meeting session information

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| HOST_REFERENCE | Reference to the user hosting or organizing the meeting | VARCHAR(16777216) |
| MEETING_TOPIC | Subject or topic of the meeting discussion | VARCHAR(16777216) |
| START_TIME | Timestamp when the meeting session started | TIMESTAMP_NTZ(9) |
| END_TIME | Timestamp when the meeting session ended | VARCHAR(16777216) |
| DURATION_MINUTES | Total duration of the meeting in minutes | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the meeting data originated | VARCHAR(16777216) |

### 2.5 Bz_Participants
**Description**: Stores raw participant data for meetings from source systems, tracking meeting attendance and engagement

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| MEETING_REFERENCE | Reference to the meeting session | VARCHAR(16777216) |
| USER_REFERENCE | Reference to the user who participated in the meeting | VARCHAR(16777216) |
| JOIN_TIME | Time when participant joined the meeting session | VARCHAR(16777216) |
| LEAVE_TIME | Time when participant left the meeting session | TIMESTAMP_NTZ(9) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the participant data originated | VARCHAR(16777216) |

### 2.6 Bz_Support_Tickets
**Description**: Contains raw support ticket data from source systems, tracking customer service interactions and resolutions

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| USER_REFERENCE | Reference to the user who created the support ticket | VARCHAR(16777216) |
| TICKET_TYPE | Category or type of the support ticket (technical, billing, feature request, etc.) | VARCHAR(16777216) |
| RESOLUTION_STATUS | Current status of the ticket resolution (open, in-progress, resolved, closed) | VARCHAR(16777216) |
| OPEN_DATE | Date when the support ticket was initially opened | DATE |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the support ticket data originated | VARCHAR(16777216) |

### 2.7 Bz_Users
**Description**: Stores raw user account data from source systems, maintaining comprehensive user profile information

| Column Name | Description | Data Type |
|-------------|-------------|----------|
| USER_NAME | Display name of the user account | VARCHAR(16777216) |
| EMAIL | Email address of the user for communication and identification | VARCHAR(16777216) |
| COMPANY | Company or organization the user belongs to | VARCHAR(16777216) |
| PLAN_TYPE | Type of subscription plan the user has (free, basic, premium, enterprise) | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when record was loaded into the Bronze layer | TIMESTAMP_NTZ(9) |
| UPDATE_TIMESTAMP | Timestamp when record was last updated in the system | TIMESTAMP_NTZ(9) |
| SOURCE_SYSTEM | Source system from which the user data originated | VARCHAR(16777216) |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Comprehensive audit trail tracking all data processing activities across Bronze layer tables for compliance and monitoring

| Field Name | Description | Data Type |
|------------|-------------|----------|
| RECORD_ID | Unique identifier for each audit record entry | VARCHAR(16777216) |
| SOURCE_TABLE | Name of the Bronze layer table being processed | VARCHAR(16777216) |
| LOAD_TIMESTAMP | Timestamp when the data processing operation occurred | TIMESTAMP_NTZ(9) |
| PROCESSED_BY | System, service, or process that handled the data operation | VARCHAR(16777216) |
| PROCESSING_TIME | Duration taken to process the data in milliseconds | NUMBER(38,0) |
| STATUS | Status of the processing operation (SUCCESS, FAILED, PARTIAL, RETRY) | VARCHAR(16777216) |
| RECORDS_PROCESSED | Number of records processed in the operation | NUMBER(38,0) |
| ERROR_MESSAGE | Error details if processing failed | VARCHAR(16777216) |

## 4. Conceptual Data Model Diagram

### 4.1 Entity Relationships (Block Diagram Format)

```
                    ┌─────────────────────┐
                    │     Bz_Users        │
                    │                     │
                    │ - USER_NAME         │
                    │ - EMAIL             │
                    │ - COMPANY           │
                    │ - PLAN_TYPE         │
                    └─────────────────────┘
                             │
                             │ (Connected via USER_REFERENCE)
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Bz_Billing_     │  │   Bz_Meetings   │  │ Bz_Support_     │
│ Events          │  │                 │  │ Tickets         │
│                 │  │ - HOST_REF      │  │                 │
│ - USER_REF      │  │ - MEETING_TOPIC │  │ - USER_REF      │
│ - EVENT_TYPE    │  │ - START_TIME    │  │ - TICKET_TYPE   │
│ - AMOUNT        │  │ - END_TIME      │  │ - RESOLUTION_   │
│ - EVENT_DATE    │  │ - DURATION_MIN  │  │   STATUS        │
└─────────────────┘  └─────────────────┘  │ - OPEN_DATE     │
                              │           └─────────────────┘
                              │
                              │ (Connected via MEETING_REFERENCE)
                              │
                    ┌─────────┼─────────┐
                    │                   │
                    ▼                   ▼
            ┌─────────────────┐  ┌─────────────────┐
            │ Bz_Participants │  │ Bz_Feature_     │
            │                 │  │ Usage           │
            │ - MEETING_REF   │  │                 │
            │ - USER_REF      │  │ - MEETING_REF   │
            │ - JOIN_TIME     │  │ - FEATURE_NAME  │
            │ - LEAVE_TIME    │  │ - USAGE_COUNT   │
            └─────────────────┘  │ - USAGE_DATE    │
                    │            └─────────────────┘
                    │
                    │ (Connected via USER_REFERENCE)
                    │
                    ▼
            ┌─────────────────┐
            │ Bz_Licenses     │
            │                 │
            │ - LICENSE_TYPE  │
            │ - ASSIGNED_TO_  │
            │   USER_REF      │
            │ - START_DATE    │
            │ - END_DATE      │
            └─────────────────┘

                    ┌─────────────────┐
                    │ Bz_Audit_Log    │
                    │                 │
                    │ - RECORD_ID     │
                    │ - SOURCE_TABLE  │
                    │ - LOAD_TS       │
                    │ - PROCESSED_BY  │
                    │ - PROC_TIME     │
                    │ - STATUS        │
                    └─────────────────┘
                            │
                            │ (Tracks all tables)
                            │
                            ▼
                    [All Bronze Tables]
```

### 4.2 Key Relationships

1. **Bz_Users** (Central Hub) connects to:
   - **Bz_Billing_Events** via USER_REFERENCE field
   - **Bz_Support_Tickets** via USER_REFERENCE field
   - **Bz_Licenses** via ASSIGNED_TO_USER_REFERENCE field
   - **Bz_Meetings** via HOST_REFERENCE field
   - **Bz_Participants** via USER_REFERENCE field

2. **Bz_Meetings** (Meeting Hub) connects to:
   - **Bz_Participants** via MEETING_REFERENCE field
   - **Bz_Feature_Usage** via MEETING_REFERENCE field

3. **Bz_Audit_Log** tracks all tables via SOURCE_TABLE field for comprehensive monitoring

4. **Date Dimension** (implicit) connects to all tables via date fields for temporal analysis

## 5. Design Decisions and Assumptions

### 5.1 Key Design Decisions

1. **Enhanced Naming Convention**: All Bronze layer tables prefixed with 'Bz_' with improved reference field naming using '_REFERENCE' suffix
2. **Complete Data Preservation**: All source data fields preserved except primary/foreign key fields, with reference fields added for relationships
3. **Enhanced Metadata Columns**: Standard metadata columns with improved descriptions for better data lineage tracking
4. **Comprehensive PII Classification**: Expanded PII classification based on GDPR, CCPA, and industry best practices
5. **Robust Audit Trail**: Enhanced audit table design with additional fields for comprehensive monitoring and compliance
6. **Improved Data Types**: Maintained source data types while ensuring consistency across related fields

### 5.2 Assumptions Made

1. **Multi-Source Integration**: Multiple source systems will feed into Bronze layer with varying data quality levels
2. **High-Volume Processing**: Designed for high-volume, high-velocity data processing with appropriate scalability considerations
3. **Hybrid Processing Patterns**: Support for both batch and real-time data ingestion with proper timestamping
4. **Strict Compliance Requirements**: GDPR, CCPA, and industry-specific data privacy regulations apply
5. **Cloud-Native Scalability**: Designed for horizontal scaling in modern cloud data platforms
6. **Data Quality Variability**: Source data may have quality issues that need to be preserved in Bronze layer

### 5.3 Rationale

1. **Bronze Layer Philosophy**: Maintains complete raw data fidelity while adding essential metadata for downstream Silver/Gold layer processing
2. **Relationship Architecture**: Logical relationships maintained through reference fields enabling flexible downstream transformations
3. **Schema Evolution**: Design supports easy extension and modification as business requirements and data sources evolve
4. **Governance Foundation**: Comprehensive PII classification and audit capabilities provide strong foundation for data governance
5. **Performance Optimization**: Structure optimized for both analytical queries and operational data management
6. **Compliance Readiness**: Built-in features support regulatory compliance and data protection requirements

### 5.4 Data Quality Considerations

1. **Source Data Integrity**: Bronze layer preserves source data exactly as received, including potential quality issues
2. **Metadata Enrichment**: Additional metadata columns support data quality assessment and improvement in downstream layers
3. **Audit Capabilities**: Comprehensive audit logging enables data quality monitoring and issue resolution
4. **Lineage Tracking**: SOURCE_SYSTEM and timestamp fields provide complete data lineage for quality investigations