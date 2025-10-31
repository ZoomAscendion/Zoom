____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Model Data Constraints for Zoom Platform Analytics System reporting requirements
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Model Data Constraints for Zoom Platform Analytics System

## 1. Data Expectations

### 1.1 Data Completeness Expectations
1. **User Data Completeness**
   - User_ID must be present for all user records
   - Plan_Type must be specified for all users (Free, Paid, etc.)
   - Company information should be available for enterprise users

2. **Meeting Data Completeness**
   - Meeting_ID must be unique and present for all meeting records
   - Duration_Minutes must be recorded for all completed meetings
   - Start_Time and End_Time must be captured for all meetings
   - Host_ID must reference a valid user for all meetings

3. **Support Ticket Completeness**
   - All support tickets must have a valid User_ID reference
   - Type and Resolution_Status must be populated from predefined values
   - Open_Date must be recorded for all tickets

4. **Billing and License Completeness**
   - All billing events must have associated User_ID and Amount
   - License records must have valid Start_Date and End_Date
   - License_Type must be from predefined categories

### 1.2 Data Accuracy Expectations
1. **Temporal Data Accuracy**
   - Start_Time must be before End_Time for all meetings
   - License Start_Date must be before End_Date
   - Meeting timestamps must be within reasonable business hours or marked appropriately

2. **Numerical Data Accuracy**
   - Duration_Minutes should correlate with Start_Time and End_Time calculations
   - Billing amounts should be positive and within expected ranges for license types
   - Usage counts should be non-negative integers

3. **Reference Data Accuracy**
   - All foreign key relationships must maintain referential integrity
   - User_ID references must exist in Users table across all related tables
   - Meeting_ID references must be valid in Features_Usage and Attendees tables

### 1.3 Data Format Expectations
1. **Timestamp Formats**
   - All date/time fields must follow consistent timestamp format
   - Time zones should be standardized (UTC preferred)

2. **Identifier Formats**
   - User_ID, Meeting_ID should follow consistent naming conventions
   - Email addresses must follow valid email format patterns

3. **Categorical Data Formats**
   - Plan_Type values must be from predefined list (Free, Basic, Pro, Business, Enterprise)
   - Meeting_Type must be standardized (Scheduled, Instant, Recurring, etc.)
   - License_Type must follow established categories

### 1.4 Data Consistency Expectations
1. **Cross-Table Consistency**
   - User plan information should be consistent across Users and Licenses tables
   - Meeting duration calculations should match between different aggregation levels
   - Feature usage should align with meeting records

2. **Temporal Consistency**
   - User activity should align with license validity periods
   - Support tickets should correlate with user activity patterns
   - Billing events should correspond to license assignments

## 2. Constraints

### 2.1 Mandatory Field Constraints
1. **Required User Fields**
   - User_ID (Primary Key) - NOT NULL
   - Plan_Type - NOT NULL
   - Registration_Date - NOT NULL

2. **Required Meeting Fields**
   - Meeting_ID (Primary Key) - NOT NULL
   - Host_ID (Foreign Key) - NOT NULL
   - Start_Time - NOT NULL
   - Duration_Minutes - NOT NULL

3. **Required Support Ticket Fields**
   - Ticket_ID (Primary Key) - NOT NULL
   - User_ID (Foreign Key) - NOT NULL
   - Type - NOT NULL
   - Open_Date - NOT NULL
   - Resolution_Status - NOT NULL

4. **Required Billing Fields**
   - Event_ID (Primary Key) - NOT NULL
   - User_ID (Foreign Key) - NOT NULL
   - Event_Type - NOT NULL
   - Amount - NOT NULL

5. **Required License Fields**
   - License_ID (Primary Key) - NOT NULL
   - License_Type - NOT NULL
   - Start_Date - NOT NULL
   - End_Date - NOT NULL
   - Assigned_To_User_ID (Foreign Key) - NOT NULL

### 2.2 Uniqueness Constraints
1. **Primary Key Uniqueness**
   - User_ID must be unique across Users table
   - Meeting_ID must be unique across Meetings table
   - Ticket_ID must be unique across Support_Tickets table
   - License_ID must be unique across Licenses table

2. **Business Uniqueness**
   - Email addresses should be unique per user
   - One active license per user per license type at any given time

### 2.3 Data Type Constraints
1. **Numerical Constraints**
   - Duration_Minutes: Non-negative integer (>= 0)
   - Amount: Positive decimal (> 0)
   - Usage_Count: Non-negative integer (>= 0)

2. **Date/Time Constraints**
   - Start_Time, End_Time: Valid timestamp format
   - Open_Date, Close_Date: Valid date format
   - Start_Date, End_Date: Valid date format with Start_Date < End_Date

3. **String Constraints**
   - Plan_Type: ENUM('Free', 'Basic', 'Pro', 'Business', 'Enterprise')
   - Resolution_Status: ENUM('Open', 'In Progress', 'Resolved', 'Closed')
   - Event_Type: ENUM('Subscription', 'Upgrade', 'Downgrade', 'Cancellation', 'Payment')

### 2.4 Referential Integrity Constraints
1. **Foreign Key Constraints**
   - Meetings.Host_ID → Users.User_ID
   - Attendees.Meeting_ID → Meetings.Meeting_ID
   - Attendees.User_ID → Users.User_ID
   - Features_Usage.Meeting_ID → Meetings.Meeting_ID
   - Support_Tickets.User_ID → Users.User_ID
   - Billing_Events.User_ID → Users.User_ID
   - Licenses.Assigned_To_User_ID → Users.User_ID

2. **Cascade Rules**
   - User deletion should handle dependent records appropriately
   - Meeting deletion should cascade to related Features_Usage and Attendees records

### 2.5 Business Logic Constraints
1. **Meeting Constraints**
   - Meeting duration should not exceed 24 hours (Duration_Minutes <= 1440)
   - End_Time must be after Start_Time
   - Host must be a valid active user

2. **License Constraints**
   - License End_Date must be after Start_Date
   - User cannot have overlapping licenses of the same type
   - License assignment must be to active users

3. **Billing Constraints**
   - Billing amounts must be positive for subscription and upgrade events
   - Refund amounts can be negative
   - Billing events must align with license changes

## 3. Business Rules

### 3.1 User Management Rules
1. **User Lifecycle Rules**
   - New users start with 'Free' plan by default
   - User plan upgrades must be reflected in both Users and Licenses tables
   - User deactivation should preserve historical data for reporting

2. **Access Control Rules**
   - Only active users can host meetings
   - Free plan users have meeting duration limitations
   - Enterprise users have additional feature access

### 3.2 Meeting Management Rules
1. **Meeting Creation Rules**
   - Users can only host meetings within their plan limitations
   - Meeting capacity is determined by user's license type
   - Recurring meetings generate separate Meeting_ID for each occurrence

2. **Meeting Data Rules**
   - Meeting duration is calculated as End_Time - Start_Time
   - Attendee count includes the host
   - Features used during meetings must be available to the host's plan

### 3.3 Support and Service Rules
1. **Ticket Management Rules**
   - Support tickets can only be created by registered users
   - Ticket resolution time is calculated from Open_Date to Close_Date
   - Priority levels may affect resolution time expectations

2. **Service Level Rules**
   - Enterprise users receive priority support
   - Free users have limited support channels
   - Response time varies by user plan type

### 3.4 Billing and Revenue Rules
1. **Billing Cycle Rules**
   - Monthly billing events are generated for active subscriptions
   - Pro-rated billing applies for mid-cycle plan changes
   - Failed payments trigger account status changes

2. **Revenue Recognition Rules**
   - Revenue is recognized based on license validity periods
   - Refunds are processed against original billing events
   - Upgrade/downgrade events affect Monthly Recurring Revenue (MRR) calculations

### 3.5 Analytics and Reporting Rules
1. **KPI Calculation Rules**
   - Daily Active Users (DAU): Users who hosted or attended at least one meeting in a day
   - Weekly Active Users (WAU): Users active within a 7-day rolling window
   - Monthly Active Users (MAU): Users active within a 30-day rolling window
   - Feature adoption rate: (Users who used feature / Total active users) × 100

2. **Data Aggregation Rules**
   - Meeting minutes are summed across all meetings for total usage
   - Average meeting duration excludes meetings shorter than 1 minute
   - License utilization considers only assigned and active licenses

3. **Historical Data Rules**
   - Historical data must be preserved for trend analysis
   - Data retention policies apply based on regulatory requirements
   - Anonymization rules apply for user privacy protection

### 3.6 Data Quality Rules
1. **Validation Rules**
   - All timestamps must be validated against system clock
   - Email addresses must pass format validation
   - Phone numbers must follow international format standards

2. **Cleansing Rules**
   - Duplicate user records must be merged following defined procedures
   - Orphaned records (missing foreign key references) must be handled
   - Data inconsistencies must be flagged for manual review

### 3.7 Security and Privacy Rules
1. **Data Access Rules**
   - Sensitive user data (Email, User_Name) must be masked for unauthorized users
   - Financial data access requires additional authorization
   - Audit trails must be maintained for all data access

2. **Data Protection Rules**
   - Personal data must comply with privacy regulations (GDPR, CCPA)
   - Data encryption requirements for sensitive fields
   - Data anonymization for analytics and reporting purposes