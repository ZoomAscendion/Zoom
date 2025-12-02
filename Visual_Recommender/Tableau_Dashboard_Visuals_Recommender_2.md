_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Service Reliability & Support Report - Tableau Dashboard Visual Recommendations
## *Version*: 2
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender
## Service Reliability & Support Report

### **Business Objective**
Analyze platform stability and customer support interactions to improve service quality and reduce ticket volume.

### **Data Model Overview**
**Primary Facts:**
- FACT_SUPPORT_ACTIVITY

**Primary Dimensions:**
- DIM_USER
- DIM_SUPPORT_CATEGORY
- DIM_DATE

**Key Relationships:**
- FACT_SUPPORT_ACTIVITY → DIM_USER (USER_KEY)
- FACT_SUPPORT_ACTIVITY → DIM_SUPPORT_CATEGORY (SUPPORT_CATEGORY_KEY)
- FACT_SUPPORT_ACTIVITY → DIM_DATE (DATE_KEY)

---

## **1. Visual Recommendations**

### **Visual 1: Number of Users by Support Category and Subcategory**
- **Data Element:** User distribution across different support categories and subcategories
- **Query / Tableau Calculation:** `COUNTD([User Key])` by Support Category and Subcategory
- **Recommended Visual:** Horizontal Stacked Bar Chart
- **Data Fields:**
  - Rows: Support_Category
  - Columns: COUNTD(User_Key)
  - Color: Support_Subcategory
  - Detail: Support_Subcategory
- **Calculations:**
  - Unique Users per Category: `COUNTD([User Key])`
  - Category Distribution %: `COUNTD([User Key]) / {FIXED : COUNTD([User Key])}`
  - Users per Subcategory: `{FIXED [Support Category], [Support Subcategory]: COUNTD([User Key])}`
- **Interactivity:**
  - Support category filter
  - Date range filter
  - Priority level filter
  - Drill down from category to subcategory
  - Tooltip showing percentage and user count
- **Justification:** Stacked bars show both total volume per category and subcategory breakdown simultaneously
- **Optimization Tips:**
  - Use extract for COUNTD performance
  - Create hierarchy for Category → Subcategory drilling
  - Index support category fields in data source

### **Visual 2: Number of Support Activities by Resolution Status**
- **Data Element:** Support ticket volume by resolution status
- **Query / Tableau Calculation:** `COUNT([Support Activity Id])` by Resolution Status
- **Recommended Visual:** Donut Chart with KPI center
- **Data Fields:**
  - Angle: COUNT(Support_Activity_ID)
  - Color: Resolution_Status
  - Detail: Resolution_Status
- **Calculations:**
  - Total Support Activities: `COUNT([Support Activity Id])`
  - Resolution Rate: `SUM(IF [Resolution Status] = 'Resolved' THEN 1 ELSE 0 END) / COUNT([Support Activity Id])`
  - Pending Activities: `SUM(IF [Resolution Status] = 'Open' OR [Resolution Status] = 'In Progress' THEN 1 ELSE 0 END)`
  - Average Resolution Time: `AVG([Resolution Time Hours])`
- **Interactivity:**
  - Date range filter
  - Priority level filter
  - Support category filter
  - Click to filter other views by status
  - Hover for detailed metrics
- **Justification:** Donut charts effectively show proportional relationships with space for central KPI display
- **Optimization Tips:**
  - Pre-calculate resolution status groupings
  - Use parameters for dynamic status grouping
  - Create calculated field for status categories

### **Visual 3: Number of Support Activities by Priority Level**
- **Data Element:** Support ticket distribution by priority levels
- **Query / Tableau Calculation:** `COUNT([Support Activity Id])` by Priority Level
- **Recommended Visual:** Bullet Graph with target lines
- **Data Fields:**
  - Rows: Priority_Level
  - Columns: COUNT(Support_Activity_ID)
  - Reference Lines: Target thresholds for each priority
- **Calculations:**
  - Activities by Priority: `COUNT([Support Activity Id])`
  - Priority Target: Parameters for each priority level target
  - SLA Compliance Rate: `AVG(IF [Sla Met] = TRUE THEN 1 ELSE 0 END)`
  - Escalation Rate: `AVG([Escalation Count])`
- **Interactivity:**
  - Priority level filter
  - Date range filter
  - Department filter
  - Parameter controls for target adjustment
  - Drill through to detailed ticket list
- **Justification:** Bullet graphs show actual vs target performance clearly for each priority level
- **Optimization Tips:**
  - Use parameters for dynamic target setting
  - Create priority level hierarchy (Critical → High → Medium → Low)
  - Pre-aggregate by priority and date


## **2. Overall Dashboard Design**

### **Layout Suggestions**
- **Top Row:** KPI Cards showing key support metrics (FCR Rate, Avg Resolution Time, Customer Satisfaction, SLA Compliance)
- **Second Row:** Support Ticket Trends (left 2/3), Resolution Status Donut Chart (right 1/3)
- **Third Row:** Users by Support Category (left), Activities by Priority (right)
- **Bottom Row:** Support Category Performance Matrix (full width)
- **Filter Panel:** Top horizontal filter bar with Date Range, Priority, Category filters

### **Performance Optimization**
- **Extract Strategy:**
  - Daily incremental refresh for support activity facts
  - Full refresh weekly for support category dimensions
  - Aggregate extracts for trend analysis
- **Filter Optimization:**
  - Use context filters for date ranges
  - Create relevant values only for category filters
  - Index priority and status fields
- **Data Prep Recommendations:**
  - Pre-calculate support metrics at category level
  - Create support performance score dimension
  - Optimize date fields for time series analysis

### **Color Scheme**
- **Primary Colors:** 
  - Blue (#1f77b4) for general metrics
  - Green (#2ca02c) for positive performance (resolved, high satisfaction)
  - Red (#d62728) for issues (overdue, low satisfaction)
  - Orange (#ff7f0e) for warnings (approaching SLA breach)
- **Priority Colors:**
  - Critical: Dark Red (#8B0000)
  - High: Red (#FF0000)
  - Medium: Orange (#FFA500)
  - Low: Green (#32CD32)
- **Status Colors:**
  - Resolved: Green (#2ca02c)
  - In Progress: Blue (#1f77b4)
  - Open: Orange (#ff7f0e)
  - Escalated: Red (#d62728)

### **Typography**
- **Headers:** Tableau Book Bold, 14pt for dashboard title, 12pt for sheet titles
- **Body Text:** Tableau Book Regular, 10pt for labels and axis
- **KPI Numbers:** Tableau Book Bold, 18pt for main metrics
- **Performance Indicators:** Tableau Book Medium, 11pt for status text

### **Interactive Elements**

| Element Type | Purpose | Implementation | Target Sheets |
|--------------|---------|----------------|---------------|
| Date Range Filter | Time period analysis | Relative date filter with presets | All sheets |
| Priority Filter | Filter by ticket priority | Multi-select dropdown | All sheets |
| Category Filter | Filter by support category | Hierarchical filter (Category → Subcategory) | All sheets |
| Status Filter | Filter by resolution status | Single/multi-select | Status-related sheets |
| Department Filter | Filter by responsible department | Dropdown filter | All sheets |
| SLA Target Parameter | Adjust SLA thresholds | Slider parameter | Performance metrics |
| Time Granularity | Change time aggregation | Parameter (Day/Week/Month) | Trend charts |
| Drill Down Action | Navigate category hierarchy | Filter action on category selection | Category charts |
| Highlight Action | Cross-highlight related data | Highlight action between sheets | All sheets |
| Filter Action | Cross-filter dashboard | Filter action on status/priority | All sheets |

### **Dashboard Actions Configuration**
- **Filter Actions:** Click on support category to filter all related views
- **Highlight Actions:** Hover over priority levels to highlight across charts
- **Parameter Actions:** Click on time periods to update granularity
- **URL Actions:** Click on KPI cards to open detailed ticket management system

### **Alerting and Monitoring**
- **SLA Breach Alerts:** Visual indicators when SLA compliance drops below threshold
- **Volume Spike Detection:** Highlight unusual increases in ticket volume
- **Performance Degradation:** Color coding for declining metrics
- **Data Freshness Indicators:** Show last refresh time and data currency

### **Performance Monitoring**
- Monitor dashboard load times (target: <8 seconds)
- Track extract refresh performance and failures
- Monitor concurrent user access during peak hours
- Set up automated alerts for data quality issues

### **Potential Pitfalls & Mitigation**
- **High Cardinality in Support Categories:** Use grouping and Top N filtering for subcategories
- **Complex Time-based Calculations:** Pre-calculate rolling averages in data prep
- **Multiple Date Fields:** Clearly distinguish between open date, close date, and target date
- **SLA Calculations:** Ensure business hour calculations are accurate and timezone-aware
- **Customer Satisfaction Bias:** Account for response rate and potential bias in satisfaction scores
- **Real-time Requirements:** Balance between data freshness and performance (consider 15-minute refresh cycles)

### **Business Intelligence Integration**
- **Automated Reporting:** Schedule daily/weekly reports for management
- **Threshold Monitoring:** Set up automated alerts for KPI breaches
- **Trend Analysis:** Implement forecasting for ticket volume planning
- **Root Cause Analysis:** Link to detailed ticket data for investigation
- **Performance Benchmarking:** Compare against industry standards and historical performance
