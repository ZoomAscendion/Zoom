_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Platform Usage & Adoption Report - Tableau Dashboard Visual Recommendations
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender - Platform Usage & Adoption Report

## Report Overview

**Business Objective:** Monitor user engagement and platform adoption rates to identify growth trends and areas for improvement.

**Key Metrics:**
- Track key usage metrics like total meeting minutes and active users
- Average Meeting Duration by Type, Category
- Number of Users by Meeting Topics
- Number of Meeting per User

**Data Sources:**
- FACT_MEETING_ACTIVITY
- FACT_FEATURE_USAGE
- DIM_USER
- DIM_MEETING
- DIM_FEATURE
- DIM_DATE

## 1. Visual Recommendations

### Visual 1: Total Meeting Minutes Trend
- **Data Element:** Total Meeting Minutes Over Time
- **Recommended Visual:** Line Chart
- **Data Fields:** 
  - DATE_KEY (from DIM_DATE)
  - DURATION_MINUTES (from FACT_MEETING_ACTIVITY)
- **Query/Tableau Calculation:** 
  ```
  SUM([DURATION_MINUTES])
  ```
- **Interactivity:** 
  - Date range filter (Year, Quarter, Month)
  - Drill-down from Year → Quarter → Month → Day
- **Justification:** Line charts effectively show trends over time and allow users to identify patterns in meeting usage
- **Optimization Tips:** 
  - Use extract with incremental refresh
  - Add context filter for date range
  - Consider data source filter for recent 2 years

### Visual 2: Active Users Count
- **Data Element:** Number of Active Users Over Time
- **Recommended Visual:** Dual Axis Line Chart
- **Data Fields:**
  - DATE_KEY (from DIM_DATE)
  - USER_KEY (from FACT_MEETING_ACTIVITY)
  - USER_KEY (from FACT_FEATURE_USAGE)
- **Query/Tableau Calculation:**
  ```
  COUNTD([USER_KEY]) // Meeting Active Users
  COUNTD([USER_KEY]) // Feature Active Users
  ```
- **Interactivity:**
  - Date range filter
  - Toggle between daily/weekly/monthly aggregation using parameter
- **Justification:** Dual axis allows comparison of users active in meetings vs features, synchronized axes show relative scale
- **Optimization Tips:**
  - Use LOD calculation: {FIXED [DATE_KEY] : COUNTD([USER_KEY])}
  - Synchronize dual axes
  - Use extract for better performance

### Visual 3: Average Meeting Duration by Type and Category
- **Data Element:** Meeting Duration Analysis
- **Recommended Visual:** Horizontal Bar Chart
- **Data Fields:**
  - MEETING_TYPE (from DIM_MEETING)
  - MEETING_CATEGORY (from DIM_MEETING)
  - DURATION_MINUTES (from FACT_MEETING_ACTIVITY)
- **Query/Tableau Calculation:**
  ```
  AVG([DURATION_MINUTES])
  ```
- **Interactivity:**
  - Filter by Meeting Type
  - Drill-down from Type to Category
  - Tooltip showing count of meetings
- **Justification:** Horizontal bars work well for categorical data comparison and accommodate longer category names
- **Optimization Tips:**
  - Sort bars by average duration descending
  - Use color encoding for meeting categories
  - Add reference line for overall average


### Visual 4: Meetings per User Distribution
- **Data Element:** User Engagement Distribution
- **Recommended Visual:** Histogram
- **Data Fields:**
  - USER_KEY (from FACT_MEETING_ACTIVITY)
  - MEETING_ACTIVITY_ID (from FACT_MEETING_ACTIVITY)
- **Query/Tableau Calculation:**
  ```
  {FIXED [USER_KEY] : COUNTD([MEETING_ACTIVITY_ID])}
  ```
- **Interactivity:**
  - Bin size parameter
  - Date range filter
  - Drill-through to user details
- **Justification:** Histogram shows distribution pattern and helps identify user engagement segments
- **Optimization Tips:**
  - Use LOD calculation for user-level aggregation
  - Create bins with appropriate size (1, 2-5, 6-10, 11-20, 21+)
  - Add statistical reference lines (median, quartiles)

### Visual 5: Feature Usage Adoption Score
- **Data Element:** Feature Adoption Analysis
- **Recommended Visual:** Bullet Graph
- **Data Fields:**
  - FEATURE_NAME (from DIM_FEATURE)
  - FEATURE_ADOPTION_SCORE (from FACT_FEATURE_USAGE)
  - IS_PREMIUM_FEATURE (from DIM_FEATURE)
- **Query/Tableau Calculation:**
  ```
  AVG([FEATURE_ADOPTION_SCORE])
  Target: Parameter [Adoption_Target] (default 7)
  ```
- **Interactivity:**
  - Target parameter for adoption threshold
  - Filter by Premium vs Standard features
  - Sort by adoption score
- **Justification:** Bullet graphs show performance against targets and are space-efficient for multiple metrics
- **Optimization Tips:**
  - Use parameters for target values
  - Color code by premium/standard features
  - Sort by performance gap

## 2. Overall Dashboard Design

### Layout Suggestions
- **Top Row:** KPI cards showing total meetings, active users, average duration
- **Second Row:** Time trend charts (Total Meeting Minutes, Active Users)
- **Third Row:** Category analysis (Meeting Duration by Type, Feature Adoption)
- **Bottom Row:** Distribution analysis (Meeting Topics Tree Map, User Engagement Histogram)
- **Right Panel:** Filters and parameters

### Performance Optimization
- **Extract Strategy:** 
  - Daily incremental refresh for fact tables
  - Weekly full refresh for dimension tables
  - Partition extracts by date for large datasets
- **Filter Optimization:**
  - Use context filters for date ranges
  - Implement data source filters for historical data limits
  - Use relevant values only for categorical filters
- **Calculation Optimization:**
  - Use LOD calculations instead of table calculations where possible
  - Minimize use of COUNTD on high-cardinality fields
  - Pre-aggregate data at source when possible

### Color Scheme
- **Primary Colors:** Blue gradient (#1f77b4 to #aec7e8) for main metrics
- **Secondary Colors:** Orange (#ff7f0e) for comparisons and highlights
- **Status Colors:** Green (#2ca02c) for positive trends, Red (#d62728) for alerts
- **Neutral Colors:** Gray (#7f7f7f) for reference lines and secondary information

### Typography
- **Headers:** Tableau Book Bold, 14-16pt
- **Labels:** Tableau Book Regular, 10-12pt
- **Tooltips:** Tableau Book Regular, 9-10pt
- **Ensure high contrast for accessibility**

### Interactive Elements

| Element Type | Name | Purpose | Scope |
|--------------|------|---------|-------|
| Filter | Date Range | Control time period | All sheets |
| Filter | Meeting Type | Filter by meeting type | Meeting-related sheets |
| Filter | User Status | Filter active/inactive users | User-related sheets |
| Parameter | Top N Topics | Control number of topics shown | Topic analysis |
| Parameter | Adoption Target | Set target for feature adoption | Feature analysis |
| Parameter | Time Granularity | Switch between daily/weekly/monthly | Trend charts |
| Action | Highlight | Cross-highlight related data | All sheets |
| Action | Filter | Click to filter other views | Category charts |
| Action | URL | Drill to detailed user reports | User metrics |
| Hierarchy | Date Hierarchy | Year → Quarter → Month → Day | Time-based analysis |
| Hierarchy | Meeting Hierarchy | Type → Category → Topic | Meeting analysis |

### Potential Pitfalls
- **High Cardinality:** MEETING_TOPIC field may have too many unique values - use Top N filtering
- **Performance:** COUNTD operations on USER_KEY across large datasets - consider pre-aggregation
- **Data Freshness:** Ensure real-time requirements are met with appropriate refresh schedules
- **Filter Interaction:** Too many filters can overwhelm users - group related filters
- **Mobile Responsiveness:** Ensure dashboard works on tablets and mobile devices
- **Data Quality:** Handle null values in MEETING_TOPIC and duration fields appropriately
