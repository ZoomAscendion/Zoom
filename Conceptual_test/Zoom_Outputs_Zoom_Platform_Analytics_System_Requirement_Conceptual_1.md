_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Conceptual Data Model for Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers the video communications business domain, focusing on three primary areas: platform usage and adoption analytics, service reliability and customer support management, and revenue and license analysis. The system manages data related to user activities, meeting operations, platform performance, customer support interactions, billing events, and license management to support business decision-making processes.

## 2. List of Entity Names with Descriptions

1. **User**: Represents individuals who use the Zoom platform with various plan types and company affiliations
2. **Meeting**: Represents video conference sessions hosted on the platform with duration and timing information
3. **Attendee**: Represents participants who join meetings hosted by other users
4. **Feature Usage**: Represents the utilization of specific platform features during meetings
5. **Support Ticket**: Represents customer service requests and issues raised by users
6. **Billing Event**: Represents financial transactions and billing activities associated with user accounts
7. **License**: Represents software licenses assigned to users with specific types and validity periods

## 3. List of Attributes for Each Entity

### User
1. **Plan Type**: The subscription plan level of the user (Free vs. Paid)
2. **Company**: The organization or company the user is affiliated with
3. **Email**: The user's email address for communication
4. **User Name**: The display name of the user

### Meeting
1. **Duration Minutes**: The length of the meeting in minutes
2. **Start Time**: The timestamp when the meeting began
3. **End Time**: The timestamp when the meeting ended
4. **Meeting Type**: The category or type of meeting conducted

### Attendee
1. **Join Time**: The timestamp when the attendee joined the meeting
2. **Leave Time**: The timestamp when the attendee left the meeting
3. **Participation Duration**: The total time the attendee was present in the meeting

### Feature Usage
1. **Feature Name**: The name of the platform feature being used
2. **Usage Count**: The number of times the feature was utilized
3. **Usage Duration**: The amount of time the feature was actively used

### Support Ticket
1. **Type**: The category of the support issue or request
2. **Resolution Status**: The current state of the ticket (open, closed, in progress)
3. **Open Date**: The date when the ticket was created
4. **Close Date**: The date when the ticket was resolved
5. **Priority Level**: The urgency level assigned to the ticket

### Billing Event
1. **Event Type**: The type of billing transaction (subscription, upgrade, payment)
2. **Amount**: The monetary value associated with the billing event
3. **Transaction Date**: The date when the billing event occurred
4. **Currency**: The currency used for the transaction

### License
1. **License Type**: The category or level of the software license
2. **Start Date**: The date when the license becomes active
3. **End Date**: The date when the license expires
4. **Status**: The current state of the license (active, expired, suspended)

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings conducted
5. **Average Meeting Duration**: Mean duration of all meetings
6. **Number of Meetings Created Per User**: Average meetings hosted by each user
7. **New User Sign-ups**: Count of new users registering over time
8. **Feature Adoption Rate**: Percentage of users utilizing specific features
9. **Number of Tickets Opened Per Day**: Daily count of new support tickets
10. **Average Ticket Resolution Time**: Mean time to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first interaction
12. **Tickets Per 1,000 Active Users**: Support ticket volume relative to user base
13. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
14. **Revenue by License Type**: Revenue breakdown by different license categories
15. **License Utilization Rate**: Percentage of licenses currently assigned to users
16. **License Expiration Trends**: Patterns in license renewal and expiration
17. **Churn Rate**: Percentage of users who stop using the platform

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meeting | Host_ID | User | Many-to-One |
| Attendee | Meeting_ID | Meeting | Many-to-One |
| Feature Usage | Meeting_ID | Meeting | Many-to-One |
| Support Ticket | User_ID | User | Many-to-One |
| Billing Event | User_ID | User | Many-to-One |
| License | Assigned_To_User_ID | User | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User_ID**: Referenced across Platform Usage & Adoption Report, Service Reliability & Support Report, and Revenue and License Analysis Report
2. **Meeting_ID**: Used in Platform Usage & Adoption Report and implicitly referenced in Service Reliability & Support Report
3. **Duration_Minutes**: Appears in Platform Usage & Adoption Report and Revenue and License Analysis Report
4. **Plan_Type/License_Type**: Referenced in Platform Usage & Adoption Report and Revenue and License Analysis Report
5. **Company**: Mentioned in Service Reliability & Support Report and Revenue and License Analysis Report
6. **Start_Time/Date fields**: Used across all reports for temporal analysis
7. **Meeting_Type**: Referenced in Platform Usage & Adoption Report and Service Reliability & Support Report
8. **Feature_Name**: Appears in Platform Usage & Adoption Report for adoption analysis
9. **Amount**: Used in Revenue and License Analysis Report for financial calculations
10. **Host_ID**: Referenced in Platform Usage & Adoption Report and Revenue and License Analysis Report