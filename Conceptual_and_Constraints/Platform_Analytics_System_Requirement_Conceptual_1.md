_____________________________________________
## *Author*: AAVA
## *Created on*:   11-11-2025
## *Description*: Conceptual data model for Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 1 
## *Updated on*: 11-11-2025
_____________________________________________

# Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Platform Analytics System operates within the **Video Communications and Collaboration** domain. This system manages and analyzes data related to user activities, meeting operations, platform performance, customer support interactions, and revenue generation. The primary focus areas include:

- **Platform Usage & Adoption**: Tracking user engagement, meeting activities, and feature utilization
- **Service Reliability & Support**: Managing customer support tickets and platform stability metrics
- **Revenue & License Management**: Monitoring billing events, license assignments, and revenue streams

## 2. List of Entity Name with Description

1. **Users** - Represents individual users of the platform with their profile information and subscription details
2. **Meetings** - Contains information about video meetings conducted on the platform
3. **Attendees** - Tracks participants who join meetings, linking users to specific meetings
4. **Features_Usage** - Records usage of specific platform features during meetings
5. **Support_Tickets** - Manages customer support requests and their resolution process
6. **Billing_Events** - Tracks all financial transactions and billing activities
7. **Licenses** - Manages license assignments and entitlements for users

## 3. List of Attributes for each Entity with Description

### **Users Entity**
- **User Name** - Full name of the user for identification purposes
- **Email** - User's email address for communication and login
- **Plan Type** - Subscription plan category (Free, Basic, Pro, Enterprise)
- **Company** - Organization or company name associated with the user
- **Registration Date** - Date when the user first signed up for the platform

### **Meetings Entity**
- **Meeting Type** - Category of meeting (Scheduled, Instant, Webinar, etc.)
- **Duration Minutes** - Total length of the meeting in minutes
- **Start Time** - Date and time when the meeting began
- **End Time** - Date and time when the meeting concluded
- **Host Name** - Name of the user who organized and hosted the meeting

### **Attendees Entity**
- **Join Time** - Timestamp when the participant joined the meeting
- **Leave Time** - Timestamp when the participant left the meeting
- **Participant Name** - Name of the meeting attendee
- **Connection Quality** - Quality of the participant's connection during the meeting

### **Features_Usage Entity**
- **Feature Name** - Name of the specific feature used (Screen Share, Recording, Chat, etc.)
- **Usage Count** - Number of times the feature was utilized
- **Usage Duration** - Total time the feature was active during the meeting
- **Usage Timestamp** - When the feature was first activated

### **Support_Tickets Entity**
- **Ticket Type** - Category of the support issue (Technical, Billing, Feature Request, etc.)
- **Resolution Status** - Current state of the ticket (Open, In Progress, Resolved, Closed)
- **Open Date** - Date when the support ticket was created
- **Close Date** - Date when the ticket was resolved and closed
- **Priority Level** - Urgency level of the support request
- **Description** - Detailed explanation of the issue or request

### **Billing_Events Entity**
- **Event Type** - Type of billing transaction (Subscription, Upgrade, Refund, etc.)
- **Amount** - Monetary value of the transaction
- **Transaction Date** - Date when the billing event occurred
- **Payment Method** - Method used for payment (Credit Card, PayPal, etc.)
- **Currency** - Currency type for the transaction amount

### **Licenses Entity**
- **License Type** - Category of license (Basic, Pro, Enterprise, Add-on)
- **Start Date** - Date when the license becomes active
- **End Date** - Date when the license expires
- **License Status** - Current state of the license (Active, Expired, Suspended)
- **Assigned User Name** - Name of the user to whom the license is assigned

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Daily Active Users (DAU)** - Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)** - Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)** - Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes per Day** - Sum of all meeting durations in a day
5. **Average Meeting Duration** - Mean duration across all meetings
6. **Number of Meetings Created per User** - Average meetings hosted by each user
7. **New User Sign-ups Over Time** - Count of new user registrations by time period
8. **Feature Adoption Rate** - Percentage of users utilizing specific features

### **Service Reliability & Support KPIs**
9. **Number of Tickets Opened per Day** - Daily count of new support tickets
10. **Average Ticket Resolution Time** - Mean time to resolve support tickets
11. **First-Contact Resolution Rate** - Percentage of tickets resolved on first interaction
12. **Tickets Opened per 1,000 Active Users** - Support ticket volume relative to user base

### **Revenue & License Analysis KPIs**
13. **Monthly Recurring Revenue (MRR)** - Predictable monthly revenue from subscriptions
14. **Revenue by License Type** - Revenue breakdown by different license categories
15. **License Utilization Rate** - Percentage of assigned licenses out of total available
16. **License Expiration Trends** - Pattern of license renewals and expirations
17. **Churn Rate** - Percentage of users who stop using the platform

## 5. Conceptual Data Model Diagram in Tabular Form

| **Source Entity** | **Target Entity** | **Relationship Key Field** | **Relationship Type** |
|-------------------|-------------------|----------------------------|----------------------|
| Users | Meetings | Host User Reference | One-to-Many |
| Meetings | Attendees | Meeting Reference | One-to-Many |
| Meetings | Features_Usage | Meeting Reference | One-to-Many |
| Users | Support_Tickets | User Reference | One-to-Many |
| Users | Billing_Events | User Reference | One-to-Many |
| Users | Licenses | Assigned User Reference | One-to-Many |
| Users | Attendees | Attendee User Reference | One-to-Many |

## 6. Common Data Elements in Report Requirements

The following data elements are referenced across multiple reports within the requirements:

### **Cross-Report Data Elements**
1. **User Reference** - Used in Platform Usage, Service Reliability, and Revenue reports
2. **Meeting Reference** - Referenced in Platform Usage and indirectly in Service Reliability reports
3. **Duration Minutes** - Used for usage analysis and revenue correlation
4. **Plan Type** - Referenced in usage patterns and revenue analysis
5. **Start Time/Date Fields** - Used across all reports for time-based analysis
6. **Company** - Referenced in support and revenue reports for organizational analysis
7. **License Type** - Used in both usage pattern analysis and revenue reports
8. **Feature Name** - Referenced in usage reports and support ticket correlation
9. **Amount** - Used in revenue analysis and billing event tracking
10. **Resolution Status** - Used in support efficiency and service quality metrics

### **Calculated Metrics Across Reports**
1. **Total Meeting Minutes** - Aggregated across usage and revenue reports
2. **Active User Count** - Used in usage, support ratio, and revenue per user calculations
3. **Average Resolution Time** - Used in support efficiency and service quality analysis
4. **Revenue Totals** - Aggregated across different time periods and license types
5. **Usage Ratios** - Feature adoption rates and license utilization percentages
