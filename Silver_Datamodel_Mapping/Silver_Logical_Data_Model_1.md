_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver Logical Data Model for Zoom Platform Analytics System following medallion architecture principles with data quality and audit capabilities
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Logical Data Model - Zoom Platform Analytics System

## 1. Silver Layer Logical Model

### 1.1 Si_Users
**Description**: Silver layer table containing cleaned and standardized user data with data quality validations applied

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| user_name | VARCHAR(255) | Standardized full name of the registered user with proper case formatting |
| email | VARCHAR(320) | Validated and standardized email address for user communication |
| company | VARCHAR(255) | Standardized organization or company affiliation of the user |
| plan_type | VARCHAR(50) | Standardized subscription tier (Free, Basic, Pro, Enterprise) |
| registration_date | DATE | Date when the user first registered on the platform |
| last_login_date | DATE | Most recent date the user accessed the platform |
| account_status | VARCHAR(20) | Current status of user account (Active, Inactive, Suspended) |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the silver layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the silver layer |
| source_system | VARCHAR(100) | Source system from which data originated |
| data_quality_score | DECIMAL(3,2) | Overall data quality score for the record (0.00 to 1.00) |

### 1.2 Si_Meetings
**Description**: Silver layer table containing cleaned and enriched meeting data with calculated metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| meeting_topic | VARCHAR(500) | Cleaned and standardized meeting subject or title |
| meeting_type | VARCHAR(50) | Standardized meeting category (Scheduled, Instant, Webinar, Personal) |
| start_time | TIMESTAMP_NTZ(9) | Validated meeting start timestamp in UTC |
| end_time | TIMESTAMP_NTZ(9) | Validated meeting end timestamp in UTC |
| duration_minutes | INTEGER | Calculated and validated meeting duration in minutes |
| host_name | VARCHAR(255) | Standardized name of the user who hosted the meeting |
| meeting_status | VARCHAR(20) | Current state (Scheduled, In Progress, Completed, Cancelled) |
| recording_status | VARCHAR(10) | Whether the meeting was recorded (Yes, No) |
| participant_count | INTEGER | Total number of participants who joined the meeting |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the silver layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the silver layer |
| source_system | VARCHAR(100) | Source system from which data originated |
| data_quality_score | DECIMAL(3,2) | Overall data quality score for the record (0.00 to 1.00) |

### 1.3 Si_Participants
**Description**: Silver layer table containing cleaned participant attendance data with calculated metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| join_time | TIMESTAMP_NTZ(9) | Validated timestamp when participant joined the meeting |
| leave_time | TIMESTAMP_NTZ(9) | Validated timestamp when participant left the meeting |
| attendance_duration | INTEGER | Calculated time participant spent in meeting (minutes) |
| participant_role | VARCHAR(20) | Role of attendee (Host, Co-host, Participant, Observer) |
| connection_quality | VARCHAR(20) | Network connection quality during participation |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the silver layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the silver layer |
| source_system | VARCHAR(100) | Source system from which data originated |
| data_quality_score | DECIMAL(3,2) | Overall data quality score for the record (0.00 to 1.00) |

### 1.4 Si_Feature_Usage
**Description**: Silver layer table containing standardized feature usage data with categorization

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| feature_name | VARCHAR(100) | Standardized name of the platform feature used |
| usage_count | INTEGER | Validated number of times feature was utilized |
| usage_duration | INTEGER | Total time the feature was active during meeting (minutes) |
| feature_category | VARCHAR(50) | Classification of feature type (Audio, Video, Collaboration, Security) |
| usage_date | DATE | Date when feature usage occurred |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the silver layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the silver layer |
| source_system | VARCHAR(100) | Source system from which data originated |
| data_quality_score | DECIMAL(3,2) | Overall data quality score for the record (0.00 to 1.00) |

### 1.5 Si_Support_Tickets
**Description**: Silver layer table containing standardized customer support ticket data with resolution metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ticket_type | VARCHAR(50) | Standardized category (Technical, Billing, Feature Request, Bug Report) |
| priority_level | VARCHAR(20) | Urgency level of ticket (Low, Medium, High, Critical) |
| open_date | DATE | Date when the support ticket was created |
| close_date | DATE | Date when the support ticket was resolved |
| resolution_status | VARCHAR(20) | Current status (Open, In Progress, Resolved, Closed) |
| issue_description | TEXT | Cleaned and standardized description of the problem |
| resolution_notes | TEXT | Summary of actions taken to resolve the issue |
| resolution_time_hours | INTEGER | Calculated time to resolve ticket in business hours |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the silver layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the silver layer |
| source_system | VARCHAR(100) | Source system from which data originated |
| data_quality_score | DECIMAL(3,2) | Overall data quality score for the record (0.00 to 1.00) |

### 1.6 Si_Billing_Events
**Description**: Silver layer table containing validated billing and financial transaction data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| event_type | VARCHAR(50) | Standardized billing transaction type (Subscription, Upgrade, Downgrade, Refund) |
| transaction_amount | DECIMAL(10,2) | Validated monetary value of the billing event |
| transaction_date | DATE | Date when the billing event occurred |
| payment_method | VARCHAR(50) | Method used for payment (Credit Card, Bank Transfer, PayPal) |
| currency_code | VARCHAR(3) | ISO currency code for the transaction |
| invoice_number | VARCHAR(50) | Unique identifier for the billing invoice |
| transaction_status | VARCHAR(20) | Status of transaction (Completed, Pending, Failed, Refunded) |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the silver layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the silver layer |
| source_system | VARCHAR(100) | Source system from which data originated |
| data_quality_score | DECIMAL(3,2) | Overall data quality score for the record (0.00 to 1.00) |

### 1.7 Si_Licenses
**Description**: Silver layer table containing validated license assignment and management data

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| license_type | VARCHAR(50) | Standardized category (Basic, Pro, Enterprise, Add-on) |
| start_date | DATE | Validated date when the license becomes active |
| end_date | DATE | Validated date when the license expires |
| license_status | VARCHAR(20) | Current state (Active, Expired, Suspended) |
| assigned_user_name | VARCHAR(255) | Name of user to whom license is assigned |
| license_cost | DECIMAL(10,2) | Price associated with the license |
| renewal_status | VARCHAR(20) | Whether license is set for automatic renewal (Yes, No) |
| utilization_percentage | DECIMAL(5,2) | Percentage of license features being utilized |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the silver layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the silver layer |
| source_system | VARCHAR(100) | Source system from which data originated |
| data_quality_score | DECIMAL(3,2) | Overall data quality score for the record (0.00 to 1.00) |

### 1.8 Si_Webinars
**Description**: Silver layer table containing cleaned webinar data with engagement metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| webinar_topic | VARCHAR(500) | Cleaned and standardized topic or title of the webinar |
| start_time | TIMESTAMP_NTZ(9) | Validated webinar start timestamp in UTC |
| end_time | TIMESTAMP_NTZ(9) | Validated webinar end timestamp in UTC |
| duration_minutes | INTEGER | Calculated webinar duration in minutes |
| registrants | INTEGER | Number of registered participants |
| attendees | INTEGER | Number of actual attendees who joined |
| attendance_rate | DECIMAL(5,2) | Percentage of registrants who attended |
| load_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was loaded into the silver layer |
| update_timestamp | TIMESTAMP_NTZ(9) | Timestamp when record was last updated in the silver layer |
| source_system | VARCHAR(100) | Source system from which data originated |
| data_quality_score | DECIMAL(3,2) | Overall data quality score for the record (0.00 to 1.00) |

## 2. Data Quality and Error Management Tables

### 2.1 Si_Data_Quality_Errors
**Description**: Table to store data validation errors and quality issues identified during Silver layer processing

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| error_id | VARCHAR(50) | Unique identifier for each data quality error |
| source_table | VARCHAR(100) | Name of the source table where error was detected |
| source_record_id | VARCHAR(100) | Identifier of the source record with data quality issues |
| error_type | VARCHAR(50) | Type of error (Missing Value, Invalid Format, Constraint Violation, Duplicate) |
| error_column | VARCHAR(100) | Column name where the error was detected |
| error_description | TEXT | Detailed description of the data quality issue |
| error_severity | VARCHAR(20) | Severity level (Critical, High, Medium, Low) |
| detected_timestamp | TIMESTAMP_NTZ(9) | When the error was detected |
| resolution_status | VARCHAR(20) | Status of error resolution (Open, In Progress, Resolved, Ignored) |
| resolution_action | TEXT | Action taken to resolve the error |
| resolved_timestamp | TIMESTAMP_NTZ(9) | When the error was resolved |
| resolved_by | VARCHAR(100) | User or process that resolved the error |

### 2.2 Si_Data_Validation_Rules
**Description**: Table to store data validation rules and their execution results

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| rule_id | VARCHAR(50) | Unique identifier for each validation rule |
| rule_name | VARCHAR(200) | Descriptive name of the validation rule |
| target_table | VARCHAR(100) | Table to which the validation rule applies |
| target_column | VARCHAR(100) | Column to which the validation rule applies |
| rule_type | VARCHAR(50) | Type of validation (Format, Range, Referential, Business Logic) |
| rule_expression | TEXT | SQL expression or logic for the validation rule |
| rule_description | TEXT | Detailed description of what the rule validates |
| is_active | BOOLEAN | Whether the rule is currently active |
| created_date | DATE | Date when the rule was created |
| last_executed | TIMESTAMP_NTZ(9) | Last time the rule was executed |
| execution_count | INTEGER | Number of times the rule has been executed |
| failure_count | INTEGER | Number of times the rule has failed |

## 3. Pipeline Audit and Process Management Tables

### 3.1 Si_Pipeline_Audit
**Description**: Comprehensive audit table for tracking all Silver layer pipeline execution details

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| audit_id | VARCHAR(50) | Unique identifier for each pipeline execution |
| pipeline_name | VARCHAR(200) | Name of the data pipeline or process |
| execution_start_time | TIMESTAMP_NTZ(9) | When the pipeline execution started |
| execution_end_time | TIMESTAMP_NTZ(9) | When the pipeline execution completed |
| execution_duration_seconds | INTEGER | Total time taken for pipeline execution |
| execution_status | VARCHAR(20) | Status (Success, Failed, Partial Success, Cancelled) |
| source_tables_processed | TEXT | List of source tables processed in this execution |
| target_tables_updated | TEXT | List of target tables updated in this execution |
| records_processed | INTEGER | Total number of records processed |
| records_inserted | INTEGER | Number of new records inserted |
| records_updated | INTEGER | Number of existing records updated |
| records_rejected | INTEGER | Number of records rejected due to quality issues |
| error_message | TEXT | Error message if pipeline failed |
| executed_by | VARCHAR(100) | User or system that executed the pipeline |
| execution_environment | VARCHAR(50) | Environment where pipeline was executed (Dev, Test, Prod) |
| data_lineage_info | TEXT | Information about data lineage and transformations |

### 3.2 Si_Process_Monitoring
**Description**: Table for monitoring ongoing processes and system performance metrics

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| monitor_id | VARCHAR(50) | Unique identifier for each monitoring record |
| process_name | VARCHAR(200) | Name of the process being monitored |
| monitor_timestamp | TIMESTAMP_NTZ(9) | When the monitoring data was captured |
| cpu_usage_percentage | DECIMAL(5,2) | CPU usage percentage during process execution |
| memory_usage_mb | INTEGER | Memory usage in megabytes |
| disk_io_operations | INTEGER | Number of disk I/O operations |
| network_throughput_mbps | DECIMAL(10,2) | Network throughput in megabits per second |
| process_status | VARCHAR(20) | Current status of the process |
| queue_size | INTEGER | Number of items in processing queue |
| throughput_records_per_second | DECIMAL(10,2) | Processing throughput in records per second |
| error_rate_percentage | DECIMAL(5,2) | Percentage of records with errors |
| alert_threshold_breached | BOOLEAN | Whether any monitoring thresholds were exceeded |
| alert_message | TEXT | Alert message if thresholds were breached |

## 4. Conceptual Data Model Diagram

### 4.1 Block Diagram Representation

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Si_Users     │    │   Si_Meetings   │    │   Si_Licenses   │
│                 │    │                 │    │                 │
│ • user_name     │◄──►│ • host_name     │    │ • license_type  │
│ • email         │    │ • meeting_topic │    │ • assigned_user │
│ • company       │    │ • start_time    │    │ • start_date    │
│ • plan_type     │    │ • duration_min  │    │ • end_date      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Si_Participants │    │Si_Feature_Usage │    │Si_Support_Tickets│
│                 │    │                 │    │                 │
│ • join_time     │◄──►│ • feature_name  │◄──►│ • ticket_type   │
│ • leave_time    │    │ • usage_count   │    │ • priority_level│
│ • attendance_dur│    │ • usage_date    │    │ • open_date     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Si_Billing_Events│   │   Si_Webinars   │    │Si_Pipeline_Audit│
│                 │    │                 │    │                 │
│ • event_type    │◄──►│ • webinar_topic │◄──►│ • audit_id      │
│ • amount        │    │ • start_time    │    │ • pipeline_name │
│ • event_date    │    │ • registrants   │    │ • execution_time│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Si_Data_Quality_ │    │Si_Data_Validation│   │Si_Process_      │
│     Errors      │    │     Rules       │    │   Monitoring    │
│                 │    │                 │    │                 │
│ • error_id      │◄──►│ • rule_id       │◄──►│ • monitor_id    │
│ • source_table  │    │ • rule_name     │    │ • process_name  │
│ • error_type    │    │ • target_table  │    │ • cpu_usage     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 4.2 Table Relationships

| Source Table | Target Table | Connection Key Field | Relationship Type | Description |
|--------------|--------------|---------------------|-------------------|-------------|
| Si_Users | Si_Participants | user_name | One-to-Many | Users can participate in multiple meetings |
| Si_Meetings | Si_Participants | meeting_topic + start_time | One-to-Many | Meetings have multiple participants |
| Si_Meetings | Si_Feature_Usage | meeting_topic + start_time | One-to-Many | Features are used during meetings |
| Si_Users | Si_Support_Tickets | user_name | One-to-Many | Users can create multiple support tickets |
| Si_Users | Si_Billing_Events | user_name | One-to-Many | Users have multiple billing events |
| Si_Users | Si_Licenses | assigned_user_name | One-to-Many | Users can have multiple licenses |
| Si_Users | Si_Webinars | user_name (as host) | One-to-Many | Users can host multiple webinars |
| Si_Data_Quality_Errors | All Si_Tables | source_table + source_record_id | Many-to-One | Errors reference specific records |
| Si_Data_Validation_Rules | All Si_Tables | target_table | One-to-Many | Rules apply to specific tables |
| Si_Pipeline_Audit | All Si_Tables | target_tables_updated | One-to-Many | Audit records track table updates |
| Si_Process_Monitoring | Si_Pipeline_Audit | process_name | One-to-Many | Monitoring tracks pipeline processes |

**Note**: In the Silver layer, relationships are established through business logic and standardized key fields rather than formal foreign key constraints, enabling flexible data processing and quality management while maintaining referential integrity through validation rules.