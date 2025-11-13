_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers two primary business domains:

1. **Platform Usage & Adoption Analytics**: Focuses on monitoring user engagement, meeting activities, and feature utilization to identify growth trends and areas for improvement.

2. **Service Reliability & Support Analytics**: Analyzes platform stability and customer support interactions to improve service quality and reduce support ticket volume.

These domains support daily decision-making processes through analytical dashboards that track key performance indicators and business metrics.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform for meetings and other activities
2. **Meetings**: Contains information about scheduled and conducted meetings on the platform
3. **Meeting Activity**: Tracks user participation and engagement in meetings
4. **Feature Usage**: Records utilization of various platform features by users
5. **Features**: Master data containing available platform features and their descriptions
6. **Support Activity**: Captures customer support interactions and ticket information
7. **Support Category**: Classification system for different types of support requests
8. **Date**: Time dimension for temporal analysis and reporting

## 3. List of Attributes for Each Entity

### Users
1. **User Names**: Names of platform users
2. **Meeting Types**: Types of meetings associated with users
3. **Meeting Topics**: Topics or subjects of meetings created by users
4. **Category**: User categorization for support purposes
5. **Sub Category**: Detailed subcategorization of users for support analysis

### Meetings
1. **Duration Minutes**: Length of meetings in minutes
2. **Start Time**: Meeting start timestamp
3. **End Time**: Meeting end timestamp
4. **Meeting Topics**: Subject or topic of the meeting
5. **Meeting Types**: Classification of meeting types
6. **Category**: Meeting categorization

### Meeting Activity
1. **Total Meeting Minutes**: Aggregate meeting duration metrics
2. **Active Users**: Count of users participating in meetings
3. **Meeting Duration**: Individual meeting length measurements

### Feature Usage
1. **Feature Usage Count**: Number of times features are utilized
2. **Feature Usage Distribution**: Statistical distribution of feature utilization

### Features
1. **Feature Name**: Name of the platform feature

### Support Activity
1. **Resolution Status**: Current status of support tickets
2. **Priority Level**: Urgency level assigned to support requests
3. **Open Date**: Date when support ticket was created

### Support Category
1. **Category**: Primary classification of support requests
2. **Sub Category**: Detailed subcategorization of support types

### Date
1. **Date Key**: Reference key for temporal relationships

## 4. KPI List

### Platform Usage & Adoption KPIs
1. **Total Number of Users**: Overall count of platform users
2. **Average Meeting Duration**: Mean duration of meetings across the platform
3. **Number of Meetings Created per User**: Meeting creation rate per individual user
4. **Feature Usage Distribution**: Statistical breakdown of feature utilization patterns

### Service Reliability & Support KPIs
1. **Number of Users**: Count of users requiring support services
2. **Number of Support Activities by Resolution Status**: Distribution of support tickets by their current status
3. **Number of Support Activities by Priority**: Breakdown of support requests by urgency level
4. **Number of Users by Support Category**: User distribution across different support categories

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meeting Activity | Date Key | Date | Many-to-One |
| Meeting Activity | Meeting ID | Meetings | Many-to-One |
| Meeting Activity | User Key | Users | Many-to-One |
| Feature Usage | Feature Key | Features | Many-to-One |
| Feature Usage | Date Key | Date | Many-to-One |
| Support Activity | Date Key | Date | Many-to-One |
| Support Activity | Support Category Key | Support Category | Many-to-One |
| Support Activity | User Key | Users | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User Information**: Referenced across both Platform Usage and Service Reliability reports for user identification and categorization
2. **Date/Time Elements**: Used in both domains for temporal analysis and trend identification
3. **Meeting Data**: Central to Platform Usage reports and indirectly referenced in support activities
4. **Category Classifications**: Applied in both meeting types/topics and support categorization
5. **Count Metrics**: Number of users, meetings, and activities appear as common measurement patterns
6. **Duration Measurements**: Meeting duration and support resolution timeframes
7. **Status Indicators**: Resolution status in support and meeting completion status in usage analytics