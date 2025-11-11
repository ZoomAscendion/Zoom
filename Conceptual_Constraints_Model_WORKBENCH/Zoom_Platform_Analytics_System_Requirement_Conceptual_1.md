_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers three primary business domains: platform usage and user engagement analytics, service reliability and customer support management, and revenue analysis with license management. The system supports video communications data analysis for business decision-making, service improvement, and revenue optimization.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform with various plan types and company affiliations
2. **Meetings**: Represents video conference sessions hosted on the platform with duration and timing information
3. **Attendees**: Represents participants who join meetings hosted by other users
4. **Features_Usage**: Represents tracking of specific feature utilization within meetings
5. **Support_Tickets**: Represents customer service requests and issues raised by users
6. **Billing_Events**: Represents financial transactions and billing activities for users
7. **Licenses**: Represents software licenses assigned to users with specific types and validity periods

## 3. List of Attributes for Each Entity

### Users
1. **Plan_Type**: The subscription plan level of the user (Free vs. Paid)
2. **Company**: The organization or company the user is affiliated with
3. **Email**: User's email address for communication
4. **User_Name**: Display name of the user

### Meetings
1. **Duration_Minutes**: Length of the meeting session in minutes
2. **Start_Time**: Timestamp when the meeting began
3. **End_Time**: Timestamp when the meeting ended
4. **Meeting_Type**: Category or type of the meeting session

### Attendees
1. **Meeting_ID**: Reference to the meeting the attendee participated in

### Features_Usage
1. **Feature_Name**: Name of the specific feature being used
2. **Usage_Count**: Number of times the feature was utilized

### Support_Tickets
1. **Type**: Category of the support issue or request
2. **Resolution_Status**: Current status of the ticket resolution process
3. **Open_Date**: Date when the support ticket was created

### Billing_Events
1. **Event_Type**: Type of billing transaction or event
2. **Amount**: Monetary value associated with the billing event

### Licenses
1. **License_Type**: Category or tier of the software license
2. **Start_Date**: Date when the license becomes active
3. **End_Date**: Date when the license expires
4. **Assigned_To_User_ID**: Reference to the user who has been assigned the license

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings
5. **Average Meeting Duration**: Mean duration across all meetings
6. **Number of Meetings Created Per User**: Meeting creation rate per individual user
7. **New User Sign-ups Over Time**: Rate of new user registrations
8. **Feature Adoption Rate**: Proportion of users utilizing specific features
9. **Number of Tickets Opened Per Day**: Daily volume of support requests
10. **Average Ticket Resolution Time**: Mean time to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first interaction
12. **Tickets Opened Per 1,000 Active Users**: Support ticket density relative to user base
13. **Monthly Recurring Revenue (MRR)**: Recurring revenue generated monthly
14. **Revenue by License Type**: Revenue breakdown by different license categories
15. **License Utilization Rate**: Proportion of assigned licenses out of total available
16. **License Expiration Trends**: Patterns in license renewal and expiration
17. **Churn Rate**: Fraction of users who stopped using the platform

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-----------------|
| Meetings | Host_ID | Users | Many-to-One |
| Attendees | Meeting_ID | Meetings | Many-to-One |
| Features_Usage | Meeting_ID | Meetings | Many-to-One |
| Support_Tickets | User_ID | Users | Many-to-One |
| Billing_Events | User_ID | Users | Many-to-One |
| Licenses | Assigned_To_User_ID | Users | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User_ID**: Referenced across Platform Usage, Service Reliability, and Revenue Analysis reports
2. **Meeting_ID**: Used in Platform Usage and implied in Service Reliability reports
3. **Duration_Minutes**: Common metric for usage analysis and revenue correlation
4. **Plan_Type/License_Type**: Critical for user segmentation across all reports
5. **Company**: Used for organizational analysis in support and revenue reports
6. **Start_Time/End_Time**: Temporal analysis elements across usage and billing reports
7. **Meeting_Type**: Classification element used in usage and support correlation analysis
8. **Amount**: Financial metric central to revenue analysis and billing event tracking