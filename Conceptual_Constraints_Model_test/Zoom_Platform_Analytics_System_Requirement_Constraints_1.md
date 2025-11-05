____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Model data constraints and business rules for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
____________________________________________

# Model Data Constraints - Zoom Platform Analytics System

## 1. Data Expectations

### 1.1 Data Completeness
1. All meeting records must have complete duration information to enable accurate total meeting minutes calculations
2. User records must contain valid plan type information for proper usage pattern analysis
3. Support ticket records must include complete type and status information for effective resolution tracking
4. Billing event records must contain complete amount and event type data for revenue analysis
5. License records must have complete start and end date information for utilization rate calculations
6. Feature usage records must contain valid feature names and usage counts for adoption rate analysis

### 1.2 Data Accuracy
1. Meeting duration calculations must accurately reflect actual session lengths for reliable KPI reporting
2. User activity tracking must precisely identify unique users for DAU, WAU, and MAU calculations
3. Revenue calculations must accurately sum billing amounts for MRR and revenue by license type reporting
4. Ticket resolution time calculations must precisely measure time between open and close dates
5. License utilization calculations must accurately reflect assigned versus available license ratios
6. Feature adoption rate calculations must correctly measure user engagement with platform features

### 1.3 Data Format
1. All timestamp fields (Start_Time, End_Time, Open_Date) must follow consistent datetime format standards
2. Duration measurements must be consistently expressed in minutes across all meeting records
3. Monetary amounts must follow standard currency format with appropriate decimal precision
4. User identification fields must maintain consistent format across all related entities
5. License and plan type values must conform to predefined enumeration standards
6. Feature names must follow standardized naming conventions for consistent reporting

### 1.4 Data Consistency
1. User references must be consistent across meetings, support tickets, billing events, and license assignments
2. Meeting references must be consistent between attendee records and feature usage records
3. Date ranges must be logically consistent with start dates preceding end dates
4. Plan type classifications must align consistently across user records and billing events
5. License type categories must remain consistent across license records and revenue reporting
6. Support ticket status values must follow consistent progression through resolution workflow

## 2. Constraints

### 2.1 Mandatory Fields
1. **Duration_Minutes**: Required for all meeting records to enable total meeting minutes and average duration calculations
2. **Start_Time**: Required for all meeting records to support temporal analysis and usage pattern identification
3. **Plan_Type**: Required for all user records to enable usage analysis by subscription tier
4. **User_ID**: Required in support tickets, billing events, and license assignments to maintain referential relationships
5. **Meeting_ID**: Required in attendee and feature usage records to establish proper meeting associations
6. **Amount**: Required for all billing events to support revenue calculations and financial analysis
7. **License_Type**: Required for all license records to enable license utilization and revenue analysis
8. **Type**: Required for all support ticket records to enable ticket categorization and volume analysis
9. **Resolution_Status**: Required for all support ticket records to track resolution progress
10. **Open_Date**: Required for all support ticket records to calculate resolution times

### 2.2 Uniqueness Requirements
1. **User_ID**: Must be unique across the user entity to ensure proper user identification
2. **Meeting_ID**: Must be unique across the meeting entity to ensure proper meeting identification
3. **Support_Ticket_ID**: Must be unique across support ticket records to ensure proper ticket tracking
4. **License_ID**: Must be unique across license records to ensure proper license management
5. **Billing_Event_ID**: Must be unique across billing event records to ensure proper transaction tracking

### 2.3 Data Type Limitations
1. **Duration_Minutes**: Must be a non-negative integer to ensure valid meeting duration values
2. **Amount**: Must be a positive number to ensure valid billing transaction values
3. **Start_Time and End_Time**: Must be valid timestamps to support temporal analysis requirements
4. **Open_Date**: Must be a valid date to enable resolution time calculations
5. **Usage_Count**: Must be a non-negative integer to ensure valid feature usage measurements
6. **Start_Date and End_Date**: Must be valid dates to support license management and expiration tracking

### 2.4 Dependencies
1. **Meeting End_Time**: Must occur after Start_Time to ensure logical temporal sequence
2. **License End_Date**: Must occur after Start_Date to ensure valid license duration
3. **Support Ticket Resolution**: Resolution_Status must align with presence of resolution timestamp
4. **Feature Usage**: Usage_Count must correspond to actual feature utilization during associated meeting
5. **Billing Event Timing**: Event timing must align with associated user account activity periods

### 2.5 Referential Integrity
1. **Meetings to Users**: Host_ID in meetings must reference existing User_ID in users table
2. **Attendees to Meetings**: Meeting_ID in attendees must reference existing Meeting_ID in meetings table
3. **Features_Usage to Meetings**: Meeting_ID in features usage must reference existing Meeting_ID in meetings table
4. **Support_Tickets to Users**: User_ID in support tickets must reference existing User_ID in users table
5. **Billing_Events to Users**: User_ID in billing events must reference existing User_ID in users table
6. **Licenses to Users**: Assigned_To_User_ID in licenses must reference existing User_ID in users table

## 3. Business Rules

### 3.1 Data Processing Rules
1. **Active User Calculation**: Users are considered active only if they have hosted at least one meeting within the specified time period
2. **Meeting Duration Aggregation**: Total meeting minutes must be calculated by summing Duration_Minutes across all meeting records
3. **Feature Adoption Measurement**: Feature adoption rate must be calculated as the proportion of users who have used a specific feature at least once
4. **Revenue Aggregation**: Total revenue must be calculated by summing all positive amounts from billing events
5. **License Utilization Calculation**: License utilization rate must be calculated as assigned licenses divided by total available licenses
6. **Ticket Resolution Timing**: Average resolution time must be calculated from Open_Date to actual resolution completion

### 3.2 Reporting Logic Rules
1. **DAU/WAU/MAU Calculation**: Active user counts must be based on unique users who hosted meetings within daily, weekly, or monthly periods respectively
2. **Churn Rate Measurement**: Churn rate must measure users who have stopped platform usage compared to total user base
3. **First-Contact Resolution**: Must be measured as tickets resolved without requiring follow-up interactions
4. **MRR Calculation**: Monthly Recurring Revenue must include only subscription-based recurring billing events
5. **Geographic Revenue Distribution**: Must be based on user company location data where available
6. **Usage Correlation Analysis**: Must correlate user activity levels with billing event patterns and plan upgrades

### 3.3 Transformation Guidelines
1. **Data Anonymization**: Sensitive user data (Email, User_Name) must be masked for non-authorized report users
2. **Temporal Aggregation**: Time-based metrics must support daily, weekly, and monthly aggregation levels
3. **Plan Type Standardization**: All plan type references must be normalized to standard classification scheme
4. **Feature Name Normalization**: Feature names must be standardized across usage tracking and reporting
5. **Currency Standardization**: All monetary amounts must be converted to standard base currency for consistent reporting
6. **Date Range Validation**: All date-based calculations must validate logical date ranges and handle edge cases appropriately