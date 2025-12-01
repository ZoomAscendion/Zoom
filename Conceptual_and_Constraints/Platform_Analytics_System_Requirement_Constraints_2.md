____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Updated Model Data Constraints for Platform Analytics System aligned with dimensional modeling approach
## *Version*: 2
## *Changes*: Restructured constraints to align with dimensional modeling approach, removed Revenue & License Analysis section, updated constraints to match fact and dimension table structure, refined business rules to support star schema design
## *Reason*: The original constraints needed to be updated to align with the current report requirements and support the dimensional modeling structure implemented in the conceptual data model
## *Updated on*: 
_____________________________________________

#   Platform Analytics System - Model Data Constraints

## 1. Data Expectations

### 1.1 Platform Usage & Adoption Data Expectations

1. **Fact Meeting Activity Data Completeness**
   - Meeting Duration Minutes must be non-negative integers representing actual meeting length
   - Number of Attendees must be positive integers (minimum value of 1 for host)
   - Meeting Start Time and Meeting End Time must be valid timestamps with proper timezone information
   - All fact records must have valid foreign keys to dimension tables

2. **Fact Feature Usage Data Accuracy**
   - Feature Usage Count must be non-negative integers
   - Feature Usage Duration Minutes must not exceed the associated meeting duration
   - Usage Start Time must be within the meeting time window
   - Feature Key must reference valid entries in Dim Feature table

3. **Dim User Data Integrity**
   - User Name must be provided for all user records (non-null)
   - User Email must follow valid email format and be unique
   - Plan Type must be from predefined values: ['Free', 'Basic', 'Pro', 'Enterprise']
   - Registration Date must be chronologically valid and not in the future
   - User Status must be from predefined values: ['Active', 'Inactive', 'Suspended']

4. **Dim Meeting Data Consistency**
   - Meeting Type must be from predefined categories: ['Scheduled', 'Instant', 'Webinar', 'Recurring']
   - Meeting Topic must be provided for all meeting records
   - Host Name must reference a valid user in the system
   - Meeting Category must follow standardized business classification

5. **Dim Feature Data Quality**
   - Feature Name must follow standardized naming conventions
   - Feature Category must be from predefined groupings: ['Communication', 'Collaboration', 'Security']
   - Feature Status must be current and accurate: ['Active', 'Deprecated', 'Beta']
   - Feature Description must provide meaningful functionality details

6. **Dim Date Data Completeness**
   - Date Value must be in standard date format
   - Day of Week, Month Name, Quarter, and Year must be correctly calculated
   - Is Weekend and Is Holiday flags must be accurately set
   - Date dimension must cover all required date ranges for analysis

### 1.2 Service Reliability & Support Data Expectations

1. **Fact Support Activity Data Quality**
   - Resolution Status must be from predefined values: ['Open', 'In Progress', 'Resolved', 'Closed']
   - Priority Level must be assigned to all support records: ['Critical', 'High', 'Medium', 'Low']
   - Open Date must be valid timestamp when support ticket was created
   - Close Date must be provided for resolved/closed tickets and be after Open Date
   - Resolution Time Hours must be calculated accurately based on business hours

2. **Dim Support Category Data Integrity**
   - Category Name must be from predefined primary categories: ['Technical', 'Billing', 'Feature Request']
   - Sub Category Name must provide detailed classification within main category
   - Category Description must explain the scope of the support category
   - Escalation Level must indicate required support tier for handling

## 2. Constraints

### 2.1 Data Type and Format Constraints

1. **Temporal Constraints**
   - Meeting Start Time and Meeting End Time must be valid timestamp formats with timezone
   - Meeting Duration Minutes must be calculated as difference between end and start times
   - Usage Start Time must be valid timestamp within meeting duration
   - Open Date and Close Date must be valid date formats
   - Resolution Time Hours must be positive decimal numbers

2. **Numeric Constraints**
   - Meeting Duration Minutes must be non-negative integers (≥ 0)
   - Number of Attendees must be positive integers (≥ 1)
   - Feature Usage Count must be non-negative integers (≥ 0)
   - Feature Usage Duration Minutes must be ≤ Meeting Duration Minutes
   - Resolution Time Hours must be positive for closed tickets

3. **String and Categorical Constraints**
   - User Name must not exceed 255 characters and be non-null
   - User Email must follow valid email format (contains @ and domain)
   - Plan Type must be from enumerated values: ['Free', 'Basic', 'Pro', 'Enterprise']
   - Meeting Type must be from: ['Scheduled', 'Instant', 'Webinar', 'Recurring']
   - Resolution Status must be from: ['Open', 'In Progress', 'Resolved', 'Closed']
   - Priority Level must be from: ['Critical', 'High', 'Medium', 'Low']
   - Feature Status must be from: ['Active', 'Deprecated', 'Beta']

### 2.2 Referential Integrity Constraints

1. **Fact to Dimension Relationships**
   - User Key in Fact Meeting Activity must exist in Dim User
   - Meeting Key in Fact Meeting Activity must exist in Dim Meeting
   - Date Key in Fact Meeting Activity must exist in Dim Date
   - User Key in Fact Support Activity must exist in Dim User
   - Support Category Key in Fact Support Activity must exist in Dim Support Category
   - Date Key in Fact Support Activity must exist in Dim Date
   - Feature Key in Fact Feature Usage must exist in Dim Feature
   - Meeting Key in Fact Feature Usage must exist in Dim Meeting
   - User Key in Fact Feature Usage must exist in Dim User
   - Date Key in Fact Feature Usage must exist in Dim Date

2. **Uniqueness Constraints**
   - User Key must be unique in Dim User table
   - Meeting Key must be unique in Dim Meeting table
   - Feature Key must be unique in Dim Feature table
   - Support Category Key must be unique in Dim Support Category table
   - Date Key must be unique in Dim Date table
   - User Email must be unique across all users

### 2.3 Business Logic Constraints

1. **Meeting Duration and Time Constraints**
   - Meeting End Time must be after Meeting Start Time
   - Meeting Duration Minutes must equal calculated difference between end and start times
   - Feature Usage Duration Minutes cannot exceed Meeting Duration Minutes
   - Usage Start Time must be between Meeting Start Time and Meeting End Time

2. **Support Ticket Lifecycle Constraints**
   - Close Date must be after Open Date for resolved/closed tickets
   - Open tickets cannot have Close Date values
   - Resolution Time Hours must be calculated only for closed tickets
   - Priority Level cannot be changed once ticket is closed

3. **Dimensional Model Constraints**
   - All fact tables must have valid foreign keys to required dimension tables
   - Dimension tables must not have null values in key business attributes
   - Date dimension must be populated for all required date ranges
   - Feature dimension must be updated when new features are released

## 3. Business Rules

### 3.1 Platform Usage & Adoption Business Rules

1. **User Activity Classification Rules**
   - Active users are defined as those who hosted at least one meeting in the measurement period
   - Meeting participation is tracked through Fact Meeting Activity records
   - Feature adoption is measured by unique users utilizing specific features
   - User engagement is calculated based on meeting frequency and duration

2. **Meeting Analysis Rules**
   - Average Meeting Duration is calculated across all meetings within the specified time period
   - Meeting Duration by Type provides insights into different meeting patterns
   - Meeting Duration by Category helps understand business use cases
   - Number of Meetings per User indicates individual user engagement levels

3. **Feature Usage Analysis Rules**
   - Feature Usage Distribution shows adoption rates across different platform capabilities
   - Feature usage is tracked per meeting session through Fact Feature Usage
   - Feature adoption trends are analyzed over time using Date dimension
   - Feature performance is measured by usage frequency and duration

4. **KPI Calculation Rules**
   - Total Number of Users: COUNT(DISTINCT User Key) from fact tables
   - Average Meeting Duration: AVG(Meeting Duration Minutes) from Fact Meeting Activity
   - Number of Meetings Created per User: COUNT(Meeting Key) / COUNT(DISTINCT User Key)
   - Feature Usage Distribution: Percentage breakdown by Feature Name

### 3.2 Service Reliability & Support Business Rules

1. **Support Ticket Classification Rules**
   - Support tickets are categorized by Category Name and Sub Category Name
   - Priority Level determines response time requirements and resource allocation
   - Resolution Status tracks ticket lifecycle from creation to closure
   - Escalation Level defines the support tier required for resolution

2. **Support Metrics Calculation Rules**
   - Number of Users by Support Category: COUNT(DISTINCT User Key) grouped by Category Name
   - Number of Users by Support Sub Category: COUNT(DISTINCT User Key) grouped by Sub Category Name
   - Number of Support Activities by Resolution Status: COUNT(*) grouped by Resolution Status
   - Number of Support Activities by Priority: COUNT(*) grouped by Priority Level
   - Average Resolution Time: AVG(Resolution Time Hours) for closed tickets

3. **Support Performance Rules**
   - Resolution time is calculated in business hours excluding weekends and holidays
   - Support ticket volume trends are analyzed using Date dimension
   - User support patterns are identified through support category analysis
   - Support efficiency is measured by resolution time and status distribution

### 3.3 Data Processing and Transformation Rules

1. **Dimensional Model Processing Rules**
   - Fact tables are loaded after dimension tables to ensure referential integrity
   - Slowly Changing Dimensions (SCD) are handled appropriately for user and feature changes
   - Date dimension is pre-populated with required date ranges
   - Surrogate keys are used for all dimension table primary keys

2. **Data Quality and Validation Rules**
   - All fact records must pass referential integrity checks before loading
   - Dimension records are validated for completeness and accuracy
   - Data lineage is maintained for all transformations
   - Error handling processes capture and log data quality issues

3. **Aggregation and Calculation Rules**
   - Daily metrics are calculated using UTC timezone
   - Weekly metrics follow Monday-to-Sunday calendar weeks
   - Monthly metrics use calendar month boundaries
   - All percentage calculations are rounded to 2 decimal places

### 3.4 Reporting and Analytics Rules

1. **Report Generation Standards**
   - Platform Usage & Adoption reports focus on user engagement and feature utilization
   - Service Reliability & Support reports emphasize ticket resolution and user satisfaction
   - All reports use consistent date ranges and filtering criteria
   - KPIs are calculated using standardized formulas across all reports

2. **Data Refresh and Update Rules**
   - Fact tables are updated in near real-time as events occur
   - Dimension tables are updated as master data changes
   - Report data is refreshed according to business requirements
   - Historical data is preserved for trend analysis

3. **Performance and Optimization Rules**
   - Star schema design optimizes query performance for analytical workloads
   - Appropriate indexing is maintained on dimension keys and date columns
   - Partitioning strategies are implemented based on date ranges
   - Query performance is monitored and optimized regularly

### 3.5 Data Governance and Compliance Rules

1. **Data Security Rules**
   - User personal information is protected according to privacy regulations
   - Access to sensitive data is controlled through role-based permissions
   - Data masking is applied in non-production environments
   - Audit trails are maintained for all data access and modifications

2. **Data Retention Rules**
   - Fact data is retained according to business and regulatory requirements
   - Dimension data is maintained for historical consistency
   - Archived data is accessible for compliance and audit purposes
   - Data deletion follows approved data lifecycle policies

3. **Data Quality Monitoring Rules**
   - Automated data quality checks are performed on all data loads
   - Data quality metrics are tracked and reported regularly
   - Data quality issues are escalated and resolved promptly
   - Data quality standards are maintained across all system components
