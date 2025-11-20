_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Tableau Dashboard Visuals Recommender for Zoom Platform Analytics focusing on Service Reliability & Support and Platform Usage & Adoption reports
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender
## Zoom Platform Analytics System - Service Reliability & Platform Usage Reports

### **1. Visual Recommendations**

#### **Chart 1: Number of Users by Support Category & Subcategory (Bar Chart)**

- **Data Element:** User distribution across support categories and subcategories
- **Recommended Visual:** Horizontal Bar Chart with nested grouping
- **Data Fields:** 
  - Support Category (from DIM_SUPPORT_CATEGORY)
  - Support Subcategory (from DIM_SUPPORT_CATEGORY) 
  - User Key (from FACT_SUPPORT_ACTIVITY)
- **Calculations:** 
  - `COUNTD([User Key])` - Distinct count of users
- **Query/Tableau Calculation:**
  ```
  SELECT 
    sc.SUPPORT_CATEGORY,
    sc.SUPPORT_SUBCATEGORY,
    COUNT(DISTINCT fsa.USER_KEY) as Number_of_Users
  FROM FACT_SUPPORT_ACTIVITY fsa
  JOIN DIM_SUPPORT_CATEGORY sc ON fsa.SUPPORT_CATEGORY_KEY = sc.SUPPORT_CATEGORY_KEY
  GROUP BY sc.SUPPORT_CATEGORY, sc.SUPPORT_SUBCATEGORY
  ```
- **Interactivity:** 
  - Filter by Support Category
  - Drill-down from Category to Subcategory
  - Tooltip showing Support Category, Support Subcategory, Number of Users
- **Justification:** Bar charts effectively show categorical comparisons and allow easy identification of which support areas have the highest user impact
- **Optimization Tips:** 
  - Use extract for better performance
  - Create context filter on date range if needed
  - Index Support Category and Subcategory fields in data source

#### **Chart 2: Number of Support Activities by Priority (Bar Chart)**

- **Data Element:** Support ticket volume by priority level
- **Recommended Visual:** Vertical Bar Chart
- **Data Fields:**
  - Priority Level (from DIM_SUPPORT_CATEGORY)
  - Support Activity ID (from FACT_SUPPORT_ACTIVITY)
- **Calculations:**
  - `COUNT([Support Activity Id])` - Count of support activities
- **Query/Tableau Calculation:**
  ```
  SELECT 
    sc.PRIORITY_LEVEL,
    COUNT(fsa.SUPPORT_ACTIVITY_ID) as Number_of_Support_Activities
  FROM FACT_SUPPORT_ACTIVITY fsa
  JOIN DIM_SUPPORT_CATEGORY sc ON fsa.SUPPORT_CATEGORY_KEY = sc.SUPPORT_CATEGORY_KEY
  GROUP BY sc.PRIORITY_LEVEL
  ORDER BY 
    CASE sc.PRIORITY_LEVEL 
      WHEN 'High' THEN 1 
      WHEN 'Medium' THEN 2 
      WHEN 'Low' THEN 3 
    END
  ```
- **Interactivity:**
  - Filter by date range
  - Color coding by priority (Red for High, Orange for Medium, Green for Low)
  - Tooltip showing Priority Level and Count of Support Activities
- **Justification:** Bar chart allows quick comparison of ticket volumes across priority levels and helps identify workload distribution
- **Optimization Tips:**
  - Use custom sort order (High, Medium, Low)
  - Apply conditional formatting for priority colors
  - Consider using parameters for dynamic date filtering

#### **Chart 3: Number of Support Activities by Resolution Status (Bar Chart)**

- **Data Element:** Support ticket distribution by resolution status
- **Recommended Visual:** Horizontal Bar Chart
- **Data Fields:**
  - Resolution Status (from FACT_SUPPORT_ACTIVITY)
  - Support Activity ID (from FACT_SUPPORT_ACTIVITY)
- **Calculations:**
  - `COUNT([Support Activity Id])` - Count of support activities
- **Query/Tableau Calculation:**
  ```
  SELECT 
    fsa.RESOLUTION_STATUS,
    COUNT(fsa.SUPPORT_ACTIVITY_ID) as Number_of_Support_Activities
  FROM FACT_SUPPORT_ACTIVITY fsa
  GROUP BY fsa.RESOLUTION_STATUS
  ORDER BY COUNT(fsa.SUPPORT_ACTIVITY_ID) DESC
  ```
- **Interactivity:**
  - Filter by date range and priority level
  - Drill-through to detailed ticket list
  - Tooltip showing Resolution Status and Count
- **Justification:** Horizontal bar chart provides clear view of resolution status distribution and helps identify bottlenecks in support process
- **Optimization Tips:**
  - Sort bars by count (descending)
  - Use distinct colors for each status
  - Add reference line for target resolution percentages

#### **Chart 4: Feature Usage Distribution (Pie Chart)**

- **Data Element:** Distribution of feature usage across different Zoom features
- **Recommended Visual:** Pie Chart with percentage labels
- **Data Fields:**
  - Feature Name (from DIM_FEATURE via FACT_FEATURE_USAGE)
  - Usage Count (from FACT_FEATURE_USAGE)
- **Calculations:**
  - `SUM([Usage Count])` - Total usage count per feature
  - Percentage calculation for pie slices
- **Query/Tableau Calculation:**
  ```
  SELECT 
    df.FEATURE_NAME,
    SUM(ffu.USAGE_COUNT) as Total_Usage_Count
  FROM FACT_FEATURE_USAGE ffu
  JOIN DIM_FEATURE df ON ffu.FEATURE_KEY = df.FEATURE_KEY
  GROUP BY df.FEATURE_NAME
  ORDER BY SUM(ffu.USAGE_COUNT) DESC
  ```
- **Interactivity:**
  - Filter by date range and feature category
  - Hover tooltip showing feature name, usage count, and percentage
  - Click to filter other charts by selected feature
- **Justification:** Pie chart effectively shows proportional distribution and helps identify most/least adopted features
- **Optimization Tips:**
  - Limit to top 10-15 features to avoid cluttered visualization
  - Use "Others" category for remaining features
  - Consider donut chart variation for better readability

#### **Chart 5: Number of Users by Meeting Topics (Bar Chart)**

- **Data Element:** User participation across different meeting topics
- **Recommended Visual:** Horizontal Bar Chart
- **Data Fields:**
  - Meeting Topic (from FACT_MEETING_ACTIVITY)
  - User Key (from FACT_MEETING_ACTIVITY)
- **Calculations:**
  - `COUNTD([User Key])` - Distinct count of users per topic
- **Query/Tableau Calculation:**
  ```
  SELECT 
    fma.MEETING_TOPIC,
    COUNT(DISTINCT fma.USER_KEY) as Number_of_Users
  FROM FACT_MEETING_ACTIVITY fma
  WHERE fma.MEETING_TOPIC IS NOT NULL
  GROUP BY fma.MEETING_TOPIC
  ORDER BY COUNT(DISTINCT fma.USER_KEY) DESC
  ```
- **Interactivity:**
  - Filter by date range and meeting type
  - Sort by user count (ascending/descending)
  - Tooltip showing Meeting Topic and User Count
- **Justification:** Bar chart allows easy comparison of user engagement across different meeting topics
- **Optimization Tips:**
  - Handle null/empty meeting topics appropriately
  - Consider grouping similar topics into categories
  - Use text wrapping for long topic names

#### **Chart 6: Average Meeting Duration by Type & Category (Bar Chart)**

- **Data Element:** Average meeting duration across different meeting types and categories
- **Recommended Visual:** Grouped Bar Chart
- **Data Fields:**
  - Meeting Type (from DIM_MEETING)
  - Meeting Category (from DIM_MEETING)
  - Duration Minutes (from FACT_MEETING_ACTIVITY)
- **Calculations:**
  - `AVG([Duration Minutes])` - Average duration per type/category
- **Query/Tableau Calculation:**
  ```
  SELECT 
    dm.MEETING_TYPE,
    dm.MEETING_CATEGORY,
    AVG(fma.DURATION_MINUTES) as Average_Duration_Minutes
  FROM FACT_MEETING_ACTIVITY fma
  JOIN DIM_MEETING dm ON fma.MEETING_KEY = dm.MEETING_KEY
  GROUP BY dm.MEETING_TYPE, dm.MEETING_CATEGORY
  ORDER BY AVG(fma.DURATION_MINUTES) DESC
  ```
- **Interactivity:**
  - Filter by date range
  - Group by Meeting Type with Category as color
  - Tooltip showing Meeting Type, Category, and Average Duration
- **Justification:** Grouped bar chart effectively shows duration patterns across both dimensions and helps identify time consumption patterns
- **Optimization Tips:**
  - Format duration in hours and minutes for readability
  - Add reference lines for target/benchmark durations
  - Consider using dual-axis if comparing with meeting count

### **2. Overall Dashboard Design**

#### **Layout Suggestions:**
- **Top Section:** Service Reliability & Support Report (Charts 1-3)
  - Arrange in a 2x2 grid with Chart 1 taking full width on top
  - Charts 2 and 3 side by side below
- **Bottom Section:** Platform Usage & Adoption Report (Charts 4-6)
  - Chart 4 (Pie chart) on the left, Charts 5 and 6 stacked on the right
- **Navigation:** Use dashboard tabs or sections to separate the two main reports
- **Filters:** Global filters at the top for Date Range, User Segment

#### **Performance Optimization:**
- **Extract Strategy:** 
  - Create extracts for all data sources
  - Schedule daily refresh during off-peak hours
  - Use incremental refresh for large fact tables
- **Filter Optimization:**
  - Use context filters for date ranges
  - Implement cascading filters (Category → Subcategory)
  - Limit initial data load with relevant date ranges
- **Data Prep Recommendations:**
  - Pre-aggregate data at appropriate grain levels
  - Create calculated fields at data source level
  - Index frequently filtered columns

#### **Color Scheme:**
- **Primary Colors:** Zoom brand colors (Blue #2D8CFF, Dark Blue #0E4F99)
- **Support Priority:** Red (High), Orange (Medium), Green (Low)
- **Status Colors:** Green (Resolved), Yellow (In Progress), Red (Escalated), Gray (Pending)
- **Feature Usage:** Use Tableau's default categorical palette for variety

#### **Typography:**
- **Headers:** Tableau Book Bold, 14pt
- **Labels:** Tableau Book, 10pt
- **Tooltips:** Tableau Book, 9pt
- **Ensure consistent font sizing across all charts**

#### **Interactive Elements:**

| Element Type | Description | Implementation |
|--------------|-------------|----------------|
| **Global Filters** | Date Range, User Segment | Parameter controls at dashboard level |
| **Drill-Down Actions** | Category → Subcategory | Hierarchy navigation in Chart 1 |
| **Filter Actions** | Click to filter other charts | Dashboard actions between related charts |
| **Highlight Actions** | Hover to highlight related data | Cross-chart highlighting |
| **URL Actions** | Link to detailed reports | Navigate to operational systems |
| **Parameter Controls** | Dynamic date selection | Date range picker, relative date options |
| **Quick Filters** | Priority, Status, Feature Type | Dropdown and checkbox filters |
| **Sort Controls** | Ascending/Descending options | Sort buttons on applicable charts |

#### **Dashboard Performance Considerations:**
- Limit initial data load to last 90 days
- Use show/hide containers for optional details
- Implement progressive disclosure for complex charts
- Monitor query performance and optimize slow-running calculations
- Consider using dashboard extensions for advanced functionality

#### **Mobile Responsiveness:**
- Create device-specific layouts for tablets and phones
- Simplify charts for smaller screens
- Use vertical layouts for mobile devices
- Test touch interactions and filter usability

#### **Data Refresh Strategy:**
- **Frequency:** Daily refresh at 6 AM
- **Incremental Refresh:** For fact tables based on load_date
- **Full Refresh:** Weekly for dimension tables
- **Monitoring:** Set up alerts for failed refreshes

#### **Security and Access:**
- Implement row-level security based on user roles
- Create different permission levels (View, Interact, Edit)
- Use Tableau Server/Cloud groups for access management
- Audit dashboard usage and performance regularly