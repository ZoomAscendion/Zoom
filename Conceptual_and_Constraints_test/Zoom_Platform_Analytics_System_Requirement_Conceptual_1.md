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

1. **Platform Usage & Adoption**: Focuses on user engagement, meeting activities, and feature utilization to track platform growth and user behavior patterns.

2. **Service Reliability & Support**: Manages customer support interactions, ticket resolution processes, and platform stability metrics to ensure service quality.

3. **Revenue & License Management**: Handles billing events, license assignments, revenue tracking, and customer value analysis for business growth insights.

## 2. List of Entity Names with Descriptions

1. **Users**: Core entity representing all platform users including their profile information and subscription details
2. **Meetings**: Central entity capturing all meeting sessions conducted on the platform with timing and participation details
3. **Attendees**: Junction entity linking users to meetings they participated in, enabling meeting participation tracking
4. **Features Usage**: Entity tracking the utilization of various platform features during meetings for adoption analysis
5. **Support Tickets**: Entity managing customer support requests and issue resolution tracking
6. **Billing Events**: Entity recording all financial transactions and billing activities for revenue tracking
7. **Licenses**: Entity managing license assignments, types, and lifecycle for subscription management

## 3. List of Attributes for Each Entity with Descriptions

### Users Entity
1. **User Name**: Full name of the platform user for identification purposes
2. **Email Address**: Primary email address used for user communication and login
3. **Plan Type**: Subscription plan category (Free, Basic, Pro, Enterprise) determining user privileges
4. **Company Name**: Organization name associated with the user account for business analytics
5. **Registration Date**: Date when the user first signed up for the platform
6. **Last Login Date**: Most recent date the user accessed the platform
7. **Account Status**: Current status of the user account (Active, Inactive, Suspended)

### Meetings Entity
1. **Meeting Title**: Descriptive name or subject of the meeting session
2. **Duration Minutes**: Total length of the meeting measured in minutes
3. **Start Time**: Timestamp when the meeting session began
4. **End Time**: Timestamp when the meeting session concluded
5. **Meeting Type**: Category of meeting (Scheduled, Instant, Recurring, Webinar)
6. **Participant Count**: Total number of attendees who joined the meeting
7. **Recording Status**: Indicator whether the meeting was recorded or not
8. **Meeting Status**: Current state of the meeting (Scheduled, In Progress, Completed, Cancelled)

### Attendees Entity
1. **Join Time**: Timestamp when the attendee joined the meeting
2. **Leave Time**: Timestamp when the attendee left the meeting
3. **Attendance Duration**: Total time the attendee spent in the meeting
4. **Connection Quality**: Network connection quality during attendance (Good, Fair, Poor)
5. **Device Type**: Type of device used to join the meeting (Desktop, Mobile, Tablet)
6. **Participation Role**: Role of the attendee in the meeting (Host, Co-host, Participant, Panelist)

### Features Usage Entity
1. **Feature Name**: Name of the platform feature being tracked (Screen Share, Chat, Breakout Rooms, etc.)
2. **Usage Count**: Number of times the feature was used during the meeting
3. **Usage Duration**: Total time the feature was actively used
4. **Feature Category**: Classification of the feature type (Communication, Collaboration, Security, etc.)
5. **Usage Timestamp**: When the feature was first activated during the meeting

### Support Tickets Entity
1. **Ticket Type**: Category of the support issue (Technical, Billing, Feature Request, Bug Report)
2. **Priority Level**: Urgency level of the ticket (Low, Medium, High, Critical)
3. **Resolution Status**: Current status of the ticket (Open, In Progress, Resolved, Closed)
4. **Open Date**: Date when the ticket was initially created
5. **Close Date**: Date when the ticket was resolved and closed
6. **Subject**: Brief description of the issue or request
7. **Description**: Detailed explanation of the problem or request
8. **Assigned Agent**: Support team member handling the ticket
9. **Customer Satisfaction Rating**: User feedback rating on ticket resolution

### Billing Events Entity
1. **Event Type**: Type of billing transaction (Subscription, Upgrade, Downgrade, Refund, Payment)
2. **Amount**: Monetary value of the billing event
3. **Currency**: Currency type for the transaction amount
4. **Transaction Date**: Date when the billing event occurred
5. **Payment Method**: Method used for payment (Credit Card, PayPal, Bank Transfer, etc.)
6. **Invoice Number**: Unique identifier for the billing invoice
7. **Tax Amount**: Tax portion of the total billing amount
8. **Billing Cycle**: Recurring billing period (Monthly, Annual, One-time)

### Licenses Entity
1. **License Type**: Category of license (Basic, Pro, Enterprise, Education)
2. **Start Date**: Date when the license becomes active
3. **End Date**: Date when the license expires
4. **License Status**: Current state of the license (Active, Expired, Suspended, Pending)
5. **Seat Count**: Number of user seats included in the license
6. **Feature Set**: List of features available with this license type
7. **Renewal Date**: Date when the license is scheduled for renewal
8. **Purchase Date**: Date when the license was originally purchased

## 4. KPI List

### Platform Usage & Adoption KPIs
1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes Per Day**: Sum of all meeting durations conducted daily
5. **Average Meeting Duration**: Mean duration across all meetings
6. **Number of Meetings Created Per User**: Average meetings hosted by each user
7. **New User Sign-ups Over Time**: Count of new user registrations within specific time periods
8. **Feature Adoption Rate**: Percentage of users utilizing specific platform features

### Service Reliability & Support KPIs
1. **Number of Tickets Opened Per Day**: Daily count of new support tickets created
2. **Average Ticket Resolution Time**: Mean time taken to resolve support tickets
3. **First-Contact Resolution Rate**: Percentage of tickets resolved on first interaction
4. **Tickets Opened Per 1,000 Active Users**: Ratio of support tickets to active user base
5. **Ticket Volume by Type**: Distribution of support tickets across different issue categories
6. **User-to-Ticket Ratio**: Comparison of total tickets to active users in same period

### Revenue & License Analysis KPIs
1. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions
2. **Revenue by License Type**: Revenue distribution across different license categories
3. **License Utilization Rate**: Percentage of assigned licenses out of total available
4. **License Expiration Trends**: Pattern analysis of license renewals and expirations
5. **Usage Correlation with Billing Events**: Relationship between platform usage and upgrade events
6. **Total Revenue**: Sum of all monetary amounts from billing events
7. **Churn Rate**: Percentage of users who stopped using the platform

## 5. Conceptual Data Model Diagram in Tabular Form

| Source Entity | Target Entity | Relationship Key Field | Relationship Type | Description |
|---------------|---------------|----------------------|-------------------|-------------|
| Users | Meetings | Host User Reference | One-to-Many | One user can host multiple meetings |
| Meetings | Attendees | Meeting Reference | One-to-Many | One meeting can have multiple attendees |
| Users | Attendees | User Reference | One-to-Many | One user can attend multiple meetings |
| Meetings | Features Usage | Meeting Reference | One-to-Many | One meeting can have multiple feature usage records |
| Users | Support Tickets | User Reference | One-to-Many | One user can create multiple support tickets |
| Users | Billing Events | User Reference | One-to-Many | One user can have multiple billing events |
| Users | Licenses | Assigned User Reference | One-to-Many | One user can be assigned multiple licenses |
| Support Tickets | Meetings | Meeting Context Reference | Many-to-One | Support tickets may relate to specific meetings (implied relationship) |

## 6. Common Data Elements in Report Requirements

The following data elements are referenced across multiple reports within the Zoom Platform Analytics System:

### Cross-Report Data Elements

1. **User Reference Fields**
   - User identification appears in Platform Usage, Service Reliability, and Revenue Analysis reports
   - Used for user behavior analysis, support correlation, and revenue attribution

2. **Meeting Reference Fields**
   - Meeting information spans Platform Usage and Service Reliability reports
   - Enables correlation between meeting activities and support issues

3. **Time-based Fields**
   - Start Time, End Time, Duration Minutes appear across Platform Usage reports
   - Open Date, Close Date used in Service Reliability reports
   - Transaction Date, Start Date, End Date used in Revenue Analysis reports
   - Critical for trend analysis and time-series reporting

4. **Plan and License Type Fields**
   - Plan Type from Users entity used in Platform Usage and Revenue reports
   - License Type from Licenses entity used in Revenue Analysis reports
   - Enables segmentation analysis across user categories

5. **Company Information**
   - Company Name appears in Service Reliability and Revenue Analysis reports
   - Supports enterprise-level analytics and B2B insights

6. **Meeting Type Classification**
   - Meeting Type used in Platform Usage reports for categorization
   - Referenced in Service Reliability reports for issue correlation

7. **Amount and Revenue Fields**
   - Amount from Billing Events central to Revenue Analysis reports
   - Used for MRR calculations and revenue trend analysis

8. **Status Fields**
   - Resolution Status in Support Tickets for service quality metrics
   - License Status in Licenses for utilization analysis
   - Meeting Status for operational reporting

9. **Feature Usage Data**
   - Feature Name and Usage Count span Platform Usage reports
   - Critical for adoption rate calculations and feature popularity analysis

10. **Duration and Time Metrics**
    - Duration Minutes from Meetings used across multiple usage calculations
    - Attendance Duration from Attendees for engagement analysis
    - Usage Duration from Features Usage for feature engagement metrics