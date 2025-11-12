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
- **Platform Usage & Adoption**: Monitoring user engagement, meeting activities, and feature adoption rates
- **Service Reliability & Support**: Analyzing platform stability and customer support interactions
- **Revenue & License Management**: Tracking billing events, license utilization, and revenue streams

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform, including both free and paid users
2. **Meetings**: Represents video conference sessions hosted on the Zoom platform
3. **Attendees**: Represents participants who join meetings hosted by users
4. **Features_Usage**: Represents the utilization of specific platform features during meetings
5. **Support_Tickets**: Represents customer service requests and issues reported by users
6. **Billing_Events**: Represents financial transactions and billing activities for user accounts
7. **Licenses**: Represents software licenses assigned to users for platform access

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription plan type (Free vs. Paid) assigned to the user
2. **Company**: The organization or company associated with the user
3. **Email**: The user's email address for communication and authentication
4. **User_Name**: The display name of the user on the platform
5. **License_Type**: The type of license assigned to the user

### Meetings
1. **Duration_Minutes**: The total duration of the meeting measured in minutes
2. **Start_Time**: The timestamp when the meeting began
3. **End_Time**: The timestamp when the meeting ended
4. **Meeting_Type**: The category or type of meeting being conducted
5. **Category**: The classification of the meeting for organizational purposes

### Attendees
1. **Meeting_ID**: Reference to the specific meeting the attendee joined
2. **User_ID**: Reference to the user who attended the meeting

### Features_Usage
1. **Feature_Name**: The name of the specific platform feature being used
2. **Usage_Count**: The number of times the feature was utilized
3. **Meeting_ID**: Reference to the meeting where the feature was used

### Support_Tickets
1. **Type**: The category or classification of the support issue
2. **Resolution_Status**: The current status of the ticket (open, closed, in progress)
3. **Open_Date**: The date when the support ticket was created
4. **User_ID**: Reference to the user who submitted the ticket
5. **Company**: The organization associated with the ticket submitter

### Billing_Events
1. **Event_Type**: The type of billing transaction or event
2. **Amount**: The monetary value associated with the billing event
3. **User_ID**: Reference to the user associated with the billing event

### Licenses
1. **License_Type**: The category or tier of the software license
2. **Start_Date**: The date when the license becomes active
3. **End_Date**: The date when the license expires
4. **Assigned_To_User_ID**: Reference to the user assigned to this license

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings
5. **Average Meeting Duration**: Mean duration of all meetings
6. **Number of Meetings Created Per User**: Count of meetings hosted by each user
7. **New User Sign-ups Over Time**: Count of new user registrations by time period
8. **Feature Adoption Rate**: Proportion of users who have used specific features
9. **Number of Tickets Opened Per Day**: Daily count of new support tickets
10. **Average Ticket Resolution Time**: Mean time to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first contact
12. **Tickets Opened Per 1,000 Active Users**: Support ticket ratio relative to user base
13. **Monthly Recurring Revenue (MRR)**: Recurring revenue generated monthly
14. **Revenue by License Type**: Total revenue segmented by license categories
15. **License Utilization Rate**: Proportion of assigned licenses out of total available
16. **License Expiration Trends**: Pattern of license renewals and expirations
17. **Churn Rate**: Fraction of users who stopped using the platform

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meetings | Host_ID | Users | Many-to-One |
| Attendees | Meeting_ID | Meetings | Many-to-One |
| Attendees | User_ID | Users | Many-to-One |
| Features_Usage | Meeting_ID | Meetings | Many-to-One |
| Support_Tickets | User_ID | Users | Many-to-One |
| Billing_Events | User_ID | Users | Many-to-One |
| Licenses | Assigned_To_User_ID | Users | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User_ID**: Referenced across Users, Support_Tickets, Billing_Events, and Licenses entities
2. **Meeting_ID**: Referenced across Meetings, Attendees, and Features_Usage entities
3. **Duration_Minutes**: Used in Platform Usage & Adoption and Revenue Analysis reports
4. **Plan_Type/License_Type**: Used across Platform Usage and Revenue Analysis reports
5. **Start_Time/End_Time**: Used for temporal analysis across all three reports
6. **Company**: Referenced in Support and Revenue reports for organizational analysis
7. **Amount**: Used in Revenue Analysis for financial calculations
8. **Feature_Name**: Used in Platform Usage for feature adoption analysis
9. **Resolution_Status**: Used in Service Reliability for support efficiency metrics
10. **Event_Type**: Used in Revenue Analysis for billing event categorization