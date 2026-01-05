____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Model Data Constraints for Zoom Platform Analytics System reporting requirements
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Model Data Constraints - Zoom Platform Analytics System

## 1. Data Expectations

### 1.1 Platform Usage & Adoption Report Data Expectations

1. **User Information Completeness**
   - All user records must have valid User_ID
   - User names must be present and non-null
   - Meeting types must be categorized consistently
   - Meeting topics must be properly classified

2. **Meeting Information Accuracy**
   - Meeting_ID must be unique and non-null for each meeting record
   - Duration_Minutes must be accurately calculated and recorded
   - Start_Time must be captured with precise timestamps
   - End_Time must be logically consistent with Start_Time and Duration

3. **Feature Usage Data Consistency**
   - Feature_Name must be standardized across all records
   - Feature usage counts must be accurate and aggregated properly
   - Feature usage must be linked to valid meetings and users

4. **Calculated Metrics Accuracy**
   - Total Number of users must reflect unique active users
   - Average Meeting duration calculations must exclude invalid or zero-duration meetings
   - Meeting counts per user must be accurately aggregated

### 1.2 Service Reliability & Support Report Data Expectations

1. **Support Activity Data Completeness**
   - All support activities must have valid User_ID references
   - Category and Sub Category must be properly classified
   - Resolution Status must be current and accurate
   - Priority Level must be assigned according to business rules

2. **User Support Information Accuracy**
   - User information must be consistent across support and platform usage data
   - Support categories must align with predefined classification standards
   - Resolution status updates must be timely and accurate

## 2. Constraints

### 2.1 Data Type and Format Constraints

1. **Meeting Data Constraints**
   - Duration_Minutes: Must be non-negative integer values only
   - Start_Time: Must be valid timestamp format (YYYY-MM-DD HH:MM:SS)
   - End_Time: Must be valid timestamp format (YYYY-MM-DD HH:MM:SS)
   - Meeting_ID: Must be unique identifier, non-null

2. **User Data Constraints**
   - User_ID: Must be unique identifier, non-null
   - User names: Must be non-empty strings
   - Meeting types: Must be from predefined list of valid meeting types

3. **Support Data Constraints**
   - Type: Must be from predefined list of support types
   - Resolution_Status: Must be from predefined list of valid status values
   - Open_Date: Must be valid date format (YYYY-MM-DD)
   - Priority Level: Must be from predefined priority classification

### 2.2 Referential Integrity Constraints

1. **Meeting Activity Relationships**
   - Meeting_ID in Meeting Activity must exist in the Meetings table
   - User_ID in Meeting Activity must exist in the Users table
   - Feature references in Feature Usage must exist in Dim Feature table

2. **Support Activity Relationships**
   - User_ID in Support Activity must exist in the Users table
   - Support categories must reference valid Dim Support Category entries
   - Date references must exist in Dim Date table

3. **Dimension Table Relationships**
   - Dimension tables must maintain one-to-many or many-to-many relationships with fact tables
   - All foreign key references must be valid and maintained

### 2.3 Mandatory Field Constraints

1. **Required Fields for Platform Usage Report**
   - User_ID (mandatory)
   - Meeting_ID (mandatory)
   - Duration_Minutes (mandatory)
   - Start_Time (mandatory)
   - Feature_Name (mandatory for feature usage records)

2. **Required Fields for Service Reliability Report**
   - User_ID (mandatory)
   - Category (mandatory)
   - Resolution_Status (mandatory)
   - Open_Date (mandatory)
   - Priority Level (mandatory)

### 2.4 Uniqueness Constraints

1. **Primary Key Constraints**
   - Meeting_ID must be unique across all meeting records
   - User_ID must be unique across all user records
   - Support Activity records must have unique identifiers

2. **Business Uniqueness Rules**
   - Each user can have multiple meetings but each meeting occurrence must be unique
   - Feature usage records must be unique per user per meeting per feature

## 3. Business Rules

### 3.1 Platform Usage & Adoption Business Rules

1. **Meeting Duration Calculation Rules**
   - Average meeting duration must exclude meetings with zero or negative duration
   - Meeting duration calculations must be grouped by meeting type and category
   - Duration calculations must handle time zone differences appropriately

2. **User Activity Classification Rules**
   - Active users are defined as users who participated in at least one meeting
   - Meeting counts per user include all meeting types and categories
   - Feature usage distribution must be calculated based on actual usage events

3. **Data Aggregation Rules**
   - Total user counts must eliminate duplicate user records
   - Meeting statistics must be aggregated at appropriate time intervals
   - Feature usage metrics must reflect actual feature engagement

### 3.2 Service Reliability & Support Business Rules

1. **Support Category Classification Rules**
   - Support categories must follow predefined taxonomy
   - Sub-categories must be valid children of their parent categories
   - Category assignments must be consistent across similar issues

2. **Resolution Status Management Rules**
   - Resolution status must follow defined workflow states
   - Status transitions must follow business-approved sequences
   - Open tickets must have valid open dates

3. **Priority Level Assignment Rules**
   - Priority levels must be assigned based on business impact criteria
   - Priority classifications must be consistent across similar issue types
   - High-priority issues must have appropriate escalation tracking

### 3.3 Data Processing and Transformation Rules

1. **Data Quality Rules**
   - All data must pass validation checks before inclusion in reports
   - Invalid or incomplete records must be flagged and excluded from calculations
   - Data refresh cycles must maintain consistency across all related tables

2. **Reporting Logic Rules**
   - KPI calculations must use standardized formulas across all reports
   - Metric definitions must be consistent with business requirements
   - Report data must reflect the most current available information

3. **Data Relationship Rules**
   - Fact tables must maintain proper relationships with dimension tables
   - Cross-report data must be consistent and reconcilable
   - Historical data must be preserved for trend analysis

### 3.4 Compliance and Governance Rules

1. **Data Accuracy Standards**
   - All reported metrics must be verifiable against source systems
   - Data lineage must be traceable for audit purposes
   - Error rates in data processing must be within acceptable thresholds

2. **Data Consistency Standards**
   - Naming conventions must be followed consistently across all data elements
   - Data formats must be standardized across all reporting components
   - Business definitions must be applied uniformly across all reports