_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Platform Usage & Adoption Report - Tableau Dashboard Visual Recommendations
## *Version*: 1
## *Updated on*: 
_____________________________________________

# Tableau Dashboard Visuals Recommender
## Platform Usage & Adoption Report

### **Business Objective**
Monitor user engagement and platform adoption rates to identify growth trends and areas for improvement.

### **Data Model Overview**
**Primary Facts:**
- FACT_MEETING_ACTIVITY

**Primary Dimensions:**
- DIM_USER
- DIM_MEETING
- DIM_DATE

**Key Relationships:**
- FACT_MEETING_ACTIVITY → DIM_USER (USER_KEY)
- FACT_MEETING_ACTIVITY → DIM_MEETING (MEETING_KEY)
- FACT_MEETING_ACTIVITY → DIM_DATE (DATE_KEY)
---

## **1. Visual Recommendations**

### **Visual 1: Total Meeting Minutes Trend**
- **Data Element:** Track key usage metrics - Total Meeting Minutes over time
- **Query / Tableau Calculation:** `SUM([Duration Minutes])` by Date
- **Recommended Visual:** Line Chart with dual axis for trend and volume
- **Data Fields:** 
  - Rows: SUM(Duration_Minutes), COUNT(Meeting_Activity_ID)
  - Columns: MONTH(Meeting_Date)
  - Marks: Line for trend, Bar for volume
- **Calculations:** 
  - Total Meeting Minutes: `SUM([Duration Minutes])`
  - Meeting Count: `COUNT([Meeting Activity Id])`
  - Moving Average: `WINDOW_AVG(SUM([Duration Minutes]), -2, 0)`
- **Interactivity:** 
  - Date range filter (relative date filter)
  - Meeting type filter
  - Drill down from Year → Quarter → Month → Day
- **Justification:** Line charts effectively show trends over time, dual axis allows comparison of volume vs duration
- **Optimization Tips:** 
  - Use extract with incremental refresh
  - Create date hierarchy for efficient drilling
  - Use context filter for date range

### **Visual 2: Active Users Trend**
- **Data Element:** Track active users over time
- **Query / Tableau Calculation:** `COUNTD([User Key])` by Date
- **Recommended Visual:** Area Chart with reference lines
- **Data Fields:**
  - Rows: COUNTD(User_Key)
  - Columns: MONTH(Meeting_Date)
  - Color: User_Status
- **Calculations:**
  - Active Users: `COUNTD([User Key])`
  - Growth Rate: `(ZN(SUM([Active Users])) - LOOKUP(ZN(SUM([Active Users])), -1)) / ABS(LOOKUP(ZN(SUM([Active Users])), -1))`
  - Target Line: Parameter for monthly active user target
- **Interactivity:**
  - Date filter
  - Geographic region filter
  - Plan type filter
  - Tooltip showing growth percentage
- **Justification:** Area charts show cumulative growth patterns effectively
- **Optimization Tips:**
  - Use COUNTD with extract for performance
  - Index User_Key in data source
  - Use incremental extract refresh

### **Visual 3: Average Meeting Duration by Type and Category**
- **Data Element:** Average Meeting Duration by Meeting Type and Category
- **Query / Tableau Calculation:** `AVG([Duration Minutes])` grouped by Meeting Type and Category
- **Recommended Visual:** Horizontal Bar Chart (sorted)
- **Data Fields:**
  - Rows: Meeting_Type, Meeting_Category
  - Columns: AVG(Duration_Minutes)
  - Color: Meeting_Type
- **Calculations:**
  - Average Duration: `AVG([Duration Minutes])`
  - Duration Category: `IF AVG([Duration Minutes]) < 30 THEN "Short" ELSEIF AVG([Duration Minutes]) < 60 THEN "Medium" ELSE "Long" END`
- **Interactivity:**
  - Meeting type filter
  - Date range filter
  - Sort by duration (ascending/descending)
  - Drill through to meeting details
- **Justification:** Horizontal bars allow easy comparison across categories and accommodate long category names
- **Optimization Tips:**
  - Pre-aggregate at meeting type level
  - Use context filter for date range
  - Create calculated field for duration categories

### **Visual 4: Number of Users by Meeting Topics**
- **Data Element:** User distribution across different meeting topics
- **Query / Tableau Calculation:** `COUNTD([User Key])` by Meeting Topic
- **Recommended Visual:** Tree Map
- **Data Fields:**
  - Marks: COUNTD(User_Key)
  - Detail: Meeting_Topic
  - Size: COUNTD(User_Key)
  - Color: AVG(Meeting_Satisfaction_Score)
- **Calculations:**
  - Unique Users per Topic: `COUNTD([User Key])`
  - Topic Popularity Rank: `RANK(COUNTD([User Key]), 'desc')`
  - Satisfaction Score: `AVG([Meeting Satisfaction Score])`
- **Interactivity:**
  - Top N parameter (show top 10, 20, 50 topics)
  - Date range filter
  - Department/Industry filter
  - Click to filter other views
- **Justification:** Tree maps effectively show proportional relationships and can handle many categories
- **Optimization Tips:**
  - Limit to top N topics using parameter
  - Use extract for COUNTD performance
  - Create topic grouping for similar topics

### **Visual 5: Number of Meetings per User Distribution**
- **Data Element:** Distribution showing how many meetings each user conducts
- **Query / Tableau Calculation:** `COUNT([Meeting Activity Id])` per User
- **Recommended Visual:** Histogram with reference lines
- **Data Fields:**
  - Rows: Number of Records (Users)
  - Columns: COUNT(Meeting_Activity_ID) (binned)
  - Detail: User_Key
- **Calculations:**
  - Meetings per User: `{FIXED [User Key]: COUNT([Meeting Activity Id])}`
  - User Segments: `IF [Meetings per User] <= 5 THEN "Light User" ELSEIF [Meetings per User] <= 20 THEN "Regular User" ELSE "Power User" END`
  - Percentile Lines: `PERCENTILE([Meetings per User], 0.25)`, `PERCENTILE([Meetings per User], 0.75)`
- **Interactivity:**
  - Bin size parameter
  - User type filter
  - Plan type filter
  - Hover for user details
- **Justification:** Histograms show distribution patterns and help identify user behavior segments
- **Optimization Tips:**
  - Use LOD calculation for meetings per user
  - Create user segment dimension
  - Use extract for complex calculations

---

## **2. Overall Dashboard Design**

### **Layout Suggestions**
- **Top Row:** KPI cards showing key metrics (Total Meeting Minutes, Active Users, Average Duration, Top Feature)
- **Second Row:** Main trend charts (Meeting Minutes Trend, Active Users Trend) side by side
- **Third Row:** Meeting Duration by Type/Category (left), User Distribution by Topics (right)
- **Bottom Row:** Meetings per User Distribution (full width)
- **Filter Panel:** Left sidebar with global filters (Date Range, Meeting Type, User Segment)

### **Performance Optimization**
- **Extract Strategy:** 
  - Daily incremental refresh for fact tables
  - Full refresh weekly for dimension tables
  - Aggregate extracts for summary views
- **Filter Optimization:**
  - Use context filters for date ranges
  - Create indexed calculated fields for common filters
  - Limit filter options using relevant values only
- **Data Prep Recommendations:**
  - Pre-aggregate meeting statistics at daily level
  - Create user segment dimension
  - Index foreign keys in data source

### **Color Scheme**
- **Primary Colors:** Blue gradient (#1f77b4 to #aec7e8) for main metrics
- **Secondary Colors:** Orange (#ff7f0e) for highlights and alerts
- **Status Colors:** Green (#2ca02c) for positive trends, Red (#d62728) for negative trends
- **Neutral Colors:** Gray (#7f7f7f) for reference lines and secondary information

### **Typography**
- **Headers:** Tableau Book Bold, 14pt for dashboard title, 12pt for sheet titles
- **Body Text:** Tableau Book Regular, 10pt for labels and tooltips
- **KPI Numbers:** Tableau Book Bold, 16pt for main metrics
- **Annotations:** Tableau Book Italic, 9pt for explanatory text

### **Interactive Elements**

| Element Type | Purpose | Implementation | Target Sheets |
|--------------|---------|----------------|---------------|
| Date Range Filter | Time period selection | Relative date filter with custom ranges | All sheets |
| Meeting Type Filter | Filter by meeting categories | Multi-select dropdown | Meeting-related sheets |
| User Segment Filter | Filter by user behavior | Single select (Light/Regular/Power) | User-related sheets |
| Geographic Filter | Regional analysis | Map-based or dropdown | All sheets |
| Top N Parameter | Limit displayed items | Integer parameter with calculated field | Topic and feature views |
| Drill Down Action | Navigate time hierarchies | Filter action on date fields | Trend charts |
| Highlight Action | Cross-highlight related data | Highlight action between sheets | All sheets |
| Filter Action | Cross-filter dashboard | Filter action on category selection | Category-based charts |

### **Dashboard Actions Configuration**
- **Filter Actions:** Click on meeting type to filter all related views
- **Highlight Actions:** Hover over user segments to highlight across charts
- **Parameter Actions:** Click on time periods to update date range parameter

### **Performance Monitoring**
- Monitor dashboard load times (target: <10 seconds)
- Track extract refresh performance
- Monitor concurrent user limits
- Set up alerts for data freshness

### **Potential Pitfalls & Mitigation**
- **High Cardinality Fields:** Meeting topics may have too many unique values - use Top N filtering
- **Complex LOD Calculations:** Pre-calculate user segments in data prep
- **Large Date Ranges:** Default to last 90 days, allow expansion
- **Multiple COUNTD Operations:** Use extracts and consider approximation for very large datasets
- **Cross-database Joins:** Ensure all related tables are in same data source for performance
