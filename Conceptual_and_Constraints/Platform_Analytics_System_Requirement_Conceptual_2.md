_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Updated conceptual data model for Platform Analytics System with refined entities and dimensional modeling approach
## *Version*: 2
## *Changes*: Restructured entities to align with dimensional modeling principles, added dimension tables for Date, Feature, and Support Category, refined fact tables for Meeting Activity and Support Activity, updated relationships to reflect proper star schema design
## *Reason*: The original model needed to be updated to better align with the specific report requirements and implement proper dimensional modeling structure as indicated in the requirements document
## *Updated on*: 
_____________________________________________

#  Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The   Platform Analytics System operates within the **Video Communications and Collaboration** domain. This system manages and analyzes data related to user activities, meeting operations, platform performance, and customer support interactions. The primary focus areas include:

- **Platform Usage & Adoption**: Tracking user engagement, meeting activities, and feature utilization patterns
- **Service Reliability & Support**: Managing customer support interactions and resolution tracking

The system follows a dimensional modeling approach with fact tables capturing business events and dimension tables providing descriptive context for analysis and reporting.

## 2. List of Entity Name with Description

### **Fact Tables**
1. **Fact Meeting Activity** - Central fact table capturing meeting events and user participation metrics
2. **Fact Support Activity** - Records customer support interactions and resolution activities
3. **Fact Feature Usage** - Tracks utilization of platform features during meetings

### **Dimension Tables**
4. **Dim User** - Contains user profile information and subscription details
5. **Dim Meeting** - Stores meeting metadata and configuration details
6. **Dim Date** - Time dimension for temporal analysis across all business processes
7. **Dim Feature** - Catalog of platform features available for usage tracking
8. **Dim Support Category** - Hierarchical categorization of support ticket types

## 3. List of Attributes for each Entity with Description

### **Fact Meeting Activity**
- **Meeting Duration Minutes** - Total length of the meeting session in minutes
- **Number of Attendees** - Count of participants who joined the meeting
- **Meeting Start Time** - Timestamp when the meeting session began
- **Meeting End Time** - Timestamp when the meeting session concluded

### **Fact Support Activity**
- **Resolution Status** - Current state of the support ticket (Open, In Progress, Resolved, Closed)
- **Priority Level** - Urgency classification of the support request
- **Open Date** - Date when the support ticket was initially created
- **Close Date** - Date when the ticket was resolved and closed
- **Resolution Time Hours** - Total time taken to resolve the support issue

### **Fact Feature Usage**
- **Feature Usage Count** - Number of times the feature was activated during the meeting
- **Feature Usage Duration Minutes** - Total time the feature was actively used
- **Usage Start Time** - Timestamp when the feature was first activated

### **Dim User**
- **User Name** - Full name of the platform user for identification
- **User Email** - Email address for communication and account management
- **Plan Type** - Subscription tier (Free, Basic, Pro, Enterprise)
- **Company Name** - Organization associated with the user account
- **Registration Date** - Date when the user first signed up for the platform
- **User Status** - Current account status (Active, Inactive, Suspended)

### **Dim Meeting**
- **Meeting Type** - Category of meeting (Scheduled, Instant, Webinar, Recurring)
- **Meeting Topic** - Subject or title of the meeting session
- **Meeting Category** - Business classification of the meeting purpose
- **Host Name** - Name of the user who organized the meeting
- **Meeting Room Name** - Virtual room identifier or name

### **Dim Date**
- **Date Value** - Full date in standard format
- **Day of Week** - Day name (Monday, Tuesday, etc.)
- **Month Name** - Full month name (January, February, etc.)
- **Quarter** - Calendar quarter (Q1, Q2, Q3, Q4)
- **Year** - Calendar year value
- **Is Weekend** - Boolean indicator for weekend dates
- **Is Holiday** - Boolean indicator for holiday dates

### **Dim Feature**
- **Feature Name** - Name of the platform feature (Screen Share, Recording, Chat, Breakout Rooms)
- **Feature Category** - Grouping of related features (Communication, Collaboration, Security)
- **Feature Description** - Detailed explanation of feature functionality
- **Feature Status** - Availability status (Active, Deprecated, Beta)

### **Dim Support Category**
- **Category Name** - Primary support category (Technical, Billing, Feature Request)
- **Sub Category Name** - Detailed classification within the main category
- **Category Description** - Explanation of the support category scope
- **Escalation Level** - Required support tier for handling this category

## 4. KPI List

### **Platform Usage & Adoption KPIs**
1. **Total Number of Users** - Count of unique users across all meetings
2. **Average Meeting Duration** - Mean duration across all meeting sessions
3. **Number of Meetings Created per User** - Average meetings hosted by each user
4. **Feature Usage Distribution** - Percentage breakdown of feature utilization
5. **Number of Users by Meeting Topics** - User count segmented by meeting subject areas
6. **Number of Users by Meeting Type** - User distribution across different meeting categories
7. **Average Meeting Duration by Type** - Mean duration segmented by meeting type
8. **Average Meeting Duration by Category** - Mean duration segmented by meeting category

### **Service Reliability & Support KPIs**
9. **Number of Users by Support Category** - User count requiring support by category type
10. **Number of Users by Support Sub Category** - Detailed user count by specific support areas
11. **Number of Support Activities by Resolution Status** - Count of tickets by current resolution state
12. **Number of Support Activities by Priority** - Distribution of support requests by urgency level
13. **Average Resolution Time** - Mean time to resolve support tickets
14. **Support Ticket Volume Trends** - Pattern of support request creation over time

## 5. Conceptual Data Model Diagram in Tabular Form

| **Source Entity** | **Target Entity** | **Relationship Key Field** | **Relationship Type** |
|-------------------|-------------------|----------------------------|----------------------|
| Fact Meeting Activity | Dim User | User Key | Many-to-One |
| Fact Meeting Activity | Dim Meeting | Meeting Key | Many-to-One |
| Fact Meeting Activity | Dim Date | Date Key | Many-to-One |
| Fact Support Activity | Dim User | User Key | Many-to-One |
| Fact Support Activity | Dim Support Category | Support Category Key | Many-to-One |
| Fact Support Activity | Dim Date | Date Key | Many-to-One |
| Fact Feature Usage | Dim Feature | Feature Key | Many-to-One |
| Fact Feature Usage | Dim Date | Date Key | Many-to-One |
| Fact Feature Usage | Dim Meeting | Meeting Key | Many-to-One |
| Fact Feature Usage | Dim User | User Key | Many-to-One |

## 6. Common Data Elements in Report Requirements

The following data elements are referenced across multiple reports within the requirements:

### **Cross-Report Data Elements**
1. **User Key** - Referenced in both Platform Usage and Service Reliability reports for user-centric analysis
2. **Date Key** - Used across all reports for temporal analysis and trending
3. **Meeting Key** - Referenced in Platform Usage reports and indirectly in support correlation
4. **Duration Minutes** - Used for meeting analysis and productivity metrics
5. **Meeting Type** - Referenced in usage pattern analysis and duration comparisons
6. **Meeting Topic** - Used for user segmentation and content analysis
7. **Feature Name** - Referenced in usage distribution and adoption analysis
8. **Support Category** - Used in support volume analysis and user segmentation
9. **Support Sub Category** - Used for detailed support analysis and resource allocation
10. **Resolution Status** - Referenced in support efficiency and service quality metrics
11. **Priority Level** - Used in support prioritization and resource management
12. **User Name** - Referenced across reports for user identification and analysis

### **Calculated Metrics Across Reports**
1. **Total Meeting Minutes** - Aggregated duration across all meetings
2. **Average Meeting Duration** - Mean duration calculated across different dimensions
3. **User Count by Dimension** - Count of unique users segmented by various attributes
4. **Feature Usage Percentage** - Adoption rate of features relative to total usage
5. **Support Resolution Metrics** - Time-based calculations for support efficiency
6. **Meeting Frequency per User** - Average number of meetings hosted by individual users
7. **Support Ticket Distribution** - Percentage breakdown of tickets by category and priority
