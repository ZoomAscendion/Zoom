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

-   Meeting Activity \--\>Users (via Date Key)
-   Meeting Activity \--\>Meeting (via Meeting ID)
-   Meeting Activity \--\>Users (via User Key)
-   Feature Usage \--\>Dim Feature (via Feature Key)'
-   Feature Usage \--\>Dim Date (via Date Key)

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

-   Duration_Minutes must be a non-negative integer.

-   Start_Time and End_Time must be valid timestamps.

-   A Meeting_ID in Attendees or Features_Usage must exist in the
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

-   Identify products or features that generate the most support
    tickets.

-   Track ticket resolution times and patterns.

-   Correlate meeting issues with ticket types.

-   Assess the efficiency of the support team.

**Data Relationships Used**

-   Support_Tickets \--\> Users (via User_ID)

-   Support_Tickets \--\> Meetings (implied link, not direct FK)

**Data Attributes in the Report**

-   User information (User_ID, Company)

-   Calculated metrics (Average_Resolution_Time, Ticket_Volume_by_Type)

**KPIs and Metrics in the Report**

-   Number of tickets opened per day.

-   Average ticket resolution time.

-   First-contact resolution rate.

-   Tickets opened per 1,000 active users.

**Calculations in the Report**

-   The ticket volume by type shows how many tickets were created for
    each type of issue.

-   The average resolution time is calculated by determining the average
    time taken to close a ticket after it was opened.

-   The user-to-ticket ratio compares the total number of tickets raised
    to the number of active users during the same period.

**Data Constraints**

-   Type and Resolution_Status must be from a predefined list of values.

-   User_ID must exist in the Users table.

-   Open_Date must be a valid date.

**Visualizations**

-   Bar chart showing ticket volume by Meeting_Type.

-   Line chart tracking average resolution time over time.

**3. REVENUE AND LICENSE ANALYSIS REPORT**

**Business Objective**

Monitor billing events and license utilization to understand revenue
streams and customer value.

**Uses of the Report**

-   Track revenue trends by License type.

-   Analyze license assignment and expiration.

-   Identify opportunities for upselling or cross-selling to users.

-   Forecast future revenue based on license data.

**Data Relationships Used**

-   Billing_Events \--\> Users (via User_ID)

-   Licenses \--\> Users (via Assigned_To_User_ID)

-   Meetings \--\> Users (via Host_ID)

**Data Attributes in the Report**

-   Billing information (Event_Type, Amount)

-   License information (License_Type, Start_Date, End_Date)

-   User information (User_ID, License_Type, Company)

-   Meeting details (Host_ID, Duration_Minutes)

**KPIs and Metrics in the Report**

-   Monthly Recurring Revenue (MRR).

-   Revenue by License_Type.

-   License utilization rate.

-   License expiration trends.

-   Usage correlation with billing events (e.g., users who upgrade after
    a certain usage threshold).

**Calculations in the Report**

-   Total revenue is calculated by summing up all monetary amounts from
    billing events.

-   The license utilization rate is the proportion of licenses that are
    currently assigned to users, out of the total number of licenses
    available.

-   The churn rate measures the fraction of users who have stopped using
    the platform, compared to the total number of users.

**Data Constraints**

-   Amount must be a positive number.

-   License_Type must be a predefined value.

-   Start_Date must be before End_Date.

**Visualizations**

-   Line chart showing MRR trends over time.

-   Stacked bar chart showing revenue distribution by License_Type.

-   Table showing upcoming license expirations.

-   Heat map showing geographic revenue distribution.

**Security**

-   Anonymize or mask sensitive user data (Email, User_Name) for
    non-authorized users.

**TECHNICAL REQUIREMENTS**

**Data Integration**

-   Ensure all foreign key relationships are correctly implemented for
    accurate joins.

-   Data must be validated against schema constraints (e.g., valid
    dates, non-negative numbers).

**Performance**

-   Optimize queries that aggregate data over large time periods.

-   Create indices on frequently used columns like User_ID, Meeting_ID,
    and date fields.

-   Implement data caching for frequently accessed reports to improve
    dashboard load times.

**Report Delivery**

-   Automate daily and weekly report generation for key stakeholders.

-   Create an alert system to notify sales teams of expiring licenses or
    users nearing a plan\'s usage limits.

-   Ensure all dashboards are mobile-responsive for on-the-go access.
