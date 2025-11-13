_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System Medallion Architecture
## *Version*: 2
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 User Data
- **USER_NAME**: Contains full names of users - classified as PII under GDPR Article 4(1) as it directly identifies natural persons
- **EMAIL**: Contains personal email addresses - classified as PII as it can identify and be used to contact natural persons
- **COMPANY**: Contains organization names - may contain PII if it's a sole proprietorship or small business where company name identifies individuals

### 1.2 Meeting Data
- **MEETING_TOPIC**: May contain sensitive business information or personal identifiers - classified as potentially sensitive data requiring careful handling

### 1.3 Support Data
- **USER_ID in SUPPORT_TICKETS**: Links support requests to individual users - classified as PII as it enables identification of individuals seeking support

### 1.4 Billing Data
- **USER_ID in BILLING_EVENTS**: Links financial transactions to individual users - classified as sensitive PII as it reveals financial behavior and payment patterns
- **AMOUNT**: Contains financial transaction amounts - classified as sensitive financial data requiring protection

## 2. Bronze Layer Logical Model

### 2.1 User Management Tables

#### Bz_Users
**Description**: Raw user profile data from Zoom platform registration and management systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_NAME | VARCHAR(16777216) | Display name of the user in the Zoom platform |
| EMAIL | VARCHAR(16777216) | User's email address for communication and login authentication |
| COMPANY | VARCHAR(16777216) | Organization or company name associated with the user account |
| PLAN_TYPE | VARCHAR(16777216) | Subscription plan category (Basic, Pro, Business, Enterprise) |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in Bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.2 Meeting and Collaboration Tables

#### Bz_Meetings
**Description**: Raw meeting data from Zoom platform including scheduled and instant meetings

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| MEETING_TOPIC | VARCHAR(16777216) | Topic or title of the meeting as set by the host |
| START_TIME | TIMESTAMP_NTZ(9) | Date and time when the meeting began |
| END_TIME | TIMESTAMP_NTZ(9) | Date and time when the meeting concluded |
| DURATION_MINUTES | NUMBER(38,0) | Total length of the meeting in minutes |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in Bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

#### Bz_Participants
**Description**: Raw participant data tracking who joined which meetings

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| JOIN_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant joined the meeting |
| LEAVE_TIME | TIMESTAMP_NTZ(9) | Timestamp when the participant left the meeting |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in Bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

#### Bz_Feature_Usage
**Description**: Raw feature utilization data from Zoom platform during meetings

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| FEATURE_NAME | VARCHAR(16777216) | Name of the specific feature used (Screen Share, Recording, Chat, etc.) |
| USAGE_COUNT | NUMBER(38,0) | Number of times the feature was utilized during the session |
| USAGE_DATE | DATE | Date when the feature usage occurred |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in Bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.3 Support and Service Tables

#### Bz_Support_Tickets
**Description**: Raw customer support ticket data from Zoom support systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| TICKET_TYPE | VARCHAR(16777216) | Category of the support issue (Technical, Billing, Feature Request, etc.) |
| RESOLUTION_STATUS | VARCHAR(16777216) | Current state of the ticket (Open, In Progress, Resolved, Closed) |
| OPEN_DATE | DATE | Date when the support ticket was created |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in Bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

### 2.4 Revenue and Licensing Tables

#### Bz_Billing_Events
**Description**: Raw billing and financial transaction data from Zoom billing systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| EVENT_TYPE | VARCHAR(16777216) | Type of billing transaction (Subscription, Upgrade, Refund, etc.) |
| AMOUNT | NUMBER(10,2) | Monetary value of the transaction |
| EVENT_DATE | DATE | Date when the billing event occurred |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in Bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

#### Bz_Licenses
**Description**: Raw license assignment and entitlement data from Zoom license management systems

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| LICENSE_TYPE | VARCHAR(16777216) | Category of license (Basic, Pro, Enterprise, Add-on) |
| START_DATE | DATE | Date when the license becomes active |
| END_DATE | DATE | Date when the license expires |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in Bronze layer |
| source_system | VARCHAR(16777216) | Source system from which data originated |

## 3. Audit Table Design

### Bz_Data_Audit_Log
**Description**: Comprehensive audit trail for all Bronze layer data operations in the Zoom Platform Analytics System

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique identifier for each audit record |
| source_table | VARCHAR(100) | Name of the Bronze layer table being audited |
| load_timestamp | TIMESTAMP_NTZ(9) | When the data load operation occurred |
| processed_by | VARCHAR(100) | System, process, or user that processed the data |
| processing_time | DECIMAL(10,3) | Time taken to process the operation in seconds |
| status | VARCHAR(20) | Status of the operation (SUCCESS, FAILED, PARTIAL) |
| record_count | INTEGER | Number of records processed in the operation |
| error_message | TEXT | Detailed error information if status is FAILED |
| source_file_path | VARCHAR(500) | Path to source file or system if applicable |
| checksum | VARCHAR(64) | Data integrity checksum for validation |
| operation_type | VARCHAR(20) | Type of operation performed (INSERT, UPDATE, DELETE, MERGE) |

## 4. Conceptual Data Model Diagram

```
┌─────────────────────┐
│     Bz_Users        │
│                     │
│ • USER_NAME         │◄──┐
│ • EMAIL             │   │
│ • COMPANY           │   │ (Host relationship)
│ • PLAN_TYPE         │   │
└─────────────────────┘   │
                          │
                          │ HOST_ID
                          │
┌─────────────────────┐   │
│    Bz_Meetings      │   │
│                     │   │
│ • MEETING_TOPIC     │◄──┘
│ • START_TIME        │◄──┐
│ • END_TIME          │   │
│ • DURATION_MINUTES  │   │
└─────────────────────┘   │
                          │ MEETING_ID
                          │
┌─────────────────────┐   │
│   Bz_Participants   │   │
│                     │   │
│ • JOIN_TIME         │◄──┤
│ • LEAVE_TIME        │   │
└─────────────────────┘   │
                          │
┌─────────────────────┐   │
│  Bz_Feature_Usage   │   │
│                     │   │
│ • FEATURE_NAME      │◄──┘
│ • USAGE_COUNT       │
│ • USAGE_DATE        │
└─────────────────────┘

┌─────────────────────┐
│  Bz_Support_Tickets │
│                     │
│ • TICKET_TYPE       │◄──── USER_ID ────► Bz_Users
│ • RESOLUTION_STATUS │
│ • OPEN_DATE         │
└─────────────────────┘

┌─────────────────────┐
│  Bz_Billing_Events  │
│                     │
│ • EVENT_TYPE        │◄──── USER_ID ────► Bz_Users
│ • AMOUNT            │
│ • EVENT_DATE        │
└─────────────────────┘

┌─────────────────────┐
│    Bz_Licenses      │
│                     │
│ • LICENSE_TYPE      │◄──── ASSIGNED_TO_USER_ID ────► Bz_Users
│ • START_DATE        │
│ • END_DATE          │
└─────────────────────┘

┌─────────────────────┐
│  Bz_Data_Audit_Log  │
│                     │
│ • record_id         │
│ • source_table      │ ──── References all Bronze tables
│ • load_timestamp    │
│ • status            │
└─────────────────────┘
```

### Key Relationships:

1. **Bz_Users ↔ Bz_Meetings**: Connected via `HOST_ID` (Users can host multiple meetings)
2. **Bz_Meetings ↔ Bz_Participants**: Connected via `MEETING_ID` (Meetings can have multiple participants)
3. **Bz_Meetings ↔ Bz_Feature_Usage**: Connected via `MEETING_ID` (Features are used within meetings)
4. **Bz_Users ↔ Bz_Participants**: Connected via `USER_ID` (Users can participate in multiple meetings)
5. **Bz_Users ↔ Bz_Support_Tickets**: Connected via `USER_ID` (Users can create multiple support tickets)
6. **Bz_Users ↔ Bz_Billing_Events**: Connected via `USER_ID` (Users can have multiple billing events)
7. **Bz_Users ↔ Bz_Licenses**: Connected via `ASSIGNED_TO_USER_ID` (Users can have multiple licenses)
8. **Bz_Data_Audit_Log**: References all tables via `source_table` field for comprehensive auditing

### Design Rationale:

1. **Naming Convention**: All Bronze tables prefixed with 'Bz_' following medallion architecture standards
2. **Source Data Fidelity**: Tables mirror the exact structure from raw schema, excluding primary and foreign key fields as instructed
3. **Metadata Consistency**: All tables include `load_timestamp`, `update_timestamp`, and `source_system` for data lineage
4. **PII Identification**: Sensitive fields clearly identified and documented for GDPR and privacy compliance
5. **Audit Capability**: Comprehensive audit table design supports data governance and regulatory requirements
6. **Scalability**: Data types sized appropriately for Zoom platform scale and performance

### Assumptions Made:

1. **Data Sources**: Raw data comes from multiple Zoom platform systems (user management, meeting services, billing, support)
2. **Data Frequency**: Data loads occur regularly with incremental updates tracked via timestamps
3. **Business Keys**: Relationships maintained through business identifiers rather than technical keys
4. **Time Zones**: All timestamps stored in UTC format for consistency
5. **Data Quality**: Source systems provide reasonably clean data with basic validation
6. **Retention**: Bronze layer serves as historical archive with full data retention
7. **Integration**: Tables designed to support downstream Silver and Gold layer transformations for analytics and reporting