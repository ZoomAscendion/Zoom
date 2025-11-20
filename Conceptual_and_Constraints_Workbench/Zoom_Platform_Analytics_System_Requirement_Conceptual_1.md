_____________________________________________
## *Author*: AAVA
## *Created on*: 20-11-2025
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 20-11-2025
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers the video communications business domain, focusing on user engagement, meeting activities, platform performance, and customer support interactions. The system supports analytical dashboards for daily decision-making processes related to platform usage adoption and service reliability.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform for video communications
2. **Meeting**: Contains information about video meetings conducted on the platform
3. **Meeting Activity**: Tracks user participation and engagement in meetings
4. **Feature Usage**: Records usage patterns of various platform features by users
5. **Dim Feature**: Dimension table containing feature definitions and metadata
6. **Dim Date**: Dimension table for time-based analysis and reporting
7. **Fact Support Activity**: Contains customer support interactions and ticket information
8. **Dim Support Category**: Dimension table for categorizing support requests
9. **Dim User**: Dimension table containing user profile and demographic information

## 3. List of Attributes for Each Entity

### Users
1. **User Names**: Names of platform users
2. **Number of Users**: Count of users in various contexts
3. **Meeting Topics**: Topics associated with user meetings
4. **Meeting Types**: Types of meetings users participate in

### Meeting
1. **Duration Minutes**: Length of meetings in minutes
2. **Start Time**: When the meeting began
3. **End Time**: When the meeting concluded

### Meeting Activity
1. **Total Meeting Minutes**: Aggregate meeting duration metrics
2. **Active Users**: Users currently engaged in meeting activities
3. **Average Meeting Duration**: Calculated average duration by type and category
4. **Number of Meetings per User**: Count of meetings created by individual users

### Feature Usage
1. **Feature Usage Count**: Number of times features are utilized
2. **Feature Usage Distribution**: Pattern of feature adoption across users

### Dim Feature
1. **Feature Name**: Names of platform features available to users

### Fact Support Activity
1. **Category**: Primary classification of support requests
2. **Sub Category**: Secondary classification for detailed categorization
3. **Resolution Status**: Current state of support ticket resolution
4. **Priority Level**: Importance level assigned to support requests
5. **Open Date**: Date when support ticket was created

### Dim Support Category
1. **Support Category**: Categories for organizing support activities
2. **Sub Category**: Detailed subcategories within main support categories

### Dim User
1. **User Information**: Comprehensive user profile data for analysis

## 4. KPI List

1. **Total Number of Users**: Overall count of platform users for adoption tracking
2. **Average Meeting Duration**: Mean duration of meetings for engagement analysis
3. **Number of Meetings Created per User**: Individual user activity measurement
4. **Feature Usage Distribution**: Pattern analysis of feature adoption across the platform
5. **Number of Users by Support Category**: Support request volume by category
6. **Number of Support Activities by Resolution Status**: Support efficiency tracking
7. **Number of Support Activities by Priority**: Priority-based support workload analysis

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meeting Activity | User Reference | Users | Many-to-One |
| Meeting Activity | Meeting Reference | Meeting | Many-to-One |
| Feature Usage | Feature Reference | Dim Feature | Many-to-One |
| Feature Usage | Date Reference | Dim Date | Many-to-One |
| Fact Support Activity | Date Reference | Dim Date | Many-to-One |
| Fact Support Activity | Support Category Reference | Dim Support Category | Many-to-One |
| Fact Support Activity | User Reference | Dim User | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User Information**: Referenced across both Platform Usage & Adoption Report and Service Reliability & Support Report
2. **Date Dimensions**: Used for time-based analysis in both reporting areas
3. **Meeting Duration Metrics**: Central to platform usage analysis
4. **User Count Metrics**: Common measurement across multiple report sections
5. **Category Classifications**: Used for both feature usage and support categorization
6. **Resolution and Status Tracking**: Applied to both meeting outcomes and support activities
