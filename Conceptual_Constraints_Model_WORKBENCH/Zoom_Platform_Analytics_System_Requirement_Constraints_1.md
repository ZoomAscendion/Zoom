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
1. All meeting records must have complete duration and timing information for accurate usage analytics
2. User information must include plan type to enable proper segmentation analysis
3. Support ticket records must contain complete type and status information for resolution tracking
4. Billing events must have complete amount and event type data for revenue analysis
5. License records must include start and end dates for utilization rate calculations
6. Feature usage records must be complete to accurately measure adoption rates

### 1.2 Data Accuracy
1. Meeting duration calculations must accurately reflect actual session times
2. User activity tracking must precisely identify unique active users for DAU/WAU/MAU metrics
3. Ticket resolution time calculations must accurately measure support team performance
4. Revenue calculations must precisely reflect actual billing amounts and events
5. License utilization rates must accurately represent current assignment status
6. Feature adoption metrics must correctly identify users who have used specific features

### 1.3 Data Format
1. All timestamp fields (Start_Time, End_Time, Open_Date) must follow consistent datetime format
2. Duration_Minutes must be expressed as integer values for consistent calculations
3. Amount fields must follow standard monetary format with appropriate precision
4. Plan_Type and License_Type must use standardized naming conventions
5. Email addresses must follow valid email format standards
6. User_Name must follow consistent naming format guidelines

### 1.4 Data Consistency
1. User plan types must be consistently categorized across all related records
2. Meeting types must be uniformly classified for accurate comparative analysis
3. Support ticket types must follow consistent categorization standards
4. License types must maintain uniform classification across all records
5. Feature names must be consistently named across all usage records
6. Company names must be standardized to avoid duplicate organizational entries

## 2. Constraints

### 2.1 Mandatory Fields
1. **Duration_Minutes**: Required for all meeting records to calculate total meeting minutes and average duration metrics
2. **Start_Time**: Essential for temporal analysis and trend identification across all reports
3. **Plan_Type**: Necessary for user segmentation analysis in usage and revenue reports
4. **User_ID**: Critical for linking user activities across meetings, support, and billing systems
5. **Meeting_ID**: Required for proper relationship establishment between meetings and related entities
6. **Amount**: Essential for revenue calculations and billing analysis
7. **License_Type**: Necessary for license utilization and revenue analysis by license category
8. **Type**: Required for support ticket categorization and volume analysis

### 2.2 Uniqueness Requirements
1. **User_ID**: Must be unique across the Users entity to ensure proper user identification
2. **Meeting_ID**: Must be unique across the Meetings entity to ensure accurate meeting tracking
3. **Email**: Must be unique per user to prevent duplicate user accounts
4. **Support Ticket ID**: Must be unique to ensure proper ticket tracking and resolution
5. **License ID**: Must be unique to prevent license assignment conflicts
6. **Billing Event ID**: Must be unique to ensure accurate revenue tracking

### 2.3 Data Type Limitations
1. **Duration_Minutes**: Must be non-negative integer values only
2. **Amount**: Must be positive numeric values for billing events
3. **Start_Time/End_Time**: Must be valid timestamp formats
4. **Open_Date**: Must be valid date format
5. **Usage_Count**: Must be non-negative integer values
6. **Plan_Type**: Must be from predefined list of valid plan types
7. **License_Type**: Must be from predefined list of valid license categories

### 2.4 Dependencies
1. **Meeting End_Time**: Must be after or equal to Start_Time for logical consistency
2. **License End_Date**: Must be after Start_Date for valid license periods
3. **Support Ticket Resolution**: Resolution_Status must align with actual ticket lifecycle
4. **User Plan Consistency**: User plan type must be consistent across meetings and billing events
5. **Feature Usage Dependency**: Feature usage records must correspond to actual meeting sessions

### 2.5 Referential Integrity
1. **Meetings to Users**: Host_ID in Meetings must reference existing User_ID in Users table
2. **Attendees to Meetings**: Meeting_ID in Attendees must reference existing Meeting_ID in Meetings table
3. **Attendees to Users**: User_ID in Attendees must reference existing User_ID in Users table
4. **Features_Usage to Meetings**: Meeting_ID in Features_Usage must reference existing Meeting_ID in Meetings table
5. **Support_Tickets to Users**: User_ID in Support_Tickets must reference existing User_ID in Users table
6. **Billing_Events to Users**: User_ID in Billing_Events must reference existing User_ID in Users table
7. **Licenses to Users**: Assigned_To_User_ID in Licenses must reference existing User_ID in Users table

## 3. Business Rules

### 3.1 Data Processing Rules
1. **Active User Definition**: A user is considered active if they have hosted at least one meeting within the specified time period
2. **Meeting Duration Calculation**: Total meeting minutes are calculated by summing Duration_Minutes across all meeting records
3. **Average Duration Calculation**: Average meeting duration is computed by dividing total duration by number of meetings
4. **Feature Adoption Calculation**: Feature adoption rate is the proportion of users who have used a specific feature at least once
5. **License Utilization Calculation**: License utilization rate is the proportion of licenses currently assigned to users
6. **Churn Rate Calculation**: Churn rate measures the fraction of users who have stopped using the platform

### 3.2 Reporting Logic Rules
1. **DAU/WAU/MAU Calculation**: Active users must be counted as unique users within daily, weekly, or monthly periods
2. **Revenue Aggregation**: Total revenue is calculated by summing all monetary amounts from billing events
3. **Resolution Time Calculation**: Average resolution time is calculated by determining the average time taken to close tickets
4. **User-to-Ticket Ratio**: Compares total number of tickets raised to the number of active users during the same period
5. **MRR Calculation**: Monthly Recurring Revenue is calculated from subscription-based billing events
6. **Geographic Revenue Distribution**: Revenue must be aggregated by user company location for geographic analysis

### 3.3 Transformation Guidelines
1. **Data Anonymization**: Sensitive user data (Email, User_Name) must be anonymized for non-authorized users
2. **Time Zone Standardization**: All timestamp data must be converted to a consistent time zone for accurate analysis
3. **Plan Type Standardization**: User plan types must be normalized to standard categories (Free vs. Paid)
4. **Company Name Normalization**: Company names must be standardized to prevent duplicate organizational entries
5. **Feature Name Consistency**: Feature names must be normalized across all usage tracking records
6. **Ticket Type Categorization**: Support ticket types must be mapped to standard predefined categories
7. **License Type Mapping**: License types must be mapped to standard revenue categories for analysis
8. **Meeting Type Classification**: Meeting types must be consistently classified for comparative analysis