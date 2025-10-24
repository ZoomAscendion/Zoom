_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Conceptual data model for Zoom Platform Analytics System reporting requirements
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System encompasses three primary business domains:

1. **Platform Usage & Adoption**: Monitoring user engagement, meeting activities, and feature adoption across the platform
2. **Service Reliability & Support**: Tracking platform stability, customer support interactions, and issue resolution
3. **Revenue & License Management**: Managing billing events, license utilization, and revenue analysis

## 2. List of Entity Names with Descriptions

1. **Users**: Core entity representing individuals who use the Zoom platform
2. **Meetings**: Central entity capturing video conference sessions and related activities
3. **Attendees**: Entity representing participants in meetings beyond the host
4. **Features Usage**: Entity tracking utilization of specific platform features during meetings
5. **Support Tickets**: Entity managing customer service requests and issue tracking
6. **Billing Events**: Entity capturing all financial transactions and billing activities
7. **Licenses**: Entity managing software licenses assigned to users

## 3. List of Attributes for Each Entity with Descriptions

### **Users Entity**
- **User Name**: Full name of the platform user
- **Email Address**: Primary email address for user communication and identification
- **Plan Type**: Subscription tier (Free, Basic, Pro, Enterprise) indicating service level
- **Company**: Organization or business entity associated with the user
- **Registration Date**: Date when the user first signed up for the platform

### **Meetings Entity**
- **Meeting Title**: Descriptive name or subject of the meeting
- **Duration Minutes**: Total length of the meeting measured in minutes
- **Start Time**: Timestamp when the meeting began
- **End Time**: Timestamp when the meeting concluded
- **Meeting Type**: Category of meeting (Scheduled, Instant, Recurring, Webinar)
- **Host Name**: Name of the user who organized and hosted the meeting

### **Attendees Entity**
- **Participant Name**: Name of the individual attending the meeting
- **Join Time**: Timestamp when the attendee entered the meeting
- **Leave Time**: Timestamp when the attendee exited the meeting
- **Attendance Duration**: Total time the attendee spent in the meeting

### **Features Usage Entity**
- **Feature Name**: Specific platform feature being utilized (Screen Share, Recording, Chat, etc.)
- **Usage Count**: Number of times the feature was used during the meeting
- **Usage Duration**: Total time the feature was active during the meeting

### **Support Tickets Entity**
- **Ticket Type**: Category of the support request (Technical, Billing, Feature Request, etc.)
- **Issue Description**: Detailed explanation of the problem or request
- **Priority Level**: Urgency classification (Low, Medium, High, Critical)
- **Resolution Status**: Current state of the ticket (Open, In Progress, Resolved, Closed)
- **Open Date**: Date when the support ticket was created
- **Close Date**: Date when the support ticket was resolved
- **Assigned Agent**: Support team member handling the ticket

### **Billing Events Entity**
- **Event Type**: Type of billing transaction (Subscription, Upgrade, Refund, Payment)
- **Amount**: Monetary value of the transaction
- **Currency**: Currency denomination for the transaction
- **Transaction Date**: Date when the billing event occurred
- **Payment Method**: Method used for payment (Credit Card, Bank Transfer, etc.)

### **Licenses Entity**
- **License Type**: Category of software license (Basic, Pro, Enterprise, Add-on)
- **Start Date**: Date when the license becomes active
- **End Date**: Date when the license expires
- **License Status**: Current state of the license (Active, Expired, Suspended)
- **Assigned User Name**: Name of the user to whom the license is allocated

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of all meeting durations across the platform
5. **Average Meeting Duration**: Mean duration of all meetings conducted
6. **Meetings Created per User**: Average number of meetings hosted by each user
7. **New User Sign-ups**: Count of new user registrations over time
8. **Feature Adoption Rate**: Percentage of users utilizing specific platform features

### **Service Reliability & Support KPIs**
1. **Daily Ticket Volume**: Number of support tickets opened per day
2. **Average Resolution Time**: Mean time taken to resolve support tickets
3. **First Contact Resolution Rate**: Percentage of tickets resolved on first interaction
4. **Tickets per 1000 Active Users**: Support ticket volume normalized by user base
5. **Ticket Volume by Type**: Distribution of support requests across different categories

### **Revenue & License Analysis KPIs**
1. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
2. **Revenue by License Type**: Revenue distribution across different license categories
3. **License Utilization Rate**: Percentage of available licenses currently assigned
4. **License Expiration Trends**: Analysis of upcoming license renewals and expirations
5. **Churn Rate**: Percentage of users who discontinue platform usage

## 5. Conceptual Data Model Diagram in Tabular Form

| **Primary Entity** | **Related Entity** | **Relationship Key Field** | **Relationship Type** |
|-------------------|-------------------|---------------------------|----------------------|
| Users | Meetings | User Name → Host Name | One-to-Many |
| Meetings | Attendees | Meeting Title → Meeting Reference | One-to-Many |
| Meetings | Features Usage | Meeting Title → Meeting Reference | One-to-Many |
| Users | Support Tickets | User Name → Ticket Requester | One-to-Many |
| Users | Billing Events | User Name → Account Holder | One-to-Many |
| Users | Licenses | User Name → Assigned User Name | One-to-Many |
| Support Tickets | Meetings | Issue Context → Meeting Reference | Many-to-One (Optional) |

## 6. Common Data Elements in Report Requirements

The following data elements are referenced across multiple reports within the requirements:

### **Cross-Report User Information**
- **User Name**: Referenced in Platform Usage, Support, and Revenue reports
- **Plan Type**: Used in Platform Usage and Revenue analysis
- **Company**: Utilized in Support and Revenue reports for organizational analysis

### **Cross-Report Meeting Data**
- **Meeting Duration**: Core metric in Platform Usage and indirectly referenced in Support analysis
- **Meeting Type**: Used in Platform Usage visualization and Support ticket correlation
- **Host Information**: Central to Platform Usage metrics and Support ticket context

### **Cross-Report Temporal Elements**
- **Date/Time Fields**: All reports utilize various date fields for trend analysis and time-based aggregations
- **Duration Metrics**: Meeting duration, ticket resolution time, and license validity periods

### **Cross-Report Financial Data**
- **License Type**: Referenced in both Platform Usage (plan analysis) and Revenue reports
- **Revenue Amounts**: Core to Revenue reports and indirectly related to Platform Usage through plan correlations

### **Cross-Report Calculated Metrics**
- **Active User Counts**: Fundamental metric spanning Platform Usage and normalized in Support analysis
- **Usage Patterns**: Feature adoption rates and meeting frequency used across Platform Usage and Revenue correlation analysis
- **Time-based Aggregations**: Daily, weekly, and monthly rollups used consistently across all report types