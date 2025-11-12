_____________________________________________
## *Author*: AAVA
## *Created on*: December 19, 2024
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: December 19, 2024
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers two primary business domains:

1. **Platform Usage & Adoption**: Monitoring user engagement, meeting activities, and feature utilization to identify growth trends and areas for improvement.
2. **Service Reliability & Support**: Analyzing platform stability and customer support interactions to improve service quality and reduce ticket volume.

The system focuses on providing analytical insights for daily decision-making processes related to user activity, meetings, platform performance, and support operations.

## 2. List of Entity Names with Descriptions

1. **User**: Represents individuals who use the Zoom platform for meetings and other activities
2. **Meeting**: Represents video conference sessions conducted on the Zoom platform
3. **Meeting Activity**: Represents the relationship and activities between users and meetings
4. **Feature**: Represents various functionalities and capabilities available on the Zoom platform
5. **Feature Usage**: Represents the utilization of specific features by users during meetings or platform interactions
6. **Support Activity**: Represents customer support interactions and tickets raised by users
7. **Support Category**: Represents classification categories for different types of support requests
8. **Date**: Represents time dimension for analytical reporting and trend analysis

## 3. List of Attributes for Each Entity

### User
1. **User Name**: Name of the user on the platform
2. **Meeting Types**: Types of meetings the user participates in or hosts
3. **Meeting Topics**: Subject areas or themes of meetings associated with the user
4. **Category**: User classification or grouping category
5. **Sub Category**: More specific classification within the main category

### Meeting
1. **Duration Minutes**: Length of the meeting in minutes
2. **Start Time**: Timestamp when the meeting began
3. **End Time**: Timestamp when the meeting ended
4. **Meeting Types**: Classification of the meeting (e.g., scheduled, instant, recurring)
5. **Meeting Topics**: Subject matter or theme of the meeting
6. **Category**: Meeting classification category

### Meeting Activity
1. **Total Meeting Minutes**: Aggregate duration of meeting activities
2. **Number of Meetings**: Count of meetings associated with the activity

### Feature
1. **Feature Name**: Name of the platform feature or functionality

### Feature Usage
1. **Feature Usage Count**: Number of times a feature has been utilized
2. **Feature Usage Distribution**: Pattern or spread of feature utilization across users or time

### Support Activity
1. **Resolution Status**: Current state of the support ticket (e.g., open, closed, pending)
2. **Priority Level**: Importance or urgency level assigned to the support request
3. **Open Date**: Date when the support ticket was created
4. **Type**: Classification type of the support request

### Support Category
1. **Category**: Main classification for support requests
2. **Sub Category**: Detailed classification within the main support category

### Date
1. **Date Key**: Reference key for date-based analysis and reporting

## 4. KPI List

### Platform Usage & Adoption KPIs
1. **Total Number of Users**: Count of active users on the platform
2. **Average Meeting Duration**: Mean duration of meetings across the platform
3. **Number of Meetings Created per User**: Average meeting creation rate per individual user
4. **Feature Usage Distribution**: Spread and frequency of feature utilization across the platform
5. **Average Meeting Duration by Type**: Mean meeting length segmented by meeting classification
6. **Average Meeting Duration by Category**: Mean meeting length segmented by meeting category
7. **Number of Users by Meeting Topics**: User count distribution across different meeting subjects
8. **Number of Meetings per User**: Meeting participation or hosting count per individual user

### Service Reliability & Support KPIs
1. **Number of Users**: Count of users requiring support services
2. **Number of Users by Support Category**: User distribution across different support classification categories
3. **Number of Users by Support Sub Category**: User distribution across detailed support classifications
4. **Number of Support Activities by Resolution Status**: Count of support tickets segmented by their current resolution state
5. **Number of Support Activities by Priority**: Count of support requests segmented by their assigned priority level

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meeting Activity | Date Key | Date | Many-to-One |
| Meeting Activity | Meeting ID | Meeting | Many-to-One |
| Meeting Activity | User Key | User | Many-to-One |
| Feature Usage | Feature Key | Feature | Many-to-One |
| Feature Usage | Date Key | Date | Many-to-One |
| Support Activity | Date Key | Date | Many-to-One |
| Support Activity | Support Category Key | Support Category | Many-to-One |
| Support Activity | User Key | User | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User Information**: Referenced across both Platform Usage & Adoption and Service Reliability & Support reports
2. **Date Key**: Used for time-based analysis in both reporting domains
3. **Meeting Duration**: Common metric for platform usage analysis
4. **User Count**: Fundamental metric appearing in multiple report contexts
5. **Category Classifications**: Used for both meeting categorization and support ticket classification
6. **Resolution Status**: Referenced in support-related reporting and analysis
7. **Feature Usage Metrics**: Common elements for understanding platform utilization patterns