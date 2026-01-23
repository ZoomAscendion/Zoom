_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Tableau Dashboard Visuals Recommender for advanced visualization capabilities including scatter charts, combination charts, dynamic parameters, and Gantt charts
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender

## Data Model Overview

Based on the provided data model, we have the following key tables:

**Dimension Tables:**
- DIM_DATE: Date hierarchy and calendar attributes
- DIM_FEATURE: Feature catalog with categories, types, and complexity
- DIM_LICENSE: License types, tiers, and pricing information
- DIM_MEETING: Meeting categorization and quality metrics
- DIM_SUPPORT_CATEGORY: Support categorization and SLA information
- DIM_USER: User demographics, plans, and geographic information

**Fact Tables:**
- FACT_FEATURE_USAGE: Feature usage metrics and performance
- FACT_MEETING_ACTIVITY: Meeting participation and quality metrics
- FACT_REVENUE_ACTIVITY: Revenue, subscriptions, and financial metrics
- FACT_SUPPORT_ACTIVITY: Support ticket resolution and satisfaction

## 1. Visual Recommendations

### 1.1 Scatter/Bubble Chart with Multiple Dimensions in Rows

- **Data Element:** Feature Usage Analysis by User Segments
- **Recommended Visual:** Scatter Plot with Size Encoding (Bubble Chart)
- **Data Fields:** 
  - Rows: DIM_USER.GEOGRAPHIC_REGION, DIM_USER.INDUSTRY_SECTOR
  - Columns: AVG(FACT_FEATURE_USAGE.FEATURE_ADOPTION_SCORE)
  - X-Axis: AVG(FACT_FEATURE_USAGE.USAGE_DURATION_MINUTES)
  - Y-Axis: AVG(FACT_FEATURE_USAGE.USER_EXPERIENCE_RATING)
  - Size: SUM(FACT_FEATURE_USAGE.USAGE_COUNT)
  - Color: DIM_FEATURE.FEATURE_CATEGORY
- **Calculations:** 
  ```
  // Average Adoption Score by Region-Industry
  { FIXED [Geographic Region], [Industry Sector] : AVG([Feature Adoption Score]) }
  
  // Usage Intensity Score
  [Usage Count] * [Usage Duration Minutes] / [Session Duration Minutes]
  ```
- **Interactivity:** 
  - Filter: Date Range, Feature Category, Plan Type
  - Parameter: Metric Selector (Adoption Score vs Performance Score)
  - Drill-down: Region → Industry → Company
- **Justification:** Scatter plots effectively show correlation between adoption and experience while bubble size indicates usage volume. Multiple dimensions in rows enable detailed segmentation.
- **Optimization Tips:** Use extract with aggregated data, apply context filters for date ranges, index on Geographic_Region and Industry_Sector

### 1.2 Marker + Area/Line Combination Charts

- **Data Element:** Revenue Trends with Support Incident Overlay
- **Recommended Visual:** Dual Axis Combination Chart (Area + Line + Markers)
- **Data Fields:**
  - Primary Axis (Area): SUM(FACT_REVENUE_ACTIVITY.NET_REVENUE_AMOUNT)
  - Secondary Axis (Line): AVG(FACT_SUPPORT_ACTIVITY.CUSTOMER_SATISFACTION_SCORE)
  - Secondary Axis (Markers): COUNT(FACT_SUPPORT_ACTIVITY.SUPPORT_ACTIVITY_ID) where SLA_MET = False
  - X-Axis: DIM_DATE.DATE_VALUE (Month/Quarter)
- **Calculations:**
  ```
  // Monthly Recurring Revenue (MRR)
  SUM([Subscription Revenue Amount])
  
  // Support Satisfaction Trend
  WINDOW_AVG(AVG([Customer Satisfaction Score]))
  
  // SLA Breach Count
  SUM(IF [SLA Met] = FALSE THEN 1 ELSE 0 END)
  ```
- **Interactivity:**
  - Filter: License Type, Geographic Region
  - Parameter: Time Granularity (Daily/Weekly/Monthly)
  - Action: Click on marker to filter support dashboard
- **Justification:** Combination charts reveal relationships between revenue performance and customer satisfaction, with SLA breaches as key incident markers.
- **Optimization Tips:** Use continuous dates, synchronize dual axes, aggregate at monthly level for performance

### 1.3 Dynamic Measure Switching Based on Parameters

- **Data Element:** KPI Dashboard with Selectable Metrics
- **Recommended Visual:** KPI Cards with Dynamic Measure Display
- **Data Fields:**
  - Dynamic Measure (controlled by parameter)
  - Dimension: DIM_DATE.MONTH_NAME, DIM_USER.PLAN_TYPE
- **Calculations:**
  ```
  // Parameter: Metric Selector
  // Values: "Revenue", "Usage", "Support", "Adoption"
  
  // Dynamic Measure Calculation
  CASE [Metric Selector]
  WHEN "Revenue" THEN SUM([Net Revenue Amount])
  WHEN "Usage" THEN AVG([Usage Duration Minutes])
  WHEN "Support" THEN AVG([Customer Satisfaction Score])
  WHEN "Adoption" THEN AVG([Feature Adoption Score])
  END
  
  // Dynamic Title
  CASE [Metric Selector]
  WHEN "Revenue" THEN "Total Revenue ($)"
  WHEN "Usage" THEN "Avg Usage Duration (min)"
  WHEN "Support" THEN "Support Satisfaction"
  WHEN "Adoption" THEN "Feature Adoption Score"
  END
  
  // Period over Period Change
  (ZN(SUM([Dynamic Measure])) - LOOKUP(ZN(SUM([Dynamic Measure])), -1)) / ABS(LOOKUP(ZN(SUM([Dynamic Measure])), -1))
  ```
- **Interactivity:**
  - Parameter: Metric Selector dropdown
  - Parameter: Time Period (MTD, QTD, YTD)
  - Filter: Plan Type, Region
- **Justification:** Parameters provide flexible metric switching without rebuilding charts, enabling executive dashboards with multiple KPI views.
- **Optimization Tips:** Pre-aggregate measures in data source, use parameters instead of filters for better performance

### 1.4 Running Total in Marimekko/Advanced Bar Charts

- **Data Element:** License Revenue Contribution and Growth Analysis
- **Recommended Visual:** Marimekko Chart with Running Total Line
- **Data Fields:**
  - Width: SUM(FACT_REVENUE_ACTIVITY.NET_REVENUE_AMOUNT) by DIM_LICENSE.LICENSE_TYPE
  - Height: Percentage of Total Revenue by DIM_LICENSE.LICENSE_TIER
  - Running Total Line: Cumulative Revenue Percentage
- **Calculations:**
  ```
  // Revenue by License Type (Width)
  SUM([Net Revenue Amount])
  
  // Percentage of Total by Tier (Height)
  SUM([Net Revenue Amount]) / TOTAL(SUM([Net Revenue Amount]))
  
  // Running Total Percentage
  RUNNING_SUM(SUM([Net Revenue Amount])) / TOTAL(SUM([Net Revenue Amount]))
  
  // Normalized Width for Marimekko
  SUM([Net Revenue Amount]) / TOTAL(SUM([Net Revenue Amount])) * 100
  ```
- **Interactivity:**
  - Filter: Date Range, Geographic Region
  - Highlight Action: Show license details on hover
  - Parameter: Sort Order (Revenue, Growth Rate)
- **Justification:** Marimekko charts show both absolute contribution (width) and relative distribution (height) while running totals identify key contributors.
- **Optimization Tips:** Limit to top 10-15 license types, use extract for complex calculations, pre-calculate percentages

### 1.5 100% Stacked Bar Chart with Absolute Value Line

- **Data Element:** Feature Usage Distribution with Total Usage Overlay
- **Recommended Visual:** 100% Stacked Bar Chart with Dual Axis Line
- **Data Fields:**
  - Primary Axis (Stacked %): Percentage of Usage by DIM_FEATURE.FEATURE_CATEGORY
  - Secondary Axis (Line): Total Usage Count
  - X-Axis: DIM_DATE.MONTH_NAME
- **Calculations:**
  ```
  // Percentage of Total Usage by Category
  SUM([Usage Count]) / TOTAL(SUM([Usage Count]))
  
  // Total Usage Count (for line)
  SUM([Usage Count])
  
  // Feature Category Rank
  RANK(SUM([Usage Count]), 'desc')
  
  // Growth Rate
  (SUM([Usage Count]) - LOOKUP(SUM([Usage Count]), -1)) / LOOKUP(SUM([Usage Count]), -1)
  ```
- **Interactivity:**
  - Filter: Feature Type, User Plan
  - Parameter: Top N Categories
  - Drill-down: Category → Feature Name
- **Justification:** Shows relative distribution changes over time while maintaining visibility of absolute growth trends.
- **Optimization Tips:** Synchronize dual axes, use continuous dates, limit feature categories for readability

### 1.6 Gantt Chart with Dynamic Legends

- **Data Element:** Support Ticket Resolution Timeline and Status Tracking
- **Recommended Visual:** Gantt Chart with Dynamic Status Legends
- **Data Fields:**
  - Rows: DIM_SUPPORT_CATEGORY.SUPPORT_CATEGORY, FACT_SUPPORT_ACTIVITY.SUPPORT_ACTIVITY_ID
  - Columns: FACT_SUPPORT_ACTIVITY.TICKET_OPEN_DATE
  - Size: DATEDIFF('day', [Ticket Open Date], [Ticket Close Date])
  - Color: Dynamic Status (controlled by parameter)
- **Calculations:**
  ```
  // Gantt Duration
  DATEDIFF('day', [Ticket Open Date], IFNULL([Ticket Close Date], TODAY()))
  
  // Dynamic Status Parameter
  // Values: "Priority", "SLA Status", "Resolution Status"
  
  // Dynamic Color Calculation
  CASE [Status Display Parameter]
  WHEN "Priority" THEN [Priority Level]
  WHEN "SLA Status" THEN IF [SLA Met] THEN "Met" ELSE "Breached" END
  WHEN "Resolution Status" THEN [Resolution Status]
  END
  
  // SLA Target Line
  [Ticket Open Date] + [SLA Target Hours]/24
  
  // Overdue Indicator
  IF [Ticket Close Date] IS NULL AND TODAY() > ([Ticket Open Date] + [SLA Target Hours]/24)
  THEN "Overdue" ELSE "On Track" END
  ```
- **Interactivity:**
  - Parameter: Status Display (Priority/SLA/Resolution)
  - Filter: Support Category, Date Range, Agent
  - Action: Click ticket to show details dashboard
  - Drill-down: Category → Subcategory → Individual Tickets
- **Justification:** Gantt charts effectively show timeline dependencies and resource allocation while dynamic legends provide multiple analytical perspectives.
- **Optimization Tips:** Limit to recent tickets (last 90 days), use extract for date calculations, index on ticket dates

## 2. Overall Dashboard Design

### Layout Suggestions
- **Executive Summary Page:** KPI cards with dynamic measures at top, trend charts below
- **Operational Dashboard:** Gantt chart for support tickets, combination charts for performance metrics
- **Analytical Deep-dive:** Scatter plots and Marimekko charts for detailed analysis
- **Mobile Layout:** Vertical stack with collapsible sections, simplified visuals
- **Navigation:** Tab structure with consistent filter panel on left side

### Performance Optimization
- **Extract Strategy:** 
  - Daily refresh for operational dashboards
  - Weekly refresh for analytical dashboards
  - Incremental refresh for large fact tables
- **Data Source Optimization:**
  - Pre-aggregate measures at monthly/weekly level
  - Create calculated fields in data source
  - Use indexed columns for frequent filters
- **Query Optimization:**
  - Use context filters for date ranges
  - Minimize LOD calculations where possible
  - Implement data source filters for large datasets
- **Dashboard Performance:**
  - Limit concurrent users during peak hours
  - Use dashboard subscriptions instead of live viewing
  - Implement progressive loading for complex visuals

### Color Scheme
- **Primary Palette:** Corporate blue (#1f77b4) for main metrics
- **Secondary Palette:** Orange (#ff7f0e) for alerts/attention items
- **Status Colors:** Green (#2ca02c) for positive, Red (#d62728) for negative
- **Neutral Colors:** Gray (#7f7f7f) for secondary information
- **Accessibility:** Ensure color-blind friendly palette with pattern/shape encoding

### Typography
- **Headers:** Tableau Book Bold, 14-16pt for dashboard titles
- **Labels:** Tableau Book Regular, 10-12pt for axis labels
- **Values:** Tableau Book Regular, 9-11pt for data labels
- **Annotations:** Tableau Book Italic, 8-10pt for explanatory text
- **Consistency:** Maintain font hierarchy across all dashboards

### Interactive Elements

| Element Type | Purpose | Implementation | Best Practice |
|--------------|---------|----------------|---------------|
| **Global Filters** | Date Range, Region, Plan Type | Filter Actions across dashboards | Place in consistent location (top/left) |
| **Parameters** | Metric Selection, Top N, Granularity | Dynamic calculations and display | Provide clear labels and default values |
| **Drill-down Actions** | Region→Industry→Company | Hierarchy navigation | Implement breadcrumb navigation |
| **Highlight Actions** | Cross-chart highlighting | Related data emphasis | Use consistent color scheme |
| **URL Actions** | External system integration | Link to detailed reports | Open in new tab/window |
| **Filter Actions** | Dashboard to dashboard navigation | Contextual filtering | Maintain filter state across sessions |
| **Set Controls** | Dynamic grouping | Ad-hoc analysis | Limit to power users |
| **Quick Filters** | Dimension filtering | Interactive exploration | Use relevant values only |

### Key Performance Indicators (KPIs)

| KPI Category | Primary Metrics | Secondary Metrics | Visualization Type |
|--------------|----------------|-------------------|--------------------|
| **Revenue** | MRR, ARR, Net Revenue | Churn Rate, CLTV | KPI Cards, Trend Lines |
| **Usage** | Active Users, Session Duration | Feature Adoption, Usage Frequency | Scatter Plots, Heat Maps |
| **Support** | CSAT, First Contact Resolution | SLA Compliance, Resolution Time | Gantt Charts, Bullet Graphs |
| **Product** | Feature Usage, Quality Scores | Error Rates, Performance | Combination Charts, Marimekko |

### Data Refresh Strategy

| Data Type | Refresh Frequency | Method | Performance Impact |
|-----------|------------------|--------|--------------------|
| **Real-time KPIs** | Every 15 minutes | Live connection | High - limit concurrent users |
| **Daily Operations** | Every 4 hours | Extract refresh | Medium - schedule off-peak |
| **Weekly Analytics** | Daily at 6 AM | Full extract refresh | Low - overnight processing |
| **Monthly Reports** | Weekly | Incremental refresh | Very Low - minimal impact |

### Mobile Responsiveness
- **Device Detection:** Automatic layout adjustment for tablets/phones
- **Touch Optimization:** Larger touch targets for filters and actions
- **Simplified Views:** Reduced visual complexity for small screens
- **Progressive Disclosure:** Expandable sections for detailed data
- **Offline Capability:** Cached extracts for offline viewing

### Security and Governance
- **Row-level Security:** User-based data filtering by region/company
- **Column-level Security:** Sensitive financial data restrictions
- **Dashboard Permissions:** Role-based access control
- **Data Lineage:** Clear documentation of data sources and transformations
- **Audit Trail:** User access and interaction logging

This comprehensive Tableau Dashboard Visuals Recommender provides detailed guidance for implementing advanced visualization capabilities while ensuring optimal performance, usability, and governance standards.