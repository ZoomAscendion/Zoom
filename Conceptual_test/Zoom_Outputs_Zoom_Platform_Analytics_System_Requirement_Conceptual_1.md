_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 
_____________________________________________

## 1. Domain Overview

The Zoom Platform Analytics System covers the video communications business domain, focusing on user engagement, platform performance, service reliability, and revenue management. The system analyzes vast amounts of data related to user activity, meetings, platform usage, support interactions, billing events, and license management to support daily decision-making processes and business growth strategies.

## 2. List of Entity Names with Descriptions

1. **User**: Represents individuals who use the Zoom platform for video communications
2. **Meeting**: Represents video communication sessions hosted on the Zoom platform
3. **Attendee**: Represents participants who join meetings on the platform
4. **Feature Usage**: Represents the utilization of specific platform features during meetings
5. **Support Ticket**: Represents customer service requests and issues reported by users
6. **Billing Event**: Represents financial transactions and billing activities for platform services
7. **License**: Represents software licenses assigned to users for accessing platform features

## 3. List of Attributes for Each Entity

### User
1. **Plan Type**: The subscription plan category (Free vs. Paid) assigned to the user
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
1. **Participation Status**: The status of attendee participation in the meeting
2. **Join Time**: The timestamp when the attendee joined the meeting
3. **Leave Time**: The timestamp when the attendee left the meeting

### Feature Usage
1. **Feature Name**: The name of the platform feature being used
2. **Usage Count**: The number of times the feature was utilized
3. **Usage Duration**: The amount of time the feature was actively used

### Support Ticket
1. **Type**: The category or classification of the support issue
2. **Resolution Status**: The current state of the ticket resolution process
3. **Open Date**: The date when the support ticket was created
4. **Close Date**: The date when the support ticket was resolved
5. **Priority Level**: The urgency level assigned to the support ticket

### Billing Event
1. **Event Type**: The category of billing transaction or activity
2. **Amount**: The monetary value associated with the billing event
3. **Transaction Date**: The date when the billing event occurred
4. **Payment Status**: The status of the payment processing

### License
1. **License Type**: The category or tier of the software license
2. **Start Date**: The date when the license becomes active
3. **End Date**: The date when the license expires
4. **License Status**: The current state of the license (active, expired, suspended)
5. **Assigned To User**: The user to whom the license is allocated

## 4. KPI List

1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings conducted
5. **Average Meeting Duration**: Mean duration of all meetings conducted
6. **Number of Meetings Created Per User**: Average count of meetings hosted by each user
7. **New User Sign-ups Over Time**: Count of new user registrations within specific time periods
8. **Feature Adoption Rate**: Proportion of users who have used specific features compared to total user base
9. **Number of Tickets Opened Per Day**: Daily count of new support tickets created
10. **Average Ticket Resolution Time**: Mean time taken to resolve support tickets
11. **First-Contact Resolution Rate**: Percentage of tickets resolved on first interaction
12. **Tickets Opened Per 1,000 Active Users**: Ratio of support tickets to active user base
13. **Monthly Recurring Revenue (MRR)**: Recurring revenue generated monthly from subscriptions
14. **Revenue by License Type**: Total revenue categorized by different license tiers
15. **License Utilization Rate**: Proportion of assigned licenses out of total available licenses
16. **License Expiration Trends**: Patterns in license renewal and expiration rates
17. **Churn Rate**: Fraction of users who stopped using the platform compared to total users

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meeting | Host | User | Many-to-One |
| Attendee | Meeting | Meeting | Many-to-One |
| Feature Usage | Meeting | Meeting | Many-to-One |
| Support Ticket | User | User | Many-to-One |
| Billing Event | User | User | Many-to-One |
| License | Assigned To User | User | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User Information**: User identification, plan type, and company details appear across all three reports for user segmentation and analysis
2. **Meeting Data**: Meeting duration, start time, and meeting type are referenced in Platform Usage and Revenue Analysis reports
3. **Time-based Metrics**: Date and timestamp fields are consistently used across all reports for trend analysis and temporal reporting
4. **License Type**: Referenced in both Platform Usage and Revenue Analysis reports for plan-based analytics
5. **Duration Minutes**: Used in Platform Usage and Revenue Analysis reports for usage correlation
6. **Feature Usage**: Referenced in Platform Usage report for adoption analysis and implied in Support reports for issue correlation
7. **Revenue Amounts**: Billing event amounts are central to Revenue Analysis and indirectly referenced in other reports for value correlation
8. **Resolution Metrics**: Support ticket resolution data is used for service quality assessment across reliability reporting
9. **User Activity Indicators**: Active user counts and engagement metrics span across usage and revenue reporting
10. **Geographic Distribution**: Company and user location data support revenue distribution analysis and usage pattern identification