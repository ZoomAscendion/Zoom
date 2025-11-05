_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Conceptual data model for Zoom Platform Analytics System supporting usage, reliability, and revenue reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System operates within the **Video Communications and Collaboration** domain. This system manages and analyzes data related to user activities, meeting operations, platform performance, customer support interactions, and revenue generation. The primary focus is on providing comprehensive analytics for business decision-making across three key areas: platform usage and adoption, service reliability and support, and revenue and license management.

## 2. List of Entity Name with Description

1. **Users** - Represents individuals who use the Zoom platform, including both free and paid subscribers
2. **Meetings** - Represents video conference sessions hosted on the Zoom platform
3. **Attendees** - Represents participants who join meetings, linking users to specific meeting sessions
4. **Features Usage** - Represents the utilization of specific platform features during meetings
5. **Support Tickets** - Represents customer service requests and issues reported by users
6. **Billing Events** - Represents financial transactions and billing activities for user accounts
7. **Licenses** - Represents software licenses assigned to users with specific terms and conditions

## 3. List of Attributes for each Entity with Description

### **Users Entity**
1. **Plan Type** - The subscription tier of the user (Free, Basic, Pro, Business, Enterprise)
2. **User Name** - The display name of the user account
3. **Email** - The email address associated with the user account
4. **Company** - The organization or company the user is affiliated with
5. **License Type** - The type of license assigned to the user

### **Meetings Entity**
1. **Duration Minutes** - The total length of the meeting in minutes
2. **Start Time** - The date and time when the meeting began
3. **End Time** - The date and time when the meeting ended
4. **Meeting Type** - The category or type of meeting (Regular, Webinar, Personal, etc.)

### **Attendees Entity**
1. **Join Time** - The timestamp when the attendee joined the meeting
2. **Leave Time** - The timestamp when the attendee left the meeting
3. **Attendance Duration** - The total time the attendee spent in the meeting

### **Features Usage Entity**
1. **Feature Name** - The name of the platform feature being used
2. **Usage Count** - The number of times the feature was utilized
3. **Usage Timestamp** - The date and time when the feature was used

### **Support Tickets Entity**
1. **Type** - The category of the support issue (Technical, Billing, Feature Request, etc.)
2. **Resolution Status** - The current state of the ticket (Open, In Progress, Resolved, Closed)
3. **Open Date** - The date when the support ticket was created
4. **Close Date** - The date when the support ticket was resolved
5. **Priority Level** - The urgency level of the support request

### **Billing Events Entity**
1. **Event Type** - The type of billing transaction (Subscription, Upgrade, Refund, etc.)
2. **Amount** - The monetary value of the billing event
3. **Transaction Date** - The date when the billing event occurred
4. **Payment Method** - The method used for payment processing

### **Licenses Entity**
1. **License Type** - The category of license (Basic, Pro, Business, Enterprise)
2. **Start Date** - The date when the license becomes active
3. **End Date** - The date when the license expires
4. **License Status** - The current state of the license (Active, Expired, Suspended)
5. **Assigned To User** - The user to whom the license is allocated

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Daily Active Users (DAU)** - Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)** - Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)** - Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes per Day** - Sum of all meeting durations in a day
5. **Average Meeting Duration** - Mean duration across all meetings
6. **Number of Meetings Created per User** - Average meetings hosted by each user
7. **New User Sign-ups Over Time** - Rate of new user registrations
8. **Feature Adoption Rate** - Percentage of users utilizing specific features

### **Service Reliability & Support KPIs**
1. **Number of Tickets Opened per Day** - Daily volume of support requests
2. **Average Ticket Resolution Time** - Mean time to resolve support tickets
3. **First-Contact Resolution Rate** - Percentage of tickets resolved on first interaction
4. **Tickets Opened per 1,000 Active Users** - Support ticket density relative to user base

### **Revenue and License Analysis KPIs**
1. **Monthly Recurring Revenue (MRR)** - Predictable monthly revenue from subscriptions
2. **Revenue by License Type** - Revenue breakdown across different license categories
3. **License Utilization Rate** - Percentage of assigned licenses actively used
4. **License Expiration Trends** - Pattern of license renewals and expirations
5. **Usage Correlation with Billing Events** - Relationship between platform usage and revenue events

## 5. Conceptual Data Model Diagram in Tabular Form

| **Source Entity** | **Target Entity** | **Relationship Key Field** | **Relationship Type** |
|-------------------|-------------------|----------------------------|----------------------|
| Users | Meetings | Host User Reference | One-to-Many |
| Meetings | Attendees | Meeting Reference | One-to-Many |
| Meetings | Features Usage | Meeting Reference | One-to-Many |
| Users | Support Tickets | User Reference | One-to-Many |
| Users | Billing Events | User Reference | One-to-Many |
| Users | Licenses | Assigned User Reference | One-to-Many |
| Attendees | Users | Attendee User Reference | Many-to-One |

## 6. Common Data Elements in Report Requirements

### **Cross-Report Data Elements**
1. **User Reference** - Used across Platform Usage, Service Reliability, and Revenue reports to identify users
2. **Meeting Reference** - Common identifier linking meetings to usage analytics and support issues
3. **Duration Minutes** - Meeting duration used in usage analytics and correlated with support patterns
4. **Plan Type/License Type** - User subscription level referenced in usage, support, and revenue analysis
5. **Start Time/Date Fields** - Temporal data used across all reports for trend analysis
6. **Company** - Organization identifier used in usage patterns and revenue analysis
7. **Feature Name** - Platform features referenced in usage adoption and support ticket categorization
8. **Amount** - Financial values used in revenue analysis and billing event tracking
9. **Resolution Status/Event Type** - Status fields used for operational reporting across support and billing
10. **Usage Count** - Quantitative metrics used in feature adoption and platform utilization analysis