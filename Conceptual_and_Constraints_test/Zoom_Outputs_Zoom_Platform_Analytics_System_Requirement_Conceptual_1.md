_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Conceptual Data Model for Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System operates within the video communications business domain, focusing on user engagement, platform performance, service reliability, and revenue management. The system captures and analyzes data related to user activities, meeting operations, support interactions, billing events, and license management to support business decision-making processes for improving service quality, identifying growth opportunities, and optimizing platform performance.

## 2. List of Entity Names with Descriptions

1. **User**: Represents individuals who use the Zoom platform, including both free and paid subscribers
2. **Meeting**: Represents video conference sessions hosted on the Zoom platform
3. **Attendee**: Represents participants who join meetings hosted by users
4. **Feature Usage**: Represents the utilization of specific platform features during meetings
5. **Support Ticket**: Represents customer service requests and issues reported by users
6. **Billing Event**: Represents financial transactions and billing activities related to user accounts
7. **License**: Represents software licenses assigned to users for accessing platform features

## 3. List of Attributes for Each Entity

### User
1. **Plan Type**: The subscription tier or plan level of the user (Free, Paid, etc.)
2. **Company**: The organization or company associated with the user
3. **Email**: The email address of the user
4. **User Name**: The display name of the user
5. **License Type**: The type of license assigned to the user

### Meeting
1. **Duration Minutes**: The length of the meeting measured in minutes
2. **Start Time**: The timestamp when the meeting began
3. **End Time**: The timestamp when the meeting ended
4. **Meeting Type**: The category or type of meeting conducted

### Attendee
1. **Participation Duration**: The amount of time an attendee spent in the meeting
2. **Join Time**: The timestamp when the attendee joined the meeting
3. **Leave Time**: The timestamp when the attendee left the meeting

### Feature Usage
1. **Feature Name**: The name of the platform feature being used
2. **Usage Count**: The number of times a feature was utilized
3. **Usage Duration**: The amount of time a feature was actively used

### Support Ticket
1. **Type**: The category or classification of the support issue
2. **Resolution Status**: The current state of the ticket (Open, Closed, In Progress)
3. **Open Date**: The date when the support ticket was created
4. **Resolution Time**: The time taken to resolve the support ticket
5. **Description**: Details about the issue or request

### Billing Event
1. **Event Type**: The type of billing transaction (Payment, Refund, Upgrade, etc.)
2. **Amount**: The monetary value associated with the billing event
3. **Transaction Date**: The date when the billing event occurred
4. **Currency**: The currency used for the transaction

### License
1. **License Type**: The category or tier of the license
2. **Start Date**: The date when the license becomes active
3. **End Date**: The date when the license expires
4. **Status**: The current state of the license (Active, Expired, Suspended)
5. **Features Included**: The platform features available with the license

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings conducted
5. **Average Meeting Duration**: Mean duration of meetings across the platform
6. **Number of Meetings Created Per User**: Average meeting creation rate per user
7. **New User Sign-ups**: Count of new users registering over time
8. **Feature Adoption Rate**: Percentage of users utilizing specific platform features
9. **Average Ticket Resolution Time**: Mean time taken to resolve support tickets
10. **First-Contact Resolution Rate**: Percentage of tickets resolved on first interaction
11. **Tickets Per 1,000 Active Users**: Support ticket volume normalized by user base
12. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
13. **Revenue by License Type**: Total revenue generated from different license tiers
14. **License Utilization Rate**: Percentage of licenses currently assigned to users
15. **License Expiration Trends**: Patterns in license renewal and expiration
16. **Churn Rate**: Percentage of users who stop using the platform

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
2. **Meeting_ID**: Used in Platform Usage & Adoption Report and implied in Service Reliability & Support Report
3. **Duration_Minutes**: Appears in Platform Usage & Adoption Report and Revenue and License Analysis Report
4. **Plan_Type/License_Type**: Referenced in Platform Usage & Adoption Report and Revenue and License Analysis Report
5. **Start_Time/Date fields**: Used across all reports for temporal analysis
6. **Company**: Referenced in Service Reliability & Support Report and Revenue and License Analysis Report
7. **Feature_Name**: Used in Platform Usage & Adoption Report for feature adoption analysis
8. **Amount**: Central to Revenue and License Analysis Report calculations
9. **Meeting_Type**: Referenced in Platform Usage & Adoption Report and Service Reliability & Support Report
10. **Resolution_Status/Type**: Key elements in Service Reliability & Support Report