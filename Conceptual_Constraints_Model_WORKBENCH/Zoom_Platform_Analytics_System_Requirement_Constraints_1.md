____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Model data constraints and business rules for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
____________________________________________

# Model Data Constraints - Zoom Platform Analytics System

## 1. Data Expectations

### 1.1 Data Completeness
1. All meeting records must have complete Duration_Minutes, Start_Time, and End_Time information
2. User information must be complete for accurate user counting and categorization
3. Feature usage records must contain valid Feature_Name and usage count data
4. Support activity records must have complete Resolution_Status and Priority Level information
5. Meeting Activity records must contain valid User Key and Meeting ID references

### 1.2 Data Accuracy
1. Duration_Minutes must accurately reflect the actual meeting duration
2. Start_Time and End_Time must be consistent and logically ordered
3. User counts and meeting counts must be accurate for reliable KPI calculations
4. Feature usage counts must accurately represent actual feature utilization
5. Support category classifications must be correctly assigned

### 1.3 Data Format
1. Duration_Minutes must be stored as non-negative integer values
2. Start_Time and End_Time must follow valid timestamp format
3. Date keys must follow consistent date formatting standards
4. User names and meeting topics must follow standardized text formatting
5. Resolution_Status and Priority Level must follow predefined format standards

### 1.4 Data Consistency
1. Meeting duration calculations must be consistent across all reports
2. User categorization must be consistent between usage and support analytics
3. Date references must be consistent across all fact and dimension tables
4. Feature names must be consistently referenced across usage records
5. Support category classifications must be consistent across all support activities

## 2. Constraints

### 2.1 Mandatory Fields
1. **Duration_Minutes**: Required for all meeting records to calculate average meeting duration KPIs
2. **Start_Time**: Mandatory for meeting scheduling and temporal analysis
3. **End_Time**: Required for meeting duration calculations and completion tracking
4. **Meeting_ID**: Essential for establishing relationships between meetings and activities
5. **User_Key**: Required for user-based analytics and relationship establishment
6. **Feature_Name**: Mandatory for feature usage distribution analysis
7. **Resolution_Status**: Required for support activity tracking and status reporting
8. **Date_Key**: Essential for temporal relationships and time-based analytics

### 2.2 Uniqueness Requirements
1. **Meeting_ID**: Must be unique across all meeting records
2. **User_Key**: Must uniquely identify individual users across the system
3. **Feature_Key**: Must uniquely identify each platform feature
4. **Support_Category_Key**: Must uniquely identify support categories
5. **Date_Key**: Must uniquely represent each date in the time dimension

### 2.3 Data Type Limitations
1. **Duration_Minutes**: Must be non-negative integer values only
2. **Start_Time**: Must be valid timestamp format with proper date-time structure
3. **End_Time**: Must be valid timestamp format with proper date-time structure
4. **User_Key**: Must be consistent identifier format across all references
5. **Feature_Usage_Count**: Must be non-negative integer values
6. **Open_Date**: Must be valid date format for support ticket creation

### 2.4 Dependencies
1. Meeting Activity records depend on valid Meeting_ID existing in Meetings table
2. Feature Usage records depend on valid Feature_Key existing in Features dimension
3. Support Activity records depend on valid User_Key existing in Users dimension
4. All fact table records depend on valid Date_Key existing in Date dimension
5. End_Time must be greater than or equal to Start_Time for meeting records

### 2.5 Referential Integrity
1. **Meeting Activity to Meetings**: Meeting_ID in Meeting Activity must exist in Meetings table
2. **Meeting Activity to Users**: User_Key in Meeting Activity must exist in Users table
3. **Feature Usage to Features**: Feature_Key in Feature Usage must exist in Features dimension
4. **Support Activity to Users**: User_Key in Support Activity must exist in Users table
5. **Support Activity to Support Category**: Support_Category_Key must exist in Support Category dimension

## 3. Business Rules

### 3.1 Data Processing Rules
1. Meeting duration calculations must exclude any meetings with invalid or missing time data
2. User counts must exclude duplicate or inactive user records
3. Feature usage aggregations must sum all valid usage counts per feature
4. Support activity counts must include only records with valid resolution status
5. Average calculations must exclude zero or null duration values

### 3.2 Reporting Logic Rules
1. Total Number of Users KPI must count unique active users only
2. Average Meeting Duration must be calculated using valid meeting records with complete time data
3. Feature Usage Distribution must represent percentage of total feature utilization
4. Support activities must be categorized according to predefined category and subcategory lists
5. Meeting per user calculations must consider only completed meetings

### 3.3 Transformation Guidelines
1. Duration_Minutes must be derived from Start_Time and End_Time differences when not directly provided
2. User categorization for support must align with meeting user classifications
3. Date keys must be consistently formatted across all dimensional relationships
4. Feature usage counts must be aggregated at appropriate granularity levels
5. Support priority levels must follow organizational priority classification standards
6. Meeting types and categories must follow standardized classification schemes
7. Resolution status values must be limited to predefined organizational status list