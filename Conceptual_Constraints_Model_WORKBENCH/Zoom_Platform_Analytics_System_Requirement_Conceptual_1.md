_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers three primary business domains: Platform Usage & Adoption Analytics, Service Reliability & Support Management, and Revenue & License Analysis. This system supports video communications platform operations by tracking user engagement, meeting activities, support interactions, billing events, and license management to enable data-driven business decisions for improving service reliability, identifying growth trends, and optimizing revenue streams.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform, including their account information and plan details
2. **Meetings**: Represents video conference sessions hosted on the platform with timing and duration details
3. **Attendees**: Represents participants who join meetings, linking users to specific meeting sessions
4. **Features_Usage**: Represents the utilization of specific platform features during meetings
5. **Support_Tickets**: Represents customer service requests and issues raised by users
6. **Billing_Events**: Represents financial transactions and billing activities associated with user accounts
7. **Licenses**: Represents software licenses assigned to users with validity periods and types

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription plan level of the user (Free vs. Paid)
2. **Company**: The organization or company associated with the user account
3. **User_Name**: The display name of the user
4. **Email**: The email address associated with the user account
5. **License_Type**: The type of license assigned to the user

### Meetings
1. **Duration_Minutes**: The length of the meeting session in minutes
2. **Start_Time**: The timestamp when the meeting began
3. **End_Time**: The timestamp when the meeting ended
4. **Meeting_Type**: The category or type of meeting session
5. **Category**: The classification category of the meeting

### Attendees
1. **Meeting_ID**: Reference to the specific meeting session
2. **User_ID**: Reference to the user who attended the meeting

### Features_Usage
1. **Feature_Name**: The name of the platform feature being used
2. **Usage_Count**: The number of times the feature was utilized
3. **Meeting_ID**: Reference to the meeting where the feature was used

### Support_Tickets
1. **Type**: The category or classification of the support issue
2. **Resolution_Status**: The current status of the ticket resolution process
3. **Open_Date**: The date when the support ticket was created
4. **Company**: The organization associated with the support request

### Billing_Events
1. **Event_Type**: The type of billing transaction or event
2. **Amount**: The monetary value associated with the billing event

### Licenses
1. **License_Type**: The category or tier of the software license
2. **Start_Date**: The date when the license becomes active
3. **End_Date**: The date when the license expires
4. **Assigned_To_User_ID**: Reference to the user who has been assigned the license

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings
5. **Average Meeting Duration**: Mean duration across all meeting sessions
6. **Number of Meetings Created Per User**: Count of meetings hosted by individual users
7. **New User Sign-ups Over Time**: Rate of new user registrations
8. **Feature Adoption Rate**: Proportion of users utilizing specific platform features
9. **Number of Tickets Opened Per Day**: Daily volume of support requests
10. **Average Ticket Resolution Time**: Mean time to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on initial contact
12. **Tickets Opened Per 1,000 Active Users**: Support ticket density relative to user base
13. **Monthly Recurring Revenue (MRR)**: Recurring revenue generated monthly
14. **Revenue by License Type**: Revenue breakdown by different license categories
15. **License Utilization Rate**: Proportion of assigned licenses relative to total available
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

1. **User_ID**: Referenced across Platform Usage & Adoption, Service Reliability & Support, and Revenue & License Analysis reports
2. **Meeting_ID**: Used in Platform Usage & Adoption and Features Usage tracking
3. **Duration_Minutes**: Common metric for meeting analysis and usage patterns
4. **Plan_Type/License_Type**: Critical for revenue analysis and user segmentation
5. **Start_Time/End_Time**: Temporal data used across all reporting domains for trend analysis
6. **Company**: Organizational grouping used in support and revenue reports
7. **Amount**: Financial data element central to revenue and billing analysis
8. **Resolution_Status**: Status tracking element for support ticket management
9. **Feature_Name**: Feature identification used in adoption and usage analysis
10. **Meeting_Type**: Classification element used for meeting analysis and support correlation