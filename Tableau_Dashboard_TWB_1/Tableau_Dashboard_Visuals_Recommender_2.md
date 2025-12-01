_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Tableau Dashboard Visuals Recommender for Service Reliability & Support Report
## *Version*: 2
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender
## Service Reliability & Support Report

## **Data Model and Relationships**

### **Star Schema Design for Support Analytics**

This report focuses on support ticket analysis, service reliability metrics, and customer support performance.

#### **Primary Fact Table:**
- **FACT_SUPPORT_METRICS** (Grain: One record per support ticket)

#### **Supporting Dimension Tables:**
- **DIM_USER** (Customer and user information)
- **DIM_DATE** (Time dimension for temporal analysis)
- **DIM_SUPPORT_CATEGORY** (Support categorization and SLA definitions)

### **Key Relationships for Support Report**

**Primary Data Flow:**
```
FACT_SUPPORT_METRICS (Grain: One record per support ticket)
├── → DIM_USER (USER_DIM_ID) [Many-to-One]
├── → DIM_SUPPORT_CATEGORY (SUPPORT_CATEGORY_ID) [Many-to-One]
├── → DIM_DATE (DATE_ID) [Many-to-One]
```

## **1. Visual Recommendations**

### **Support Overview Section**

#### **Metric 1: Support KPI Dashboard**
- **Data Element:** Key Support Performance Indicators
- **Recommended Visual:** KPI Cards with Status Indicators
- **Data Fields:** 
  - SUPPORT_METRICS_ID from FACT_SUPPORT_METRICS
  - RESOLUTION_STATUS from FACT_SUPPORT_METRICS
  - FIRST_CONTACT_RESOLUTION from FACT_SUPPORT_METRICS
  - SLA_MET from FACT_SUPPORT_METRICS
  - CUSTOMER_SATISFACTION_SCORE from FACT_SUPPORT_METRICS
- **Query/Tableau Calculation:** 
  ```
  // Total Support Tickets
  COUNT([Support Metrics Id])
  
  // Resolution Rate
  SUM(IF [Resolution Status] = 'Resolved' THEN 1 ELSE 0 END) / COUNT([Support Metrics Id])
  
  // First Contact Resolution Rate
  SUM(IF [First Contact Resolution] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Metrics Id])
  
  // SLA Compliance Rate
  SUM(IF [Sla Met] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Metrics Id])
  
  // Average Customer Satisfaction
  AVG([Customer Satisfaction Score])
  
  // Trend Indicator (Month-over-Month)
  (COUNT([Support Metrics Id]) - LOOKUP(COUNT([Support Metrics Id]), -1)) / ABS(LOOKUP(COUNT([Support Metrics Id]), -1))
  ```
- **Calculations:** Resolution rates, SLA compliance, satisfaction averages, trend indicators
- **Interactivity:** 
  - Date range filter with preset options
  - Drill-down to daily/weekly granularity
  - Color coding based on performance thresholds
- **Justification:** KPI cards provide immediate visibility into critical support metrics with performance indicators
- **Optimization Tips:** 
  - Use extract with daily aggregations
  - Pre-calculate rates at source level
  - Implement conditional formatting for status indicators

---

#### **Metric 2: Support Volume and Resolution Trends**
- **Data Element:** Support Ticket Volume and Resolution Time Trends
- **Recommended Visual:** Dual-Axis Line Chart with Bar Overlay
- **Data Fields:** 
  - DATE_ID from FACT_SUPPORT_METRICS
  - SUPPORT_METRICS_ID count
  - RESOLUTION_TIME_HOURS from FACT_SUPPORT_METRICS
  - SLA_TARGET_HOURS from DIM_SUPPORT_CATEGORY
- **Query/Tableau Calculation:** 
  ```
  // Daily Ticket Volume
  COUNT([Support Metrics Id])
  
  // Average Resolution Time
  AVG([Resolution Time Hours])
  
  // SLA Target Reference
  AVG([Sla Target Hours])
  
  // Resolution Time Variance
  AVG([Resolution Time Hours]) - AVG([Sla Target Hours])
  
  // 7-Day Moving Average
  WINDOW_AVG(COUNT([Support Metrics Id]), -6, 0)
  
  // Trend Direction
  (AVG([Resolution Time Hours]) - LOOKUP(AVG([Resolution Time Hours]), -7)) / ABS(LOOKUP(AVG([Resolution Time Hours]), -7))
  ```
- **Calculations:** Moving averages, variance calculations, trend analysis
- **Interactivity:** 
  - Parameter to switch between daily/weekly/monthly views
  - Filter by priority level and support category
  - Reference lines for SLA targets
- **Justification:** Dual-axis shows relationship between volume and performance metrics
- **Optimization Tips:** Use continuous date axis, pre-aggregate by date, implement date partitioning

---

### **Category Analysis Section**

#### **Metric 3: Support Categories and User Distribution**
- **Data Element:** Support Category Analysis with User Impact
- **Recommended Visual:** Nested Bar Chart (Horizontal Stacked)
- **Data Fields:** 
  - SUPPORT_CATEGORY from DIM_SUPPORT_CATEGORY
  - SUPPORT_SUBCATEGORY from DIM_SUPPORT_CATEGORY
  - USER_DIM_ID from FACT_SUPPORT_METRICS
  - PRIORITY_LEVEL from FACT_SUPPORT_METRICS
- **Query/Tableau Calculation:** 
  ```
  // Unique Users per Category
  COUNTD([User Dim Id])
  
  // Category Distribution Percentage
  COUNTD([User Dim Id]) / TOTAL(COUNTD([User Dim Id]))
  
  // Subcategory within Category Percentage
  COUNTD([User Dim Id]) / TOTAL(COUNTD([User Dim Id]) INCLUDE [Support Category])
  
  // Average Priority Score by Category
  AVG(IF [Priority Level] = 'Critical' THEN 4
      ELSEIF [Priority Level] = 'High' THEN 3
      ELSEIF [Priority Level] = 'Medium' THEN 2
      ELSE 1 END)
  
  // Category Impact Score
  COUNTD([User Dim Id]) * AVG([Customer Satisfaction Score])
  ```
- **Calculations:** User counts, percentage distributions, priority scoring, impact metrics
- **Interactivity:** 
  - Hierarchical drill-down from category to subcategory
  - Filter by priority level and date range
  - Sort by user count, priority, or satisfaction
  - Color coding by priority distribution
- **Justification:** Stacked bars show both volume and internal distribution with priority context
- **Optimization Tips:** 
  - Pre-aggregate user counts by category
  - Use extract with category rollups
  - Limit subcategories to top 10 per category

---

#### **Metric 4: Resolution Status Analysis**
- **Data Element:** Support Ticket Resolution Status Distribution
- **Recommended Visual:** Donut Chart with Central KPI and Detail Table
- **Data Fields:** 
  - RESOLUTION_STATUS from FACT_SUPPORT_METRICS
  - SUPPORT_METRICS_ID count
  - RESOLUTION_TIME_HOURS from FACT_SUPPORT_METRICS
  - CUSTOMER_SATISFACTION_SCORE from FACT_SUPPORT_METRICS
- **Query/Tableau Calculation:** 
  ```
  // Status Distribution
  COUNT([Support Metrics Id])
  
  // Status Percentage
  COUNT([Support Metrics Id]) / TOTAL(COUNT([Support Metrics Id]))
  
  // Average Resolution Time by Status
  AVG([Resolution Time Hours])
  
  // Status-based Satisfaction
  AVG([Customer Satisfaction Score])
  
  // Resolution Efficiency Score
  SUM(IF [Resolution Status] IN ('Resolved', 'Closed') THEN 1 ELSE 0 END) / COUNT([Support Metrics Id])
  
  // Pending Tickets Age
  IF [Resolution Status] = 'Open' OR [Resolution Status] = 'In Progress' THEN
    DATEDIFF('day', [Ticket Created Date], TODAY())
  END
  ```
- **Calculations:** Status counts, percentages, time-based metrics, efficiency scores
- **Interactivity:** 
  - Click to filter detailed views by status
  - Hover for detailed metrics and counts
  - Filter by date range and priority
  - Drill-through to ticket details
- **Justification:** Donut chart shows proportional distribution with central summary, table provides detailed breakdown
- **Optimization Tips:** 
  - Use quick table calculations for percentages
  - Limit status categories to active ones
  - Pre-calculate aging metrics

---

### **Performance Analysis Section**

#### **Metric 5: Priority Level Analysis with SLA Performance**
- **Data Element:** Priority-based Performance and SLA Compliance
- **Recommended Visual:** Bullet Graph with Performance Bands
- **Data Fields:** 
  - PRIORITY_LEVEL from FACT_SUPPORT_METRICS
  - SUPPORT_METRICS_ID count
  - RESOLUTION_TIME_HOURS from FACT_SUPPORT_METRICS
  - SLA_TARGET_HOURS from DIM_SUPPORT_CATEGORY
  - SLA_MET from FACT_SUPPORT_METRICS
- **Query/Tableau Calculation:** 
  ```
  // Tickets by Priority
  COUNT([Support Metrics Id])
  
  // SLA Compliance Rate by Priority
  SUM(IF [Sla Met] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Metrics Id])
  
  // Average Resolution Time vs Target
  AVG([Resolution Time Hours])
  AVG([Sla Target Hours])
  
  // Performance Score (0-100)
  (SUM(IF [Sla Met] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Metrics Id])) * 100
  
  // Priority Distribution
  COUNT([Support Metrics Id]) / TOTAL(COUNT([Support Metrics Id]))
  
  // SLA Breach Analysis
  AVG(IF [Sla Met] = FALSE THEN [Sla Breach Hours] ELSE 0 END)
  ```
- **Calculations:** Priority counts, SLA performance, variance analysis, breach metrics
- **Interactivity:** 
  - Parameter for SLA target adjustment (80%, 85%, 90%, 95%)
  - Filter by support category and date range
  - Color coding for performance bands (Red <70%, Yellow 70-90%, Green >90%)
  - Drill-down to individual ticket analysis
- **Justification:** Bullet graphs effectively show actual vs target performance with clear visual performance indicators
- **Optimization Tips:** 
  - Use parameters for dynamic SLA targets
  - Pre-calculate SLA metrics at priority level
  - Implement performance band calculations

---

#### **Metric 6: Support Agent Performance and Workload**
- **Data Element:** Agent Performance Metrics and Capacity Analysis
- **Recommended Visual:** Scatter Plot with Quadrant Analysis
- **Data Fields:** 
  - AGENT_INTERACTIONS_COUNT from FACT_SUPPORT_METRICS
  - RESOLUTION_TIME_HOURS from FACT_SUPPORT_METRICS
  - CUSTOMER_SATISFACTION_SCORE from FACT_SUPPORT_METRICS
  - FIRST_CONTACT_RESOLUTION from FACT_SUPPORT_METRICS
- **Query/Tableau Calculation:** 
  ```
  // Agent Workload (Tickets per Agent)
  COUNT([Support Metrics Id])
  
  // Average Resolution Time per Agent
  AVG([Resolution Time Hours])
  
  // Agent Satisfaction Score
  AVG([Customer Satisfaction Score])
  
  // First Contact Resolution Rate
  SUM(IF [First Contact Resolution] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Metrics Id])
  
  // Agent Efficiency Score
  (AVG([Customer Satisfaction Score]) * 20) + 
  (SUM(IF [First Contact Resolution] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Metrics Id]) * 80)
  
  // Performance Quadrants
  IF AVG([Resolution Time Hours]) <= WINDOW_AVG(AVG([Resolution Time Hours])) AND 
     AVG([Customer Satisfaction Score]) >= WINDOW_AVG(AVG([Customer Satisfaction Score])) 
  THEN "High Performer"
  ELSEIF AVG([Resolution Time Hours]) <= WINDOW_AVG(AVG([Resolution Time Hours])) 
  THEN "Fast Resolver"
  ELSEIF AVG([Customer Satisfaction Score]) >= WINDOW_AVG(AVG([Customer Satisfaction Score])) 
  THEN "Quality Focused"
  ELSE "Needs Improvement"
  END
  ```
- **Calculations:** Agent-level aggregations, efficiency scores, quadrant analysis
- **Interactivity:** 
  - Size by ticket volume, color by satisfaction score
  - Filter by support category and time period
  - Quadrant reference lines for performance benchmarks
  - Drill-through to individual agent performance
- **Justification:** Scatter plot reveals relationships between efficiency and quality metrics with performance segmentation
- **Optimization Tips:** 
  - Aggregate at agent level for performance
  - Use calculated fields for quadrant analysis
  - Implement agent anonymization if required

---

## **2. Overall Dashboard Design**

### **Layout Suggestions:**
- **Header Section (20% height):** 
  - Support KPI cards (total tickets, resolution rate, SLA compliance, satisfaction)
  - Global filters and date range selector
- **Main Content Area (65% height):**
  - **Left Panel (45%):** Category analysis and resolution status charts
  - **Right Panel (55%):** Priority analysis and performance trends
- **Footer Section (15% height):** 
  - Agent performance scatter plot
  - Additional filter controls and export options

### **Performance Optimization:**
- **Extract Strategy:** 
  - Daily incremental refresh for FACT_SUPPORT_METRICS
  - Weekly full refresh for DIM_SUPPORT_CATEGORY
  - Separate extracts for current vs historical analysis
- **Query Optimization:**
  - Use custom SQL with pre-aggregated support metrics
  - Implement ticket status indexing
  - Create materialized views for SLA calculations
- **Calculation Optimization:**
  - Move SLA calculations to data source level
  - Use context filters for date and priority
  - Minimize agent-level LOD calculations

### **Color Scheme:**
- **Primary:** Blue (#1f77b4) for support volume metrics
- **Success:** Green (#2ca02c) for resolved tickets and SLA compliance
- **Warning:** Orange (#ff7f0e) for in-progress and medium priority
- **Critical:** Red (#d62728) for overdue tickets and SLA breaches
- **Neutral:** Gray (#7f7f7f) for pending and background elements

### **Typography:**
- **Dashboard Title:** Tableau Book, 18pt, Bold
- **Section Headers:** Tableau Book, 14pt, Bold
- **Chart Titles:** Tableau Book, 12pt, Bold
- **KPI Values:** Tableau Book, 24pt, Bold
- **Status Indicators:** Tableau Book, 11pt, Bold
- **Labels and Legends:** Tableau Book, 10pt, Regular
- **Tooltips:** Tableau Book, 9pt, Regular

### **Interactive Elements:**

| Element Type | Purpose | Implementation | Data Fields |
|--------------|---------|----------------|-------------|
| **Date Range Filter** | Time period selection | Relative date filter with support-specific ranges | DATE_ID (Last 7 days, Last 30 days, Last Quarter, YTD, Custom) |
| **Priority Filter** | Priority-based filtering | Multi-select with "All" option | PRIORITY_LEVEL (Critical, High, Medium, Low, All) |
| **Support Category Filter** | Category-based analysis | Hierarchical filter with search | SUPPORT_CATEGORY → SUPPORT_SUBCATEGORY |
| **Resolution Status Filter** | Status-based filtering | Multi-select dropdown | RESOLUTION_STATUS (Open, In Progress, Resolved, Closed, Escalated) |
| **SLA Target Parameter** | Performance benchmark adjustment | Slider parameter (70%-99%) | SLA compliance threshold for color coding |
| **Agent Filter** | Agent performance filtering | Multi-select with anonymization option | Agent identifiers (if available) |
| **Customer Segment Filter** | Customer-based analysis | Multi-select dropdown | PLAN_TYPE, ACCOUNT_TYPE, GEOGRAPHIC_REGION |
| **Cross-Filter Actions** | Related data highlighting | Filter actions between charts | USER_DIM_ID, SUPPORT_CATEGORY_ID cross-filtering |
| **Drill-Down Actions** | Navigate to detailed views | URL actions to ticket details | Individual ticket analysis, Agent dashboards |
| **Alert Actions** | Performance notifications | Conditional actions | SLA breach alerts, High priority notifications |
| **Export Actions** | Data extraction and reporting | Download actions | Filtered data export, Performance reports |

### **SLA Performance Indicators:**
- **Green (Target Met):** SLA compliance ≥ 95%
- **Yellow (Warning):** SLA compliance 85-94%
- **Red (Critical):** SLA compliance < 85%
- **Reference Lines:** Industry benchmarks and internal targets

### **Dashboard Alerts and Notifications:**
1. **Critical Priority Overdue:** Tickets exceeding SLA by >4 hours
2. **High Volume Alert:** Daily ticket volume >150% of average
3. **Low Satisfaction Alert:** Daily average satisfaction <3.0
4. **Agent Overload Alert:** Agent handling >20 active tickets
5. **SLA Breach Trend:** 3+ consecutive days of <90% compliance

### **Mobile Optimization:**
- **Responsive Layout:** Automatic adjustment for tablet and mobile devices
- **Touch-Friendly Filters:** Large touch targets for mobile interaction
- **Simplified Mobile View:** Key KPIs and trends only for mobile
- **Offline Capability:** Cached data for offline viewing of key metrics

**Output URL:** https://github.com/DIAscendion/Ascendion/blob/Agent_Output/Tableau_Dashboard_TWB_1
**Pipeline ID:** 9468