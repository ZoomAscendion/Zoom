_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Tableau Dashboard Visuals Recommender for Platform Analytics System Reports with Complete Table Relationships
## *Version*: 2
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender
## Platform Analytics System - Reports & Requirements

## **Data Model Overview**

### **Complete Table Structure and Relationships**

#### **Dimension Tables:**
1. **DIM_DATE** - Time dimension with date hierarchies (18 columns)
2. **DIM_USER** - User information and demographics (21 columns)
3. **DIM_MEETING** - Meeting characteristics and categories (15 columns)
4. **DIM_FEATURE** - Platform features and capabilities (14 columns)
5. **DIM_LICENSE** - License types and pricing information (20 columns)
6. **DIM_SUPPORT_CATEGORY** - Support categorization and SLA definitions (15 columns)

#### **Fact Tables:**
1. **FACT_MEETING_ACTIVITY** - Meeting events and participation metrics (30 columns)
2. **FACT_FEATURE_USAGE** - Feature utilization and performance data (23 columns)
3. **FACT_REVENUE_ACTIVITY** - Financial transactions and revenue metrics (32 columns)
4. **FACT_SUPPORT_ACTIVITY** - Support ticket and resolution data (30 columns)

#### **Audit Table:**
1. **GO_AUDIT_LOG** - System process monitoring and data quality tracking (26 columns)

### **Table Relationships and Join Structure**

#### **Primary Relationships:**

**FACT_MEETING_ACTIVITY Relationships:**
- FACT_MEETING_ACTIVITY.USER_KEY → DIM_USER.USER_KEY (Many-to-One)
- FACT_MEETING_ACTIVITY.MEETING_KEY → DIM_MEETING.MEETING_KEY (Many-to-One)
- FACT_MEETING_ACTIVITY.DATE_KEY → DIM_DATE.DATE_KEY (Many-to-One)
- FACT_MEETING_ACTIVITY.FEATURE_KEY → DIM_FEATURE.FEATURE_KEY (Many-to-One)

**FACT_FEATURE_USAGE Relationships:**
- FACT_FEATURE_USAGE.USER_KEY → DIM_USER.USER_KEY (Many-to-One)
- FACT_FEATURE_USAGE.FEATURE_KEY → DIM_FEATURE.FEATURE_KEY (Many-to-One)
- FACT_FEATURE_USAGE.DATE_KEY → DIM_DATE.DATE_KEY (Many-to-One)
- FACT_FEATURE_USAGE.MEETING_KEY → DIM_MEETING.MEETING_KEY (Many-to-One)

**FACT_REVENUE_ACTIVITY Relationships:**
- FACT_REVENUE_ACTIVITY.USER_KEY → DIM_USER.USER_KEY (Many-to-One)
- FACT_REVENUE_ACTIVITY.LICENSE_KEY → DIM_LICENSE.LICENSE_KEY (Many-to-One)
- FACT_REVENUE_ACTIVITY.DATE_KEY → DIM_DATE.DATE_KEY (Many-to-One)

**FACT_SUPPORT_ACTIVITY Relationships:**
- FACT_SUPPORT_ACTIVITY.USER_KEY → DIM_USER.USER_KEY (Many-to-One)
- FACT_SUPPORT_ACTIVITY.SUPPORT_CATEGORY_KEY → DIM_SUPPORT_CATEGORY.SUPPORT_CATEGORY_KEY (Many-to-One)
- FACT_SUPPORT_ACTIVITY.DATE_KEY → DIM_DATE.DATE_KEY (Many-to-One)

### **Detailed Table Schemas**

#### **DIM_DATE Table:**
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| DATE_KEY | DATE | Primary key for date dimension |
| DATE_ID | NUMBER(18,0) | Unique identifier |
| DATE_VALUE | DATE | Actual date value |
| YEAR | NUMBER(4,0) | Year component |
| QUARTER | NUMBER(2,0) | Quarter component |
| MONTH | NUMBER(2,0) | Month component |
| MONTH_NAME | VARCHAR(3) | Month abbreviation |
| DAY_OF_MONTH | NUMBER(2,0) | Day of month |
| DAY_OF_WEEK | NUMBER(2,0) | Day of week number |
| DAY_NAME | VARCHAR(3) | Day abbreviation |
| IS_WEEKEND | BOOLEAN | Weekend indicator |
| IS_HOLIDAY | BOOLEAN | Holiday indicator |
| FISCAL_YEAR | NUMBER(5,0) | Fiscal year |
| FISCAL_QUARTER | NUMBER(1,0) | Fiscal quarter |
| WEEK_OF_YEAR | NUMBER(2,0) | Week number |

#### **DIM_USER Table:**
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| USER_KEY | VARCHAR(32) | Primary key for user dimension |
| USER_DIM_ID | NUMBER(18,0) | Unique identifier |
| USER_ID | VARCHAR(16777216) | User identifier |
| USER_NAME | VARCHAR(16777216) | User display name |
| EMAIL_DOMAIN | VARCHAR(16777216) | Email domain |
| COMPANY | VARCHAR(16777216) | Company name |
| PLAN_TYPE | VARCHAR(10) | Subscription plan type |
| PLAN_CATEGORY | VARCHAR(7) | Plan category |
| REGISTRATION_DATE | DATE | User registration date |
| USER_STATUS | VARCHAR(8) | Current user status |
| GEOGRAPHIC_REGION | VARCHAR(7) | Geographic region |
| INDUSTRY_SECTOR | VARCHAR(7) | Industry classification |
| USER_ROLE | VARCHAR(7) | User role |
| ACCOUNT_TYPE | VARCHAR(10) | Account type |
| LANGUAGE_PREFERENCE | VARCHAR(7) | Preferred language |
| IS_CURRENT_RECORD | BOOLEAN | Current record indicator |

### **Key Tableau Calculations**

#### **Meeting Analytics Calculations:**
```
// Total Meeting Duration
SUM([Duration Minutes])

// Average Meeting Duration by Type
{FIXED [Meeting Type] : AVG([Duration Minutes])}

// Meeting Participation Rate
SUM([Total Join Time Minutes]) / (SUM([Duration Minutes]) * AVG([Participant Count]))

// Meeting Quality Score
AVG([Meeting Quality Score])

// Peak Utilization Hours
{FIXED DATEPART('hour', [Start Time]) : COUNT([Meeting Activity Id])}
```

#### **Feature Usage Calculations:**
```
// Feature Adoption Rate
COUNTD([User Key]) / {FIXED : COUNTD([User Key])}

// Feature Usage Intensity
SUM([Usage Count]) / COUNTD([User Key])

// Feature Performance Score
AVG([Feature Performance Score])

// Feature Success Rate
AVG([Success Rate])

// Concurrent Feature Usage
AVG([Concurrent Features Count])
```

#### **Support Analytics Calculations:**
```
// First Contact Resolution Rate
SUM(IF [First Contact Resolution Flag] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])

// SLA Compliance Rate
SUM(IF [Sla Met] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])

// Average Resolution Time
AVG([Resolution Time Hours])

// Escalation Rate
SUM([Escalation Count]) / COUNT([Support Activity Id])

// Customer Satisfaction Score
AVG([Customer Satisfaction Score])
```

#### **Revenue Analytics Calculations:**
```
// Monthly Recurring Revenue (MRR)
SUM([Mrr Impact])

// Annual Recurring Revenue (ARR)
SUM([Arr Impact])

// Customer Lifetime Value
AVG([Customer Lifetime Value])

// Revenue Growth Rate
(SUM([Net Revenue Amount]) - LOOKUP(SUM([Net Revenue Amount]), -1)) / LOOKUP(SUM([Net Revenue Amount]), -1)

// Churn Risk Score
AVG([Churn Risk Score])
```

### **1. Visual Recommendations**

#### **Report 1: Platform Usage & Adoption Report**

**Data Element:** Total Meeting Minutes by User
- **Recommended Visual:** Horizontal Bar Chart
- **Data Fields:** USER_NAME, SUM(DURATION_MINUTES)
- **Tables Used:** FACT_MEETING_ACTIVITY, DIM_USER
- **Relationships:** FACT_MEETING_ACTIVITY.USER_KEY → DIM_USER.USER_KEY
- **Calculations:** 
  - Total Meeting Minutes: `SUM([Duration Minutes])`
  - Average Meeting Duration: `AVG([Duration Minutes])`
- **Interactivity:** 
  - Filter by Date Range (DATE_KEY from DIM_DATE)
  - Filter by User Status (DIM_USER.USER_STATUS)
  - Filter by Geographic Region (DIM_USER.GEOGRAPHIC_REGION)
  - Drill-down from User to Meeting Details
- **Justification:** Horizontal bar charts effectively show ranking and comparison of users by total meeting time, making it easy to identify top users
- **Optimization Tips:** Use extract with aggregated data, apply context filter on date range, index on USER_KEY and DATE_KEY

---

**Data Element:** Average Meeting Duration by Type and Category
- **Recommended Visual:** Grouped Bar Chart (Side-by-Side)
- **Data Fields:** MEETING_TYPE, MEETING_CATEGORY, AVG(DURATION_MINUTES)
- **Tables Used:** FACT_MEETING_ACTIVITY, DIM_MEETING
- **Relationships:** FACT_MEETING_ACTIVITY.MEETING_KEY → DIM_MEETING.MEETING_KEY
- **Calculations:** 
  - Average Duration by Type: `{FIXED [Meeting Type] : AVG([Duration Minutes])}`
  - Average Duration by Category: `{FIXED [Meeting Category] : AVG([Duration Minutes])}`
- **Interactivity:** 
  - Parameter to switch between Meeting Type and Meeting Category view
  - Filter by Date Range (DIM_DATE)
  - Tooltip showing participant count and quality scores
- **Justification:** Grouped bar charts allow easy comparison across multiple dimensions simultaneously
- **Optimization Tips:** Use LOD calculations sparingly, pre-aggregate in data source, use extract refresh strategy

---

**Data Element:** Number of Users by Meeting Topics
- **Recommended Visual:** Tree Map
- **Data Fields:** MEETING_TOPIC, COUNT(DISTINCT USER_KEY)
- **Tables Used:** FACT_MEETING_ACTIVITY, DIM_USER
- **Relationships:** FACT_MEETING_ACTIVITY.USER_KEY → DIM_USER.USER_KEY
- **Calculations:** 
  - Unique Users per Topic: `COUNTD([User Key])`
  - Topic Popularity Score: `COUNTD([User Key]) / TOTAL(COUNTD([User Key]))`
- **Interactivity:** 
  - Filter by Date Range (DIM_DATE)
  - Filter by Meeting Type (DIM_MEETING.MEETING_TYPE)
  - Click to filter other views
  - Drill-through to detailed user list
- **Justification:** Tree maps effectively show hierarchical data and relative sizes, perfect for topic popularity visualization
- **Optimization Tips:** Limit to top 50 topics, use context filters, consider data extract with topic aggregation

---

**Data Element:** Number of Meetings per User
- **Recommended Visual:** Histogram with Distribution Curve
- **Data Fields:** USER_NAME, COUNT(MEETING_ACTIVITY_ID)
- **Tables Used:** FACT_MEETING_ACTIVITY, DIM_USER
- **Relationships:** FACT_MEETING_ACTIVITY.USER_KEY → DIM_USER.USER_KEY
- **Calculations:** 
  - Meetings per User: `{FIXED [User Key] : COUNTD([Meeting Activity Id])}`
  - User Engagement Percentile: `PERCENTILE([Meetings per User], 0.75)`
- **Interactivity:** 
  - Parameter for bin size adjustment
  - Filter by User Role (DIM_USER.USER_ROLE) and Plan Type (DIM_USER.PLAN_TYPE)
  - Highlight action to show user details
- **Justification:** Histograms show distribution patterns and help identify user engagement segments
- **Optimization Tips:** Pre-calculate user meeting counts, use parameters for dynamic binning, limit to active users

---

**Data Element:** Feature Usage Trends Over Time
- **Recommended Visual:** Multi-Line Chart with Dual Axis
- **Data Fields:** DATE_KEY, FEATURE_NAME, SUM(USAGE_COUNT), AVG(USAGE_DURATION_MINUTES)
- **Tables Used:** FACT_FEATURE_USAGE, DIM_FEATURE, DIM_DATE
- **Relationships:** 
  - FACT_FEATURE_USAGE.FEATURE_KEY → DIM_FEATURE.FEATURE_KEY
  - FACT_FEATURE_USAGE.DATE_KEY → DIM_DATE.DATE_KEY
- **Calculations:** 
  - Daily Usage Count: `SUM([Usage Count])`
  - 7-Day Moving Average: `WINDOW_AVG(SUM([Usage Count]), -6, 0)`
  - Usage Duration Trend: `AVG([Usage Duration Minutes])`
- **Interactivity:** 
  - Date range filter with relative date options
  - Feature multi-select filter (DIM_FEATURE.FEATURE_CATEGORY)
  - Parameter to switch between daily/weekly/monthly view
  - Synchronized dual axis for count and duration
- **Justification:** Line charts show trends over time effectively, dual axis allows comparison of different metrics
- **Optimization Tips:** Use continuous dates, limit to top 10 features, use table calculations for moving averages

---

#### **Report 2: Service Reliability & Support Report**

**Data Element:** Number of Users by Support Category and Subcategory
- **Recommended Visual:** Nested Bar Chart (Stacked)
- **Data Fields:** SUPPORT_CATEGORY, SUPPORT_SUBCATEGORY, COUNT(DISTINCT USER_KEY)
- **Tables Used:** FACT_SUPPORT_ACTIVITY, DIM_SUPPORT_CATEGORY, DIM_USER
- **Relationships:** 
  - FACT_SUPPORT_ACTIVITY.SUPPORT_CATEGORY_KEY → DIM_SUPPORT_CATEGORY.SUPPORT_CATEGORY_KEY
  - FACT_SUPPORT_ACTIVITY.USER_KEY → DIM_USER.USER_KEY
- **Calculations:** 
  - Users per Category: `COUNTD([User Key])`
  - Category Distribution: `SUM([Users per Category]) / TOTAL(SUM([Users per Category]))`
- **Interactivity:** 
  - Drill-down from Category to Subcategory
  - Filter by Priority Level (DIM_SUPPORT_CATEGORY.PRIORITY_LEVEL)
  - Filter by Date Range (DIM_DATE)
  - Sort by count or alphabetically
- **Justification:** Stacked bars show both total and breakdown by subcategory in a single view
- **Optimization Tips:** Use extract with pre-aggregated support data, context filter on date, index on support category keys

---

**Data Element:** Support Activities by Resolution Status
- **Recommended Visual:** Donut Chart with KPI Cards
- **Data Fields:** RESOLUTION_STATUS, COUNT(SUPPORT_ACTIVITY_ID)
- **Tables Used:** FACT_SUPPORT_ACTIVITY
- **Calculations:** 
  - Total Support Activities: `COUNT([Support Activity Id])`
  - Resolution Rate: `SUM(IF [Resolution Status] = 'Resolved' THEN 1 ELSE 0 END) / COUNT([Support Activity Id])`
  - Average Resolution Time: `AVG([Resolution Time Hours])`
- **Interactivity:** 
  - Filter by Date Range (DIM_DATE)
  - Filter by Priority Level (DIM_SUPPORT_CATEGORY.PRIORITY_LEVEL)
  - Click to filter detailed views
  - Parameter for time period comparison
- **Justification:** Donut charts show proportions clearly, KPI cards provide key metrics at a glance
- **Optimization Tips:** Use calculated fields for percentages, limit status categories, use quick filters

---

**Data Element:** Support Activities by Priority Level
- **Recommended Visual:** Bullet Graph with Target Lines
- **Data Fields:** PRIORITY_LEVEL, COUNT(SUPPORT_ACTIVITY_ID), SLA_TARGET_HOURS
- **Tables Used:** FACT_SUPPORT_ACTIVITY, DIM_SUPPORT_CATEGORY
- **Relationships:** FACT_SUPPORT_ACTIVITY.SUPPORT_CATEGORY_KEY → DIM_SUPPORT_CATEGORY.SUPPORT_CATEGORY_KEY
- **Calculations:** 
  - Activities by Priority: `COUNT([Support Activity Id])`
  - SLA Compliance Rate: `SUM(IF [Sla Met] = TRUE THEN 1 ELSE 0 END) / COUNT([Support Activity Id])`
  - Target vs Actual: `AVG([Resolution Time Hours]) - AVG([Sla Target Hours])`
- **Interactivity:** 
  - Parameter for SLA target adjustment
  - Filter by Support Category (DIM_SUPPORT_CATEGORY.SUPPORT_CATEGORY)
  - Drill-through to ticket details
  - Color coding for SLA performance
- **Justification:** Bullet graphs effectively show performance against targets with clear visual indicators
- **Optimization Tips:** Use parameters for dynamic targets, pre-calculate SLA metrics, use color coding for quick identification

---

#### **Additional Revenue Analytics Visuals**

**Data Element:** Revenue Trends by License Type
- **Recommended Visual:** Area Chart with Stacked Layers
- **Data Fields:** DATE_KEY, LICENSE_TYPE, SUM(NET_REVENUE_AMOUNT)
- **Tables Used:** FACT_REVENUE_ACTIVITY, DIM_LICENSE, DIM_DATE
- **Relationships:** 
  - FACT_REVENUE_ACTIVITY.LICENSE_KEY → DIM_LICENSE.LICENSE_KEY
  - FACT_REVENUE_ACTIVITY.DATE_KEY → DIM_DATE.DATE_KEY
- **Calculations:** 
  - Monthly Revenue: `SUM([Net Revenue Amount])`
  - Revenue Growth Rate: `(SUM([Net Revenue Amount]) - LOOKUP(SUM([Net Revenue Amount]), -1)) / LOOKUP(SUM([Net Revenue Amount]), -1)`
- **Interactivity:** 
  - Date range filter
  - License tier filter (DIM_LICENSE.LICENSE_TIER)
  - Geographic region filter (DIM_USER.GEOGRAPHIC_REGION)
- **Justification:** Area charts show revenue composition and trends over time effectively
- **Optimization Tips:** Use monthly aggregation, limit to active license types, use extract for performance

---

**Data Element:** Customer Lifetime Value Distribution
- **Recommended Visual:** Scatter Plot with Trend Line
- **Data Fields:** CUSTOMER_LIFETIME_VALUE, CHURN_RISK_SCORE, PLAN_TYPE
- **Tables Used:** FACT_REVENUE_ACTIVITY, DIM_USER
- **Relationships:** FACT_REVENUE_ACTIVITY.USER_KEY → DIM_USER.USER_KEY
- **Calculations:** 
  - Average CLV: `AVG([Customer Lifetime Value])`
  - Risk-Adjusted CLV: `AVG([Customer Lifetime Value]) * (1 - AVG([Churn Risk Score]))`
- **Interactivity:** 
  - Filter by Plan Type
  - Filter by Industry Sector
  - Highlight high-value, low-risk customers
- **Justification:** Scatter plots reveal relationships between CLV and churn risk, helping identify valuable customer segments
- **Optimization Tips:** Use sampling for large datasets, add reference lines for benchmarks

---

### **2. Overall Dashboard Design**

#### **Layout Suggestions:**
- **Dashboard Structure:** Use a 4-tier layout approach
  - **Top Tier:** Executive KPI cards (Total Users, Total Meetings, Total Revenue, Average Resolution Time)
  - **Second Tier:** Primary analytical views (Usage trends, Revenue trends, Support status overview)
  - **Third Tier:** Detailed analysis views (Feature usage patterns, Customer segmentation)
  - **Bottom Tier:** Detailed drill-down views and distribution analysis
- **Navigation:** Implement tab-based navigation for different report sections:
  - **Overview Tab:** Executive summary with key metrics
  - **Usage Analytics Tab:** Meeting and feature usage analysis
  - **Support Analytics Tab:** Support ticket and resolution analysis
  - **Revenue Analytics Tab:** Financial performance and customer value analysis
- **Responsive Design:** Use device-specific layouts for mobile and desktop viewing
- **White Space:** Maintain adequate spacing between visualizations for clarity

#### **Performance Optimization:**
- **Extract Strategy:** 
  - Create extracts for fact tables with incremental refresh daily at 6 AM
  - Full refresh weekly for dimension tables on Sundays
  - Use aggregate extracts for summary-level dashboards
  - Implement data source filters to limit to last 2 years of data
- **Data Source Optimization:**
  - Use custom SQL connections with pre-joined tables
  - Create indexed views in Snowflake for frequently accessed combinations
  - Implement clustering keys on DATE_KEY and USER_KEY in Snowflake
  - Use result caching in Snowflake for repeated queries
- **Calculation Optimization:**
  - Move complex calculations to data source level using custom SQL
  - Use context filters before dimension filters
  - Limit LOD calculations and prefer table calculations where possible
  - Pre-calculate common metrics like MRR, ARR in the data warehouse
- **Filter Optimization:**
  - Use single-value dropdown filters instead of multi-select where appropriate
  - Implement cascading filters to reduce data scanning
  - Use "Only Relevant Values" option for filters
  - Apply data source filters for date ranges

#### **Color Scheme:**
- **Primary Colors:** 
  - Blue (#1f77b4) for primary metrics and positive indicators
  - Orange (#ff7f0e) for secondary metrics and warnings
  - Red (#d62728) for alerts and critical issues
  - Green (#2ca02c) for success metrics and targets met
- **Supporting Colors:**
  - Light gray (#f0f0f0) for backgrounds
  - Dark gray (#333333) for text and borders
  - Light blue (#aec7e8) for hover states
- **Accessibility:** Ensure color combinations meet WCAG 2.1 AA standards
- **Consistency:** Use the same color for the same metric across all views

#### **Typography:**
- **Headers:** Tableau Book, 14-16pt, Bold
- **Axis Labels:** Tableau Book, 10-12pt, Regular
- **Data Labels:** Tableau Book, 9-10pt, Regular
- **Tooltips:** Tableau Book, 9pt, Regular
- **KPI Values:** Tableau Book, 18-24pt, Bold
- **Hierarchy:** Use font size and weight to establish visual hierarchy

#### **Interactive Elements:**

| Element Type | Purpose | Implementation | Data Fields | Tables Used |
|--------------|---------|----------------|-------------|-------------|
| **Date Range Filter** | Time period selection | Relative date filter with custom ranges | DATE_KEY | DIM_DATE |
| **User Segment Filter** | Filter by user characteristics | Multi-select dropdown | PLAN_TYPE, USER_ROLE, GEOGRAPHIC_REGION | DIM_USER |
| **Meeting Type Parameter** | Switch between meeting analysis views | Single-select parameter | MEETING_TYPE, MEETING_CATEGORY | DIM_MEETING |
| **Priority Level Filter** | Support ticket priority filtering | Single-select with "All" option | PRIORITY_LEVEL | DIM_SUPPORT_CATEGORY |
| **Feature Category Filter** | Feature usage analysis | Hierarchical filter | FEATURE_CATEGORY, FEATURE_TYPE | DIM_FEATURE |
| **License Tier Filter** | Revenue analysis by license level | Multi-select dropdown | LICENSE_TIER, LICENSE_CATEGORY | DIM_LICENSE |
| **Drill-Down Action** | Navigate from summary to detail | Filter action on click | USER_KEY → Meeting details, MEETING_KEY → Feature usage | Multiple fact tables |
| **Highlight Action** | Cross-highlight related data | Highlight action on hover | Highlight related records across multiple sheets | All tables |
| **URL Action** | Link to external systems | URL action with parameters | Link to support ticket system with SUPPORT_ACTIVITY_ID | FACT_SUPPORT_ACTIVITY |
| **Reset Filters** | Clear all applied filters | Button with reset action | Reset all dashboard filters to default state | All tables |
| **Export Options** | Data export capabilities | Download actions | PDF for executive summary, Excel for detailed data | All tables |

#### **Data Relationships Summary Table:**

| Fact Table | Dimension Table | Join Key | Relationship Type | Cardinality |
|------------|-----------------|----------|-------------------|-------------|
| FACT_MEETING_ACTIVITY | DIM_USER | USER_KEY | Inner Join | Many-to-One |
| FACT_MEETING_ACTIVITY | DIM_MEETING | MEETING_KEY | Inner Join | Many-to-One |
| FACT_MEETING_ACTIVITY | DIM_DATE | DATE_KEY | Inner Join | Many-to-One |
| FACT_MEETING_ACTIVITY | DIM_FEATURE | FEATURE_KEY | Left Join | Many-to-One |
| FACT_FEATURE_USAGE | DIM_USER | USER_KEY | Inner Join | Many-to-One |
| FACT_FEATURE_USAGE | DIM_FEATURE | FEATURE_KEY | Inner Join | Many-to-One |
| FACT_FEATURE_USAGE | DIM_DATE | DATE_KEY | Inner Join | Many-to-One |
| FACT_FEATURE_USAGE | DIM_MEETING | MEETING_KEY | Left Join | Many-to-One |
| FACT_REVENUE_ACTIVITY | DIM_USER | USER_KEY | Inner Join | Many-to-One |
| FACT_REVENUE_ACTIVITY | DIM_LICENSE | LICENSE_KEY | Inner Join | Many-to-One |
| FACT_REVENUE_ACTIVITY | DIM_DATE | DATE_KEY | Inner Join | Many-to-One |
| FACT_SUPPORT_ACTIVITY | DIM_USER | USER_KEY | Inner Join | Many-to-One |
| FACT_SUPPORT_ACTIVITY | DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY_KEY | Inner Join | Many-to-One |
| FACT_SUPPORT_ACTIVITY | DIM_DATE | DATE_KEY | Inner Join | Many-to-One |

#### **Dashboard Performance Monitoring:**
- **Load Time Targets:** 
  - Initial load: < 10 seconds
  - Filter interactions: < 3 seconds
  - Drill-down actions: < 5 seconds
- **Data Freshness Indicators:** Display last refresh timestamp from GO_AUDIT_LOG
- **Error Handling:** Implement graceful error messages for data connection issues
- **Usage Analytics:** Track dashboard usage patterns using Tableau Server logs

#### **Mobile Optimization:**
- **Device Layouts:** Create specific layouts for phone and tablet views
- **Touch Interactions:** Ensure filters and actions work well with touch interfaces
- **Simplified Views:** Reduce complexity for mobile versions while maintaining key insights
- **Vertical Scrolling:** Design for vertical scrolling on mobile devices

#### **Security and Governance:**
- **Row-Level Security:** Implement user-based data filtering where required
- **Data Source Permissions:** Ensure appropriate access controls on underlying data
- **Refresh Schedules:** Coordinate with data pipeline schedules
- **Version Control:** Maintain dashboard versioning and change documentation

This comprehensive Tableau Dashboard Visuals Recommender provides a structured approach to building effective analytics dashboards for the Platform Analytics System, ensuring optimal performance, user experience, and actionable insights with complete table relationships and missing table information now included.