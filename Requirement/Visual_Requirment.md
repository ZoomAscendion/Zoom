Zoom Platform Analytics System - Reports & Requirements

Zoom, as a video communications company, deals with vast amounts of data related to user activity, meetings, and platform performance. This data is critical for making business decisions, from improving service reliability to identifying popular features.

This document outlines the official reporting requirements for the Zoom Platform Analytics System based on the current database structure. These requirements will guide the development of analytical dashboards to support daily decision-making processes.

1. PLATFORM USAGE & ADOPTION REPORT

Business Purpose
This report provides a simple overview of Zoom platform usage using meeting activity data.
It answers three core questions:
How many total users participated in meetings?
How many meetings were held per user?
What is the average meeting duration?
This keeps the report lightweight and simple.

2.Data Model ( Ensure that we use the fact table "Fact Meeting Acitivty" and 
dimension tables "Meetings" , "Users" and "Dates" )

3.KPIS needed are:

Total Number of users
Average meeting duration
Number of meetings created per user
Feature Usage Distribution
