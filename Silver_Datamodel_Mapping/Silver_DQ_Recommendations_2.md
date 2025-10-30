_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data quality recommendations for Zoom Platform Analytics System Silver layer with enhanced bad data detection
## *Version*: 2 
## *Updated on*: 
## *Changes*: Enhanced data quality checks based on specific bad data patterns identified in production data
## *Reason*: Added comprehensive validation rules for all identified bad data types including missing values, invalid formats, temporal logic violations, and referential integrity issues
_____________________________________________

# Silver Layer Data Quality Recommendations
## Zoom Platform Analytics System - Enhanced Version

## 1. **WEBINARS Data Quality Checks (SILVER.SI_WEBINARS)**

### 1.1 **Missing END_TIME Validation Check**
   - **Rationale**: END_TIME is mandatory for calculating webinar duration and ensuring complete session tracking
   - **SQL Example**:
   ```sql
   -- Check for missing END_TIME
   SELECT COUNT(*) as missing_end_time_count
   FROM SILVER.SI_WEBINARS 
   WHERE END_TIME IS NULL;
   ```

### 1.2 **Negative REGISTRANTS Validation Check**
   - **Rationale**: REGISTRANTS count cannot be negative as it represents actual user registrations
   - **SQL Example**:
   ```sql
   -- Check for negative registrants
   SELECT COUNT(*) as negative_registrants_count
   FROM SILVER.SI_WEBINARS 
   WHERE REGISTRANTS < 0;
   ```

### 1.3 **END_TIME Earlier Than START_TIME Check**
   - **Rationale**: END_TIME must be after START_TIME to ensure logical temporal sequence
   - **SQL Example**:
   ```sql
   -- Check for invalid time sequence
   SELECT COUNT(*) as invalid_time_sequence_count
   FROM SILVER.SI_WEBINARS 
   WHERE END_TIME < START_TIME;
   ```

### 1.4 **Duplicate WEBINAR_ID Check**
   - **Rationale**: WEBINAR_ID must be unique to maintain data integrity and prevent duplicate records
   - **SQL Example**:
   ```sql
   -- Check for duplicate webinar IDs
   SELECT WEBINAR_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_WEBINARS 
   GROUP BY WEBINAR_ID 
   HAVING COUNT(*) > 1;
   ```

### 1.5 **Null WEBINAR_TOPIC Check**
   - **Rationale**: WEBINAR_TOPIC is essential for webinar identification and reporting
   - **SQL Example**:
   ```sql
   -- Check for null webinar topics
   SELECT COUNT(*) as null_topic_count
   FROM SILVER.SI_WEBINARS 
   WHERE WEBINAR_TOPIC IS NULL OR TRIM(WEBINAR_TOPIC) = '';
   ```

### 1.6 **Invalid SOURCE_SYSTEM Check**
   - **Rationale**: SOURCE_SYSTEM must be from valid predefined systems for data lineage tracking
   - **SQL Example**:
   ```sql
   -- Check for invalid source systems
   SELECT SOURCE_SYSTEM, COUNT(*) as invalid_count
   FROM SILVER.SI_WEBINARS 
   WHERE SOURCE_SYSTEM NOT IN ('ZOOM_API', 'ZOOM_WEBHOOK', 'ZOOM_EXPORT')
   GROUP BY SOURCE_SYSTEM;
   ```

## 2. **USERS Data Quality Checks (SILVER.SI_USERS)**

### 2.1 **Missing EMAIL Validation Check**
   - **Rationale**: EMAIL is mandatory for user identification and communication
   - **SQL Example**:
   ```sql
   -- Check for missing email addresses
   SELECT COUNT(*) as missing_email_count
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NULL OR TRIM(EMAIL) = '';
   ```

### 2.2 **Invalid Email Format Check**
   - **Rationale**: EMAIL must follow valid format pattern for proper communication and data integrity
   - **SQL Example**:
   ```sql
   -- Check for invalid email formats
   SELECT COUNT(*) as invalid_email_format_count
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NOT NULL 
   AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$');
   ```

### 2.3 **Duplicate USER_ID Check**
   - **Rationale**: USER_ID must be unique across the system to maintain referential integrity
   - **SQL Example**:
   ```sql
   -- Check for duplicate user IDs
   SELECT USER_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_USERS 
   GROUP BY USER_ID 
   HAVING COUNT(*) > 1;
   ```

### 2.4 **Null USER_NAME Check**
   - **Rationale**: USER_NAME is essential for user identification and display purposes
   - **SQL Example**:
   ```sql
   -- Check for null user names
   SELECT COUNT(*) as null_username_count
   FROM SILVER.SI_USERS 
   WHERE USER_NAME IS NULL OR TRIM(USER_NAME) = '';
   ```

### 2.5 **Invalid PLAN_TYPE Check**
   - **Rationale**: PLAN_TYPE must be from predefined list for proper subscription management
   - **SQL Example**:
   ```sql
   -- Check for invalid plan types
   SELECT PLAN_TYPE, COUNT(*) as invalid_count
   FROM SILVER.SI_USERS 
   WHERE PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise')
   GROUP BY PLAN_TYPE;
   ```

### 2.6 **UPDATE_TIMESTAMP Earlier Than LOAD_TIMESTAMP Check**
   - **Rationale**: UPDATE_TIMESTAMP should not be earlier than LOAD_TIMESTAMP for logical data processing sequence
   - **SQL Example**:
   ```sql
   -- Check for invalid timestamp sequence
   SELECT COUNT(*) as invalid_timestamp_sequence_count
   FROM SILVER.SI_USERS 
   WHERE UPDATE_TIMESTAMP < LOAD_TIMESTAMP;
   ```

### 2.7 **Future LOAD_TIMESTAMP Check**
   - **Rationale**: LOAD_TIMESTAMP cannot be in the future as it represents when data was loaded
   - **SQL Example**:
   ```sql
   -- Check for future load timestamps
   SELECT COUNT(*) as future_load_timestamp_count
   FROM SILVER.SI_USERS 
   WHERE LOAD_TIMESTAMP > CURRENT_TIMESTAMP();
   ```

### 2.8 **Non-String Email Values Check**
   - **Rationale**: EMAIL field must contain string values, not numeric or other data types
   - **SQL Example**:
   ```sql
   -- Check for non-string email values (basic validation)
   SELECT COUNT(*) as non_string_email_count
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NOT NULL 
   AND REGEXP_LIKE(EMAIL, '^[0-9]+$'); -- Pure numeric emails are invalid
   ```

## 3. **SUPPORT_TICKETS Data Quality Checks (SILVER.SI_SUPPORT_TICKETS)**

### 3.1 **Invalid USER_ID Format Check**
   - **Rationale**: USER_ID must follow consistent format pattern for proper referential integrity
   - **SQL Example**:
   ```sql
   -- Check for invalid user ID formats
   SELECT COUNT(*) as invalid_user_id_format_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE USER_ID IS NOT NULL 
   AND NOT REGEXP_LIKE(USER_ID, '^[A-Za-z0-9_-]+$');
   ```

### 3.2 **Future OPEN_DATE Check**
   - **Rationale**: OPEN_DATE cannot be in the future as tickets cannot be opened in future dates
   - **SQL Example**:
   ```sql
   -- Check for future open dates
   SELECT COUNT(*) as future_open_date_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE OPEN_DATE > CURRENT_DATE();
   ```

### 3.3 **Null USER_ID Check**
   - **Rationale**: USER_ID is mandatory for associating tickets with users
   - **SQL Example**:
   ```sql
   -- Check for null user IDs
   SELECT COUNT(*) as null_user_id_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE USER_ID IS NULL;
   ```

### 3.4 **Invalid RESOLUTION_STATUS Check**
   - **Rationale**: RESOLUTION_STATUS must be from predefined list for proper ticket tracking
   - **SQL Example**:
   ```sql
   -- Check for invalid resolution status
   SELECT RESOLUTION_STATUS, COUNT(*) as invalid_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed')
   GROUP BY RESOLUTION_STATUS;
   ```

### 3.5 **UPDATE_TIMESTAMP Earlier Than LOAD_TIMESTAMP Check**
   - **Rationale**: UPDATE_TIMESTAMP should not be earlier than LOAD_TIMESTAMP for logical sequence
   - **SQL Example**:
   ```sql
   -- Check for invalid timestamp sequence
   SELECT COUNT(*) as invalid_timestamp_sequence_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE UPDATE_TIMESTAMP < LOAD_TIMESTAMP;
   ```

### 3.6 **Missing SOURCE_SYSTEM Check**
   - **Rationale**: SOURCE_SYSTEM is mandatory for data lineage and audit purposes
   - **SQL Example**:
   ```sql
   -- Check for missing source system
   SELECT COUNT(*) as missing_source_system_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE SOURCE_SYSTEM IS NULL OR TRIM(SOURCE_SYSTEM) = '';
   ```

### 3.7 **Invalid TICKET_TYPE Check**
   - **Rationale**: TICKET_TYPE must be from predefined categories for proper classification
   - **SQL Example**:
   ```sql
   -- Check for invalid ticket types
   SELECT TICKET_TYPE, COUNT(*) as invalid_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE TICKET_TYPE NOT IN ('Technical', 'Billing', 'Feature Request', 'Bug Report')
   GROUP BY TICKET_TYPE;
   ```

### 3.8 **Duplicate TICKET_ID Check**
   - **Rationale**: TICKET_ID must be unique to prevent duplicate ticket records
   - **SQL Example**:
   ```sql
   -- Check for duplicate ticket IDs
   SELECT TICKET_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   GROUP BY TICKET_ID 
   HAVING COUNT(*) > 1;
   ```

### 3.9 **Negative TICKET_ID Check**
   - **Rationale**: TICKET_ID should be positive integer for proper identification
   - **SQL Example**:
   ```sql
   -- Check for negative ticket IDs
   SELECT COUNT(*) as negative_ticket_id_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE TRY_CAST(TICKET_ID AS INTEGER) < 0;
   ```

## 4. **PARTICIPANTS Data Quality Checks (SILVER.SI_PARTICIPANTS)**

### 4.1 **Missing LEAVE_TIME Check**
   - **Rationale**: LEAVE_TIME is essential for calculating participation duration
   - **SQL Example**:
   ```sql
   -- Check for missing leave time
   SELECT COUNT(*) as missing_leave_time_count
   FROM SILVER.SI_PARTICIPANTS 
   WHERE LEAVE_TIME IS NULL;
   ```

### 4.2 **LEAVE_TIME Earlier Than JOIN_TIME Check**
   - **Rationale**: LEAVE_TIME must be after JOIN_TIME for logical participation sequence
   - **SQL Example**:
   ```sql
   -- Check for invalid participation time sequence
   SELECT COUNT(*) as invalid_participation_sequence_count
   FROM SILVER.SI_PARTICIPANTS 
   WHERE LEAVE_TIME < JOIN_TIME;
   ```

### 4.3 **Null USER_ID Check**
   - **Rationale**: USER_ID is mandatory for associating participants with users
   - **SQL Example**:
   ```sql
   -- Check for null user IDs
   SELECT COUNT(*) as null_user_id_count
   FROM SILVER.SI_PARTICIPANTS 
   WHERE USER_ID IS NULL;
   ```

### 4.4 **Invalid SOURCE_SYSTEM Check**
   - **Rationale**: SOURCE_SYSTEM must be from valid predefined systems
   - **SQL Example**:
   ```sql
   -- Check for invalid source systems
   SELECT SOURCE_SYSTEM, COUNT(*) as invalid_count
   FROM SILVER.SI_PARTICIPANTS 
   WHERE SOURCE_SYSTEM NOT IN ('ZOOM_API', 'ZOOM_WEBHOOK', 'ZOOM_EXPORT')
   GROUP BY SOURCE_SYSTEM;
   ```

### 4.5 **Duplicate PARTICIPANT_ID Check**
   - **Rationale**: PARTICIPANT_ID must be unique to prevent duplicate participation records
   - **SQL Example**:
   ```sql
   -- Check for duplicate participant IDs
   SELECT PARTICIPANT_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_PARTICIPANTS 
   GROUP BY PARTICIPANT_ID 
   HAVING COUNT(*) > 1;
   ```

### 4.6 **Future Timestamps Check**
   - **Rationale**: JOIN_TIME and LEAVE_TIME cannot be in the future
   - **SQL Example**:
   ```sql
   -- Check for future timestamps
   SELECT COUNT(*) as future_timestamps_count
   FROM SILVER.SI_PARTICIPANTS 
   WHERE JOIN_TIME > CURRENT_TIMESTAMP() OR LEAVE_TIME > CURRENT_TIMESTAMP();
   ```

### 4.7 **Non-String MEETING_ID Check**
   - **Rationale**: MEETING_ID should be string format, not purely numeric
   - **SQL Example**:
   ```sql
   -- Check for non-string meeting IDs (basic validation)
   SELECT COUNT(*) as non_string_meeting_id_count
   FROM SILVER.SI_PARTICIPANTS 
   WHERE MEETING_ID IS NOT NULL 
   AND REGEXP_LIKE(MEETING_ID, '^[0-9]+$') 
   AND LENGTH(MEETING_ID) < 5; -- Too short to be valid meeting ID
   ```

## 5. **MEETINGS Data Quality Checks (SILVER.SI_MEETINGS)**

### 5.1 **END_TIME Earlier Than START_TIME Check**
   - **Rationale**: END_TIME must be after START_TIME for logical meeting duration
   - **SQL Example**:
   ```sql
   -- Check for invalid meeting time sequence
   SELECT COUNT(*) as invalid_meeting_sequence_count
   FROM SILVER.SI_MEETINGS 
   WHERE END_TIME < START_TIME;
   ```

### 5.2 **Null MEETING_TOPIC Check**
   - **Rationale**: MEETING_TOPIC is essential for meeting identification and reporting
   - **SQL Example**:
   ```sql
   -- Check for null meeting topics
   SELECT COUNT(*) as null_topic_count
   FROM SILVER.SI_MEETINGS 
   WHERE MEETING_TOPIC IS NULL OR TRIM(MEETING_TOPIC) = '';
   ```

### 5.3 **Negative DURATION Check**
   - **Rationale**: DURATION_MINUTES cannot be negative
   - **SQL Example**:
   ```sql
   -- Check for negative duration
   SELECT COUNT(*) as negative_duration_count
   FROM SILVER.SI_MEETINGS 
   WHERE DURATION_MINUTES < 0;
   ```

### 5.4 **Invalid SOURCE_SYSTEM Check**
   - **Rationale**: SOURCE_SYSTEM must be from valid predefined systems
   - **SQL Example**:
   ```sql
   -- Check for invalid source systems
   SELECT SOURCE_SYSTEM, COUNT(*) as invalid_count
   FROM SILVER.SI_MEETINGS 
   WHERE SOURCE_SYSTEM NOT IN ('ZOOM_API', 'ZOOM_WEBHOOK', 'ZOOM_EXPORT')
   GROUP BY SOURCE_SYSTEM;
   ```

### 5.5 **Duplicate MEETING_ID Check**
   - **Rationale**: MEETING_ID must be unique to prevent duplicate meeting records
   - **SQL Example**:
   ```sql
   -- Check for duplicate meeting IDs
   SELECT MEETING_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_MEETINGS 
   GROUP BY MEETING_ID 
   HAVING COUNT(*) > 1;
   ```

### 5.6 **Null HOST_ID Check**
   - **Rationale**: HOST_ID is mandatory for associating meetings with hosts
   - **SQL Example**:
   ```sql
   -- Check for null host IDs
   SELECT COUNT(*) as null_host_id_count
   FROM SILVER.SI_MEETINGS 
   WHERE HOST_ID IS NULL;
   ```

### 5.7 **Future Timestamps Check**
   - **Rationale**: START_TIME and END_TIME should not be in the future for completed meetings
   - **SQL Example**:
   ```sql
   -- Check for future timestamps
   SELECT COUNT(*) as future_timestamps_count
   FROM SILVER.SI_MEETINGS 
   WHERE START_TIME > CURRENT_TIMESTAMP() OR END_TIME > CURRENT_TIMESTAMP();
   ```

## 6. **LICENSES Data Quality Checks (SILVER.SI_LICENSES)**

### 6.1 **END_DATE Before START_DATE Check**
   - **Rationale**: END_DATE must be after START_DATE for valid license period
   - **SQL Example**:
   ```sql
   -- Check for invalid license date sequence
   SELECT COUNT(*) as invalid_license_sequence_count
   FROM SILVER.SI_LICENSES 
   WHERE END_DATE < START_DATE;
   ```

### 6.2 **Null LICENSE_TYPE Check**
   - **Rationale**: LICENSE_TYPE is mandatory for license classification
   - **SQL Example**:
   ```sql
   -- Check for null license types
   SELECT COUNT(*) as null_license_type_count
   FROM SILVER.SI_LICENSES 
   WHERE LICENSE_TYPE IS NULL OR TRIM(LICENSE_TYPE) = '';
   ```

### 6.3 **Invalid SOURCE_SYSTEM Check**
   - **Rationale**: SOURCE_SYSTEM must be from valid predefined systems
   - **SQL Example**:
   ```sql
   -- Check for invalid source systems
   SELECT SOURCE_SYSTEM, COUNT(*) as invalid_count
   FROM SILVER.SI_LICENSES 
   WHERE SOURCE_SYSTEM NOT IN ('ZOOM_API', 'ZOOM_WEBHOOK', 'ZOOM_EXPORT')
   GROUP BY SOURCE_SYSTEM;
   ```

### 6.4 **Duplicate LICENSE_ID Check**
   - **Rationale**: LICENSE_ID must be unique to prevent duplicate license records
   - **SQL Example**:
   ```sql
   -- Check for duplicate license IDs
   SELECT LICENSE_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_LICENSES 
   GROUP BY LICENSE_ID 
   HAVING COUNT(*) > 1;
   ```

### 6.5 **START_DATE in Future Check**
   - **Rationale**: START_DATE should not be in the future for active licenses
   - **SQL Example**:
   ```sql
   -- Check for future start dates
   SELECT COUNT(*) as future_start_date_count
   FROM SILVER.SI_LICENSES 
   WHERE START_DATE > CURRENT_DATE();
   ```

### 6.6 **Missing END_DATE Check**
   - **Rationale**: END_DATE is mandatory for license expiration tracking
   - **SQL Example**:
   ```sql
   -- Check for missing end dates
   SELECT COUNT(*) as missing_end_date_count
   FROM SILVER.SI_LICENSES 
   WHERE END_DATE IS NULL;
   ```

### 6.7 **Null ASSIGNED_TO_USER_ID Check**
   - **Rationale**: ASSIGNED_TO_USER_ID is mandatory for license assignment tracking
   - **SQL Example**:
   ```sql
   -- Check for null assigned user IDs
   SELECT COUNT(*) as null_assigned_user_count
   FROM SILVER.SI_LICENSES 
   WHERE ASSIGNED_TO_USER_ID IS NULL;
   ```

### 6.8 **Invalid Date Format Check**
   - **Rationale**: START_DATE and END_DATE must be valid date formats
   - **SQL Example**:
   ```sql
   -- Check for invalid date formats (basic validation)
   SELECT COUNT(*) as invalid_date_format_count
   FROM SILVER.SI_LICENSES 
   WHERE TRY_CAST(START_DATE AS DATE) IS NULL 
   OR TRY_CAST(END_DATE AS DATE) IS NULL;
   ```

### 6.9 **UPDATE_TIMESTAMP Earlier Than LOAD_TIMESTAMP Check**
   - **Rationale**: UPDATE_TIMESTAMP should not be earlier than LOAD_TIMESTAMP
   - **SQL Example**:
   ```sql
   -- Check for invalid timestamp sequence
   SELECT COUNT(*) as invalid_timestamp_sequence_count
   FROM SILVER.SI_LICENSES 
   WHERE UPDATE_TIMESTAMP < LOAD_TIMESTAMP;
   ```

### 6.10 **Unrecognized LICENSE_TYPE Check**
   - **Rationale**: LICENSE_TYPE must be from predefined list
   - **SQL Example**:
   ```sql
   -- Check for unrecognized license types
   SELECT LICENSE_TYPE, COUNT(*) as unrecognized_count
   FROM SILVER.SI_LICENSES 
   WHERE LICENSE_TYPE NOT IN ('Basic', 'Pro', 'Enterprise', 'Add-on')
   GROUP BY LICENSE_TYPE;
   ```

## 7. **FEATURE_USAGE Data Quality Checks (SILVER.SI_FEATURE_USAGE)**

### 7.1 **Negative USAGE_COUNT Check**
   - **Rationale**: USAGE_COUNT cannot be negative as it represents actual usage occurrences
   - **SQL Example**:
   ```sql
   -- Check for negative usage counts
   SELECT COUNT(*) as negative_usage_count
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_COUNT < 0;
   ```

### 7.2 **Extremely Large USAGE_COUNT Check**
   - **Rationale**: USAGE_COUNT should be within reasonable limits to detect data anomalies
   - **SQL Example**:
   ```sql
   -- Check for extremely large usage counts
   SELECT COUNT(*) as extreme_usage_count
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_COUNT > 10000; -- Threshold for extremely large usage
   ```

### 7.3 **Future USAGE_DATE Check**
   - **Rationale**: USAGE_DATE cannot be in the future
   - **SQL Example**:
   ```sql
   -- Check for future usage dates
   SELECT COUNT(*) as future_usage_date_count
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_DATE > CURRENT_DATE();
   ```

### 7.4 **USAGE_DATE Before Product Launch Check**
   - **Rationale**: USAGE_DATE should not be before product launch date
   - **SQL Example**:
   ```sql
   -- Check for usage dates before product launch
   SELECT COUNT(*) as pre_launch_usage_count
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_DATE < '2011-01-01'; -- Zoom founded in 2011
   ```

### 7.5 **Null FEATURE_NAME Check**
   - **Rationale**: FEATURE_NAME is mandatory for feature usage tracking
   - **SQL Example**:
   ```sql
   -- Check for null feature names
   SELECT COUNT(*) as null_feature_name_count
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '';
   ```

### 7.6 **Unrecognized SOURCE_SYSTEM Check**
   - **Rationale**: SOURCE_SYSTEM must be from valid predefined systems
   - **SQL Example**:
   ```sql
   -- Check for unrecognized source systems
   SELECT SOURCE_SYSTEM, COUNT(*) as unrecognized_count
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE SOURCE_SYSTEM NOT IN ('ZOOM_API', 'ZOOM_WEBHOOK', 'ZOOM_EXPORT')
   GROUP BY SOURCE_SYSTEM;
   ```

### 7.7 **Duplicate USAGE_ID Check**
   - **Rationale**: USAGE_ID must be unique to prevent duplicate usage records
   - **SQL Example**:
   ```sql
   -- Check for duplicate usage IDs
   SELECT USAGE_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_FEATURE_USAGE 
   GROUP BY USAGE_ID 
   HAVING COUNT(*) > 1;
   ```

### 7.8 **UPDATE_TIMESTAMP Before LOAD_TIMESTAMP Check**
   - **Rationale**: UPDATE_TIMESTAMP should not be before LOAD_TIMESTAMP
   - **SQL Example**:
   ```sql
   -- Check for invalid timestamp sequence
   SELECT COUNT(*) as invalid_timestamp_sequence_count
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE UPDATE_TIMESTAMP < LOAD_TIMESTAMP;
   ```

### 7.9 **Invalid MEETING_ID Format Check**
   - **Rationale**: MEETING_ID must follow consistent format pattern
   - **SQL Example**:
   ```sql
   -- Check for invalid meeting ID formats
   SELECT COUNT(*) as invalid_meeting_id_format_count
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE MEETING_ID IS NOT NULL 
   AND NOT REGEXP_LIKE(MEETING_ID, '^[A-Za-z0-9_-]+$');
   ```

## 8. **BILLING_EVENTS Data Quality Checks (SILVER.SI_BILLING_EVENTS)**

### 8.1 **Negative AMOUNT Check**
   - **Rationale**: AMOUNT should be positive for most billing events except refunds
   - **SQL Example**:
   ```sql
   -- Check for negative amounts (excluding refunds)
   SELECT COUNT(*) as negative_amount_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT < 0 AND EVENT_TYPE != 'Refund';
   ```

### 8.2 **Extremely Large AMOUNT Check**
   - **Rationale**: AMOUNT should be within reasonable business limits
   - **SQL Example**:
   ```sql
   -- Check for extremely large amounts
   SELECT COUNT(*) as extreme_amount_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT > 100000; -- Threshold for extremely large amounts
   ```

### 8.3 **Future EVENT_DATE Check**
   - **Rationale**: EVENT_DATE cannot be in the future for completed transactions
   - **SQL Example**:
   ```sql
   -- Check for future event dates
   SELECT COUNT(*) as future_event_date_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE EVENT_DATE > CURRENT_DATE();
   ```

### 8.4 **EVENT_DATE Before Company Launch Check**
   - **Rationale**: EVENT_DATE should not be before company launch date
   - **SQL Example**:
   ```sql
   -- Check for event dates before company launch
   SELECT COUNT(*) as pre_launch_event_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE EVENT_DATE < '2011-01-01'; -- Zoom founded in 2011
   ```

### 8.5 **Null EVENT_TYPE Check**
   - **Rationale**: EVENT_TYPE is mandatory for billing event classification
   - **SQL Example**:
   ```sql
   -- Check for null event types
   SELECT COUNT(*) as null_event_type_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE EVENT_TYPE IS NULL OR TRIM(EVENT_TYPE) = '';
   ```

### 8.6 **Unrecognized SOURCE_SYSTEM Check**
   - **Rationale**: SOURCE_SYSTEM must be from valid predefined systems
   - **SQL Example**:
   ```sql
   -- Check for unrecognized source systems
   SELECT SOURCE_SYSTEM, COUNT(*) as unrecognized_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE SOURCE_SYSTEM NOT IN ('ZOOM_API', 'ZOOM_WEBHOOK', 'ZOOM_EXPORT')
   GROUP BY SOURCE_SYSTEM;
   ```

### 8.7 **Duplicate EVENT_ID Check**
   - **Rationale**: EVENT_ID must be unique to prevent duplicate billing records
   - **SQL Example**:
   ```sql
   -- Check for duplicate event IDs
   SELECT EVENT_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_BILLING_EVENTS 
   GROUP BY EVENT_ID 
   HAVING COUNT(*) > 1;
   ```

### 8.8 **UPDATE_TIMESTAMP Earlier Than LOAD_TIMESTAMP Check**
   - **Rationale**: UPDATE_TIMESTAMP should not be earlier than LOAD_TIMESTAMP
   - **SQL Example**:
   ```sql
   -- Check for invalid timestamp sequence
   SELECT COUNT(*) as invalid_timestamp_sequence_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE UPDATE_TIMESTAMP < LOAD_TIMESTAMP;
   ```

### 8.9 **Amount Equals Zero Check**
   - **Rationale**: Zero amount transactions may indicate data quality issues
   - **SQL Example**:
   ```sql
   -- Check for zero amount transactions
   SELECT COUNT(*) as zero_amount_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT = 0;
   ```

### 8.10 **EVENT_DATE After UPDATE_TIMESTAMP Check**
   - **Rationale**: EVENT_DATE should not be after UPDATE_TIMESTAMP for logical sequence
   - **SQL Example**:
   ```sql
   -- Check for event date after update timestamp
   SELECT COUNT(*) as invalid_date_sequence_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE EVENT_DATE > DATE(UPDATE_TIMESTAMP);
   ```

## 9. **Cross-Table Referential Integrity Checks**

### 9.1 **User Reference Integrity Check**
   - **Rationale**: All USER_ID references must exist in the USERS table
   - **SQL Example**:
   ```sql
   -- Check for orphaned user references across all tables
   SELECT 'MEETINGS' as table_name, COUNT(*) as orphaned_count
   FROM SILVER.SI_MEETINGS m
   LEFT JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND m.HOST_ID IS NOT NULL
   UNION ALL
   SELECT 'SUPPORT_TICKETS', COUNT(*)
   FROM SILVER.SI_SUPPORT_TICKETS st
   LEFT JOIN SILVER.SI_USERS u ON st.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND st.USER_ID IS NOT NULL
   UNION ALL
   SELECT 'BILLING_EVENTS', COUNT(*)
   FROM SILVER.SI_BILLING_EVENTS be
   LEFT JOIN SILVER.SI_USERS u ON be.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND be.USER_ID IS NOT NULL;
   ```

### 9.2 **Meeting Reference Integrity Check**
   - **Rationale**: All MEETING_ID references must exist in the MEETINGS table
   - **SQL Example**:
   ```sql
   -- Check for orphaned meeting references
   SELECT 'PARTICIPANTS' as table_name, COUNT(*) as orphaned_count
   FROM SILVER.SI_PARTICIPANTS p
   LEFT JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL AND p.MEETING_ID IS NOT NULL
   UNION ALL
   SELECT 'FEATURE_USAGE', COUNT(*)
   FROM SILVER.SI_FEATURE_USAGE fu
   LEFT JOIN SILVER.SI_MEETINGS m ON fu.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL AND fu.MEETING_ID IS NOT NULL;
   ```

## 10. **Comprehensive Data Quality Monitoring**

### 10.1 **Overall Data Quality Score Check**
   - **Rationale**: Monitor overall data quality across all tables to ensure data pipeline health
   - **SQL Example**:
   ```sql
   -- Comprehensive data quality summary
   WITH quality_metrics AS (
       SELECT 
           'WEBINARS' as table_name,
           COUNT(*) as total_records,
           SUM(CASE WHEN END_TIME IS NULL THEN 1 ELSE 0 END) as null_end_time,
           SUM(CASE WHEN REGISTRANTS < 0 THEN 1 ELSE 0 END) as negative_registrants,
           SUM(CASE WHEN END_TIME < START_TIME THEN 1 ELSE 0 END) as invalid_time_sequence
       FROM SILVER.SI_WEBINARS
       UNION ALL
       SELECT 
           'USERS',
           COUNT(*),
           SUM(CASE WHEN EMAIL IS NULL THEN 1 ELSE 0 END),
           SUM(CASE WHEN NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 1 ELSE 0 END),
           SUM(CASE WHEN UPDATE_TIMESTAMP < LOAD_TIMESTAMP THEN 1 ELSE 0 END)
       FROM SILVER.SI_USERS
   )
   SELECT 
       table_name,
       total_records,
       (null_end_time + negative_registrants + invalid_time_sequence) as total_quality_issues,
       ROUND(((total_records - (null_end_time + negative_registrants + invalid_time_sequence))::FLOAT / total_records * 100), 2) as quality_score_percentage
   FROM quality_metrics;
   ```

### 10.2 **Data Quality Trend Analysis**
   - **Rationale**: Track data quality trends over time to identify degradation patterns
   - **SQL Example**:
   ```sql
   -- Data quality trend by load date
   SELECT 
       DATE(LOAD_TIMESTAMP) as load_date,
       COUNT(*) as total_records,
       SUM(CASE WHEN DATA_QUALITY_SCORE < 0.8 THEN 1 ELSE 0 END) as low_quality_records,
       AVG(DATA_QUALITY_SCORE) as avg_quality_score
   FROM SILVER.SI_USERS
   WHERE LOAD_TIMESTAMP >= CURRENT_DATE() - 30
   GROUP BY DATE(LOAD_TIMESTAMP)
   ORDER BY load_date DESC;
   ```

## 11. **Automated Data Quality Pipeline Recommendations**

### 11.1 **Real-time Data Quality Monitoring**
   - **Implementation**: Set up automated checks that run after each data load
   - **Alert Thresholds**: 
     - Critical: >5% of records fail validation
     - Warning: >2% of records fail validation
     - Info: >0.5% of records fail validation

### 11.2 **Data Quality Quarantine Process**
   - **Implementation**: Automatically quarantine records that fail critical validations
   - **Process**: Move failed records to separate quarantine tables for manual review

### 11.3 **Data Quality Reporting Dashboard**
   - **Implementation**: Create real-time dashboard showing data quality metrics
   - **Metrics**: Include all validation check results, trends, and alert status

---

**Implementation Notes**:
1. **Execution Frequency**: Run these checks after each Silver layer data load
2. **Error Handling**: Log all validation failures to SI_DATA_QUALITY_ERRORS table
3. **Performance**: Use sampling for large datasets to maintain pipeline performance
4. **Alerting**: Configure automated alerts for critical data quality violations
5. **Remediation**: Implement automated data correction for common issues where possible

**Quality Thresholds**:
- **Excellent**: >95% of records pass all validations
- **Good**: 90-95% of records pass all validations  
- **Acceptable**: 85-90% of records pass all validations
- **Poor**: <85% of records pass all validations (requires immediate attention)

These enhanced data quality recommendations provide comprehensive coverage for all identified bad data patterns and ensure clean, reliable, and loadable data for the Zoom Platform Analytics System Silver layer.