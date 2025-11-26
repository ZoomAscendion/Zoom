_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Tableau Dashboard Visuals Recommender for Platform Usage & Adoption Report - Focused on 4 Key Visuals
## *Version*: 2
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender - Platform Usage & Adoption Report (Focused Version)

## Overview

This document provides focused recommendations for designing and implementing a Tableau dashboard for the **Platform Usage & Adoption Report** with emphasis on four key visuals. The dashboard will monitor user engagement and platform adoption rates to identify growth trends and areas for improvement.

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
  Active Users (Last 30 Days): COUNTD(IF DATEDIFF('day', [Meeting Date], TODAY()) <= 30 THEN [User Key] END)
  User Growth Rate: (COUNTD([User Key]) - LOOKUP(COUNTD([User Key]), -1)) / LOOKUP(COUNTD([User Key]), -1)
  ```
- **Interactivity:** 
  - Filter by Date Range
  - Filter by Plan Type
  - Filter by Geographic Region
  - Parameter to switch between Total Users and Active Users
- **Justification:** KPI cards provide immediate visibility of key metrics and are perfect for executive dashboards. Shows the fundamental health metric of platform adoption.
- **Optimization Tips:** Use extract with incremental refresh, add context filter for date range, pre-calculate user counts in data source if possible

### Visual 2: Average Meeting Duration by Type and Category

- **Data Element:** Average Meeting Duration by Meeting Type and Category
- **Recommended Visual:** Horizontal Bar Chart with Color Encoding
- **Data Fields:** 
  - DIM_MEETING.MEETING_TYPE (Rows)
  - DIM_MEETING.MEETING_CATEGORY (Color)
  - FACT_MEETING_ACTIVITY.DURATION_MINUTES (Columns - Average)
- **Calculations:** 
  ```
  Avg Duration (Minutes): AVG([Duration Minutes])
  Avg Duration (Hours): AVG([Duration Minutes])/60
  Duration Category: 
  IF AVG([Duration Minutes]) >= 60 THEN "Long (60+ min)"
  ELSEIF AVG([Duration Minutes]) >= 30 THEN "Medium (30-60 min)"
  ELSE "Short (<30 min)" END
  Meeting Efficiency Score: AVG([Meeting Satisfaction Score]) * (1 - (AVG([Duration Minutes]) - 30)/120)
  ```
- **Interactivity:** 
  - Drill-down from Meeting Type to Meeting Category
  - Filter by Date Range
  - Tooltip showing participant count and meeting quality score
  - Sort by duration (ascending/descending)
- **Justification:** Horizontal bars are ideal for comparing categories with text labels, easy to read meeting types. Color encoding by category provides additional dimension for analysis.
- **Optimization Tips:** Use LOD calculation for consistent aggregation: {FIXED [Meeting Type], [Meeting Category] : AVG([Duration Minutes])}, limit to active meeting types

### Visual 3: Number of Meetings per User

- **Data Element:** Meeting Count Distribution per User
- **Recommended Visual:** Horizontal Bar Chart (Top N Users)
- **Data Fields:** 
  - DIM_USER.USER_NAME (Rows)
  - FACT_MEETING_ACTIVITY.MEETING_ACTIVITY_ID (Columns - Count)
  - DIM_USER.PLAN_TYPE (Color)
- **Calculations:** 
  ```
  Meetings per User: COUNTD([Meeting Activity Id])
  User Engagement Level: 
  IF [Meetings per User] >= 20 THEN "High Engagement"
  ELSEIF [Meetings per User] >= 10 THEN "Medium Engagement"
  ELSEIF [Meetings per User] >= 5 THEN "Low Engagement"
  ELSE "Minimal Engagement" END
  
  Average Meeting Duration per User: 
  {FIXED [User Key] : AVG([Duration Minutes])}
  
  User Activity Rank: RANK([Meetings per User], 'desc')
  ```
- **Interactivity:** 
  - Top N parameter (default: Top 25 users)
  - Sort by meeting count (ascending/descending)
  - Filter by engagement level
  - Filter by plan type
  - Drill-through action to user detail dashboard
  - Highlight action to show user's activity in other visuals
- **Justification:** Bar chart clearly shows user engagement levels and identifies power users vs. occasional users. Helps identify user adoption patterns and potential churn risks.
- **Optimization Tips:** Use Top N filter (Top 50 users) and context filter for performance, consider using user engagement level as a quick filter

### Visual 4: Feature Usage Distribution

- **Data Element:** Feature Usage Distribution
- **Recommended Visual:** Donut Chart with Highlight Table
- **Data Fields:** 
  - DIM_FEATURE.FEATURE_NAME (Angle/Rows)
  - FACT_FEATURE_USAGE.USAGE_COUNT (Size/Values - Sum)
  - DIM_FEATURE.FEATURE_CATEGORY (Color)
- **Calculations:** 
  ```
  Total Feature Usage: SUM([Usage Count])
  Usage Percentage: SUM([Usage Count]) / TOTAL(SUM([Usage Count]))
  Feature Adoption Rate: COUNTD([User Key]) / {FIXED : COUNTD([User Key])}
  
  Feature Popularity Rank: RANK(SUM([Usage Count]), 'desc')
  
  Feature Engagement Score: 
  (SUM([Usage Count]) * AVG([User Experience Rating])) / TOTAL(SUM([Usage Count]))
  
  Usage Trend: 
  (SUM(IF DATEDIFF('day', [Usage Date], TODAY()) <= 30 THEN [Usage Count] END) - 
   SUM(IF DATEDIFF('day', [Usage Date], TODAY()) BETWEEN 31 AND 60 THEN [Usage Count] END)) /
  SUM(IF DATEDIFF('day', [Usage Date], TODAY()) BETWEEN 31 AND 60 THEN [Usage Count] END)
  ```
- **Interactivity:** 
  - Click on donut slice to filter other charts
  - Parameter to toggle between usage count and adoption rate
  - Filter by feature category
  - Tooltip showing feature adoption rate and user experience rating
  - Quick filter for Top N features
- **Justification:** Donut chart effectively shows proportional usage while leaving center space for key metrics. Complemented by highlight table for precise values and additional metrics.
- **Optimization Tips:** Limit to top 15 features, use "Others" category for remaining features, pre-aggregate usage counts by feature in data source

## 2. Overall Dashboard Design

### Layout Suggestions
- **Top Row:** Total Number of Users KPI Card (left, 25% width) + Key metrics summary cards (right, 75% width)
- **Second Row:** Average Meeting Duration by Type and Category (full width, 100%)
- **Third Row:** Number of Meetings per User (left, 60% width) + Feature Usage Distribution donut chart (right, 40% width)
- **Bottom Section:** Feature Usage highlight table (full width for detailed breakdown)

### Performance Optimization
- **Extract Strategy:** 
  - Use Tableau extracts with incremental refresh based on LOAD_DATE
  - Schedule refresh during off-peak hours (2-4 AM)
  - Implement data source filters to limit historical data (e.g., last 2 years)
  - Create aggregated extracts for user-level and feature-level metrics
- **Filter Optimization:**
  - Use context filters for date ranges and major categorical filters
  - Implement cascading filters (Region → Company → User)
  - Add "All" option to key filters
  - Use relevant values only for categorical filters
- **Calculation Optimization:**
  - Use LOD calculations for user-level aggregations
  - Pre-calculate engagement levels and rankings in data source
  - Use table calculations for running totals and percentages
  - Minimize use of COUNTD in complex calculations

### Color Scheme
- **Primary Colors:** Platform blue (#2D8CFF) for main metrics and KPIs
- **Secondary Colors:** Complementary blues and teals (#4A90E2, #17A2B8, #6C757D)
- **Category Colors:** Distinct colors for meeting categories and feature types
- **Engagement Levels:** Green (#28A745) for high, Yellow (#FFC107) for medium, Red (#DC3545) for low
- **Neutral Colors:** Light grays (#F8F9FA, #E9ECEF) for backgrounds and borders

### Typography
- **Dashboard Title:** Tableau Book Bold, 18pt
- **Visual Titles:** Tableau Book Bold, 14pt
- **KPI Numbers:** Tableau Book Bold, 24pt
- **Axis Labels:** Tableau Book Regular, 10pt
- **Tooltips:** Tableau Book Regular, 9pt

### Interactive Elements

| Element Type | Purpose | Implementation | Target Visuals |
|--------------|---------|----------------|----------------|
| Date Range Filter | Time-based analysis | Relative date filter with presets (Last 30/90/365 days) | All visuals |
| Plan Type Filter | User segment analysis | Multi-select dropdown with "All" option | Visuals 1, 3 |
| Geographic Region Filter | Regional analysis | Hierarchical filter (Region > Country) | Visuals 1, 3 |
| Top N Parameter | Limit displayed items | Integer parameter (10-50, default 25) | Visuals 3, 4 |
| Meeting Type Filter | Meeting analysis | Multi-select with "All" option | Visual 2 |
| Feature Category Filter | Feature analysis | Single-select dropdown | Visual 4 |
| Engagement Level Filter | User segmentation | Multi-select (High/Medium/Low/Minimal) | Visual 3 |
| Metric Toggle Parameter | Switch KPI views | String parameter (Total Users/Active Users) | Visual 1 |

### Dashboard Actions

| Action Type | Source | Target | Purpose |
|-------------|--------|--------|----------|
| Filter Action | Feature Usage Donut | Meeting Duration & User charts | Show impact of feature usage on meetings |
| Highlight Action | User bar chart | All other visuals | Highlight selected user's activity |
| Filter Action | Meeting Type/Category | User and Feature visuals | Focus on specific meeting contexts |
| Go to Sheet Action | KPI Card | Detailed user analysis sheet | Navigate to user trend analysis |
| URL Action | User names | User profile/detail page | External drill-through |

### Potential Pitfalls & Mitigation

1. **Performance with Large User Base:**
   - **Problem:** Slow rendering with thousands of users
   - **Solution:** Implement Top N filters, use user engagement level grouping, consider user sampling for very large datasets

2. **Feature Name Length:**
   - **Problem:** Long feature names causing layout issues
   - **Solution:** Create abbreviated feature names, use tooltips for full names, rotate labels if necessary

3. **Date Range Sensitivity:**
   - **Problem:** Metrics varying significantly with date selection
   - **Solution:** Add reference periods, show period-over-period comparisons, set reasonable default date ranges

4. **Null/Missing Data:**
   - **Problem:** Users without meetings or features without usage
   - **Solution:** Handle nulls explicitly in calculations, create "No Activity" categories, use ISNULL() checks

5. **Dual Metric Confusion:**
   - **Problem:** Users confusing usage count vs. adoption rate
   - **Solution:** Clear labeling, separate visuals for different metrics, explanatory tooltips

### Success Metrics
- Dashboard load time < 8 seconds
- User adoption rate > 85% within 30 days
- Reduction in manual reporting requests by 60%
- Monthly active dashboard users > 150
- User satisfaction score > 4.0/5.0

### Maintenance Recommendations
- **Weekly:** Monitor dashboard performance and usage statistics
- **Bi-weekly:** Review user feedback and usage patterns
- **Monthly:** Update Top N parameters based on data growth
- **Quarterly:** Review and refresh color schemes and layout based on user needs
- **Semi-annually:** Comprehensive dashboard redesign review

### Additional Considerations
- **Mobile Responsiveness:** Ensure KPI cards and key visuals work well on tablets
- **Accessibility:** Use colorblind-friendly palettes, ensure sufficient contrast ratios
- **Data Governance:** Implement row-level security if needed for user data
- **Training Materials:** Create user guides for interpreting engagement levels and feature adoption metrics