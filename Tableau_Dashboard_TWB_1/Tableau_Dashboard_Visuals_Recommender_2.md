_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Updated Tableau Dashboard Visuals Recommender for Zoom Platform Analytics System
## *Version*: 2
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender - Updated

## Data Model Overview

This updated recommendation is specifically tailored for the Zoom Platform Analytics System requirements, focusing on two primary reporting areas:

**Dimension Tables:**
- DIM_DATE: Time dimension with fiscal and calendar hierarchies
- DIM_USER: User demographics, plan types, and geographic information
- DIM_FEATURE: Platform features with categories and complexity levels
- DIM_MEETING: Meeting types, categories, and quality metrics
- DIM_SUPPORT_CATEGORY: Support categories with SLA and priority levels

**Fact Tables:**
- FACT_FEATURE_USAGE: Feature adoption and usage metrics
- FACT_MEETING_ACTIVITY: Meeting participation and quality data
- FACT_SUPPORT_ACTIVITY: Support ticket resolution and satisfaction data

## 1. Visual Recommendations

### 1.1 Platform Usage & Adoption Report Dashboard

**Data Element:** Number of Meetings per User
**Recommended Visual:** Horizontal Bar Chart
**Data Fields:** 
- Rows: [USER_NAME] from DIM_USER
- Columns: COUNT([MEETING_ACTIVITY_ID]) from FACT_MEETING_ACTIVITY
- Color: [PLAN_TYPE] from DIM_USER
**Calculations:** 
```
// Meetings per User
COUNT([MEETING_ACTIVITY_ID])

// User Activity Level
IF COUNT([MEETING_ACTIVITY_ID]) > 10 THEN "High Activity"
ELSEIF COUNT([MEETING_ACTIVITY_ID]) > 5 THEN "Medium Activity"
ELSE "Low Activity"
END
```
**Interactivity:** User name filter, plan type filter, date range filter, drill-down to meeting details
**Justification:** Horizontal bar charts are ideal for comparing values across many categories (users) and allow easy identification of top performers
**Optimization Tips:** Use context filter for date range, limit to top 50 users, create extract with user-level aggregation

---

**Data Element:** Average Meeting Duration by Type and Category
**Recommended Visual:** Grouped Bar Chart
**Data Fields:** 
- Rows: [MEETING_TYPE] from DIM_MEETING
- Columns: AVG([DURATION_MINUTES]) from FACT_MEETING_ACTIVITY
- Color: [MEETING_CATEGORY] from DIM_MEETING
**Calculations:** 
```
// Average Duration by Type
{FIXED [MEETING_TYPE] : AVG([DURATION_MINUTES])}

// Duration Category Classification
IF AVG([DURATION_MINUTES]) > 60 THEN "Long (>60 min)"
ELSEIF AVG([DURATION_MINUTES]) > 30 THEN "Medium (30-60 min)"
ELSE "Short (<30 min)"
END

// Duration Efficiency Score
AVG([DURATION_MINUTES]) / AVG([PARTICIPANT_COUNT])
```
**Interactivity:** Meeting type filter, meeting category filter, duration range parameter
**Justification:** Grouped bar charts effectively show comparisons across two categorical dimensions
**Optimization Tips:** Aggregate at meeting type-category level, use quick filters for better performance

---

**Data Element:** Number of Users by Meeting Topics
**Recommended Visual:** Tree Map
**Data Fields:** 
- Size: COUNT(DISTINCT [USER_KEY])
- Color: AVG([DURATION_MINUTES])
- Detail: [MEETING_TOPIC] from FACT_MEETING_ACTIVITY
**Calculations:** 
```
// Users per Topic
COUNT(DISTINCT [USER_KEY])

// Topic Popularity Rank
RANK(COUNT(DISTINCT [USER_KEY]), 'desc')

// Average Engagement per Topic
AVG([AVERAGE_PARTICIPATION_MINUTES]) / AVG([DURATION_MINUTES])
```
**Interactivity:** Topic search filter, user count threshold parameter, drill-through to user details
**Justification:** Tree maps excel at showing proportional relationships and allow quick identification of popular topics
**Optimization Tips:** Limit to top 20 topics, use data source filter for non-null topics

---

**Data Element:** Feature Usage Distribution
**Recommended Visual:** Pie Chart with Donut Style
**Data Fields:** 
- Angle: SUM([USAGE_COUNT]) from FACT_FEATURE_USAGE
- Color: [FEATURE_NAME] from DIM_FEATURE
- Detail: [FEATURE_CATEGORY]
**Calculations:** 
```
// Feature Usage Percentage
SUM([USAGE_COUNT]) / TOTAL(SUM([USAGE_COUNT]))

// Top Features (Others grouped)
IF RANK(SUM([USAGE_COUNT]), 'desc') <= 8 THEN [FEATURE_NAME]
ELSE "Others"
END

// Usage Intensity Score
SUM([USAGE_DURATION_MINUTES]) / SUM([USAGE_COUNT])
```
**Interactivity:** Feature category filter, usage threshold parameter, drill-down to feature details
**Justification:** Pie charts are perfect for showing part-to-whole relationships in feature usage distribution
**Optimization Tips:** Group low-usage features into "Others", use extract with feature-level aggregation

---

**Data Element:** Total Number of Users KPI
**Recommended Visual:** KPI Card with Trend Indicator
**Data Fields:** 
- Value: COUNT(DISTINCT [USER_KEY])
- Comparison: Previous period user count
**Calculations:** 
```
// Total Active Users
COUNT(DISTINCT [USER_KEY])

// User Growth Rate
(COUNT(DISTINCT [USER_KEY]) - 
LOOKUP(COUNT(DISTINCT [USER_KEY]), -1)) / 
LOOKUP(COUNT(DISTINCT [USER_KEY]), -1)

// New vs Returning Users
IF DATEDIFF('day', [REGISTRATION_DATE], [MEETING_DATE]) <= 30 
THEN "New User" ELSE "Returning User" END
```
**Interactivity:** Date range filter, user status filter
**Justification:** KPI cards provide clear, prominent display of key metrics with trend context
**Optimization Tips:** Use parameters for flexible period comparisons, cache user counts

---

### 1.2 Service Reliability & Support Report Dashboard

**Data Element:** Number of Users by Support Category and Subcategory
**Recommended Visual:** Horizontal Stacked Bar Chart
**Data Fields:** 
- Rows: [SUPPORT_CATEGORY] from DIM_SUPPORT_CATEGORY
- Columns: COUNT(DISTINCT [USER_KEY]) from FACT_SUPPORT_ACTIVITY
- Color: [SUPPORT_SUBCATEGORY] from DIM_SUPPORT_CATEGORY
**Calculations:** 
```
// Users per Support Category
COUNT(DISTINCT [USER_KEY])

// Category Distribution Percentage
COUNT(DISTINCT [USER_KEY]) / TOTAL(COUNT(DISTINCT [USER_KEY]))

// Support Load by Category
{FIXED [SUPPORT_CATEGORY] : COUNT([SUPPORT_ACTIVITY_ID])}
```
**Interactivity:** Support category filter, subcategory filter, date range filter
**Justification:** Stacked bar charts effectively show both total volume and composition by subcategory
**Optimization Tips:** Use context filter for date range, aggregate at category-subcategory level

---

**Data Element:** Number of Support Activities by Resolution Status
**Recommended Visual:** Donut Chart with Center KPI
**Data Fields:** 
- Angle: COUNT([SUPPORT_ACTIVITY_ID])
- Color: [RESOLUTION_STATUS] from FACT_SUPPORT_ACTIVITY
- Center KPI: Total ticket count
**Calculations:** 
```
// Resolution Status Distribution
COUNT([SUPPORT_ACTIVITY_ID]) / TOTAL(COUNT([SUPPORT_ACTIVITY_ID]))

// Resolution Rate
SUM(IF [RESOLUTION_STATUS] = "Resolved" THEN 1 ELSE 0 END) / 
COUNT([SUPPORT_ACTIVITY_ID])

// Average Resolution Time by Status
{FIXED [RESOLUTION_STATUS] : AVG([RESOLUTION_TIME_HOURS])}
```
**Interactivity:** Resolution status filter, priority level filter, drill-through to ticket details
**Justification:** Donut charts clearly show status distribution while center space displays total volume
**Optimization Tips:** Use quick filters, pre-calculate resolution metrics

---

**Data Element:** Number of Support Activities by Priority Level
**Recommended Visual:** Vertical Bar Chart with Reference Lines
**Data Fields:** 
- Columns: [PRIORITY_LEVEL] from DIM_SUPPORT_CATEGORY
- Rows: COUNT([SUPPORT_ACTIVITY_ID])
- Color: [SLA_MET] from FACT_SUPPORT_ACTIVITY
**Calculations:** 
```
// Activities by Priority
COUNT([SUPPORT_ACTIVITY_ID])

// SLA Compliance by Priority
SUM(IF [SLA_MET] THEN 1 ELSE 0 END) / COUNT([SUPPORT_ACTIVITY_ID])

// Priority Target Lines
[High Priority Target] = 100 (Parameter)
[Medium Priority Target] = 200 (Parameter)
[Low Priority Target] = 300 (Parameter)
```
**Interactivity:** Priority filter, SLA status filter, target parameters
**Justification:** Bar charts with reference lines clearly show actual vs target performance by priority
**Optimization Tips:** Use parameters for flexible target setting, add reference lines for capacity planning

---

**Data Element:** Support Resolution Time Performance
**Recommended Visual:** Bullet Graph
**Data Fields:** 
- Actual: AVG([RESOLUTION_TIME_HOURS])
- Target: [SLA_TARGET_HOURS] from DIM_SUPPORT_CATEGORY
- Performance Ranges: Good/Satisfactory/Poor zones
**Calculations:** 
```
// Average Resolution Time
AVG([RESOLUTION_TIME_HOURS])

// SLA Performance Ratio
AVG([RESOLUTION_TIME_HOURS]) / AVG([SLA_TARGET_HOURS])

// Performance Zones
// Good: <= SLA Target
// Satisfactory: <= 1.2 * SLA Target  
// Poor: > 1.2 * SLA Target
```
**Interactivity:** Support category filter, priority level filter, date range filter
**Justification:** Bullet graphs excel at showing performance against targets with clear visual zones
**Optimization Tips:** Use parameters for flexible SLA targets, create calculated fields for performance zones

---

**Data Element:** Support Ticket Volume Trend
**Recommended Visual:** Area Chart with Forecast
**Data Fields:** 
- X-axis: [DATE_VALUE] from DIM_DATE (Daily level)
- Y-axis: COUNT([SUPPORT_ACTIVITY_ID])
- Color: [PRIORITY_LEVEL]
**Calculations:** 
```
// Daily Ticket Count
COUNT([SUPPORT_ACTIVITY_ID])

// 7-Day Moving Average
WINDOW_AVG(COUNT([SUPPORT_ACTIVITY_ID]), -6, 0)

// Ticket Volume Trend
(COUNT([SUPPORT_ACTIVITY_ID]) - 
LOOKUP(COUNT([SUPPORT_ACTIVITY_ID]), -7)) / 
LOOKUP(COUNT([SUPPORT_ACTIVITY_ID]), -7)
```
**Interactivity:** Date range filter, priority filter, trend line toggle
**Justification:** Area charts effectively show volume trends over time with priority composition
**Optimization Tips:** Use daily aggregation, implement forecasting for capacity planning

---

## 2. Overall Dashboard Design

### Layout Suggestions

**Platform Usage & Adoption Dashboard:**
- **Top Row:** KPI cards showing Total Users, Average Meeting Duration, Total Meetings
- **Middle Section:** 
  - Left: Number of Meetings per User (bar chart)
  - Right: Feature Usage Distribution (pie chart)
- **Bottom Section:**
  - Left: Average Duration by Meeting Type/Category (grouped bar)
  - Right: Users by Meeting Topics (tree map)

**Service Reliability & Support Dashboard:**
- **Top Row:** KPI cards showing Total Tickets, Resolution Rate, Average Resolution Time
- **Middle Section:**
  - Left: Support Activities by Resolution Status (donut chart)
  - Right: Support Activities by Priority (bar chart with reference lines)
- **Bottom Section:**
  - Left: Users by Support Category/Subcategory (stacked bar)
  - Right: Resolution Time Performance (bullet graph)

### Performance Optimization

**Extract Strategy:**
- **Platform Usage Dashboard:** Daily refresh at 2 AM for previous day's meeting data
- **Support Dashboard:** Real-time connection for operational monitoring
- **Data Aggregation:** Pre-aggregate at user, meeting type, and support category levels

**Query Optimization:**
- Use context filters for date ranges to reduce data scanning
- Implement data source filters for active users and open tickets
- Create indexed calculated fields for frequently used metrics
- Use FIXED LOD calculations sparingly, prefer table calculations when possible

**Visual Performance:**
- Limit bar charts to top 50 items with "Others" grouping
- Use show/hide containers for detailed breakdowns
- Implement progressive disclosure with drill-down actions
- Cache expensive calculations using data prep or custom SQL

### Color Scheme

**Platform Usage Dashboard:**
- **Primary:** Blue palette (#1f77b4, #aec7e8, #c5dbf1) for meeting and user metrics
- **Secondary:** Green palette (#2ca02c, #98df8a) for positive performance indicators
- **Accent:** Orange (#ff7f0e) for feature usage highlights

**Support Dashboard:**
- **Status Colors:** 
  - Green (#2ca02c) for "Resolved" and "Closed"
  - Yellow (#ffbb33) for "In Progress" and "Pending"
  - Red (#d62728) for "Open" and "Escalated"
- **Priority Colors:**
  - Red (#d62728) for "Critical" and "High"
  - Orange (#ff7f0e) for "Medium"
  - Blue (#1f77b4) for "Low"

### Typography
- **Dashboard Titles:** Tableau Book Bold, 16pt
- **Chart Titles:** Tableau Book Bold, 14pt
- **Axis Labels:** Tableau Book Regular, 11pt
- **KPI Values:** Tableau Book Bold, 18pt
- **Legends:** Tableau Book Regular, 10pt

### Interactive Elements

| Element Type | Dashboard | Implementation | Purpose | Performance Impact |
|--------------|-----------|----------------|---------|--------------------|
| Date Range Filter | Both | Relative date with custom ranges | Time-based analysis | Medium - use context filter |
| User Plan Filter | Platform Usage | Multi-select dropdown | Plan-based segmentation | Low - dimension filter |
| Meeting Type Filter | Platform Usage | Quick filter with "All" | Meeting analysis | Low - dimension filter |
| Priority Level Filter | Support | Radio button selection | Priority focus | Low - dimension filter |
| Support Category Filter | Support | Hierarchical filter | Category drill-down | Medium - affects mark count |
| Resolution Status Filter | Support | Multi-select with colors | Status analysis | Low - dimension filter |
| Drill-through Actions | Both | Dashboard navigation | Detailed analysis | High - loads new views |
| Highlight Actions | Both | Cross-chart highlighting | Visual correlation | Low - client-side only |
| Parameter Controls | Both | Slider/dropdown controls | Dynamic thresholds | Low - calculation only |

### Dashboard Navigation Structure
```
Zoom Analytics Overview
├── Platform Usage & Adoption
│   ├── User Activity Analysis
│   ├── Meeting Performance
│   └── Feature Adoption
└── Service Reliability & Support
    ├── Ticket Management
    ├── Resolution Performance
    └── Customer Satisfaction
```

### Key Performance Indicators (KPIs)

**Platform Usage & Adoption KPIs:**
- Total Active Users
- Average Meeting Duration
- Meetings per User
- Feature Adoption Rate
- User Engagement Score

**Service Reliability & Support KPIs:**
- Total Support Tickets
- Resolution Rate (%)
- Average Resolution Time
- SLA Compliance Rate
- Customer Satisfaction Score
- First Contact Resolution Rate

### Data Refresh Strategy
- **Platform Usage Dashboard:** Daily refresh at 2 AM (previous day data)
- **Support Dashboard:** Hourly refresh during business hours (8 AM - 6 PM)
- **KPI Extracts:** 15-minute refresh for real-time monitoring
- **Historical Analysis:** Weekly full refresh on Sundays

### Specific Tableau Calculations for Requirements

**Platform Usage Calculations:**
```sql
// Total Number of Users
COUNT(DISTINCT [USER_KEY])

// Average Meeting Duration
AVG([DURATION_MINUTES])

// Meetings per User
COUNT([MEETING_ACTIVITY_ID]) / COUNT(DISTINCT [USER_KEY])

// Feature Usage Distribution
SUM([USAGE_COUNT]) / TOTAL(SUM([USAGE_COUNT]))
```

**Support Analytics Calculations:**
```sql
// Number of Users by Support Category
COUNT(DISTINCT [USER_KEY])

// Number of Tickets
COUNT([SUPPORT_ACTIVITY_ID])

// Resolution Status Distribution
COUNT([SUPPORT_ACTIVITY_ID]) / TOTAL(COUNT([SUPPORT_ACTIVITY_ID]))

// Priority Level Analysis
{FIXED [PRIORITY_LEVEL] : COUNT([SUPPORT_ACTIVITY_ID])}
```

### Data Validation and Constraints
- **Duration Validation:** Ensure DURATION_MINUTES >= 0
- **Timestamp Validation:** START_TIME < END_TIME for all meetings
- **Referential Integrity:** All MEETING_ID in facts exist in DIM_MEETING
- **User Validation:** All USER_KEY references exist in DIM_USER
- **Support Category Validation:** All categories exist in DIM_SUPPORT_CATEGORY

### Potential Performance Pitfalls and Solutions

**Common Issues:**
- High cardinality in USER_NAME and MEETING_TOPIC fields
- Complex LOD calculations across large fact tables
- Multiple filters causing Cartesian products
- Real-time connections to large datasets

**Solutions:**
- Implement user grouping for high-cardinality dimensions
- Use table calculations instead of LOD when possible
- Apply context filters strategically
- Use extracts with appropriate aggregation levels
- Implement incremental refresh for large fact tables

### Security and Access Control
- **Row-Level Security:** Filter data by user's organization/department
- **Dashboard Permissions:** Role-based access (Admin, Manager, Analyst)
- **Data Source Security:** Separate connections for sensitive support data
- **Export Controls:** Limit data export capabilities by user role