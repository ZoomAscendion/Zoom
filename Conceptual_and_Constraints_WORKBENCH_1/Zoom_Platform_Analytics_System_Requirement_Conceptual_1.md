_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System operates within the video communications domain, focusing on user engagement, meeting activities, platform performance, and customer support interactions. The system captures and analyzes data related to user behavior, meeting usage patterns, feature adoption, and service reliability to support business decision-making processes.

## 2. List of Entity Names with Descriptions

1. **User**: Represents individuals who use the Zoom platform for video communications
2. **Meeting**: Represents video conference sessions conducted on the Zoom platform
3. **Meeting Activity**: Represents the interaction and participation data between users and meetings
4. **Feature Usage**: Represents the utilization of various Zoom platform features by users
5. **Support Activity**: Represents customer support interactions and ticket management
6. **Dim Feature**: Dimension table containing feature definitions and classifications
7. **Dim Date**: Dimension table containing date hierarchies for temporal analysis
8. **Dim Support Category**: Dimension table containing support categorization and classification

## 3. List of Attributes for Each Entity

### User
1. **User Name**: The name of the platform user
2. **Meeting Types**: Types of meetings the user participates in
3. **Meeting Topics**: Subject areas or topics of meetings the user is involved with

### Meeting
1. **Duration Minutes**: The length of the meeting in minutes
2. **Start Time**: The timestamp when the meeting begins
3. **End Time**: The timestamp when the meeting ends

### Meeting Activity
1. **Total Meeting Minutes**: Cumulative meeting time for analysis
2. **Active Users**: Count of users actively participating in meetings

### Feature Usage
1. **Feature Usage Count**: Number of times a feature has been utilized
2. **Feature Usage Distribution**: Statistical distribution of feature adoption

### Support Activity
1. **Category**: Primary classification of the support request
2. **Sub Category**: Secondary classification providing more specific categorization
3. **Resolution Status**: Current state of the support ticket resolution process
4. **Priority Level**: Urgency level assigned to the support request
5. **Open Date**: Date when the support ticket was created

### Dim Feature
1. **Feature Name**: Name of the platform feature

### Dim Date
1. **Date Attributes**: Various date dimensions for temporal analysis

### Dim Support Category
1. **Support Category Classifications**: Hierarchical categorization of support types

## 4. KPI List

1. **Total Number of Users**: Count of all users on the platform
2. **Average Meeting Duration**: Mean duration of meetings across the platform
3. **Number of Meetings Created per User**: Meeting creation rate per individual user
4. **Feature Usage Distribution**: Statistical breakdown of feature adoption rates
5. **Average Meeting Duration by Type and Category**: Mean meeting length segmented by meeting classifications
6. **Number of Users by Meeting Topics**: User count organized by meeting subject areas
7. **Number of Meeting per User**: Meeting participation frequency per user
8. **Number of Users by Support Category and Sub Category**: User count organized by support request types
9. **Number of Support Activities by Resolution Status**: Support ticket count by current resolution state
10. **Number of Support Activities by Priority**: Support ticket count organized by urgency level

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meeting Activity | User Reference | User | Many-to-One |
| Meeting Activity | Meeting Reference | Meeting | Many-to-One |
| Feature Usage | Feature Reference | Dim Feature | Many-to-One |
| Feature Usage | Date Reference | Dim Date | Many-to-One |
| Support Activity | Date Reference | Dim Date | Many-to-One |
| Support Activity | Support Category Reference | Dim Support Category | Many-to-One |
| Support Activity | User Reference | Dim User | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User Information**: Referenced across Platform Usage & Adoption Report and Service Reliability & Support Report
2. **Date/Time Elements**: Used in both reports for temporal analysis and filtering
3. **Meeting Data**: Central to Platform Usage & Adoption Report for usage analytics
4. **Feature Usage Metrics**: Key component for platform adoption analysis
5. **Support Categories**: Essential for service reliability and support quality analysis
6. **Resolution Status**: Critical for support performance measurement
7. **Duration Metrics**: Used for meeting analysis and performance measurement
8. **Count Metrics**: Applied across both reports for quantitative analysis