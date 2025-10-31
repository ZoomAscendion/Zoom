_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Logical Data Model for Zoom Platform Analytics System following medallion architecture with dimensional modeling for analytics and reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Gold Layer Logical Data Model - Zoom Platform Analytics System

## 1. Gold Layer Logical Model

### 1.1 FACT TABLES

#### 1.1.1 Go_Fact_Meeting_Activity
**Table Type**: Fact
**Description**: Central fact table capturing meeting activities and usage metrics for platform usage analysis
**SCD Type**: N/A (Fact Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| meeting_date | DATE | Date when the meeting occurred | Non-PII |
| meeting_duration_minutes | INTEGER | Total duration of the meeting in minutes | Non-PII |
| participant_count | INTEGER | Number of participants who joined the meeting | Non-PII |
| meeting_type | VARCHAR(50) | Type of meeting (Scheduled, Instant, Webinar, Personal) | Non-PII |
| recording_enabled_flag | BOOLEAN | Whether recording was enabled for the meeting | Non-PII |
| feature_usage_count | INTEGER | Total number of features used during the meeting | Non-PII |
| total_attendance_minutes | INTEGER | Sum of all participant attendance durations | Non-PII |
| host_plan_type | VARCHAR(50) | Plan type of the meeting host | Non-PII |
| meeting_status | VARCHAR(20) | Final status of the meeting | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.1.2 Go_Fact_Support_Metrics
**Table Type**: Fact
**Description**: Fact table for support ticket metrics and resolution tracking
**SCD Type**: N/A (Fact Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| ticket_date | DATE | Date when support ticket was created | Non-PII |
| resolution_time_hours | DECIMAL(10,2) | Time taken to resolve ticket in business hours | Non-PII |
| ticket_type | VARCHAR(50) | Category of support ticket | Non-PII |
| priority_level | VARCHAR(20) | Priority level of the ticket | Non-PII |
| resolution_status | VARCHAR(20) | Final resolution status | Non-PII |
| first_contact_resolution_flag | BOOLEAN | Whether ticket was resolved on first contact | Non-PII |
| escalation_flag | BOOLEAN | Whether ticket required escalation | Non-PII |
| customer_plan_type | VARCHAR(50) | Plan type of the customer who created ticket | Non-PII |
| satisfaction_score | INTEGER | Customer satisfaction rating (1-5) | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.1.3 Go_Fact_Revenue_Events
**Table Type**: Fact
**Description**: Fact table capturing billing events and revenue metrics
**SCD Type**: N/A (Fact Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| transaction_date | DATE | Date of the billing transaction | Non-PII |
| transaction_amount_usd | DECIMAL(12,2) | Transaction amount converted to USD | Non-PII |
| original_amount | DECIMAL(12,2) | Original transaction amount | Non-PII |
| currency_code | VARCHAR(3) | Original currency code | Non-PII |
| event_type | VARCHAR(50) | Type of billing event | Non-PII |
| payment_method | VARCHAR(50) | Payment method used | Non-PII |
| license_type | VARCHAR(50) | Type of license associated with transaction | Non-PII |
| customer_plan_type | VARCHAR(50) | Customer's subscription plan type | Non-PII |
| transaction_status | VARCHAR(20) | Status of the transaction | Non-PII |
| mrr_impact | DECIMAL(12,2) | Impact on Monthly Recurring Revenue | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.1.4 Go_Fact_Feature_Usage
**Table Type**: Fact
**Description**: Fact table for detailed feature usage analytics
**SCD Type**: N/A (Fact Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| usage_date | DATE | Date when feature was used | Non-PII |
| feature_name | VARCHAR(100) | Name of the feature used | Non-PII |
| feature_category | VARCHAR(50) | Category of the feature | Non-PII |
| usage_count | INTEGER | Number of times feature was used | Non-PII |
| usage_duration_minutes | INTEGER | Total duration feature was active | Non-PII |
| meeting_type | VARCHAR(50) | Type of meeting where feature was used | Non-PII |
| user_plan_type | VARCHAR(50) | Plan type of the user | Non-PII |
| participant_count | INTEGER | Number of participants in the meeting | Non-PII |
| load_date | DATE | Date when record was loaded into Gold layer | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 1.2 DIMENSION TABLES

#### 1.2.1 Go_Dim_Date
**Table Type**: Dimension
**Description**: Standard date dimension for time-based analysis
**SCD Type**: Type 1

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| date_key | DATE | Primary date key | Non-PII |
| year | INTEGER | Year component | Non-PII |
| quarter | INTEGER | Quarter number (1-4) | Non-PII |
| month | INTEGER | Month number (1-12) | Non-PII |
| month_name | VARCHAR(20) | Full month name | Non-PII |
| week_of_year | INTEGER | Week number in year | Non-PII |
| day_of_month | INTEGER | Day of the month | Non-PII |
| day_of_week | INTEGER | Day of week (1-7) | Non-PII |
| day_name | VARCHAR(20) | Full day name | Non-PII |
| is_weekend | BOOLEAN | Whether date falls on weekend | Non-PII |
| is_holiday | BOOLEAN | Whether date is a business holiday | Non-PII |
| fiscal_year | INTEGER | Fiscal year | Non-PII |
| fiscal_quarter | INTEGER | Fiscal quarter | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.2 Go_Dim_User
**Table Type**: Dimension
**Description**: User dimension with slowly changing attributes
**SCD Type**: Type 2

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| user_business_key | VARCHAR(255) | Business key for the user | PII |
| user_name | VARCHAR(255) | Full name of the user | PII |
| email_domain | VARCHAR(100) | Domain part of email address | Non-PII |
| company_name | VARCHAR(255) | Company or organization name | PII |
| plan_type | VARCHAR(50) | Current subscription plan type | Non-PII |
| account_status | VARCHAR(20) | Current account status | Non-PII |
| registration_date | DATE | Date when user registered | Non-PII |
| user_segment | VARCHAR(50) | User segment classification | Non-PII |
| effective_start_date | DATE | When this version became effective | Non-PII |
| effective_end_date | DATE | When this version expired | Non-PII |
| is_current | BOOLEAN | Whether this is the current version | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.3 Go_Dim_Meeting_Type
**Table Type**: Dimension
**Description**: Meeting type classification dimension
**SCD Type**: Type 1

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| meeting_type_key | VARCHAR(50) | Meeting type identifier | Non-PII |
| meeting_type_name | VARCHAR(100) | Full name of meeting type | Non-PII |
| meeting_category | VARCHAR(50) | High-level category | Non-PII |
| is_scheduled | BOOLEAN | Whether meeting type requires scheduling | Non-PII |
| supports_recording | BOOLEAN | Whether recording is supported | Non-PII |
| max_participants | INTEGER | Maximum number of participants allowed | Non-PII |
| requires_license | BOOLEAN | Whether special license is required | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.4 Go_Dim_Feature
**Table Type**: Dimension
**Description**: Platform feature dimension for usage analysis
**SCD Type**: Type 1

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| feature_key | VARCHAR(100) | Feature identifier | Non-PII |
| feature_name | VARCHAR(200) | Full name of the feature | Non-PII |
| feature_category | VARCHAR(50) | Feature category classification | Non-PII |
| feature_subcategory | VARCHAR(50) | Feature subcategory | Non-PII |
| is_premium_feature | BOOLEAN | Whether feature requires premium plan | Non-PII |
| release_date | DATE | When feature was first released | Non-PII |
| deprecation_date | DATE | When feature was deprecated | Non-PII |
| is_active | BOOLEAN | Whether feature is currently active | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.5 Go_Dim_Support_Category
**Table Type**: Dimension
**Description**: Support ticket categorization dimension
**SCD Type**: Type 1

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| category_key | VARCHAR(50) | Support category identifier | Non-PII |
| ticket_type | VARCHAR(100) | Type of support ticket | Non-PII |
| category_group | VARCHAR(50) | High-level category grouping | Non-PII |
| priority_level | VARCHAR(20) | Default priority level | Non-PII |
| sla_hours | INTEGER | Service level agreement in hours | Non-PII |
| escalation_threshold_hours | INTEGER | Hours before automatic escalation | Non-PII |
| requires_technical_expertise | BOOLEAN | Whether technical skills are required | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.6 Go_Dim_License
**Table Type**: Dimension
**Description**: License type and pricing dimension
**SCD Type**: Type 2

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| license_type_key | VARCHAR(50) | License type identifier | Non-PII |
| license_name | VARCHAR(100) | Full name of license type | Non-PII |
| license_tier | VARCHAR(50) | License tier classification | Non-PII |
| monthly_cost | DECIMAL(10,2) | Monthly cost of license | Non-PII |
| annual_cost | DECIMAL(10,2) | Annual cost of license | Non-PII |
| max_participants | INTEGER | Maximum participants allowed | Non-PII |
| storage_gb | INTEGER | Storage allocation in GB | Non-PII |
| features_included | TEXT | List of included features | Non-PII |
| effective_start_date | DATE | When this pricing became effective | Non-PII |
| effective_end_date | DATE | When this pricing expired | Non-PII |
| is_current | BOOLEAN | Whether this is current pricing | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 1.3 AGGREGATED TABLES

#### 1.3.1 Go_Agg_Daily_Usage_Summary
**Table Type**: Aggregated
**Description**: Daily aggregated usage metrics for performance optimization
**SCD Type**: N/A (Aggregated Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| summary_date | DATE | Date of the aggregated metrics | Non-PII |
| total_meetings | INTEGER | Total number of meetings held | Non-PII |
| total_participants | INTEGER | Total number of unique participants | Non-PII |
| total_meeting_minutes | INTEGER | Sum of all meeting durations | Non-PII |
| average_meeting_duration | DECIMAL(10,2) | Average meeting duration in minutes | Non-PII |
| total_active_users | INTEGER | Number of users who hosted or attended meetings | Non-PII |
| new_user_registrations | INTEGER | Number of new user sign-ups | Non-PII |
| webinar_count | INTEGER | Total number of webinars held | Non-PII |
| recording_usage_count | INTEGER | Number of meetings with recording enabled | Non-PII |
| feature_usage_events | INTEGER | Total feature usage events | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.3.2 Go_Agg_Monthly_Revenue_Summary
**Table Type**: Aggregated
**Description**: Monthly revenue and billing aggregations
**SCD Type**: N/A (Aggregated Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| revenue_month | DATE | Month of the revenue summary (first day of month) | Non-PII |
| total_revenue_usd | DECIMAL(15,2) | Total revenue in USD | Non-PII |
| mrr_usd | DECIMAL(15,2) | Monthly Recurring Revenue in USD | Non-PII |
| new_customer_revenue | DECIMAL(15,2) | Revenue from new customers | Non-PII |
| expansion_revenue | DECIMAL(15,2) | Revenue from upgrades | Non-PII |
| churn_revenue | DECIMAL(15,2) | Revenue lost from churned customers | Non-PII |
| total_transactions | INTEGER | Total number of billing transactions | Non-PII |
| active_licenses | INTEGER | Number of active licenses | Non-PII |
| license_utilization_rate | DECIMAL(5,2) | Percentage of licenses being utilized | Non-PII |
| average_revenue_per_user | DECIMAL(10,2) | Average revenue per active user | Non-PII |
| customer_churn_rate | DECIMAL(5,2) | Percentage of customers who churned | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.3.3 Go_Agg_Weekly_Support_Summary
**Table Type**: Aggregated
**Description**: Weekly support metrics aggregation
**SCD Type**: N/A (Aggregated Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| week_start_date | DATE | Start date of the week | Non-PII |
| total_tickets_created | INTEGER | Total tickets created during the week | Non-PII |
| total_tickets_resolved | INTEGER | Total tickets resolved during the week | Non-PII |
| average_resolution_time_hours | DECIMAL(10,2) | Average resolution time in hours | Non-PII |
| first_contact_resolution_rate | DECIMAL(5,2) | Percentage resolved on first contact | Non-PII |
| escalation_rate | DECIMAL(5,2) | Percentage of tickets escalated | Non-PII |
| tickets_by_priority_critical | INTEGER | Number of critical priority tickets | Non-PII |
| tickets_by_priority_high | INTEGER | Number of high priority tickets | Non-PII |
| tickets_by_priority_medium | INTEGER | Number of medium priority tickets | Non-PII |
| tickets_by_priority_low | INTEGER | Number of low priority tickets | Non-PII |
| customer_satisfaction_avg | DECIMAL(3,2) | Average customer satisfaction score | Non-PII |
| load_date | DATE | Date when record was loaded | Non-PII |
| update_date | DATE | Date when record was last updated | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

### 1.4 AUDIT AND ERROR DATA TABLES

#### 1.4.1 Go_Process_Audit
**Table Type**: Audit
**Description**: Comprehensive audit trail for Gold layer pipeline execution and data processing
**SCD Type**: N/A (Audit Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| audit_key | VARCHAR(100) | Unique identifier for audit record | Non-PII |
| pipeline_name | VARCHAR(200) | Name of the data pipeline executed | Non-PII |
| execution_start_timestamp | TIMESTAMP_NTZ(9) | When pipeline execution started | Non-PII |
| execution_end_timestamp | TIMESTAMP_NTZ(9) | When pipeline execution completed | Non-PII |
| execution_duration_seconds | INTEGER | Total execution time in seconds | Non-PII |
| execution_status | VARCHAR(50) | Status of execution (Success, Failed, Partial) | Non-PII |
| source_tables_processed | TEXT | List of source tables processed | Non-PII |
| target_tables_updated | TEXT | List of target tables updated | Non-PII |
| records_processed | INTEGER | Total number of records processed | Non-PII |
| records_inserted | INTEGER | Number of new records inserted | Non-PII |
| records_updated | INTEGER | Number of existing records updated | Non-PII |
| records_rejected | INTEGER | Number of records rejected due to quality issues | Non-PII |
| data_quality_score | DECIMAL(5,2) | Overall data quality score for the batch | Non-PII |
| error_message | TEXT | Error message if execution failed | Non-PII |
| executed_by | VARCHAR(100) | User or system that executed the pipeline | Non-PII |
| execution_environment | VARCHAR(50) | Environment (Dev, Test, Prod) | Non-PII |
| load_date | DATE | Date when audit record was created | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.4.2 Go_Data_Quality_Errors
**Table Type**: Error Data
**Description**: Data validation errors and quality issues in Gold layer processing
**SCD Type**: N/A (Error Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|--------------------|
| error_key | VARCHAR(100) | Unique identifier for error record | Non-PII |
| source_table_name | VARCHAR(100) | Name of source table where error occurred | Non-PII |
| target_table_name | VARCHAR(100) | Name of target table affected | Non-PII |
| source_record_identifier | VARCHAR(200) | Identifier of problematic source record | Non-PII |
| error_type | VARCHAR(50) | Type of error (Validation, Transformation, Load) | Non-PII |
| error_category | VARCHAR(50) | Category (Missing Data, Invalid Format, Business Rule) | Non-PII |
| error_column_name | VARCHAR(100) | Column where error was detected | Non-PII |
| error_description | TEXT | Detailed description of the error | Non-PII |
| error_severity | VARCHAR(20) | Severity level (Critical, High, Medium, Low) | Non-PII |
| detected_timestamp | TIMESTAMP_NTZ(9) | When error was detected | Non-PII |
| resolution_status | VARCHAR(50) | Status of error resolution | Non-PII |
| resolution_action | TEXT | Action taken to resolve error | Non-PII |
| resolved_timestamp | TIMESTAMP_NTZ(9) | When error was resolved | Non-PII |
| resolved_by | VARCHAR(100) | Who resolved the error | Non-PII |
| business_impact | VARCHAR(100) | Impact on business reporting | Non-PII |
| load_date | DATE | Date when error record was created | Non-PII |
| source_system | VARCHAR(100) | Source system identifier | Non-PII |

## 2. Conceptual Data Model Diagram

### 2.1 Table Relationships and Key Fields

| Source Table | Target Table | Relationship Key Field | Relationship Type | Description |
|--------------|--------------|----------------------|-------------------|-------------|
| Go_Dim_Date | Go_Fact_Meeting_Activity | meeting_date | One-to-Many | Date dimension supports time-based analysis |
| Go_Dim_User | Go_Fact_Meeting_Activity | user_business_key | One-to-Many | Users can host multiple meetings |
| Go_Dim_Meeting_Type | Go_Fact_Meeting_Activity | meeting_type_key | One-to-Many | Meeting types used in multiple meetings |
| Go_Dim_Date | Go_Fact_Support_Metrics | ticket_date | One-to-Many | Date dimension for support analysis |
| Go_Dim_User | Go_Fact_Support_Metrics | user_business_key | One-to-Many | Users can create multiple support tickets |
| Go_Dim_Support_Category | Go_Fact_Support_Metrics | category_key | One-to-Many | Support categories used in multiple tickets |
| Go_Dim_Date | Go_Fact_Revenue_Events | transaction_date | One-to-Many | Date dimension for revenue analysis |
| Go_Dim_User | Go_Fact_Revenue_Events | user_business_key | One-to-Many | Users can have multiple billing events |
| Go_Dim_License | Go_Fact_Revenue_Events | license_type_key | One-to-Many | License types in multiple transactions |
| Go_Dim_Date | Go_Fact_Feature_Usage | usage_date | One-to-Many | Date dimension for feature usage analysis |
| Go_Dim_Feature | Go_Fact_Feature_Usage | feature_key | One-to-Many | Features used multiple times |
| Go_Dim_User | Go_Fact_Feature_Usage | user_business_key | One-to-Many | Users can use multiple features |
| Go_Dim_Date | Go_Agg_Daily_Usage_Summary | summary_date | One-to-One | Daily aggregations by date |
| Go_Dim_Date | Go_Agg_Monthly_Revenue_Summary | revenue_month | One-to-One | Monthly aggregations by date |
| Go_Dim_Date | Go_Agg_Weekly_Support_Summary | week_start_date | One-to-One | Weekly aggregations by date |

## 3. ER Diagram Visualization

### 3.1 Gold Layer Entity Relationship Diagram

```
                    ┌─────────────────────┐
                    │     Go_Dim_Date     │
                    │                     │
                    │ • date_key          │
                    │ • year              │
                    │ • quarter           │
                    │ • month             │
                    │ • day_name          │
                    └─────────┬───────────┘
                              │
                              │ (1:M)
                              ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│     Go_Dim_User     │    │Go_Fact_Meeting_     │    │ Go_Dim_Meeting_Type │
│                     │    │     Activity        │    │                     │
│ • user_business_key │◄──►│                     │◄──►│ • meeting_type_key  │
│ • user_name         │    │ • meeting_date      │    │ • meeting_type_name │
│ • email_domain      │    │ • duration_minutes  │    │ • meeting_category  │
│ • company_name      │    │ • participant_count │    │ • supports_recording│
│ • plan_type         │    │ • meeting_type      │    │ • max_participants  │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
         │                           │                           │
         │ (1:M)                     │ (1:M)                     │
         ▼                           ▼                           ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│Go_Fact_Support_     │    │Go_Fact_Feature_     │    │   Go_Dim_Feature    │
│     Metrics         │    │      Usage          │    │                     │
│                     │    │                     │◄──►│ • feature_key       │
│ • ticket_date       │    │ • usage_date        │    │ • feature_name      │
│ • resolution_time   │    │ • usage_count       │    │ • feature_category  │
│ • ticket_type       │    │ • usage_duration    │    │ • is_premium_feature│
│ • priority_level    │    │ • feature_name      │    │ • release_date      │
└─────────┬───────────┘    └─────────────────────┘    └─────────────────────┘
          │                           │
          │ (1:M)                     │ (1:M)
          ▼                           ▼
┌─────────────────────┐    ┌─────────────────────┐
│Go_Dim_Support_      │    │Go_Fact_Revenue_     │
│    Category         │    │      Events         │
│                     │    │                     │
│ • category_key      │    │ • transaction_date  │
│ • ticket_type       │    │ • amount_usd        │
│ • category_group    │    │ • event_type        │
│ • sla_hours         │    │ • payment_method    │
│ • escalation_thresh │    │ • mrr_impact        │
└─────────────────────┘    └─────────┬───────────┘
                                     │
                                     │ (1:M)
                                     ▼
                           ┌─────────────────────┐
                           │    Go_Dim_License   │
                           │                     │
                           │ • license_type_key  │
                           │ • license_name      │
                           │ • license_tier      │
                           │ • monthly_cost      │
                           │ • features_included │
                           └─────────────────────┘

                    AGGREGATED TABLES

┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│Go_Agg_Daily_Usage_ │    │Go_Agg_Monthly_      │    │Go_Agg_Weekly_       │
│     Summary         │    │Revenue_Summary      │    │Support_Summary      │
│                     │    │                     │    │                     │
│ • summary_date      │    │ • revenue_month     │    │ • week_start_date   │
│ • total_meetings    │    │ • total_revenue_usd │    │ • total_tickets     │
│ • total_participants│    │ • mrr_usd           │    │ • avg_resolution    │
│ • active_users      │    │ • churn_revenue     │    │ • escalation_rate   │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘

                    AUDIT AND ERROR TABLES

┌─────────────────────┐    ┌─────────────────────┐
│  Go_Process_Audit   │    │Go_Data_Quality_     │
│                     │    │     Errors          │
│ • audit_key         │    │                     │
│ • pipeline_name     │    │ • error_key         │
│ • execution_start   │    │ • source_table_name │
│ • execution_status  │    │ • error_type        │
│ • records_processed │    │ • error_description │
│ • data_quality_score│    │ • resolution_status │
└─────────────────────┘    └─────────────────────┘
```

## 4. Design Rationale and Key Decisions

### 4.1 Dimensional Modeling Approach
1. **Star Schema Design**: Implemented classic star schema with fact tables at center and dimension tables providing context
2. **Conformed Dimensions**: Go_Dim_Date and Go_Dim_User are shared across multiple fact tables for consistent analysis
3. **Slowly Changing Dimensions**: Type 2 SCD implemented for Go_Dim_User and Go_Dim_License to track historical changes
4. **Grain Definition**: Each fact table has clearly defined grain for accurate aggregation

### 4.2 Performance Optimization
1. **Pre-aggregated Tables**: Created daily, weekly, and monthly summary tables for faster query performance
2. **Denormalization**: Included commonly used attributes directly in fact tables to reduce joins
3. **Partitioning Strategy**: Date-based partitioning recommended for all fact and aggregated tables

### 4.3 Data Quality and Governance
1. **Audit Trail**: Comprehensive audit table tracks all data processing activities
2. **Error Management**: Dedicated error table captures and tracks data quality issues
3. **PII Classification**: All columns classified for privacy compliance (GDPR, CCPA)
4. **Data Lineage**: Source system tracking in all tables for data lineage

### 4.4 Business Alignment
1. **KPI Support**: Model directly supports all required KPIs from business requirements
2. **Report Enablement**: Structure optimized for Platform Usage, Support, and Revenue reporting
3. **Scalability**: Design supports future expansion with additional fact and dimension tables

### 4.5 Assumptions Made
1. **Currency Conversion**: All revenue amounts converted to USD for consistent analysis
2. **Time Zone**: All timestamps standardized to UTC in source systems
3. **Business Hours**: Support resolution times calculated based on standard business hours
4. **Data Retention**: Historical data maintained indefinitely for trend analysis
5. **User Identification**: Users uniquely identified across all systems using business keys

This Gold layer logical data model provides a robust foundation for analytics and reporting while ensuring data quality, performance, and governance requirements are met.