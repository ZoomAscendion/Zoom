____________________________________________
## *Author*: AAVA
## *Created on*:   11-11-2025
## *Description*: Model Data Constraints for Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 1 
## *Updated on*: 11-11-2025
_____________________________________________

#  Platform Analytics System - Model Data Constraints

## 1. Data Expectations

### 1.1 Platform Usage & Adoption Data Expectations

1. **Meeting Data Completeness**
   - All meetings must have valid Duration_Minutes, Start_Time, and End_Time values
   - Meeting_ID must be unique and present for all meeting records
   - Host_ID must reference a valid user in the Users table

2. **User Data Accuracy**
   - User_ID must be unique across all user records
   - Plan_Type must be consistently categorized (Free, Basic, Pro, Enterprise)
   - Registration dates must be chronologically valid

3. **Feature Usage Data Consistency**
   - Feature_Name must follow standardized naming conventions
   - Usage_Count must be non-negative integers
   - Usage_Duration must align with meeting duration constraints

4. **Attendee Data Integrity**
   - Join_Time must be after or equal to meeting Start_Time
   - Leave_Time must be after Join_Time and before or equal to meeting End_Time
   - Participant_Name must be provided for all attendee records

### 1.2 Service Reliability & Support Data Expectations

1. **Support Ticket Data Quality**
   - All tickets must have valid Open_Date timestamps
   - Resolution_Status must be from predefined status values
   - Ticket_Type must be categorized consistently
   - User_ID must reference existing users in the system

2. **Resolution Time Accuracy**
   - Close_Date must be after Open_Date for resolved tickets
   - Priority_Level must be assigned to all tickets
   - Description field must contain meaningful issue details

### 1.3 Revenue & License Data Expectations

1. **Billing Event Data Precision**
   - Amount values must be positive numbers with appropriate decimal precision
   - Transaction_Date must be valid timestamps
   - Event_Type must follow standardized billing categories
   - Currency must be specified for all monetary transactions

2. **License Data Completeness**
   - License_Type must be from predefined license categories
   - Start_Date and End_Date must be chronologically valid
   - Assigned_To_User_ID must reference valid users
   - License_Status must be current and accurate

## 2. Constraints

### 2.1 Data Type and Format Constraints

1. **Temporal Constraints**
   - Start_Time and End_Time must be valid timestamp formats
   - Duration_Minutes must be non-negative integers
   - Open_Date and Close_Date must be valid date formats
   - Transaction_Date must be valid timestamp with timezone information

2. **Numeric Constraints**
   - Usage_Count must be non-negative integers
   - Amount must be positive decimal numbers
   - Duration_Minutes must be greater than or equal to 0
   - Usage_Duration must not exceed meeting Duration_Minutes

3. **String Constraints**
   - Feature_Name must not exceed 100 characters
   - Plan_Type must be from enumerated values: ['Free', 'Basic', 'Pro', 'Enterprise']
   - Resolution_Status must be from: ['Open', 'In Progress', 'Resolved', 'Closed']
   - License_Type must be from predefined license categories

### 2.2 Referential Integrity Constraints

1. **Foreign Key Constraints**
   - Meeting_ID in Attendees table must exist in Meetings table
   - Meeting_ID in Features_Usage table must exist in Meetings table
   - Host_ID in Meetings table must exist as User_ID in Users table
   - User_ID in Support_Tickets table must exist in Users table
   - User_ID in Billing_Events table must exist in Users table
   - Assigned_To_User_ID in Licenses table must exist as User_ID in Users table

2. **Uniqueness Constraints**
   - User_ID must be unique in Users table
   - Meeting_ID must be unique in Meetings table
   - Combination of Meeting_ID and User_ID must be unique in Attendees table
   - Ticket_ID must be unique in Support_Tickets table

### 2.3 Business Logic Constraints

1. **Meeting Duration Constraints**
   - Meeting End_Time must be after Start_Time
   - Duration_Minutes must equal the calculated difference between End_Time and Start_Time
   - Attendee Leave_Time must be after Join_Time

2. **License Validity Constraints**
   - License Start_Date must be before End_Date
   - Active licenses must have End_Date in the future
   - Users cannot have multiple active licenses of the same type simultaneously

3. **Support Ticket Constraints**
   - Closed tickets must have valid Close_Date
   - Resolution time must be calculated as Close_Date minus Open_Date
   - Tickets cannot be closed before they are opened

## 3. Business Rules

### 3.1 Platform Usage & Adoption Business Rules

1. **Active User Definition Rules**
   - Daily Active Users (DAU): Users who hosted at least one meeting in a 24-hour period
   - Weekly Active Users (WAU): Users who hosted at least one meeting in a 7-day period
   - Monthly Active Users (MAU): Users who hosted at least one meeting in a 30-day period

2. **Meeting Classification Rules**
   - Meetings with duration < 5 minutes are classified as "Brief"
   - Meetings with 2+ attendees are classified as "Collaborative"
   - Meetings using screen share feature are classified as "Presentation"

3. **Feature Adoption Calculation Rules**
   - Feature adoption rate = (Users who used feature / Total active users) × 100
   - Feature usage must be tracked per meeting session
   - New feature adoption is measured within 30 days of feature release

### 3.2 Service Reliability & Support Business Rules

1. **Ticket Priority Assignment Rules**
   - Critical: System outages affecting > 1000 users
   - High: Feature failures affecting specific user groups
   - Medium: Individual user technical issues
   - Low: Feature requests and general inquiries

2. **Resolution Time Targets**
   - Critical tickets: 4 hours maximum
   - High priority tickets: 24 hours maximum
   - Medium priority tickets: 72 hours maximum
   - Low priority tickets: 7 days maximum

3. **Support Metrics Calculation Rules**
   - First-contact resolution rate = (Tickets resolved on first contact / Total tickets) × 100
   - Average resolution time excludes weekends and holidays for non-critical tickets
   - Ticket volume per 1000 users = (Total tickets / Active users) × 1000

### 3.3 Revenue & License Analysis Business Rules

1. **Revenue Recognition Rules**
   - Monthly Recurring Revenue (MRR) includes only subscription-based revenue
   - One-time payments are excluded from MRR calculations
   - Refunds are subtracted from the month they are processed

2. **License Utilization Rules**
   - License utilization rate = (Assigned licenses / Total available licenses) × 100
   - Expired licenses are excluded from utilization calculations
   - Grace period of 7 days is allowed for license renewals

3. **Churn Rate Calculation Rules**
   - Churn rate = (Users who cancelled / Total users at start of period) × 100
   - Churn is measured monthly for subscription users
   - Users with expired licenses who don't renew within 30 days are considered churned

### 3.4 Data Processing and Transformation Rules

1. **Aggregation Rules**
   - Daily metrics are calculated using UTC timezone
   - Weekly metrics start on Monday and end on Sunday
   - Monthly metrics are calculated using calendar months

2. **Data Quality Rules**
   - Records with missing critical fields are flagged for review
   - Duplicate records are identified and merged based on business logic
   - Data older than 7 years is archived but not deleted

3. **Security and Privacy Rules**
   - User email and personal information must be masked in non-production environments
   - Access to revenue data requires specific authorization levels
   - Support ticket descriptions containing sensitive information must be encrypted

### 3.5 Reporting and Analytics Rules

1. **KPI Calculation Standards**
   - All percentage calculations are rounded to 2 decimal places
   - Growth rates are calculated using period-over-period comparison
   - Trend analysis requires minimum 3 months of historical data

2. **Data Refresh Rules**
   - Usage metrics are updated every 4 hours
   - Support metrics are updated every 2 hours
   - Revenue metrics are updated daily at midnight UTC

3. **Alert and Notification Rules**
   - Automatic alerts for license expirations within 30 days
   - Performance degradation alerts when average resolution time exceeds targets by 50%
   - Revenue alerts when MRR drops by more than 5% month-over-month
