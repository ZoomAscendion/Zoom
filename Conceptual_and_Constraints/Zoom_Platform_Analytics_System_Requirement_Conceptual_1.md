_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Conceptual data model for Zoom Platform Analytics System reporting requirements
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System operates within the **Video Communications and Collaboration** domain. This system manages and analyzes data related to user interactions, meeting activities, platform performance, customer support, and revenue generation. The primary focus is on providing comprehensive analytics for platform usage adoption, service reliability support, and revenue license analysis to support business decision-making processes.

## 2. List of Entity Names with Descriptions

1. **Users** - Represents individual users of the Zoom platform with their profile information and subscription details
2. **Meetings** - Contains information about video meetings conducted on the platform including duration and timing
3. **Attendees** - Tracks participants who join meetings and their participation details
4. **Features Usage** - Records usage statistics of various platform features during meetings
5. **Support Tickets** - Manages customer support requests and issue resolution tracking
6. **Billing Events** - Captures all financial transactions and billing activities for users
7. **Licenses** - Manages license assignments, types, and expiration information for users

## 3. List of Attributes for Each Entity with Descriptions

### **Users Entity**
- **User Name** - Full name of the user registered on the platform
- **Email** - Email address used for user identification and communication
- **Plan Type** - Subscription plan category (Free, Basic, Pro, Business, Enterprise)
- **Company** - Organization or company name associated with the user account
- **Registration Date** - Date when the user first registered on the platform

### **Meetings Entity**
- **Meeting Type** - Category of meeting (Scheduled, Instant, Recurring, Webinar)
- **Duration Minutes** - Total length of the meeting measured in minutes
- **Start Time** - Date and time when the meeting began
- **End Time** - Date and time when the meeting concluded
- **Meeting Topic** - Subject or title of the meeting
- **Host Name** - Name of the user who organized and hosted the meeting

### **Attendees Entity**
- **Attendee Name** - Name of the participant who joined the meeting
- **Join Time** - Timestamp when the attendee entered the meeting
- **Leave Time** - Timestamp when the attendee left the meeting
- **Participation Duration** - Total time the attendee spent in the meeting
- **Device Type** - Type of device used to join the meeting (Desktop, Mobile, Web)

### **Features Usage Entity**
- **Feature Name** - Name of the specific platform feature used (Screen Share, Chat, Recording, Breakout Rooms)
- **Usage Count** - Number of times the feature was utilized during the meeting
- **Usage Duration** - Total time the feature was actively used
- **Feature Category** - Classification of the feature type (Communication, Collaboration, Security)

### **Support Tickets Entity**
- **Ticket Type** - Category of the support issue (Technical, Billing, Feature Request, Bug Report)
- **Resolution Status** - Current state of the ticket (Open, In Progress, Resolved, Closed)
- **Open Date** - Date when the support ticket was created
- **Close Date** - Date when the support ticket was resolved
- **Priority Level** - Urgency level of the support request (Low, Medium, High, Critical)
- **Issue Description** - Detailed description of the problem or request

### **Billing Events Entity**
- **Event Type** - Type of billing transaction (Subscription, Upgrade, Downgrade, Refund, Payment)
- **Amount** - Monetary value of the billing event
- **Transaction Date** - Date when the billing event occurred
- **Payment Method** - Method used for payment (Credit Card, PayPal, Bank Transfer)
- **Currency** - Currency type used for the transaction

### **Licenses Entity**
- **License Type** - Category of license (Basic, Pro, Business, Enterprise, Education)
- **Start Date** - Date when the license becomes active
- **End Date** - Date when the license expires
- **License Status** - Current state of the license (Active, Expired, Suspended, Pending)
- **Assigned User Name** - Name of the user to whom the license is assigned

## 4. KPI List

1. **Daily Active Users (DAU)** - Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)** - Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)** - Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes Per Day** - Sum of all meeting durations conducted daily
5. **Average Meeting Duration** - Mean duration of all meetings conducted
6. **Number of Meetings Created Per User** - Average count of meetings organized by each user
7. **New User Sign-ups Over Time** - Count of new user registrations within specific time periods
8. **Feature Adoption Rate** - Percentage of users who have used specific features
9. **Number of Tickets Opened Per Day** - Daily count of new support tickets created
10. **Average Ticket Resolution Time** - Mean time taken to resolve support tickets
11. **First-Contact Resolution Rate** - Percentage of tickets resolved on first interaction
12. **Tickets Opened Per 1000 Active Users** - Support ticket volume normalized by user base
13. **Monthly Recurring Revenue (MRR)** - Predictable monthly revenue from subscriptions
14. **Revenue by License Type** - Total revenue generated from each license category
15. **License Utilization Rate** - Percentage of assigned licenses out of total available
16. **License Expiration Trends** - Analysis of upcoming license renewals and expirations
17. **Churn Rate** - Percentage of users who stopped using the platform

## 5. Conceptual Data Model Diagram in Tabular Form

| **Source Entity** | **Target Entity** | **Relationship Key Field** | **Relationship Type** |
|-------------------|-------------------|----------------------------|----------------------|
| Users | Meetings | Host User Reference | One-to-Many |
| Meetings | Attendees | Meeting Reference | One-to-Many |
| Meetings | Features Usage | Meeting Reference | One-to-Many |
| Users | Support Tickets | User Reference | One-to-Many |
| Users | Billing Events | User Reference | One-to-Many |
| Users | Licenses | Assigned User Reference | One-to-Many |
| Support Tickets | Meetings | Meeting Context Reference | Many-to-One (Implied) |

## 6. Common Data Elements in Report Requirements

1. **User Reference Fields** - User identification and profile information used across multiple reports for user-centric analysis
2. **Meeting Reference Fields** - Meeting identification and basic meeting information referenced in usage and support analysis
3. **Time and Date Fields** - Temporal data elements (Start Time, End Time, Open Date, Transaction Date) used for trend analysis across all reports
4. **Duration Fields** - Time-based measurements (Duration Minutes, Resolution Time) used for performance and usage metrics
5. **Type Classification Fields** - Categorical data (Plan Type, Meeting Type, License Type, Ticket Type) used for segmentation analysis
6. **Status Fields** - State indicators (Resolution Status, License Status) used for operational monitoring
7. **Amount and Count Fields** - Quantitative measures (Amount, Usage Count, Ticket Volume) used for financial and usage analytics
8. **Feature and Service Fields** - Platform capability identifiers (Feature Name, License Type) used for adoption and utilization analysis
9. **Company and Organization Fields** - Business entity information used for enterprise-level reporting and analysis
10. **Contact Information Fields** - Communication details (Email, User Name) used for user identification and support correlation