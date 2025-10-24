____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Model Data Constraints for Zoom Platform Analytics System reporting requirements
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Model Data Constraints

## 1. Data Expectations

### 1.1 Platform Usage & Adoption Data Expectations

1. **User Data Completeness**
   - User_ID must be present for all user records
   - Plan_Type must be specified for accurate usage analysis
   - Registration dates must be available for trend analysis

2. **Meeting Data Accuracy**
   - Meeting_ID must be unique and present for all meeting records
   - Duration_Minutes must accurately reflect actual meeting length
   - Start_Time and End_Time must be synchronized and valid
   - Host_ID must correspond to valid users in the system

3. **Feature Usage Data Consistency**
   - Feature_Name must follow standardized naming conventions
   - Usage_Count must accurately represent feature utilization frequency
   - Feature usage must be linked to valid meetings

4. **Attendee Data Integrity**
   - Join_Time and Leave_Time must be within meeting duration boundaries
   - Attendance_Duration must be calculated consistently
   - Participant information must be complete for accurate headcount

### 1.2 Service Reliability & Support Data Expectations

5. **Support Ticket Data Quality**
   - Ticket_Type must be categorized using predefined classifications
   - Issue_Description must provide sufficient detail for analysis
   - Priority_Level must be assigned based on business impact criteria
   - Resolution_Status must be updated in real-time

6. **Temporal Data Accuracy**
   - Open_Date and Close_Date must be valid and sequential
   - Resolution time calculations must account for business hours
   - Ticket aging must be tracked accurately

### 1.3 Revenue & License Analysis Data Expectations

7. **Billing Data Precision**
   - Amount values must be accurate to two decimal places
   - Currency must be specified for multi-currency environments
   - Transaction_Date must align with actual payment processing

8. **License Data Completeness**
   - License_Type must be clearly defined and categorized
   - Start_Date and End_Date must define valid license periods
   - License assignment must be tracked to specific users

## 2. Constraints

### 2.1 Data Type and Format Constraints

1. **Numeric Constraints**
   - Duration_Minutes: Non-negative integer, maximum 1440 (24 hours)
   - Usage_Count: Non-negative integer
   - Amount: Positive decimal with 2 decimal places precision
   - User_ID: Unique identifier, not null
   - Meeting_ID: Unique identifier, not null

2. **Date and Time Constraints**
   - Start_Time: Valid timestamp format (YYYY-MM-DD HH:MM:SS)
   - End_Time: Valid timestamp format, must be >= Start_Time
   - Open_Date: Valid date format, not future dated
   - Close_Date: Valid date format, must be >= Open_Date
   - Transaction_Date: Valid date format within acceptable range

3. **String and Categorical Constraints**
   - Plan_Type: Must be one of ['Free', 'Basic', 'Pro', 'Enterprise']
   - Meeting_Type: Must be one of ['Scheduled', 'Instant', 'Recurring', 'Webinar']
   - Ticket_Type: Must be from predefined list ['Technical', 'Billing', 'Feature Request', 'General']
   - Priority_Level: Must be one of ['Low', 'Medium', 'High', 'Critical']
   - Resolution_Status: Must be one of ['Open', 'In Progress', 'Resolved', 'Closed']
   - License_Type: Must be from predefined list ['Basic', 'Pro', 'Enterprise', 'Add-on']
   - License_Status: Must be one of ['Active', 'Expired', 'Suspended']

### 2.2 Referential Integrity Constraints

4. **Foreign Key Constraints**
   - Host_ID in Meetings must exist in Users.User_ID
   - Meeting_ID in Attendees must exist in Meetings.Meeting_ID
   - Meeting_ID in Features_Usage must exist in Meetings.Meeting_ID
   - User_ID in Support_Tickets must exist in Users.User_ID
   - User_ID in Billing_Events must exist in Users.User_ID
   - Assigned_To_User_ID in Licenses must exist in Users.User_ID

5. **Data Relationship Constraints**
   - A user cannot be both host and attendee of the same meeting
   - Feature usage records must have corresponding meeting records
   - Billing events must have associated user accounts
   - License assignments must reference valid user accounts

### 2.3 Business Logic Constraints

6. **Meeting Duration Constraints**
   - Meeting duration must not exceed plan-specific limits
   - Free plan meetings limited to 40 minutes for 3+ participants
   - End_Time must be after Start_Time

7. **License Utilization Constraints**
   - Users cannot have multiple active licenses of the same type
   - License End_Date must be after Start_Date
   - Expired licenses cannot be assigned to new users

8. **Support Ticket Constraints**
   - Closed tickets cannot be reopened without proper workflow
   - Resolution time must be calculated only for resolved/closed tickets
   - Critical priority tickets must have assigned agents

## 3. Business Rules

### 3.1 Platform Usage & Adoption Business Rules

1. **Active User Definition Rules**
   - Daily Active User (DAU): User who hosted at least one meeting in a 24-hour period
   - Weekly Active User (WAU): User who hosted at least one meeting in a 7-day period
   - Monthly Active User (MAU): User who hosted at least one meeting in a 30-day period

2. **Meeting Classification Rules**
   - Instant meetings: Created and started within 5 minutes
   - Scheduled meetings: Created at least 5 minutes before start time
   - Recurring meetings: Part of a series with same meeting settings

3. **Feature Adoption Calculation Rules**
   - Feature adoption rate = (Users who used feature / Total active users) × 100
   - Feature must be used at least once to count toward adoption
   - Adoption rates calculated monthly for trending analysis

### 3.2 Service Reliability & Support Business Rules

4. **Ticket Resolution Time Rules**
   - Resolution time calculated in business hours only (Monday-Friday, 9 AM-5 PM)
   - Critical tickets must be acknowledged within 1 hour
   - High priority tickets must be resolved within 24 business hours
   - Medium priority tickets must be resolved within 72 business hours

5. **First Contact Resolution Rules**
   - Ticket resolved in first interaction without escalation or follow-up
   - Must be marked as resolved by the same agent who opened it
   - Customer confirmation not required for FCR classification

6. **Ticket Volume Normalization Rules**
   - Tickets per 1000 active users = (Total tickets / Active users) × 1000
   - Active users defined as users with at least one meeting in the period
   - Calculation performed on monthly basis for trending

### 3.3 Revenue & License Analysis Business Rules

7. **Monthly Recurring Revenue (MRR) Rules**
   - MRR includes only subscription-based recurring revenue
   - One-time payments and refunds excluded from MRR calculation
   - Upgrades and downgrades reflected in the month they take effect

8. **License Utilization Rules**
   - Utilization rate = (Assigned licenses / Total available licenses) × 100
   - Only active licenses count toward utilization
   - Expired or suspended licenses excluded from calculation

9. **Churn Rate Calculation Rules**
   - Churn rate = (Users who cancelled / Total users at start of period) × 100
   - Calculated monthly based on subscription cancellations
   - Users who downgrade plans not counted as churned

10. **Revenue Recognition Rules**
    - Revenue recognized when service is delivered, not when payment is received
    - Subscription revenue recognized monthly over the subscription period
    - Refunds deducted from revenue in the month they are processed

### 3.4 Data Security and Privacy Rules

11. **Data Anonymization Rules**
    - Email addresses and user names must be masked for non-authorized users
    - Company information can be displayed in aggregate form only
    - Individual user data requires appropriate access permissions

12. **Data Retention Rules**
    - Meeting data retained for 12 months for analytics purposes
    - Support ticket data retained for 24 months for trend analysis
    - Billing data retained according to financial compliance requirements

### 3.5 Report Generation and Performance Rules

13. **Data Freshness Rules**
    - Platform usage reports updated every 4 hours
    - Support metrics updated in real-time
    - Revenue reports updated daily after billing cycle completion

14. **Query Optimization Rules**
    - Queries spanning more than 90 days must use pre-aggregated data
    - Real-time queries limited to current day data only
    - Historical trend analysis uses cached monthly aggregations

15. **Alert and Notification Rules**
    - License expiration alerts sent 30, 15, and 7 days before expiration
    - Usage limit alerts triggered at 80% and 95% of plan limits
    - Critical support ticket alerts sent immediately to management