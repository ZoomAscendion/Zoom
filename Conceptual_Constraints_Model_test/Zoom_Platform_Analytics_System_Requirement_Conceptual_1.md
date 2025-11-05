_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System operates within the video communications domain, focusing on three primary business areas: platform usage and adoption tracking, service reliability and customer support management, and revenue and license analysis. The system captures and analyzes data related to user activity, meeting operations, platform performance, support interactions, billing events, and license management to support strategic business decision-making processes.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform, including both free and paid subscribers
2. **Meetings**: Represents video conference sessions hosted on the Zoom platform
3. **Attendees**: Represents participants who join meetings hosted by users
4. **Features_Usage**: Represents the utilization of specific platform features during meetings
5. **Support_Tickets**: Represents customer service requests and issues reported by users
6. **Billing_Events**: Represents financial transactions and billing activities associated with user accounts
7. **Licenses**: Represents software licenses assigned to users for accessing platform features

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription tier or plan level associated with the user account
2. **Company**: The organization or company name associated with the user
3. **Email**: The email address used for user identification and communication
4. **User_Name**: The display name or username of the platform user

### Meetings
1. **Duration_Minutes**: The total length of the meeting measured in minutes
2. **Start_Time**: The timestamp when the meeting session began
3. **End_Time**: The timestamp when the meeting session concluded
4. **Meeting_Type**: The category or classification of the meeting session

### Attendees
1. **Meeting_ID**: Reference to the specific meeting session the attendee participated in

### Features_Usage
1. **Feature_Name**: The name or identifier of the platform feature being used
2. **Usage_Count**: The number of times a specific feature was utilized
3. **Meeting_ID**: Reference to the meeting session where the feature was used

### Support_Tickets
1. **Type**: The category or classification of the support issue
2. **Resolution_Status**: The current state of the ticket in the resolution process
3. **Open_Date**: The date when the support ticket was initially created

### Billing_Events
1. **Event_Type**: The category or nature of the billing transaction
2. **Amount**: The monetary value associated with the billing event

### Licenses
1. **License_Type**: The category or tier of the software license
2. **Start_Date**: The date when the license becomes active
3. **End_Date**: The date when the license expires
4. **Assigned_To_User_ID**: Reference to the user who has been assigned the license

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Cumulative duration of all meetings conducted on the platform
5. **Average Meeting Duration**: Mean duration across all meeting sessions
6. **Number of Meetings Created Per User**: Average meeting creation rate per individual user
7. **New User Sign-ups Over Time**: Rate of new user registrations within specific time periods
8. **Feature Adoption Rate**: Percentage of users utilizing specific platform features
9. **Number of Tickets Opened Per Day**: Daily volume of new support requests
10. **Average Ticket Resolution Time**: Mean time required to resolve customer support issues
11. **First-Contact Resolution Rate**: Percentage of tickets resolved in initial customer interaction
12. **Tickets Opened Per 1,000 Active Users**: Support ticket density relative to active user base
13. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscription services
14. **Revenue by License Type**: Financial performance segmented by license categories
15. **License Utilization Rate**: Percentage of available licenses currently assigned to users
16. **License Expiration Trends**: Patterns in license renewal and expiration timing
17. **Churn Rate**: Percentage of users who discontinue platform usage

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-----------------|
| Meetings | Host_ID | Users | Many-to-One |
| Attendees | Meeting_ID | Meetings | Many-to-One |
| Features_Usage | Meeting_ID | Meetings | Many-to-One |
| Support_Tickets | User_ID | Users | Many-to-One |
| Billing_Events | User_ID | Users | Many-to-One |
| Licenses | Assigned_To_User_ID | Users | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User_ID**: Referenced across Platform Usage & Adoption Report, Service Reliability & Support Report, and Revenue and License Analysis Report
2. **Meeting_ID**: Used in Platform Usage & Adoption Report and implied in Service Reliability & Support Report
3. **Duration_Minutes**: Appears in Platform Usage & Adoption Report and Revenue and License Analysis Report
4. **Plan_Type**: Referenced in Platform Usage & Adoption Report analysis
5. **License_Type**: Central to Revenue and License Analysis Report and user categorization
6. **Company**: Used for organizational analysis across Service Reliability & Support Report and Revenue and License Analysis Report
7. **Start_Time**: Critical for temporal analysis in Platform Usage & Adoption Report
8. **Meeting_Type**: Used for categorization in Platform Usage & Adoption Report and Service Reliability & Support Report
9. **Feature_Name**: Essential for feature adoption analysis in Platform Usage & Adoption Report
10. **Amount**: Core financial metric in Revenue and License Analysis Report