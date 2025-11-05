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

1. **Platform Usage & Adoption**: Monitoring user engagement, meeting activities, and feature adoption across the platform
2. **Service Reliability & Support**: Tracking customer support interactions, ticket management, and platform stability metrics
3. **Revenue & License Management**: Managing billing events, license utilization, and revenue analysis for business growth

## 2. List of Entity Names with Descriptions

1. **Users**: Platform users who can host meetings and utilize Zoom services
2. **Meetings**: Video conference sessions hosted on the Zoom platform
3. **Attendees**: Participants who join meetings hosted by users
4. **Features_Usage**: Records of specific feature utilization during meetings
5. **Support_Tickets**: Customer support requests and issues raised by users
6. **Billing_Events**: Financial transactions and billing activities for user accounts
7. **Licenses**: Software licenses assigned to users for platform access and features

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription plan type (Free vs. Paid) assigned to the user
2. **Company**: The organization or company associated with the user account
3. **Email**: User's email address for account identification
4. **User_Name**: Display name of the user on the platform

### Meetings
1. **Duration_Minutes**: Total duration of the meeting measured in minutes
2. **Start_Time**: Timestamp when the meeting session began
3. **End_Time**: Timestamp when the meeting session ended
4. **Meeting_Type**: Category or type classification of the meeting

### Attendees
1. **Meeting_ID**: Reference to the specific meeting the attendee joined

### Features_Usage
1. **Feature_Name**: Name of the specific feature being used during meetings
2. **Usage_Count**: Number of times the feature was utilized

### Support_Tickets
1. **Type**: Category classification of the support issue or request
2. **Resolution_Status**: Current status of the ticket resolution process
3. **Open_Date**: Date when the support ticket was initially created

### Billing_Events
1. **Event_Type**: Type of billing transaction or financial event
2. **Amount**: Monetary value associated with the billing event

### Licenses
1. **License_Type**: Category or tier of the software license
2. **Start_Date**: Date when the license becomes active
3. **End_Date**: Date when the license expires
4. **Assigned_To_User_ID**: Reference to the user who has been assigned the license

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users active on a daily basis
2. **Weekly Active Users (WAU)**: Number of unique users active on a weekly basis
3. **Monthly Active Users (MAU)**: Number of unique users active on a monthly basis
4. **Total Meeting Minutes**: Cumulative duration of all meetings conducted
5. **Average Meeting Duration**: Mean duration across all meeting sessions
6. **Number of Meetings Created Per User**: Meeting creation rate by individual users
7. **New User Sign-ups Over Time**: Rate of new user registrations
8. **Feature Adoption Rate**: Percentage of users utilizing specific platform features
9. **Number of Tickets Opened Per Day**: Daily volume of support ticket creation
10. **Average Ticket Resolution Time**: Mean time taken to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on initial contact
12. **Tickets Opened Per 1,000 Active Users**: Support ticket density relative to user base
13. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
14. **Revenue by License_Type**: Revenue distribution across different license categories
15. **License Utilization Rate**: Percentage of licenses currently assigned and active
16. **License Expiration Trends**: Patterns in license renewal and expiration
17. **Usage Correlation with Billing Events**: Relationship between platform usage and billing activities

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

1. **User_ID**: Referenced across Platform Usage, Service Reliability, and Revenue Analysis reports
2. **Meeting_ID**: Used in Platform Usage and Features Usage tracking
3. **Duration_Minutes**: Common metric for meeting analysis and usage patterns
4. **Start_Time/End_Time**: Temporal data used across all reporting domains
5. **Plan_Type/License_Type**: User categorization used in usage and revenue analysis
6. **Company**: Organizational grouping used in support and revenue reports
7. **Meeting_Type**: Classification used in usage analysis and support correlation
8. **Amount**: Financial data used in billing and revenue calculations
9. **Feature_Name**: Feature tracking used in adoption and usage analysis
10. **Resolution_Status**: Support ticket status used in service reliability metrics