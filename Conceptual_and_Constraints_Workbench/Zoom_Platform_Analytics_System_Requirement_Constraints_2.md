____________________________________________
## *Author*: AAVA
## *Created on*: 20-11-2025
## *Description*: Model data constraints and business rules for Zoom Platform Analytics System
## *Version*: 2
## *Updated on*: 20-11-2025
## *Changes*: Enhanced constraints with additional business rules and refined data expectations based on comprehensive requirements analysis
## *Reason*: Update requested to improve constraint completeness and alignment with reporting requirements
____________________________________________

# Model Data Constraints - Zoom Platform Analytics System

## 1. Data Expectations

### 1.1 Data Completeness
1. All meeting records must have valid Duration_Minutes values to support accurate usage analytics and average duration calculations
2. User information must be complete for all meeting participants to enable proper user engagement tracking and user count metrics
3. Feature usage data must be captured for all platform interactions to provide comprehensive usage distribution analysis
4. Support activity records must contain complete category and subcategory information for effective support analysis and categorization
5. All dimension tables must have complete reference data to support proper fact table relationships and referential integrity
6. Meeting type and category information must be complete for all meetings to support categorical analysis and reporting
7. Priority level must be specified for all support activities to enable priority-based workload analysis
8. Resolution status must be maintained for all support tickets to track support efficiency and performance

### 1.2 Data Accuracy
1. Meeting duration calculations must accurately reflect actual meeting times for reliable usage metrics and trend analysis
2. User counts must be precise and deduplicated to avoid inflated adoption statistics and ensure accurate reporting
3. Feature usage counts must accurately represent actual feature interactions without double-counting or system-generated events
4. Support ticket resolution status must reflect the current and accurate state of each support case for operational insights
5. Time-based data must be accurate to support proper trend analysis and temporal reporting requirements
6. Meeting type and category classifications must be accurate to support meaningful business insights
7. User participation metrics must accurately reflect actual engagement levels and activity patterns
8. Priority assignments must accurately reflect business importance and urgency levels

### 1.3 Data Format
1. Duration_Minutes must be stored as non-negative integer values for consistent mathematical operations
2. Start_Time and End_Time must follow valid timestamp formats for consistent time-based analysis and calculations
3. Open_Date must be stored in valid date format for proper chronological ordering and date-based grouping
4. User identifiers must follow consistent formatting across all related tables for proper relationship maintenance
5. Category and subcategory values must adhere to standardized naming conventions for consistent reporting
6. Priority levels must follow predefined enumeration values for consistent classification
7. Resolution status values must conform to standardized status definitions for accurate tracking
8. Meeting types must follow standardized classification schemes for consistent categorical analysis

### 1.4 Data Consistency
1. User references must be consistent across Meeting Activity, Feature Usage, and Support Activity tables for accurate cross-functional analysis
2. Meeting identifiers must be consistent between Meeting and Meeting Activity tables for proper relationship integrity
3. Feature names must be standardized across Feature Usage and Dim Feature tables for accurate feature analysis
4. Date references must be consistent across all fact tables and the Dim Date table for temporal consistency
5. Support category classifications must be consistent across Fact Support Activity and Dim Support Category tables
6. Meeting type and category values must be consistent across all meeting-related tables for accurate reporting
7. Priority level definitions must be consistent across all support-related processes and reporting
8. User classification must be consistent across Users and Dim User tables for accurate user analytics

## 2. Constraints

### 2.1 Mandatory Fields
1. Duration_Minutes: Required for all meeting records to calculate usage metrics and average meeting duration KPIs
2. Start_Time: Essential for meeting records to support time-based analysis and scheduling insights
3. User_ID: Mandatory in all user-related tables to maintain proper relationships and user tracking across reports
4. Meeting_ID: Required in Meeting Activity and Feature Usage tables to link activities to specific meetings
5. Resolution_Status: Mandatory for support activities to track ticket progress and support efficiency metrics
6. Category: Required for support activities to enable proper categorization and support volume analysis
7. Priority: Mandatory for support activities to enable priority-based workload analysis and resource allocation
8. Meeting_Type: Required for meetings to support categorical analysis and type-based reporting
9. Feature_Name: Mandatory in feature usage records to identify specific features for usage distribution analysis

### 2.2 Uniqueness Requirements
1. Meeting_ID: Must be unique within the Meeting table to ensure distinct meeting identification and proper relationships
2. User_ID: Must be unique within the Users and Dim User tables to prevent duplicate user records and ensure accurate counts
3. Feature_Name: Must be unique within Dim Feature table to avoid feature definition conflicts and ensure accurate usage tracking
4. Support Activity ID: Must be unique to ensure distinct tracking of individual support cases and accurate ticket counts
5. Combination of User_ID and Meeting_ID: Must be unique in Meeting Activity to prevent duplicate participation records

### 2.3 Data Type Limitations
1. Duration_Minutes: Must be non-negative integer values only, no decimal or negative values allowed for consistent calculations
2. Start_Time and End_Time: Must be valid timestamp data types with proper date-time formatting for temporal analysis
3. Open_Date: Must be valid date data type without time components for consistent date-based grouping and reporting
4. User counts: Must be positive integer values for accurate user metrics calculation and adoption tracking
5. Feature usage counts: Must be non-negative integer values to represent actual usage frequency accurately
6. Priority levels: Must be from predefined enumeration (High, Medium, Low) for consistent classification
7. Resolution status: Must be from predefined list of valid status values for accurate tracking
8. Meeting types: Must conform to predefined meeting type classifications for consistent reporting

### 2.4 Dependencies
1. Meeting Activity records depend on existing Meeting records for proper relationship integrity and meeting context
2. Feature Usage records depend on valid Feature definitions in Dim Feature table for accurate feature identification
3. Support Activity records depend on valid User records for proper user association and user-based analysis
4. All fact table date references depend on corresponding entries in Dim Date table for temporal consistency
5. Support categorization depends on predefined categories in Dim Support Category table for consistent classification
6. Attendees records depend on both valid Meeting and User records for proper attendance tracking
7. Meeting type classifications depend on predefined type definitions for consistent categorization

### 2.5 Referential Integrity
1. Meeting_ID in Meeting Activity must exist in the Meeting table to maintain meeting-activity relationships
2. Meeting_ID in Feature Usage must exist in the Meeting table to link feature usage to specific meetings
3. User_ID in Support Activity must exist in the Users table to maintain user-support relationships
4. Feature references in Feature Usage must correspond to valid entries in Dim Feature table
5. Date references across all fact tables must correspond to valid entries in Dim Date table
6. Meeting_ID in Attendees must exist in Meeting table for proper attendance tracking
7. User_ID in Attendees must exist in Users table for valid participant identification
8. Support category references must exist in Dim Support Category table for valid categorization

## 3. Business Rules

### 3.1 Data Processing Rules
1. Meeting duration calculations must exclude any system downtime or technical interruptions to ensure accurate usage metrics
2. User activity aggregations must account for multiple meeting participations by the same user to avoid double-counting
3. Feature usage metrics must be calculated based on distinct user interactions, not system-generated events
4. Support activity metrics must reflect actual customer-initiated requests, excluding automated system notifications
5. Average meeting duration calculations must exclude meetings shorter than 1 minute or longer than 24 hours as outliers
6. User count calculations must deduplicate users across different time periods and meeting types
7. Feature usage distribution must account for different feature categories and usage patterns
8. Support ticket volume must be calculated based on unique ticket identifiers to ensure accurate counts

### 3.2 Reporting Logic Rules
1. Platform usage reports must aggregate data by meeting type and category for meaningful business insights
2. User engagement metrics must be calculated based on active participation, not just meeting attendance
3. Feature usage distribution must be presented as percentages of total feature interactions for comparative analysis
4. Support activity reports must group tickets by priority level and resolution status for operational insights
5. Time-based trending must use consistent time periods (daily, weekly, monthly) for accurate comparison
6. Average meeting duration by type and category must exclude system-generated or test meetings
7. Number of meetings per user must account for both created and participated meetings for comprehensive analysis
8. Support category analysis must include both primary category and subcategory for detailed insights

### 3.3 Transformation Guidelines
1. Raw meeting data must be transformed to calculate derived metrics like average duration and user participation rates
2. User activity data must be aggregated to provide both individual and collective usage patterns
3. Feature usage data must be normalized to account for different feature types and usage patterns
4. Support data must be categorized and prioritized according to business-defined classification schemes
5. Dimension table relationships must be maintained during any data transformation processes to preserve analytical integrity
6. Meeting type and category transformations must follow standardized business classification rules
7. User segmentation must be applied consistently across all user-related analytics and reporting
8. Time-based aggregations must account for business calendar considerations and exclude non-business periods where applicable
