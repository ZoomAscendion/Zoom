_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Tableau Dashboard Visuals Recommender for Platform Usage & Adoption Report
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender
## Platform Usage & Adoption Report

## **Data Model and Relationships**

### **Star Schema Design for Platform Usage Analytics**

This report focuses on platform usage patterns, meeting activities, and user adoption metrics.

#### **Primary Fact Table:**
- **FACT_MEETING_ACTIVITY** (Grain: One record per meeting)
- **FACT_FEATURE_USAGE** (Grain: One record per feature usage event)

#### **Supporting Dimension Tables:**
- **DIM_USER** (User characteristics and demographics)
- **DIM_DATE** (Time dimension for temporal analysis)
- **DIM_MEETING_TYPE** (Meeting characteristics and categories)
- **DIM_FEATURE** (Feature details and classifications)

### **Key Relationships for Platform Usage Report**

**Primary Data Flow:**
```
FACT_MEETING_ACTIVITY (Grain: One record per meeting)
├── → DIM_USER (USER_DIM_ID) [Many-to-One]
├── → DIM_MEETING_TYPE (MEETING_TYPE_ID) [Many-to-One]
├── → DIM_DATE (DATE_ID) [Many-to-One]

FACT_FEATURE_USAGE (Grain: One record per feature usage)
├── → DIM_USER (USER_DIM_ID) [Many-to-One]
├── → DIM_FEATURE (FEATURE_ID) [Many-to-One]
├── → DIM_DATE (DATE_ID) [Many-to-One]
```

## **1. Visual Recommendations**

### **KPI Overview Section**

#### **Metric 1: Total Meeting Minutes and Active Users**
- **Data Element:** Key Platform Usage KPIs
- **Recommended Visual:** KPI Cards with Trend Sparklines
- **Data Fields:** 
  - ACTUAL_DURATION_MINUTES from FACT_MEETING_ACTIVITY
  - USER_DIM_ID from FACT_MEETING_ACTIVITY
  - DATE_ID for trend analysis
- **Query/Tableau Calculation:** 
  ```
  // Total Meeting Minutes
  SUM([Actual Duration Minutes])
  
  // Active Users
  COUNTD([User Dim Id])
  
  // Month-over-Month Growth Rate
  (SUM([Actual Duration Minutes]) - LOOKUP(SUM([Actual Duration Minutes]), -1)) / ABS(LOOKUP(SUM([Actual Duration Minutes]), -1))
  
  // Weekly Active Users Trend
  {FIXED DATETRUNC('week', [Date Id]) : COUNTD([User Dim Id])}
  ```
- **Calculations:** Period-over-period percentage change, rolling averages, trend indicators
- **Interactivity:** 
  - Date range filter (Last 30 days, Last Quarter, Last Year)
  - Drill-down to daily/weekly granularity
  - Hover tooltips showing previous period comparison
- **Justification:** KPI cards provide immediate visibility into key performance indicators with historical context
- **Optimization Tips:** 
  - Use extract with daily aggregations
  - Implement incremental refresh for recent data
  - Create indexed views for date-based queries

---

#### **Metric 2: Meeting Quality Score Trends**
- **Data Element:** Platform Performance Quality Metrics
- **Recommended Visual:** Dual-Axis Line Chart with Area Fill
- **Data Fields:** 
  - MEETING_QUALITY_SCORE from FACT_MEETING_ACTIVITY
  - AUDIO_QUALITY_SCORE from FACT_MEETING_ACTIVITY
  - VIDEO_QUALITY_SCORE from FACT_MEETING_ACTIVITY
  - DATE_ID for time series
- **Query/Tableau Calculation:** 
  ```
  // Average Quality Scores by Date
  AVG([Meeting Quality Score])
  AVG([Audio Quality Score])
  AVG([Video Quality Score])
  
  // Quality Trend Indicator
  INDEX() = SIZE() AND AVG([Meeting Quality Score]) >= WINDOW_AVG(AVG([Meeting Quality Score]))
  
  // Quality Score Distribution
  PERCENTILE([Meeting Quality Score], 0.25)
  PERCENTILE([Meeting Quality Score], 0.75)
  ```
- **Calculations:** Moving averages, percentile bands, trend indicators
- **Interactivity:** 
  - Parameter to switch between quality metrics
  - Filter by meeting type and user segment
  - Reference bands for quality thresholds
- **Justification:** Dual-axis shows multiple quality dimensions with trend context
- **Optimization Tips:** Pre-aggregate quality scores by date, use continuous date axis

---

### **Usage Analysis Section**

#### **Metric 3: Average Meeting Duration by Type and Category**
- **Data Element:** Meeting Duration Analysis
- **Recommended Visual:** Grouped Bar Chart with Reference Lines
- **Data Fields:** 
  - MEETING_TYPE from DIM_MEETING_TYPE
  - MEETING_CATEGORY from DIM_MEETING_TYPE
  - ACTUAL_DURATION_MINUTES from FACT_MEETING_ACTIVITY
  - SCHEDULED_DURATION_MINUTES from FACT_MEETING_ACTIVITY
- **Query/Tableau Calculation:** 
  ```
  // Average Actual Duration by Type
  {FIXED [Meeting Type] : AVG([Actual Duration Minutes])}
  
  // Duration Variance (Actual vs Scheduled)
  AVG([Actual Duration Minutes]) - AVG([Scheduled Duration Minutes])
  
  // Overall Average Reference Line
  WINDOW_AVG(AVG([Actual Duration Minutes]))
  
  // Duration Efficiency Ratio
  AVG([Actual Duration Minutes]) / AVG([Scheduled Duration Minutes])
  ```
- **Calculations:** Fixed LOD for consistent averages, variance calculations, efficiency ratios
- **Interactivity:** 
  - Parameter to switch between Actual vs Scheduled duration
  - Filter by business purpose and time period
  - Tooltip showing participant statistics
  - Sort by duration or meeting count
- **Justification:** Grouped bars allow comparison across categorical dimensions with benchmark context
- **Optimization Tips:** 
  - Use context filters for date ranges
  - Pre-aggregate at meeting type level
  - Limit to top 15 meeting types for performance

---

#### **Metric 4: Participant Engagement Metrics**
- **Data Element:** Meeting Participation Analysis
- **Recommended Visual:** Scatter Plot with Size and Color Encoding
- **Data Fields:** 
  - PARTICIPANT_COUNT from FACT_MEETING_ACTIVITY
  - AVERAGE_PARTICIPATION_MINUTES from FACT_MEETING_ACTIVITY
  - PEAK_CONCURRENT_PARTICIPANTS from FACT_MEETING_ACTIVITY
  - MEETING_SATISFACTION_SCORE from FACT_MEETING_ACTIVITY
- **Query/Tableau Calculation:** 
  ```
  // Engagement Rate
  [Average Participation Minutes] / [Actual Duration Minutes]
  
  // Participation Efficiency
  [Peak Concurrent Participants] / [Participant Count]
  
  // Engagement Score Bins
  IF [Engagement Rate] >= 0.8 THEN "High Engagement"
  ELSEIF [Engagement Rate] >= 0.5 THEN "Medium Engagement"
  ELSE "Low Engagement"
  END
  
  // Meeting Size Categories
  IF [Participant Count] <= 5 THEN "Small (1-5)"
  ELSEIF [Participant Count] <= 15 THEN "Medium (6-15)"
  ELSEIF [Participant Count] <= 50 THEN "Large (16-50)"
  ELSE "Very Large (50+)"
  END
  ```
- **Calculations:** Engagement ratios, categorical binning, efficiency metrics
- **Interactivity:** 
  - Size by participant count, color by satisfaction score
  - Filter by meeting type and date range
  - Highlight action to filter other views
  - Drill-through to meeting details
- **Justification:** Scatter plot reveals relationships between multiple engagement dimensions
- **Optimization Tips:** 
  - Sample large datasets for scatter plot performance
  - Use calculated fields for binning
  - Implement data density controls

---

### **Feature Usage Section**

#### **Metric 5: Feature Adoption and Usage Patterns**
- **Data Element:** Platform Feature Utilization
- **Recommended Visual:** Highlight Table (Heat Map Style) with Nested Sorting
- **Data Fields:** 
  - FEATURE_NAME from DIM_FEATURE
  - FEATURE_CATEGORY from DIM_FEATURE
  - USAGE_COUNT from FACT_FEATURE_USAGE
  - FEATURE_ADOPTION_SCORE from FACT_FEATURE_USAGE
  - USER_EXPERIENCE_RATING from FACT_FEATURE_USAGE
- **Query/Tableau Calculation:** 
  ```
  // Feature Usage Frequency
  SUM([Usage Count])
  
  // Unique Users per Feature
  COUNTD([User Dim Id])
  
  // Feature Adoption Rate
  COUNTD([User Dim Id]) / TOTAL(COUNTD([User Dim Id]))
  
  // Average User Experience Rating
  AVG([User Experience Rating])
  
  // Feature Usage Intensity
  SUM([Usage Count]) / COUNTD([User Dim Id])
  
  // Category Performance Score
  {FIXED [Feature Category] : AVG([Feature Adoption Score])}
  ```
- **Calculations:** Adoption rates, usage intensity, experience ratings, category aggregations
- **Interactivity:** 
  - Hierarchical filter: Category → Feature
  - Sort by adoption rate, usage count, or experience rating
  - Color coding by performance thresholds
  - Click to filter usage trends
- **Justification:** Heat map format shows both feature popularity and user satisfaction intensity
- **Optimization Tips:** 
  - Limit to top 50 features for performance
  - Use string aggregation for feature grouping
  - Pre-calculate adoption metrics

---

#### **Metric 6: User Engagement Distribution**
- **Data Element:** User Activity Level Analysis
- **Recommended Visual:** Histogram with Box Plot Overlay
- **Data Fields:** 
  - USER_DIM_ID from FACT_MEETING_ACTIVITY
  - MEETING_ACTIVITY_ID count
  - PLAN_TYPE from DIM_USER
  - USER_ROLE from DIM_USER
- **Query/Tableau Calculation:** 
  ```
  // Meetings per User
  {FIXED [User Dim Id] : COUNT([Meeting Activity Id])}
  
  // User Engagement Segments
  IF [Meetings per User] <= 2 THEN "Inactive (0-2)"
  ELSEIF [Meetings per User] <= 10 THEN "Low (3-10)"
  ELSEIF [Meetings per User] <= 25 THEN "Medium (11-25)"
  ELSEIF [Meetings per User] <= 50 THEN "High (26-50)"
  ELSE "Very High (50+)"
  END
  
  // Percentile Rankings
  PERCENTILE([Meetings per User], 0.25)
  PERCENTILE([Meetings per User], 0.5)
  PERCENTILE([Meetings per User], 0.75)
  
  // Engagement Score by Plan Type
  {FIXED [Plan Type] : AVG([Meetings per User])}
  ```
- **Calculations:** User-level aggregation, binning logic, percentile calculations, plan comparisons
- **Interactivity:** 
  - Dynamic bin size parameter (5, 10, 15 meetings)
  - Filter by user role, plan type, and geographic region
  - Drill-through to individual user analysis
  - Color by plan type or user role
- **Justification:** Histogram shows engagement distribution patterns, box plot adds statistical context
- **Optimization Tips:** 
  - Create user-level extract for performance
  - Use calculated bins instead of Tableau's automatic binning
  - Implement user sampling for large datasets

---

## **2. Overall Dashboard Design**

### **Layout Suggestions:**
- **Header Section (15% height):** 
  - KPI cards for total minutes, active users, and quality scores
  - Global date range filter and reset button
- **Main Content Area (70% height):**
  - **Left Panel (40%):** Meeting duration analysis and participant engagement scatter plot
  - **Right Panel (60%):** Feature adoption heat map and usage trends
- **Footer Section (15% height):** 
  - User engagement histogram
  - Filter controls for user segments and meeting types

### **Performance Optimization:**
- **Extract Strategy:** 
  - Daily incremental refresh for FACT_MEETING_ACTIVITY and FACT_FEATURE_USAGE
  - Weekly full refresh for dimension tables
  - Separate extracts for meeting and feature analysis
- **Query Optimization:**
  - Use custom SQL with pre-aggregated metrics
  - Implement date partitioning for large fact tables
  - Create indexed views for frequently used joins
- **Calculation Optimization:**
  - Move complex calculations to data source level
  - Use context filters before dimension filters
  - Minimize nested LOD calculations

### **Color Scheme:**
- **Primary:** Blue (#1f77b4) for meeting metrics
- **Secondary:** Green (#2ca02c) for positive trends and targets met
- **Accent:** Orange (#ff7f0e) for feature usage and comparisons
- **Alert:** Red (#d62728) for low performance or issues
- **Neutral:** Gray (#7f7f7f) for supporting elements and backgrounds

### **Typography:**
- **Dashboard Title:** Tableau Book, 18pt, Bold
- **Section Headers:** Tableau Book, 14pt, Bold
- **Chart Titles:** Tableau Book, 12pt, Bold
- **KPI Values:** Tableau Book, 24pt, Bold
- **Labels and Legends:** Tableau Book, 10pt, Regular
- **Tooltips:** Tableau Book, 9pt, Regular

### **Interactive Elements:**

| Element Type | Purpose | Implementation | Data Fields |
|--------------|---------|----------------|-------------|
| **Date Range Filter** | Time period selection | Relative date filter with custom ranges | DATE_ID (Last 7 days, Last 30 days, Last Quarter, Last Year, Custom) |
| **User Segment Filter** | User demographic filtering | Multi-select dropdown with "All" option | PLAN_TYPE, USER_ROLE, GEOGRAPHIC_REGION, INDUSTRY_SECTOR |
| **Meeting Type Parameter** | Analysis focus switching | Single-select parameter with radio buttons | MEETING_TYPE vs MEETING_CATEGORY vs BUSINESS_PURPOSE |
| **Quality Threshold Parameter** | Performance benchmark adjustment | Slider parameter (1-10 scale) | MEETING_QUALITY_SCORE threshold for color coding |
| **Feature Category Filter** | Feature analysis filtering | Hierarchical filter with expand/collapse | FEATURE_CATEGORY → FEATURE_NAME |
| **Engagement Bin Parameter** | User segmentation adjustment | Single-select parameter | Bin sizes: 5, 10, 15, 20 meetings |
| **Cross-Filter Actions** | Related data highlighting | Filter actions between related charts | USER_DIM_ID, MEETING_TYPE_ID cross-filtering |
| **Drill-Down Actions** | Navigate to detailed views | URL actions to detailed dashboards | Meeting details, User profiles, Feature analysis |
| **Reset Dashboard Action** | Clear all selections | Button action | Return to default filter state |
| **Export Data Action** | Data extraction | Download action | Filtered data export to CSV/Excel |

### **Dashboard Performance Tips:**
1. **Data Connection:** Use extracts instead of live connections for better performance
2. **Filter Order:** Apply context filters first, then dimension filters, then measure filters
3. **Calculation Placement:** Move calculations to data source when possible
4. **Visual Optimization:** Limit mark count to under 10,000 per worksheet
5. **Refresh Strategy:** Schedule extract refreshes during off-peak hours
6. **Mobile Optimization:** Create device-specific layouts for mobile access

**Output URL:** https://github.com/DIAscendion/Ascendion/blob/Agent_Output/Tableau_Dashboard_TWB_1
**Pipeline ID:** 9468