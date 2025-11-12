_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers three primary business domains:

1. **Platform Usage & Adoption**: Monitoring user engagement, platform adoption rates, and feature usage patterns to identify growth trends and improvement areas.
2. **Service Reliability & Support**: Analyzing platform stability and customer support interactions to improve service quality and reduce ticket volume.
3. **Revenue & License Management**: Monitoring billing events and license utilization to understand revenue streams and customer value.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individual users of the Zoom platform with their account information and plan details
2. **Meetings**: Represents video conference sessions hosted on the platform with timing and duration details
3. **Attendees**: Represents participants who join meetings, linking users to specific meeting sessions
4. **Features_Usage**: Represents the utilization of specific platform features during meetings
5. **Support_Tickets**: Represents customer support requests and issues raised by users
6. **Billing_Events**: Represents financial transactions and billing activities for user accounts
7. **Licenses**: Represents software licenses assigned to users with validity periods and types

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription plan type (Free vs. Paid) associated with the user account
2. **Company**: The organization or company name associated with the user
3. **Email**: User's email address for communication and identification
4. **User_Name**: Display name or username of the platform user
5. **License_Type**: Type of license assigned to the user

### Meetings
1. **Duration_Minutes**: Total duration of the meeting session in minutes
2. **Start_Time**: Timestamp when the meeting session began
3. **End_Time**: Timestamp when the meeting session ended
4. **Meeting_Type**: Category or type classification of the meeting
5. **Category**: Additional classification for meeting categorization

### Attendees
1. **Meeting_ID**: Reference to the specific meeting session the attendee joined
2. **User_ID**: Reference to the user who attended the meeting

### Features_Usage
1. **Feature_Name**: Name of the specific platform feature that was used
2. **Usage_Count**: Number of times the feature was utilized
3. **Meeting_ID**: Reference to the meeting where the feature was used

### Support_Tickets
1. **Type**: Category or classification of the support issue
2. **Resolution_Status**: Current status of the ticket resolution process
3. **Open_Date**: Date when the support ticket was created
4. **User_ID**: Reference to the user who raised the support ticket

### Billing_Events
1. **Event_Type**: Type of billing transaction or event
2. **Amount**: Monetary value associated with the billing event
3. **User_ID**: Reference to the user account for the billing event

### Licenses
1. **License_Type**: Type or category of the software license
2. **Start_Date**: Date when the license becomes active
3. **End_Date**: Date when the license expires
4. **Assigned_To_User_ID**: Reference to the user to whom the license is assigned

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who have hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who have hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who have hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration in minutes across all meetings
5. **Average Meeting Duration**: Mean duration across all meeting sessions
6. **Number of Meetings Created Per User**: Count of meetings hosted by individual users
7. **New User Sign-ups Over Time**: Trend of new user registrations
8. **Feature Adoption Rate**: Proportion of users who have used specific features
9. **Number of Tickets Opened Per Day**: Daily count of new support tickets
10. **Average Ticket Resolution Time**: Mean time taken to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first contact
12. **Tickets Opened Per 1,000 Active Users**: Support ticket volume relative to user base
13. **Monthly Recurring Revenue (MRR)**: Recurring revenue generated monthly
14. **Revenue by License Type**: Revenue breakdown by different license categories
15. **License Utilization Rate**: Proportion of assigned licenses out of total available
16. **License Expiration Trends**: Pattern of license renewals and expirations
17. **Churn Rate**: Fraction of users who have stopped using the platform

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-----------------|
| Meetings | Host_ID | Users | Many-to-One |
| Attendees | Meeting_ID | Meetings | Many-to-One |
| Attendees | User_ID | Users | Many-to-One |
| Features_Usage | Meeting_ID | Meetings | Many-to-One |
| Support_Tickets | User_ID | Users | Many-to-One |
| Billing_Events | User_ID | Users | Many-to-One |
| Licenses | Assigned_To_User_ID | Users | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User_ID**: Referenced across Users, Support_Tickets, Billing_Events, and Licenses entities for user identification
2. **Meeting_ID**: Referenced across Meetings, Attendees, and Features_Usage entities for meeting session tracking
3. **Duration_Minutes**: Used in Platform Usage & Adoption and Revenue Analysis reports for usage correlation
4. **Plan_Type/License_Type**: Used across multiple reports for user segmentation and revenue analysis
5. **Start_Time/End_Time**: Used for temporal analysis across all reporting domains
6. **Amount**: Used in Revenue and License Analysis for financial calculations
7. **Company**: Used for organizational-level analysis across usage and revenue reports
8. **Meeting_Type**: Used for categorization in usage and support analysis
9. **Resolution_Status**: Used in Service Reliability reports for support efficiency tracking
10. **Feature_Name**: Used in Platform Usage reports for feature adoption analysis