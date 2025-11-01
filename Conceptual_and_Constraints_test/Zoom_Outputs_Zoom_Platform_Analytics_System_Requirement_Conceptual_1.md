_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Conceptual Data Model for Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers the video communications business domain, focusing on three primary areas: platform usage and user adoption, service reliability and customer support, and revenue management with license analysis. The system manages data related to user activities, meeting operations, platform performance, customer support interactions, billing events, and license management to support business decision-making processes.

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
3. **Email**: The user's email address for communication
4. **User_Name**: The display name of the user
5. **License_Type**: The type of license assigned to the user

### Meetings
1. **Duration_Minutes**: The length of the meeting measured in minutes
2. **Start_Time**: The timestamp when the meeting began
3. **End_Time**: The timestamp when the meeting ended
4. **Meeting_Type**: The category or type of meeting conducted

### Attendees
1. **Participation_Duration**: The length of time an attendee was present in the meeting
2. **Join_Time**: The timestamp when the attendee joined the meeting
3. **Leave_Time**: The timestamp when the attendee left the meeting

### Features_Usage
1. **Feature_Name**: The name of the platform feature being used
2. **Usage_Count**: The number of times the feature was utilized
3. **Usage_Duration**: The amount of time the feature was actively used

### Support_Tickets
1. **Type**: The category of the support issue or request
2. **Resolution_Status**: The current state of the ticket (open, closed, in progress)
3. **Open_Date**: The date when the support ticket was created
4. **Close_Date**: The date when the support ticket was resolved
5. **Priority**: The urgency level assigned to the support ticket

### Billing_Events
1. **Event_Type**: The type of billing transaction (payment, refund, upgrade)
2. **Amount**: The monetary value associated with the billing event
3. **Transaction_Date**: The date when the billing event occurred
4. **Currency**: The currency used for the billing transaction

### Licenses
1. **License_Type**: The category of license (Basic, Pro, Enterprise)
2. **Start_Date**: The date when the license becomes active
3. **End_Date**: The date when the license expires
4. **Status**: The current state of the license (active, expired, suspended)

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings conducted
5. **Average Meeting Duration**: Mean duration of all meetings conducted
6. **Number of Meetings Created Per User**: Average count of meetings hosted by each user
7. **New User Sign-ups**: Count of new users registering over time
8. **Feature Adoption Rate**: Proportion of users utilizing specific features
9. **Number of Tickets Opened Per Day**: Daily count of new support tickets created
10. **Average Ticket Resolution Time**: Mean time taken to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first interaction
12. **Tickets Opened Per 1,000 Active Users**: Support ticket volume normalized by user base
13. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
14. **Revenue by License Type**: Total revenue generated from each license category
15. **License Utilization Rate**: Percentage of available licenses currently assigned
16. **License Expiration Trends**: Pattern of license renewals and expirations
17. **Churn Rate**: Percentage of users who stop using the platform

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
5. **Start_Time/End_Time**: Used for time-based analysis across all three reports
6. **Company**: Referenced in Service Reliability & Support Report and Revenue and License Analysis Report
7. **Feature_Name**: Used in Platform Usage & Adoption Report for feature adoption analysis
8. **Amount**: Central to Revenue and License Analysis Report for financial calculations
9. **Meeting_Type**: Referenced in Platform Usage & Adoption Report and Service Reliability & Support Report
10. **Resolution_Status**: Key element in Service Reliability & Support Report for tracking ticket lifecycle