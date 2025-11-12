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
1. All meetings must have valid Start_Time and End_Time timestamps for accurate duration calculations
2. User information must include Plan_Type to enable usage analysis by subscription tier
3. Support tickets must have complete Type and Resolution_Status information for service quality analysis
4. Billing events must include Event_Type and Amount for revenue tracking and analysis
5. License information must have Start_Date and End_Date for expiration trend analysis
6. Meeting attendee information must be complete to calculate accurate active user metrics
7. Feature usage data must be captured for all meetings to measure adoption rates

### 1.2 Data Accuracy
1. Duration_Minutes must accurately reflect the actual meeting duration for reliable usage metrics
2. Billing amounts must be precise and match actual financial transactions
3. User Plan_Type must be current and reflect the user's actual subscription status
4. License assignment must accurately reflect current user entitlements
5. Support ticket resolution times must be calculated based on actual open and close timestamps
6. Feature usage counts must accurately represent actual feature utilization
7. Active user calculations must be based on verified meeting hosting activity

### 1.3 Data Format
1. All timestamp fields (Start_Time, End_Time, Open_Date) must follow consistent datetime format
2. Duration_Minutes must be expressed as integer values for consistent calculations
3. Amount fields must use consistent currency format with appropriate decimal precision
4. User_ID and Meeting_ID must follow consistent identifier format across all entities
5. Plan_Type and License_Type must use standardized enumeration values
6. Email addresses must follow valid email format standards
7. Resolution_Status must use predefined status codes

### 1.4 Data Consistency
1. User_ID references must be consistent across Users, Meetings, Support_Tickets, Billing_Events, and Licenses
2. Meeting_ID references must be consistent across Meetings, Attendees, and Features_Usage
3. Plan_Type in Users entity must align with License_Type in Licenses entity
4. Meeting duration calculations must be consistent with Start_Time and End_Time values
5. Support ticket User_ID must correspond to valid users in the Users entity
6. Billing event User_ID must correspond to valid users with appropriate license types
7. Feature usage Meeting_ID must correspond to valid meetings in the Meetings entity

## 2. Constraints

### 2.1 Mandatory Fields
1. **Duration_Minutes**: Required for calculating total meeting minutes and average meeting duration KPIs
2. **Start_Time**: Essential for temporal analysis and active user calculations
3. **Plan_Type**: Mandatory for usage pattern analysis by subscription tier
4. **User_ID**: Required in all entities for establishing relationships and user-based analytics
5. **Meeting_ID**: Essential for linking attendees and feature usage to specific meetings
6. **Amount**: Required in billing events for revenue calculations and MRR analysis
7. **License_Type**: Mandatory for license utilization and revenue analysis
8. **Resolution_Status**: Required for support ticket analysis and resolution time calculations

### 2.2 Uniqueness Requirements
1. **User_ID**: Must be unique within Users entity to ensure accurate user identification
2. **Meeting_ID**: Must be unique within Meetings entity to prevent data duplication
3. **Support_Ticket_ID**: Must be unique to ensure proper ticket tracking and resolution
4. **License_ID**: Must be unique to prevent license assignment conflicts
5. **Billing_Event_ID**: Must be unique to ensure accurate financial transaction tracking
6. **Email**: Must be unique within Users entity to prevent account conflicts
7. **User_ID + Meeting_ID combination**: Must be unique in Attendees entity to prevent duplicate attendance records

### 2.3 Data Type Limitations
1. **Duration_Minutes**: Must be non-negative integer values only
2. **Amount**: Must be positive numeric values for valid billing transactions
3. **Start_Time/End_Time**: Must be valid timestamp format with proper timezone handling
4. **Open_Date**: Must be valid date format for accurate resolution time calculations
5. **Usage_Count**: Must be non-negative integer values for feature utilization tracking
6. **Plan_Type**: Must be from predefined enumeration (Free, Paid, etc.)
7. **Resolution_Status**: Must be from predefined list of valid status values

### 2.4 Dependencies
1. **Meeting End_Time**: Must be after or equal to Start_Time for valid duration calculation
2. **License End_Date**: Must be after Start_Date for valid license period
3. **Support Ticket Resolution**: Resolution_Status must align with actual ticket lifecycle
4. **Feature Usage**: Can only exist for valid meetings with corresponding Meeting_ID
5. **Billing Events**: Must correspond to users with appropriate license entitlements
6. **Attendee Records**: Can only exist for valid meetings and valid users
7. **License Assignment**: Assigned_To_User_ID must correspond to existing user

### 2.5 Referential Integrity
1. **Meetings.Host_ID**: Must reference valid User_ID in Users table
2. **Attendees.Meeting_ID**: Must reference valid Meeting_ID in Meetings table
3. **Attendees.User_ID**: Must reference valid User_ID in Users table
4. **Features_Usage.Meeting_ID**: Must reference valid Meeting_ID in Meetings table
5. **Support_Tickets.User_ID**: Must reference valid User_ID in Users table
6. **Billing_Events.User_ID**: Must reference valid User_ID in Users table
7. **Licenses.Assigned_To_User_ID**: Must reference valid User_ID in Users table

## 3. Business Rules

### 3.1 Data Processing Rules
1. **Active User Calculation**: A user is considered active if they have hosted at least one meeting within the specified time period
2. **Feature Adoption Rate**: Calculated as the proportion of users who have used a specific feature at least once compared to total user base
3. **License Utilization Rate**: Calculated as the proportion of licenses currently assigned to users out of total available licenses
4. **Average Resolution Time**: Calculated by determining the average time taken to close a ticket after it was opened
5. **Churn Rate**: Calculated as the fraction of users who have stopped using the platform compared to total number of users
6. **Monthly Recurring Revenue**: Calculated by summing recurring billing events within monthly periods
7. **Total Meeting Minutes**: Calculated by summing Duration_Minutes across all meetings

### 3.2 Reporting Logic Rules
1. **DAU/WAU/MAU Calculation**: Based on unique users who hosted meetings within daily/weekly/monthly periods respectively
2. **Revenue by License Type**: Aggregated from billing events grouped by associated user license types
3. **Ticket Volume Analysis**: Grouped by Type field to identify most common support issues
4. **Usage Pattern Analysis**: Segmented by Plan_Type to compare free versus paid user behavior
5. **License Expiration Trends**: Based on End_Date analysis to forecast renewal requirements
6. **Feature Usage Distribution**: Calculated from Features_Usage entity aggregated by Feature_Name
7. **Support Efficiency Metrics**: Based on resolution time calculations and first-contact resolution tracking

### 3.3 Transformation Guidelines
1. **Timestamp Standardization**: All datetime fields must be converted to consistent timezone (UTC) for accurate temporal analysis
2. **Duration Calculation**: Meeting duration must be calculated as difference between End_Time and Start_Time converted to minutes
3. **User Anonymization**: Email and User_Name must be masked for non-authorized users accessing reports
4. **Revenue Aggregation**: All monetary amounts must be converted to consistent currency for accurate revenue calculations
5. **Status Normalization**: Resolution_Status and Event_Type must be standardized to predefined enumeration values
6. **Geographic Data**: Company information should be standardized for geographic revenue distribution analysis
7. **Plan Type Mapping**: Plan_Type and License_Type must be consistently mapped for cross-entity analysis