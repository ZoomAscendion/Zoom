_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Simplified data quality recommendations for Zoom Platform Analytics System Silver layer
## *Version*: 2 
## *Changes*: Simplified data quality checks by removing complex validations like referential integrity, cross-table consistency, and business rule compliance checks
## *Reason*: User requested simple silver data quality checks without complex validations like referential integrity
## *Updated on*: 
_____________________________________________

# Silver Layer Data Quality Recommendations
## Zoom Platform Analytics System - Simplified Version

## Recommended Data Quality Checks:

### 1. **User Data Null Value Validation**
   - **Description**: Check for null values in critical user fields
   - **Rationale**: User data completeness is essential for basic analytics. Null values in key fields can cause reporting issues.
   - **SQL Example**: 
   ```sql
   -- Check for null values in critical user fields
   SELECT COUNT(*) as null_user_ids
   FROM SILVER.SI_USERS 
   WHERE USER_ID IS NULL;
   
   SELECT COUNT(*) as null_emails
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NULL;
   
   SELECT COUNT(*) as null_plan_types
   FROM SILVER.SI_USERS 
   WHERE PLAN_TYPE IS NULL;
   ```

### 2. **Plan Type Value Validation**
   - **Description**: Validate Plan_Type contains only allowed values
   - **Rationale**: Plan type categorization must be consistent for accurate user segmentation and reporting.
   - **SQL Example**: 
   ```sql
   -- Validate Plan_Type against allowed values
   SELECT COUNT(*) as invalid_plan_types
   FROM SILVER.SI_USERS 
   WHERE PLAN_TYPE NOT IN ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE');
   ```

### 3. **Meeting Duration Range Validation**
   - **Description**: Validate meeting duration values are within reasonable ranges
   - **Rationale**: Meeting duration must be positive and reasonable for accurate usage analytics.
   - **SQL Example**: 
   ```sql
   -- Check for negative or zero duration meetings
   SELECT COUNT(*) as invalid_duration_meetings
   FROM SILVER.SI_MEETINGS 
   WHERE DURATION_MINUTES <= 0 OR DURATION_MINUTES IS NULL;
   
   -- Check for unreasonably long meetings (over 24 hours)
   SELECT COUNT(*) as excessive_duration_meetings
   FROM SILVER.SI_MEETINGS 
   WHERE DURATION_MINUTES > 1440;
   ```

### 4. **Timestamp Format Validation**
   - **Description**: Ensure timestamp fields are properly formatted and not null
   - **Rationale**: Valid timestamps are required for time-based analytics and reporting.
   - **SQL Example**: 
   ```sql
   -- Check for null timestamps in meetings
   SELECT COUNT(*) as null_start_times
   FROM SILVER.SI_MEETINGS 
   WHERE START_TIME IS NULL;
   
   SELECT COUNT(*) as null_end_times
   FROM SILVER.SI_MEETINGS 
   WHERE END_TIME IS NULL;
   
   -- Check for future timestamps (data quality issue)
   SELECT COUNT(*) as future_meetings
   FROM SILVER.SI_MEETINGS 
   WHERE START_TIME > CURRENT_TIMESTAMP;
   ```

### 5. **Support Ticket Status Validation**
   - **Description**: Validate support ticket status values are from predefined list
   - **Rationale**: Consistent status values are required for accurate support metrics and reporting.
   - **SQL Example**: 
   ```sql
   -- Check for null ticket statuses
   SELECT COUNT(*) as null_statuses
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS IS NULL;
   
   -- Validate resolution status values
   SELECT COUNT(*) as invalid_status
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS NOT IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED');
   ```

### 6. **Billing Amount Range Validation**
   - **Description**: Validate billing amounts are positive numbers
   - **Rationale**: Revenue calculations require positive amounts. Negative or zero amounts indicate data quality issues.
   - **SQL Example**: 
   ```sql
   -- Check for negative or zero billing amounts
   SELECT COUNT(*) as invalid_amounts
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT <= 0 OR AMOUNT IS NULL;
   
   -- Check for extremely high amounts (potential data entry errors)
   SELECT COUNT(*) as excessive_amounts
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT > 50000;
   ```

### 7. **License Date Range Validation**
   - **Description**: Validate license start and end dates are logical
   - **Rationale**: License date validation ensures accurate license management and compliance reporting.
   - **SQL Example**: 
   ```sql
   -- Check for null license dates
   SELECT COUNT(*) as null_start_dates
   FROM SILVER.SI_LICENSES 
   WHERE START_DATE IS NULL;
   
   SELECT COUNT(*) as null_end_dates
   FROM SILVER.SI_LICENSES 
   WHERE END_DATE IS NULL;
   
   -- Check for invalid date ranges (end before start)
   SELECT COUNT(*) as invalid_date_ranges
   FROM SILVER.SI_LICENSES 
   WHERE START_DATE > END_DATE;
   ```

### 8. **Feature Usage Count Validation**
   - **Description**: Validate feature usage counts are non-negative integers
   - **Rationale**: Usage counts must be non-negative for accurate feature adoption analytics.
   - **SQL Example**: 
   ```sql
   -- Check for negative usage counts
   SELECT COUNT(*) as negative_usage_counts
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_COUNT < 0;
   
   -- Check for null usage counts
   SELECT COUNT(*) as null_usage_counts
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_COUNT IS NULL;
   ```

### 9. **Email Format Validation**
   - **Description**: Validate email addresses follow basic format standards
   - **Rationale**: Valid email format is required for user communication and data quality.
   - **SQL Example**: 
   ```sql
   -- Basic email format validation
   SELECT COUNT(*) as invalid_emails
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NOT NULL 
   AND EMAIL NOT LIKE '%@%';
   
   -- Check for emails with multiple @ symbols
   SELECT COUNT(*) as malformed_emails
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NOT NULL 
   AND (LENGTH(EMAIL) - LENGTH(REPLACE(EMAIL, '@', ''))) != 1;
   ```

### 10. **Participant Attendance Duration Validation**
   - **Description**: Validate attendance duration is non-negative
   - **Rationale**: Attendance duration must be positive for accurate engagement metrics.
   - **SQL Example**: 
   ```sql
   -- Check for negative attendance durations
   SELECT COUNT(*) as negative_attendance
   FROM SILVER.SI_PARTICIPANTS 
   WHERE ATTENDANCE_DURATION < 0;
   
   -- Check for null attendance durations
   SELECT COUNT(*) as null_attendance
   FROM SILVER.SI_PARTICIPANTS 
   WHERE ATTENDANCE_DURATION IS NULL;
   ```

### 11. **Data Freshness Validation**
   - **Description**: Monitor when data was last loaded into each table
   - **Rationale**: Ensures data is current and load processes are functioning correctly.
   - **SQL Example**: 
   ```sql
   -- Check data freshness for each table
   SELECT 
      'SI_USERS' as table_name,
      MAX(LOAD_TIMESTAMP) as last_load_time,
      DATEDIFF('hour', MAX(LOAD_TIMESTAMP), CURRENT_TIMESTAMP) as hours_since_load
   FROM SILVER.SI_USERS
   UNION ALL
   SELECT 
      'SI_MEETINGS' as table_name,
      MAX(LOAD_TIMESTAMP) as last_load_time,
      DATEDIFF('hour', MAX(LOAD_TIMESTAMP), CURRENT_TIMESTAMP) as hours_since_load
   FROM SILVER.SI_MEETINGS;
   ```

### 12. **Record Count Validation**
   - **Description**: Monitor daily record counts for anomaly detection
   - **Rationale**: Unusual record count changes may indicate data loading issues.
   - **SQL Example**: 
   ```sql
   -- Monitor daily record counts
   SELECT 
      DATE(LOAD_TIMESTAMP) as load_date,
      COUNT(*) as daily_record_count
   FROM SILVER.SI_USERS 
   GROUP BY DATE(LOAD_TIMESTAMP) 
   ORDER BY load_date DESC
   LIMIT 7;
   
   -- Check for empty tables
   SELECT 
      'SI_USERS' as table_name,
      COUNT(*) as record_count
   FROM SILVER.SI_USERS
   UNION ALL
   SELECT 
      'SI_MEETINGS' as table_name,
      COUNT(*) as record_count
   FROM SILVER.SI_MEETINGS;
   ```

### 13. **String Length Validation**
   - **Description**: Validate string fields are within expected length limits
   - **Rationale**: Extremely long strings may indicate data truncation or input errors.
   - **SQL Example**: 
   ```sql
   -- Check for excessively long user names
   SELECT COUNT(*) as long_user_names
   FROM SILVER.SI_USERS 
   WHERE LENGTH(USER_NAME) > 100;
   
   -- Check for excessively long meeting topics
   SELECT COUNT(*) as long_meeting_topics
   FROM SILVER.SI_MEETINGS 
   WHERE LENGTH(MEETING_TOPIC) > 500;
   ```

### 14. **Duplicate ID Validation**
   - **Description**: Check for duplicate primary key values
   - **Rationale**: Duplicate IDs can cause data integrity issues and incorrect analytics.
   - **SQL Example**: 
   ```sql
   -- Check for duplicate user IDs
   SELECT USER_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_USERS 
   GROUP BY USER_ID 
   HAVING COUNT(*) > 1;
   
   -- Check for duplicate meeting IDs
   SELECT MEETING_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_MEETINGS 
   GROUP BY MEETING_ID 
   HAVING COUNT(*) > 1;
   ```

### 15. **Numeric Precision Validation**
   - **Description**: Validate numeric fields have appropriate precision
   - **Rationale**: Ensures numeric data is stored with correct precision for calculations.
   - **SQL Example**: 
   ```sql
   -- Check for billing amounts with excessive decimal places
   SELECT COUNT(*) as excessive_precision
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT != ROUND(AMOUNT, 2);
   
   -- Check for negative participant counts (if applicable)
   SELECT COUNT(*) as negative_counts
   FROM SILVER.SI_MEETINGS 
   WHERE PARTICIPANT_COUNT < 0;
   ```