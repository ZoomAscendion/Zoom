_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Enhanced conceptual data model for Zoom Platform Analytics System reporting requirements
## *Version*: 2 
## *Changes*: Enhanced entity relationships, refined attribute definitions, added missing KPIs, improved data model diagram with proper foreign key relationships
## *Reason*: Comprehensive review and enhancement of the initial conceptual data model to better align with reporting requirements and improve data architecture foundation
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System encompasses three primary business domains that support comprehensive analytics and decision-making:

1. **Platform Usage & Adoption**: Monitoring user engagement, meeting activities, feature utilization, and platform adoption patterns to drive growth strategies
2. **Service Reliability & Support**: Tracking platform stability, customer support interactions, issue resolution efficiency, and service quality metrics
3. **Revenue & License Management**: Managing billing events, license utilization, revenue analysis, and customer lifecycle management

## 2. List of Entity Names with Descriptions

1. **Users**: Core entity representing individuals who use the Zoom platform, serving as the central reference point for all user-related activities
2. **Meetings**: Central entity capturing video conference sessions, webinars, and related meeting activities across the platform
3. **Attendees**: Entity representing participants in meetings beyond the host, tracking attendance patterns and engagement
4. **Features Usage**: Entity tracking utilization of specific platform features during meetings to measure feature adoption and usage patterns
5. **Support Tickets**: Entity managing customer service requests, issue tracking, and support interaction history
6. **Billing Events**: Entity capturing all financial transactions, billing activities, and revenue-generating events
7. **Licenses**: Entity managing software licenses, subscriptions, and entitlements assigned to users

## 3. List of Attributes for Each Entity with Descriptions

### **Users Entity**
- **User Name**: Full name of the platform user for identification and personalization
- **Email Address**: Primary email address used for user communication, authentication, and identification
- **Plan Type**: Subscription tier (Free, Basic, Pro, Enterprise) indicating service level and feature access
- **Company**: Organization or business entity associated with the user for enterprise analytics
- **Registration Date**: Date when the user first signed up for the platform to track user acquisition
- **Account Status**: Current status of the user account (Active, Suspended, Inactive)
- **Geographic Location**: User's primary location for regional analysis and compliance

### **Meetings Entity**
- **Meeting Title**: Descriptive name or subject of the meeting for identification and categorization
- **Duration Minutes**: Total length of the meeting measured in minutes for usage analytics
- **Start Time**: Timestamp when the meeting began for scheduling and usage pattern analysis
- **End Time**: Timestamp when the meeting concluded for duration calculations
- **Meeting Type**: Category of meeting (Scheduled, Instant, Recurring, Webinar) for usage pattern analysis
- **Host Name**: Name of the user who organized and hosted the meeting
- **Participant Count**: Total number of attendees who joined the meeting
- **Recording Status**: Whether the meeting was recorded (Yes/No) for feature usage tracking

### **Attendees Entity**
- **Participant Name**: Name of the individual attending the meeting for attendance tracking
- **Join Time**: Timestamp when the attendee entered the meeting for engagement analysis
- **Leave Time**: Timestamp when the attendee exited the meeting for session duration tracking
- **Attendance Duration**: Total time the attendee spent in the meeting measured in minutes
- **Participant Role**: Role of the attendee (Host, Co-host, Participant, Panelist)
- **Connection Quality**: Quality of the participant's connection (Excellent, Good, Fair, Poor)

### **Features Usage Entity**
- **Feature Name**: Specific platform feature being utilized (Screen Share, Recording, Chat, Breakout Rooms, etc.)
- **Usage Count**: Number of times the feature was used during the meeting
- **Usage Duration**: Total time the feature was active during the meeting measured in minutes
- **Feature Category**: Category of the feature (Communication, Collaboration, Security, Recording)
- **Usage Timestamp**: When the feature was first activated during the meeting

### **Support Tickets Entity**
- **Ticket Type**: Category of the support request (Technical, Billing, Feature Request, Account Issues)
- **Issue Description**: Detailed explanation of the problem or request submitted by the user
- **Priority Level**: Urgency classification (Low, Medium, High, Critical) based on business impact
- **Resolution Status**: Current state of the ticket (Open, In Progress, Resolved, Closed, Escalated)
- **Open Date**: Date when the support ticket was created by the user or system
- **Close Date**: Date when the support ticket was resolved and closed
- **Assigned Agent**: Support team member responsible for handling and resolving the ticket
- **Resolution Time**: Total time taken to resolve the ticket measured in hours
- **Customer Satisfaction Score**: Rating provided by the user after ticket resolution

### **Billing Events Entity**
- **Event Type**: Type of billing transaction (Subscription, Upgrade, Downgrade, Refund, Payment, Renewal)
- **Amount**: Monetary value of the transaction in the specified currency
- **Currency**: Currency denomination for the transaction (USD, EUR, GBP, etc.)
- **Transaction Date**: Date when the billing event occurred for revenue tracking
- **Payment Method**: Method used for payment (Credit Card, Bank Transfer, PayPal, etc.)
- **Billing Cycle**: Billing frequency (Monthly, Annual, One-time) for revenue forecasting
- **Transaction Status**: Status of the transaction (Successful, Failed, Pending, Refunded)

### **Licenses Entity**
- **License Type**: Category of software license (Basic, Pro, Enterprise, Add-on, Webinar, Phone)
- **Start Date**: Date when the license becomes active and available for use
- **End Date**: Date when the license expires and requires renewal
- **License Status**: Current state of the license (Active, Expired, Suspended, Cancelled)
- **Assigned User Name**: Name of the user to whom the license is allocated
- **License Capacity**: Maximum number of participants or features allowed under the license
- **Renewal Status**: Whether the license is set for automatic renewal (Auto-renew, Manual, Cancelled)

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Daily Active Users (DAU)**: Number of unique users who hosted at least one meeting per day
2. **Weekly Active Users (WAU)**: Number of unique users who hosted at least one meeting per week
3. **Monthly Active Users (MAU)**: Number of unique users who hosted at least one meeting per month
4. **Total Meeting Minutes**: Sum of all meeting durations across the platform per time period
5. **Average Meeting Duration**: Mean duration of all meetings conducted on the platform
6. **Meetings Created per User**: Average number of meetings hosted by each user over a specific period
7. **New User Sign-ups**: Count of new user registrations over time to track growth
8. **Feature Adoption Rate**: Percentage of users utilizing specific platform features
9. **User Retention Rate**: Percentage of users who continue using the platform over time
10. **Meeting Frequency**: Average number of meetings per user per time period

### **Service Reliability & Support KPIs**
1. **Daily Ticket Volume**: Number of support tickets opened per day
2. **Average Resolution Time**: Mean time taken to resolve support tickets measured in hours
3. **First Contact Resolution Rate**: Percentage of tickets resolved on first interaction with support
4. **Tickets per 1000 Active Users**: Support ticket volume normalized by active user base
5. **Ticket Volume by Type**: Distribution of support requests across different issue categories
6. **Customer Satisfaction Score**: Average rating provided by users after ticket resolution
7. **Escalation Rate**: Percentage of tickets that require escalation to higher support tiers
8. **Agent Productivity**: Average number of tickets resolved per support agent per day

### **Revenue & License Analysis KPIs**
1. **Monthly Recurring Revenue (MRR)**: Predictable monthly revenue from subscriptions and licenses
2. **Revenue by License Type**: Revenue distribution across different license categories and tiers
3. **License Utilization Rate**: Percentage of available licenses currently assigned to active users
4. **License Expiration Trends**: Analysis of upcoming license renewals and potential churn
5. **Churn Rate**: Percentage of users who discontinue platform usage or cancel subscriptions
6. **Average Revenue Per User (ARPU)**: Mean revenue generated per user over a specific period
7. **Customer Lifetime Value (CLV)**: Predicted total revenue from a customer over their entire relationship
8. **Conversion Rate**: Percentage of free users who upgrade to paid plans
9. **Renewal Rate**: Percentage of licenses that are renewed upon expiration

## 5. Conceptual Data Model Diagram in Tabular Form

| **Primary Entity** | **Related Entity** | **Relationship Key Field** | **Relationship Type** | **Business Rule** |
|-------------------|-------------------|---------------------------|----------------------|-------------------|
| Users | Meetings | User Name → Host Name | One-to-Many | One user can host multiple meetings |
| Meetings | Attendees | Meeting Title → Meeting Reference | One-to-Many | One meeting can have multiple attendees |
| Meetings | Features Usage | Meeting Title → Meeting Reference | One-to-Many | One meeting can have multiple feature usage records |
| Users | Support Tickets | User Name → Ticket Requester | One-to-Many | One user can create multiple support tickets |
| Users | Billing Events | User Name → Account Holder | One-to-Many | One user can have multiple billing events |
| Users | Licenses | User Name → Assigned User Name | One-to-Many | One user can have multiple licenses assigned |
| Support Tickets | Meetings | Issue Context → Meeting Reference | Many-to-One (Optional) | Support tickets may reference specific meetings |
| Billing Events | Licenses | Transaction Reference → License Reference | One-to-One (Optional) | Billing events may be associated with specific licenses |

## 6. Common Data Elements in Report Requirements

The following data elements are referenced across multiple reports within the requirements, ensuring consistency and enabling cross-report analysis:

### **Cross-Report User Information**
- **User Name**: Primary identifier referenced in Platform Usage, Support, and Revenue reports for user-centric analysis
- **Plan Type**: Critical dimension used in Platform Usage analytics and Revenue analysis for segmentation
- **Company**: Organizational identifier utilized in Support and Revenue reports for enterprise-level insights
- **Account Status**: User account state referenced across all report types for active user calculations

### **Cross-Report Meeting Data**
- **Meeting Duration**: Core metric in Platform Usage reports and indirectly referenced in Support analysis for context
- **Meeting Type**: Used in Platform Usage visualizations and Support ticket correlation for issue categorization
- **Host Information**: Central to Platform Usage metrics and Support ticket context for user activity tracking
- **Start Time/End Time**: Temporal elements used across all reports for time-based analysis and trending

### **Cross-Report Temporal Elements**
- **Date/Time Fields**: All reports utilize various date fields for trend analysis, time-based aggregations, and historical comparisons
- **Duration Metrics**: Meeting duration, ticket resolution time, and license validity periods for performance measurement
- **Timestamp Data**: Used for real-time analytics and operational reporting across all domains

### **Cross-Report Financial Data**
- **License Type**: Referenced in both Platform Usage (plan analysis) and Revenue reports for subscription analytics
- **Revenue Amounts**: Core to Revenue reports and indirectly related to Platform Usage through plan correlations
- **Billing Cycle**: Used in Revenue forecasting and License management for renewal planning

### **Cross-Report Calculated Metrics**
- **Active User Counts**: Fundamental metric spanning Platform Usage and normalized in Support analysis for ratio calculations
- **Usage Patterns**: Feature adoption rates and meeting frequency used across Platform Usage and Revenue correlation analysis
- **Time-based Aggregations**: Daily, weekly, and monthly rollups used consistently across all report types for trend analysis
- **Conversion Metrics**: User conversion rates, feature adoption rates, and license utilization rates used across multiple domains

### **Cross-Report Quality Metrics**
- **Resolution Times**: Support ticket resolution times that may correlate with platform usage patterns
- **Satisfaction Scores**: Customer satisfaction metrics that span Support and indirectly influence Revenue retention
- **Performance Indicators**: Platform reliability metrics that impact both Support ticket volume and Revenue retention