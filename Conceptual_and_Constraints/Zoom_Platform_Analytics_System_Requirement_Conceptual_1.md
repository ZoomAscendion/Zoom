_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Conceptual data model for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System operates within the **Video Communications and Collaboration** domain. This system manages and analyzes data related to user interactions, meeting activities, platform performance, customer support, and revenue generation. The primary focus is on providing comprehensive analytics for business decision-making across three key areas: platform usage and adoption, service reliability and support, and revenue and license management.

## 2. List of Entity Names with Descriptions

1. **Users** - Represents individuals who use the Zoom platform, including both free and paid subscribers
2. **Meetings** - Represents video conference sessions hosted on the Zoom platform
3. **Attendees** - Represents participants who join meetings, linking users to specific meeting sessions
4. **Features_Usage** - Represents the utilization of specific platform features during meetings
5. **Support_Tickets** - Represents customer service requests and issues reported by users
6. **Billing_Events** - Represents financial transactions and billing activities for user accounts
7. **Licenses** - Represents software licenses assigned to users with specific terms and conditions

## 3. List of Attributes for Each Entity with Descriptions

### **Users Entity**
1. **User Name** - The display name or full name of the user account
2. **Email Address** - The primary email address associated with the user account
3. **Plan Type** - The subscription tier (Free, Basic, Pro, Business, Enterprise) assigned to the user
4. **Company Name** - The organization or company name associated with the user account
5. **Registration Date** - The date when the user first created their Zoom account
6. **Account Status** - The current status of the user account (Active, Inactive, Suspended)

### **Meetings Entity**
1. **Meeting Title** - The name or subject assigned to the meeting session
2. **Duration Minutes** - The total length of the meeting measured in minutes
3. **Start Time** - The date and time when the meeting began
4. **End Time** - The date and time when the meeting concluded
5. **Meeting Type** - The category of meeting (Scheduled, Instant, Recurring, Webinar)
6. **Host Name** - The name of the user who organized and hosted the meeting
7. **Meeting Status** - The current state of the meeting (Scheduled, In Progress, Completed, Cancelled)

### **Attendees Entity**
1. **Join Time** - The timestamp when the participant joined the meeting
2. **Leave Time** - The timestamp when the participant left the meeting
3. **Attendance Duration** - The total time the participant spent in the meeting
4. **Participant Role** - The role of the attendee (Host, Co-host, Participant, Panelist)
5. **Connection Quality** - The network connection quality during the meeting (Excellent, Good, Fair, Poor)

### **Features_Usage Entity**
1. **Feature Name** - The specific platform feature being used (Screen Share, Recording, Chat, Breakout Rooms)
2. **Usage Count** - The number of times the feature was utilized during the meeting
3. **Usage Duration** - The total time the feature was active during the meeting
4. **Feature Category** - The classification of the feature (Communication, Collaboration, Security, Recording)

### **Support_Tickets Entity**
1. **Ticket Type** - The category of the support request (Technical, Billing, Account, Feature Request)
2. **Priority Level** - The urgency level assigned to the ticket (Low, Medium, High, Critical)
3. **Resolution Status** - The current state of the ticket (Open, In Progress, Resolved, Closed)
4. **Open Date** - The date when the support ticket was created
5. **Close Date** - The date when the support ticket was resolved or closed
6. **Subject** - The brief description or title of the support issue
7. **Description** - The detailed explanation of the problem or request

### **Billing_Events Entity**
1. **Event Type** - The type of billing transaction (Subscription, Upgrade, Downgrade, Refund, Payment)
2. **Amount** - The monetary value associated with the billing event
3. **Currency** - The currency denomination for the billing amount
4. **Transaction Date** - The date when the billing event occurred
5. **Payment Method** - The method used for payment (Credit Card, PayPal, Bank Transfer, Invoice)
6. **Transaction Status** - The status of the billing transaction (Pending, Completed, Failed, Refunded)

### **Licenses Entity**
1. **License Type** - The category of license (Basic, Pro, Business, Enterprise, Add-on)
2. **Start Date** - The date when the license becomes active
3. **End Date** - The date when the license expires
4. **License Status** - The current state of the license (Active, Expired, Suspended, Cancelled)
5. **Assigned User Name** - The name of the user to whom the license is assigned
6. **License Features** - The specific features and capabilities included in the license
7. **Renewal Status** - The renewal state of the license (Auto-renew, Manual, Cancelled)

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Daily Active Users (DAU)** - Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)** - Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)** - Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes** - Sum of all meeting durations across the platform
5. **Average Meeting Duration** - Mean duration of all meetings conducted
6. **Meetings Created Per User** - Average number of meetings hosted by each user
7. **New User Sign-ups** - Number of new user registrations over time
8. **Feature Adoption Rate** - Percentage of users utilizing specific platform features

### **Service Reliability & Support KPIs**
1. **Daily Ticket Volume** - Number of support tickets opened per day
2. **Average Resolution Time** - Mean time taken to resolve support tickets
3. **First-Contact Resolution Rate** - Percentage of tickets resolved on first interaction
4. **Tickets Per 1000 Active Users** - Support ticket volume normalized by user base
5. **Ticket Volume by Type** - Distribution of support requests by category
6. **Support Team Efficiency** - Metrics measuring support team performance

### **Revenue & License Analysis KPIs**
1. **Monthly Recurring Revenue (MRR)** - Predictable monthly revenue from subscriptions
2. **Revenue by License Type** - Revenue distribution across different license tiers
3. **License Utilization Rate** - Percentage of assigned licenses actively being used
4. **License Expiration Trends** - Patterns in license renewal and expiration
5. **Customer Churn Rate** - Percentage of users who discontinue service
6. **Usage-Billing Correlation** - Relationship between platform usage and billing events

## 5. Conceptual Data Model Diagram in Tabular Form

| **Source Entity** | **Target Entity** | **Relationship Key Field** | **Relationship Type** | **Description** |
|-------------------|-------------------|----------------------------|----------------------|------------------|
| Users | Meetings | User Name → Host Name | One-to-Many | One user can host multiple meetings |
| Meetings | Attendees | Meeting Title → Meeting Reference | One-to-Many | One meeting can have multiple attendees |
| Users | Attendees | User Name → Participant Name | One-to-Many | One user can attend multiple meetings |
| Meetings | Features_Usage | Meeting Title → Meeting Reference | One-to-Many | One meeting can have multiple feature usage records |
| Users | Support_Tickets | User Name → Ticket Owner | One-to-Many | One user can create multiple support tickets |
| Users | Billing_Events | User Name → Account Holder | One-to-Many | One user can have multiple billing events |
| Users | Licenses | User Name → Assigned User Name | One-to-Many | One user can have multiple licenses assigned |

## 6. Common Data Elements in Report Requirements

The following data elements are referenced across multiple reports within the Zoom Platform Analytics System requirements:

### **Cross-Report Data Elements**
1. **User Name** - Referenced in Platform Usage, Service Reliability, and Revenue Analysis reports
2. **Plan Type** - Used in Platform Usage and Revenue Analysis reports for segmentation
3. **Meeting Duration Minutes** - Critical metric in Platform Usage and Revenue Analysis reports
4. **Company Name** - Referenced in Service Reliability and Revenue Analysis reports
5. **Start Time/Date Fields** - Used across all reports for temporal analysis and trending
6. **License Type** - Referenced in Platform Usage and Revenue Analysis reports
7. **Meeting Type** - Used in Platform Usage and Service Reliability reports
8. **Feature Usage Data** - Referenced in Platform Usage reports and indirectly in Support reports
9. **User Activity Metrics** - Core to Platform Usage reports and Revenue correlation analysis
10. **Time-based Aggregations** - Daily, Weekly, Monthly metrics used across all three report categories

### **Shared Calculation Elements**
1. **Active User Counts** - Calculated consistently across Platform Usage and Revenue reports
2. **Time Period Aggregations** - Standard time groupings (daily, weekly, monthly) used in all reports
3. **User Segmentation** - Plan type and company-based groupings used in multiple reports
4. **Usage Correlation Metrics** - Relationships between usage patterns and business outcomes
5. **Trend Analysis Components** - Time-series calculations used across all reporting domains