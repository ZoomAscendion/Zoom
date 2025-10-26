_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Logical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Gold Layer Logical Data Model - Zoom Platform Analytics System

## 1. Gold Layer Logical Model

### 1.1 FACT TABLES

#### 1.1.1 Table: Go_MEETING_FACTS
**Description**: Central fact table capturing meeting activities and metrics for platform usage analytics
**Table Type**: Fact
**SCD Type**: N/A (Fact Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| MEETING_DATE | DATE | Date when the meeting occurred for time-based analysis | Non-PII |
| HOST_NAME | VARCHAR(200) | Name of the meeting host for user analysis | PII - Personal Name |
| MEETING_TOPIC | VARCHAR(500) | Subject or title of the meeting | Non-PII |
| DURATION_MINUTES | INTEGER | Total meeting duration in minutes | Non-PII |
| MEETING_TYPE | VARCHAR(30) | Type of meeting (Scheduled, Instant, Recurring, Webinar) | Non-PII |
| PARTICIPANT_COUNT | INTEGER | Total number of participants in the meeting | Non-PII |
| TOTAL_ATTENDANCE_MINUTES | INTEGER | Sum of all participant attendance minutes | Non-PII |
| AVERAGE_ATTENDANCE_PERCENTAGE | DECIMAL(5,2) | Average attendance percentage across all participants | Non-PII |
| FEATURE_USAGE_COUNT | INTEGER | Total number of features used during the meeting | Non-PII |
| BUSINESS_HOURS_FLAG | BOOLEAN | Indicator if meeting occurred during business hours | Non-PII |
| MEETING_SIZE_CATEGORY | VARCHAR(20) | Categorized meeting size (Small, Medium, Large, Enterprise) | Non-PII |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| UPDATE_DATE | DATE | Date when record was last updated | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.1.2 Table: Go_BILLING_FACTS
**Description**: Fact table for financial transactions and revenue analysis
**Table Type**: Fact
**SCD Type**: N/A (Fact Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| TRANSACTION_DATE | DATE | Date of the billing transaction | Non-PII |
| USER_NAME | VARCHAR(200) | Name of the user associated with the transaction | PII - Personal Name |
| EVENT_TYPE | VARCHAR(50) | Type of billing event (Subscription, Payment, Refund, Upgrade) | Non-PII |
| AMOUNT | DECIMAL(12,2) | Transaction amount | Non-PII |
| CURRENCY_CODE | VARCHAR(3) | ISO currency code | Non-PII |
| PAYMENT_METHOD | VARCHAR(50) | Method of payment used | Non-PII |
| TRANSACTION_STATUS | VARCHAR(20) | Status of the transaction | Non-PII |
| PLAN_TYPE | VARCHAR(30) | Subscription plan type | Non-PII |
| COMPANY | VARCHAR(200) | Company associated with the transaction | PII - Organization |
| REVENUE_RECOGNITION_AMOUNT | DECIMAL(12,2) | Amount recognized for revenue accounting | Non-PII |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| UPDATE_DATE | DATE | Date when record was last updated | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.1.3 Table: Go_SUPPORT_FACTS
**Description**: Fact table for support ticket metrics and service reliability analysis
**Table Type**: Fact
**SCD Type**: N/A (Fact Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| TICKET_DATE | DATE | Date when support ticket was created | Non-PII |
| USER_NAME | VARCHAR(200) | Name of user who created the ticket | PII - Personal Name |
| TICKET_TYPE | VARCHAR(50) | Category of support ticket | Non-PII |
| PRIORITY_LEVEL | VARCHAR(20) | Priority level of the ticket | Non-PII |
| RESOLUTION_STATUS | VARCHAR(30) | Current status of the ticket | Non-PII |
| RESOLUTION_TIME_HOURS | INTEGER | Time taken to resolve ticket in hours | Non-PII |
| FIRST_RESPONSE_TIME_HOURS | INTEGER | Time to first response in hours | Non-PII |
| ESCALATION_FLAG | BOOLEAN | Indicator if ticket was escalated | Non-PII |
| SLA_BREACH_FLAG | BOOLEAN | Indicator if SLA was breached | Non-PII |
| COMPANY | VARCHAR(200) | Company of the user | PII - Organization |
| PLAN_TYPE | VARCHAR(30) | User's subscription plan | Non-PII |
| ASSIGNED_AGENT | VARCHAR(200) | Support agent assigned to ticket | PII - Personal Name |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| UPDATE_DATE | DATE | Date when record was last updated | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

### 1.2 DIMENSION TABLES

#### 1.2.1 Table: Go_USER_DIMENSION
**Description**: Dimension table containing user profile information and attributes
**Table Type**: Dimension
**SCD Type**: Type 2 (Track historical changes)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| USER_NAME | VARCHAR(200) | Full name of the platform user | PII - Personal Name |
| EMAIL_ADDRESS | VARCHAR(300) | Primary email address of the user | PII - Email |
| EMAIL_DOMAIN | VARCHAR(100) | Domain part of the email address | Non-PII |
| COMPANY | VARCHAR(200) | Organization associated with the user | PII - Organization |
| PLAN_TYPE | VARCHAR(30) | Current subscription plan type | Non-PII |
| REGISTRATION_DATE | DATE | Date when user registered on platform | Non-PII |
| ACCOUNT_AGE_DAYS | INTEGER | Number of days since registration | Non-PII |
| USER_SEGMENT | VARCHAR(30) | Derived user segment classification | Non-PII |
| GEOGRAPHIC_REGION | VARCHAR(50) | Geographic region of the user | Non-PII |
| USER_STATUS | VARCHAR(20) | Current status of the user account | Non-PII |
| EFFECTIVE_START_DATE | DATE | Start date for this version of the record | Non-PII |
| EFFECTIVE_END_DATE | DATE | End date for this version of the record | Non-PII |
| CURRENT_FLAG | BOOLEAN | Indicator for current active record | Non-PII |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| UPDATE_DATE | DATE | Date when record was last updated | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.2 Table: Go_TIME_DIMENSION
**Description**: Time dimension for temporal analysis and reporting
**Table Type**: Dimension
**SCD Type**: Type 1 (No historical tracking needed)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| DATE_KEY | DATE | Primary date key | Non-PII |
| YEAR | INTEGER | Year component | Non-PII |
| QUARTER | INTEGER | Quarter of the year (1-4) | Non-PII |
| MONTH | INTEGER | Month component (1-12) | Non-PII |
| MONTH_NAME | VARCHAR(20) | Full month name | Non-PII |
| WEEK_OF_YEAR | INTEGER | Week number in the year | Non-PII |
| DAY_OF_MONTH | INTEGER | Day of the month | Non-PII |
| DAY_OF_WEEK | INTEGER | Day of the week (1-7) | Non-PII |
| DAY_NAME | VARCHAR(20) | Full day name | Non-PII |
| IS_WEEKEND | BOOLEAN | Indicator for weekend days | Non-PII |
| IS_BUSINESS_DAY | BOOLEAN | Indicator for business days | Non-PII |
| FISCAL_YEAR | INTEGER | Fiscal year | Non-PII |
| FISCAL_QUARTER | INTEGER | Fiscal quarter | Non-PII |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.3 Table: Go_FEATURE_DIMENSION
**Description**: Dimension table for platform features and their categorization
**Table Type**: Dimension
**SCD Type**: Type 1 (Overwrite changes)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| FEATURE_NAME | VARCHAR(100) | Name of the platform feature | Non-PII |
| FEATURE_CATEGORY | VARCHAR(50) | Category classification of the feature | Non-PII |
| FEATURE_DESCRIPTION | VARCHAR(500) | Detailed description of the feature | Non-PII |
| FEATURE_TYPE | VARCHAR(30) | Type of feature (Core, Premium, Add-on) | Non-PII |
| AVAILABILITY_PLAN | VARCHAR(100) | Plans where feature is available | Non-PII |
| FEATURE_STATUS | VARCHAR(20) | Current status of the feature | Non-PII |
| LAUNCH_DATE | DATE | Date when feature was launched | Non-PII |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| UPDATE_DATE | DATE | Date when record was last updated | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.2.4 Table: Go_LICENSE_DIMENSION
**Description**: Dimension table for license types and their attributes
**Table Type**: Dimension
**SCD Type**: Type 2 (Track historical changes)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| LICENSE_TYPE | VARCHAR(50) | Type of license (Basic, Pro, Business, Enterprise) | Non-PII |
| LICENSE_DESCRIPTION | VARCHAR(500) | Detailed description of license features | Non-PII |
| LICENSE_CATEGORY | VARCHAR(30) | Category of license (Subscription, Add-on) | Non-PII |
| PRICE_TIER | VARCHAR(20) | Pricing tier classification | Non-PII |
| MAX_PARTICIPANTS | INTEGER | Maximum participants allowed | Non-PII |
| MEETING_DURATION_LIMIT | INTEGER | Meeting duration limit in minutes | Non-PII |
| STORAGE_LIMIT_GB | INTEGER | Storage limit in gigabytes | Non-PII |
| SUPPORT_LEVEL | VARCHAR(30) | Level of support provided | Non-PII |
| EFFECTIVE_START_DATE | DATE | Start date for this version of the record | Non-PII |
| EFFECTIVE_END_DATE | DATE | End date for this version of the record | Non-PII |
| CURRENT_FLAG | BOOLEAN | Indicator for current active record | Non-PII |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| UPDATE_DATE | DATE | Date when record was last updated | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

### 1.3 PROCESS AUDIT TABLES

#### 1.3.1 Table: Go_PIPELINE_AUDIT
**Description**: Audit table for tracking ETL pipeline execution and performance
**Table Type**: Audit
**SCD Type**: N/A (Audit Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| AUDIT_KEY | VARCHAR(50) | Unique identifier for audit record | Non-PII |
| PIPELINE_NAME | VARCHAR(200) | Name of the executed pipeline | Non-PII |
| EXECUTION_START_TIME | TIMESTAMP_NTZ(9) | Pipeline execution start timestamp | Non-PII |
| EXECUTION_END_TIME | TIMESTAMP_NTZ(9) | Pipeline execution completion timestamp | Non-PII |
| EXECUTION_DURATION_SECONDS | INTEGER | Total execution time in seconds | Non-PII |
| SOURCE_TABLE_NAME | VARCHAR(100) | Source table being processed | Non-PII |
| TARGET_TABLE_NAME | VARCHAR(100) | Target Gold layer table | Non-PII |
| RECORDS_PROCESSED | INTEGER | Total number of records processed | Non-PII |
| RECORDS_SUCCESS | INTEGER | Number of successfully processed records | Non-PII |
| RECORDS_FAILED | INTEGER | Number of records that failed processing | Non-PII |
| RECORDS_REJECTED | INTEGER | Number of records rejected due to quality issues | Non-PII |
| EXECUTION_STATUS | VARCHAR(30) | Pipeline execution status | Non-PII |
| ERROR_MESSAGE | VARCHAR(2000) | Error details for failed executions | Non-PII |
| PROCESSED_BY | VARCHAR(100) | User or system that executed the pipeline | Non-PII |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Audit record creation timestamp | Non-PII |

### 1.4 ERROR DATA TABLES

#### 1.4.1 Table: Go_DATA_VALIDATION_ERRORS
**Description**: Error table for capturing data validation failures and quality issues
**Table Type**: Error Data
**SCD Type**: N/A (Error Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| ERROR_KEY | VARCHAR(50) | Unique identifier for each data validation error | Non-PII |
| SOURCE_TABLE_NAME | VARCHAR(100) | Name of the source table where error occurred | Non-PII |
| TARGET_TABLE_NAME | VARCHAR(100) | Name of the target Gold table | Non-PII |
| ERROR_TYPE | VARCHAR(50) | Type of validation error | Non-PII |
| ERROR_DESCRIPTION | VARCHAR(1000) | Detailed description of the data quality issue | Non-PII |
| AFFECTED_COLUMN | VARCHAR(100) | Column name where the error was detected | Non-PII |
| ERROR_VALUE | VARCHAR(500) | Actual value that caused the validation failure | Potentially PII |
| ERROR_SEVERITY | VARCHAR(20) | Severity level of the error | Non-PII |
| ERROR_DATE | DATE | Date when the error was detected | Non-PII |
| ERROR_TIMESTAMP | TIMESTAMP_NTZ(9) | Precise timestamp of error detection | Non-PII |
| RESOLUTION_STATUS | VARCHAR(30) | Error resolution status | Non-PII |
| RESOLUTION_ACTION | VARCHAR(500) | Action taken to resolve the error | Non-PII |
| VALIDATION_RULE_NAME | VARCHAR(200) | Name of the validation rule that failed | Non-PII |
| LOAD_TIMESTAMP | TIMESTAMP_NTZ(9) | Error record creation timestamp | Non-PII |

### 1.5 AGGREGATED TABLES

#### 1.5.1 Table: Go_DAILY_USAGE_SUMMARY
**Description**: Daily aggregated metrics for platform usage and adoption analysis
**Table Type**: Aggregated
**SCD Type**: N/A (Aggregated Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| SUMMARY_DATE | DATE | Date for which metrics are aggregated | Non-PII |
| TOTAL_MEETINGS | INTEGER | Total number of meetings conducted | Non-PII |
| TOTAL_MEETING_MINUTES | INTEGER | Sum of all meeting durations | Non-PII |
| UNIQUE_HOSTS | INTEGER | Number of unique meeting hosts | Non-PII |
| UNIQUE_PARTICIPANTS | INTEGER | Number of unique meeting participants | Non-PII |
| AVERAGE_MEETING_DURATION | DECIMAL(10,2) | Average meeting duration in minutes | Non-PII |
| AVERAGE_PARTICIPANTS_PER_MEETING | DECIMAL(10,2) | Average number of participants per meeting | Non-PII |
| TOTAL_FEATURE_USAGE | INTEGER | Total feature usage count | Non-PII |
| BUSINESS_HOURS_MEETINGS | INTEGER | Number of meetings during business hours | Non-PII |
| WEEKEND_MEETINGS | INTEGER | Number of meetings during weekends | Non-PII |
| NEW_USER_REGISTRATIONS | INTEGER | Number of new user registrations | Non-PII |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| UPDATE_DATE | DATE | Date when record was last updated | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.5.2 Table: Go_MONTHLY_REVENUE_SUMMARY
**Description**: Monthly aggregated revenue and billing metrics
**Table Type**: Aggregated
**SCD Type**: N/A (Aggregated Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| SUMMARY_MONTH | DATE | Month for which revenue is aggregated | Non-PII |
| TOTAL_REVENUE | DECIMAL(15,2) | Total revenue for the month | Non-PII |
| SUBSCRIPTION_REVENUE | DECIMAL(15,2) | Revenue from subscriptions | Non-PII |
| UPGRADE_REVENUE | DECIMAL(15,2) | Revenue from plan upgrades | Non-PII |
| NEW_CUSTOMER_REVENUE | DECIMAL(15,2) | Revenue from new customers | Non-PII |
| TOTAL_TRANSACTIONS | INTEGER | Total number of billing transactions | Non-PII |
| SUCCESSFUL_TRANSACTIONS | INTEGER | Number of successful transactions | Non-PII |
| FAILED_TRANSACTIONS | INTEGER | Number of failed transactions | Non-PII |
| AVERAGE_TRANSACTION_VALUE | DECIMAL(12,2) | Average transaction amount | Non-PII |
| UNIQUE_PAYING_CUSTOMERS | INTEGER | Number of unique paying customers | Non-PII |
| CHURN_COUNT | INTEGER | Number of customers who churned | Non-PII |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| UPDATE_DATE | DATE | Date when record was last updated | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

#### 1.5.3 Table: Go_SUPPORT_METRICS_SUMMARY
**Description**: Aggregated support ticket metrics for service reliability analysis
**Table Type**: Aggregated
**SCD Type**: N/A (Aggregated Table)

| Column Name | Data Type | Description | PII Classification |
|-------------|-----------|-------------|-------------------|
| SUMMARY_DATE | DATE | Date for which support metrics are aggregated | Non-PII |
| TOTAL_TICKETS_OPENED | INTEGER | Total number of tickets opened | Non-PII |
| TOTAL_TICKETS_RESOLVED | INTEGER | Total number of tickets resolved | Non-PII |
| AVERAGE_RESOLUTION_TIME_HOURS | DECIMAL(10,2) | Average resolution time in hours | Non-PII |
| AVERAGE_FIRST_RESPONSE_TIME_HOURS | DECIMAL(10,2) | Average first response time in hours | Non-PII |
| CRITICAL_TICKETS | INTEGER | Number of critical priority tickets | Non-PII |
| HIGH_PRIORITY_TICKETS | INTEGER | Number of high priority tickets | Non-PII |
| ESCALATED_TICKETS | INTEGER | Number of escalated tickets | Non-PII |
| SLA_BREACHED_TICKETS | INTEGER | Number of tickets with SLA breach | Non-PII |
| FIRST_CONTACT_RESOLUTION_COUNT | INTEGER | Number of tickets resolved on first contact | Non-PII |
| FIRST_CONTACT_RESOLUTION_RATE | DECIMAL(5,2) | First contact resolution rate percentage | Non-PII |
| TICKETS_BY_TECHNICAL | INTEGER | Number of technical support tickets | Non-PII |
| TICKETS_BY_BILLING | INTEGER | Number of billing related tickets | Non-PII |
| LOAD_DATE | DATE | Date when record was loaded into Gold layer | Non-PII |
| UPDATE_DATE | DATE | Date when record was last updated | Non-PII |
| SOURCE_SYSTEM | VARCHAR(100) | Source system identifier | Non-PII |

## 2. Conceptual Data Model Diagram

### 2.1 Table Relationships and Key Fields

| Primary Table | Related Table | Relationship Key Field | Relationship Type | Description |
|---------------|---------------|------------------------|-------------------|-------------|
| Go_USER_DIMENSION | Go_MEETING_FACTS | USER_NAME → HOST_NAME | One-to-Many | Users host multiple meetings |
| Go_TIME_DIMENSION | Go_MEETING_FACTS | DATE_KEY → MEETING_DATE | One-to-Many | Time dimension for meeting analysis |
| Go_USER_DIMENSION | Go_BILLING_FACTS | USER_NAME → USER_NAME | One-to-Many | Users generate multiple billing events |
| Go_TIME_DIMENSION | Go_BILLING_FACTS | DATE_KEY → TRANSACTION_DATE | One-to-Many | Time dimension for billing analysis |
| Go_USER_DIMENSION | Go_SUPPORT_FACTS | USER_NAME → USER_NAME | One-to-Many | Users create multiple support tickets |
| Go_TIME_DIMENSION | Go_SUPPORT_FACTS | DATE_KEY → TICKET_DATE | One-to-Many | Time dimension for support analysis |
| Go_LICENSE_DIMENSION | Go_USER_DIMENSION | LICENSE_TYPE → PLAN_TYPE | One-to-Many | License types assigned to users |
| Go_FEATURE_DIMENSION | Go_MEETING_FACTS | FEATURE_NAME → Feature Usage | Many-to-Many | Features used in meetings |
| Go_TIME_DIMENSION | Go_DAILY_USAGE_SUMMARY | DATE_KEY → SUMMARY_DATE | One-to-One | Time dimension for daily summaries |
| Go_TIME_DIMENSION | Go_MONTHLY_REVENUE_SUMMARY | DATE_KEY → SUMMARY_MONTH | One-to-One | Time dimension for monthly summaries |
| Go_TIME_DIMENSION | Go_SUPPORT_METRICS_SUMMARY | DATE_KEY → SUMMARY_DATE | One-to-One | Time dimension for support summaries |

## 3. ER Diagram Visualization

### 3.1 Gold Layer ER Diagram - Block Format

```
                    ┌─────────────────────┐
                    │   Go_TIME_DIMENSION │
                    │                     │
                    │ - DATE_KEY          │
                    │ - YEAR              │
                    │ - QUARTER           │
                    │ - MONTH             │
                    │ - DAY_NAME          │
                    │ - IS_BUSINESS_DAY   │
                    └─────────────────────┘
                              │
                              │ (1:M)
                              ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│  Go_USER_DIMENSION  │────│  Go_MEETING_FACTS   │────│ Go_FEATURE_DIMENSION│
│                     │    │                     │    │                     │
│ - USER_NAME         │    │ - MEETING_DATE      │    │ - FEATURE_NAME      │
│ - EMAIL_ADDRESS     │    │ - HOST_NAME         │    │ - FEATURE_CATEGORY  │
│ - COMPANY           │    │ - MEETING_TOPIC     │    │ - FEATURE_TYPE      │
│ - PLAN_TYPE         │    │ - DURATION_MINUTES  │    │ - AVAILABILITY_PLAN │
│ - USER_SEGMENT      │    │ - PARTICIPANT_COUNT │    │ - FEATURE_STATUS    │
│ - GEOGRAPHIC_REGION │    │ - MEETING_TYPE      │    └─────────────────────┘
└─────────────────────┘    └─────────────────────┘
         │                           │
         │ (1:M)                     │ (1:M)
         ▼                           ▼
┌─────────────────────┐    ┌─────────────────────┐
│  Go_BILLING_FACTS   │    │  Go_SUPPORT_FACTS   │
│                     │    │                     │
│ - TRANSACTION_DATE  │    │ - TICKET_DATE       │
│ - USER_NAME         │    │ - USER_NAME         │
│ - EVENT_TYPE        │    │ - TICKET_TYPE       │
│ - AMOUNT            │    │ - PRIORITY_LEVEL    │
│ - CURRENCY_CODE     │    │ - RESOLUTION_TIME   │
│ - PLAN_TYPE         │    │ - SLA_BREACH_FLAG   │
└─────────────────────┘    └─────────────────────┘
         │                           │
         │                           │
         ▼                           ▼
┌─────────────────────┐    ┌─────────────────────┐
│Go_LICENSE_DIMENSION │    │ Go_SUPPORT_METRICS_ │
│                     │    │      SUMMARY        │
│ - LICENSE_TYPE      │    │                     │
│ - LICENSE_CATEGORY  │    │ - SUMMARY_DATE      │
│ - PRICE_TIER        │    │ - TOTAL_TICKETS     │
│ - MAX_PARTICIPANTS  │    │ - AVG_RESOLUTION    │
│ - SUPPORT_LEVEL     │    │ - SLA_BREACHED      │
└─────────────────────┘    └─────────────────────┘

┌─────────────────────┐    ┌─────────────────────┐
│Go_DAILY_USAGE_      │    │Go_MONTHLY_REVENUE_  │
│     SUMMARY         │    │     SUMMARY         │
│                     │    │                     │
│ - SUMMARY_DATE      │    │ - SUMMARY_MONTH     │
│ - TOTAL_MEETINGS    │    │ - TOTAL_REVENUE     │
│ - UNIQUE_HOSTS      │    │ - SUBSCRIPTION_REV  │
│ - AVG_DURATION      │    │ - NEW_CUSTOMER_REV  │
│ - FEATURE_USAGE     │    │ - CHURN_COUNT       │
└─────────────────────┘    └─────────────────────┘

┌─────────────────────┐    ┌─────────────────────┐
│ Go_PIPELINE_AUDIT   │    │Go_DATA_VALIDATION_  │
│                     │    │      ERRORS         │
│ - AUDIT_KEY         │    │                     │
│ - PIPELINE_NAME     │    │ - ERROR_KEY         │
│ - EXECUTION_STATUS  │    │ - SOURCE_TABLE      │
│ - RECORDS_PROCESSED │    │ - ERROR_TYPE        │
│ - EXECUTION_TIME    │    │ - ERROR_SEVERITY    │
└─────────────────────┘    └─────────────────────┘
```

## 4. Design Rationale and Key Decisions

### 4.1 Dimensional Modeling Approach
1. **Star Schema Design**: Implemented classic star schema with fact tables at the center connected to dimension tables
2. **Conformed Dimensions**: Created shared dimensions (Time, User) that can be used across multiple fact tables
3. **Slowly Changing Dimensions**: Applied SCD Type 2 for User and License dimensions to track historical changes

### 4.2 Fact Table Design
1. **Meeting Facts**: Central fact table capturing meeting activities with metrics for platform usage analysis
2. **Billing Facts**: Financial transaction facts for revenue analysis and billing insights
3. **Support Facts**: Support ticket facts for service reliability and customer satisfaction metrics

### 4.3 Aggregation Strategy
1. **Daily Usage Summary**: Pre-aggregated daily metrics for faster dashboard performance
2. **Monthly Revenue Summary**: Monthly financial aggregations for executive reporting
3. **Support Metrics Summary**: Daily support KPIs for operational monitoring

### 4.4 Data Quality and Audit Framework
1. **Pipeline Audit**: Comprehensive tracking of ETL processes with performance metrics
2. **Data Validation Errors**: Detailed error tracking for data quality monitoring
3. **Metadata Columns**: Consistent load_date, update_date, and source_system tracking

### 4.5 PII Classification and Security
1. **PII Identification**: Classified all columns containing personally identifiable information
2. **Data Masking**: Applied appropriate masking for sensitive fields in dimension tables
3. **Compliance Ready**: Structure supports GDPR and other privacy regulation requirements

### 4.6 Performance Optimization
1. **Naming Convention**: Consistent 'Go_' prefix for all Gold layer tables
2. **Indexing Strategy**: Designed for optimal query performance on common filter columns
3. **Partitioning Ready**: Date-based columns support time-based partitioning

## 5. Key Assumptions

1. **Source Data Quality**: Silver layer provides cleansed and validated data as input
2. **Business Rules**: Applied business logic from constraints document for data transformations
3. **Reporting Requirements**: Designed to support all KPIs identified in conceptual model
4. **Scalability**: Model supports growth in data volume and additional business requirements
5. **Real-time vs Batch**: Designed for batch processing with near real-time capabilities
6. **Data Retention**: Assumes standard data retention policies for different data types
7. **Multi-tenancy**: Structure supports potential multi-tenant deployment scenarios
8. **Compliance**: Designed to meet enterprise data governance and compliance requirements

---

**Note**: This Gold layer logical data model implements medallion architecture principles by providing analytics-ready data through dimensional modeling. The model supports efficient querying for reporting and analytics, maintains comprehensive audit trails, and includes robust error handling capabilities. All tables are designed without traditional primary/foreign key constraints while maintaining referential relationships through business keys, enabling flexible analytics and reporting scenarios.