_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers three primary business domains: Platform Usage & Adoption, Service Reliability & Support, and Revenue & License Analysis. This system manages data related to user activity, meeting operations, customer support interactions, billing events, and license management to support analytical dashboards for daily decision-making processes.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform with various plan types and company affiliations
2. **Meetings**: Represents video communication sessions hosted on the platform with duration and timing information
3. **Attendees**: Represents participants who join meetings, linking users to specific meeting sessions
4. **Features_Usage**: Represents the utilization of specific platform features during meetings
5. **Support_Tickets**: Represents customer support requests and issues raised by users
6. **Billing_Events**: Represents financial transactions and billing activities associated with user accounts
7. **Licenses**: Represents software licenses assigned to users with specific types and validity periods

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription plan level of the user (e.g., Free vs. Paid)
2. **Company**: The organization or company the user is affiliated with
3. **Email**: User's email address for communication and identification
4. **User_Name**: Display name of the user

### Meetings
1. **Duration_Minutes**: Length of the meeting session in minutes
2. **Start_Time**: Timestamp when the meeting began
3. **End_Time**: Timestamp when the meeting ended
4. **Meeting_Type**: Category or type of the meeting session

### Attendees
1. **Meeting participation details**: Information linking users to specific meetings they attended

### Features_Usage
1. **Feature_Name**: Name of the specific platform feature being used
2. **Usage_Count**: Number of times the feature was utilized

### Support_Tickets
1. **Type**: Category of the support issue or request
2. **Resolution_Status**: Current status of the ticket resolution process
3. **Open_Date**: Date when the support ticket was created

### Billing_Events
1. **Event_Type**: Type of billing transaction or event
2. **Amount**: Monetary value associated with the billing event

### Licenses
1. **License_Type**: Category or level of the software license
2. **Start_Date**: Date when the license becomes active
3. **End_Date**: Date when the license expires

## 4. KPI List

1. **Daily, Weekly and Monthly Active Users (DAU, WAU, MAU)**: Count of unique users active within specified time periods
2. **Total meeting minutes per day**: Aggregate duration of all meetings conducted daily
3. **Average meeting duration**: Mean length of meeting sessions
4. **Number of meetings created per user**: Meeting creation rate by individual users
5. **New user sign-ups over time**: Rate of new user registrations
6. **Feature adoption rate**: Percentage of users utilizing specific platform features
7. **Number of tickets opened per day**: Daily volume of support requests
8. **Average ticket resolution time**: Mean time to resolve support tickets
9. **First-contact resolution rate**: Percentage of tickets resolved on first interaction
10. **Tickets opened per 1,000 active users**: Support ticket density relative to user base
11. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
12. **Revenue by License_Type**: Revenue breakdown by different license categories
13. **License utilization rate**: Percentage of licenses currently assigned and active
14. **License expiration trends**: Patterns in license renewal and expiration
15. **Churn rate**: Percentage of users who stop using the platform

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
3. **Duration_Minutes**: Common metric for meeting analysis and usage calculations
4. **Plan_Type**: Referenced in usage analysis and revenue reporting
5. **License_Type**: Used in both license analysis and revenue reporting
6. **Company**: Referenced in support ticket analysis and revenue reporting
7. **Start_Time/End_Time**: Common temporal elements for trend analysis across all reports
8. **Meeting_Type**: Used in usage analysis and support correlation reporting