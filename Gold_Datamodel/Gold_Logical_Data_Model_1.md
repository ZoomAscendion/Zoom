_____________________________________________
## *Author*: AAVA
## *Created on*:   10-11-2025
## *Description*: Gold layer logical data model for Zoom Platform Analytics System following Medallion architecture with dimensional modeling
## *Version*: 1 
## *Updated on*:  10-11-2025
_____________________________________________

# Gold Layer Logical Data Model - Zoom Platform Analytics System

## 1. Overview

This document defines the Gold layer logical data model for the Zoom Platform Analytics System following the Medallion architecture pattern. The Gold layer serves as the consumption-ready data layer, implementing dimensional modeling principles with Facts, Dimensions, and Aggregated tables optimized for analytics, reporting, and business intelligence.

### Key Principles:
- **Dimensional Modeling**: Star schema design with Facts and Dimensions
- **Business-Centric**: Optimized for business users and reporting tools
- **Aggregated Views**: Pre-calculated metrics for performance
- **Audit & Error Tracking**: Comprehensive process audit and error data management
- **Consistent Naming**: 'Go_' prefix for all Gold layer tables

## 2. Gold Layer Schema Design

### Schema Naming Convention
- **Target Database**: DB_POC_ZOOM
- **Target Schema**: GOLD
- **Table Prefix**: Go_ (Gold layer identifier)
- **Naming Pattern**: Go_[TableType]_[BusinessEntity]

### Standard Metadata Columns
All Gold layer tables include the following standard metadata columns:
- `load_date` - Date when record was processed into Gold layer
- `update_date` - Date when record was last updated
- `source_system` - Source system identifier for data lineage

## 3. Gold Layer Table Definitions

### 3.1 FACT TABLES

#### 3.1.1 Go_Fact_Meeting_Activity
**Purpose**: Central fact table capturing meeting activities and usage metrics
**Table Type**: Fact
**SCD Type**: N/A (Fact table)
**Source Mapping**: SILVER.Si_MEETINGS, Si_PARTICIPANTS, Si_FEATURE_USAGE

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| meeting_date | DATE | Date when the meeting occurred | Non-PII |
| meeting_topic | VARCHAR(500) | Topic or title of the meeting | Non-PII |
| start_time | TIMESTAMP_NTZ(9) | Meeting start timestamp | Non-PII |
| end_time | TIMESTAMP_NTZ(9) | Meeting end timestamp | Non-PII |
| duration_minutes | NUMBER(10,0) | Total meeting duration in minutes | Non-PII |
| participant_count | NUMBER(10,0) | Total number of participants in the meeting | Non-PII |
| total_join_time_minutes | NUMBER(15,2) | Sum of all participant join times in minutes | Non-PII |
| average_participation_minutes | NUMBER(10,2) | Average participation time per participant | Non-PII |
| features_used_count | NUMBER(10,0) | Total number of features used during meeting | Non-PII |
| screen_share_usage_count | NUMBER(10,0) | Number of times screen sharing was used | Non-PII |
| recording_usage_count | NUMBER(10,0) | Number of times recording was used | Non-PII |
| chat_usage_count | NUMBER(10,0) | Number of times chat was used | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 3.1.2 Go_Fact_Support_Activity
**Purpose**: Fact table capturing support ticket activities and resolution metrics
**Table Type**: Fact
**SCD Type**: N/A (Fact table)
**Source Mapping**: SILVER.Si_SUPPORT_TICKETS

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| ticket_open_date | DATE | Date when support ticket was opened | Non-PII |
| ticket_close_date | DATE | Date when support ticket was closed | Non-PII |
| ticket_type | VARCHAR(100) | Type of support ticket | Non-PII |
| resolution_status | VARCHAR(100) | Current resolution status of the ticket | Non-PII |
| priority_level | VARCHAR(50) | Priority level of the support ticket | Non-PII |
| resolution_time_hours | NUMBER(10,2) | Time taken to resolve ticket in hours | Non-PII |
| escalation_count | NUMBER(5,0) | Number of times ticket was escalated | Non-PII |
| customer_satisfaction_score | NUMBER(3,1) | Customer satisfaction rating for resolution | Non-PII |
| first_contact_resolution_flag | BOOLEAN | Whether ticket was resolved on first contact | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 3.1.3 Go_Fact_Revenue_Activity
**Purpose**: Fact table capturing billing events and revenue metrics
**Table Type**: Fact
**SCD Type**: N/A (Fact table)
**Source Mapping**: SILVER.Si_BILLING_EVENTS

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| transaction_date | DATE | Date when the billing transaction occurred | Non-PII |
| event_type | VARCHAR(100) | Type of billing event | Non-PII |
| amount | NUMBER(15,2) | Monetary amount of the transaction | Non-PII |
| currency | VARCHAR(10) | Currency code for the transaction | Non-PII |
| payment_method | VARCHAR(100) | Method used for payment | Non-PII |
| subscription_revenue_amount | NUMBER(15,2) | Revenue amount from subscriptions | Non-PII |
| one_time_revenue_amount | NUMBER(15,2) | Revenue amount from one-time payments | Non-PII |
| refund_amount | NUMBER(15,2) | Amount refunded if applicable | Non-PII |
| tax_amount | NUMBER(15,2) | Tax amount for the transaction | Non-PII |
| net_revenue_amount | NUMBER(15,2) | Net revenue after taxes and refunds | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 3.2 DIMENSION TABLES

#### 3.2.1 Go_Dim_User
**Purpose**: Dimension table containing user profile and subscription information
**Table Type**: Dimension
**SCD Type**: Type 2 (Track historical changes)
**Source Mapping**: SILVER.Si_USERS

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| user_name | VARCHAR(200) | Display name of the user | PII - Personal |
| email_domain | VARCHAR(100) | Domain part of user email for analysis | Non-PII |
| company | VARCHAR(200) | Company or organization name | Non-PII |
| plan_type | VARCHAR(100) | Current subscription plan type | Non-PII |
| plan_category | VARCHAR(50) | Plan category (Free, Paid, Enterprise) | Non-PII |
| registration_date | DATE | Date when user first registered | Non-PII |
| user_status | VARCHAR(50) | Current status of the user account | Non-PII |
| geographic_region | VARCHAR(100) | Geographic region of the user | Non-PII |
| industry_sector | VARCHAR(100) | Industry sector of user's organization | Non-PII |
| effective_start_date | DATE | Start date for this version of the record | Non-PII |
| effective_end_date | DATE | End date for this version of the record | Non-PII |
| is_current_record | BOOLEAN | Flag indicating if this is the current version | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 3.2.2 Go_Dim_Meeting
**Purpose**: Dimension table containing meeting characteristics and metadata
**Table Type**: Dimension
**SCD Type**: Type 1 (Overwrite changes)
**Source Mapping**: SILVER.Si_MEETINGS

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| meeting_type | VARCHAR(100) | Type of meeting (Scheduled, Instant, Webinar) | Non-PII |
| meeting_category | VARCHAR(100) | Business category of the meeting | Non-PII |
| duration_category | VARCHAR(50) | Duration category (Short, Medium, Long) | Non-PII |
| participant_size_category | VARCHAR(50) | Size category based on participant count | Non-PII |
| time_of_day_category | VARCHAR(50) | Time category (Morning, Afternoon, Evening) | Non-PII |
| day_of_week | VARCHAR(20) | Day of the week when meeting occurred | Non-PII |
| is_weekend | BOOLEAN | Flag indicating if meeting was on weekend | Non-PII |
| is_recurring | BOOLEAN | Flag indicating if meeting is part of series | Non-PII |
| meeting_quality_score | NUMBER(3,1) | Overall quality score of the meeting | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 3.2.3 Go_Dim_Feature
**Purpose**: Dimension table containing platform features and their characteristics
**Table Type**: Dimension
**SCD Type**: Type 1 (Overwrite changes)
**Source Mapping**: SILVER.Si_FEATURE_USAGE

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| feature_name | VARCHAR(200) | Name of the platform feature | Non-PII |
| feature_category | VARCHAR(100) | Category of the feature (Communication, Collaboration, etc.) | Non-PII |
| feature_type | VARCHAR(100) | Type of feature (Core, Premium, Add-on) | Non-PII |
| feature_complexity | VARCHAR(50) | Complexity level (Basic, Intermediate, Advanced) | Non-PII |
| is_premium_feature | BOOLEAN | Flag indicating if feature requires premium plan | Non-PII |
| feature_release_date | DATE | Date when feature was first released | Non-PII |
| feature_status | VARCHAR(50) | Current status of the feature | Non-PII |
| usage_frequency_category | VARCHAR(50) | Frequency category based on usage patterns | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 3.2.4 Go_Dim_License
**Purpose**: Dimension table containing license types and entitlements
**Table Type**: Dimension
**SCD Type**: Type 2 (Track historical changes)
**Source Mapping**: SILVER.Si_LICENSES

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| license_type | VARCHAR(100) | Type of license (Basic, Pro, Business, Enterprise) | Non-PII |
| license_category | VARCHAR(50) | Category of license (Standard, Premium, Enterprise) | Non-PII |
| license_tier | VARCHAR(50) | Tier level of the license | Non-PII |
| max_participants | NUMBER(10,0) | Maximum participants allowed for this license | Non-PII |
| storage_limit_gb | NUMBER(10,0) | Storage limit in GB for this license | Non-PII |
| recording_limit_hours | NUMBER(10,0) | Recording limit in hours per month | Non-PII |
| admin_features_included | BOOLEAN | Whether admin features are included | Non-PII |
| api_access_included | BOOLEAN | Whether API access is included | Non-PII |
| sso_support_included | BOOLEAN | Whether SSO support is included | Non-PII |
| monthly_price | NUMBER(10,2) | Monthly price for this license type | Non-PII |
| annual_price | NUMBER(10,2) | Annual price for this license type | Non-PII |
| effective_start_date | DATE | Start date for this version of the record | Non-PII |
| effective_end_date | DATE | End date for this version of the record | Non-PII |
| is_current_record | BOOLEAN | Flag indicating if this is the current version | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 3.2.5 Go_Dim_Date
**Purpose**: Standard date dimension for time-based analysis
**Table Type**: Dimension
**SCD Type**: Type 1 (Static reference data)
**Source Mapping**: Generated dimension

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| date_value | DATE | The actual date value | Non-PII |
| year | NUMBER(4,0) | Year component of the date | Non-PII |
| quarter | NUMBER(1,0) | Quarter component (1-4) | Non-PII |
| month | NUMBER(2,0) | Month component (1-12) | Non-PII |
| month_name | VARCHAR(20) | Full name of the month | Non-PII |
| day_of_month | NUMBER(2,0) | Day of the month (1-31) | Non-PII |
| day_of_week | NUMBER(1,0) | Day of the week (1-7) | Non-PII |
| day_name | VARCHAR(20) | Full name of the day | Non-PII |
| is_weekend | BOOLEAN | Flag indicating if date is weekend | Non-PII |
| is_holiday | BOOLEAN | Flag indicating if date is a holiday | Non-PII |
| fiscal_year | NUMBER(4,0) | Fiscal year for the date | Non-PII |
| fiscal_quarter | NUMBER(1,0) | Fiscal quarter for the date | Non-PII |
| week_of_year | NUMBER(2,0) | Week number in the year | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 3.3 AGGREGATED TABLES

#### 3.3.1 Go_Agg_Daily_Usage_Summary
**Purpose**: Daily aggregated metrics for platform usage and adoption
**Table Type**: Aggregated
**SCD Type**: N/A (Aggregated data)
**Source Mapping**: Go_Fact_Meeting_Activity, Go_Dim_User, Go_Dim_Date

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| summary_date | DATE | Date for which metrics are aggregated | Non-PII |
| total_meetings | NUMBER(15,0) | Total number of meetings conducted | Non-PII |
| total_meeting_minutes | NUMBER(20,0) | Total meeting minutes across all meetings | Non-PII |
| unique_hosts | NUMBER(15,0) | Number of unique meeting hosts | Non-PII |
| unique_participants | NUMBER(15,0) | Number of unique meeting participants | Non-PII |
| average_meeting_duration | NUMBER(10,2) | Average duration of meetings in minutes | Non-PII |
| average_participants_per_meeting | NUMBER(10,2) | Average number of participants per meeting | Non-PII |
| total_screen_shares | NUMBER(15,0) | Total screen sharing sessions | Non-PII |
| total_recordings | NUMBER(15,0) | Total recording sessions | Non-PII |
| total_chat_usage | NUMBER(15,0) | Total chat usage instances | Non-PII |
| peak_concurrent_meetings | NUMBER(10,0) | Peak number of concurrent meetings | Non-PII |
| new_user_registrations | NUMBER(10,0) | Number of new user registrations | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 3.3.2 Go_Agg_Monthly_Revenue_Summary
**Purpose**: Monthly aggregated revenue and billing metrics
**Table Type**: Aggregated
**SCD Type**: N/A (Aggregated data)
**Source Mapping**: Go_Fact_Revenue_Activity, Go_Dim_License, Go_Dim_Date

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| summary_month | DATE | Month for which revenue is aggregated (first day of month) | Non-PII |
| total_revenue | NUMBER(20,2) | Total revenue for the month | Non-PII |
| subscription_revenue | NUMBER(20,2) | Revenue from subscription plans | Non-PII |
| one_time_revenue | NUMBER(20,2) | Revenue from one-time purchases | Non-PII |
| refund_amount | NUMBER(20,2) | Total refunds processed | Non-PII |
| net_revenue | NUMBER(20,2) | Net revenue after refunds | Non-PII |
| new_customer_revenue | NUMBER(20,2) | Revenue from new customers | Non-PII |
| expansion_revenue | NUMBER(20,2) | Revenue from plan upgrades | Non-PII |
| churn_revenue_lost | NUMBER(20,2) | Revenue lost due to churn | Non-PII |
| average_revenue_per_user | NUMBER(15,2) | Average revenue per user for the month | Non-PII |
| total_active_licenses | NUMBER(15,0) | Total number of active licenses | Non-PII |
| license_utilization_rate | NUMBER(5,2) | Percentage of licenses being utilized | Non-PII |
| monthly_recurring_revenue | NUMBER(20,2) | Monthly recurring revenue (MRR) | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 3.3.3 Go_Agg_Support_Performance_Summary
**Purpose**: Aggregated support performance and service reliability metrics
**Table Type**: Aggregated
**SCD Type**: N/A (Aggregated data)
**Source Mapping**: Go_Fact_Support_Activity, Go_Dim_User, Go_Dim_Date

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| summary_date | DATE | Date for which support metrics are aggregated | Non-PII |
| total_tickets_opened | NUMBER(10,0) | Total number of tickets opened | Non-PII |
| total_tickets_closed | NUMBER(10,0) | Total number of tickets closed | Non-PII |
| tickets_resolved_same_day | NUMBER(10,0) | Number of tickets resolved on same day | Non-PII |
| average_resolution_time_hours | NUMBER(10,2) | Average time to resolve tickets in hours | Non-PII |
| first_contact_resolution_rate | NUMBER(5,2) | Percentage of tickets resolved on first contact | Non-PII |
| customer_satisfaction_average | NUMBER(3,2) | Average customer satisfaction score | Non-PII |
| critical_tickets_count | NUMBER(10,0) | Number of critical priority tickets | Non-PII |
| high_priority_tickets_count | NUMBER(10,0) | Number of high priority tickets | Non-PII |
| escalated_tickets_count | NUMBER(10,0) | Number of tickets that were escalated | Non-PII |
| tickets_per_1000_users | NUMBER(10,2) | Number of tickets per 1000 active users | Non-PII |
| sla_compliance_rate | NUMBER(5,2) | Percentage of tickets meeting SLA targets | Non-PII |
| load_date | DATE | Date when record was processed into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 3.4 PROCESS AUDIT TABLES

#### 3.4.1 Go_Process_Audit_Log
**Purpose**: Comprehensive audit trail for all Gold layer pipeline executions and processes
**Table Type**: Audit
**SCD Type**: N/A (Audit data)
**Source Mapping**: Pipeline execution metadata

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| audit_log_id | VARCHAR(50) | Unique identifier for each audit log entry | Non-PII |
| process_name | VARCHAR(200) | Name of the executed process or pipeline | Non-PII |
| process_type | VARCHAR(100) | Type of process (ETL, Data Quality, Aggregation) | Non-PII |
| execution_start_timestamp | TIMESTAMP_NTZ(9) | Timestamp when process execution started | Non-PII |
| execution_end_timestamp | TIMESTAMP_NTZ(9) | Timestamp when process execution completed | Non-PII |
| execution_duration_seconds | NUMBER(15,2) | Total execution time in seconds | Non-PII |
| execution_status | VARCHAR(50) | Status of execution (SUCCESS, FAILED, PARTIAL) | Non-PII |
| source_table_name | VARCHAR(200) | Name of source table processed | Non-PII |
| target_table_name | VARCHAR(200) | Name of target table created/updated | Non-PII |
| records_read | NUMBER(20,0) | Number of records read from source | Non-PII |
| records_processed | NUMBER(20,0) | Number of records successfully processed | Non-PII |
| records_inserted | NUMBER(20,0) | Number of records inserted into target | Non-PII |
| records_updated | NUMBER(20,0) | Number of records updated in target | Non-PII |
| records_failed | NUMBER(20,0) | Number of records that failed processing | Non-PII |
| data_quality_score | NUMBER(5,2) | Overall data quality score for the process | Non-PII |
| error_count | NUMBER(15,0) | Total number of errors encountered | Non-PII |
| warning_count | NUMBER(15,0) | Total number of warnings generated | Non-PII |
| process_trigger | VARCHAR(100) | What triggered the process (SCHEDULED, MANUAL, EVENT) | Non-PII |
| executed_by | VARCHAR(100) | User or system that executed the process | Non-PII |
| server_name | VARCHAR(100) | Server where process was executed | Non-PII |
| process_version | VARCHAR(50) | Version of the process that was executed | Non-PII |
| configuration_parameters | VARIANT | JSON object containing process configuration | Non-PII |
| performance_metrics | VARIANT | JSON object containing performance metrics | Non-PII |
| load_date | DATE | Date when audit record was created | Non-PII |
| update_date | DATE | Date when audit record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 3.5 ERROR DATA TABLES

#### 3.5.1 Go_Data_Validation_Errors
**Purpose**: Stores detailed error information from data validation processes in Gold layer
**Table Type**: Error Data
**SCD Type**: N/A (Error tracking data)
**Source Mapping**: Data validation process outputs

| Column Name | Data Type | Business Description | PII Classification |
|-------------|-----------|---------------------|-------------------|
| error_id | VARCHAR(50) | Unique identifier for each error record | Non-PII |
| process_execution_id | VARCHAR(50) | Reference to the process execution that generated error | Non-PII |
| error_timestamp | TIMESTAMP_NTZ(9) | Timestamp when error was detected | Non-PII |
| source_table_name | VARCHAR(200) | Name of source table where error originated | Non-PII |
| target_table_name | VARCHAR(200) | Name of target table being processed | Non-PII |
| source_record_identifier | VARCHAR(500) | Identifier of the source record with error | Non-PII |
| error_type | VARCHAR(100) | Type of error (VALIDATION, TRANSFORMATION, BUSINESS_RULE) | Non-PII |
| error_category | VARCHAR(100) | Category of error (DATA_TYPE, NULL_VALUE, RANGE, FORMAT) | Non-PII |
| error_severity | VARCHAR(50) | Severity level (CRITICAL, HIGH, MEDIUM, LOW) | Non-PII |
| error_code | VARCHAR(50) | Standardized error code for categorization | Non-PII |
| error_message | VARCHAR(1000) | Detailed error message description | Non-PII |
| column_name | VARCHAR(200) | Name of column where error was detected | Non-PII |
| invalid_value | VARCHAR(1000) | The value that caused the validation error | Potentially PII |
| expected_format | VARCHAR(500) | Expected format or range for the value | Non-PII |
| validation_rule_name | VARCHAR(200) | Name of validation rule that failed | Non-PII |
| validation_rule_expression | VARCHAR(1000) | Expression or logic of the validation rule | Non-PII |
| business_impact | VARCHAR(500) | Description of business impact of this error | Non-PII |
| resolution_status | VARCHAR(50) | Status of error resolution (OPEN, IN_PROGRESS, RESOLVED) | Non-PII |
| resolution_action | VARCHAR(500) | Action taken to resolve the error | Non-PII |
| resolved_by | VARCHAR(100) | User who resolved the error | Non-PII |
| resolution_timestamp | TIMESTAMP_NTZ(9) | Timestamp when error was resolved | Non-PII |
| resolution_notes | VARCHAR(1000) | Notes about error resolution | Non-PII |
| retry_count | NUMBER(5,0) | Number of times processing was retried | Non-PII |
| is_false_positive | BOOLEAN | Flag indicating if error was a false positive | Non-PII |
| load_date | DATE | Date when error record was created | Non-PII |
| update_date | DATE | Date when error record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

## 4. Conceptual Data Model Diagram

### Table Relationships and Key Fields

| Source Table | Target Table | Relationship Key Field | Relationship Type | Business Context |
|--------------|--------------|----------------------|-------------------|------------------|
| Go_Dim_Date | Go_Fact_Meeting_Activity | meeting_date | One-to-Many | Date dimension for meeting analysis |
| Go_Dim_User | Go_Fact_Meeting_Activity | host_user_context | One-to-Many | User hosting meetings |
| Go_Dim_Meeting | Go_Fact_Meeting_Activity | meeting_context | One-to-Many | Meeting characteristics |
| Go_Dim_Feature | Go_Fact_Meeting_Activity | feature_context | Many-to-Many | Features used in meetings |
| Go_Dim_Date | Go_Fact_Support_Activity | ticket_open_date | One-to-Many | Date dimension for support analysis |
| Go_Dim_User | Go_Fact_Support_Activity | user_context | One-to-Many | Users creating support tickets |
| Go_Dim_Date | Go_Fact_Revenue_Activity | transaction_date | One-to-Many | Date dimension for revenue analysis |
| Go_Dim_User | Go_Fact_Revenue_Activity | user_context | One-to-Many | Users generating revenue |
| Go_Dim_License | Go_Fact_Revenue_Activity | license_context | One-to-Many | License types for revenue |
| Go_Fact_Meeting_Activity | Go_Agg_Daily_Usage_Summary | meeting_date | Many-to-One | Aggregation of daily meeting metrics |
| Go_Fact_Revenue_Activity | Go_Agg_Monthly_Revenue_Summary | transaction_date | Many-to-One | Aggregation of monthly revenue |
| Go_Fact_Support_Activity | Go_Agg_Support_Performance_Summary | ticket_open_date | Many-to-One | Aggregation of support metrics |

## 5. ER Diagram Visualization

```
                           GOLD LAYER DIMENSIONAL MODEL
                                                                    
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│    Go_Dim_Date      │    │    Go_Dim_User     │    │   Go_Dim_Meeting    │
│                     │    │                     │    │                     │
│ • date_value        │    │ • user_name         │    │ • meeting_type      │
│ • year              │    │ • email_domain      │    │ • meeting_category  │
│ • quarter           │    │ • company           │    │ • duration_category │
│ • month             │    │ • plan_type         │    │ • participant_size  │
│ • day_of_week       │    │ • plan_category     │    │ • time_of_day       │
│ • is_weekend        │    │ • registration_date │    │ • is_recurring      │
│ • fiscal_year       │    │ • effective_dates   │    │ • quality_score     │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
           │                           │                           │
           │                           │                           │
           └─────────────┐             │             ┌─────────────┘
                         │             │             │
                         ▼             ▼             ▼
                    ┌─────────────────────────────────────────┐
                    │        Go_Fact_Meeting_Activity         │
                    │                                         │
                    │ • meeting_date                          │
                    │ • meeting_topic                         │
                    │ • start_time / end_time                 │
                    │ • duration_minutes                      │
                    │ • participant_count                     │
                    │ • total_join_time_minutes               │
                    │ • features_used_count                   │
                    │ • screen_share_usage_count              │
                    │ • recording_usage_count                 │
                    │ • chat_usage_count                      │
                    └─────────────────────────────────────────┘
                                         │
                                         │
                                         ▼
                    ┌─────────────────────────────────────────┐
                    │      Go_Agg_Daily_Usage_Summary         │
                    │                                         │
                    │ • summary_date                          │
                    │ • total_meetings                        │
                    │ • total_meeting_minutes                 │
                    │ • unique_hosts                          │
                    │ • unique_participants                   │
                    │ • average_meeting_duration              │
                    │ • peak_concurrent_meetings              │
                    │ • new_user_registrations                │
                    └─────────────────────────────────────────┘

┌─────────────────────┐                    ┌─────────────────────┐
│   Go_Dim_Feature    │                    │   Go_Dim_License    │
│                     │                    │                     │
│ • feature_name      │                    │ • license_type      │
│ • feature_category  │                    │ • license_category  │
│ • feature_type      │                    │ • license_tier      │
│ • complexity        │                    │ • max_participants  │
│ • is_premium        │                    │ • storage_limit_gb  │
│ • release_date      │                    │ • monthly_price     │
│ • usage_frequency   │                    │ • effective_dates   │
└─────────────────────┘                    └─────────────────────┘
           │                                           │
           │                                           │
           └─────────────┐                             │
                         │                             │
                         ▼                             ▼
                ┌─────────────────────┐    ┌─────────────────────┐
                │Go_Fact_Support_     │    │Go_Fact_Revenue_     │
                │Activity             │    │Activity             │
                │                     │    │                     │
                │ • ticket_open_date  │    │ • transaction_date  │
                │ • ticket_close_date │    │ • event_type        │
                │ • ticket_type       │    │ • amount            │
                │ • resolution_status │    │ • currency          │
                │ • priority_level    │    │ • payment_method    │
                │ • resolution_time   │    │ • subscription_rev  │
                │ • escalation_count  │    │ • one_time_revenue  │
                │ • satisfaction_score│    │ • net_revenue       │
                └─────────────────────┘    └─────────────────────┘
                         │                             │
                         │                             │
                         ▼                             ▼
                ┌─────────────────────┐    ┌─────────────────────┐
                │Go_Agg_Support_     │    │Go_Agg_Monthly_      │
                │Performance_Summary  │    │Revenue_Summary      │
                │                     │    │                     │
                │ • summary_date      │    │ • summary_month     │
                │ • total_tickets     │    │ • total_revenue     │
                │ • avg_resolution    │    │ • subscription_rev  │
                │ • first_contact_rate│    │ • net_revenue       │
                │ • satisfaction_avg  │    │ • new_customer_rev  │
                │ • sla_compliance    │    │ • churn_revenue     │
                │ • tickets_per_1000  │    │ • monthly_recurring │
                └─────────────────────┘    └─────────────────────┘

                    ┌─────────────────────────────────────────┐
                    │           AUDIT & ERROR LAYER           │
                    ├─────────────────────┬───────────────────┤
                    │ Go_Process_Audit_Log│Go_Data_Validation_│
                    │                     │Errors             │
                    │ • audit_log_id      │ • error_id        │
                    │ • process_name      │ • error_timestamp │
                    │ • execution_status  │ • error_type      │
                    │ • records_processed │ • error_severity  │
                    │ • data_quality_score│ • resolution_status│
                    │ • performance_metrics│ • business_impact │
                    └─────────────────────┴───────────────────┘
```

## 6. Key Design Decisions and Rationale

### 6.1 Dimensional Modeling Approach
**Decision**: Implemented star schema with Facts and Dimensions
**Rationale**: 
- Optimizes query performance for analytical workloads
- Provides intuitive structure for business users
- Enables efficient aggregations and drill-down analysis
- Supports standard BI tool integration

### 6.2 SCD Type Selection
**Decision**: 
- Type 2 for Go_Dim_User and Go_Dim_License (track historical changes)
- Type 1 for Go_Dim_Meeting and Go_Dim_Feature (overwrite changes)
**Rationale**:
- User and license changes need historical tracking for trend analysis
- Meeting and feature attributes are more static and don't require history
- Balances storage efficiency with analytical requirements

### 6.3 Aggregated Tables Strategy
**Decision**: Pre-calculated daily, monthly, and performance summary tables
**Rationale**:
- Improves query performance for common reporting scenarios
- Reduces computational load on fact tables
- Enables faster dashboard and report generation
- Supports real-time analytics requirements

### 6.4 Comprehensive Audit Framework
**Decision**: Dedicated audit and error tracking tables
**Rationale**:
- Supports operational monitoring and data governance
- Enables troubleshooting and process optimization
- Provides compliance audit trail
- Facilitates data quality improvement

### 6.5 PII Classification
**Decision**: Explicit PII classification for all columns
**Rationale**:
- Supports data privacy compliance (GDPR, CCPA)
- Enables appropriate security controls
- Facilitates data masking and anonymization
- Supports data governance requirements

## 7. Assumptions Made

1. **Business Requirements**: Assumed focus on usage analytics, support performance, and revenue analysis
2. **Data Volume**: Assumed moderate to high volume requiring aggregated tables for performance
3. **Update Frequency**: Assumed daily batch processing for most tables with some real-time requirements
4. **Historical Tracking**: Assumed need for historical analysis of user and license changes
5. **Reporting Tools**: Assumed integration with standard BI tools requiring dimensional model
6. **Data Governance**: Assumed enterprise-level data governance and compliance requirements
7. **Performance Requirements**: Assumed sub-second query response times for aggregated data
8. **Data Quality**: Assumed need for comprehensive data quality monitoring and error tracking

## 8. Summary

This Gold layer logical data model provides:

1. **3 Fact Tables**: Meeting Activity, Support Activity, and Revenue Activity for core business processes
2. **5 Dimension Tables**: User, Meeting, Feature, License, and Date dimensions for analytical context
3. **3 Aggregated Tables**: Daily usage, monthly revenue, and support performance summaries
4. **2 Audit/Error Tables**: Process audit log and data validation errors for operational excellence
5. **Dimensional Design**: Star schema optimized for analytical queries and BI tools
6. **SCD Implementation**: Type 1 and Type 2 slowly changing dimensions based on business requirements
7. **Comprehensive Metadata**: Load dates, update dates, and source system tracking
8. **PII Classification**: Explicit classification supporting data privacy compliance

The model supports all key reporting areas:
- **Platform Usage & Adoption**: Through meeting activity facts and usage aggregations
- **Service Reliability & Support**: Through support activity facts and performance summaries
- **Revenue & License Management**: Through revenue activity facts and monthly summaries

All tables follow the 'Go_' naming convention and are optimized for Snowflake's cloud data platform while maintaining comprehensive audit trails and data quality monitoring capabilities.
