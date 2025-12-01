**Zoom Platform Analytics System - Reports & Requirements**

Zoom, as a video communications company, deals with vast amounts of data
related to user activity, meetings, and platform performance. This data
is critical for making business decisions, from improving service
reliability to identifying popular features.

This document outlines the official reporting requirements for the Zoom
Platform Analytics System based on the current database structure. These
requirements will guide the development of analytical dashboards to
support daily decision-making processes.

**1. PLATFORM USAGE & ADOPTION REPORT**

**Business Objective**

Monitor user engagement and platform adoption rates to identify growth
trends and areas for improvement.

**Uses of the Report**

-   Track key usage metrics like total meeting minutes and active users.
-   Average Meeting Duration by Type,Category
-   Number of Users by Meeting Topics
-   Number of Meeting per User

**Data Relationships Used**

-   Meeting Activity \--\>Users
-   Meeting Activity \--\>Meeting
-   Meeting Activity \--\>Users
-   Feature Usage \--\>Dim Feature
-   Feature Usage \--\>Dim Date

**Data Attributes in the Report**

-   User information (Number of users, meeting types, meeting topics, user names )
-   Meeting information (Meeting_ID, Duration_Minutes, Start_Time)
-   Feature Usage Distribution (Feature_Name, Feature usage Count)
-   Calculated metrics (Total Number of users, Average Meeting duration)

**KPIs and Metrics in the Report**

-   Total Number of users
-   Average meeting duration
-   Number of meetings created per user
-   Feature Usage Distribution

**Data Constraints**

-   Duration in Minutes must be a non-negative integer.

-   Start Time and End Time must be valid timestamps.

-   A Meeting IF in Attendees or Features Usage must exist in the
    Meetings table.

-   Dimension should have  one/many to many relationships wiht fact tables.

**Visualizations**

-   Bar chart showing Number of Meeting per User 
-   Bar chart showcasing Number of Meeting per User
-   Bar chart showcasing Average Duration meetings by type , category
-   Pie chart showing feature usage distribution.

**2. SERVICE RELIABILITY & SUPPORT REPORT**

**Business Objective**

Analyze platform stability and customer support interactions to improve
service quality and reduce ticket volume.

**Uses of the Report**


- Number of users by Support Category, Sub category
- Number of Support Activities by Resolution Status
- Number of Support Activities by Priority

**Data Relationships Used**

-   Fact Support Activity  \--\> Dim Date
-   Fact Support Activity  \--\> Dim Support Category
-   Fact Support Activity  \--\> Dim User

**Data Attributes in the Report**

-   User information (User_ID, Category, Sub Category, Resolution Status, Priority Level)

**KPIs and Metrics in the Report**
- Number of Users
- Number of Tickets
  
**Data Constraints**

-   Type and Resolution_Status must be from a predefined list of values.

-   User ID must exist in the Users table.

-   Open_Date must be a valid date.

**Visualizations**

-   Bar chart showing Number of users by Support Category, Sub category
-   Bar chart showing  Number of Support Activities by Rsolution Status
-   Bar chart showing Number of Support Activities by Rsolution Status
