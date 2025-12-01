_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Enhanced Tableau Dashboard Visuals Recommender with Data Model and Relationships for Platform Analytics System
## *Version*: 2
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender
## Platform Analytics System - Enhanced with Data Model and Relationships

## **Data Model and Relationships**

### **Star Schema Design for Platform Analytics**

Based on the requirement document analysis, the following data model supports the two main reports:

#### **Fact Tables:**
1. **FACT_MEETING_ACTIVITY** (Primary fact for Platform Usage & Adoption Report)
2. **FACT_SUPPORT_ACTIVITY** (Primary fact for Service Reliability & Support Report)

#### **Dimension Tables:**
1. **DIM_USER** (Central dimension for user analysis)
2. **DIM_DATE** (Time dimension for temporal analysis)
3. **DIM_MEETING** (Meeting characteristics)
4. **DIM_FEATURE** (Feature details)
5. **DIM_SUPPORT_CATEGORY** (Support categorization)

### **Key Relationships for Report Requirements**

#### **Report 1: Platform Usage & Adoption Report**

**Primary Data Flow:**
```
FACT_MEETING_ACTIVITY (Grain: One record per meeting per user)
├── → DIM_USER (USER_KEY) [Many-to-One]
├── → DIM_MEETING (MEETING_KEY) [Many-to-One]
├── → DIM_DATE (DATE_KEY) [Many-to-One]
└── → DIM_FEATURE (FEATURE_KEY) [Many-to-One]

FACT_FEATURE_USAGE (Grain: One record per feature usage event)
├── → DIM_FEATURE (FEATURE_KEY) [Many-to-One]
├── → DIM_USER (USER_KEY) [Many-to-One]
├── → DIM_DATE (DATE_KEY) [Many-to-One]
└── → DIM_MEETING (MEETING_KEY) [Many-to-One]
```

**Required Tables for Platform Usage Metrics:**
- **FACT_MEETING_ACTIVITY**: Contains DURATION_MINUTES, PARTICIPANT_COUNT, MEETING_TOPIC
- **DIM_USER**: Contains USER_NAME, PLAN_TYPE, GEOGRAPHIC_REGION, USER_ROLE
- **DIM_MEETING**: Contains MEETING_TYPE, MEETING_CATEGORY, BUSINESS_PURPOSE
- **DIM_DATE**: Contains DATE_VALUE, YEAR, MONTH, QUARTER for time-based analysis
- **DIM_FEATURE**: Contains FEATURE_NAME, FEATURE_CATEGORY for feature usage tracking

#### **Report 2: Service Reliability & Support Report**

**Primary Data Flow:**
```
FACT_SUPPORT_ACTIVITY (Grain: One record per support ticket)
├── → DIM_USER (USER_KEY) [Many-to-One]
├── → DIM_DATE (DATE_KEY) [Many-to-One]
└── → DIM_SUPPORT_CATEGORY (SUPPORT_CATEGORY_KEY) [Many-to-One]
```

**Required Tables for Support Metrics:**
- **FACT_SUPPORT_ACTIVITY**: Contains RESOLUTION_STATUS, PRIORITY_LEVEL, RESOLUTION_TIME_HOURS
- **DIM_SUPPORT_CATEGORY**: Contains SUPPORT_CATEGORY, SUPPORT_SUBCATEGORY, PRIORITY_LEVEL
- **DIM_USER**: Contains user details for support requesters
- **DIM_DATE**: Contains temporal dimensions for support trend analysis

## **1. Visual Recommendations**

### **Report 1: Platform Usage & Adoption Report**

#### **Metric 1: Track Key Usage Metrics (Total Meeting Minutes and Active Users)**
- **Data Element:** Total Meeting Minutes and Active Users KPI
- **Recommended Visual:** KPI Cards with Trend Indicators
- **Data Fields:** 
  - Total Minutes: `SUM([Duration Minutes])`
  - Active Users: `COUNTD([User Key])`
  - Previous Period Comparison
- **Query/Tableau Calculation:** 
  ```
  // Total Meeting Minutes
  SUM([Duration Minutes])
  
  // Active Users
  COUNTD([User Key])
  
  // Month-over-Month Growth
  (SUM([Duration Minutes]) - LOOKUP(SUM([Duration Minutes]), -1)) / LOOKUP(SUM([Duration Minutes]), -1)
  ```
- **Calculations:** Period-over-period percentage change, trend indicators
- **Interactivity:** Date range filter, drill-down to daily/weekly views
- **Justification:** KPI cards provide immediate visibility into key performance indicators with trend context
- **Optimization Tips:** Use extract with monthly aggregations, implement incremental refresh

---

#### **Metric 2: Average Meeting Duration by Type and Category**
- **Data Element:** Average Meeting Duration Analysis
- **Recommended Visual:** Grouped Bar Chart with Reference Lines
- **Data Fields:** MEETING_TYPE, MEETING_CATEGORY, AVG(DURATION_MINUTES)
- **Query/Tableau Calculation:** 
  ```
  // Average Duration by Type
  {FIXED [Meeting Type] : AVG([Duration Minutes])}
  
  // Average Duration by Category within Type
  {FIXED [Meeting Type], [Meeting Category] : AVG([Duration Minutes])}
  
  // Overall Average Reference Line
  WINDOW_AVG(AVG([Duration Minutes]))
  ```
- **Calculations:** Fixed LOD for consistent averages, reference line for benchmark
- **Interactivity:** 
  - Parameter to switch between Type and Category view
  - Filter by date range and user segment
  - Tooltip showing participant count statistics
- **Justification:** Grouped bars allow comparison across multiple categorical dimensions
- **Optimization Tips:** Pre-aggregate at source level, use context filters for date ranges

---

#### **Metric 3: Number of Users by Meeting Topics**
- **Data Element:** Meeting Topic Popularity
- **Recommended Visual:** Highlight Table (Square Mark Type) - Heat Map Style
- **Data Fields:** MEETING_TOPIC, COUNT(DISTINCT USER_KEY), Meeting Frequency
- **Query/Tableau Calculation:** 
  ```
  // Unique Users per Topic
  COUNTD([User Key])
  
  // Topic Engagement Score
  COUNTD([User Key]) / TOTAL(COUNTD([User Key]))
  
  // Meeting Frequency per Topic
  COUNT([Meeting Activity Id])
  ```
- **Calculations:** User count, engagement percentage, frequency metrics
- **Interactivity:** 
  - Filter by meeting type and date range
  - Sort by user count or engagement score
  - Click to filter other dashboard views
- **Justification:** Heat map format shows both topic popularity and engagement intensity
- **Optimization Tips:** Limit to top 50 topics, use string aggregation for topic grouping

---

#### **Metric 4: Number of Meetings per User**
- **Data Element:** User Meeting Frequency Distribution
- **Recommended Visual:** Histogram with Box Plot Overlay
- **Data Fields:** USER_NAME, COUNT(MEETING_ACTIVITY_ID), User Segments
- **Query/Tableau Calculation:** 
  ```
  // Meetings per User
  {FIXED [User Key] : COUNT([Meeting Activity Id])}
  
  // User Engagement Bins
  IF [Meetings per User] <= 5 THEN "Low (1-5)"
  ELSEIF [Meetings per User] <= 15 THEN "Medium (6-15)"
  ELSEIF [Meetings per User] <= 30 THEN "High (16-30)"
  ELSE "Very High (30+)"
  END
  
  // Percentile Ranking
  PERCENTILE([Meetings per User], 0.25, 0.5, 0.75)
  ```
- **Calculations:** User-level aggregation, binning logic, percentile calculations
- **Interactivity:** 
  - Dynamic bin size parameter
  - Filter by user role and plan type
  - Drill-through to user detail view
- **Justification:** Histogram shows distribution patterns, box plot adds statistical context
- **Optimization Tips:** Create user-level extract, use calculated bins for performance

---

### **Report 2: Service Reliability & Support Report**

#### **Metric 1: Number of Users by Support Category and Subcategory**
- **Data Element:** Support Category User Distribution
- **Recommended Visual:** Nested Bar Chart (Stacked Horizontal)
- **Data Fields:** SUPPORT_CATEGORY, SUPPORT_SUBCATEGORY, COUNT(DISTINCT USER_KEY)
- **Query/Tableau Calculation:** 
  ```
  // Users per Category
  COUNTD([User Key])
  
  // Category Distribution Percentage
  COUNTD([User Key]) / TOTAL(COUNTD([User Key]))
  
  // Subcategory within Category Percentage
  COUNTD([User Key]) / TOTAL(COUNTD([User Key]) INCLUDE [Support Category])
  ```
- **Calculations:** Distinct user counts, percentage distributions at multiple levels
- **Interactivity:** 
  - Hierarchical drill-down from category to subcategory
  - Filter by priority level and date range
  - Sort options (count, alphabetical)
- **Justification:** Stacked bars show both total volume and internal distribution
- **Optimization Tips:** Pre-aggregate support user counts, use extract with category rollups

---

#### **Metric 2: Number of Support Activities by Resolution Status**
- **Data Element:** Support Resolution Status Overview
- **Recommended Visual:** Donut Chart with Central KPI
- **Data Fields:** RESOLUTION_STATUS, COUNT(SUPPORT_ACTIVITY_ID)
- **Query/Tableau Calculation:** 
  ```
  // Total Support Activities
  COUNT([Support Activity Id])
  
  // Resolution Rate
  SUM(IF [Resolution Status] = 'Resolved' THEN 1 ELSE 0 END) / COUNT([Support Activity Id])
  
  // Average Resolution Time by Status
  AVG([Resolution Time Hours])
  
  // First Contact Resolution Rate
  SUM(IF [First Contact Resolution Flag] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])
  ```
- **Calculations:** Status counts, resolution rates, time-based metrics
- **Interactivity:** 
  - Date range and priority filters
  - Click to filter detailed views
  - Hover for detailed metrics
- **Justification:** Donut chart shows proportional distribution with central summary metric
- **Optimization Tips:** Use quick table calculations for percentages, limit status categories

---

#### **Metric 3: Number of Support Activities by Priority**
- **Data Element:** Priority Level Analysis with SLA Performance
- **Recommended Visual:** Bullet Graph with Target Indicators
- **Data Fields:** PRIORITY_LEVEL, COUNT(SUPPORT_ACTIVITY_ID), SLA_TARGET_HOURS, RESOLUTION_TIME_HOURS
- **Query/Tableau Calculation:** 
  ```
  // Activities by Priority
  COUNT([Support Activity Id])
  
  // SLA Compliance Rate
  SUM(IF [Sla Met] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])
  
  // Average vs Target Resolution Time
  AVG([Resolution Time Hours]) - AVG([Expected Resolution Time Hours])
  
  // Priority Distribution
  COUNT([Support Activity Id]) / TOTAL(COUNT([Support Activity Id]))
  ```
- **Calculations:** Priority counts, SLA performance metrics, variance calculations
- **Interactivity:** 
  - Parameter for SLA target adjustment
  - Filter by support category
  - Color coding for performance indicators
- **Justification:** Bullet graphs effectively show actual vs target performance with clear visual indicators
- **Optimization Tips:** Use parameters for dynamic targets, pre-calculate SLA metrics

---

## **2. Overall Dashboard Design**

### **Layout Suggestions:**
- **Dashboard 1 - Platform Usage & Adoption:**
  - **Header:** KPI cards for total minutes and active users
  - **Left Panel:** Meeting duration analysis and user distribution
  - **Right Panel:** Topic popularity and feature usage trends
  - **Footer:** User engagement histogram and filters

- **Dashboard 2 - Service Reliability & Support:**
  - **Header:** Support KPI summary (total tickets, resolution rate, avg time)
  - **Main Area:** Category distribution and resolution status charts
  - **Side Panel:** Priority analysis and SLA performance
  - **Bottom:** Detailed support metrics and trend analysis

### **Performance Optimization:**
- **Extract Strategy:** 
  - Daily incremental refresh for fact tables
  - Weekly full refresh for dimensions
  - Separate extracts for each major report area
- **Data Source Optimization:**
  - Use the custom SQL queries provided above
  - Implement data source filters for date ranges
  - Create indexed views for frequently joined tables
- **Calculation Optimization:**
  - Move aggregations to data source level where possible
  - Use context filters before dimension filters
  - Minimize LOD calculations by pre-aggregating

### **Color Scheme:**
- **Primary:** Blue (#1f77b4) for main metrics
- **Secondary:** Orange (#ff7f0e) for comparisons
- **Alert:** Red (#d62728) for issues/high priority
- **Success:** Green (#2ca02c) for targets met
- **Neutral:** Gray (#7f7f7f) for supporting elements

### **Typography:**
- **Headers:** Tableau Book, 16pt, Bold
- **Labels:** Tableau Book, 11pt, Regular
- **KPIs:** Tableau Book, 20pt, Bold
- **Details:** Tableau Book, 9pt, Regular

### **Interactive Elements:**

| Element Type | Purpose | Implementation | Data Fields |
|--------------|---------|----------------|-------------|
| **Date Range Filter** | Time period selection | Relative date with custom options | DATE_KEY (Last 30 days, Last Quarter, Last Year) |
| **User Segment Filter** | User characteristic filtering | Multi-select dropdown | PLAN_TYPE, USER_ROLE, GEOGRAPHIC_REGION |
| **Meeting Type Parameter** | Switch analysis focus | Single-select parameter | MEETING_TYPE vs MEETING_CATEGORY |
| **Priority Filter** | Support priority filtering | Single-select with "All" | PRIORITY_LEVEL (High, Medium, Low, All) |
| **Support Category Filter** | Category-based filtering | Hierarchical filter | SUPPORT_CATEGORY → SUPPORT_SUBCATEGORY |
| **Drill-Down Actions** | Navigate to details | Filter actions | USER_KEY → User details, MEETING_KEY → Meeting analysis |
| **Cross-Filter Actions** | Related data highlighting | Highlight actions | Cross-highlight between related visualizations |
| **Reset Dashboard** | Clear all filters | Reset button | Return to default filter state |

### **Data Relationships Summary:**

**For Platform Usage Dashboard:**
- Primary: FACT_MEETING_ACTIVITY → DIM_USER, DIM_MEETING, DIM_DATE
- Secondary: FACT_FEATURE_USAGE → DIM_FEATURE, DIM_USER, DIM_DATE
- Join Type: Inner joins to ensure data quality
- Grain: Meeting-level and feature usage-level analysis

**For Support Dashboard:**
- Primary: FACT_SUPPORT_ACTIVITY → DIM_USER, DIM_SUPPORT_CATEGORY, DIM_DATE
- Join Type: Inner joins with current record filtering
- Grain: Support ticket-level analysis

This enhanced version provides the complete data model, relationships, and specific table usage that directly aligns with the Platform Analytics System requirements outlined in the requirement document.
