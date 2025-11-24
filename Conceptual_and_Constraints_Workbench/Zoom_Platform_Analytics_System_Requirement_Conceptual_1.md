_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers the video communications business domain, focusing on user engagement, platform adoption, meeting activities, feature usage, and customer support interactions. The system supports analytical dashboards for daily decision-making processes related to service reliability, user behavior analysis, and platform performance optimization.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individual users of the Zoom platform who participate in meetings and utilize various features
2. **Meeting**: Contains information about scheduled and conducted meetings on the platform
3. **Meeting Activity**: Records user participation and activities within meetings
4. **Feature Usage**: Tracks utilization of various platform features by users
5. **Dim Feature**: Dimension table containing feature definitions and metadata
6. **Dim Date**: Date dimension table for time-based analysis
7. **Fact Support Activity**: Fact table recording customer support interactions and ticket activities
8. **Dim Support Category**: Dimension table containing support categories and subcategories
9. **Dim User**: User dimension table for analytical purposes

## 3. List of Attributes for Each Entity

### Users
1. **User Names**: Names of platform users
2. **Meeting Types**: Types of meetings associated with users
3. **Meeting Topics**: Topics or subjects of meetings users participate in

### Meeting
1. **Duration Minutes**: Length of meetings measured in minutes
2. **Start Time**: Timestamp when the meeting begins
3. **End Time**: Timestamp when the meeting ends

### Meeting Activity
1. **User Information**: Details about users participating in meeting activities
2. **Meeting Information**: Associated meeting details for each activity

### Feature Usage
1. **Feature Name**: Name of the platform feature being used
2. **Feature Usage Count**: Number of times a feature has been utilized

### Dim Feature
1. **Feature Name**: Descriptive name of platform features

### Dim Date
1. **Date Information**: Time dimension attributes for temporal analysis

### Fact Support Activity
1. **Category**: Support ticket category classification
2. **Sub Category**: Detailed subcategory of support requests
3. **Resolution Status**: Current status of support ticket resolution
4. **Priority Level**: Priority assigned to support activities
5. **Open Date**: Date when support ticket was created

### Dim Support Category
1. **Category**: Main support category definitions
2. **Sub Category**: Subcategory classifications for support requests

### Dim User
1. **User Information**: User attributes for dimensional analysis

## 4. KPI List

1. **Total Number of Users**: Count of active users on the platform
2. **Average Meeting Duration**: Mean duration of meetings across different types and categories
3. **Number of Meetings Created Per User**: Productivity metric showing meeting creation activity per user
4. **Feature Usage Distribution**: Distribution pattern of feature utilization across the platform
5. **Number of Users by Meeting Topics**: User engagement metrics segmented by meeting topics
6. **Number of Meeting Per User**: Meeting participation frequency per individual user
7. **Average Meeting Duration by Type, Category**: Segmented average duration metrics
8. **Number of Users by Support Category, Sub Category**: Support engagement metrics by category
9. **Number of Support Activities by Resolution Status**: Support ticket resolution tracking
10. **Number of Support Activities by Priority**: Priority-based support activity metrics
11. **Number of Tickets**: Total count of support tickets in the system

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meeting Activity | User Information | Users | Many-to-One |
| Meeting Activity | Meeting Information | Meeting | Many-to-One |
| Feature Usage | Feature Name | Dim Feature | Many-to-One |
| Feature Usage | Date Information | Dim Date | Many-to-One |
| Fact Support Activity | Date Information | Dim Date | Many-to-One |
| Fact Support Activity | Category | Dim Support Category | Many-to-One |
| Fact Support Activity | User Information | Dim User | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User Information**: Referenced across Platform Usage & Adoption Report and Service Reliability & Support Report
2. **Date/Time Elements**: Used in both reports for temporal analysis (Start_Time, Open_Date)
3. **Category Classifications**: Present in both feature categories and support categories
4. **Count Metrics**: Number of users, meetings, and tickets appear across multiple reports
5. **Duration Measurements**: Meeting duration metrics used for performance analysis
6. **Status Indicators**: Resolution status and priority levels for tracking progress
7. **Relationship Keys**: User associations and meeting references span multiple reporting areas