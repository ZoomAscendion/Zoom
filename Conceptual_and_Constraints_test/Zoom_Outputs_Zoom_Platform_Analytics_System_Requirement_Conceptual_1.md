_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

## 1. Domain Overview

The Zoom Platform Analytics System covers the video communications business domain, focusing on three primary areas: platform usage and adoption analytics, service reliability and customer support management, and revenue and license analysis. The system manages data related to user activities, meeting operations, platform performance, customer support interactions, billing events, and license management to support business decision-making processes.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform with various plan types and company affiliations
2. **Meetings**: Represents video conference sessions hosted on the platform with duration and timing information
3. **Attendees**: Represents participants who join meetings hosted by other users
4. **Features_Usage**: Represents the utilization of specific platform features during meetings
5. **Support_Tickets**: Represents customer service requests and issues raised by users
6. **Billing_Events**: Represents financial transactions and billing activities associated with user accounts
7. **Licenses**: Represents software licenses assigned to users with specific types and validity periods

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription plan level of the user (e.g., Free vs. Paid)
2. **Company**: The organization or company the user is affiliated with
3. **Email**: The email address of the user
4. **User_Name**: The display name of the user
5. **License_Type**: The type of license assigned to the user

### Meetings
1. **Duration_Minutes**: The length of the meeting in minutes
2. **Start_Time**: The timestamp when the meeting began
3. **End_Time**: The timestamp when the meeting ended
4. **Meeting_Type**: The category or type of meeting conducted

### Attendees
1. **Meeting_ID**: Reference to the meeting the attendee participated in

### Features_Usage
1. **Feature_Name**: The name of the platform feature being used
2. **Usage_Count**: The number of times the feature was utilized

### Support_Tickets
1. **Type**: The category of the support issue or request
2. **Resolution_Status**: The current state of the ticket resolution process
3. **Open_Date**: The date when the support ticket was created

### Billing_Events
1. **Event_Type**: The type of billing transaction or event
2. **Amount**: The monetary value associated with the billing event

### Licenses
1. **License_Type**: The category or level of the software license
2. **Start_Date**: The date when the license becomes active
3. **End_Date**: The date when the license expires
4. **Assigned_To_User_ID**: Reference to the user who is assigned the license

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings conducted
5. **Average Meeting Duration**: Mean duration of all meetings
6. **Number of Meetings Created Per User**: Count of meetings hosted by individual users
7. **New User Sign-ups Over Time**: Rate of new user registrations
8. **Feature Adoption Rate**: Proportion of users utilizing specific features
9. **Number of Tickets Opened Per Day**: Daily volume of support requests
10. **Average Ticket Resolution Time**: Mean time to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first interaction
12. **Tickets Opened Per 1,000 Active Users**: Support ticket density relative to user base
13. **Monthly Recurring Revenue (MRR)**: Recurring revenue generated monthly
14. **Revenue by License Type**: Revenue breakdown by different license categories
15. **License Utilization Rate**: Proportion of assigned licenses out of total available
16. **License Expiration Trends**: Patterns in license renewal and expiration
17. **Churn Rate**: Fraction of users who stopped using the platform

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
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
4. **Plan_Type/License_Type**: Referenced in Platform Usage & Adoption Report and Revenue and License Analysis Report
5. **Company**: Mentioned in Service Reliability & Support Report and Revenue and License Analysis Report
6. **Meeting_Type**: Used in Platform Usage & Adoption Report and Service Reliability & Support Report
7. **Start_Time/End_Time**: Referenced across multiple reports for temporal analysis
8. **Amount**: Central to Revenue and License Analysis Report calculations
9. **Feature_Name**: Key element in Platform Usage & Adoption Report for feature adoption analysis
10. **Resolution_Status**: Critical for Service Reliability & Support Report metrics