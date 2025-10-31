_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System reporting requirements
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System operates within the video communications domain, focusing on three primary business areas:

1. **Platform Usage & Adoption**: Monitoring user engagement, meeting activities, and feature utilization to understand platform adoption patterns and growth trends.

2. **Service Reliability & Support**: Tracking customer support interactions, ticket management, and service quality metrics to improve platform stability and customer satisfaction.

3. **Revenue & License Management**: Managing billing events, license assignments, and revenue tracking to understand financial performance and customer value.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform, including both free and paid subscribers
2. **Meetings**: Represents video conference sessions hosted on the Zoom platform
3. **Attendees**: Represents participants who join meetings (excluding the host)
4. **Features Usage**: Represents the utilization of specific platform features during meetings
5. **Support Tickets**: Represents customer service requests and issues reported by users
6. **Billing Events**: Represents financial transactions and billing activities for user accounts
7. **Licenses**: Represents software licenses assigned to users for different service tiers

## 3. List of Attributes for Each Entity with Descriptions

### **Users Entity**
1. **Plan Type**: The subscription tier of the user (Free, Basic, Pro, Business, Enterprise)
2. **User Name**: The display name of the user account
3. **Email**: The email address associated with the user account
4. **Company**: The organization or company name associated with the user
5. **License Type**: The type of license assigned to the user

### **Meetings Entity**
1. **Duration Minutes**: The total length of the meeting in minutes
2. **Start Time**: The date and time when the meeting began
3. **End Time**: The date and time when the meeting ended
4. **Meeting Type**: The category or type of meeting (Regular, Webinar, Personal, etc.)

### **Attendees Entity**
1. **Join Time**: The timestamp when the attendee joined the meeting
2. **Leave Time**: The timestamp when the attendee left the meeting
3. **Participant Name**: The name of the meeting participant

### **Features Usage Entity**
1. **Feature Name**: The name of the platform feature being used
2. **Usage Count**: The number of times the feature was utilized
3. **Usage Duration**: The total time the feature was active during the meeting

### **Support Tickets Entity**
1. **Type**: The category of the support issue (Technical, Billing, Feature Request, etc.)
2. **Resolution Status**: The current state of the ticket (Open, In Progress, Resolved, Closed)
3. **Open Date**: The date when the support ticket was created
4. **Close Date**: The date when the support ticket was resolved
5. **Priority Level**: The urgency level of the support ticket
6. **Description**: Detailed information about the reported issue

### **Billing Events Entity**
1. **Event Type**: The type of billing transaction (Payment, Refund, Upgrade, Downgrade)
2. **Amount**: The monetary value of the billing event
3. **Transaction Date**: The date when the billing event occurred
4. **Currency**: The currency used for the transaction
5. **Payment Method**: The method used for payment processing

### **Licenses Entity**
1. **License Type**: The category of license (Basic, Pro, Business, Enterprise)
2. **Start Date**: The date when the license becomes active
3. **End Date**: The date when the license expires
4. **License Status**: The current state of the license (Active, Expired, Suspended)
5. **Assigned Date**: The date when the license was assigned to the user

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of all meeting durations in minutes
5. **Average Meeting Duration**: Mean duration of all meetings
6. **Meetings Created Per User**: Average number of meetings hosted by each user
7. **New User Sign-ups**: Number of new user registrations over time
8. **Feature Adoption Rate**: Percentage of users utilizing specific platform features

### **Service Reliability & Support KPIs**
1. **Daily Ticket Volume**: Number of support tickets opened per day
2. **Average Resolution Time**: Mean time taken to resolve support tickets
3. **First Contact Resolution Rate**: Percentage of tickets resolved on first interaction
4. **Tickets Per 1000 Active Users**: Support ticket volume normalized by user base
5. **Ticket Volume by Type**: Distribution of support tickets across different categories

### **Revenue & License Analysis KPIs**
1. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
2. **Revenue by License Type**: Revenue distribution across different license tiers
3. **License Utilization Rate**: Percentage of assigned licenses actively being used
4. **License Expiration Trends**: Pattern of license renewals and expirations
5. **Churn Rate**: Percentage of users who discontinue platform usage
6. **Usage-Billing Correlation**: Relationship between platform usage and billing events

## 5. Conceptual Data Model Diagram in Tabular Form

| **Source Entity** | **Target Entity** | **Relationship Key Field** | **Relationship Type** | **Description** |
|-------------------|-------------------|---------------------------|----------------------|------------------|
| Users | Meetings | Host User Reference | One-to-Many | One user can host multiple meetings |
| Meetings | Attendees | Meeting Reference | One-to-Many | One meeting can have multiple attendees |
| Meetings | Features Usage | Meeting Reference | One-to-Many | One meeting can have multiple feature usage records |
| Users | Support Tickets | User Reference | One-to-Many | One user can create multiple support tickets |
| Users | Billing Events | User Reference | One-to-Many | One user can have multiple billing events |
| Users | Licenses | Assigned User Reference | One-to-Many | One user can have multiple licenses over time |

## 6. Common Data Elements in Report Requirements

The following data elements are referenced across multiple reports within the requirements:

### **Cross-Report Data Elements**
1. **User Reference**: Used in Platform Usage, Service Reliability, and Revenue Analysis reports
2. **Meeting Reference**: Used in Platform Usage and indirectly in Service Reliability reports
3. **Duration Minutes**: Used in Platform Usage and Revenue Analysis reports for usage correlation
4. **Plan Type/License Type**: Used in Platform Usage and Revenue Analysis reports
5. **Start Time/Date Fields**: Used across all reports for time-based analysis
6. **Company**: Used in Service Reliability and Revenue Analysis reports
7. **Feature Name**: Used in Platform Usage reports for adoption analysis
8. **Amount**: Used in Revenue Analysis reports for financial calculations
9. **Resolution Status**: Used in Service Reliability reports for ticket tracking
10. **Event Type**: Used in Revenue Analysis reports for transaction categorization

### **Calculated Metrics Across Reports**
1. **Active User Counts**: Calculated across Platform Usage and Revenue Analysis
2. **Average Duration**: Used in Platform Usage for meeting analysis
3. **Resolution Time**: Calculated in Service Reliability reports
4. **Revenue Totals**: Calculated in Revenue Analysis reports
5. **Utilization Rates**: Calculated across Platform Usage and Revenue Analysis
6. **Trend Analysis**: Time-based calculations used across all report types