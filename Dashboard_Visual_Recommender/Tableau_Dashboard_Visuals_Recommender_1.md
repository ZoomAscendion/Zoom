_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Platform Usage & Adoption Dashboard Visual Recommendations
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender - Platform Usage & Adoption Report

## Business Objective
Monitor user engagement and platform adoption rates to identify growth trends and areas for improvement.

## Data Model Overview
**Primary Fact Tables:**
- FACT_MEETING_ACTIVITY

**Primary Dimension Tables:**
- DIM_USER
- DIM_MEETING
- DIM_DATE

**Key Relationships:**
- FACT_MEETING_ACTIVITY → DIM_USER (USER_KEY)
- FACT_MEETING_ACTIVITY → DIM_MEETING (MEETING_KEY)
- FACT_MEETING_ACTIVITY → DIM_DATE (DATE_KEY)

## 1. Visual Recommendations

### KPI 1: Total Meeting Minutes and Active Users

- **Data Element:** Total Meeting Minutes and Active Users
- **Recommended Visual:** KPI Cards with Dual Axis Line Chart
- **Data Fields:** 
  - SUM([DURATION_MINUTES]) from FACT_MEETING_ACTIVITY
  - COUNTD([USER_KEY]) from FACT_MEETING_ACTIVITY
  - [DATE_VALUE] from DIM_DATE
- **Calculations:** 
  - Total Meeting Minutes: `SUM([DURATION_MINUTES])`
  - Active Users: `COUNTD([USER_KEY])`
  - Monthly Trend: `DATETRUNC('month', [MEETING_DATE])`
- **Interactivity:** 
  - Date Range Filter (Month/Quarter/Year)
  - User Plan Type Filter
  - Geographic Region Filter
- **Justification:** KPI cards provide immediate visibility to key metrics, while line chart shows trends over time
- **Optimization Tips:** Use extract with monthly aggregation, apply context filters on date ranges

### KPI 2: Average Meeting Duration by Type and Category

- **Data Element:** Average Meeting Duration by Meeting Type and Category
- **Recommended Visual:** Horizontal Bar Chart with Color Encoding
- **Data Fields:**
  - [MEETING_TYPE] from DIM_MEETING
  - [MEETING_CATEGORY] from DIM_MEETING
  - AVG([DURATION_MINUTES]) from FACT_MEETING_ACTIVITY
- **Calculations:**
  - Average Duration: `AVG([DURATION_MINUTES])`
  - Duration Category: `IF AVG([DURATION_MINUTES]) < 30 THEN "Short" ELSEIF AVG([DURATION_MINUTES]) < 60 THEN "Medium" ELSE "Long" END`
- **Interactivity:**
  - Meeting Type Filter
  - Date Range Parameter
  - Drill-down from Type to Category
- **Justification:** Horizontal bars allow easy comparison across categories, color encoding adds visual distinction
- **Optimization Tips:** Pre-aggregate data at meeting type level, use indexed fields for filtering

### KPI 3: Number of Users by Meeting Topics

- **Data Element:** User Distribution by Meeting Topics
- **Recommended Visual:** Highlight Table (Heatmap Style)
- **Data Fields:**
  - [MEETING_TOPIC] from FACT_MEETING_ACTIVITY
  - COUNTD([USER_KEY]) from FACT_MEETING_ACTIVITY
  - [COMPANY] from DIM_USER
- **Calculations:**
  - User Count: `COUNTD([USER_KEY])`
  - Topic Popularity Rank: `RANK(COUNTD([USER_KEY]), 'desc')`
- **Interactivity:**
  - Meeting Topic Search Filter
  - Company Filter
  - Top N Parameter (Top 10, 20, 50 topics)
- **Justification:** Highlight table with square marks provides heatmap visualization showing topic popularity patterns
- **Optimization Tips:** Limit to top topics using Top N filter, create topic hierarchy for drill-down

### KPI 4: Number of Meetings per User

- **Data Element:** Meeting Frequency Distribution per User
- **Recommended Visual:** Histogram with Reference Lines
- **Data Fields:**
  - COUNT([MEETING_ACTIVITY_ID]) from FACT_MEETING_ACTIVITY per [USER_KEY]
  - [USER_ROLE] from DIM_USER
  - [PLAN_TYPE] from DIM_USER
- **Calculations:**
  - Meetings per User: `{FIXED [USER_KEY]: COUNT([MEETING_ACTIVITY_ID])}`
  - Average Meetings: `AVG({FIXED [USER_KEY]: COUNT([MEETING_ACTIVITY_ID])})`
  - User Engagement Level: `IF [Meetings per User] > [Average Meetings] THEN "High" ELSE "Low" END`
- **Interactivity:**
  - Plan Type Filter
  - User Role Filter
  - Date Range Filter
  - Bin Size Parameter for histogram
- **Justification:** Histogram shows distribution pattern, reference lines highlight benchmarks
- **Optimization Tips:** Use LOD calculations efficiently, consider user sampling for large datasets

## 2. Overall Dashboard Design

### Layout Suggestions
- **Top Row:** KPI Cards showing Total Meeting Minutes, Active Users, Average Duration
- **Second Row:** Average Meeting Duration by Type/Category (Left), User Distribution Heatmap (Right)
- **Bottom Row:** Meetings per User Histogram with filters panel on the right
- **Navigation:** Tab structure for different time periods (Daily, Weekly, Monthly views)

### Performance Optimization
- **Extract Strategy:** Daily refresh with incremental updates
- **Indexing:** Create indexes on DATE_KEY, USER_KEY, MEETING_KEY
- **Aggregation:** Pre-calculate monthly/weekly aggregations
- **Context Filters:** Apply date range as context filter
- **Data Source Filters:** Filter out test users and invalid meetings

### Color Scheme
- **Primary Colors:** Blue (#1f77b4) for meeting metrics, Green (#2ca02c) for user metrics
- **Secondary Colors:** Orange (#ff7f0e) for alerts/thresholds, Gray (#7f7f7f) for neutral data
- **Accessibility:** Ensure color-blind friendly palette with sufficient contrast

### Typography
- **Headers:** Tableau Book Bold, 14pt
- **KPI Values:** Tableau Book Bold, 18pt
- **Labels:** Tableau Book Regular, 10pt
- **Tooltips:** Tableau Book Regular, 9pt

### Interactive Elements

| Element Type | Name | Purpose | Scope |
|--------------|------|---------|-------|
| Filter | Date Range | Time period selection | Dashboard |
| Filter | Plan Type | User segment analysis | Dashboard |
| Filter | Geographic Region | Regional analysis | Dashboard |
| Parameter | Top N Topics | Limit topic display | Meeting Topics Sheet |
| Parameter | Bin Size | Histogram granularity | Meetings per User Sheet |
| Action | Drill-down | Type to Category navigation | Duration Chart |
| Action | Highlight | Cross-sheet highlighting | All sheets |
| Action | Filter | Click to filter other views | All sheets |

### Performance Considerations
- Limit concurrent users during peak hours
- Monitor extract refresh times
- Use incremental refresh for large fact tables
- Implement row-level security if needed
- Consider data sampling for exploratory analysis
