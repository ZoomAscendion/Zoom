_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Tableau Dashboard Visuals Recommender for Zoom Platform Usage & Adoption Report
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender
## Zoom Platform Usage & Adoption Report

### **1. Visual Recommendations**

#### **KPI 1: Total Number of Users**
- **Data Element:** Total Number of Users
- **Recommended Visual:** KPI Card/Big Number
- **Data Fields:** 
  - USER_KEY from FACT_MEETING_ACTIVITY
  - USER_NAME from DIM_USER (for validation)
- **Calculations:** 
  ```
  Total Users: COUNTD([USER_KEY])
  ```
- **Interactivity:** 
  - Date range filter (using DATE_KEY)
  - Geographic region filter (from DIM_USER.GEOGRAPHIC_REGION)
  - Plan type filter (from DIM_USER.PLAN_TYPE)
- **Justification:** KPI cards are ideal for displaying single metric values prominently. The distinct count ensures we don't double-count users who attended multiple meetings.
- **Optimization Tips:** 
  - Use extract with aggregated data
  - Create context filter for date range to improve performance
  - Index USER_KEY in source system

#### **KPI 2: Average Meeting Duration**
- **Data Element:** Average Meeting Duration
- **Recommended Visual:** KPI Card with Trend Line (Dual Visual)
- **Data Fields:** 
  - DURATION_MINUTES from FACT_MEETING_ACTIVITY
  - DATE_KEY for trend analysis
- **Calculations:** 
  ```
  Average Duration: AVG([DURATION_MINUTES])
  Duration in Hours: [Average Duration]/60
  ```
- **Interactivity:** 
  - Date range filter
  - Meeting type filter (from DIM_MEETING.MEETING_TYPE)
  - Time of day category filter (from DIM_MEETING.TIME_OF_DAY_CATEGORY)
  - Drill-down to daily/weekly/monthly trends
- **Justification:** KPI card shows the key metric while a trend line reveals patterns over time. This combination provides both current state and directional insight.
- **Optimization Tips:** 
  - Pre-aggregate duration calculations in extract
  - Use continuous date axis for smooth trend lines
  - Limit trend analysis to reasonable time periods

#### **KPI 3: Number of Meetings Created Per User**
- **Data Element:** Meetings Per User
- **Recommended Visual:** Histogram/Distribution Chart + Summary KPI Card
- **Data Fields:** 
  - USER_KEY from FACT_MEETING_ACTIVITY
  - MEETING_KEY from FACT_MEETING_ACTIVITY
  - USER_NAME from DIM_USER
- **Calculations:** 
  ```
  Meetings Per User: {FIXED [USER_KEY]: COUNTD([MEETING_KEY])}
  Average Meetings Per User: AVG([Meetings Per User])
  Median Meetings Per User: MEDIAN([Meetings Per User])
  ```
- **Interactivity:** 
  - Date range filter
  - User segment filter (from DIM_USER.USER_ROLE, PLAN_TYPE)
  - Drill-through to individual user details
  - Parameter for binning (e.g., 1-5 meetings, 6-10 meetings, etc.)
- **Justification:** Histogram shows the distribution of meeting creation behavior across users, while KPI cards provide summary statistics. This reveals user engagement patterns.
- **Optimization Tips:** 
  - Use LOD calculations efficiently
  - Create bins for better performance
  - Consider using sets for user segmentation

#### **Supporting Visual: Meeting Activity Trend**
- **Data Element:** Meeting Activity Over Time
- **Recommended Visual:** Dual-Axis Line Chart
- **Data Fields:** 
  - DATE_KEY (continuous)
  - MEETING_KEY (count distinct)
  - USER_KEY (count distinct)
- **Calculations:** 
  ```
  Daily Meetings: COUNTD([MEETING_KEY])
  Daily Active Users: COUNTD([USER_KEY])
  ```
- **Interactivity:** 
  - Date range filter
  - Granularity parameter (Daily/Weekly/Monthly)
  - Meeting type filter
- **Justification:** Shows correlation between user activity and meeting volume over time. Dual axis allows comparison of two related metrics.
- **Optimization Tips:** 
  - Synchronize dual axes for proper comparison
  - Use extract with date aggregations
  - Implement proper axis formatting

#### **Supporting Visual: User Engagement Matrix**
- **Data Element:** User Engagement by Plan Type and Region
- **Recommended Visual:** Highlight Table (Square marks)
- **Data Fields:** 
  - PLAN_TYPE from DIM_USER
  - GEOGRAPHIC_REGION from DIM_USER
  - Calculated meetings per user metric
- **Calculations:** 
  ```
  Avg Meetings by Segment: {FIXED [PLAN_TYPE], [GEOGRAPHIC_REGION]: AVG([Meetings Per User])}
  ```
- **Interactivity:** 
  - Color intensity based on engagement level
  - Tooltip showing detailed metrics
  - Filter actions to other visuals
- **Justification:** Heat map format quickly identifies high/low engagement segments for targeted analysis.
- **Optimization Tips:** 
  - Use square marks for better heat map visualization
  - Implement color legend for clear interpretation
  - Aggregate at segment level for performance

### **2. Overall Dashboard Design**

#### **Layout Suggestions:**
- **Top Row:** Three main KPI cards (Total Users, Avg Duration, Meetings/User) with large, prominent numbers
- **Middle Row:** Meeting Activity Trend chart (full width) showing temporal patterns
- **Bottom Left:** User Engagement Distribution (histogram)
- **Bottom Right:** User Engagement Matrix (highlight table)
- **Sidebar:** Interactive filters and parameters
- **Mobile Layout:** Stack KPIs vertically, simplify charts for mobile consumption

#### **Performance Optimization:**
- **Extract Strategy:** 
  - Create extract with pre-aggregated metrics at daily level
  - Refresh extract daily during off-peak hours
  - Use incremental refresh for large datasets
- **Filter Optimization:** 
  - Use context filters for date ranges
  - Implement cascading filters (Region → Plan Type)
  - Limit filter options to reasonable ranges
- **Data Prep Recommendations:** 
  - Pre-calculate common metrics in data source
  - Create indexed views for frequently used joins
  - Implement proper foreign key relationships

#### **Color Scheme:**
- **Primary Colors:** Zoom blue (#2D8CFF) for main metrics
- **Secondary Colors:** Complementary blues and grays for supporting visuals
- **Accent Colors:** Orange (#FF6B35) for highlights and alerts
- **Neutral Colors:** Light grays for backgrounds and borders
- **Accessibility:** Ensure sufficient contrast ratios, use patterns in addition to colors

#### **Typography:**
- **Headers:** Bold, sans-serif fonts (Tableau Book Bold) for dashboard title
- **KPI Numbers:** Large, bold fonts (24-36pt) for primary metrics
- **Labels:** Medium fonts (10-12pt) for axis labels and legends
- **Tooltips:** Consistent formatting with clear hierarchy
- **Readability:** Maintain consistent font sizes across similar elements

#### **Interactive Elements:**

| Element Type | Name | Purpose | Implementation |
|--------------|------|---------|----------------|
| **Date Filter** | Date Range | Filter all visuals by time period | Quick filter with relative date options |
| **Geographic Filter** | Region Selector | Filter by user geographic region | Multi-select dropdown |
| **Plan Type Filter** | Plan Filter | Filter by subscription plan | Multi-select with "All" option |
| **Meeting Type Filter** | Meeting Category | Filter by meeting type | Single select dropdown |
| **Granularity Parameter** | Time Granularity | Switch between Daily/Weekly/Monthly | Parameter control with radio buttons |
| **Bin Size Parameter** | Distribution Bins | Adjust histogram bin sizes | Parameter slider |
| **Drill-Down Action** | Date Hierarchy | Drill from Month → Week → Day | Hierarchy drill-down on trend chart |
| **Filter Action** | Cross-Filtering | Click segment to filter other visuals | Dashboard action from matrix to other charts |
| **Highlight Action** | Visual Emphasis | Highlight related data points | Hover actions across charts |
| **URL Action** | User Details | Link to detailed user reports | Context menu action |

#### **Performance Considerations:**
- **Potential Pitfalls:**
  - High cardinality in USER_KEY field - use extracts and aggregation
  - Complex LOD calculations - minimize and optimize
  - Too many simultaneous filters - implement filter hierarchy
  - Large date ranges - set reasonable defaults and limits
  - Inefficient joins - ensure proper indexing and relationship design

#### **Data Model Recommendations:**
- **Primary Fact Table:** FACT_MEETING_ACTIVITY
- **Dimension Tables:** 
  - DIM_USER (for user attributes)
  - DIM_MEETING (for meeting characteristics)
  - DIM_DATE (for time-based analysis)
- **Relationships:** 
  - FACT_MEETING_ACTIVITY.USER_KEY → DIM_USER.USER_KEY
  - FACT_MEETING_ACTIVITY.MEETING_KEY → DIM_MEETING.MEETING_KEY
  - FACT_MEETING_ACTIVITY.DATE_KEY → DIM_DATE.DATE_KEY
- **Join Strategy:** Use inner joins for active records, left joins for optional dimensions

#### **Additional Recommendations:**
- **Refresh Schedule:** Daily refresh at 6 AM to capture previous day's activity
- **Data Quality:** Implement data validation rules for duration and participant counts
- **User Training:** Provide tooltips and help text for complex metrics
- **Mobile Optimization:** Create simplified mobile version with key KPIs only
- **Export Options:** Enable PDF export for executive reporting
- **Alerts:** Set up data-driven alerts for unusual patterns (e.g., significant drops in usage)

---

**Dashboard Success Metrics:**
- Load time under 5 seconds for initial view
- Filter response time under 2 seconds
- User adoption rate >80% within first month
- Reduced time-to-insight for platform usage questions
- Increased self-service analytics adoption