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

### 1. **User Data Completeness and Validity Checks**
   - **Description**: Ensure all user records have complete and valid information
   - **Rationale**: User data is fundamental to all analytics and must be complete for accurate reporting. Business rules require valid User_ID and Plan_Type for all users.
   - **SQL Example**: 
   ```sql
   -- Check for missing critical user information
   SELECT COUNT(*) as invalid_users
   FROM SILVER.SI_USERS 
   WHERE USER_ID IS NULL 
      OR TRIM(USER_ID) = '' 
      OR EMAIL IS NULL 
      OR EMAIL NOT LIKE '%@%'
      OR PLAN_TYPE IS NULL;
   
   -- Validate Plan_Type against allowed values
   SELECT COUNT(*) as invalid_plan_types
   FROM SILVER.SI_USERS 
   WHERE PLAN_TYPE NOT IN ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE');
   ```

### 2. **Meeting Duration Validation**
   - **Description**: Validate meeting duration consistency and business logic
   - **Rationale**: Meeting duration must be accurate for usage analytics. Business rules exclude meetings shorter than 1 minute and require chronological consistency.
   - **SQL Example**: 
   ```sql
   -- Check for negative or zero duration meetings
   SELECT COUNT(*) as invalid_duration_meetings
   FROM SILVER.SI_MEETINGS 
   WHERE DURATION_MINUTES <= 0 
      OR DURATION_MINUTES IS NULL;
   
   -- Validate duration consistency with start/end times
   SELECT COUNT(*) as inconsistent_duration
   FROM SILVER.SI_MEETINGS 
   WHERE DURATION_MINUTES != DATEDIFF('minute', START_TIME, END_TIME)
      AND START_TIME IS NOT NULL 
      AND END_TIME IS NOT NULL;
   ```

### 3. **Timestamp Chronological Validation**
   - **Description**: Ensure all timestamp fields follow logical chronological order
   - **Rationale**: Temporal data integrity is crucial for accurate time-based analytics and trend analysis.
   - **SQL Example**: 
   ```sql
   -- Check for meetings where end time is before start time
   SELECT COUNT(*) as invalid_meeting_times
   FROM SILVER.SI_MEETINGS 
   WHERE END_TIME < START_TIME;
   
   -- Validate participant join/leave times within meeting duration
   SELECT COUNT(*) as invalid_participant_times
   FROM SILVER.SI_PARTICIPANTS p
   JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
   WHERE p.JOIN_TIME < m.START_TIME 
      OR p.LEAVE_TIME > m.END_TIME
      OR p.LEAVE_TIME < p.JOIN_TIME;
   ```

### 4. **Referential Integrity Validation**
   - **Description**: Validate foreign key relationships across all tables
   - **Rationale**: Business rules require all foreign key relationships to be valid for accurate cross-table analytics.
   - **SQL Example**: 
   ```sql
   -- Check for orphaned meeting records (host not in users table)
   SELECT COUNT(*) as orphaned_meetings
   FROM SILVER.SI_MEETINGS m
   LEFT JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID
   WHERE u.USER_ID IS NULL;
   
   -- Check for orphaned participant records
   SELECT COUNT(*) as orphaned_participants
   FROM SILVER.SI_PARTICIPANTS p
   LEFT JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL;
   
   -- Check for orphaned feature usage records
   SELECT COUNT(*) as orphaned_feature_usage
   FROM SILVER.SI_FEATURE_USAGE f
   LEFT JOIN SILVER.SI_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL;
   ```

### 5. **Support Ticket Data Quality Validation**
   - **Description**: Validate support ticket data completeness and business logic
   - **Rationale**: Support metrics require complete ticket information with valid status and type categorization.
   - **SQL Example**: 
   ```sql
   -- Check for incomplete support ticket data
   SELECT COUNT(*) as incomplete_tickets
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE TICKET_ID IS NULL 
      OR USER_ID IS NULL 
      OR TICKET_TYPE IS NULL 
      OR RESOLUTION_STATUS IS NULL;
   
   -- Validate resolution status values
   SELECT COUNT(*) as invalid_status
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS NOT IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED');
   
   -- Check for negative resolution times
   SELECT COUNT(*) as invalid_resolution_times
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_TIME_HOURS < 0;
   ```

### 6. **Billing Amount and Currency Validation**
   - **Description**: Validate billing event amounts and ensure positive values
   - **Rationale**: Revenue calculations require accurate positive amounts. Business rules specify amounts must be positive decimal numbers.
   - **SQL Example**: 
   ```sql
   -- Check for negative or zero billing amounts
   SELECT COUNT(*) as invalid_amounts
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT <= 0 OR AMOUNT IS NULL;
   
   -- Validate currency code format
   SELECT COUNT(*) as invalid_currency
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE CURRENCY_CODE IS NULL 
      OR LENGTH(CURRENCY_CODE) != 3
      OR CURRENCY_CODE NOT REGEXP '^[A-Z]{3}$';
   
   -- Check for reasonable amount ranges (detect outliers)
   SELECT COUNT(*) as potential_outliers
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT > 10000 OR AMOUNT < 0.01;
   ```

### 7. **License Date and Status Validation**
   - **Description**: Validate license date ranges and calculated status fields
   - **Rationale**: License management requires accurate date validation and status calculation for compliance and optimization.
   - **SQL Example**: 
   ```sql
   -- Check for invalid license date ranges
   SELECT COUNT(*) as invalid_license_dates
   FROM SILVER.SI_LICENSES 
   WHERE START_DATE > END_DATE 
      OR START_DATE IS NULL 
      OR END_DATE IS NULL;
   
   -- Validate license status calculation
   SELECT COUNT(*) as incorrect_status
   FROM SILVER.SI_LICENSES 
   WHERE (END_DATE < CURRENT_DATE AND LICENSE_STATUS != 'EXPIRED')
      OR (END_DATE >= CURRENT_DATE AND START_DATE <= CURRENT_DATE AND LICENSE_STATUS NOT IN ('ACTIVE', 'EXPIRING_SOON'))
      OR (START_DATE > CURRENT_DATE AND LICENSE_STATUS != 'FUTURE');
   
   -- Validate days to expiry calculation
   SELECT COUNT(*) as incorrect_expiry_calc
   FROM SILVER.SI_LICENSES 
   WHERE DAYS_TO_EXPIRY != CASE 
      WHEN END_DATE >= CURRENT_DATE THEN DATEDIFF('day', CURRENT_DATE, END_DATE)
      ELSE 0 
   END;
   ```

### 8. **Feature Usage Count Validation**
   - **Description**: Validate feature usage counts are non-negative integers
   - **Rationale**: Usage analytics require accurate non-negative counts for feature adoption calculations.
   - **SQL Example**: 
   ```sql
   -- Check for negative usage counts
   SELECT COUNT(*) as negative_usage_counts
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_COUNT < 0 OR USAGE_COUNT IS NULL;
   
   -- Validate feature usage dates within reasonable ranges
   SELECT COUNT(*) as invalid_usage_dates
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_DATE > CURRENT_DATE 
      OR USAGE_DATE < '2020-01-01';
   
   -- Check for feature usage without corresponding meetings
   SELECT COUNT(*) as orphaned_feature_usage
   FROM SILVER.SI_FEATURE_USAGE f
   LEFT JOIN SILVER.SI_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL;
   ```

### 9. **Participant Attendance Duration Validation**
   - **Description**: Validate calculated attendance duration against join/leave times
   - **Rationale**: Attendance metrics must be accurate for user engagement analysis and meeting effectiveness reporting.
   - **SQL Example**: 
   ```sql
   -- Validate attendance duration calculation
   SELECT COUNT(*) as incorrect_attendance_duration
   FROM SILVER.SI_PARTICIPANTS 
   WHERE ATTENDANCE_DURATION != DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)
      AND JOIN_TIME IS NOT NULL 
      AND LEAVE_TIME IS NOT NULL;
   
   -- Check for negative attendance durations
   SELECT COUNT(*) as negative_attendance
   FROM SILVER.SI_PARTICIPANTS 
   WHERE ATTENDANCE_DURATION < 0;
   
   -- Validate attendance duration doesn't exceed meeting duration
   SELECT COUNT(*) as excessive_attendance
   FROM SILVER.SI_PARTICIPANTS p
   JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
   WHERE p.ATTENDANCE_DURATION > m.DURATION_MINUTES;
   ```

### 10. **Email Format Validation**
   - **Description**: Validate email addresses follow proper format standards
   - **Rationale**: Valid email addresses are required for user communication and data quality in user management.
   - **SQL Example**: 
   ```sql
   -- Validate email format using regex
   SELECT COUNT(*) as invalid_emails
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NULL 
      OR EMAIL NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      OR LENGTH(EMAIL) > 254;
   
   -- Check for duplicate email addresses
   SELECT EMAIL, COUNT(*) as duplicate_count
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NOT NULL
   GROUP BY EMAIL 
   HAVING COUNT(*) > 1;
   ```

### 11. **Data Freshness and Load Validation**
   - **Description**: Monitor data freshness and validate load timestamps
   - **Rationale**: Ensures data is current and load processes are functioning correctly for real-time analytics.
   - **SQL Example**: 
   ```sql
   -- Check data freshness (data loaded within last 24 hours)
   SELECT 
      'SI_USERS' as table_name,
      MAX(LOAD_TIMESTAMP) as last_load,
      DATEDIFF('hour', MAX(LOAD_TIMESTAMP), CURRENT_TIMESTAMP) as hours_since_load
   FROM SILVER.SI_USERS
   UNION ALL
   SELECT 
      'SI_MEETINGS' as table_name,
      MAX(LOAD_TIMESTAMP) as last_load,
      DATEDIFF('hour', MAX(LOAD_TIMESTAMP), CURRENT_TIMESTAMP) as hours_since_load
   FROM SILVER.SI_MEETINGS;
   
   -- Validate load timestamps are not in the future
   SELECT COUNT(*) as future_load_timestamps
   FROM SILVER.SI_USERS 
   WHERE LOAD_TIMESTAMP > CURRENT_TIMESTAMP;
   ```

### 12. **Business Rule Compliance Validation**
   - **Description**: Validate adherence to specific business rules and constraints
   - **Rationale**: Ensures data meets business requirements for accurate reporting and analytics.
   - **SQL Example**: 
   ```sql
   -- Validate active user definition (users who hosted at least one meeting)
   SELECT u.USER_ID, u.USER_NAME
   FROM SILVER.SI_USERS u
   LEFT JOIN SILVER.SI_MEETINGS m ON u.USER_ID = m.HOST_ID
   WHERE m.HOST_ID IS NULL
   AND u.PLAN_TYPE IN ('PRO', 'BUSINESS', 'ENTERPRISE');
   
   -- Check for plan type consistency with license type
   SELECT COUNT(*) as inconsistent_plan_license
   FROM SILVER.SI_USERS u
   JOIN SILVER.SI_LICENSES l ON u.USER_ID = l.ASSIGNED_TO_USER_ID
   WHERE (u.PLAN_TYPE = 'ENTERPRISE' AND l.LICENSE_TYPE != 'ENTERPRISE')
      OR (u.PLAN_TYPE = 'BUSINESS' AND l.LICENSE_TYPE NOT IN ('BUSINESS', 'ENTERPRISE'))
      OR (u.PLAN_TYPE = 'PRO' AND l.LICENSE_TYPE NOT IN ('PRO', 'BUSINESS', 'ENTERPRISE'));
   
   -- Validate meeting duration excludes test meetings (< 1 minute)
   SELECT COUNT(*) as test_meetings
   FROM SILVER.SI_MEETINGS 
   WHERE DURATION_MINUTES < 1;
   ```

### 13. **Cross-Table Consistency Validation**
   - **Description**: Validate data consistency across related tables
   - **Rationale**: Ensures referential integrity and data consistency for accurate cross-table analytics.
   - **SQL Example**: 
   ```sql
   -- Validate user activity correlation with support tickets
   SELECT COUNT(*) as tickets_without_users
   FROM SILVER.SI_SUPPORT_TICKETS st
   LEFT JOIN SILVER.SI_USERS u ON st.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL;
   
   -- Check billing events have corresponding users
   SELECT COUNT(*) as billing_without_users
   FROM SILVER.SI_BILLING_EVENTS be
   LEFT JOIN SILVER.SI_USERS u ON be.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL;
   
   -- Validate feature usage timestamps fall within meeting timeframes
   SELECT COUNT(*) as invalid_feature_timing
   FROM SILVER.SI_FEATURE_USAGE f
   JOIN SILVER.SI_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
   WHERE f.USAGE_DATE != DATE(m.START_TIME);
   ```

### 14. **Null Value and Completeness Validation**
   - **Description**: Monitor null values in critical fields across all tables
   - **Rationale**: Ensures data completeness for accurate analytics and reporting.
   - **SQL Example**: 
   ```sql
   -- Check null percentages in critical fields
   SELECT 
      'USER_ID' as field_name,
      COUNT(*) as total_records,
      COUNT(USER_ID) as non_null_records,
      (COUNT(*) - COUNT(USER_ID)) as null_records,
      ROUND(((COUNT(*) - COUNT(USER_ID)) * 100.0 / COUNT(*)), 2) as null_percentage
   FROM SILVER.SI_USERS
   UNION ALL
   SELECT 
      'MEETING_ID' as field_name,
      COUNT(*) as total_records,
      COUNT(MEETING_ID) as non_null_records,
      (COUNT(*) - COUNT(MEETING_ID)) as null_records,
      ROUND(((COUNT(*) - COUNT(MEETING_ID)) * 100.0 / COUNT(*)), 2) as null_percentage
   FROM SILVER.SI_MEETINGS;
   ```

### 15. **Data Volume and Growth Validation**
   - **Description**: Monitor data volume trends and detect anomalies
   - **Rationale**: Helps identify data loading issues and ensures consistent data growth patterns.
   - **SQL Example**: 
   ```sql
   -- Monitor daily data volume trends
   SELECT 
      LOAD_DATE,
      COUNT(*) as daily_record_count,
      LAG(COUNT(*)) OVER (ORDER BY LOAD_DATE) as previous_day_count,
      COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY LOAD_DATE) as daily_change
   FROM SILVER.SI_MEETINGS 
   GROUP BY LOAD_DATE 
   ORDER BY LOAD_DATE DESC
   LIMIT 30;
   
   -- Detect unusual data volume spikes or drops
   WITH daily_stats AS (
      SELECT 
         LOAD_DATE,
         COUNT(*) as record_count
      FROM SILVER.SI_USERS 
      GROUP BY LOAD_DATE
   ),
   volume_analysis AS (
      SELECT 
         LOAD_DATE,
         record_count,
         AVG(record_count) OVER (ORDER BY LOAD_DATE ROWS BETWEEN 6 PRECEDING AND 1 PRECEDING) as avg_previous_7_days
      FROM daily_stats
   )
   SELECT *
   FROM volume_analysis
   WHERE record_count > avg_previous_7_days * 2 
      OR record_count < avg_previous_7_days * 0.5;
   ```