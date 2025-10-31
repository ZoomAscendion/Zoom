_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Conceptual data model for Zoom Platform Analytics System supporting usage analytics, service reliability, and revenue analysis
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System operates within the video communications domain, focusing on three primary business areas:

1. **Platform Usage & Adoption**: Monitoring user engagement, meeting activities, and feature utilization to drive growth strategies
2. **Service Reliability & Support**: Tracking platform stability, customer support interactions, and issue resolution to improve service quality
3. **Revenue & License Management**: Analyzing billing events, license utilization, and revenue streams to optimize business performance

The system captures comprehensive data about user interactions, meeting activities, support operations, and financial transactions to enable data-driven decision making across the organization.

## 2. List of Entity Name with Description

1. **Users**: Core entity representing all platform users including their profile information and subscription details
2. **Meetings**: Central entity capturing all meeting sessions hosted on the platform with timing and duration details
3. **Attendees**: Junction entity tracking participation in meetings and attendance patterns
4. **Features Usage**: Entity recording utilization of specific platform features during meetings
5. **Support Tickets**: Entity managing customer support interactions and issue tracking
6. **Billing Events**: Entity capturing all financial transactions and billing activities
7. **Licenses**: Entity managing license assignments, types, and lifecycle information

## 3. List of Attributes for Each Entity with Description

### **Users Entity**
- **User Name**: Full name of the platform user for identification purposes
- **Email**: User's email address serving as primary contact and login credential
- **Plan Type**: Subscription tier (Free, Basic, Pro, Enterprise) determining feature access
- **Company**: Organization name associated with the user account
- **Registration Date**: Date when user first signed up for the platform
- **Last Login**: Most recent platform access timestamp for activity tracking

### **Meetings Entity**
- **Meeting Title**: Descriptive name or subject of the meeting session
- **Host Name**: Name of the user who organized and hosted the meeting
- **Duration Minutes**: Total length of the meeting session in minutes
- **Start Time**: Timestamp when the meeting began
- **End Time**: Timestamp when the meeting concluded
- **Meeting Type**: Category of meeting (Scheduled, Instant, Recurring, Webinar)
- **Participant Count**: Total number of attendees who joined the meeting

### **Attendees Entity**
- **Attendee Name**: Name of the person who participated in the meeting
- **Join Time**: Timestamp when attendee entered the meeting
- **Leave Time**: Timestamp when attendee exited the meeting
- **Attendance Duration**: Total time spent by attendee in the meeting
- **Connection Quality**: Network performance rating during attendance

### **Features Usage Entity**
- **Feature Name**: Specific platform feature utilized (Screen Share, Recording, Chat, Breakout Rooms)
- **Usage Count**: Number of times the feature was activated during the meeting
- **Usage Duration**: Total time the feature was actively used
- **Usage Timestamp**: When the feature was first activated

### **Support Tickets Entity**
- **Ticket Subject**: Brief description of the issue or inquiry
- **Ticket Type**: Category of support request (Technical, Billing, Feature Request, Bug Report)
- **Priority Level**: Urgency classification (Low, Medium, High, Critical)
- **Resolution Status**: Current state of the ticket (Open, In Progress, Resolved, Closed)
- **Open Date**: When the support ticket was initially created
- **Close Date**: When the ticket was resolved and closed
- **Description**: Detailed explanation of the issue or request

### **Billing Events Entity**
- **Event Type**: Type of billing transaction (Subscription, Upgrade, Downgrade, Refund)
- **Amount**: Monetary value of the transaction
- **Transaction Date**: When the billing event occurred
- **Payment Method**: How the payment was processed (Credit Card, Bank Transfer, Invoice)
- **Currency**: Monetary unit used for the transaction

### **Licenses Entity**
- **License Type**: Category of license (Basic, Pro, Enterprise, Add-on)
- **Start Date**: When the license becomes active
- **End Date**: When the license expires
- **License Status**: Current state (Active, Expired, Suspended, Pending)
- **Assigned User Name**: Name of user to whom license is allocated
- **License Cost**: Price associated with the license

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of duration across all meetings conducted
5. **Average Meeting Duration**: Mean duration of all meetings held
6. **Meetings Created Per User**: Average number of meetings hosted by each user
7. **New User Sign-ups**: Count of new user registrations over time
8. **Feature Adoption Rate**: Percentage of users utilizing specific platform features

### **Service Reliability & Support KPIs**
9. **Daily Ticket Volume**: Number of support tickets opened per day
10. **Average Resolution Time**: Mean time taken to resolve support tickets
11. **First Contact Resolution Rate**: Percentage of tickets resolved on first interaction
12. **Tickets Per 1000 Active Users**: Support ticket density relative to user base
13. **Ticket Volume by Type**: Distribution of support requests across categories

### **Revenue & License Analysis KPIs**
14. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
15. **Revenue by License Type**: Revenue breakdown across different subscription tiers
16. **License Utilization Rate**: Percentage of purchased licenses actively assigned
17. **License Expiration Trends**: Pattern of license renewals and expirations
18. **Customer Churn Rate**: Percentage of users who discontinue service

## 5. Conceptual Data Model Diagram in Tabular Form

| **Source Entity** | **Target Entity** | **Relationship Key Field** | **Relationship Type** | **Description** |
|-------------------|-------------------|----------------------------|----------------------|------------------|
| Users | Meetings | Host User Reference | One-to-Many | One user can host multiple meetings |
| Meetings | Attendees | Meeting Reference | One-to-Many | One meeting can have multiple attendees |
| Meetings | Features Usage | Meeting Reference | One-to-Many | One meeting can have multiple feature usage records |
| Users | Support Tickets | User Reference | One-to-Many | One user can create multiple support tickets |
| Users | Billing Events | User Reference | One-to-Many | One user can have multiple billing transactions |
| Users | Licenses | Assigned User Reference | One-to-Many | One user can be assigned multiple licenses |
| Users | Attendees | Attendee User Reference | One-to-Many | One user can attend multiple meetings as attendee |

## 6. Common Data Elements in Report Requirements

The following data elements are referenced across multiple reports within the requirements:

### **Cross-Report User Information**
- **User Reference**: Used in Platform Usage, Service Reliability, and Revenue Analysis reports
- **Plan Type**: Referenced in usage analysis and revenue reporting
- **Company**: Utilized in support analysis and revenue geographic distribution

### **Cross-Report Meeting Information**
- **Meeting Reference**: Central to usage analytics and indirectly linked to support analysis
- **Duration Minutes**: Key metric in usage reports and correlated with billing events
- **Start Time/End Time**: Essential for temporal analysis across all report types
- **Meeting Type**: Used for usage pattern analysis and support ticket correlation

### **Cross-Report Temporal Elements**
- **Date Fields**: All reports require date-based filtering and trending (Registration Date, Transaction Date, Open Date, Start Date)
- **Time-based Aggregations**: Daily, weekly, and monthly groupings used across usage, support, and revenue reports

### **Cross-Report Financial Elements**
- **Amount**: Core to revenue analysis and referenced in usage correlation studies
- **License Type**: Links usage patterns with revenue streams and support requirements

### **Cross-Report Calculated Metrics**
- **Active User Counts**: Fundamental denominator for usage rates, support ratios, and revenue per user calculations
- **Resolution Times**: Support efficiency metric that impacts user satisfaction and retention
- **Usage Patterns**: Feature adoption rates that influence both support needs and upgrade opportunities