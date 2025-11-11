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
1. **Platform Usage & Adoption**: Monitoring user engagement, meeting activities, and feature adoption across the platform
2. **Service Reliability & Support**: Tracking customer support interactions, ticket resolution, and platform stability metrics
3. **Revenue & License Management**: Managing billing events, license utilization, and revenue analysis across different user segments

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform, including both free and paid users
2. **Meetings**: Represents video conference sessions hosted on the platform with various types and durations
3. **Attendees**: Represents participants who join meetings, linking users to specific meeting sessions
4. **Features_Usage**: Represents the utilization of specific platform features during meetings
5. **Support_Tickets**: Represents customer service requests and issues raised by users
6. **Billing_Events**: Represents financial transactions and billing activities associated with user accounts
7. **Licenses**: Represents software licenses assigned to users with specific types and validity periods

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription plan level of the user (Free vs. Paid)
2. **Company**: The organization or company associated with the user
3. **Email**: User's email address for communication and identification
4. **User_Name**: Display name of the user on the platform

### Meetings
1. **Duration_Minutes**: Length of the meeting session in minutes
2. **Start_Time**: Timestamp when the meeting began
3. **End_Time**: Timestamp when the meeting ended
4. **Meeting_Type**: Category or type of meeting conducted

### Attendees
1. **Meeting_ID**: Reference to the specific meeting attended
2. **User_ID**: Reference to the user who attended the meeting

### Features_Usage
1. **Feature_Name**: Name of the platform feature being used
2. **Usage_Count**: Number of times the feature was utilized
3. **Meeting_ID**: Reference to the meeting where the feature was used

### Support_Tickets
1. **Type**: Category of the support issue or request
2. **Resolution_Status**: Current status of the ticket resolution process
3. **Open_Date**: Date when the support ticket was created
4. **Company**: Organization associated with the ticket requester

### Billing_Events
1. **Event_Type**: Type of billing transaction or event
2. **Amount**: Monetary value associated with the billing event

### Licenses
1. **License_Type**: Category or tier of the software license
2. **Start_Date**: Date when the license becomes active
3. **End_Date**: Date when the license expires
4. **Assigned_To_User_ID**: Reference to the user assigned the license

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users active on a daily basis
2. **Weekly Active Users (WAU)**: Number of unique users active on a weekly basis
3. **Monthly Active Users (MAU)**: Number of unique users active on a monthly basis
4. **Total Meeting Minutes**: Cumulative duration of all meetings conducted
5. **Average Meeting Duration**: Mean duration across all meeting sessions
6. **Number of Meetings Created per User**: Meeting creation rate per individual user
7. **New User Sign-ups**: Rate of new user registrations over time
8. **Feature Adoption Rate**: Percentage of users utilizing specific platform features
9. **Number of Tickets Opened per Day**: Daily volume of support requests
10. **Average Ticket Resolution Time**: Mean time to resolve customer support issues
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on initial contact
12. **Tickets per 1,000 Active Users**: Support ticket density relative to user base
13. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
14. **Revenue by License Type**: Revenue breakdown across different license categories
15. **License Utilization Rate**: Percentage of licenses actively assigned to users
16. **License Expiration Trends**: Patterns in license renewal and expiration
17. **Churn Rate**: Percentage of users who discontinue platform usage

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

1. **User_ID**: Referenced across Platform Usage, Service Reliability, and Revenue Analysis reports
2. **Meeting_ID**: Used in Platform Usage reports and implied in Service Reliability reports
3. **Duration_Minutes**: Common metric for meeting analysis across multiple reports
4. **Plan_Type/License_Type**: Used for user segmentation in usage and revenue analysis
5. **Start_Time/End_Time**: Temporal data elements for trend analysis across all reports
6. **Company**: Organizational grouping used in support and revenue reports
7. **Amount**: Financial data element central to revenue and billing analysis
8. **Feature_Name**: Feature identification used in adoption and usage analysis
9. **Meeting_Type**: Meeting categorization used in usage and support correlation analysis
10. **Resolution_Status**: Status tracking used in service reliability metrics