_____________________________________________
## *Author*: AAVA
## *Created on*: 20-11-2025
## *Description*: Conceptual data model for Zoom Platform Analytics System
## *Version*: 2
## *Updated on*: 20-11-2025
## *Changes*: Enhanced entity relationships and added missing attributes from requirements analysis
## *Reason*: Update requested to improve data model completeness and accuracy
_____________________________________________

# Conceptual Data Model - Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System covers the video communications business domain, focusing on user engagement, meeting activities, platform performance, and customer support interactions. The system supports analytical dashboards for daily decision-making processes related to platform usage adoption and service reliability. This enhanced model provides comprehensive coverage of all reporting requirements including platform usage analytics and service reliability metrics.

## 2. List of Entity Names with Descriptions

1. **Users**: Represents individuals who use the Zoom platform for video communications and meeting participation
2. **Meeting**: Contains comprehensive information about video meetings conducted on the platform including duration and timing
3. **Meeting Activity**: Tracks detailed user participation and engagement patterns in meetings across different types and categories
4. **Feature Usage**: Records comprehensive usage patterns of various platform features by users with usage counts and distribution metrics
5. **Dim Feature**: Dimension table containing complete feature definitions, metadata, and feature categorization
6. **Dim Date**: Dimension table for comprehensive time-based analysis and reporting across all business processes
7. **Fact Support Activity**: Contains detailed customer support interactions, ticket information, and resolution tracking
8. **Dim Support Category**: Dimension table for comprehensive categorization of support requests including categories and subcategories
9. **Dim User**: Dimension table containing comprehensive user profile, demographic information, and user classification data
10. **Attendees**: Entity tracking meeting attendance and participant information for detailed meeting analytics

## 3. List of Attributes for Each Entity

### Users
1. **User Names**: Complete names of platform users for identification and reporting
2. **Number of Users**: Aggregate count of users in various analytical contexts and groupings
3. **Meeting Topics**: Comprehensive topics and subjects associated with user meetings
4. **Meeting Types**: Complete classification of meeting types users participate in
5. **User Categories**: Classification of users based on usage patterns and engagement levels

### Meeting
1. **Duration Minutes**: Precise length of meetings in minutes for usage analytics
2. **Start Time**: Exact timestamp when the meeting began for scheduling analysis
3. **End Time**: Precise timestamp when the meeting concluded for duration calculations
4. **Meeting Type**: Classification of meeting by type for categorical analysis
5. **Meeting Category**: Secondary classification for detailed meeting analytics

### Meeting Activity
1. **Total Meeting Minutes**: Aggregate meeting duration metrics across users and time periods
2. **Active Users**: Count of users currently engaged in meeting activities
3. **Average Meeting Duration**: Calculated average duration by type and category for performance analysis
4. **Number of Meetings per User**: Detailed count of meetings created by individual users
5. **Meeting Participation Rate**: Engagement metrics for user activity analysis

### Feature Usage
1. **Feature Usage Count**: Precise number of times features are utilized by users
2. **Feature Usage Distribution**: Comprehensive pattern of feature adoption across user base
3. **Usage Frequency**: Detailed frequency metrics for feature utilization analysis
4. **Feature Adoption Rate**: Metrics tracking feature adoption across user segments

### Dim Feature
1. **Feature Name**: Complete names of platform features available to users
2. **Feature Category**: Classification of features by functional category
3. **Feature Description**: Detailed description of feature functionality and purpose

### Fact Support Activity
1. **Category**: Primary classification of support requests for organizational analysis
2. **Sub Category**: Secondary classification for detailed categorization and routing
3. **Resolution Status**: Current state of support ticket resolution for tracking efficiency
4. **Priority Level**: Importance level assigned to support requests for resource allocation
5. **Open Date**: Date when support ticket was created for timeline analysis
6. **Ticket Count**: Number of support tickets for volume analysis
7. **Resolution Time**: Time taken to resolve support requests for efficiency metrics

### Dim Support Category
1. **Support Category**: Primary categories for organizing support activities and routing
2. **Sub Category**: Detailed subcategories within main support categories for precise classification
3. **Category Description**: Comprehensive description of support category scope and purpose

### Dim User
1. **User Information**: Comprehensive user profile data for detailed analytical segmentation
2. **User Demographics**: Demographic information for user behavior analysis
3. **Account Type**: Classification of user account types for segmented reporting

### Attendees
1. **Attendance Status**: Status of user attendance in meetings for participation tracking
2. **Join Time**: Time when user joined the meeting for engagement analysis
3. **Leave Time**: Time when user left the meeting for participation duration calculation

## 4. KPI List

1. **Total Number of Users**: Overall count of platform users for comprehensive adoption tracking
2. **Average Meeting Duration**: Mean duration of meetings for detailed engagement analysis
3. **Number of Meetings Created per User**: Individual user activity measurement for productivity analysis
4. **Feature Usage Distribution**: Comprehensive pattern analysis of feature adoption across the platform
5. **Number of Users by Support Category**: Support request volume analysis by category and subcategory
6. **Number of Support Activities by Resolution Status**: Support efficiency tracking and performance measurement
7. **Number of Support Activities by Priority**: Priority-based support workload analysis for resource planning
8. **Number of Tickets**: Total support ticket volume for workload management
9. **Average Meeting Duration by Type and Category**: Detailed meeting performance analysis
10. **Number of Users by Meeting Topics**: Topic-based user engagement analysis

## 5. Conceptual Data Model Diagram

| Source Entity | Relationship Key Field | Target Entity | Relationship Type |
|---------------|------------------------|---------------|-------------------|
| Meeting Activity | User Reference | Users | Many-to-One |
| Meeting Activity | Meeting Reference | Meeting | Many-to-One |
| Feature Usage | Feature Reference | Dim Feature | Many-to-One |
| Feature Usage | Date Reference | Dim Date | Many-to-One |
| Feature Usage | User Reference | Users | Many-to-One |
| Fact Support Activity | Date Reference | Dim Date | Many-to-One |
| Fact Support Activity | Support Category Reference | Dim Support Category | Many-to-One |
| Fact Support Activity | User Reference | Dim User | Many-to-One |
| Attendees | Meeting Reference | Meeting | Many-to-One |
| Attendees | User Reference | Users | Many-to-One |
| Meeting | User Reference | Users | Many-to-One |

## 6. Common Data Elements in Report Requirements

1. **User Information**: Referenced across both Platform Usage & Adoption Report and Service Reliability & Support Report for comprehensive user analysis
2. **Date Dimensions**: Used for time-based analysis in both reporting areas for trend identification and temporal analytics
3. **Meeting Duration Metrics**: Central to platform usage analysis and user engagement measurement
4. **User Count Metrics**: Common measurement across multiple report sections for adoption and engagement tracking
5. **Category Classifications**: Used for both feature usage categorization and support request classification
6. **Resolution and Status Tracking**: Applied to both meeting outcomes and support activities for performance monitoring
7. **Meeting Type and Category**: Common classification elements used across multiple analytical contexts
8. **Priority and Status Indicators**: Shared across different business processes for operational efficiency tracking
