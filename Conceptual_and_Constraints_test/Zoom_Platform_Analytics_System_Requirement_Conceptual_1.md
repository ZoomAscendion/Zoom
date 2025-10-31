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

1. **Platform Usage & Adoption Analytics** - Monitoring user engagement, meeting activities, and feature adoption patterns
2. **Service Reliability & Support Management** - Tracking platform stability, customer support interactions, and issue resolution
3. **Revenue & License Management** - Managing billing events, license utilization, and revenue optimization

The system supports analytical reporting for business decision-making, service improvement, and revenue growth strategies.

## 2. List of Entity Names with Descriptions

1. **Users** - Represents individual users of the Zoom platform including their profile information and subscription details
2. **Meetings** - Contains information about video meetings hosted on the platform including duration and timing details
3. **Attendees** - Tracks participation of users in meetings for attendance analytics
4. **Features Usage** - Records usage patterns of specific platform features during meetings
5. **Support Tickets** - Manages customer support requests and issue tracking for service reliability analysis
6. **Billing Events** - Captures all financial transactions and billing activities for revenue tracking
7. **Licenses** - Manages license assignments, types, and expiration tracking for subscription management

## 3. List of Attributes for Each Entity with Descriptions

### **Users Entity**
- **User Name** - Full name of the platform user for identification purposes
- **Email Address** - Primary email address used for user communication and authentication
- **Plan Type** - Subscription plan category (Free, Basic, Pro, Enterprise) determining feature access
- **Company Name** - Organization name associated with the user account for business analytics
- **Registration Date** - Date when the user first signed up for the platform

### **Meetings Entity**
- **Meeting Title** - Descriptive name or subject of the meeting for identification
- **Meeting Type** - Category of meeting (Scheduled, Instant, Webinar, Personal) for usage pattern analysis
- **Duration Minutes** - Total length of the meeting in minutes for usage metrics calculation
- **Start Time** - Timestamp when the meeting began for scheduling and usage analysis
- **End Time** - Timestamp when the meeting concluded for duration calculation
- **Host Name** - Name of the user who organized and hosted the meeting

### **Attendees Entity**
- **Participant Name** - Name of the user who joined the meeting as an attendee
- **Join Time** - Timestamp when the participant entered the meeting
- **Leave Time** - Timestamp when the participant left the meeting
- **Meeting Title** - Reference to the specific meeting attended

### **Features Usage Entity**
- **Feature Name** - Name of the specific platform feature used (Screen Share, Recording, Chat, etc.)
- **Usage Count** - Number of times the feature was utilized during the meeting
- **Meeting Reference** - Connection to the specific meeting where the feature was used

### **Support Tickets Entity**
- **Ticket Type** - Category of the support request (Technical, Billing, Feature Request, Bug Report)
- **Resolution Status** - Current state of the ticket (Open, In Progress, Resolved, Closed)
- **Open Date** - Date when the support ticket was initially created
- **Close Date** - Date when the ticket was resolved and closed
- **User Name** - Name of the user who submitted the support request
- **Company Name** - Organization associated with the support ticket

### **Billing Events Entity**
- **Event Type** - Type of billing transaction (Subscription, Upgrade, Downgrade, Refund)
- **Amount** - Monetary value of the billing event for revenue calculation
- **Transaction Date** - Date when the billing event occurred
- **User Name** - Name of the user associated with the billing transaction

### **Licenses Entity**
- **License Type** - Category of license (Basic, Pro, Enterprise, Add-on) defining feature access
- **Start Date** - Date when the license becomes active and valid
- **End Date** - Expiration date of the license for renewal tracking
- **Assigned User Name** - Name of the user to whom the license is allocated
- **License Status** - Current state of the license (Active, Expired, Suspended)

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Daily Active Users (DAU)** - Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)** - Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)** - Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes Per Day** - Sum of all meeting durations in a single day
5. **Average Meeting Duration** - Mean duration across all meetings
6. **Number of Meetings Created Per User** - Average meeting creation rate per user
7. **New User Sign-ups Over Time** - Count of new user registrations within specific time periods
8. **Feature Adoption Rate** - Percentage of users utilizing specific platform features

### **Service Reliability & Support KPIs**
9. **Number of Tickets Opened Per Day** - Daily count of new support requests
10. **Average Ticket Resolution Time** - Mean time from ticket creation to closure
11. **First-Contact Resolution Rate** - Percentage of tickets resolved in initial interaction
12. **Tickets Opened Per 1,000 Active Users** - Support ticket density relative to user base

### **Revenue & License Analysis KPIs**
13. **Monthly Recurring Revenue (MRR)** - Predictable monthly revenue from subscriptions
14. **Revenue by License Type** - Revenue breakdown across different subscription tiers
15. **License Utilization Rate** - Percentage of assigned licenses actively being used
16. **License Expiration Trends** - Pattern analysis of upcoming license renewals
17. **Usage Correlation with Billing Events** - Relationship between platform usage and upgrade patterns

## 5. Conceptual Data Model Diagram in Tabular Form

| **Entity 1** | **Relationship** | **Entity 2** | **Key Field** | **Description** |
|--------------|------------------|---------------|---------------|------------------|
| Users | One-to-Many | Meetings | User Name → Host Name | One user can host multiple meetings |
| Meetings | One-to-Many | Attendees | Meeting Title → Meeting Title | One meeting can have multiple attendees |
| Users | One-to-Many | Attendees | User Name → Participant Name | One user can attend multiple meetings |
| Meetings | One-to-Many | Features Usage | Meeting Title → Meeting Reference | One meeting can have multiple feature usage records |
| Users | One-to-Many | Support Tickets | User Name → User Name | One user can create multiple support tickets |
| Users | One-to-Many | Billing Events | User Name → User Name | One user can have multiple billing transactions |
| Users | One-to-Many | Licenses | User Name → Assigned User Name | One user can be assigned multiple licenses |

## 6. Common Data Elements in Report Requirements

The following data elements are referenced across multiple reports within the requirements:

### **Cross-Report Data Elements**
1. **User Name** - Referenced in Platform Usage, Service Reliability, and Revenue Analysis reports
2. **Plan Type** - Used in Platform Usage and Revenue Analysis for segmentation
3. **Company Name** - Appears in Service Reliability and Revenue Analysis for organizational insights
4. **Meeting Duration Minutes** - Central to Platform Usage and indirectly referenced in Revenue Analysis
5. **Meeting Type** - Used in Platform Usage and Service Reliability reports
6. **License Type** - Referenced in Platform Usage (plan analysis) and Revenue Analysis reports
7. **Start Date/Time** - Common timestamp element across Platform Usage and Service Reliability
8. **Feature Name** - Referenced in Platform Usage for adoption analysis
9. **Amount** - Financial metric used across Revenue Analysis calculations
10. **Resolution Status** - Service quality metric referenced in Service Reliability reporting

### **Calculated Metrics Across Reports**
1. **Total Meeting Minutes** - Aggregated across Platform Usage and Revenue correlation analysis
2. **Active Users Count** - Fundamental metric used in Platform Usage and Service Reliability ratios
3. **Average Resolution Time** - Service quality metric for Support analysis
4. **Revenue Totals** - Financial aggregations for Revenue Analysis reporting
5. **Usage Rates** - Feature and license utilization metrics spanning multiple report categories