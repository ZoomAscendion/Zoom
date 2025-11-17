____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Model data constraints and business rules for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
____________________________________________

# Model Data Constraints - Zoom Platform Analytics System

## 1. Data Expectations

### 1.1 Data Completeness
1. All meeting records must have valid Duration_Minutes, Start_Time, and End_Time values
2. User information must be complete for accurate user counting and meeting topic analysis
3. Feature usage data must be captured for all platform features to ensure comprehensive distribution analysis
4. Support activity records must contain complete category, sub-category, and resolution status information
5. Meeting activity data must link properly to both user and meeting entities for accurate reporting

### 1.2 Data Accuracy
1. Duration_Minutes must accurately reflect the actual meeting duration based on Start_Time and End_Time
2. Feature usage counts must represent actual feature utilization events
3. User counts must reflect unique active users without duplication
4. Support activity priority levels must accurately represent business urgency
5. Meeting types and categories must be correctly classified for accurate segmentation

### 1.3 Data Format
1. Start_Time and End_Time must be in valid timestamp format
2. Duration_Minutes must be in integer format representing minutes
3. Open_Date must be in valid date format
4. Feature_Name must follow consistent naming conventions
5. User names must follow standardized format for consistent reporting

### 1.4 Data Consistency
1. Meeting duration calculations must be consistent across all reports
2. User identification must be consistent across meeting activity and support activity data
3. Feature usage distribution calculations must use consistent methodology
4. Support category classifications must be applied uniformly
5. Date dimensions must be consistent across all temporal analyses

## 2. Constraints

### 2.1 Mandatory Fields
1. **Duration_Minutes**: Required for all meeting records to calculate average meeting duration and usage metrics
2. **Start_Time**: Mandatory for meeting records to establish temporal context and scheduling analysis
3. **End_Time**: Required for meeting records to calculate accurate duration and usage patterns
4. **User_ID**: Mandatory in support activities to link tickets to users and ensure proper user counting
5. **Meeting_ID**: Required in meeting activity records to establish proper relationships
6. **Resolution_Status**: Mandatory for support activities to track ticket progress and performance
7. **Open_Date**: Required for support activities to enable temporal analysis and aging reports

### 2.2 Uniqueness Requirements
1. **Meeting_ID**: Must be unique across all meeting records to prevent duplication in reporting
2. **User_ID**: Must be unique in user dimension to ensure accurate user counting
3. **Feature_Name**: Must be unique in feature dimension to prevent confusion in usage distribution
4. **Support Activity ID**: Must be unique to ensure accurate support ticket counting and tracking

### 2.3 Data Type Limitations
1. **Duration_Minutes**: Must be a non-negative integer value
2. **Start_Time**: Must be valid timestamp format with proper date and time components
3. **End_Time**: Must be valid timestamp format and chronologically after Start_Time
4. **Open_Date**: Must be valid date format within reasonable business date ranges
5. **Feature_Usage_Count**: Must be non-negative integer representing actual usage events

### 2.4 Dependencies
1. Meeting Activity records depend on the existence of corresponding Meeting and User records
2. Feature Usage records depend on the existence of corresponding Feature and Date dimension records
3. Support Activity records depend on the existence of corresponding User, Date, and Support Category dimension records
4. End_Time must be chronologically after or equal to Start_Time for the same meeting
5. Duration_Minutes should be calculable from Start_Time and End_Time difference

### 2.5 Referential Integrity
1. **Meeting_ID in Meeting Activity**: Must exist in the Meetings table to ensure valid meeting references
2. **Meeting_ID in Feature Usage**: Must exist in the Meetings table for proper feature usage tracking
3. **User_ID in Support Activity**: Must exist in the Users table to ensure valid user references
4. **Feature references in Feature Usage**: Must correspond to valid entries in Dim Feature table
5. **Date references**: Must correspond to valid entries in Dim Date table for temporal consistency

## 3. Business Rules

### 3.1 Data Processing Rules
1. Average meeting duration calculations must exclude meetings with zero or negative duration
2. User counting must eliminate duplicate entries within the same reporting period
3. Feature usage distribution must be calculated as percentages of total feature usage events
4. Support activity counting must consider only tickets within the specified reporting timeframe
5. Meeting per user calculations must account for both hosted and attended meetings

### 3.2 Reporting Logic Rules
1. Platform usage reports must aggregate data by meeting type and category for meaningful segmentation
2. Support reliability reports must group activities by resolution status and priority for actionable insights
3. User engagement metrics must consider both meeting participation and feature usage patterns
4. Temporal analysis must use consistent date hierarchies across all reports
5. KPI calculations must follow standardized formulas to ensure consistency across reporting periods

### 3.3 Transformation Guidelines
1. **Type and Resolution_Status**: Must be validated against predefined list of acceptable values
2. **Meeting Duration**: Should be calculated consistently using Start_Time and End_Time differences
3. **User Aggregations**: Must handle multiple meeting participations per user appropriately
4. **Feature Usage Distribution**: Should be normalized to show relative adoption rates
5. **Support Category Analysis**: Must maintain hierarchical relationships between category and sub-category
6. **Dimension Relationships**: Must enforce one-to-many or many-to-many relationships between dimension and fact tables as specified
7. **Date Filtering**: Must apply consistent date range logic across all temporal analyses