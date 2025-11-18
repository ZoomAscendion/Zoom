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

Data Model (Star Schema)
Fact Table:
FACT_TABLE
COLUMN 1
COLUMN 2
COLUMN 3
Dimension Tables:
COLUMN 1
COLUMN 2
COLUMN 3

Data Attributes in the Report

User information (Number of users, meeting types, meeting topics, user names )
Meeting information (Meeting_ID, Duration_Minutes, Start_Time)


KPIs and Metrics in the Report

Average meeting duration
Count of meetings

