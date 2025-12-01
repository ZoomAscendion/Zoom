**Platform Analytics System - Reports & Requirements**

As a video communications company, deals with vast amounts of data
related to user activity, meetings, and platform performance. This data
is critical for making business decisions, from improving service
reliability to identifying popular features.

This document outlines the official reporting requirements for the
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

**Facts, Dimensions and Data Relationships Used**

-   Fact Meeting Activity \--\>Dim Users
-   Fact Meeting Activity \--\>Dim Meeting
-   Fact Meeting Activity \--\>Dim Users
-   Fact Feature Usage \--\>Dim Feature
-   Fact Feature Usage \--\>Dim Date


**2. SERVICE RELIABILITY & SUPPORT REPORT**

**Business Objective**
Analyze platform stability and customer support interactions to improve
service quality and reduce ticket volume.

**Uses of the Report**
- Number of users by Support Category, Sub category
- Number of Support Activities by Resolution Status
- Number of Support Activities by Priority

**Facts, Dimensions and Data Relationships Used**
-   Fact Support Activity  \--\> Dim Date
-   Fact Support Activity  \--\> Dim Support Category
-   Fact Support Activity  \--\> Dim User
