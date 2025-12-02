_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Platform Usage & Adoption Dashboard - Minimal KPI Visual Recommendations
## *Version*: 3
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender - Platform Usage & Adoption Report (Minimal KPIs)

## Business Objective
Monitor user engagement and platform adoption rates to identify growth trends and areas for improvement.

## Data Model Overview
**Primary Fact Tables:**
- FACT_MEETING_ACTIVITY
- FACT_FEATURE_USAGE

**Primary Dimension Tables:**
- DIM_USER
- DIM_MEETING
- DIM_FEATURE
- DIM_DATE

**Key Relationships:**
- FACT_MEETING_ACTIVITY → DIM_USER (USER_KEY)
- FACT_MEETING_ACTIVITY → DIM_MEETING (MEETING_KEY)
- FACT_MEETING_ACTIVITY → DIM_DATE (DATE_KEY)
- FACT_FEATURE_USAGE → DIM_FEATURE (FEATURE_KEY)
- FACT_FEATURE_USAGE → DIM_DATE (DATE_KEY)

## 1. Visual Recommendations (Minimal KPIs)

### KPI 1: Total Meeting Minutes and Active Users

- **Data Element:** Key usage metrics - Total Meeting Minutes and Active Users
- **Recommended Visual:** KPI Cards with Trend Sparklines
- **Data Fields:** 
  - SUM([DURATION_MINUTES]) from FACT_MEETING_ACTIVITY
  - COUNTD([USER_KEY]) from FACT_MEETING_ACTIVITY
  - [DATE_VALUE] from DIM_DATE
- **Calculations:** 
  - Total Meeting Minutes: `SUM([DURATION_MINUTES])`
  - Active Users: `COUNTD([USER_KEY])`
  - Monthly Growth: `(SUM([DURATION_MINUTES]) - LOOKUP(SUM([DURATION_MINUTES]), -1)) / LOOKUP(SUM([DURATION_MINUTES]), -1)`
- **Interactivity:** 
  - Date Range Filter (Month/Quarter/Year)
  - Plan Type Quick Filter
- **Justification:** KPI cards provide immediate visibility to key metrics with sparklines showing trends
- **Optimization Tips:** Use extract with monthly aggregation, apply context filters on date ranges

### KPI 2: Average Meeting Duration by Type and Category

- **Data Element:** Average Meeting Duration segmented by Meeting Type and Category
- **Recommended Visual:** Horizontal Bar Chart with Color Encoding
- **Data Fields:**
  - [MEETING_TYPE] from DIM_MEETING
  - [MEETING_CATEGORY] from DIM_MEETING
  - AVG([DURATION_MINUTES]) from FACT_MEETING_ACTIVITY
- **Calculations:**
  - Average Duration: `AVG([DURATION_MINUTES])`
  - Duration Benchmark: `AVG({FIXED : AVG([DURATION_MINUTES])})`
- **Interactivity:**
  - Meeting Type Filter
  - Drill-down from Type to Category
- **Justification:** Horizontal bars enable easy comparison across categories with clear visual hierarchy
- **Optimization Tips:** Pre-aggregate data at meeting type level, use indexed fields for filtering

### KPI 3: Number of Users by Meeting Topics

- **Data Element:** User Distribution across Meeting Topics
- **Recommended Visual:** Highlight Table (Heatmap Style)
- **Data Fields:**
  - [MEETING_TOPIC] from FACT_MEETING_ACTIVITY
  - COUNTD([USER_KEY]) from FACT_MEETING_ACTIVITY
- **Calculations:**
  - User Count: `COUNTD([USER_KEY])`
  - Topic Popularity Rank: `RANK(COUNTD([USER_KEY]), 'desc')`
- **Interactivity:**
  - Top N Parameter (Top 10, 20 topics)
  - Meeting Topic Search Filter
- **Justification:** Highlight table with square marks provides clear heatmap visualization for topic popularity
- **Optimization Tips:** Limit to top topics using Top N filter, create topic hierarchy for performance

### KPI 4: Number of Meetings per User

- **Data Element:** Meeting Frequency Distribution per User
- **Recommended Visual:** Histogram with Reference Line
- **Data Fields:**
  - COUNT([MEETING_ACTIVITY_ID]) from FACT_MEETING_ACTIVITY per [USER_KEY]
  - [USER_ROLE] from DIM_USER
- **Calculations:**
  - Meetings per User: `{FIXED [USER_KEY]: COUNT([MEETING_ACTIVITY_ID])}`
  - Average Meetings: `AVG({FIXED [USER_KEY]: COUNT([MEETING_ACTIVITY_ID])})`
- **Interactivity:**
  - User Role Filter
  - Bin Size Parameter for histogram
- **Justification:** Histogram shows distribution pattern with reference line highlighting average benchmark
- **Optimization Tips:** Use LOD calculations efficiently, consider user sampling for large datasets

## 2. Overall Dashboard Design

### Layout Suggestions
- **Top Row:** KPI Cards - Total Meeting Minutes (Left), Active Users (Right)
- **Middle Row:** Average Meeting Duration by Type/Category (Full Width)
- **Bottom Left:** User Distribution by Meeting Topics (Heatmap)
- **Bottom Right:** Meetings per User Distribution (Histogram)
- **Filter Panel:** Right sidebar with key filters

### Performance Optimization
- **Extract Strategy:** Daily refresh with incremental updates
- **Indexing:** Create indexes on DATE_KEY, USER_KEY, MEETING_KEY
- **Context Filters:** Apply date range as context filter
- **Data Source Filters:** Filter out test users and invalid meetings

### Color Scheme
- **Primary Colors:** Blue (#1f77b4) for meeting metrics, Green (#2ca02c) for user metrics
- **Accent Colors:** Orange (#ff7f0e) for highlights, Gray (#7f7f7f) for neutral data
- **Accessibility:** Color-blind friendly palette with sufficient contrast

### Typography
- **KPI Headers:** Tableau Book Bold, 14pt
- **KPI Values:** Tableau Book Bold, 18pt
- **Chart Labels:** Tableau Book Regular, 10pt
- **Tooltips:** Tableau Book Regular, 9pt

### Interactive Elements

| Element Type | Name | Purpose | Scope |
|--------------|------|---------|-------|
| Filter | Date Range | Time period selection | Dashboard |
| Filter | Plan Type | User segment analysis | Dashboard |
| Parameter | Top N Topics | Limit topic display | Meeting Topics Sheet |
| Parameter | Bin Size | Histogram granularity | Meetings per User Sheet |
| Action | Drill-down | Type to Category navigation | Duration Chart |
| Action | Highlight | Cross-sheet highlighting | All sheets |

### Dashboard Alignment & Layout
- **Grid System:** Use 12-column grid for consistent alignment
- **Spacing:** Maintain 8px padding between elements
- **Sizing:** KPI cards - 300px width, Charts - responsive to container
- **Responsive Design:** Ensure proper scaling across different screen sizes
- **Visual Hierarchy:** Largest elements for KPIs, medium for primary charts, smaller for supporting visuals