_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Tableau Dashboard Visuals Recommender for Service Reliability & Support Report - Updated for FACT_SUPPORT_ACTIVITY
## *Version*: 3
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender
## Service Reliability & Support Report - Updated for FACT_SUPPORT_ACTIVITY

## **Important Note: Table Structure Update**

**Update Request:** The user requested to change from FACT_SUPPORT_METRICS to FACT_SUPPORT_ACTIVITY.

**Current Status:** After reviewing the Snowflake database schema, FACT_SUPPORT_ACTIVITY table does not exist in the current gold layer. The available support-related fact table is FACT_SUPPORT_METRICS.

**Recommendation:** 
1. **Option A:** Continue using FACT_SUPPORT_METRICS (existing table) with all current functionality
2. **Option B:** Request creation of FACT_SUPPORT_ACTIVITY table in the database
3. **Option C:** Use the conceptual design below assuming FACT_SUPPORT_ACTIVITY structure

**This document proceeds with Option C - Conceptual FACT_SUPPORT_ACTIVITY design while noting the table availability issue.**

---

## **Data Model and Relationships**

### **Star Schema Design for Support Activity Analytics**

This report focuses on support activity analysis, service reliability metrics, and customer support performance tracking.

#### **Primary Fact Table:**
- **FACT_SUPPORT_ACTIVITY** (Grain: One record per support activity/interaction)
  - *Note: This table currently does not exist in the database. Using conceptual structure based on FACT_SUPPORT_METRICS.*

#### **Supporting Dimension Tables:**
- **DIM_USER** (Customer and user information)
- **DIM_DATE** (Time dimension for temporal analysis)
- **DIM_SUPPORT_CATEGORY** (Support categorization and SLA definitions)

### **Conceptual FACT_SUPPORT_ACTIVITY Structure**

Assuming FACT_SUPPORT_ACTIVITY would contain activity-focused metrics:

```sql
-- Conceptual structure for FACT_SUPPORT_ACTIVITY
CREATE TABLE FACT_SUPPORT_ACTIVITY (
    SUPPORT_ACTIVITY_ID NUMBER(18,0),
    DATE_ID DATE,
    SUPPORT_CATEGORY_ID NUMBER(18,0),
    USER_DIM_ID NUMBER(18,0),
    ACTIVITY_ID VARCHAR(16777216),
    ACTIVITY_TYPE VARCHAR(50), -- 'Ticket_Created', 'Response_Sent', 'Escalation', 'Resolution', etc.
    ACTIVITY_TIMESTAMP TIMESTAMP_NTZ(9),
    TICKET_ID VARCHAR(16777216),
    AGENT_ID VARCHAR(100),
    ACTIVITY_DURATION_MINUTES NUMBER(10,2),
    ACTIVITY_STATUS VARCHAR(20),
    INTERACTION_CHANNEL VARCHAR(20), -- 'Email', 'Chat', 'Phone', 'Portal'
    ACTIVITY_OUTCOME VARCHAR(50),
    CUSTOMER_EFFORT_SCORE NUMBER(1,0),
    ACTIVITY_COST NUMBER(10,2),
    FOLLOW_UP_REQUIRED BOOLEAN,
    KNOWLEDGE_ARTICLE_USED VARCHAR(100),
    ESCALATION_LEVEL NUMBER(1,0),
    CUSTOMER_SATISFACTION_RATING NUMBER(1,0),
    RESOLUTION_PROVIDED BOOLEAN,
    LOAD_DATE DATE,
    UPDATE_DATE DATE,
    SOURCE_SYSTEM VARCHAR(100)
);
```

### **Key Relationships for Support Activity Report**

**Primary Data Flow:**
```
FACT_SUPPORT_ACTIVITY (Grain: One record per support activity)
├── → DIM_USER (USER_DIM_ID) [Many-to-One]
├── → DIM_SUPPORT_CATEGORY (SUPPORT_CATEGORY_ID) [Many-to-One]
├── → DIM_DATE (DATE_ID) [Many-to-One]
```

## **1. Visual Recommendations**

### **Support Activity Overview Section**

#### **Metric 1: Support Activity KPI Dashboard**
- **Data Element:** Key Support Activity Performance Indicators
- **Recommended Visual:** KPI Cards with Status Indicators
- **Data Fields:** 
  - SUPPORT_ACTIVITY_ID from FACT_SUPPORT_ACTIVITY
  - ACTIVITY_TYPE from FACT_SUPPORT_ACTIVITY
  - ACTIVITY_STATUS from FACT_SUPPORT_ACTIVITY
  - RESOLUTION_PROVIDED from FACT_SUPPORT_ACTIVITY
  - CUSTOMER_SATISFACTION_RATING from FACT_SUPPORT_ACTIVITY
  - CUSTOMER_EFFORT_SCORE from FACT_SUPPORT_ACTIVITY
- **Query/Tableau Calculation:** 
  ```
  // Total Support Activities
  COUNT([Support Activity Id])
  
  // Resolution Activity Rate
  SUM(IF [Resolution Provided] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])
  
  // Average Customer Effort Score
  AVG([Customer Effort Score])
  
  // Activity Completion Rate
  SUM(IF [Activity Status] = 'Completed' THEN 1 ELSE 0 END) / COUNT([Support Activity Id])
  
  // Average Customer Satisfaction
  AVG([Customer Satisfaction Rating])
  
  // Activity Volume Trend (Day-over-Day)
  (COUNT([Support Activity Id]) - LOOKUP(COUNT([Support Activity Id]), -1)) / ABS(LOOKUP(COUNT([Support Activity Id]), -1))
  
  // Unique Tickets Handled
  COUNTD([Ticket Id])
  ```
- **Calculations:** Activity rates, satisfaction averages, effort scores, trend indicators
- **Interactivity:** 
  - Date range filter with preset options
  - Activity type filter (multi-select)
  - Drill-down to hourly/daily granularity
  - Color coding based on performance thresholds
- **Justification:** KPI cards provide immediate visibility into critical support activity metrics with performance indicators
- **Optimization Tips:** 
  - Use extract with daily aggregations
  - Pre-calculate rates at source level
  - Implement conditional formatting for status indicators

---

#### **Metric 2: Support Activity Volume and Response Time Trends**
- **Data Element:** Support Activity Volume and Response Time Analysis
- **Recommended Visual:** Dual-Axis Line Chart with Bar Overlay
- **Data Fields:** 
  - DATE_ID from FACT_SUPPORT_ACTIVITY
  - SUPPORT_ACTIVITY_ID count
  - ACTIVITY_DURATION_MINUTES from FACT_SUPPORT_ACTIVITY
  - ACTIVITY_TYPE from FACT_SUPPORT_ACTIVITY
  - INTERACTION_CHANNEL from FACT_SUPPORT_ACTIVITY
- **Query/Tableau Calculation:** 
  ```
  // Daily Activity Volume
  COUNT([Support Activity Id])
  
  // Average Activity Duration
  AVG([Activity Duration Minutes])
  
  // Response Activities (First Response)
  COUNT(IF [Activity Type] = 'Response_Sent' THEN [Support Activity Id] END)
  
  // Activity Duration by Type
  AVG(IF [Activity Type] = 'Ticket_Created' THEN [Activity Duration Minutes] END)
  
  // 7-Day Moving Average Volume
  WINDOW_AVG(COUNT([Support Activity Id]), -6, 0)
  
  // Channel Distribution
  COUNT([Support Activity Id]) / TOTAL(COUNT([Support Activity Id]))
  
  // Peak Activity Hours
  DATEPART('hour', [Activity Timestamp])
  ```
- **Calculations:** Moving averages, duration analysis, channel distribution, time-based patterns
- **Interactivity:** 
  - Parameter to switch between daily/weekly/monthly views
  - Filter by activity type and interaction channel
  - Reference lines for target response times
  - Drill-down by hour of day analysis
- **Justification:** Dual-axis shows relationship between activity volume and efficiency metrics
- **Optimization Tips:** Use continuous date axis, pre-aggregate by date and activity type, implement time partitioning

---

### **Activity Type Analysis Section**

#### **Metric 3: Support Activity Types and Channel Distribution**
- **Data Element:** Activity Type Analysis with Channel Breakdown
- **Recommended Visual:** Nested Bar Chart (Horizontal Stacked)
- **Data Fields:** 
  - ACTIVITY_TYPE from FACT_SUPPORT_ACTIVITY
  - INTERACTION_CHANNEL from FACT_SUPPORT_ACTIVITY
  - SUPPORT_ACTIVITY_ID count
  - ACTIVITY_DURATION_MINUTES from FACT_SUPPORT_ACTIVITY
  - CUSTOMER_EFFORT_SCORE from FACT_SUPPORT_ACTIVITY
- **Query/Tableau Calculation:** 
  ```
  // Activities per Type
  COUNT([Support Activity Id])
  
  // Activity Type Distribution
  COUNT([Support Activity Id]) / TOTAL(COUNT([Support Activity Id]))
  
  // Channel within Activity Type
  COUNT([Support Activity Id]) / TOTAL(COUNT([Support Activity Id]) INCLUDE [Activity Type])
  
  // Average Effort Score by Activity Type
  AVG([Customer Effort Score])
  
  // Activity Efficiency Score
  AVG([Activity Duration Minutes]) / COUNT([Support Activity Id])
  
  // Channel Preference Index
  COUNT([Support Activity Id]) / WINDOW_SUM(COUNT([Support Activity Id]))
  ```
- **Calculations:** Activity counts, percentage distributions, efficiency metrics, channel analysis
- **Interactivity:** 
  - Hierarchical drill-down from activity type to channel
  - Filter by date range and customer segment
  - Sort by volume, duration, or effort score
  - Color coding by efficiency levels
- **Justification:** Stacked bars show both volume and internal distribution with channel context
- **Optimization Tips:** 
  - Pre-aggregate activity counts by type and channel
  - Use extract with activity type rollups
  - Limit channels to active ones

---

#### **Metric 4: Activity Outcome Analysis**
- **Data Element:** Support Activity Outcome Distribution
- **Recommended Visual:** Donut Chart with Central KPI and Detail Table
- **Data Fields:** 
  - ACTIVITY_OUTCOME from FACT_SUPPORT_ACTIVITY
  - SUPPORT_ACTIVITY_ID count
  - RESOLUTION_PROVIDED from FACT_SUPPORT_ACTIVITY
  - CUSTOMER_SATISFACTION_RATING from FACT_SUPPORT_ACTIVITY
  - FOLLOW_UP_REQUIRED from FACT_SUPPORT_ACTIVITY
- **Query/Tableau Calculation:** 
  ```
  // Outcome Distribution
  COUNT([Support Activity Id])
  
  // Outcome Percentage
  COUNT([Support Activity Id]) / TOTAL(COUNT([Support Activity Id]))
  
  // Resolution Rate by Outcome
  SUM(IF [Resolution Provided] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])
  
  // Outcome-based Satisfaction
  AVG([Customer Satisfaction Rating])
  
  // Follow-up Required Rate
  SUM(IF [Follow Up Required] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])
  
  // Activity Success Score
  (SUM(IF [Resolution Provided] = TRUE THEN 1 ELSE 0 END) + 
   SUM(IF [Follow Up Required] = FALSE THEN 1 ELSE 0 END)) / (COUNT([Support Activity Id]) * 2)
  ```
- **Calculations:** Outcome counts, percentages, success metrics, satisfaction correlation
- **Interactivity:** 
  - Click to filter detailed views by outcome
  - Hover for detailed metrics and counts
  - Filter by activity type and date range
  - Drill-through to activity details
- **Justification:** Donut chart shows proportional distribution with central summary, table provides detailed breakdown
- **Optimization Tips:** 
  - Use quick table calculations for percentages
  - Pre-calculate success metrics
  - Limit outcome categories to meaningful ones

---

### **Performance Analysis Section**

#### **Metric 5: Agent Activity Performance Analysis**
- **Data Element:** Agent Performance and Activity Efficiency
- **Recommended Visual:** Bullet Graph with Performance Bands
- **Data Fields:** 
  - AGENT_ID from FACT_SUPPORT_ACTIVITY
  - SUPPORT_ACTIVITY_ID count
  - ACTIVITY_DURATION_MINUTES from FACT_SUPPORT_ACTIVITY
  - CUSTOMER_SATISFACTION_RATING from FACT_SUPPORT_ACTIVITY
  - RESOLUTION_PROVIDED from FACT_SUPPORT_ACTIVITY
- **Query/Tableau Calculation:** 
  ```
  // Activities per Agent
  COUNT([Support Activity Id])
  
  // Agent Resolution Rate
  SUM(IF [Resolution Provided] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])
  
  // Average Activity Duration per Agent
  AVG([Activity Duration Minutes])
  
  // Agent Satisfaction Score
  AVG([Customer Satisfaction Rating])
  
  // Agent Performance Score (0-100)
  ((SUM(IF [Resolution Provided] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])) * 50) +
  (AVG([Customer Satisfaction Rating]) * 10)
  
  // Activity Efficiency (Activities per Hour)
  COUNT([Support Activity Id]) / (SUM([Activity Duration Minutes]) / 60)
  
  // Target Performance Benchmark
  // Parameter: [Agent Performance Target] (default 75)
  [Agent Performance Target]
  ```
- **Calculations:** Agent-level metrics, performance scoring, efficiency analysis
- **Interactivity:** 
  - Parameter for performance target adjustment (60-95)
  - Filter by activity type and date range
  - Color coding for performance bands (Red <60, Yellow 60-80, Green >80)
  - Drill-down to individual agent activity analysis
- **Justification:** Bullet graphs effectively show actual vs target performance with clear visual performance indicators
- **Optimization Tips:** 
  - Use parameters for dynamic performance targets
  - Pre-calculate agent metrics
  - Implement performance band calculations

---

#### **Metric 6: Activity Cost and ROI Analysis**
- **Data Element:** Activity Cost Analysis and Return on Investment
- **Recommended Visual:** Scatter Plot with Trend Lines
- **Data Fields:** 
  - ACTIVITY_COST from FACT_SUPPORT_ACTIVITY
  - ACTIVITY_DURATION_MINUTES from FACT_SUPPORT_ACTIVITY
  - CUSTOMER_SATISFACTION_RATING from FACT_SUPPORT_ACTIVITY
  - RESOLUTION_PROVIDED from FACT_SUPPORT_ACTIVITY
  - ACTIVITY_TYPE from FACT_SUPPORT_ACTIVITY
- **Query/Tableau Calculation:** 
  ```
  // Total Activity Cost
  SUM([Activity Cost])
  
  // Cost per Resolution
  SUM([Activity Cost]) / SUM(IF [Resolution Provided] = TRUE THEN 1 ELSE 0 END)
  
  // Cost Efficiency Score
  AVG([Customer Satisfaction Rating]) / AVG([Activity Cost])
  
  // ROI Calculation
  (AVG([Customer Satisfaction Rating]) * 100) - SUM([Activity Cost])
  
  // Cost per Minute
  SUM([Activity Cost]) / SUM([Activity Duration Minutes])
  
  // Activity Value Score
  IF [Resolution Provided] = TRUE AND [Customer Satisfaction Rating] >= 4 
  THEN SUM([Activity Cost]) * 1.5
  ELSE SUM([Activity Cost]) * 0.8
  END
  ```
- **Calculations:** Cost analysis, ROI metrics, efficiency ratios, value scoring
- **Interactivity:** 
  - Size by activity volume, color by satisfaction rating
  - Filter by activity type and cost range
  - Trend lines for cost vs satisfaction correlation
  - Drill-through to cost breakdown analysis
- **Justification:** Scatter plot reveals relationships between cost, efficiency, and satisfaction metrics
- **Optimization Tips:** 
  - Aggregate at activity type level for performance
  - Use calculated fields for ROI analysis
  - Implement cost threshold parameters

---

## **2. Overall Dashboard Design**

### **Layout Suggestions:**
- **Header Section (20% height):** 
  - Support Activity KPI cards (total activities, resolution rate, avg satisfaction, effort score)
  - Global filters and date range selector
- **Main Content Area (65% height):**
  - **Left Panel (45%):** Activity type analysis and outcome distribution charts
  - **Right Panel (55%):** Performance trends and agent analysis
- **Footer Section (15% height):** 
  - Cost analysis scatter plot
  - Additional filter controls and export options

### **Performance Optimization:**
- **Extract Strategy:** 
  - Hourly incremental refresh for FACT_SUPPORT_ACTIVITY (high-frequency data)
  - Daily full refresh for DIM_SUPPORT_CATEGORY
  - Separate extracts for real-time vs historical analysis
- **Query Optimization:**
  - Use custom SQL with pre-aggregated activity metrics
  - Implement activity type and timestamp indexing
  - Create materialized views for agent performance calculations
- **Calculation Optimization:**
  - Move cost calculations to data source level
  - Use context filters for date and activity type
  - Minimize agent-level LOD calculations

### **Color Scheme:**
- **Primary:** Blue (#1f77b4) for activity volume metrics
- **Success:** Green (#2ca02c) for resolved activities and high satisfaction
- **Warning:** Orange (#ff7f0e) for in-progress and medium effort
- **Critical:** Red (#d62728) for high-cost activities and low satisfaction
- **Neutral:** Gray (#7f7f7f) for pending and background elements
- **Activity Types:** Categorical palette (Tableau 10)

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
| **Date Range Filter** | Time period selection | Relative date filter with activity-specific ranges | DATE_ID (Last 24 hours, Last 7 days, Last 30 days, Custom) |
| **Activity Type Filter** | Activity-based filtering | Multi-select with "All" option | ACTIVITY_TYPE (Ticket_Created, Response_Sent, Escalation, Resolution, etc.) |
| **Channel Filter** | Channel-based analysis | Multi-select dropdown | INTERACTION_CHANNEL (Email, Chat, Phone, Portal, All) |
| **Agent Filter** | Agent performance filtering | Multi-select with search capability | AGENT_ID (with anonymization option) |
| **Outcome Filter** | Outcome-based filtering | Multi-select dropdown | ACTIVITY_OUTCOME (Resolved, Escalated, Pending, Closed) |
| **Performance Target Parameter** | Benchmark adjustment | Slider parameter (60-95) | Performance threshold for color coding |
| **Cost Range Filter** | Cost-based analysis | Range slider | ACTIVITY_COST (Low, Medium, High cost activities) |
| **Customer Segment Filter** | Customer-based analysis | Multi-select dropdown | USER attributes from DIM_USER |
| **Cross-Filter Actions** | Related data highlighting | Filter actions between charts | TICKET_ID, AGENT_ID cross-filtering |
| **Drill-Down Actions** | Navigate to detailed views | URL actions to activity details | Individual activity analysis, Agent dashboards |
| **Alert Actions** | Performance notifications | Conditional actions | High-cost alerts, Low satisfaction notifications |
| **Export Actions** | Data extraction and reporting | Download actions | Filtered data export, Performance reports |

### **Activity Performance Indicators:**
- **Green (Excellent):** Satisfaction ≥ 4.5, Resolution provided, Low effort
- **Yellow (Good):** Satisfaction 3.5-4.4, Partial resolution
- **Red (Needs Improvement):** Satisfaction < 3.5, No resolution, High effort
- **Reference Lines:** Industry benchmarks and internal targets

### **Dashboard Alerts and Notifications:**
1. **High-Cost Activity Alert:** Activities exceeding $50 cost threshold
2. **Low Satisfaction Alert:** Activities with satisfaction rating < 2.0
3. **High Effort Alert:** Activities with effort score > 4.0
4. **Agent Overload Alert:** Agent handling >30 activities per day
5. **Resolution Rate Alert:** Daily resolution rate < 70%

### **Mobile Optimization:**
- **Responsive Layout:** Automatic adjustment for tablet and mobile devices
- **Touch-Friendly Filters:** Large touch targets for mobile interaction
- **Simplified Mobile View:** Key KPIs and trends only for mobile
- **Real-time Updates:** Live data refresh for activity monitoring

### **Data Quality Considerations:**
- **Missing Data Handling:** Clear indicators for incomplete activity records
- **Data Validation:** Alerts for unusual activity patterns or data anomalies
- **Audit Trail:** Track changes in activity status and outcomes

**Note:** This design assumes the creation of FACT_SUPPORT_ACTIVITY table. If using existing FACT_SUPPORT_METRICS, field mappings would need to be adjusted accordingly.

**Output URL:** https://github.com/DIAscendion/Ascendion/blob/Agent_Output/Tableau_Dashboard_TWB_1
**Pipeline ID:** 9468