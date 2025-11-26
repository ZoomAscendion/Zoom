_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Tableau Dashboard Visuals Recommender for Platform Usage & Adoption Report
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender - Platform Usage & Adoption Report

## Overview

This document provides comprehensive recommendations for designing and implementing a Tableau dashboard for the **Platform Usage & Adoption Report**. The dashboard will monitor user engagement and platform adoption rates to identify growth trends and areas for improvement.

## Data Model & Relationships

### Primary Data Sources
- **FACT_MEETING_ACTIVITY** (Primary Fact Table)
- **FACT_FEATURE_USAGE** (Secondary Fact Table)
- **DIM_USER** (User Dimension)
- **DIM_MEETING** (Meeting Dimension)
- **DIM_FEATURE** (Feature Dimension)
- **DIM_DATE** (Date Dimension)

### Key Relationships
- FACT_MEETING_ACTIVITY → DIM_USER (USER_KEY)
- FACT_MEETING_ACTIVITY → DIM_MEETING (MEETING_KEY)
- FACT_MEETING_ACTIVITY → DIM_DATE (DATE_KEY)
- FACT_FEATURE_USAGE → DIM_FEATURE (FEATURE_KEY)
- FACT_FEATURE_USAGE → DIM_USER (USER_KEY)
- FACT_FEATURE_USAGE → DIM_DATE (DATE_KEY)

## 1. Visual Recommendations

### Visual 1: Total Number of Users KPI Card

- **Data Element:** Total Number of Users
- **Recommended Visual:** KPI Card/Big Number
- **Data Fields:** 
  - DIM_USER.USER_KEY (Count Distinct)
- **Calculations:** 
  ```
  Total Users: COUNTD([User Key])
  ```
- **Interactivity:** 
  - Filter by Date Range
  - Filter by Plan Type
  - Filter by Geographic Region
- **Justification:** KPI cards provide immediate visibility of key metrics and are perfect for executive dashboards
- **Optimization Tips:** Use extract with incremental refresh, add context filter for date range

### Visual 2: Average Meeting Duration by Type and Category

- **Data Element:** Average Meeting Duration by Meeting Type and Category
- **Recommended Visual:** Horizontal Bar Chart
- **Data Fields:** 
  - DIM_MEETING.MEETING_TYPE (Rows)
  - DIM_MEETING.MEETING_CATEGORY (Color)
  - FACT_MEETING_ACTIVITY.DURATION_MINUTES (Columns - Average)
- **Calculations:** 
  ```
  Avg Duration (Minutes): AVG([Duration Minutes])
  Avg Duration (Hours): AVG([Duration Minutes])/60
  ```
- **Interactivity:** 
  - Drill-down from Meeting Type to Meeting Category
  - Filter by Date Range
  - Tooltip showing participant count
- **Justification:** Horizontal bars are ideal for comparing categories with text labels, easy to read meeting types
- **Optimization Tips:** Use LOD calculation if needed: {FIXED [Meeting Type], [Meeting Category] : AVG([Duration Minutes])}

### Visual 3: Number of Users by Meeting Topics

- **Data Element:** User Distribution by Meeting Topics
- **Recommended Visual:** Tree Map
- **Data Fields:** 
  - FACT_MEETING_ACTIVITY.MEETING_TOPIC (Detail)
  - DIM_USER.USER_KEY (Size - Count Distinct)
- **Calculations:** 
  ```
  Users per Topic: COUNTD([User Key])
  Topic Popularity Rank: RANK(COUNTD([User Key]), 'desc')
  ```
- **Interactivity:** 
  - Click to filter other visuals
  - Tooltip showing meeting count
  - Parameter for Top N topics
- **Justification:** Tree maps effectively show proportional relationships and help identify dominant meeting topics
- **Optimization Tips:** Limit to top 20-30 topics using Top N filter to avoid overcrowding

### Visual 4: Number of Meetings per User

- **Data Element:** Meeting Count Distribution per User
- **Recommended Visual:** Histogram/Bar Chart
- **Data Fields:** 
  - DIM_USER.USER_NAME (Rows)
  - FACT_MEETING_ACTIVITY.MEETING_ACTIVITY_ID (Columns - Count)
- **Calculations:** 
  ```
  Meetings per User: COUNTD([Meeting Activity Id])
  User Engagement Level: 
  IF [Meetings per User] >= 20 THEN "High"
  ELSEIF [Meetings per User] >= 10 THEN "Medium"
  ELSE "Low" END
  ```
- **Interactivity:** 
  - Sort by meeting count (ascending/descending)
  - Filter by engagement level
  - Drill-through to user detail page
- **Justification:** Bar chart clearly shows user engagement levels and identifies power users vs. occasional users
- **Optimization Tips:** Use Top N filter (Top 50 users) and context filter for performance

### Visual 5: Feature Usage Distribution

- **Data Element:** Feature Usage Distribution
- **Recommended Visual:** Pie Chart with Detail Table
- **Data Fields:** 
  - DIM_FEATURE.FEATURE_NAME (Angle/Rows)
  - FACT_FEATURE_USAGE.USAGE_COUNT (Size/Values - Sum)
- **Calculations:** 
  ```
  Total Feature Usage: SUM([Usage Count])
  Usage Percentage: SUM([Usage Count]) / TOTAL(SUM([Usage Count]))
  Feature Adoption Rate: COUNTD([User Key]) / TOTAL(COUNTD([User Key]))
  ```
- **Interactivity:** 
  - Click on pie slice to filter other charts
  - Toggle between usage count and adoption rate
  - Filter by feature category
- **Justification:** Pie chart effectively shows proportional usage, complemented by table for precise values
- **Optimization Tips:** Limit to top 10 features, use "Others" category for remaining features

### Visual 6: Meeting Trends Over Time

- **Data Element:** Meeting Activity Trends
- **Recommended Visual:** Dual-Axis Line Chart
- **Data Fields:** 
  - DIM_DATE.DATE_VALUE (Columns)
  - FACT_MEETING_ACTIVITY.MEETING_ACTIVITY_ID (Rows - Count) - Left Axis
  - FACT_MEETING_ACTIVITY.DURATION_MINUTES (Rows - Average) - Right Axis
- **Calculations:** 
  ```
  Daily Meeting Count: COUNTD([Meeting Activity Id])
  Daily Avg Duration: AVG([Duration Minutes])
  7-Day Moving Average: WINDOW_AVG(AVG([Duration Minutes]), -6, 0)
  ```
- **Interactivity:** 
  - Date range filter
  - Granularity parameter (Daily/Weekly/Monthly)
  - Highlight weekends vs. weekdays
- **Justification:** Dual-axis shows both volume and quality metrics, trends are easily identifiable
- **Optimization Tips:** Use continuous date axis, synchronize dual axes, add reference lines for targets

### Visual 7: User Engagement Heatmap

- **Data Element:** User Activity by Day of Week and Hour
- **Recommended Visual:** Highlight Table (Square marks)
- **Data Fields:** 
  - DIM_DATE.DAY_NAME (Rows)
  - HOUR([Start Time]) (Columns)
  - FACT_MEETING_ACTIVITY.MEETING_ACTIVITY_ID (Color - Count)
- **Calculations:** 
  ```
  Hour of Day: DATEPART('hour', [Start Time])
  Meeting Intensity: COUNT([Meeting Activity Id])
  Peak Usage Indicator: 
  IF [Meeting Intensity] >= PERCENTILE([Meeting Intensity], 0.8) THEN "Peak" 
  ELSE "Normal" END
  ```
- **Interactivity:** 
  - Hover for exact counts
  - Filter by date range
  - Click to drill into specific time periods
- **Justification:** Heatmap reveals usage patterns and helps identify peak usage times for capacity planning
- **Optimization Tips:** Use square marks for better visual impact, apply appropriate color scheme (sequential)

## 2. Overall Dashboard Design

### Layout Suggestions
- **Top Row:** KPI cards (Total Users, Total Meetings, Avg Duration, Feature Adoption Rate)
- **Second Row:** Meeting trends line chart (full width)
- **Third Row:** Split between Average Duration by Type/Category (left) and Feature Usage pie chart (right)
- **Fourth Row:** User engagement heatmap (left) and Top users bar chart (right)
- **Bottom Row:** Meeting topics tree map (full width)

### Performance Optimization
- **Extract Strategy:** 
  - Use Tableau extracts with incremental refresh based on LOAD_DATE
  - Schedule refresh during off-peak hours (2-4 AM)
  - Implement data source filters to limit historical data (e.g., last 2 years)
- **Filter Optimization:**
  - Use context filters for date ranges and major categorical filters
  - Implement cascading filters (Region → Company → User)
  - Add "All" option to key filters
- **Calculation Optimization:**
  - Use LOD calculations sparingly, prefer table calculations when possible
  - Pre-aggregate data in database where feasible
  - Use FIXED LODs for user-level metrics

### Color Scheme
- **Primary Colors:** Zoom blue (#2D8CFF) for main metrics
- **Secondary Colors:** Complementary blues and grays (#4A90E2, #7B68EE, #B0C4DE)
- **Accent Colors:** Orange (#FF6B35) for highlights and alerts
- **Status Colors:** Green (#28A745) for positive trends, Red (#DC3545) for issues

### Typography
- **Headers:** Tableau Book Bold, 14-16pt
- **Body Text:** Tableau Book Regular, 10-12pt
- **KPI Numbers:** Tableau Book Bold, 18-24pt
- **Axis Labels:** Tableau Book Regular, 9-10pt

### Interactive Elements

| Element Type | Purpose | Implementation | Target Visuals |
|--------------|---------|----------------|----------------|
| Date Range Filter | Time-based analysis | Relative date filter with presets | All visuals |
| Plan Type Filter | Segment analysis | Multi-select dropdown | User-related visuals |
| Geographic Region Filter | Regional analysis | Hierarchical filter | All visuals |
| Top N Parameter | Limit displayed items | Integer parameter (5-50) | Rankings and lists |
| Granularity Parameter | Time analysis detail | String parameter (Day/Week/Month) | Trend charts |
| Meeting Type Filter | Category analysis | Multi-select with "All" | Meeting-related visuals |
| User Engagement Level | User segmentation | Calculated field filter | User analysis visuals |
| Feature Category Filter | Feature analysis | Single-select dropdown | Feature usage visuals |

### Dashboard Actions

| Action Type | Source | Target | Purpose |
|-------------|--------|--------|----------|
| Filter Action | Meeting Topics Tree Map | All other visuals | Focus on specific topics |
| Highlight Action | User bar chart | Meeting trends | Show individual user patterns |
| URL Action | User names | User detail dashboard | Drill-through to user details |
| Filter Action | Feature pie chart | Meeting activity visuals | Show meetings using specific features |
| Go to Sheet | KPI cards | Detailed analysis sheets | Navigate to detailed views |

### Potential Pitfalls & Mitigation

1. **High Cardinality Issues:**
   - **Problem:** Too many meeting topics or users
   - **Solution:** Implement Top N filters and "Others" grouping

2. **Performance Issues:**
   - **Problem:** Large dataset causing slow load times
   - **Solution:** Use extracts, context filters, and data source filters

3. **Date Handling:**
   - **Problem:** Timezone inconsistencies
   - **Solution:** Standardize to UTC in data preparation, add timezone parameter

4. **Null Values:**
   - **Problem:** Missing meeting topics or user information
   - **Solution:** Create "Unknown" categories and handle nulls in calculations

5. **Dual Axis Confusion:**
   - **Problem:** Users misinterpreting dual-axis charts
   - **Solution:** Clear labeling, synchronized axes where appropriate, tooltips explaining metrics

### Success Metrics
- Dashboard load time < 10 seconds
- User adoption rate > 80% within 30 days
- Reduction in ad-hoc data requests by 50%
- Monthly active dashboard users > 100

### Maintenance Recommendations
- Weekly review of dashboard performance metrics
- Monthly user feedback sessions
- Quarterly review of KPIs and metrics relevance
- Semi-annual dashboard design refresh based on user needs