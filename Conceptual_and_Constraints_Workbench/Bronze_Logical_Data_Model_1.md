_____________________________________________
## *Author*: AAVA
## *Created on*: 2026-01-06
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2026-01-06
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| Column Name | Table | PII Classification | Reason |
|-------------|-------|-------------------|--------|
| User_Name | Bz_Users | Sensitive | Contains personally identifiable information that can directly identify an individual |
| Email_Address | Bz_Users | Sensitive | Email addresses are considered PII under GDPR and can be used to identify and contact individuals |
| Phone_Number | Bz_Users | Sensitive | Phone numbers are personal contact information that can identify individuals |
| User_Location | Bz_Users | Sensitive | Location data can be used to track and identify individuals, considered sensitive under privacy regulations |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description**: Contains user information and profile data for platform users

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| User_Name | VARCHAR(100) | Full name of the user |
| Email_Address | VARCHAR(255) | User's email address for communication |
| Phone_Number | VARCHAR(20) | User's contact phone number |
| User_Location | VARCHAR(100) | Geographic location of the user |
| Registration_Date | DATE | Date when user registered on the platform |
| User_Status | VARCHAR(20) | Current status of the user account (Active, Inactive, Suspended) |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.2 Bz_Meetings
**Description**: Contains meeting details and metadata

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Meeting_Title | VARCHAR(200) | Title or name of the meeting |
| Duration_Minutes | INTEGER | Duration of the meeting in minutes |
| Start_Time | TIMESTAMP | Meeting start timestamp |
| End_Time | TIMESTAMP | Meeting end timestamp |
| Meeting_Type | VARCHAR(50) | Type of meeting (Scheduled, Instant, Recurring) |
| Meeting_Category | VARCHAR(50) | Category classification of the meeting |
| Meeting_Topic | VARCHAR(500) | Topic or agenda of the meeting |
| Max_Participants | INTEGER | Maximum number of participants allowed |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.3 Bz_Meeting_Activity
**Description**: Fact table capturing user participation in meetings

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Participation_Duration | INTEGER | Duration of user participation in minutes |
| Join_Time | TIMESTAMP | Time when user joined the meeting |
| Leave_Time | TIMESTAMP | Time when user left the meeting |
| Participation_Status | VARCHAR(30) | Status of participation (Attended, No-Show, Left Early) |
| Role_In_Meeting | VARCHAR(30) | User's role in the meeting (Host, Participant, Co-host) |
| Connection_Quality | VARCHAR(20) | Quality of user's connection during meeting |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.4 Bz_Feature_Usage
**Description**: Tracks usage of platform features by users

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Usage_Count | INTEGER | Number of times feature was used |
| Usage_Duration | INTEGER | Duration of feature usage in minutes |
| Usage_Date | DATE | Date when feature was used |
| Usage_Context | VARCHAR(100) | Context in which feature was used |
| Device_Type | VARCHAR(50) | Type of device used to access feature |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.5 Bz_Dim_Feature
**Description**: Dimension table containing feature definitions and metadata

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Feature_Name | VARCHAR(100) | Name of the platform feature |
| Feature_Description | VARCHAR(500) | Detailed description of the feature |
| Feature_Category | VARCHAR(50) | Category classification of the feature |
| Feature_Type | VARCHAR(50) | Type of feature (Core, Premium, Add-on) |
| Is_Active | BOOLEAN | Whether the feature is currently active |
| Release_Date | DATE | Date when feature was released |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.6 Bz_Dim_Date
**Description**: Date dimension table for time-based analysis

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Date_Value | DATE | Actual date value |
| Year | INTEGER | Year component of the date |
| Month | INTEGER | Month component of the date |
| Day | INTEGER | Day component of the date |
| Quarter | INTEGER | Quarter of the year (1-4) |
| Week_Number | INTEGER | Week number in the year |
| Day_Of_Week | VARCHAR(10) | Name of the day of week |
| Is_Weekend | BOOLEAN | Whether the date falls on weekend |
| Is_Holiday | BOOLEAN | Whether the date is a holiday |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.7 Bz_Support_Activity
**Description**: Fact table capturing customer support interactions and tickets

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Ticket_Title | VARCHAR(200) | Title or subject of the support ticket |
| Ticket_Description | TEXT | Detailed description of the issue |
| Priority_Level | VARCHAR(20) | Priority level of the ticket (Low, Medium, High, Critical) |
| Resolution_Status | VARCHAR(30) | Current status of the ticket (Open, In Progress, Resolved, Closed) |
| Open_Date | DATE | Date when ticket was opened |
| Resolution_Date | DATE | Date when ticket was resolved |
| Response_Time_Hours | INTEGER | Time taken to first response in hours |
| Resolution_Time_Hours | INTEGER | Total time taken to resolve in hours |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.8 Bz_Dim_Support_Category
**Description**: Dimension table for support ticket categorization

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Category_Name | VARCHAR(100) | Main category of the support issue |
| Sub_Category | VARCHAR(100) | Sub-category for more specific classification |
| Category_Description | VARCHAR(500) | Description of the category |
| Escalation_Required | BOOLEAN | Whether issues in this category require escalation |
| SLA_Hours | INTEGER | Service Level Agreement response time in hours |
| Department | VARCHAR(50) | Department responsible for handling this category |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description**: Tracks all data processing activities and changes in the Bronze layer

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique identifier for the audit record |
| source_table | VARCHAR(100) | Name of the source table being processed |
| load_timestamp | TIMESTAMP | Timestamp when the data load process started |
| processed_by | VARCHAR(100) | System or user that processed the data |
| processing_time | INTEGER | Time taken to process the data in seconds |
| status | VARCHAR(20) | Status of the processing (Success, Failed, Warning) |
| error_message | TEXT | Error message if processing failed |
| records_processed | INTEGER | Number of records processed |
| records_inserted | INTEGER | Number of new records inserted |
| records_updated | INTEGER | Number of existing records updated |
| records_failed | INTEGER | Number of records that failed processing |

## 4. Conceptual Data Model Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Bz_Users      │────▶│ Bz_Meeting_     │◀────│   Bz_Meetings   │
│                 │     │   Activity      │     │                 │
│ - User_Name     │     │                 │     │ - Meeting_Title │
│ - Email_Address │     │ - Participation │     │ - Duration_Min  │
│ - Phone_Number  │     │   _Duration     │     │ - Start_Time    │
│ - User_Location │     │ - Join_Time     │     │ - Meeting_Type  │
└─────────────────┘     │ - Leave_Time    │     └─────────────────┘
                        └─────────────────┘
                                │
                                ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Bz_Dim_Feature  │────▶│ Bz_Feature_     │◀────│   Bz_Dim_Date   │
│                 │     │   Usage         │     │                 │
│ - Feature_Name  │     │                 │     │ - Date_Value    │
│ - Feature_Desc  │     │ - Usage_Count   │     │ - Year          │
│ - Feature_Cat   │     │ - Usage_Duration│     │ - Month         │
└─────────────────┘     │ - Usage_Date    │     │ - Quarter       │
                        └─────────────────┘     └─────────────────┘

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Bz_Users      │────▶│ Bz_Support_     │◀────│ Bz_Dim_Support_ │
│                 │     │   Activity      │     │   Category      │
│ (Referenced     │     │                 │     │                 │
│  above)         │     │ - Ticket_Title  │     │ - Category_Name │
└─────────────────┘     │ - Priority_Level│     │ - Sub_Category  │
                        │ - Resolution_   │     │ - SLA_Hours     │
                        │   Status        │     └─────────────────┘
                        └─────────────────┘
                                │
                                ▼
                        ┌─────────────────┐
                        │   Bz_Dim_Date   │
                        │                 │
                        │ (Referenced     │
                        │  above)         │
                        └─────────────────┘
```

### 4.1 Table Relationships

1. **Bz_Users ↔ Bz_Meeting_Activity**: Connected through User reference field
2. **Bz_Meetings ↔ Bz_Meeting_Activity**: Connected through Meeting reference field
3. **Bz_Users ↔ Bz_Feature_Usage**: Connected through User reference field
4. **Bz_Dim_Feature ↔ Bz_Feature_Usage**: Connected through Feature reference field
5. **Bz_Dim_Date ↔ Bz_Feature_Usage**: Connected through Usage_Date field
6. **Bz_Users ↔ Bz_Support_Activity**: Connected through User reference field
7. **Bz_Dim_Support_Category ↔ Bz_Support_Activity**: Connected through Category reference field
8. **Bz_Dim_Date ↔ Bz_Support_Activity**: Connected through Open_Date field

## 5. Design Decisions and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for consistent identification
2. **Metadata Columns**: Added standard metadata columns (load_timestamp, update_timestamp, source_system) to all tables for data lineage tracking
3. **PII Handling**: Identified and classified PII fields for proper data governance and compliance
4. **Audit Trail**: Comprehensive audit table to track all data processing activities
5. **Data Types**: Selected appropriate data types based on expected data volume and precision requirements

### 5.2 Assumptions Made

1. **Source System Integration**: Assumed data will be ingested from multiple source systems requiring source_system tracking
2. **Data Volume**: Designed for moderate to high data volumes with appropriate indexing considerations
3. **Compliance Requirements**: Assumed GDPR and similar privacy regulations apply, hence PII classification
4. **Real-time Processing**: Designed to support both batch and near real-time data processing
5. **Data Quality**: Assumed source data may have quality issues, hence comprehensive audit logging

### 5.3 Rationale for Key Fields

1. **Timestamp Fields**: Essential for temporal analysis and data lineage tracking
2. **Status Fields**: Enable monitoring of data processing and business process states
3. **Duration Fields**: Critical for performance analysis and user engagement metrics
4. **Category Fields**: Support dimensional analysis and reporting flexibility
5. **Quality Fields**: Enable monitoring of technical performance and user experience