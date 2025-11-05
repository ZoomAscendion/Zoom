_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Conceptual Data Model for Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System operates within the video communications business domain, focusing on three primary areas: platform usage and user adoption analytics, service reliability and customer support management, and revenue analysis with license management. The system supports decision-making processes by providing insights into user engagement patterns, service quality metrics, and financial performance indicators across the Zoom platform.

## 2. List of Entity Names with Descriptions

1. **User**: Represents individuals who use the Zoom platform, including both free and paid subscribers
2. **Meeting**: Represents video conference sessions hosted on the Zoom platform
3. **Attendee**: Represents participants who join meetings hosted by users
4. **Feature Usage**: Represents the utilization of specific Zoom features during meetings
5. **Support Ticket**: Represents customer service requests and issues reported by users
6. **Billing Event**: Represents financial transactions and billing activities related to user accounts
7. **License**: Represents software licenses assigned to users for accessing Zoom services

## 3. List of Attributes for Each Entity

### User
1. **Plan Type**: The subscription tier of the user (Free, Paid, etc.)
2. **Company**: The organization or company associated with the user
3. **Email**: The email address of the user
4. **User Name**: The display name of the user
5. **License Type**: The type of license assigned to the user

### Meeting
1. **Duration Minutes**: The length of the meeting in minutes
2. **Start Time**: The timestamp when the meeting began
3. **End Time**: The timestamp when the meeting ended
4. **Meeting Type**: The category or type of meeting conducted

### Attendee
1. **Participation Status**: The attendance status of the participant in the meeting

### Feature Usage
1. **Feature Name**: The name of the specific Zoom feature being used
2. **Usage Count**: The number of times the feature was utilized

### Support Ticket
1. **Type**: The category or classification of the support issue
2. **Resolution Status**: The current state of the ticket (open, closed, in progress)
3. **Open Date**: The date when the support ticket was created
4. **Resolution Time**: The time taken to resolve the support ticket

### Billing Event
1. **Event Type**: The type of billing transaction (payment, refund, upgrade, etc.)
2. **Amount**: The monetary value associated with the billing event

### License
1. **License Type**: The category of license (Basic, Pro, Enterprise, etc.)
2. **Start Date**: The date when the license becomes active
3. **End Date**: The date when the license expires
4. **Assignment Status**: Whether the license is currently assigned to a user

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings conducted
5. **Average Meeting Duration**: Mean duration of meetings across the platform
6. **Number of Meetings Created Per User**: Average meeting creation rate per user
7. **New User Sign-ups**: Count of new user registrations over time
8. **Feature Adoption Rate**: Percentage of users utilizing specific features
9. **Number of Tickets Opened Per Day**: Daily volume of support tickets created
10. **Average Ticket Resolution Time**: Mean time to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first contact
12. **Tickets Per 1,000 Active Users**: Support ticket volume normalized by user base
13. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
14. **Revenue by License Type**: Revenue breakdown across different license categories
15. **License Utilization Rate**: Percentage of available licenses currently assigned
16. **License Expiration Trends**: Patterns in license renewal and expiration
17. **Churn Rate**: Percentage of users who stop using the platform

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-----------------|
| Meeting | Host_ID | User | Many-to-One |
| Attendee | Meeting_ID | Meeting | Many-to-One |
| Feature Usage | Meeting_ID | Meeting | Many-to-One |
| Support Ticket | User_ID | User | Many-to-One |
| Billing Event | User_ID | User | Many-to-One |
| License | Assigned_To_User_ID | User | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User_ID**: Referenced across Platform Usage & Adoption Report, Service Reliability & Support Report, and Revenue and License Analysis Report
2. **Meeting_ID**: Used in Platform Usage & Adoption Report and referenced in Service Reliability & Support Report
3. **Duration_Minutes**: Appears in Platform Usage & Adoption Report and Revenue and License Analysis Report
4. **Start_Time/End_Time**: Used for time-based analysis across all three reports
5. **License_Type**: Referenced in Platform Usage & Adoption Report and Revenue and License Analysis Report
6. **Plan_Type**: Used in Platform Usage & Adoption Report for user segmentation
7. **Company**: Referenced in Service Reliability & Support Report and Revenue and License Analysis Report
8. **Meeting_Type**: Used in Platform Usage & Adoption Report and Service Reliability & Support Report
9. **Feature_Name**: Appears in Platform Usage & Adoption Report for feature adoption analysis
10. **Amount**: Used in Revenue and License Analysis Report for financial calculations