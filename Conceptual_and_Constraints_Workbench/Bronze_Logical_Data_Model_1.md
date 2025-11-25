_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Bronze layer logical data model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model - Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Identified PII Fields

| Column Name | Table | PII Classification | Reason |
|-------------|-------|-------------------|--------|
| User_Name | Bz_Users | High Sensitivity | Contains personal identifiable information - individual's name |
| Email_Address | Bz_Users | High Sensitivity | Contains personal contact information that can identify an individual |
| Phone_Number | Bz_Users | High Sensitivity | Contains personal contact information that can identify an individual |
| IP_Address | Bz_Meeting_Activity | Medium Sensitivity | Can be used to identify user's location and potentially the individual |
| Device_Info | Bz_Meeting_Activity | Low Sensitivity | May contain device identifiers that could be linked to individuals |

## 2. Bronze Layer Logical Model

### 2.1 Table: Bz_Users
**Description**: Contains user information for the Zoom platform

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| User_Name | VARCHAR(100) | Full name of the user |
| Email_Address | VARCHAR(255) | User's email address |
| Phone_Number | VARCHAR(20) | User's contact phone number |
| Registration_Date | DATE | Date when user registered on the platform |
| User_Type | VARCHAR(50) | Type of user (Premium, Basic, Enterprise) |
| Status | VARCHAR(20) | Current status of the user account (Active, Inactive, Suspended) |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.2 Table: Bz_Meetings
**Description**: Contains meeting information and details

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Meeting_Title | VARCHAR(255) | Title or name of the meeting |
| Meeting_Type | VARCHAR(50) | Type of meeting (Scheduled, Instant, Recurring) |
| Meeting_Category | VARCHAR(50) | Category of meeting (Business, Personal, Educational) |
| Meeting_Topic | VARCHAR(500) | Topic or agenda of the meeting |
| Duration_Minutes | INTEGER | Duration of the meeting in minutes |
| Start_Time | TIMESTAMP | Meeting start timestamp |
| End_Time | TIMESTAMP | Meeting end timestamp |
| Max_Participants | INTEGER | Maximum number of participants allowed |
| Meeting_Status | VARCHAR(20) | Status of the meeting (Scheduled, Completed, Cancelled) |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.3 Table: Bz_Meeting_Activity
**Description**: Fact table containing meeting participation and activity data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Participation_Duration | INTEGER | Duration of user participation in minutes |
| Join_Time | TIMESTAMP | Time when user joined the meeting |
| Leave_Time | TIMESTAMP | Time when user left the meeting |
| Connection_Quality | VARCHAR(20) | Quality of user's connection (Good, Fair, Poor) |
| Device_Type | VARCHAR(50) | Type of device used (Desktop, Mobile, Tablet) |
| IP_Address | VARCHAR(45) | IP address of the participant |
| Device_Info | VARCHAR(255) | Additional device information |
| Participant_Role | VARCHAR(50) | Role of participant (Host, Co-host, Attendee) |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.4 Table: Bz_Feature_Usage
**Description**: Contains feature usage tracking information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Feature_Usage_Count | INTEGER | Number of times feature was used |
| Usage_Duration | INTEGER | Duration of feature usage in seconds |
| Usage_Date | DATE | Date when feature was used |
| Feature_Context | VARCHAR(255) | Context in which feature was used |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.5 Table: Bz_Dim_Features
**Description**: Dimension table containing feature information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Feature_Name | VARCHAR(100) | Name of the feature |
| Feature_Category | VARCHAR(50) | Category of the feature (Audio, Video, Collaboration) |
| Feature_Description | VARCHAR(500) | Description of the feature functionality |
| Feature_Type | VARCHAR(50) | Type of feature (Core, Premium, Add-on) |
| Is_Active | BOOLEAN | Whether the feature is currently active |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.6 Table: Bz_Dim_Date
**Description**: Date dimension table for time-based analysis

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Date_Value | DATE | The actual date value |
| Year | INTEGER | Year component |
| Quarter | INTEGER | Quarter of the year (1-4) |
| Month | INTEGER | Month component (1-12) |
| Month_Name | VARCHAR(20) | Name of the month |
| Day_of_Month | INTEGER | Day of the month (1-31) |
| Day_of_Week | INTEGER | Day of the week (1-7) |
| Day_Name | VARCHAR(20) | Name of the day |
| Is_Weekend | BOOLEAN | Whether the date falls on weekend |
| Is_Holiday | BOOLEAN | Whether the date is a holiday |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.7 Table: Bz_Support_Activity
**Description**: Fact table containing support ticket and activity information

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Ticket_Number | VARCHAR(50) | Unique ticket identifier |
| Open_Date | DATE | Date when ticket was opened |
| Close_Date | DATE | Date when ticket was closed |
| Resolution_Status | VARCHAR(50) | Current status of the ticket (Open, In Progress, Resolved, Closed) |
| Priority_Level | VARCHAR(20) | Priority level (Low, Medium, High, Critical) |
| Resolution_Time_Hours | INTEGER | Time taken to resolve in hours |
| Customer_Satisfaction_Score | INTEGER | Customer satisfaction rating (1-5) |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

### 2.8 Table: Bz_Dim_Support_Category
**Description**: Dimension table containing support categories

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Category_Name | VARCHAR(100) | Main support category name |
| Sub_Category | VARCHAR(100) | Sub-category within main category |
| Category_Description | VARCHAR(500) | Description of the support category |
| Escalation_Level | INTEGER | Level at which issues are escalated |
| Expected_Resolution_Time | INTEGER | Expected resolution time in hours |
| load_timestamp | TIMESTAMP | Timestamp when record was loaded into Bronze layer |
| update_timestamp | TIMESTAMP | Timestamp when record was last updated |
| source_system | VARCHAR(50) | Source system from which data originated |

## 3. Audit Table Design

### 3.1 Table: Bz_Audit_Log
**Description**: Audit table to track data processing activities across all Bronze layer tables

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(100) | Unique identifier for the audit record |
| source_table | VARCHAR(100) | Name of the source table being processed |
| load_timestamp | TIMESTAMP | Timestamp when the data load process started |
| processed_by | VARCHAR(100) | System or user that processed the data |
| processing_time | INTEGER | Time taken to process the data in seconds |
| status | VARCHAR(50) | Status of the processing (Success, Failed, Partial) |
| error_message | VARCHAR(1000) | Error message if processing failed |
| records_processed | INTEGER | Number of records processed |
| records_inserted | INTEGER | Number of records successfully inserted |
| records_updated | INTEGER | Number of records updated |
| records_failed | INTEGER | Number of records that failed processing |

## 4. Conceptual Data Model Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bz_Users      │    │  Bz_Meetings    │    │Bz_Meeting_      │
│                 │    │                 │    │Activity         │
│ - User_Name     │────│ - Meeting_Title │────│- Participation_ │
│ - Email_Address │    │ - Meeting_Type  │    │  Duration       │
│ - Phone_Number  │    │ - Duration_     │    │- Join_Time      │
│ - User_Type     │    │   Minutes       │    │- Device_Type    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         │                                              │
         └──────────────────────────────────────────────┘
                    Connected via User reference

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Bz_Feature_Usage │    │ Bz_Dim_Features │    │   Bz_Dim_Date   │
│                 │    │                 │    │                 │
│- Feature_Usage_ │────│ - Feature_Name  │    │ - Date_Value    │
│  Count          │    │ - Feature_      │    │ - Year          │
│- Usage_Duration │    │   Category      │    │ - Month         │
│- Usage_Date     │────│ - Feature_Type  │────│ - Day_Name      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         └──────────────────────────────────────────────┘
                    Connected via Date reference

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Bz_Support_      │    │Bz_Dim_Support_  │    │   Bz_Users      │
│Activity         │    │Category         │    │                 │
│                 │    │                 │    │ - User_Name     │
│- Ticket_Number  │────│ - Category_Name │    │ - Email_Address │
│- Resolution_    │    │ - Sub_Category  │    │ - User_Type     │
│  Status         │    │ - Escalation_   │────│ - Status        │
│- Priority_Level │    │   Level         │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         └──────────────────────────────────────────────┘
                    Connected via User reference
```

### 4.1 Table Relationships

1. **Bz_Users ↔ Bz_Meeting_Activity**: Connected through user reference field
   - One user can participate in multiple meetings (1:M)

2. **Bz_Meetings ↔ Bz_Meeting_Activity**: Connected through meeting reference field
   - One meeting can have multiple participants (1:M)

3. **Bz_Feature_Usage ↔ Bz_Dim_Features**: Connected through feature reference field
   - One feature can have multiple usage records (1:M)

4. **Bz_Feature_Usage ↔ Bz_Dim_Date**: Connected through usage date field
   - One date can have multiple feature usage records (1:M)

5. **Bz_Support_Activity ↔ Bz_Dim_Support_Category**: Connected through category reference field
   - One category can have multiple support activities (1:M)

6. **Bz_Support_Activity ↔ Bz_Users**: Connected through user reference field
   - One user can have multiple support tickets (1:M)

## 5. Design Rationale and Assumptions

### 5.1 Key Design Decisions

1. **Naming Convention**: All Bronze layer tables prefixed with 'Bz_' for consistency
2. **Metadata Columns**: Added load_timestamp, update_timestamp, and source_system to all tables for data lineage
3. **PII Handling**: Identified and classified PII fields for proper data governance
4. **Audit Trail**: Comprehensive audit table to track all data processing activities
5. **Data Types**: Selected appropriate data types based on expected data volume and precision requirements

### 5.2 Assumptions Made

1. Source systems provide clean, validated data
2. User identifiers are consistent across all source systems
3. Meeting duration is captured in minutes for consistency
4. Feature usage tracking is available at granular level
5. Support ticket resolution times are tracked in hours
6. Data retention policies will be applied at higher layers

### 5.3 Data Quality Considerations

1. **Referential Integrity**: Ensured proper relationships between fact and dimension tables
2. **Data Constraints**: Applied business rules as specified in requirements
3. **Null Handling**: Allowed for nullable fields where business logic permits
4. **Data Validation**: Audit table tracks data quality issues during processing