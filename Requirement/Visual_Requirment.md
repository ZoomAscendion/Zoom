Zoom Platform Analytics System - Reports & Requirements

Zoom, as a video communications company, deals with vast amounts of data related to user activity, meetings, and platform performance. This data is critical for making business decisions, from improving service reliability to identifying popular features.

This document outlines the official reporting requirements for the Zoom Platform Analytics System based on the current database structure. These requirements will guide the development of analytical dashboards to support daily decision-making processes.

1. PLATFORM USAGE & ADOPTION REPORT

Business Objective

Monitor user engagement and platform adoption rates to identify growth trends and areas for improvement.

Uses of the Report

Track key usage metrics like total meeting minutes and active users.
Average Meeting Duration by Type,Category
Number of Users by Meeting Topics
Number of Meeting per User
Data Relationships Used

Meeting Activity -->Users (via Date Key)
Meeting Activity -->Meeting (via Meeting ID)
Meeting Activity -->Users (via User Key)
Feature Usage -->Dim Feature (via Feature Key)
Feature Usage -->Dim Date (via Date Key)
Data Attributes in the Report

User information (Number of users, meeting types, meeting topics, user names )
Meeting information (Meeting_ID, Duration_Minutes, Start_Time)
Feature Usage Distribution (Feature_Name, Feature usage Count)
Calculated metrics (Total Number of users, Average Meeting duration)
KPIs and Metrics in the Report

Total Number of users
Average meeting duration
Number of meetings created per user
Feature Usage Distribution
Data Constraints

Duration_Minutes must be a non-negative integer.

Start_Time and End_Time must be valid timestamps.

A Meeting_ID in Attendees or Features_Usage must exist in the Meetings table.

Dimension should have one/many to many relationships wiht fact tables.
