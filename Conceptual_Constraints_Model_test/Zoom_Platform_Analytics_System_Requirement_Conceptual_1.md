_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers three primary business domains:

1. **Platform Usage & Adoption**: Monitoring user engagement, meeting activities, and feature utilization to track growth trends and platform adoption rates.

2. **Service Reliability & Support**: Analyzing platform stability through customer support interactions, ticket resolution patterns, and service quality metrics.

3. **Revenue & License Management**: Tracking billing events, license utilization, and revenue streams to understand customer value and identify business opportunities.

## 2. List of Entity Names with Descriptions

1. **Users**: Individuals who use the Zoom platform, including both free and paid subscribers
2. **Meetings**: Video conference sessions hosted on the Zoom platform
3. **Attendees**: Participants who join meetings hosted by users
4. **Features_Usage**: Records of specific platform features being utilized during meetings
5. **Support_Tickets**: Customer service requests and issues reported by users
6. **Billing_Events**: Financial transactions and billing activities associated with user accounts
7. **Licenses**: Software licenses assigned to users for accessing platform features

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription plan level of the user (Free vs. Paid)
2. **Company**: The organization or company associated with the user
3. **Email**: User's email address for account identification
4. **User_Name**: Display name of the user
5. **License_Type**: Type of license assigned to the user

### Meetings
1. **Duration_Minutes**: Length of the meeting in minutes
2. **Start_Time**: Timestamp when the meeting began
3. **End_Time**: Timestamp when the meeting ended
4. **Meeting_Type**: Category or type of the meeting

### Attendees
1. **Attendance_Duration**: Time spent by the attendee in the meeting
2. **Join_Time**: Timestamp when the attendee joined the meeting
3. **Leave_Time**: Timestamp when the attendee left the meeting

### Features_Usage
1. **Feature_Name**: Name of the platform feature being used
2. **Usage_Count**: Number of times the feature was utilized
3. **Usage_Duration**: Time spent using the specific feature

### Support_Tickets
1. **Type**: Category of the support issue or request
2. **Resolution_Status**: Current status of the ticket (open, closed, pending)
3. **Open_Date**: Date when the ticket was created
4. **Close_Date**: Date when the ticket was resolved
5. **Priority**: Urgency level of the support ticket

### Billing_Events
1. **Event_Type**: Type of billing transaction (payment, refund, upgrade)
2. **Amount**: Monetary value of the billing event
3. **Transaction_Date**: Date when the billing event occurred
4. **Currency**: Currency used for the transaction

### Licenses
1. **License_Type**: Category of the license (Basic, Pro, Enterprise)
2. **Start_Date**: Date when the license becomes active
3. **End_Date**: Date when the license expires
4. **Status**: Current state of the license (active, expired, suspended)

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings
5. **Average Meeting Duration**: Mean duration of all meetings
6. **Number of Meetings Created Per User**: Meeting count per individual user
7. **New User Sign-ups**: Count of new user registrations over time
8. **Feature Adoption Rate**: Proportion of users utilizing specific features
9. **Number of Tickets Opened Per Day**: Daily count of new support tickets
10. **Average Ticket Resolution Time**: Mean time to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first interaction
12. **Tickets Per 1,000 Active Users**: Support ticket density relative to user base
13. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
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

1. **User_ID**: Referenced across Users, Support_Tickets, Billing_Events, and Licenses entities
2. **Meeting_ID**: Referenced across Meetings, Attendees, and Features_Usage entities
3. **Duration_Minutes**: Used in both Meetings and Attendees for time-based calculations
4. **Date/Time Fields**: Start_Time, End_Time, Open_Date, Close_Date, Transaction_Date, Start_Date, End_Date for temporal analysis
5. **License_Type**: Referenced in both Users and Licenses for license management
6. **Plan_Type**: Used for user segmentation and revenue analysis
7. **Amount**: Financial values used in billing and revenue calculations
8. **Feature_Name**: Used for feature adoption and usage analysis
9. **Meeting_Type**: Used for meeting categorization and analysis
10. **Company**: Used for organizational-level reporting and analysis