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
1. All meeting records must have complete Duration_Minutes, Start_Time, and End_Time information for accurate usage analytics
2. User records must have Plan_Type information to enable proper user segmentation analysis
3. Support ticket records must have Type and Resolution_Status for effective support analysis
4. Billing event records must have complete Event_Type and Amount information for revenue calculations
5. License records must have License_Type, Start_Date, and End_Date for proper license management
6. Feature usage records must have Feature_Name and Usage_Count for adoption rate calculations

### 1.2 Data Accuracy
1. Meeting duration calculations must accurately reflect the time difference between Start_Time and End_Time
2. Active user counts must be based on users who have actually hosted at least one meeting
3. Revenue calculations must accurately sum all monetary amounts from billing events
4. License utilization rates must reflect the actual proportion of assigned licenses
5. Support ticket resolution times must accurately calculate the time between Open_Date and resolution
6. Feature adoption rates must accurately measure the proportion of users who have used specific features

### 1.3 Data Format
1. Duration_Minutes must be expressed as non-negative integers
2. Start_Time and End_Time must be valid timestamps in consistent format
3. Amount values must be positive numbers for billing calculations
4. Date fields (Open_Date, Start_Date, End_Date) must be valid dates
5. User identification fields must maintain consistent format across all entities
6. Meeting and user identifiers must be consistently formatted for proper relationship mapping

### 1.4 Data Consistency
1. User information must be consistent across Users, Support_Tickets, Billing_Events, and Licenses entities
2. Meeting information must be consistent across Meetings, Attendees, and Features_Usage entities
3. Plan_Type and License_Type information must be consistent for the same user
4. Time-based data must maintain chronological consistency (Start_Date before End_Date)
5. Foreign key relationships must maintain referential consistency across all related entities
6. User plan types must align with corresponding license types and billing events

## 2. Constraints

### 2.1 Mandatory Fields
1. **Duration_Minutes**: Required for calculating total meeting minutes and average meeting duration KPIs
2. **Start_Time**: Required for temporal analysis and meeting scheduling patterns
3. **Plan_Type**: Required for user segmentation and adoption analysis by plan type
4. **User_ID**: Required for linking user activities across meetings, support, and billing
5. **Meeting_ID**: Required for linking meeting activities with attendees and feature usage
6. **Amount**: Required for revenue calculations and billing analysis
7. **License_Type**: Required for license utilization and revenue analysis
8. **Type**: Required for support ticket categorization and analysis

### 2.2 Uniqueness Requirements
1. **User_ID**: Must be unique within Users entity to ensure proper user identification
2. **Meeting_ID**: Must be unique within Meetings entity to ensure proper meeting tracking
3. **Support_Ticket_ID**: Must be unique within Support_Tickets entity for ticket tracking
4. **License_ID**: Must be unique within Licenses entity for license management
5. **Billing_Event_ID**: Must be unique within Billing_Events entity for transaction tracking

### 2.3 Data Type Limitations
1. **Duration_Minutes**: Must be non-negative integer values only
2. **Amount**: Must be positive numeric values for billing calculations
3. **Start_Time/End_Time**: Must be valid timestamp data types
4. **Open_Date/Start_Date/End_Date**: Must be valid date data types
5. **Usage_Count**: Must be non-negative integer values
6. **Plan_Type/License_Type**: Must be from predefined enumerated values

### 2.4 Dependencies
1. **Meeting-User Dependency**: Every meeting must have a valid Host_ID that exists in Users table
2. **Attendee-Meeting Dependency**: Every attendee record must reference a valid Meeting_ID
3. **Feature-Meeting Dependency**: Every feature usage record must reference a valid Meeting_ID
4. **Support-User Dependency**: Every support ticket must reference a valid User_ID
5. **Billing-User Dependency**: Every billing event must reference a valid User_ID
6. **License-User Dependency**: Every license must be assigned to a valid User_ID

### 2.5 Referential Integrity
1. **Meetings → Users**: Host_ID in Meetings must exist as User_ID in Users table
2. **Attendees → Meetings**: Meeting_ID in Attendees must exist in Meetings table
3. **Attendees → Users**: User_ID in Attendees must exist in Users table
4. **Features_Usage → Meetings**: Meeting_ID in Features_Usage must exist in Meetings table
5. **Support_Tickets → Users**: User_ID in Support_Tickets must exist in Users table
6. **Billing_Events → Users**: User_ID in Billing_Events must exist in Users table
7. **Licenses → Users**: Assigned_To_User_ID in Licenses must exist as User_ID in Users table

## 3. Business Rules

### 3.1 Data Processing Rules
1. **Active User Calculation**: A user is considered active only if they have hosted at least one meeting within the specified time period
2. **Meeting Duration Validation**: Meeting duration must be calculated as the difference between End_Time and Start_Time
3. **Feature Adoption Calculation**: Feature adoption rate is calculated as the number of users who used a feature divided by total user base
4. **Revenue Aggregation**: Total revenue is calculated by summing all positive Amount values from billing events
5. **License Utilization**: License utilization rate is calculated as assigned licenses divided by total available licenses
6. **Support Resolution Time**: Resolution time is calculated from Open_Date to the date when Resolution_Status indicates closure

### 3.2 Reporting Logic Rules
1. **Time Period Segmentation**: DAU, WAU, and MAU calculations must use distinct time periods without overlap
2. **User Segmentation**: Analysis by Plan_Type must categorize users as Free vs. Paid based on current plan status
3. **Meeting Categorization**: Meeting analysis must group by Meeting_Type and Category for comparative reporting
4. **Support Ticket Classification**: Ticket analysis must group by Type for identifying common issue patterns
5. **Revenue Classification**: Revenue analysis must segment by License_Type for understanding revenue streams
6. **Geographic Analysis**: Revenue distribution analysis must be based on user Company information where available

### 3.3 Transformation Guidelines
1. **Data Anonymization**: Email and User_Name must be masked or anonymized for non-authorized users accessing reports
2. **Temporal Aggregation**: Time-based metrics must be aggregated consistently (daily, weekly, monthly) across all reports
3. **Currency Standardization**: All Amount values must be in consistent currency units for accurate revenue calculations
4. **Date Standardization**: All date and timestamp fields must be converted to consistent timezone for accurate temporal analysis
5. **Plan Type Normalization**: Plan_Type values must be standardized to enable consistent segmentation analysis
6. **Feature Name Standardization**: Feature_Name values must be normalized to ensure accurate adoption rate calculations