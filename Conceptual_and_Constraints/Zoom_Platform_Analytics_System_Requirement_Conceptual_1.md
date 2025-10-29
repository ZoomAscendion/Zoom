_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Conceptual data model for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System operates within the **Video Communications and Collaboration** domain. This system manages and analyzes data related to user activities, meeting operations, platform performance, customer support interactions, and revenue generation. The primary focus areas include:

1. **Platform Usage & Adoption**: Tracking user engagement, meeting activities, and feature utilization
2. **Service Reliability & Support**: Managing customer support tickets and platform stability metrics
3. **Revenue & License Management**: Monitoring billing events, license assignments, and revenue streams

## 2. List of Entity Names with Descriptions

1. **Users**: Core entity representing all platform users including hosts and attendees
2. **Meetings**: Central entity capturing all meeting sessions and their characteristics
3. **Attendees**: Junction entity linking users to meetings they participate in
4. **Features_Usage**: Entity tracking utilization of specific platform features during meetings
5. **Support_Tickets**: Entity managing customer support interactions and issue resolution
6. **Billing_Events**: Entity capturing all financial transactions and billing activities
7. **Licenses**: Entity managing license assignments, types, and lifecycle information

## 3. List of Attributes for Each Entity with Descriptions

### **Users Entity**
1. **User Name**: Full name of the registered user
2. **Email Address**: Primary email address for user communication and identification
3. **Plan Type**: Subscription tier (Free, Basic, Pro, Enterprise) indicating service level
4. **Company Name**: Organization or company affiliation of the user
5. **Registration Date**: Date when the user first signed up for the platform
6. **Last Login Date**: Most recent date the user accessed the platform
7. **Account Status**: Current status of user account (Active, Inactive, Suspended)

### **Meetings Entity**
1. **Meeting Title**: Descriptive name or subject of the meeting
2. **Meeting Type**: Category of meeting (Scheduled, Instant, Webinar, Personal)
3. **Start Time**: Date and time when the meeting began
4. **End Time**: Date and time when the meeting concluded
5. **Duration Minutes**: Total length of the meeting in minutes
6. **Host Name**: Name of the user who organized and hosted the meeting
7. **Meeting Status**: Current state of the meeting (Scheduled, In Progress, Completed, Cancelled)
8. **Recording Status**: Whether the meeting was recorded (Yes/No)

### **Attendees Entity**
1. **Join Time**: Date and time when the attendee joined the meeting
2. **Leave Time**: Date and time when the attendee left the meeting
3. **Attendance Duration**: Total time the attendee spent in the meeting
4. **Participant Role**: Role of the attendee (Host, Co-host, Participant, Observer)
5. **Connection Quality**: Network connection quality during participation

### **Features_Usage Entity**
1. **Feature Name**: Name of the specific platform feature used
2. **Usage Count**: Number of times the feature was utilized during the meeting
3. **Usage Duration**: Total time the feature was active during the meeting
4. **Feature Category**: Classification of feature type (Audio, Video, Collaboration, Security)

### **Support_Tickets Entity**
1. **Ticket Type**: Category of the support issue (Technical, Billing, Feature Request, Bug Report)
2. **Priority Level**: Urgency level of the ticket (Low, Medium, High, Critical)
3. **Open Date**: Date when the support ticket was created
4. **Close Date**: Date when the support ticket was resolved
5. **Resolution Status**: Current status of the ticket (Open, In Progress, Resolved, Closed)
6. **Issue Description**: Detailed description of the problem or request
7. **Resolution Notes**: Summary of actions taken to resolve the issue

### **Billing_Events Entity**
1. **Event Type**: Type of billing transaction (Subscription, Upgrade, Downgrade, Refund)
2. **Transaction Amount**: Monetary value of the billing event
3. **Transaction Date**: Date when the billing event occurred
4. **Payment Method**: Method used for payment (Credit Card, Bank Transfer, PayPal)
5. **Currency Code**: Currency in which the transaction was processed
6. **Invoice Number**: Unique identifier for the billing invoice

### **Licenses Entity**
1. **License Type**: Category of license (Basic, Pro, Enterprise, Add-on)
2. **Start Date**: Date when the license becomes active
3. **End Date**: Date when the license expires
4. **License Status**: Current state of the license (Active, Expired, Suspended)
5. **Assigned User Name**: Name of the user to whom the license is assigned
6. **License Cost**: Price associated with the license
7. **Renewal Status**: Whether the license is set for automatic renewal

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Daily Active Users (DAU)**: Number of unique users active each day
2. **Weekly Active Users (WAU)**: Number of unique users active each week
3. **Monthly Active Users (MAU)**: Number of unique users active each month
4. **Total Meeting Minutes**: Sum of all meeting durations per time period
5. **Average Meeting Duration**: Mean duration across all meetings
6. **Meetings Created Per User**: Average number of meetings hosted by each user
7. **New User Sign-ups**: Count of new user registrations over time
8. **Feature Adoption Rate**: Percentage of users utilizing specific features

### **Service Reliability & Support KPIs**
1. **Daily Ticket Volume**: Number of support tickets opened per day
2. **Average Resolution Time**: Mean time to resolve support tickets
3. **First Contact Resolution Rate**: Percentage of tickets resolved on first interaction
4. **Tickets Per 1000 Active Users**: Support ticket density relative to user base
5. **Ticket Volume by Type**: Distribution of tickets across different categories

### **Revenue & License Analysis KPIs**
1. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
2. **Revenue by License Type**: Revenue breakdown across different license categories
3. **License Utilization Rate**: Percentage of assigned licenses out of total available
4. **License Expiration Trends**: Pattern of license renewals and expirations
5. **Customer Churn Rate**: Percentage of users who discontinue service
6. **Usage-Billing Correlation**: Relationship between platform usage and upgrade events

## 5. Conceptual Data Model Diagram in Tabular Form

| **Source Entity** | **Target Entity** | **Relationship Key Field** | **Relationship Type** | **Description** |
|-------------------|-------------------|---------------------------|----------------------|------------------|
| Users | Meetings | Host User Reference | One-to-Many | One user can host multiple meetings |
| Meetings | Attendees | Meeting Reference | One-to-Many | One meeting can have multiple attendees |
| Users | Attendees | User Reference | One-to-Many | One user can attend multiple meetings |
| Meetings | Features_Usage | Meeting Reference | One-to-Many | One meeting can have multiple feature usage records |
| Users | Support_Tickets | User Reference | One-to-Many | One user can create multiple support tickets |
| Users | Billing_Events | User Reference | One-to-Many | One user can have multiple billing events |
| Users | Licenses | Assigned User Reference | One-to-Many | One user can have multiple licenses assigned |

## 6. Common Data Elements in Report Requirements

### **Cross-Report Data Elements**

1. **User Reference Fields**:
   - User Name (appears in all three reports)
   - Plan Type (used in Platform Usage and Revenue reports)
   - Company Name (used in Service Reliability and Revenue reports)

2. **Meeting Reference Fields**:
   - Meeting Type (used in Platform Usage and Service Reliability reports)
   - Duration Minutes (used in Platform Usage and Revenue reports)
   - Start Time (used in Platform Usage report for time-based analysis)

3. **Time-based Fields**:
   - Date fields for trend analysis across all reports
   - Duration fields for calculating time-based metrics

4. **License and Billing Fields**:
   - License Type (used in Platform Usage and Revenue reports)
   - Amount fields (used in Revenue report for financial calculations)

5. **Calculated Metrics**:
   - Active User Counts (derived from multiple entities)
   - Resolution Times (calculated from Support_Tickets)
   - Revenue Totals (calculated from Billing_Events)
   - Utilization Rates (calculated from Licenses and Users)

### **Data Integration Points**

1. **User-centric Integration**: All entities connect through user references enabling comprehensive user journey analysis
2. **Meeting-centric Integration**: Meeting entity serves as central hub for usage and feature adoption analysis
3. **Time-based Integration**: Date/time fields across entities enable temporal analysis and trending
4. **Financial Integration**: Billing and License entities provide revenue and cost analysis capabilities

This conceptual data model provides the foundation for generating the three required reports while ensuring data consistency, relationship integrity, and comprehensive coverage of business requirements.