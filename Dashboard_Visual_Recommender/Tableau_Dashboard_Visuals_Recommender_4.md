_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Service Reliability & Support Dashboard - Minimal KPI Visual Recommendations
## *Version*: 4
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender - Service Reliability & Support Report (Minimal KPIs)

## Business Objective
Analyze platform stability and customer support interactions to improve service quality and reduce ticket volume.

## Data Model Overview
**Primary Fact Tables:**
- FACT_SUPPORT_ACTIVITY

**Primary Dimension Tables:**
- DIM_USER
- DIM_SUPPORT_CATEGORY
- DIM_DATE

**Key Relationships:**
- FACT_SUPPORT_ACTIVITY → DIM_USER (USER_KEY)
- FACT_SUPPORT_ACTIVITY → DIM_SUPPORT_CATEGORY (SUPPORT_CATEGORY_KEY)
- FACT_SUPPORT_ACTIVITY → DIM_DATE (DATE_KEY)

## 1. Visual Recommendations (Minimal KPIs)

### KPI 1: Number of Users by Support Category and Sub-category

- **Data Element:** User Distribution across Support Categories and Sub-categories
- **Recommended Visual:** Treemap with Hierarchical Navigation
- **Data Fields:**
  - [SUPPORT_CATEGORY] from DIM_SUPPORT_CATEGORY
  - [SUPPORT_SUBCATEGORY] from DIM_SUPPORT_CATEGORY
  - COUNTD([USER_KEY]) from FACT_SUPPORT_ACTIVITY
- **Calculations:**
  - Unique Users: `COUNTD([USER_KEY])`
  - Category Percentage: `COUNTD([USER_KEY]) / TOTAL(COUNTD([USER_KEY]))`
- **Interactivity:**
  - Hierarchy: Support Category → Support Sub-category
  - Date Range Filter
- **Justification:** Treemap effectively shows proportional relationships and enables hierarchical exploration from category to sub-category
- **Optimization Tips:** Use data extract with pre-aggregated user counts, implement incremental refresh

### KPI 2: Number of Support Activities by Resolution Status

- **Data Element:** Support Activity Volume by Resolution Status
- **Recommended Visual:** Donut Chart with Center KPI
- **Data Fields:**
  - [RESOLUTION_STATUS] from FACT_SUPPORT_ACTIVITY
  - COUNT([SUPPORT_ACTIVITY_ID]) from FACT_SUPPORT_ACTIVITY
- **Calculations:**
  - Activity Count: `COUNT([SUPPORT_ACTIVITY_ID])`
  - Resolution Rate: `SUM(IF [RESOLUTION_STATUS] = "Resolved" THEN 1 ELSE 0 END) / COUNT([SUPPORT_ACTIVITY_ID])`
- **Interactivity:**
  - Resolution Status Filter
  - Time Period Parameter (Last 7/30/90 days)
- **Justification:** Donut chart provides clear visual of status distribution with center space for key resolution rate metric
- **Optimization Tips:** Create calculated field for resolution categories, use context filters for date ranges

### KPI 3: Number of Support Activities by Priority

- **Data Element:** Support Activity Distribution by Priority Level
- **Recommended Visual:** Horizontal Bar Chart with Conditional Formatting
- **Data Fields:**
  - [PRIORITY_LEVEL] from DIM_SUPPORT_CATEGORY
  - COUNT([SUPPORT_ACTIVITY_ID]) from FACT_SUPPORT_ACTIVITY
  - [SLA_MET] from FACT_SUPPORT_ACTIVITY
- **Calculations:**
  - Activity Count by Priority: `COUNT([SUPPORT_ACTIVITY_ID])`
  - SLA Compliance Rate: `SUM(IF [SLA_MET] = TRUE THEN 1 ELSE 0 END) / COUNT([SUPPORT_ACTIVITY_ID])`
- **Interactivity:**
  - Priority Level Filter
  - SLA Status Filter
- **Justification:** Horizontal bars allow easy comparison across priority levels with conditional formatting highlighting SLA performance
- **Optimization Tips:** Index priority and SLA fields, pre-calculate SLA metrics in data source

## 2. Overall Dashboard Design

### Layout Suggestions
- **Top Row:** Key Metrics - Total Support Activities, Resolution Rate, Average Resolution Time
- **Middle Row:** Support Category Treemap (Left 60%), Resolution Status Donut Chart (Right 40%)
- **Bottom Row:** Priority Distribution Bar Chart (Full Width)
- **Filter Panel:** Top header with essential filters

### Performance Optimization
- **Extract Strategy:** Daily refresh with incremental updates for current month
- **Indexing:** Create composite indexes on (USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY)
- **Context Filters:** Apply date range and active tickets as context filters
- **Data Source Filters:** Exclude test tickets and system-generated activities

### Color Scheme
- **Priority Colors:** 
  - Critical: Red (#d62728)
  - High: Orange (#ff7f0e)
  - Medium: Yellow (#ffbb78)
  - Low: Green (#2ca02c)
- **Status Colors:**
  - Resolved: Green (#2ca02c)
  - In Progress: Blue (#1f77b4)
  - Pending: Gray (#7f7f7f)
  - Escalated: Red (#d62728)

### Typography
- **KPI Headers:** Tableau Book Bold, 14pt
- **KPI Values:** Tableau Book Bold, 18pt
- **Chart Labels:** Tableau Book Regular, 10pt
- **Tooltips:** Tableau Book Regular, 9pt

### Interactive Elements

| Element Type | Name | Purpose | Scope |
|--------------|------|---------|-------|
| Filter | Date Range | Time period analysis | Dashboard |
| Filter | Priority Level | Focus on specific priorities | Dashboard |
| Filter | Resolution Status | Status-based filtering | Dashboard |
| Parameter | Time Comparison | Period-over-period analysis | Trend Analysis |
| Action | Drill-down | Category to Sub-category | Treemap |
| Action | Highlight | Cross-sheet highlighting | All Sheets |
| Action | Filter | Click-to-filter interaction | All Sheets |

### Dashboard Alignment & Layout
- **Grid System:** Use 12-column grid for consistent alignment
- **Spacing:** Maintain 8px padding between elements
- **Sizing:** 
  - KPI cards: 250px width
  - Treemap: 60% width of container
  - Donut chart: 40% width of container
  - Bar chart: Full width responsive
- **Responsive Design:** Ensure proper scaling across different screen sizes
- **Visual Hierarchy:** Largest elements for primary KPIs, balanced layout for supporting charts
- **Consistent Margins:** 16px margins around dashboard containers
- **Alignment:** Left-align text labels, center-align KPI values, right-align numerical data in tables

### Performance Considerations
- Monitor dashboard load times during peak support hours
- Use incremental refresh for large support activity datasets
- Optimize LOD calculations for better performance
- Cache frequently accessed aggregations
- Implement row-level security for department-specific access