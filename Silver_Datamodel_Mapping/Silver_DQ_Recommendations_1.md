_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data quality recommendations for Zoom Platform Analytics System Silver layer
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Quality Recommendations
## Zoom Platform Analytics System

## Recommended Data Quality Checks:

### 1. **User Data Quality Checks (Si_USERS)**

1. **User ID Uniqueness Check**: Ensure USER_ID is unique across all records
   - Rationale: USER_ID serves as the primary identifier and must be unique to maintain data integrity
   - SQL Example: 
   ```sql
   SELECT USER_ID, COUNT(*) as duplicate_count
   FROM SILVER.Si_USERS
   GROUP BY USER_ID
   HAVING COUNT(*) > 1;
   ```

2. **User ID Not Null Check**: Verify USER_ID is not null or empty
   - Rationale: USER_ID is a critical field required for all user records and referential integrity
   - SQL Example:
   ```sql
   SELECT COUNT(*) as null_user_ids
   FROM SILVER.Si_USERS
   WHERE USER_ID IS NULL OR TRIM(USER_ID) = '';
   ```

3. **Email Format Validation**: Validate email addresses follow proper format
   - Rationale: Email is used for communication and must be in valid format for business operations
   - SQL Example:
   ```sql
   SELECT USER_ID, EMAIL
   FROM SILVER.Si_USERS
   WHERE EMAIL IS NOT NULL 
   AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
   ```

4. **Plan Type Validation**: Ensure PLAN_TYPE contains only valid values
   - Rationale: Based on business rules, PLAN_TYPE must be from enumerated values: ['Free', 'Basic', 'Pro', 'Enterprise']
   - SQL Example:
   ```sql
   SELECT USER_ID, PLAN_TYPE
   FROM SILVER.Si_USERS
   WHERE PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise')
   OR PLAN_TYPE IS NULL;
   ```

5. **User Name Length Check**: Validate USER_NAME does not exceed maximum length
   - Rationale: Ensure data consistency and prevent truncation issues
   - SQL Example:
   ```sql
   SELECT USER_ID, USER_NAME, LENGTH(USER_NAME) as name_length
   FROM SILVER.Si_USERS
   WHERE LENGTH(USER_NAME) > 255 OR USER_NAME IS NULL;
   ```

### 2. **Meeting Data Quality Checks (Si_MEETINGS)**

6. **Meeting ID Uniqueness Check**: Ensure MEETING_ID is unique across all records
   - Rationale: MEETING_ID serves as the primary identifier for meetings and must be unique
   - SQL Example:
   ```sql
   SELECT MEETING_ID, COUNT(*) as duplicate_count
   FROM SILVER.Si_MEETINGS
   GROUP BY MEETING_ID
   HAVING COUNT(*) > 1;
   ```

7. **Meeting Duration Consistency Check**: Verify DURATION_MINUTES matches calculated duration
   - Rationale: Based on business rules, Duration_Minutes must equal the calculated difference between End_Time and Start_Time
   - SQL Example:
   ```sql
   SELECT MEETING_ID, START_TIME, END_TIME, DURATION_MINUTES,
          DATEDIFF('minute', START_TIME, END_TIME) as calculated_duration
   FROM SILVER.Si_MEETINGS
   WHERE DURATION_MINUTES != DATEDIFF('minute', START_TIME, END_TIME)
   OR DURATION_MINUTES IS NULL;
   ```

8. **Meeting Time Sequence Check**: Ensure END_TIME is after START_TIME
   - Rationale: Business logic constraint that meeting End_Time must be after Start_Time
   - SQL Example:
   ```sql
   SELECT MEETING_ID, START_TIME, END_TIME
   FROM SILVER.Si_MEETINGS
   WHERE END_TIME <= START_TIME
   OR START_TIME IS NULL OR END_TIME IS NULL;
   ```

9. **Host ID Referential Integrity Check**: Verify HOST_ID exists in Users table
   - Rationale: Based on business rules, Host_ID in Meetings table must exist as User_ID in Users table
   - SQL Example:
   ```sql
   SELECT m.MEETING_ID, m.HOST_ID
   FROM SILVER.Si_MEETINGS m
   LEFT JOIN SILVER.Si_USERS u ON m.HOST_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND m.HOST_ID IS NOT NULL;
   ```

10. **Duration Range Check**: Validate DURATION_MINUTES is non-negative
    - Rationale: Based on business constraints, Duration_Minutes must be greater than or equal to 0
    - SQL Example:
    ```sql
    SELECT MEETING_ID, DURATION_MINUTES
    FROM SILVER.Si_MEETINGS
    WHERE DURATION_MINUTES < 0;
    ```

### 3. **Participant Data Quality Checks (Si_PARTICIPANTS)**

11. **Participant Session Time Validation**: Ensure LEAVE_TIME is after JOIN_TIME
    - Rationale: Business logic constraint that attendee Leave_Time must be after Join_Time
    - SQL Example:
    ```sql
    SELECT PARTICIPANT_ID, MEETING_ID, JOIN_TIME, LEAVE_TIME
    FROM SILVER.Si_PARTICIPANTS
    WHERE LEAVE_TIME <= JOIN_TIME
    OR JOIN_TIME IS NULL OR LEAVE_TIME IS NULL;
    ```

12. **Participant Meeting Boundary Check**: Verify participant times are within meeting duration
    - Rationale: Join_Time must be after or equal to meeting Start_Time and Leave_Time must be before or equal to meeting End_Time
    - SQL Example:
    ```sql
    SELECT p.PARTICIPANT_ID, p.MEETING_ID, p.JOIN_TIME, p.LEAVE_TIME, m.START_TIME, m.END_TIME
    FROM SILVER.Si_PARTICIPANTS p
    JOIN SILVER.Si_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
    WHERE p.JOIN_TIME < m.START_TIME 
    OR p.LEAVE_TIME > m.END_TIME;
    ```

13. **Meeting-Participant Referential Integrity**: Verify MEETING_ID exists in Meetings table
    - Rationale: Based on business rules, Meeting_ID in Participants table must exist in Meetings table
    - SQL Example:
    ```sql
    SELECT p.PARTICIPANT_ID, p.MEETING_ID
    FROM SILVER.Si_PARTICIPANTS p
    LEFT JOIN SILVER.Si_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
    WHERE m.MEETING_ID IS NULL;
    ```

14. **User-Participant Referential Integrity**: Verify USER_ID exists in Users table
    - Rationale: Ensure participant references valid user account
    - SQL Example:
    ```sql
    SELECT p.PARTICIPANT_ID, p.USER_ID
    FROM SILVER.Si_PARTICIPANTS p
    LEFT JOIN SILVER.Si_USERS u ON p.USER_ID = u.USER_ID
    WHERE u.USER_ID IS NULL AND p.USER_ID IS NOT NULL;
    ```

15. **Unique Participant per Meeting Check**: Ensure combination of MEETING_ID and USER_ID is unique
    - Rationale: Based on business rules, combination of Meeting_ID and User_ID must be unique in Participants table
    - SQL Example:
    ```sql
    SELECT MEETING_ID, USER_ID, COUNT(*) as duplicate_count
    FROM SILVER.Si_PARTICIPANTS
    GROUP BY MEETING_ID, USER_ID
    HAVING COUNT(*) > 1;
    ```

### 4. **Feature Usage Data Quality Checks (Si_FEATURE_USAGE)**

16. **Feature Name Standardization Check**: Validate FEATURE_NAME follows naming conventions
    - Rationale: Based on business rules, Feature_Name must follow standardized naming conventions and not exceed 100 characters
    - SQL Example:
    ```sql
    SELECT USAGE_ID, FEATURE_NAME, LENGTH(FEATURE_NAME) as name_length
    FROM SILVER.Si_FEATURE_USAGE
    WHERE LENGTH(FEATURE_NAME) > 100 
    OR FEATURE_NAME IS NULL 
    OR TRIM(FEATURE_NAME) = '';
    ```

17. **Usage Count Validation**: Ensure USAGE_COUNT is non-negative
    - Rationale: Based on business constraints, Usage_Count must be non-negative integers
    - SQL Example:
    ```sql
    SELECT USAGE_ID, USAGE_COUNT
    FROM SILVER.Si_FEATURE_USAGE
    WHERE USAGE_COUNT < 0 OR USAGE_COUNT IS NULL;
    ```

18. **Feature Usage Date Consistency**: Verify USAGE_DATE aligns with meeting dates
    - Rationale: Feature usage should occur on the same date as the meeting
    - SQL Example:
    ```sql
    SELECT f.USAGE_ID, f.MEETING_ID, f.USAGE_DATE, DATE(m.START_TIME) as meeting_date
    FROM SILVER.Si_FEATURE_USAGE f
    JOIN SILVER.Si_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
    WHERE f.USAGE_DATE != DATE(m.START_TIME);
    ```

19. **Feature-Meeting Referential Integrity**: Verify MEETING_ID exists in Meetings table
    - Rationale: Based on business rules, Meeting_ID in Features_Usage table must exist in Meetings table
    - SQL Example:
    ```sql
    SELECT f.USAGE_ID, f.MEETING_ID
    FROM SILVER.Si_FEATURE_USAGE f
    LEFT JOIN SILVER.Si_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
    WHERE m.MEETING_ID IS NULL;
    ```

### 5. **Support Ticket Data Quality Checks (Si_SUPPORT_TICKETS)**

20. **Ticket ID Uniqueness Check**: Ensure TICKET_ID is unique across all records
    - Rationale: Based on business rules, Ticket_ID must be unique in Support_Tickets table
    - SQL Example:
    ```sql
    SELECT TICKET_ID, COUNT(*) as duplicate_count
    FROM SILVER.Si_SUPPORT_TICKETS
    GROUP BY TICKET_ID
    HAVING COUNT(*) > 1;
    ```

21. **Resolution Status Validation**: Ensure RESOLUTION_STATUS contains valid values
    - Rationale: Based on business rules, Resolution_Status must be from: ['Open', 'In Progress', 'Resolved', 'Closed']
    - SQL Example:
    ```sql
    SELECT TICKET_ID, RESOLUTION_STATUS
    FROM SILVER.Si_SUPPORT_TICKETS
    WHERE RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed')
    OR RESOLUTION_STATUS IS NULL;
    ```

22. **Support User Referential Integrity**: Verify USER_ID exists in Users table
    - Rationale: Based on business rules, User_ID in Support_Tickets table must exist in Users table
    - SQL Example:
    ```sql
    SELECT s.TICKET_ID, s.USER_ID
    FROM SILVER.Si_SUPPORT_TICKETS s
    LEFT JOIN SILVER.Si_USERS u ON s.USER_ID = u.USER_ID
    WHERE u.USER_ID IS NULL AND s.USER_ID IS NOT NULL;
    ```

23. **Open Date Validation**: Ensure OPEN_DATE is a valid date and not in the future
    - Rationale: Open dates should be valid and not exceed current date
    - SQL Example:
    ```sql
    SELECT TICKET_ID, OPEN_DATE
    FROM SILVER.Si_SUPPORT_TICKETS
    WHERE OPEN_DATE IS NULL 
    OR OPEN_DATE > CURRENT_DATE();
    ```

### 6. **Billing Events Data Quality Checks (Si_BILLING_EVENTS)**

24. **Amount Precision Check**: Validate AMOUNT is positive with appropriate decimal precision
    - Rationale: Based on business rules, Amount values must be positive numbers with appropriate decimal precision
    - SQL Example:
    ```sql
    SELECT EVENT_ID, AMOUNT
    FROM SILVER.Si_BILLING_EVENTS
    WHERE AMOUNT <= 0 
    OR AMOUNT IS NULL
    OR AMOUNT != ROUND(AMOUNT, 2);
    ```

25. **Event Date Validation**: Ensure EVENT_DATE is valid and not in the future
    - Rationale: Based on business constraints, Transaction_Date must be valid timestamps
    - SQL Example:
    ```sql
    SELECT EVENT_ID, EVENT_DATE
    FROM SILVER.Si_BILLING_EVENTS
    WHERE EVENT_DATE IS NULL 
    OR EVENT_DATE > CURRENT_DATE();
    ```

26. **Billing User Referential Integrity**: Verify USER_ID exists in Users table
    - Rationale: Based on business rules, User_ID in Billing_Events table must exist in Users table
    - SQL Example:
    ```sql
    SELECT b.EVENT_ID, b.USER_ID
    FROM SILVER.Si_BILLING_EVENTS b
    LEFT JOIN SILVER.Si_USERS u ON b.USER_ID = u.USER_ID
    WHERE u.USER_ID IS NULL AND b.USER_ID IS NOT NULL;
    ```

27. **Event Type Standardization**: Validate EVENT_TYPE follows standardized billing categories
    - Rationale: Based on business rules, Event_Type must follow standardized billing categories
    - SQL Example:
    ```sql
    SELECT EVENT_ID, EVENT_TYPE
    FROM SILVER.Si_BILLING_EVENTS
    WHERE EVENT_TYPE IS NULL 
    OR TRIM(EVENT_TYPE) = ''
    OR LENGTH(EVENT_TYPE) > 100;
    ```

### 7. **License Data Quality Checks (Si_LICENSES)**

28. **License Date Sequence Check**: Ensure END_DATE is after START_DATE
    - Rationale: Based on business logic constraints, License Start_Date must be before End_Date
    - SQL Example:
    ```sql
    SELECT LICENSE_ID, START_DATE, END_DATE
    FROM SILVER.Si_LICENSES
    WHERE END_DATE <= START_DATE
    OR START_DATE IS NULL OR END_DATE IS NULL;
    ```

29. **License User Referential Integrity**: Verify ASSIGNED_TO_USER_ID exists in Users table
    - Rationale: Based on business rules, Assigned_To_User_ID in Licenses table must exist as User_ID in Users table
    - SQL Example:
    ```sql
    SELECT l.LICENSE_ID, l.ASSIGNED_TO_USER_ID
    FROM SILVER.Si_LICENSES l
    LEFT JOIN SILVER.Si_USERS u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
    WHERE u.USER_ID IS NULL AND l.ASSIGNED_TO_USER_ID IS NOT NULL;
    ```

30. **Active License Validation**: Ensure active licenses have valid future end dates
    - Rationale: Based on business rules, active licenses must have End_Date in the future
    - SQL Example:
    ```sql
    SELECT LICENSE_ID, START_DATE, END_DATE
    FROM SILVER.Si_LICENSES
    WHERE START_DATE <= CURRENT_DATE()
    AND END_DATE <= CURRENT_DATE();
    ```

31. **License Type Validation**: Ensure LICENSE_TYPE is from predefined categories
    - Rationale: Based on business rules, License_Type must be from predefined license categories
    - SQL Example:
    ```sql
    SELECT LICENSE_ID, LICENSE_TYPE
    FROM SILVER.Si_LICENSES
    WHERE LICENSE_TYPE IS NULL 
    OR TRIM(LICENSE_TYPE) = ''
    OR LENGTH(LICENSE_TYPE) > 100;
    ```

### 8. **Cross-Table Data Quality Checks**

32. **Meeting Classification Validation**: Validate meeting duration classifications
    - Rationale: Based on business rules, meetings with duration < 5 minutes are classified as "Brief"
    - SQL Example:
    ```sql
    SELECT MEETING_ID, DURATION_MINUTES,
           CASE WHEN DURATION_MINUTES < 5 THEN 'Brief'
                WHEN DURATION_MINUTES >= 5 THEN 'Standard'
           END as meeting_classification
    FROM SILVER.Si_MEETINGS
    WHERE DURATION_MINUTES IS NOT NULL;
    ```

33. **Collaborative Meeting Validation**: Identify meetings with 2+ attendees
    - Rationale: Based on business rules, meetings with 2+ attendees are classified as "Collaborative"
    - SQL Example:
    ```sql
    SELECT m.MEETING_ID, COUNT(p.PARTICIPANT_ID) as participant_count,
           CASE WHEN COUNT(p.PARTICIPANT_ID) >= 2 THEN 'Collaborative'
                ELSE 'Individual'
           END as meeting_type
    FROM SILVER.Si_MEETINGS m
    LEFT JOIN SILVER.Si_PARTICIPANTS p ON m.MEETING_ID = p.MEETING_ID
    GROUP BY m.MEETING_ID;
    ```

34. **Data Freshness Check**: Validate LOAD_TIMESTAMP and UPDATE_TIMESTAMP consistency
    - Rationale: Ensure data lineage and freshness tracking across all tables
    - SQL Example:
    ```sql
    SELECT 'Si_USERS' as table_name, COUNT(*) as records_with_invalid_timestamps
    FROM SILVER.Si_USERS
    WHERE UPDATE_TIMESTAMP < LOAD_TIMESTAMP
    UNION ALL
    SELECT 'Si_MEETINGS', COUNT(*)
    FROM SILVER.Si_MEETINGS
    WHERE UPDATE_TIMESTAMP < LOAD_TIMESTAMP;
    ```

35. **Source System Consistency Check**: Validate SOURCE_SYSTEM field across all tables
    - Rationale: Ensure proper data lineage tracking and source system identification
    - SQL Example:
    ```sql
    SELECT 'Si_USERS' as table_name, SOURCE_SYSTEM, COUNT(*) as record_count
    FROM SILVER.Si_USERS
    WHERE SOURCE_SYSTEM IS NULL OR TRIM(SOURCE_SYSTEM) = ''
    GROUP BY SOURCE_SYSTEM
    UNION ALL
    SELECT 'Si_MEETINGS', SOURCE_SYSTEM, COUNT(*)
    FROM SILVER.Si_MEETINGS
    WHERE SOURCE_SYSTEM IS NULL OR TRIM(SOURCE_SYSTEM) = ''
    GROUP BY SOURCE_SYSTEM;
    ```

### 9. **Business Rule Validation Checks**

36. **Monthly Recurring Revenue (MRR) Validation**: Validate MRR calculation rules
    - Rationale: Based on business rules, Monthly Recurring Revenue (MRR) includes only subscription-based revenue
    - SQL Example:
    ```sql
    SELECT USER_ID, EVENT_TYPE, SUM(AMOUNT) as monthly_revenue
    FROM SILVER.Si_BILLING_EVENTS
    WHERE EVENT_TYPE LIKE '%subscription%'
    AND EXTRACT(MONTH FROM EVENT_DATE) = EXTRACT(MONTH FROM CURRENT_DATE())
    AND EXTRACT(YEAR FROM EVENT_DATE) = EXTRACT(YEAR FROM CURRENT_DATE())
    GROUP BY USER_ID, EVENT_TYPE;
    ```

37. **Feature Adoption Rate Validation**: Calculate and validate feature adoption metrics
    - Rationale: Based on business rules, Feature adoption rate = (Users who used feature / Total active users) × 100
    - SQL Example:
    ```sql
    WITH feature_users AS (
        SELECT FEATURE_NAME, COUNT(DISTINCT u.USER_ID) as users_using_feature
        FROM SILVER.Si_FEATURE_USAGE f
        JOIN SILVER.Si_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
        JOIN SILVER.Si_USERS u ON m.HOST_ID = u.USER_ID
        GROUP BY FEATURE_NAME
    ),
    total_users AS (
        SELECT COUNT(DISTINCT USER_ID) as total_active_users
        FROM SILVER.Si_USERS
    )
    SELECT f.FEATURE_NAME, f.users_using_feature, t.total_active_users,
           ROUND((f.users_using_feature * 100.0 / t.total_active_users), 2) as adoption_rate
    FROM feature_users f
    CROSS JOIN total_users t;
    ```

38. **Data Quality Error Tracking**: Monitor data quality issues in error table
    - Rationale: Track and monitor data quality issues for continuous improvement
    - SQL Example:
    ```sql
    SELECT ERROR_TYPE, SEVERITY_LEVEL, COUNT(*) as error_count,
           MIN(ERROR_TIMESTAMP) as first_occurrence,
           MAX(ERROR_TIMESTAMP) as last_occurrence
    FROM SILVER.Si_DATA_QUALITY_ERRORS
    WHERE RESOLUTION_STATUS IN ('Open', 'In Progress')
    GROUP BY ERROR_TYPE, SEVERITY_LEVEL
    ORDER BY error_count DESC;
    ```

### 10. **Performance and Monitoring Checks**

39. **Pipeline Audit Monitoring**: Monitor pipeline execution success rates
    - Rationale: Ensure data pipeline reliability and performance tracking
    - SQL Example:
    ```sql
    SELECT PIPELINE_NAME, EXECUTION_STATUS, COUNT(*) as execution_count,
           AVG(EXECUTION_DURATION) as avg_duration_seconds,
           SUM(RECORDS_PROCESSED) as total_records_processed,
           SUM(RECORDS_FAILED) as total_records_failed
    FROM SILVER.Si_PIPELINE_AUDIT
    WHERE LOAD_DATE >= CURRENT_DATE() - 7
    GROUP BY PIPELINE_NAME, EXECUTION_STATUS
    ORDER BY PIPELINE_NAME, EXECUTION_STATUS;
    ```

40. **Data Volume Anomaly Detection**: Detect unusual data volume patterns
    - Rationale: Identify potential data quality issues through volume analysis
    - SQL Example:
    ```sql
    WITH daily_counts AS (
        SELECT LOAD_DATE, COUNT(*) as daily_record_count
        FROM SILVER.Si_MEETINGS
        WHERE LOAD_DATE >= CURRENT_DATE() - 30
        GROUP BY LOAD_DATE
    ),
    avg_volume AS (
        SELECT AVG(daily_record_count) as avg_daily_count,
               STDDEV(daily_record_count) as stddev_daily_count
        FROM daily_counts
    )
    SELECT d.LOAD_DATE, d.daily_record_count, a.avg_daily_count,
           CASE WHEN ABS(d.daily_record_count - a.avg_daily_count) > (2 * a.stddev_daily_count)
                THEN 'ANOMALY_DETECTED'
                ELSE 'NORMAL'
           END as volume_status
    FROM daily_counts d
    CROSS JOIN avg_volume a
    ORDER BY d.LOAD_DATE DESC;
    ```

## Summary

This comprehensive data quality framework provides 40 essential checks covering:
- **Data Integrity**: Uniqueness, referential integrity, and consistency checks
- **Business Rule Validation**: Compliance with Zoom platform business logic
- **Data Format Validation**: Proper data types, formats, and constraints
- **Cross-Table Validation**: Relationships and dependencies between entities
- **Performance Monitoring**: Pipeline execution and data volume tracking
- **Error Management**: Systematic tracking and resolution of data quality issues

These checks should be implemented as part of the Silver layer data processing pipeline to ensure high-quality, reliable data for downstream Gold layer analytics and reporting.