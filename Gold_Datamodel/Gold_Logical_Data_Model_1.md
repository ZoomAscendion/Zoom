_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Logical Data Model for Zoom Platform Analytics System following medallion architecture with dimensional modeling for analytics and reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Gold Logical Data Model - Zoom Platform Analytics System

## 1. Gold Layer Logical Model

### 1.1 FACT TABLES

#### 1.1.1 Go_Meeting_Activity_Fact
**Table Type**: Fact
**Description**: Central fact table capturing meeting activities and metrics for platform usage analysis

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| meeting_date | DATE | Date when the meeting occurred | Non-PII |
| meeting_duration_minutes | INTEGER | Total duration of the meeting in minutes | Non-PII |
| participant_count | INTEGER | Number of participants who joined the meeting | Non-PII |
| host_plan_type | VARCHAR(50) | Subscription plan type of the meeting host | Non-PII |
| meeting_type | VARCHAR(50) | Type of meeting (Scheduled, Instant, Webinar, Personal) | Non-PII |
| recording_enabled | BOOLEAN | Whether the meeting was recorded | Non-PII |
| feature_usage_count | INTEGER | Total number of features used during the meeting | Non-PII |
| total_attendance_minutes | INTEGER | Sum of all participant attendance durations | Non-PII |
| average_connection_quality_score | DECIMAL(3,2) | Average connection quality across all participants | Non-PII |
| meeting_completion_status | VARCHAR(20) | Whether meeting completed successfully | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.1.2 Go_Support_Ticket_Fact
**Table Type**: Fact
**Description**: Fact table capturing support ticket metrics and resolution performance

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| ticket_date | DATE | Date when the support ticket was created | Non-PII |
| ticket_type | VARCHAR(50) | Category of support ticket | Non-PII |
| priority_level | VARCHAR(20) | Urgency level of the ticket | Non-PII |
| resolution_time_hours | INTEGER | Time taken to resolve ticket in business hours | Non-PII |
| customer_plan_type | VARCHAR(50) | Plan type of the customer who created ticket | Non-PII |
| first_contact_resolution | BOOLEAN | Whether ticket was resolved on first contact | Non-PII |
| escalation_required | BOOLEAN | Whether ticket required escalation | Non-PII |
| customer_satisfaction_score | INTEGER | Customer satisfaction rating (1-5) | Non-PII |
| resolution_status | VARCHAR(20) | Final status of the ticket | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.1.3 Go_Revenue_Fact
**Table Type**: Fact
**Description**: Fact table capturing billing events and revenue metrics

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| transaction_date | DATE | Date when the billing transaction occurred | Non-PII |
| transaction_amount | DECIMAL(10,2) | Monetary value of the transaction | Non-PII |
| transaction_type | VARCHAR(50) | Type of billing event | Non-PII |
| customer_plan_type | VARCHAR(50) | Plan type associated with the transaction | Non-PII |
| payment_method | VARCHAR(50) | Method used for payment | Non-PII |
| currency_code | VARCHAR(3) | ISO currency code | Non-PII |
| license_count | INTEGER | Number of licenses involved in transaction | Non-PII |
| is_recurring_revenue | BOOLEAN | Whether transaction represents recurring revenue | Non-PII |
| customer_tenure_months | INTEGER | Number of months customer has been active | Non-PII |
| transaction_status | VARCHAR(20) | Status of the transaction | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.1.4 Go_Feature_Usage_Fact
**Table Type**: Fact
**Description**: Fact table capturing detailed feature usage patterns and adoption metrics

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| usage_date | DATE | Date when feature usage occurred | Non-PII |
| feature_name | VARCHAR(100) | Name of the feature used | Non-PII |
| feature_category | VARCHAR(50) | Category of the feature | Non-PII |
| usage_count | INTEGER | Number of times feature was used | Non-PII |
| usage_duration_minutes | INTEGER | Total duration feature was active | Non-PII |
| user_plan_type | VARCHAR(50) | Plan type of the user using the feature | Non-PII |
| meeting_type | VARCHAR(50) | Type of meeting where feature was used | Non-PII |
| user_tenure_days | INTEGER | Number of days since user registration | Non-PII |
| is_first_time_usage | BOOLEAN | Whether this is user's first time using the feature | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 1.2 DIMENSION TABLES

#### 1.2.1 Go_User_Dimension
**Table Type**: Dimension
**SCD Type**: Type 2
**Description**: Slowly changing dimension containing user profile information with historical tracking

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| user_name | VARCHAR(255) | Full name of the user | PII - Direct Identifier |
| email_domain | VARCHAR(100) | Domain portion of user email address | Non-PII |
| company_name | VARCHAR(255) | Organization name | PII - Quasi Identifier |
| plan_type | VARCHAR(50) | Current subscription plan | Non-PII |
| account_status | VARCHAR(20) | Current account status | Non-PII |
| registration_date | DATE | Date when user registered | Non-PII |
| user_segment | VARCHAR(50) | Business segment classification | Non-PII |
| geographic_region | VARCHAR(100) | Geographic region of the user | Non-PII |
| company_size_category | VARCHAR(50) | Size category of user's company | Non-PII |
| effective_start_date | DATE | Start date for this version of the record | Non-PII |
| effective_end_date | DATE | End date for this version of the record | Non-PII |
| is_current_record | BOOLEAN | Whether this is the current active record | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.2 Go_Date_Dimension
**Table Type**: Dimension
**SCD Type**: Type 1
**Description**: Date dimension providing comprehensive date attributes for time-based analysis

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| date_key | DATE | Primary date value | Non-PII |
| year | INTEGER | Year component | Non-PII |
| quarter | INTEGER | Quarter number (1-4) | Non-PII |
| month | INTEGER | Month number (1-12) | Non-PII |
| month_name | VARCHAR(20) | Full month name | Non-PII |
| week_of_year | INTEGER | Week number in the year | Non-PII |
| day_of_month | INTEGER | Day of the month | Non-PII |
| day_of_week | INTEGER | Day of the week (1-7) | Non-PII |
| day_name | VARCHAR(20) | Full day name | Non-PII |
| is_weekend | BOOLEAN | Whether the date falls on weekend | Non-PII |
| is_holiday | BOOLEAN | Whether the date is a business holiday | Non-PII |
| fiscal_year | INTEGER | Fiscal year | Non-PII |
| fiscal_quarter | INTEGER | Fiscal quarter | Non-PII |
| business_day_flag | BOOLEAN | Whether the date is a business day | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.3 Go_Plan_Dimension
**Table Type**: Dimension
**SCD Type**: Type 1
**Description**: Dimension containing subscription plan details and features

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| plan_type | VARCHAR(50) | Plan type identifier | Non-PII |
| plan_name | VARCHAR(100) | Descriptive plan name | Non-PII |
| plan_category | VARCHAR(50) | Plan category (Free, Paid, Enterprise) | Non-PII |
| max_participants | INTEGER | Maximum participants allowed | Non-PII |
| meeting_duration_limit | INTEGER | Maximum meeting duration in minutes | Non-PII |
| recording_enabled | BOOLEAN | Whether recording is available | Non-PII |
| cloud_storage_gb | INTEGER | Cloud storage allocation in GB | Non-PII |
| admin_features_enabled | BOOLEAN | Whether admin features are available | Non-PII |
| api_access_enabled | BOOLEAN | Whether API access is included | Non-PII |
| support_level | VARCHAR(50) | Level of customer support provided | Non-PII |
| monthly_price | DECIMAL(10,2) | Monthly subscription price | Non-PII |
| annual_price | DECIMAL(10,2) | Annual subscription price | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.4 Go_Feature_Dimension
**Table Type**: Dimension
**SCD Type**: Type 1
**Description**: Dimension containing feature definitions and categorizations

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| feature_name | VARCHAR(100) | Name of the feature | Non-PII |
| feature_category | VARCHAR(50) | Category classification | Non-PII |
| feature_subcategory | VARCHAR(50) | Subcategory classification | Non-PII |
| feature_description | TEXT | Detailed description of the feature | Non-PII |
| availability_by_plan | VARCHAR(200) | Plans that include this feature | Non-PII |
| is_premium_feature | BOOLEAN | Whether feature requires premium plan | Non-PII |
| release_date | DATE | Date when feature was released | Non-PII |
| deprecation_date | DATE | Date when feature was deprecated | Non-PII |
| usage_complexity | VARCHAR(20) | Complexity level (Simple, Moderate, Advanced) | Non-PII |
| business_impact | VARCHAR(50) | Business impact category | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 1.3 PROCESS AUDIT TABLES

#### 1.3.1 Go_Pipeline_Execution_Audit
**Table Type**: Audit
**Description**: Comprehensive audit table for tracking Gold layer pipeline execution details

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| execution_id | VARCHAR(50) | Unique identifier for pipeline execution | Non-PII |
| pipeline_name | VARCHAR(200) | Name of the executed pipeline | Non-PII |
| execution_start_time | TIMESTAMP_NTZ(9) | Pipeline execution start timestamp | Non-PII |
| execution_end_time | TIMESTAMP_NTZ(9) | Pipeline execution end timestamp | Non-PII |
| execution_duration_seconds | INTEGER | Total execution time in seconds | Non-PII |
| execution_status | VARCHAR(20) | Status (Success, Failed, Partial Success) | Non-PII |
| source_tables_processed | TEXT | List of source tables processed | Non-PII |
| target_tables_updated | TEXT | List of target tables updated | Non-PII |
| records_processed | INTEGER | Total number of records processed | Non-PII |
| records_inserted | INTEGER | Number of new records inserted | Non-PII |
| records_updated | INTEGER | Number of existing records updated | Non-PII |
| records_rejected | INTEGER | Number of records rejected | Non-PII |
| data_quality_score | DECIMAL(5,2) | Overall data quality score for execution | Non-PII |
| error_message | TEXT | Error details if execution failed | Non-PII |
| executed_by | VARCHAR(100) | User or system that executed pipeline | Non-PII |
| execution_environment | VARCHAR(50) | Environment (Dev, Test, Prod) | Non-PII |
| resource_utilization | TEXT | CPU, memory, and storage utilization metrics | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 1.4 ERROR DATA TABLES

#### 1.4.1 Go_Data_Validation_Errors
**Table Type**: Error Data
**Description**: Table storing data validation errors and quality issues from Gold layer processing

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| error_id | VARCHAR(50) | Unique identifier for each error | Non-PII |
| source_table | VARCHAR(100) | Source table where error was detected | Non-PII |
| target_table | VARCHAR(100) | Target table being processed | Non-PII |
| error_type | VARCHAR(50) | Type of validation error | Non-PII |
| error_category | VARCHAR(50) | Category of error (Data Quality, Business Rule, Technical) | Non-PII |
| error_severity | VARCHAR(20) | Severity level (Critical, High, Medium, Low) | Non-PII |
| error_description | TEXT | Detailed description of the error | Non-PII |
| affected_column | VARCHAR(100) | Column where error was detected | Non-PII |
| error_value | TEXT | Value that caused the error | Potentially PII |
| expected_value_pattern | TEXT | Expected value pattern or range | Non-PII |
| business_rule_violated | VARCHAR(200) | Business rule that was violated | Non-PII |
| detection_timestamp | TIMESTAMP_NTZ(9) | When error was detected | Non-PII |
| resolution_status | VARCHAR(20) | Status of error resolution | Non-PII |
| resolution_action | TEXT | Action taken to resolve error | Non-PII |
| resolved_timestamp | TIMESTAMP_NTZ(9) | When error was resolved | Non-PII |
| resolved_by | VARCHAR(100) | Who resolved the error | Non-PII |
| impact_assessment | TEXT | Assessment of error impact on business | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 1.5 AGGREGATED TABLES

#### 1.5.1 Go_Daily_Usage_Summary
**Table Type**: Aggregated
**Description**: Daily aggregated metrics for platform usage and adoption analysis

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| summary_date | DATE | Date for which metrics are aggregated | Non-PII |
| total_meetings | INTEGER | Total number of meetings conducted | Non-PII |
| total_participants | INTEGER | Total number of unique participants | Non-PII |
| total_meeting_minutes | INTEGER | Sum of all meeting durations | Non-PII |
| average_meeting_duration | DECIMAL(10,2) | Average meeting duration in minutes | Non-PII |
| daily_active_users | INTEGER | Number of unique active users | Non-PII |
| new_user_registrations | INTEGER | Number of new user sign-ups | Non-PII |
| meetings_by_plan_free | INTEGER | Meetings hosted by Free plan users | Non-PII |
| meetings_by_plan_basic | INTEGER | Meetings hosted by Basic plan users | Non-PII |
| meetings_by_plan_pro | INTEGER | Meetings hosted by Pro plan users | Non-PII |
| meetings_by_plan_enterprise | INTEGER | Meetings hosted by Enterprise plan users | Non-PII |
| recorded_meetings_count | INTEGER | Number of meetings that were recorded | Non-PII |
| webinar_count | INTEGER | Number of webinars conducted | Non-PII |
| total_feature_usage_events | INTEGER | Total feature usage events | Non-PII |
| unique_features_used | INTEGER | Number of unique features used | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.5.2 Go_Monthly_Revenue_Summary
**Table Type**: Aggregated
**Description**: Monthly aggregated revenue and billing metrics

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| summary_month | DATE | Month for which metrics are aggregated | Non-PII |
| total_revenue | DECIMAL(15,2) | Total revenue for the month | Non-PII |
| recurring_revenue | DECIMAL(15,2) | Monthly recurring revenue | Non-PII |
| one_time_revenue | DECIMAL(15,2) | One-time charges and fees | Non-PII |
| new_customer_revenue | DECIMAL(15,2) | Revenue from new customers | Non-PII |
| expansion_revenue | DECIMAL(15,2) | Revenue from plan upgrades | Non-PII |
| churn_revenue_lost | DECIMAL(15,2) | Revenue lost due to churn | Non-PII |
| refund_amount | DECIMAL(15,2) | Total refunds processed | Non-PII |
| active_licenses | INTEGER | Number of active licenses | Non-PII |
| new_licenses_sold | INTEGER | Number of new licenses sold | Non-PII |
| licenses_cancelled | INTEGER | Number of licenses cancelled | Non-PII |
| average_revenue_per_user | DECIMAL(10,2) | Average revenue per user | Non-PII |
| customer_acquisition_cost | DECIMAL(10,2) | Cost to acquire new customers | Non-PII |
| customer_lifetime_value | DECIMAL(15,2) | Average customer lifetime value | Non-PII |
| churn_rate_percentage | DECIMAL(5,2) | Customer churn rate | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.5.3 Go_Weekly_Support_Summary
**Table Type**: Aggregated
**Description**: Weekly aggregated support ticket metrics and performance indicators

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| summary_week | DATE | Week start date for aggregated metrics | Non-PII |
| total_tickets_created | INTEGER | Total number of tickets created | Non-PII |
| total_tickets_resolved | INTEGER | Total number of tickets resolved | Non-PII |
| tickets_by_type_technical | INTEGER | Technical support tickets | Non-PII |
| tickets_by_type_billing | INTEGER | Billing-related tickets | Non-PII |
| tickets_by_type_feature | INTEGER | Feature request tickets | Non-PII |
| tickets_by_type_bug | INTEGER | Bug report tickets | Non-PII |
| tickets_by_priority_critical | INTEGER | Critical priority tickets | Non-PII |
| tickets_by_priority_high | INTEGER | High priority tickets | Non-PII |
| tickets_by_priority_medium | INTEGER | Medium priority tickets | Non-PII |
| tickets_by_priority_low | INTEGER | Low priority tickets | Non-PII |
| average_resolution_time_hours | DECIMAL(10,2) | Average time to resolve tickets | Non-PII |
| first_contact_resolution_rate | DECIMAL(5,2) | Percentage resolved on first contact | Non-PII |
| escalation_rate | DECIMAL(5,2) | Percentage of tickets escalated | Non-PII |
| customer_satisfaction_avg | DECIMAL(3,2) | Average customer satisfaction score | Non-PII |
| tickets_per_1000_users | DECIMAL(10,2) | Ticket density per 1000 active users | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

## 2. Conceptual Data Model Diagram

### 2.1 Table Relationships and Key Fields

| Source Table | Target Table | Relationship Key Field | Relationship Type | Description |
|--------------|--------------|----------------------|-------------------|-------------|
| Go_User_Dimension | Go_Meeting_Activity_Fact | user_name | One-to-Many | Users can host multiple meetings |
| Go_Date_Dimension | Go_Meeting_Activity_Fact | meeting_date | One-to-Many | Each date can have multiple meetings |
| Go_Plan_Dimension | Go_Meeting_Activity_Fact | host_plan_type | One-to-Many | Each plan type can have multiple meetings |
| Go_User_Dimension | Go_Support_Ticket_Fact | user_name | One-to-Many | Users can create multiple support tickets |
| Go_Date_Dimension | Go_Support_Ticket_Fact | ticket_date | One-to-Many | Each date can have multiple tickets |
| Go_Plan_Dimension | Go_Support_Ticket_Fact | customer_plan_type | One-to-Many | Each plan can have multiple support tickets |
| Go_User_Dimension | Go_Revenue_Fact | user_name | One-to-Many | Users can have multiple billing transactions |
| Go_Date_Dimension | Go_Revenue_Fact | transaction_date | One-to-Many | Each date can have multiple transactions |
| Go_Plan_Dimension | Go_Revenue_Fact | customer_plan_type | One-to-Many | Each plan can have multiple transactions |
| Go_Feature_Dimension | Go_Feature_Usage_Fact | feature_name | One-to-Many | Each feature can have multiple usage events |
| Go_Date_Dimension | Go_Feature_Usage_Fact | usage_date | One-to-Many | Each date can have multiple feature usage events |
| Go_User_Dimension | Go_Feature_Usage_Fact | user_name | One-to-Many | Users can have multiple feature usage events |
| Go_Date_Dimension | Go_Daily_Usage_Summary | summary_date | One-to-One | Each date has one daily summary |
| Go_Date_Dimension | Go_Monthly_Revenue_Summary | summary_month | One-to-One | Each month has one revenue summary |
| Go_Date_Dimension | Go_Weekly_Support_Summary | summary_week | One-to-One | Each week has one support summary |

## 3. ER Diagram Visualization

### 3.1 Gold Layer Entity Relationship Diagram

```
                    DIMENSIONS                           FACTS                        AGGREGATED TABLES
    
┌─────────────────────┐                    ┌─────────────────────┐              ┌─────────────────────┐
│   Go_Date_Dimension │◄──────────────────►│Go_Meeting_Activity_ │              │ Go_Daily_Usage_     │
│                     │                    │       Fact          │              │     Summary         │
│ • date_key          │                    │                     │              │                     │
│ • year              │                    │ • meeting_date      │              │ • summary_date      │
│ • quarter           │                    │ • duration_minutes  │              │ • total_meetings    │
│ • month             │                    │ • participant_count │              │ • daily_active_users│
│ • day_name          │                    │ • host_plan_type    │              │ • total_minutes     │
└─────────────────────┘                    └─────────────────────┘              └─────────────────────┘
         │                                           │                                       │
         │                                           │                                       │
         ▼                                           ▼                                       ▼
┌─────────────────────┐                    ┌─────────────────────┐              ┌─────────────────────┐
│  Go_User_Dimension  │◄──────────────────►│ Go_Support_Ticket_  │              │Go_Weekly_Support_   │
│                     │                    │       Fact          │              │     Summary         │
│ • user_name         │                    │                     │              │                     │
│ • email_domain      │                    │ • ticket_date       │              │ • summary_week      │
│ • company_name      │                    │ • resolution_hours  │              │ • total_tickets     │
│ • plan_type         │                    │ • priority_level    │              │ • avg_resolution    │
│ • account_status    │                    │ • customer_plan     │              │ • satisfaction_avg  │
└─────────────────────┘                    └─────────────────────┘              └─────────────────────┘
         │                                           │                                       │
         │                                           │                                       │
         ▼                                           ▼                                       ▼
┌─────────────────────┐                    ┌─────────────────────┐              ┌─────────────────────┐
│  Go_Plan_Dimension  │◄──────────────────►│   Go_Revenue_Fact   │              │Go_Monthly_Revenue_  │
│                     │                    │                     │              │     Summary         │
│ • plan_type         │                    │ • transaction_date  │              │                     │
│ • plan_name         │                    │ • transaction_amount│              │ • summary_month     │
│ • max_participants  │                    │ • transaction_type  │              │ • total_revenue     │
│ • monthly_price     │                    │ • customer_plan     │              │ • recurring_revenue │
│ • support_level     │                    │ • license_count     │              │ • churn_rate        │
└─────────────────────┘                    └─────────────────────┘              └─────────────────────┘
         │                                           │                                       │
         │                                           │                                       │
         ▼                                           ▼                                       ▼
┌─────────────────────┐                    ┌─────────────────────┐              ┌─────────────────────┐
│Go_Feature_Dimension │◄──────────────────►│Go_Feature_Usage_    │              │                     │
│                     │                    │       Fact          │              │   AUDIT & ERROR     │
│ • feature_name      │                    │                     │              │      TABLES         │
│ • feature_category  │                    │ • usage_date        │              │                     │
│ • feature_desc      │                    │ • feature_name      │              │                     │
│ • is_premium        │                    │ • usage_count       │              │                     │
│ • release_date      │                    │ • usage_duration    │              │                     │
└─────────────────────┘                    └─────────────────────┘              └─────────────────────┘
                                                    │                                       │
                                                    │                                       │
                                                    ▼                                       ▼
                                          ┌─────────────────────┐              ┌─────────────────────┐
                                          │Go_Pipeline_Execution│              │Go_Data_Validation_  │
                                          │      _Audit         │              │      Errors         │
                                          │                     │              │                     │
                                          │ • execution_id      │              │ • error_id          │
                                          │ • pipeline_name     │              │ • source_table      │
                                          │ • start_time        │              │ • error_type        │
                                          │ • records_processed │              │ • error_severity    │
                                          │ • execution_status  │              │ • resolution_status │
                                          └─────────────────────┘              └─────────────────────┘
```

### 3.2 Design Rationale and Key Decisions

1. **Dimensional Modeling Approach**: 
   - Implemented star schema design with fact tables at the center and dimension tables providing context
   - Separated transactional data (facts) from descriptive data (dimensions) for optimal query performance
   - Used consistent naming convention with 'Go_' prefix for all Gold layer tables

2. **Slowly Changing Dimensions**:
   - Go_User_Dimension uses SCD Type 2 to track historical changes in user profiles
   - Other dimensions use SCD Type 1 for simpler maintenance where historical tracking is not critical

3. **Fact Table Design**:
   - Created separate fact tables for different business processes (meetings, support, revenue, features)
   - Included both additive measures (counts, amounts) and semi-additive measures (averages, percentages)
   - Added derived metrics to support common analytical queries

4. **Aggregated Tables**:
   - Pre-calculated common metrics at different time grains (daily, weekly, monthly)
   - Designed to support dashboard and reporting requirements efficiently
   - Included KPIs identified in the conceptual model

5. **Data Quality and Audit**:
   - Comprehensive audit table to track all pipeline executions
   - Error tracking table to manage data quality issues
   - Metadata columns in all tables for data lineage and governance

6. **PII Classification**:
   - Classified all columns according to GDPR and privacy standards
   - Minimized PII exposure in analytical tables
   - Used derived fields (e.g., email_domain instead of full email) where possible

This Gold layer logical data model provides a robust foundation for analytics and reporting while ensuring data quality, governance, and performance optimization for the Zoom Platform Analytics System.