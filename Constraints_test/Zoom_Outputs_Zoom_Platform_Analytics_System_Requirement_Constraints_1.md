____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Model data constraints and business rules for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
____________________________________________

## 1. Data Expectations

### 1.1 Data Completeness
1. All meetings must have valid Host_ID references to existing users in the Users table
2. Meeting duration data must be complete for accurate total meeting minutes calculations
3. User plan type information must be available for all users to enable usage pattern analysis
4. Feature usage data must be linked to valid meetings for adoption rate calculations
5. Support ticket data must include user associations for user-to-ticket ratio analysis
6. Billing events must be associated with valid users for revenue tracking
7. License assignments must reference existing users for utilization rate calculations

### 1.2 Data Accuracy
1. Meeting duration calculations must accurately reflect actual meeting lengths
2. Active user counts must correctly identify unique users who hosted at least one meeting
3. Feature adoption rates must accurately measure proportion of users utilizing specific features
4. Ticket resolution times must precisely calculate time between open and close dates
5. Revenue calculations must accurately sum all monetary amounts from billing events
6. License utilization rates must correctly represent assigned versus available licenses
7. Churn rate calculations must accurately identify users who stopped using the platform

### 1.3 Data Format
1. Duration_Minutes must be stored as non-negative integers for consistent calculations
2. Start_Time and End_Time must follow valid timestamp formats for temporal analysis
3. Amount fields must be stored as positive numbers for revenue calculations
4. Date fields (Open_Date, Start_Date, End_Date) must use consistent date formats
5. User_ID, Meeting_ID references must maintain consistent identifier formats
6. Type and Resolution_Status must use standardized categorical values
7. License_Type must follow predefined enumeration values

### 1.4 Data Consistency
1. Foreign key relationships must be maintained across all entity relationships
2. Meeting start times must be before end times for duration calculations
3. License start dates must precede end dates for validity period tracking
4. User plan types must align with assigned license types
5. Feature usage counts must correspond to actual meeting occurrences
6. Support ticket user references must match existing user records
7. Billing event user associations must correspond to valid user accounts

## 2. Constraints

### 2.1 Mandatory Fields
1. User_ID: Required for all user-related analytics and cross-report correlation
2. Meeting_ID: Essential for meeting-based calculations and feature usage tracking
3. Duration_Minutes: Mandatory for total meeting minutes and average duration calculations
4. Host_ID: Required to link meetings to users for active user metrics
5. Plan_Type: Necessary for usage pattern analysis by subscription level
6. Amount: Required for all revenue calculations and billing analysis
7. License_Type: Essential for license utilization and revenue by license type analysis

### 2.2 Uniqueness Requirements
1. User_ID: Must be unique across the Users entity for proper user identification
2. Meeting_ID: Must be unique across the Meetings entity for accurate meeting tracking
3. Support ticket identifiers: Must be unique for proper ticket resolution tracking
4. License assignments: Each license must have unique assignment to prevent conflicts
5. Billing event identifiers: Must be unique to prevent duplicate revenue counting

### 2.3 Data Type Limitations
1. Duration_Minutes: Must be non-negative integer values only
2. Amount: Must be positive numeric values for billing events
3. Usage_Count: Must be non-negative integer values for feature usage tracking
4. Start_Time/End_Time: Must be valid timestamp data types
5. Date fields: Must be valid date data types (Open_Date, Start_Date, End_Date)
6. User_ID/Meeting_ID: Must be consistent identifier data types across relationships

### 2.4 Dependencies
1. Attendees entity depends on valid Meeting_ID references in Meetings table
2. Features_Usage entity requires valid Meeting_ID references for feature adoption analysis
3. Support_Tickets entity depends on valid User_ID references in Users table
4. Billing_Events entity requires valid User_ID references for revenue attribution
5. Licenses entity depends on valid Assigned_To_User_ID references in Users table
6. Meeting duration calculations depend on both Start_Time and End_Time availability

### 2.5 Referential Integrity
1. Meetings.Host_ID → Users.User_ID: Ensures all meetings have valid host references
2. Attendees.Meeting_ID → Meetings.Meeting_ID: Maintains meeting participation integrity
3. Features_Usage.Meeting_ID → Meetings.Meeting_ID: Links feature usage to valid meetings
4. Support_Tickets.User_ID → Users.User_ID: Connects support requests to valid users
5. Billing_Events.User_ID → Users.User_ID: Associates billing events with valid users
6. Licenses.Assigned_To_User_ID → Users.User_ID: Links license assignments to valid users

## 3. Business Rules

### 3.1 Data Processing Rules
1. Active users must be calculated as unique users who hosted at least one meeting within the specified time period
2. Feature adoption rate must be calculated as proportion of users who used a specific feature at least once compared to total user base
3. Average resolution time must be calculated by determining mean time between ticket open and close dates
4. License utilization rate must represent proportion of assigned licenses out of total available licenses
5. Monthly Recurring Revenue must be calculated by summing recurring billing events within monthly periods
6. Churn rate must measure fraction of users who stopped platform usage compared to total user base

### 3.2 Reporting Logic Rules
1. Daily Active Users (DAU) must count unique users with at least one meeting per day
2. Weekly Active Users (WAU) must count unique users with at least one meeting per week
3. Monthly Active Users (MAU) must count unique users with at least one meeting per month
4. Total meeting minutes must sum Duration_Minutes across all meetings for specified periods
5. Revenue by license type must aggregate billing amounts grouped by License_Type categories
6. Ticket volume analysis must group support tickets by Type for pattern identification
7. First-contact resolution rate must calculate percentage of tickets resolved without escalation

### 3.3 Transformation Guidelines
1. User data anonymization must mask Email and User_Name fields for non-authorized users
2. Time-based aggregations must use consistent time zone handling across all reports
3. Revenue calculations must handle currency conversion if multiple currencies are present
4. Feature usage aggregations must normalize usage counts across different meeting types
5. Support ticket categorization must follow predefined Type and Resolution_Status values
6. License expiration analysis must account for renewal patterns and grace periods
7. Cross-report data correlation must maintain consistent User_ID and Meeting_ID references