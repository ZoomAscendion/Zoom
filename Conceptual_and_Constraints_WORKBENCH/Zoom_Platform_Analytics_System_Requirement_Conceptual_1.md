_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System operates within the video communications domain, focusing on user engagement analytics, meeting performance tracking, feature utilization monitoring, and customer support analysis. The system supports business decision-making through comprehensive reporting on platform usage patterns, service reliability metrics, and support interaction analytics.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform for video communications and meetings
2. **Meeting**: Contains information about video meetings conducted on the Zoom platform
3. **Meeting Activity**: Tracks user participation and engagement within meetings
4. **Feature Usage**: Records utilization of various Zoom platform features by users
5. **Dim Feature**: Dimension table containing feature definitions and classifications
6. **Dim Date**: Dimension table for time-based analysis and reporting
7. **Fact Support Activity**: Contains customer support interactions and ticket information
8. **Dim Support Category**: Dimension table for support ticket categorization
9. **Dim User**: Dimension table containing user profile and demographic information

## 3. List of Attributes for Each Entity

### Users
1. **User Names**: Names of platform users
2. **Number of Users**: Count of active users
3. **Meeting Types**: Types of meetings associated with users
4. **Meeting Topics**: Subject areas or topics of user meetings

### Meeting
1. **Duration Minutes**: Length of meetings in minutes
2. **Start Time**: Meeting commencement timestamp
3. **End Time**: Meeting conclusion timestamp

### Meeting Activity
1. **User Participation**: User engagement within meetings
2. **Meeting Engagement Metrics**: Measures of user activity during meetings

### Feature Usage
1. **Feature Name**: Name of the Zoom platform feature
2. **Feature Usage Count**: Number of times a feature has been utilized
3. **Feature Usage Distribution**: Breakdown of feature utilization patterns

### Dim Feature
1. **Feature Name**: Standardized feature names
2. **Feature Classification**: Categorization of platform features

### Dim Date
1. **Date Attributes**: Time dimensions for temporal analysis
2. **Time Periods**: Various time granularities for reporting

### Fact Support Activity
1. **Category**: Primary classification of support requests
2. **Sub Category**: Secondary classification of support requests
3. **Resolution Status**: Current status of support ticket resolution
4. **Priority Level**: Urgency level assigned to support activities
5. **Open Date**: Date when support ticket was created

### Dim Support Category
1. **Category**: Support ticket primary categories
2. **Sub Category**: Support ticket secondary categories

### Dim User
1. **User Profile Information**: Demographic and profile data for users
2. **User Classification**: User type and segmentation data

## 4. KPI List

1. **Total Number of Users**: Complete count of platform users
2. **Average Meeting Duration**: Mean length of meetings across the platform
3. **Number of Meetings Created per User**: Meeting creation rate by individual users
4. **Feature Usage Distribution**: Breakdown of feature utilization across the platform
5. **Average Meeting Duration by Type and Category**: Mean meeting length segmented by meeting classifications
6. **Number of Users by Meeting Topics**: User count organized by meeting subject areas
7. **Number of Meeting per User**: Meeting participation rate for individual users
8. **Number of Users by Support Category and Sub Category**: User count organized by support request types
9. **Number of Support Activities by Resolution Status**: Support ticket count by resolution state
10. **Number of Support Activities by Priority**: Support ticket count by urgency level

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meeting Activity | User Reference | Users | Many-to-One |
| Meeting Activity | Meeting Reference | Meeting | Many-to-One |
| Feature Usage | Feature Reference | Dim Feature | Many-to-One |
| Feature Usage | Date Reference | Dim Date | Many-to-One |
| Fact Support Activity | Date Reference | Dim Date | Many-to-One |
| Fact Support Activity | Category Reference | Dim Support Category | Many-to-One |
| Fact Support Activity | User Reference | Dim User | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User Information**: Referenced across both Platform Usage & Adoption Report and Service Reliability & Support Report
2. **Date/Time Attributes**: Used for temporal analysis in both reporting domains
3. **Meeting Duration**: Core metric for platform usage analysis
4. **User Count Metrics**: Fundamental measurement across multiple report categories
5. **Category Classifications**: Used for both feature usage and support ticket categorization
6. **Resolution Status**: Applied to both meeting outcomes and support ticket tracking
7. **Priority Levels**: Used for both feature importance and support ticket urgency