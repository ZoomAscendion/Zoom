_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Conceptual data model for Platform Analytics System Reports
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Conceptual Data Model - Platform Analytics System

## 1. Domain Overview

The Platform Analytics System serves a video communications company that manages vast amounts of data related to user activity, meetings, and platform performance. The system supports analytical dashboards for daily decision-making processes, focusing on platform usage adoption and service reliability support reporting.

## 2. List of Entity Names with Descriptions

1. **Meeting Activity**: Records of meeting sessions and related activities on the platform
2. **Users**: Information about platform users and their profiles
3. **Meeting**: Details about individual meetings including type, category, and topics
4. **Feature Usage**: Records of feature utilization across the platform
5. **Support Activity**: Customer support interactions and ticket information
6. **Date**: Time dimension for temporal analysis
7. **Feature**: Available platform features and their specifications
8. **Support Category**: Classification system for support requests

## 3. List of Attributes for Each Entity

### Meeting Activity
1. **Total Meeting Minutes**: Duration of meeting sessions
2. **Meeting Duration**: Length of individual meetings
3. **Meeting Type**: Classification of meeting format
4. **Meeting Category**: Grouping of meetings by business purpose

### Users
1. **User Name**: Identifier for platform users
2. **Active Status**: Current engagement level of users
3. **User Engagement Level**: Measure of user participation

### Meeting
1. **Meeting Topics**: Subject matter discussed in meetings
2. **Meeting Type**: Format classification of meetings
3. **Meeting Category**: Business purpose grouping
4. **Average Duration**: Typical length by type and category

### Feature Usage
1. **Usage Frequency**: How often features are utilized
2. **Feature Adoption Rate**: Percentage of users adopting features

### Support Activity
1. **Support Category**: Primary classification of support requests
2. **Sub Category**: Detailed classification within main categories
3. **Resolution Status**: Current state of support tickets
4. **Priority Level**: Urgency classification of support requests

### Date
1. **Date Value**: Temporal reference for analysis
2. **Time Period**: Grouping for trend analysis

### Feature
1. **Feature Name**: Identifier for platform capabilities
2. **Feature Type**: Classification of feature functionality

### Support Category
1. **Category Name**: Primary support classification
2. **Sub Category Name**: Detailed support classification

## 4. KPI List

1. **Total Meeting Minutes**: Aggregate duration of all meetings for usage tracking
2. **Active Users Count**: Number of engaged users for adoption measurement
3. **Average Meeting Duration by Type and Category**: Performance metric for meeting efficiency
4. **Number of Users by Meeting Topics**: Engagement distribution across topics
5. **Number of Meetings per User**: Individual user engagement level
6. **Number of Users by Support Category and Sub Category**: Support demand distribution
7. **Number of Support Activities by Resolution Status**: Support team performance
8. **Number of Support Activities by Priority**: Urgency distribution for resource allocation

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-----------------|
| Meeting Activity | User Reference | Users | Many-to-One |
| Meeting Activity | Meeting Reference | Meeting | Many-to-One |
| Feature Usage | Feature Reference | Feature | Many-to-One |
| Feature Usage | Date Reference | Date | Many-to-One |
| Support Activity | Date Reference | Date | Many-to-One |
| Support Activity | Support Category Reference | Support Category | Many-to-One |
| Support Activity | User Reference | Users | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User Information**: Referenced across both Platform Usage & Adoption Report and Service Reliability & Support Report
2. **Date/Time Dimensions**: Used for temporal analysis in both reporting areas
3. **Activity Metrics**: Meeting activities and support activities both track user interactions
4. **Classification Systems**: Meeting categories/types and support categories for grouping and analysis
5. **Performance Indicators**: Duration metrics for meetings and resolution metrics for support
6. **User Engagement Measures**: Active users in platform usage and users requiring support