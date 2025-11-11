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
2. **Service Reliability & Support**: Tracking customer support interactions, ticket resolution, and service quality metrics
3. **Revenue & License Management**: Managing billing events, license utilization, and revenue analysis across different user segments

## 2. List of Entity Names with Descriptions

1. **Users**: Individuals who use the Zoom platform, including both free and paid users with various plan types
2. **Meetings**: Video conference sessions hosted on the platform with specific durations and participant counts
3. **Attendees**: Participants who join meetings, representing the many-to-many relationship between users and meetings
4. **Features_Usage**: Records of specific platform features being utilized during meetings or user sessions
5. **Support_Tickets**: Customer service requests and issues raised by users requiring resolution
6. **Billing_Events**: Financial transactions and billing activities associated with user accounts and services
7. **Licenses**: Software licenses assigned to users, defining their access rights and service levels

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription level or plan category of the user (Free, Paid, etc.)
2. **Company**: The organization or company associated with the user account
3. **User_Name**: The display name of the user
4. **Email**: The email address associated with the user account

### Meetings
1. **Duration_Minutes**: The total length of the meeting measured in minutes
2. **Start_Time**: The timestamp when the meeting began
3. **End_Time**: The timestamp when the meeting concluded
4. **Meeting_Type**: The category or type of meeting being conducted

### Attendees
1. **Meeting_ID**: Reference to the specific meeting the attendee participated in
2. **User_ID**: Reference to the user who attended the meeting

### Features_Usage
1. **Feature_Name**: The name of the platform feature being used
2. **Usage_Count**: The number of times the feature was utilized
3. **Meeting_ID**: Reference to the meeting during which the feature was used

### Support_Tickets
1. **Type**: The category or classification of the support issue
2. **Resolution_Status**: The current state of the ticket (open, closed, in progress, etc.)
3. **Open_Date**: The date when the support ticket was created
4. **User_ID**: Reference to the user who raised the support ticket

### Billing_Events
1. **Event_Type**: The type of billing transaction or event
2. **Amount**: The monetary value associated with the billing event
3. **User_ID**: Reference to the user account associated with the billing event

### Licenses
1. **License_Type**: The category or level of license (Basic, Pro, Enterprise, etc.)
2. **Start_Date**: The date when the license becomes active
3. **End_Date**: The date when the license expires
4. **Assigned_To_User_ID**: Reference to the user to whom the license is assigned

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings
5. **Average Meeting Duration**: Mean duration across all meetings
6. **Number of Meetings Created Per User**: Meeting count per individual user
7. **New User Sign-ups Over Time**: Rate of new user registrations
8. **Feature Adoption Rate**: Proportion of users utilizing specific features
9. **Number of Tickets Opened Per Day**: Daily volume of support requests
10. **Average Ticket Resolution Time**: Mean time to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first interaction
12. **Tickets Opened Per 1,000 Active Users**: Support ticket density relative to user base
13. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
14. **Revenue by License Type**: Revenue breakdown across different license categories
15. **License Utilization Rate**: Proportion of assigned licenses out of total available
16. **License Expiration Trends**: Patterns in license renewal and expiration
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
6. **Company**: Used in Service Reliability and Revenue Analysis reports
7. **Amount**: Used in Revenue and License Analysis for financial calculations
8. **Feature_Name**: Used in Platform Usage & Adoption for feature analysis
9. **Resolution_Status**: Used in Service Reliability & Support for ticket tracking
10. **Meeting_Type**: Used across Platform Usage and Service Reliability reports