_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Conceptual Data Model for Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System operates within the video communications business domain, focusing on user engagement, platform performance, service reliability, and revenue management. The system supports analytical reporting for three primary areas: Platform Usage & Adoption, Service Reliability & Support, and Revenue & License Analysis. This domain encompasses user activity tracking, meeting management, feature usage monitoring, customer support operations, billing processes, and license administration.

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
3. **Usage Timestamp**: When the feature was accessed or used

### Support Ticket
1. **Type**: The category of the support issue or request
2. **Resolution Status**: The current state of the ticket (open, closed, in progress)
3. **Open Date**: The date when the ticket was created
4. **Resolution Date**: The date when the ticket was resolved
5. **Description**: Details about the issue or request

### Billing Event
1. **Event Type**: The type of billing transaction (payment, refund, upgrade)
2. **Amount**: The monetary value of the billing event
3. **Transaction Date**: When the billing event occurred
4. **Currency**: The currency used for the transaction

### License
1. **License Type**: The category of license (Basic, Pro, Enterprise)
2. **Start Date**: When the license becomes active
3. **End Date**: When the license expires
4. **Status**: Current state of the license (active, expired, suspended)

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings
5. **Average Meeting Duration**: Mean duration of all meetings
6. **Number of Meetings Created Per User**: Meeting count divided by user count
7. **New User Sign-ups**: Count of new user registrations over time
8. **Feature Adoption Rate**: Percentage of users who have used a specific feature
9. **Number of Tickets Opened Per Day**: Daily count of new support tickets
10. **Average Ticket Resolution Time**: Mean time to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first contact
12. **Tickets Per 1,000 Active Users**: Support ticket volume normalized by user base
13. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
14. **Revenue by License Type**: Total revenue segmented by license categories
15. **License Utilization Rate**: Percentage of licenses currently assigned to users
16. **License Expiration Trends**: Pattern of license renewals and expirations
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

1. **User_ID**: Referenced across Platform Usage & Adoption, Service Reliability & Support, and Revenue & License Analysis reports
2. **Meeting_ID**: Used in Platform Usage & Adoption and Service Reliability & Support reports
3. **Duration_Minutes**: Appears in Platform Usage & Adoption and Revenue & License Analysis reports
4. **Plan_Type/License_Type**: Referenced in Platform Usage & Adoption and Revenue & License Analysis reports
5. **Start_Time/Date fields**: Used across all three report categories for temporal analysis
6. **Company**: Referenced in Service Reliability & Support and Revenue & License Analysis reports
7. **Meeting_Type**: Appears in Platform Usage & Adoption and Service Reliability & Support reports
8. **Amount**: Used in Revenue & License Analysis for financial calculations
9. **Feature_Name**: Referenced in Platform Usage & Adoption for feature adoption analysis
10. **Resolution_Status/Status**: Used in Service Reliability & Support and Revenue & License Analysis reports