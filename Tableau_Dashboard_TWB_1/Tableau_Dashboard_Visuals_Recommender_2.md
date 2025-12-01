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
1. **DIM_DATE** - Time dimension with date hierarchies
2. **DIM_USER** - User information and demographics
3. **DIM_MEETING** - Meeting characteristics and categories
4. **DIM_FEATURE** - Platform features and capabilities
5. **DIM_LICENSE** - License types and pricing information
6. **DIM_SUPPORT_CATEGORY** - Support categorization and SLA definitions

#### **Fact Tables:**
1. **FACT_MEETING_ACTIVITY** - Meeting events and participation metrics
2. **FACT_FEATURE_USAGE** - Feature utilization and performance data
3. **FACT_REVENUE_ACTIVITY** - Financial transactions and revenue metrics
4. **FACT_SUPPORT_ACTIVITY** - Support ticket and resolution data

#### **Audit Table:**
1. **GO_AUDIT_LOG** - System process monitoring and data quality tracking

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

#### **Recommended Tableau Data Source Configuration:**

**Primary Data Source (Main Analytics):**
```sql
-- Custom SQL for comprehensive analytics view
SELECT 
    fma.*