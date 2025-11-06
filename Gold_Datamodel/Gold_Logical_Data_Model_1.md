_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold layer logical data model for Zoom Platform Analytics System supporting dimensional modeling for analytics and reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Gold Layer Logical Data Model

## 1. Gold Layer Logical Model

### 1.1 Go_Fact_Meeting_Activity
**Description:** Central fact table capturing meeting activities with metrics for platform usage analysis and reporting.
**Table Type:** Fact
**SCD Type:** N/A

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| meeting_date | DATE | Date when the meeting occurred for time-based analysis | Non-PII |
| host_user_key | VARCHAR(16777216) | Business key reference to the meeting host user | Non-PII |
| meeting_topic | VARCHAR(16777216) | Subject or topic of the meeting for categorization | Non-PII |
| start_time | TIMESTAMP_NTZ(9) | Meeting start timestamp for temporal analysis | Non-PII |
| end_time | TIMESTAMP_NTZ(9) | Meeting end timestamp for duration calculations | Non-PII |
| duration_minutes | NUMBER(38,0) | Total meeting duration in minutes for usage metrics | Non-PII |
| participant_count | NUMBER(38,0) | Total number of participants in the meeting | Non-PII |
| total_attendance_minutes | NUMBER(38,0) | Sum of all participant attendance durations | Non-PII |
| average_attendance_minutes | NUMBER(10,2) | Average attendance duration per participant | Non-PII |
| feature_usage_count | NUMBER(38,0) | Total number of features used during the meeting | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.2 Go_Fact_Support_Activity
**Description:** Fact table capturing support ticket activities and resolution metrics for service reliability analysis.
**Table Type:** Fact
**SCD Type:** N/A

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| ticket_date | DATE | Date when the support ticket was opened | Non-PII |
| user_key | VARCHAR(16777216) | Business key reference to the user who opened the ticket | Non-PII |
| ticket_type | VARCHAR(16777216) | Category of the support ticket for classification | Non-PII |
| resolution_status | VARCHAR(16777216) | Current status of the ticket resolution | Non-PII |
| open_date | DATE | Date when the support ticket was created | Non-PII |
| resolution_time_hours | NUMBER(10,2) | Time taken to resolve the ticket in hours | Non-PII |
| priority_level | VARCHAR(50) | Priority level assigned to the support ticket | Non-PII |
| first_contact_resolution_flag | BOOLEAN | Flag indicating if ticket was resolved on first contact | Non-PII |
| escalation_flag | BOOLEAN | Flag indicating if ticket required escalation | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.3 Go_Fact_Revenue_Activity
**Description:** Fact table capturing billing events and revenue metrics for financial analysis and reporting.
**Table Type:** Fact
**SCD Type:** N/A

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| event_date | DATE | Date when the billing event occurred | Non-PII |
| user_key | VARCHAR(16777216) | Business key reference to the user associated with the billing event | Non-PII |
| event_type | VARCHAR(16777216) | Type of billing event for categorization | Non-PII |
| amount | NUMBER(10,2) | Monetary amount of the billing event | Non-PII |
| currency_code | VARCHAR(3) | Currency code for the billing amount | Non-PII |
| payment_method | VARCHAR(100) | Method used for payment processing | Non-PII |
| recurring_revenue_flag | BOOLEAN | Flag indicating if this is recurring revenue | Non-PII |
| churn_risk_score | NUMBER(3,2) | Calculated risk score for customer churn | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.4 Go_Dim_User
**Description:** Dimension table containing user information with slowly changing dimension tracking for user analysis.
**Table Type:** Dimension
**SCD Type:** Type 2

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| user_key | VARCHAR(16777216) | Business key for the user dimension | Non-PII |
| user_name | VARCHAR(16777216) | Display name of the user account | PII |
| email_domain | VARCHAR(16777216) | Domain portion of user email for analysis | Non-PII |
| company | VARCHAR(16777216) | Organization or company the user is affiliated with | Non-PII |
| plan_type | VARCHAR(16777216) | Current subscription plan type of the user | Non-PII |
| user_category | VARCHAR(100) | Categorization of user based on usage patterns | Non-PII |
| account_creation_date | DATE | Date when the user account was created | Non-PII |
| last_activity_date | DATE | Date of user's last platform activity | Non-PII |
| effective_start_date | DATE | Start date for this version of the dimension record | Non-PII |
| effective_end_date | DATE | End date for this version of the dimension record | Non-PII |
| current_record_flag | BOOLEAN | Flag indicating if this is the current version | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.5 Go_Dim_Date
**Description:** Date dimension table providing comprehensive date attributes for time-based analysis and reporting.
**Table Type:** Dimension
**SCD Type:** Type 1

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| date_key | DATE | Primary date value for the dimension | Non-PII |
| year | NUMBER(4,0) | Year component of the date | Non-PII |
| quarter | NUMBER(1,0) | Quarter component of the date | Non-PII |
| month | NUMBER(2,0) | Month component of the date | Non-PII |
| month_name | VARCHAR(20) | Full name of the month | Non-PII |
| week_of_year | NUMBER(2,0) | Week number within the year | Non-PII |
| day_of_month | NUMBER(2,0) | Day component of the date | Non-PII |
| day_of_week | NUMBER(1,0) | Day of week (1=Sunday, 7=Saturday) | Non-PII |
| day_name | VARCHAR(20) | Full name of the day | Non-PII |
| is_weekend | BOOLEAN | Flag indicating if the date is a weekend | Non-PII |
| is_holiday | BOOLEAN | Flag indicating if the date is a holiday | Non-PII |
| fiscal_year | NUMBER(4,0) | Fiscal year for business reporting | Non-PII |
| fiscal_quarter | NUMBER(1,0) | Fiscal quarter for business reporting | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.6 Go_Dim_License
**Description:** Dimension table containing license information with historical tracking for license management analysis.
**Table Type:** Dimension
**SCD Type:** Type 2

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| license_key | VARCHAR(16777216) | Business key for the license dimension | Non-PII |
| license_type | VARCHAR(16777216) | Type of Zoom license assigned | Non-PII |
| license_tier | VARCHAR(100) | Tier classification of the license | Non-PII |
| start_date | DATE | Date when the license becomes active | Non-PII |
| end_date | DATE | Date when the license expires | Non-PII |
| license_status | VARCHAR(50) | Current status of the license | Non-PII |
| days_to_expiry | NUMBER(38,0) | Number of days until license expiration | Non-PII |
| license_cost | NUMBER(10,2) | Cost associated with the license | Non-PII |
| utilization_rate | NUMBER(5,2) | Percentage utilization of the license | Non-PII |
| effective_start_date | DATE | Start date for this version of the dimension record | Non-PII |
| effective_end_date | DATE | End date for this version of the dimension record | Non-PII |
| current_record_flag | BOOLEAN | Flag indicating if this is the current version | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.7 Go_Code_Feature_Types
**Description:** Code table containing standardized feature types and categories for feature usage analysis.
**Table Type:** Code Table
**SCD Type:** Type 1

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| feature_code | VARCHAR(50) | Unique code for the feature type | Non-PII |
| feature_name | VARCHAR(16777216) | Standardized name of the Zoom feature | Non-PII |
| feature_category | VARCHAR(100) | Category classification of the feature | Non-PII |
| feature_description | VARCHAR(16777216) | Detailed description of the feature functionality | Non-PII |
| is_premium_feature | BOOLEAN | Flag indicating if feature requires premium license | Non-PII |
| adoption_priority | VARCHAR(50) | Priority level for feature adoption tracking | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.8 Go_Code_Plan_Types
**Description:** Code table containing standardized plan types and subscription tiers for user categorization.
**Table Type:** Code Table
**SCD Type:** Type 1

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| plan_code | VARCHAR(50) | Unique code for the plan type | Non-PII |
| plan_name | VARCHAR(16777216) | Standardized name of the subscription plan | Non-PII |
| plan_tier | VARCHAR(100) | Tier classification of the plan | Non-PII |
| plan_description | VARCHAR(16777216) | Detailed description of plan features and limits | Non-PII |
| monthly_cost | NUMBER(10,2) | Monthly cost of the subscription plan | Non-PII |
| max_participants | NUMBER(38,0) | Maximum number of participants allowed | Non-PII |
| feature_set | VARCHAR(16777216) | JSON string containing available features | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.9 Go_Agg_Daily_Usage_Summary
**Description:** Aggregated table providing daily usage metrics for platform adoption and performance analysis.
**Table Type:** Aggregated
**SCD Type:** N/A

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| summary_date | DATE | Date for which the usage summary is calculated | Non-PII |
| plan_type | VARCHAR(16777216) | Subscription plan type for segmented analysis | Non-PII |
| total_meetings | NUMBER(38,0) | Total number of meetings conducted | Non-PII |
| total_participants | NUMBER(38,0) | Total number of participants across all meetings | Non-PII |
| total_meeting_minutes | NUMBER(38,0) | Total duration of all meetings in minutes | Non-PII |
| average_meeting_duration | NUMBER(10,2) | Average duration per meeting in minutes | Non-PII |
| unique_hosts | NUMBER(38,0) | Number of unique users who hosted meetings | Non-PII |
| unique_attendees | NUMBER(38,0) | Number of unique users who attended meetings | Non-PII |
| feature_usage_events | NUMBER(38,0) | Total number of feature usage events | Non-PII |
| most_used_feature | VARCHAR(16777216) | Most frequently used feature for the day | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.10 Go_Agg_Monthly_Revenue_Summary
**Description:** Aggregated table providing monthly revenue metrics for financial analysis and business reporting.
**Table Type:** Aggregated
**SCD Type:** N/A

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| summary_month | DATE | Month for which the revenue summary is calculated | Non-PII |
| plan_type | VARCHAR(16777216) | Subscription plan type for revenue segmentation | Non-PII |
| total_revenue | NUMBER(12,2) | Total revenue generated for the month | Non-PII |
| recurring_revenue | NUMBER(12,2) | Monthly recurring revenue (MRR) component | Non-PII |
| one_time_revenue | NUMBER(12,2) | One-time revenue component | Non-PII |
| refunds_amount | NUMBER(12,2) | Total refunds processed | Non-PII |
| net_revenue | NUMBER(12,2) | Net revenue after refunds and adjustments | Non-PII |
| active_subscribers | NUMBER(38,0) | Number of active subscribers | Non-PII |
| new_subscribers | NUMBER(38,0) | Number of new subscribers acquired | Non-PII |
| churned_subscribers | NUMBER(38,0) | Number of subscribers who churned | Non-PII |
| average_revenue_per_user | NUMBER(10,2) | Average revenue per user (ARPU) | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.11 Go_Process_Audit
**Description:** Audit table capturing pipeline execution details and performance metrics for Gold layer processing.
**Table Type:** Audit
**SCD Type:** N/A

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| audit_key | VARCHAR(16777216) | Unique identifier for each audit record | Non-PII |
| pipeline_name | VARCHAR(16777216) | Name of the data pipeline executed | Non-PII |
| pipeline_run_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the pipeline run started | Non-PII |
| source_table | VARCHAR(16777216) | Name of the source Silver layer table | Non-PII |
| target_table | VARCHAR(16777216) | Name of the target Gold layer table | Non-PII |
| execution_start_time | TIMESTAMP_NTZ(9) | Pipeline execution start timestamp | Non-PII |
| execution_end_time | TIMESTAMP_NTZ(9) | Pipeline execution end timestamp | Non-PII |
| execution_duration_seconds | NUMBER(10,2) | Total execution time in seconds | Non-PII |
| records_read | NUMBER(38,0) | Number of records read from source | Non-PII |
| records_processed | NUMBER(38,0) | Number of records successfully processed | Non-PII |
| records_inserted | NUMBER(38,0) | Number of records inserted into target | Non-PII |
| records_updated | NUMBER(38,0) | Number of records updated in target | Non-PII |
| records_rejected | NUMBER(38,0) | Number of records rejected due to validation | Non-PII |
| execution_status | VARCHAR(50) | Overall status of pipeline execution | Non-PII |
| error_message | VARCHAR(16777216) | Detailed error message if execution failed | Non-PII |
| processed_by | VARCHAR(16777216) | System or user that executed the pipeline | Non-PII |
| data_freshness_timestamp | TIMESTAMP_NTZ(9) | Timestamp of most recent data processed | Non-PII |
| load_date | DATE | Date when audit record was created | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

### 1.12 Go_Error_Data
**Description:** Error data table capturing data validation failures and quality issues during Gold layer processing.
**Table Type:** Error Data
**SCD Type:** N/A

| **Column Name** | **Data Type** | **Description** | **PII Classification** |
|-----------------|---------------|-----------------|------------------------|
| error_key | VARCHAR(16777216) | Unique identifier for each error record | Non-PII |
| pipeline_run_timestamp | TIMESTAMP_NTZ(9) | Timestamp of the pipeline run that detected the error | Non-PII |
| source_table | VARCHAR(16777216) | Name of the source table where error was detected | Non-PII |
| source_record_key | VARCHAR(16777216) | Business key of the record that failed validation | Non-PII |
| error_type | VARCHAR(100) | Type of validation error encountered | Non-PII |
| error_column | VARCHAR(16777216) | Column name where the error was detected | Non-PII |
| error_value | VARCHAR(16777216) | The value that caused the validation failure | Non-PII |
| error_description | VARCHAR(16777216) | Detailed description of the validation error | Non-PII |
| validation_rule | VARCHAR(16777216) | The validation rule that was violated | Non-PII |
| error_severity | VARCHAR(50) | Severity level of the error | Non-PII |
| error_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the error was detected | Non-PII |
| processing_batch_key | VARCHAR(16777216) | Batch identifier for the processing run | Non-PII |
| resolution_status | VARCHAR(50) | Current status of error resolution | Non-PII |
| resolution_notes | VARCHAR(16777216) | Notes about error resolution or handling | Non-PII |
| resolved_by | VARCHAR(16777216) | User or system that resolved the error | Non-PII |
| resolution_timestamp | TIMESTAMP_NTZ(9) | Timestamp when the error was resolved | Non-PII |
| load_date | DATE | Date when error record was created | Non-PII |
| source_system | VARCHAR(16777216) | Source system identifier for data lineage | Non-PII |

## 2. Conceptual Data Model Diagram

### 2.1 Table Relationships in Tabular Format

| **Source Table** | **Target Table** | **Relationship Key Field** | **Relationship Type** |
|------------------|------------------|----------------------------|----------------------|
| Go_Dim_Date | Go_Fact_Meeting_Activity | meeting_date | One-to-Many |
| Go_Dim_User | Go_Fact_Meeting_Activity | host_user_key | One-to-Many |
| Go_Dim_Date | Go_Fact_Support_Activity | ticket_date | One-to-Many |
| Go_Dim_User | Go_Fact_Support_Activity | user_key | One-to-Many |
| Go_Dim_Date | Go_Fact_Revenue_Activity | event_date | One-to-Many |
| Go_Dim_User | Go_Fact_Revenue_Activity | user_key | One-to-Many |
| Go_Dim_License | Go_Dim_User | license_key | One-to-Many |
| Go_Code_Plan_Types | Go_Dim_User | plan_type | One-to-Many |
| Go_Code_Feature_Types | Go_Fact_Meeting_Activity | feature_name | One-to-Many |
| Go_Dim_Date | Go_Agg_Daily_Usage_Summary | summary_date | One-to-One |
| Go_Code_Plan_Types | Go_Agg_Daily_Usage_Summary | plan_type | One-to-Many |
| Go_Dim_Date | Go_Agg_Monthly_Revenue_Summary | summary_month | One-to-One |
| Go_Code_Plan_Types | Go_Agg_Monthly_Revenue_Summary | plan_type | One-to-Many |

### 2.2 Key Relationships Summary

1. **Date Dimension Relationships**: Go_Dim_Date serves as the primary time dimension connecting to all fact tables and aggregated tables
2. **User Dimension Relationships**: Go_Dim_User connects to all fact tables providing user context for analysis
3. **Code Table Relationships**: Go_Code_Plan_Types and Go_Code_Feature_Types provide standardized reference data
4. **License Dimension Relationships**: Go_Dim_License provides license context for user analysis
5. **Aggregated Table Relationships**: Summary tables connect to dimensions for pre-calculated metrics
6. **Audit and Error Relationships**: Go_Process_Audit and Go_Error_Data provide operational visibility

## 3. ER Diagram Visualization

### 3.1 Dimensional Model ER Diagram

```
                    ┌─────────────────────┐
                    │    Go_Dim_Date      │
                    │                     │
                    │ - date_key          │
                    │ - year              │
                    │ - quarter           │
                    │ - month             │
                    │ - day_name          │
                    │ - is_weekend        │
                    └─────────────────────┘
                             │
                             │ (Date Relationships)
                             ▼
    ┌─────────────────────┐  │  ┌─────────────────────┐  │  ┌─────────────────────┐
    │ Go_Fact_Meeting_    │◄─┼──┤ Go_Fact_Support_    │◄─┼──┤ Go_Fact_Revenue_    │
    │     Activity        │  │  │     Activity        │  │  │     Activity        │
    │                     │  │  │                     │  │  │                     │
    │ - meeting_date      │  │  │ - ticket_date       │  │  │ - event_date        │
    │ - host_user_key     │  │  │ - user_key          │  │  │ - user_key          │
    │ - duration_minutes  │  │  │ - resolution_time   │  │  │ - amount            │
    │ - participant_count │  │  │ - priority_level    │  │  │ - currency_code     │
    └─────────────────────┘  │  └─────────────────────┘  │  └─────────────────────┘
             │               │             │               │             │
             │               │             │               │             │
             ▼               │             ▼               │             ▼
    ┌─────────────────────┐  │  ┌─────────────────────┐  │  ┌─────────────────────┐
    │    Go_Dim_User      │◄─┼──┤    Go_Dim_User      │◄─┼──┤    Go_Dim_User      │
    │                     │  │  │                     │  │  │                     │
    │ - user_key          │  │  │ - user_key          │  │  │ - user_key          │
    │ - user_name         │  │  │ - user_name         │  │  │ - user_name         │
    │ - company           │  │  │ - company           │  │  │ - company           │
    │ - plan_type         │  │  │ - plan_type         │  │  │ - plan_type         │
    │ - effective_dates   │  │  │ - effective_dates   │  │  │ - effective_dates   │
    └─────────────────────┘  │  └─────────────────────┘  │  └─────────────────────┘
             │               │                           │
             │               │                           │
             ▼               │                           │
    ┌─────────────────────┐  │                           │
    │   Go_Dim_License    │  │                           │
    │                     │  │                           │
    │ - license_key       │  │                           │
    │ - license_type      │  │                           │
    │ - start_date        │  │                           │
    │ - end_date          │  │                           │
    │ - license_status    │  │                           │
    │ - effective_dates   │  │                           │
    └─────────────────────┘  │                           │
                             │                           │
    ┌─────────────────────┐  │  ┌─────────────────────┐  │
    │ Go_Code_Feature_    │◄─┼──┤ Go_Code_Plan_       │◄─┘
    │     Types           │  │  │     Types           │
    │                     │  │  │                     │
    │ - feature_code      │  │  │ - plan_code         │
    │ - feature_name      │  │  │ - plan_name         │
    │ - feature_category  │  │  │ - plan_tier         │
    │ - is_premium        │  │  │ - monthly_cost      │
    └─────────────────────┘  │  └─────────────────────┘
                             │
                             ▼
    ┌─────────────────────┐  │  ┌─────────────────────┐
    │ Go_Agg_Daily_Usage_ │◄─┼──┤ Go_Agg_Monthly_     │
    │     Summary         │  │  │ Revenue_Summary     │
    │                     │  │  │                     │
    │ - summary_date      │  │  │ - summary_month     │
    │ - plan_type         │  │  │ - plan_type         │
    │ - total_meetings    │  │  │ - total_revenue     │
    │ - unique_hosts      │  │  │ - recurring_revenue │
    │ - feature_usage     │  │  │ - active_subscribers│
    └─────────────────────┘  │  └─────────────────────┘
                             │
                             ▼
    ┌─────────────────────┐  │  ┌─────────────────────┐
    │  Go_Process_Audit   │  │  │   Go_Error_Data     │
    │                     │  │  │                     │
    │ - audit_key         │  │  │ - error_key         │
    │ - pipeline_name     │  │  │ - source_table      │
    │ - execution_status  │  │  │ - error_type        │
    │ - records_processed │  │  │ - error_description │
    │ - execution_time    │  │  │ - resolution_status │
    └─────────────────────┘  │  └─────────────────────┘
```

### 3.2 Data Flow Relationships

1. **Central Hub**: Go_Dim_Date and Go_Dim_User serve as central hubs connecting to all fact tables
2. **Fact Tables**: Three main fact tables capture different business processes (meetings, support, revenue)
3. **Dimension Tables**: Provide context and attributes for analysis with SCD Type 2 for historical tracking
4. **Code Tables**: Standardize categorical data and provide reference information
5. **Aggregated Tables**: Pre-calculated summaries for improved query performance
6. **Operational Tables**: Audit and error tables provide operational visibility and data quality monitoring

## 4. Design Decisions and Rationale

### 4.1 Key Design Decisions

1. **Dimensional Modeling Approach**: Implemented star schema design with fact tables at the center and dimension tables providing context, optimized for analytical queries and reporting.

2. **Slowly Changing Dimensions**: Applied SCD Type 2 to Go_Dim_User and Go_Dim_License to track historical changes in user attributes and license information.

3. **Fact Table Granularity**: 
   - Go_Fact_Meeting_Activity: One record per meeting
   - Go_Fact_Support_Activity: One record per support ticket
   - Go_Fact_Revenue_Activity: One record per billing event

4. **Aggregated Tables**: Created pre-aggregated tables for daily usage and monthly revenue to improve query performance for common reporting scenarios.

5. **Code Tables**: Implemented standardized code tables for feature types and plan types to ensure data consistency and enable easy maintenance.

6. **Audit and Error Tracking**: Comprehensive audit trail and error tracking tables to support data governance and operational monitoring.

### 4.2 Assumptions Made

1. **Business Keys**: Assumed that business keys from Silver layer can be used as dimension keys in Gold layer.

2. **Data Quality**: Assumed that data quality issues are resolved in Silver layer, with Gold layer focusing on dimensional modeling.

3. **Historical Tracking**: Assumed that historical tracking is required for user and license dimensions based on business requirements.

4. **Aggregation Levels**: Assumed daily and monthly aggregations are sufficient for most reporting needs.

5. **PII Classification**: Applied conservative PII classification, marking user names as PII while keeping business-relevant fields as non-PII.

### 4.3 Performance Optimizations

1. **Pre-Aggregated Tables**: Created summary tables to reduce query complexity and improve performance for common reporting scenarios.

2. **Dimensional Design**: Star schema design optimizes for analytical queries with minimal joins required.

3. **Date Dimension**: Comprehensive date dimension supports various time-based analyses without complex date calculations.

4. **Partitioning Strategy**: Tables can be partitioned by date fields for improved query performance on large datasets.

### 4.4 Data Governance Features

1. **Data Lineage**: Source system tracking in all tables provides complete data lineage.

2. **Audit Trail**: Comprehensive audit table tracks all processing activities and performance metrics.

3. **Error Tracking**: Detailed error tracking supports data quality monitoring and issue resolution.

4. **PII Classification**: Clear PII classification supports compliance with data protection regulations.

5. **Version Control**: SCD implementation provides historical tracking and version control for changing dimensions.

## 5. Implementation Guidelines

### 5.1 Data Loading Strategy

1. **Incremental Loading**: Use effective dates and change detection for SCD Type 2 dimensions.

2. **Fact Table Loading**: Load fact tables incrementally based on source system timestamps.

3. **Aggregation Refresh**: Refresh aggregated tables after fact table updates to maintain consistency.

4. **Code Table Maintenance**: Implement change management process for code table updates.

### 5.2 Query Optimization

1. **Indexing Strategy**: Create appropriate indexes on dimension keys and date fields.

2. **Partitioning**: Implement date-based partitioning for large fact tables.

3. **Materialized Views**: Consider materialized views for frequently accessed aggregations.

4. **Query Patterns**: Optimize for common analytical query patterns and reporting requirements.

### 5.3 Monitoring and Maintenance

1. **Data Quality Monitoring**: Regular monitoring of error tables and data quality metrics.

2. **Performance Monitoring**: Track query performance and optimize based on usage patterns.

3. **Capacity Planning**: Monitor data growth and plan for scaling requirements.

4. **Documentation Maintenance**: Keep documentation updated with schema changes and business rule updates.