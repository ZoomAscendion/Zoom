_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Enhanced comprehensive data quality recommendations for Zoom Platform Analytics System Silver layer with advanced remediation strategies
## *Version*: 2 
## *Updated on*: 
## *Changes*: Enhanced with advanced data quality patterns, severity classifications, and automated remediation strategies based on Bronze layer analysis
## *Reason*: Incorporating detailed data quality patterns from Bronze layer analysis to provide more comprehensive and actionable data quality recommendations with specific remediation approaches
_____________________________________________

# Silver Layer Data Quality Recommendations
## Zoom Platform Analytics System - Enhanced Version

## Recommended Data Quality Checks:

### 1. **WEBINARS Table Data Quality Checks**

#### 1.1 **Missing END_TIME Validation**
   - **Rationale**: END_TIME is critical for calculating webinar duration and attendance metrics. Missing values impact analytics accuracy
   - **Severity**: `WARN` (move to Silver but flag for review)
   - **SQL Check**:
   ```sql
   SELECT webinar_id, start_time, end_time
   FROM BRONZE.BZ_WEBINARS 
   WHERE end_time IS NULL;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT webinar_id,
          start_time,
          COALESCE(end_time, start_time + INTERVAL '1' HOUR) as end_time_corrected,
          CASE WHEN end_time IS NULL THEN 'INFERRED_END_TIME' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_WEBINARS;
   ```

#### 1.2 **Negative Registrant Count Validation**
   - **Rationale**: Negative registrant counts are logically impossible and indicate data corruption or system errors
   - **Severity**: `BLOCK` (do not move to Silver)
   - **SQL Check**:
   ```sql
   SELECT webinar_id, registrants
   FROM BRONZE.BZ_WEBINARS 
   WHERE registrants < 0;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT webinar_id,
          CASE WHEN registrants < 0 THEN NULL ELSE registrants END as registrants_corrected,
          CASE WHEN registrants < 0 THEN 'NEGATIVE_VALUE_NULLIFIED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_WEBINARS;
   ```

#### 1.3 **End Time Before Start Time Logic Check**
   - **Rationale**: End time occurring before start time violates temporal logic and corrupts duration calculations
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT webinar_id, start_time, end_time
   FROM BRONZE.BZ_WEBINARS 
   WHERE end_time < start_time;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT webinar_id,
          start_time,
          CASE WHEN end_time < start_time 
               THEN start_time + INTERVAL '1' HOUR 
               ELSE end_time END as end_time_corrected,
          CASE WHEN end_time < start_time THEN 'TIME_LOGIC_CORRECTED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_WEBINARS;
   ```

#### 1.4 **Duplicate WEBINAR_ID Check**
   - **Rationale**: Duplicate webinar IDs compromise data integrity and analytics accuracy
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT webinar_id, COUNT(*) as duplicate_count
   FROM BRONZE.BZ_WEBINARS 
   GROUP BY webinar_id 
   HAVING COUNT(*) > 1;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT *,
          ROW_NUMBER() OVER(PARTITION BY webinar_id ORDER BY load_timestamp DESC) as rn
   FROM BRONZE.BZ_WEBINARS
   QUALIFY rn = 1;
   ```

#### 1.5 **Null WEBINAR_TOPIC Validation**
   - **Rationale**: Missing webinar topics impact content analysis and reporting capabilities
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   SELECT webinar_id, webinar_topic
   FROM BRONZE.BZ_WEBINARS 
   WHERE webinar_topic IS NULL OR TRIM(webinar_topic) = '';
   ```
   - **Remediation SQL**:
   ```sql
   SELECT webinar_id,
          COALESCE(NULLIF(TRIM(webinar_topic), ''), 'Unknown Topic - needs enrichment') as webinar_topic_corrected
   FROM BRONZE.BZ_WEBINARS;
   ```

### 2. **USERS Table Data Quality Checks**

#### 2.1 **Missing EMAIL Validation**
   - **Rationale**: Email is critical for user identification and communication in identity tables
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT user_id, email
   FROM BRONZE.BZ_USERS 
   WHERE email IS NULL OR TRIM(email) = '';
   ```
   - **Remediation SQL**:
   ```sql
   SELECT user_id,
          CASE WHEN email IS NULL OR TRIM(email) = '' 
               THEN 'QUARANTINE_NO_EMAIL' 
               ELSE email END as email_status
   FROM BRONZE.BZ_USERS;
   ```

#### 2.2 **Invalid Email Format Validation**
   - **Rationale**: Invalid email formats prevent proper communication and user identification
   - **Severity**: `BLOCK` with normalization attempt
   - **SQL Check**:
   ```sql
   SELECT user_id, email
   FROM BRONZE.BZ_USERS 
   WHERE email IS NOT NULL 
   AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
   ```
   - **Remediation SQL**:
   ```sql
   SELECT user_id,
          CASE WHEN REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
               THEN LOWER(TRIM(email)) 
               ELSE NULL END as email_normalized,
          CASE WHEN NOT REGEXP_LIKE(LOWER(TRIM(email)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
               THEN 'INVALID_EMAIL_FORMAT' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_USERS;
   ```

#### 2.3 **Duplicate USER_ID Check**
   - **Rationale**: Duplicate user IDs compromise referential integrity across all related tables
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT user_id, COUNT(*) as duplicate_count
   FROM BRONZE.BZ_USERS 
   GROUP BY user_id 
   HAVING COUNT(*) > 1;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT *,
          ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY load_timestamp DESC) as rn
   FROM BRONZE.BZ_USERS
   QUALIFY rn = 1;
   ```

#### 2.4 **Invalid PLAN_TYPE Validation**
   - **Rationale**: Plan types must conform to business-defined categories for accurate subscription analysis
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   SELECT user_id, plan_type
   FROM BRONZE.BZ_USERS 
   WHERE plan_type NOT IN ('Free','Pro','Business','Enterprise');
   ```
   - **Remediation SQL**:
   ```sql
   SELECT user_id,
          CASE WHEN plan_type IN ('Free','Pro','Business','Enterprise') 
               THEN plan_type 
               ELSE 'UNKNOWN_PLAN' END as plan_type_standardized,
          plan_type as plan_type_raw
   FROM BRONZE.BZ_USERS;
   ```

#### 2.5 **Temporal Inconsistency Check**
   - **Rationale**: Update timestamp should not be older than load timestamp for data consistency
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   SELECT user_id, update_timestamp, load_timestamp
   FROM BRONZE.BZ_USERS 
   WHERE update_timestamp < load_timestamp;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT user_id,
          GREATEST(update_timestamp, load_timestamp) as update_timestamp_corrected,
          CASE WHEN update_timestamp < load_timestamp 
               THEN 'TEMPORAL_ANOMALY_CORRECTED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_USERS;
   ```

#### 2.6 **Future LOAD_TIMESTAMP Validation**
   - **Rationale**: Future load timestamps indicate system clock issues or data corruption
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT user_id, load_timestamp
   FROM BRONZE.BZ_USERS 
   WHERE load_timestamp > CURRENT_TIMESTAMP() + INTERVAL '1' DAY;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT user_id,
          CASE WHEN load_timestamp > CURRENT_TIMESTAMP() + INTERVAL '1' DAY 
               THEN CURRENT_TIMESTAMP() 
               ELSE load_timestamp END as load_timestamp_corrected,
          CASE WHEN load_timestamp > CURRENT_TIMESTAMP() + INTERVAL '1' DAY
               THEN 'FUTURE_TIMESTAMP_CORRECTED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_USERS;
   ```

### 3. **SUPPORT_TICKETS Table Data Quality Checks**

#### 3.1 **Invalid USER_ID Format Check**
   - **Rationale**: User ID format consistency is crucial for proper referential integrity
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   SELECT ticket_id, user_id
   FROM BRONZE.BZ_SUPPORT_TICKETS 
   WHERE user_id IS NOT NULL 
   AND NOT REGEXP_LIKE(user_id, '^USR[0-9]+$');
   ```
   - **Remediation SQL**:
   ```sql
   SELECT ticket_id,
          CASE WHEN REGEXP_LIKE(user_id, '^USR[0-9]+$') 
               THEN user_id 
               ELSE 'UNKNOWN_USER' END as user_id_standardized
   FROM BRONZE.BZ_SUPPORT_TICKETS;
   ```

#### 3.2 **Future Open Date Validation**
   - **Rationale**: Future open dates are logically impossible and indicate data entry errors
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT ticket_id, open_date
   FROM BRONZE.BZ_SUPPORT_TICKETS 
   WHERE open_date > CURRENT_DATE() + INTERVAL '1' DAY;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT ticket_id,
          CASE WHEN open_date > CURRENT_DATE() + INTERVAL '1' DAY 
               THEN CURRENT_DATE() 
               ELSE open_date END as open_date_corrected,
          CASE WHEN open_date > CURRENT_DATE() + INTERVAL '1' DAY
               THEN 'FUTURE_DATE_CORRECTED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_SUPPORT_TICKETS;
   ```

#### 3.3 **Null USER_ID Validation**
   - **Rationale**: Support tickets without user association cannot be properly tracked or analyzed
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT ticket_id, user_id
   FROM BRONZE.BZ_SUPPORT_TICKETS 
   WHERE user_id IS NULL;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT ticket_id,
          CASE WHEN user_id IS NULL 
               THEN 'QUARANTINE_NO_USER' 
               ELSE user_id END as user_association_status
   FROM BRONZE.BZ_SUPPORT_TICKETS;
   ```

#### 3.4 **Invalid Resolution Status Check**
   - **Rationale**: Resolution status must conform to predefined workflow states
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   SELECT ticket_id, resolution_status
   FROM BRONZE.BZ_SUPPORT_TICKETS 
   WHERE resolution_status NOT IN ('Open', 'In Progress', 'Resolved', 'Closed');
   ```
   - **Remediation SQL**:
   ```sql
   SELECT ticket_id,
          CASE WHEN resolution_status IN ('Open', 'In Progress', 'Resolved', 'Closed') 
               THEN resolution_status 
               ELSE 'UNKNOWN_STATUS' END as resolution_status_standardized,
          resolution_status as resolution_status_raw
   FROM BRONZE.BZ_SUPPORT_TICKETS;
   ```

### 4. **PARTICIPANTS Table Data Quality Checks**

#### 4.1 **Missing LEAVE_TIME Validation**
   - **Rationale**: Missing leave times prevent accurate attendance duration calculations
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   SELECT participant_id, meeting_id, join_time, leave_time
   FROM BRONZE.BZ_PARTICIPANTS 
   WHERE leave_time IS NULL;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT participant_id,
          meeting_id,
          join_time,
          COALESCE(leave_time, 
                   join_time + (SELECT AVG(DATEDIFF('minute', join_time, leave_time)) 
                                FROM BRONZE.BZ_PARTICIPANTS 
                                WHERE leave_time IS NOT NULL) * INTERVAL '1' MINUTE,
                   join_time) as leave_time_inferred
   FROM BRONZE.BZ_PARTICIPANTS;
   ```

#### 4.2 **LEAVE_TIME Earlier Than JOIN_TIME Check**
   - **Rationale**: Leave time before join time violates temporal logic
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT participant_id, join_time, leave_time
   FROM BRONZE.BZ_PARTICIPANTS 
   WHERE leave_time < join_time;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT participant_id,
          CASE WHEN leave_time < join_time 
               THEN join_time 
               ELSE leave_time END as leave_time_corrected,
          CASE WHEN leave_time < join_time 
               THEN 'TEMPORAL_LOGIC_CORRECTED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_PARTICIPANTS;
   ```

#### 4.3 **Future Timestamps Validation**
   - **Rationale**: Future timestamps indicate system issues or data corruption
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT participant_id, join_time, leave_time
   FROM BRONZE.BZ_PARTICIPANTS 
   WHERE join_time > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR
   OR leave_time > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT participant_id,
          CASE WHEN join_time > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR 
               THEN CURRENT_TIMESTAMP() 
               ELSE join_time END as join_time_corrected,
          CASE WHEN leave_time > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR 
               THEN CURRENT_TIMESTAMP() 
               ELSE leave_time END as leave_time_corrected
   FROM BRONZE.BZ_PARTICIPANTS;
   ```

### 5. **MEETINGS Table Data Quality Checks**

#### 5.1 **End Time Earlier Than Start Time Check**
   - **Rationale**: Invalid time sequences corrupt duration calculations and analytics
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT meeting_id, start_time, end_time, duration_minutes
   FROM BRONZE.BZ_MEETINGS 
   WHERE end_time < start_time;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT meeting_id,
          start_time,
          CASE WHEN end_time < start_time 
               THEN start_time + (duration_minutes * INTERVAL '1' MINUTE)
               ELSE end_time END as end_time_corrected,
          CASE WHEN end_time < start_time 
               THEN 'TIME_SEQUENCE_CORRECTED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_MEETINGS;
   ```

#### 5.2 **Negative Duration Validation**
   - **Rationale**: Negative durations are logically impossible and indicate calculation errors
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT meeting_id, duration_minutes, start_time, end_time
   FROM BRONZE.BZ_MEETINGS 
   WHERE duration_minutes < 0;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT meeting_id,
          CASE WHEN duration_minutes < 0 
               THEN ABS(duration_minutes)
               WHEN duration_minutes < 0 AND start_time IS NOT NULL AND end_time IS NOT NULL
               THEN DATEDIFF('minute', start_time, end_time)
               ELSE duration_minutes END as duration_minutes_corrected
   FROM BRONZE.BZ_MEETINGS;
   ```

#### 5.3 **Null HOST_ID Validation**
   - **Rationale**: Meetings must have a host for proper attribution and analytics
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT meeting_id, host_id
   FROM BRONZE.BZ_MEETINGS 
   WHERE host_id IS NULL;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT meeting_id,
          CASE WHEN host_id IS NULL 
               THEN 'QUARANTINE_NO_HOST' 
               ELSE host_id END as host_assignment_status
   FROM BRONZE.BZ_MEETINGS;
   ```

### 6. **LICENSES Table Data Quality Checks**

#### 6.1 **END_DATE Before START_DATE Validation**
   - **Rationale**: Invalid date ranges corrupt license lifecycle tracking
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT license_id, start_date, end_date
   FROM BRONZE.BZ_LICENSES 
   WHERE end_date < start_date;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT license_id,
          CASE WHEN end_date < start_date 
               THEN end_date 
               ELSE start_date END as start_date_corrected,
          CASE WHEN end_date < start_date 
               THEN start_date 
               ELSE end_date END as end_date_corrected,
          CASE WHEN end_date < start_date 
               THEN 'DATE_RANGE_SWAPPED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_LICENSES;
   ```

#### 6.2 **Future START_DATE Validation**
   - **Rationale**: Future start dates may be valid for planned licenses but need validation
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   SELECT license_id, start_date, license_type
   FROM BRONZE.BZ_LICENSES 
   WHERE start_date > CURRENT_DATE() + INTERVAL '1' YEAR;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT license_id,
          start_date,
          CASE WHEN start_date > CURRENT_DATE() + INTERVAL '1' YEAR 
               THEN 'FUTURE_LICENSE_REVIEW_REQUIRED' 
               ELSE 'VALID' END as temporal_validation_flag
   FROM BRONZE.BZ_LICENSES;
   ```

### 7. **FEATURE_USAGE Table Data Quality Checks**

#### 7.1 **Negative Usage Count Validation**
   - **Rationale**: Negative usage counts are impossible and indicate data corruption
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT usage_id, feature_name, usage_count
   FROM BRONZE.BZ_FEATURE_USAGE 
   WHERE usage_count < 0;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT usage_id,
          CASE WHEN usage_count < 0 
               THEN NULL 
               ELSE usage_count END as usage_count_corrected,
          CASE WHEN usage_count < 0 
               THEN 'NEGATIVE_VALUE_NULLIFIED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_FEATURE_USAGE;
   ```

#### 7.2 **Extremely Large Count Outlier Detection**
   - **Rationale**: Statistical outliers may indicate data entry errors or system anomalies
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   WITH usage_stats AS (
       SELECT AVG(usage_count) as mean_usage,
              STDDEV(usage_count) as stddev_usage
       FROM BRONZE.BZ_FEATURE_USAGE 
       WHERE usage_count >= 0
   )
   SELECT u.usage_id, u.usage_count, s.mean_usage, s.stddev_usage
   FROM BRONZE.BZ_FEATURE_USAGE u
   CROSS JOIN usage_stats s
   WHERE u.usage_count > (s.mean_usage + 3 * s.stddev_usage);
   ```
   - **Remediation SQL**:
   ```sql
   WITH usage_stats AS (
       SELECT AVG(usage_count) as mean_usage,
              STDDEV(usage_count) as stddev_usage
       FROM BRONZE.BZ_FEATURE_USAGE 
       WHERE usage_count >= 0
   )
   SELECT u.usage_id,
          CASE WHEN u.usage_count > (s.mean_usage + 3 * s.stddev_usage) 
               THEN (s.mean_usage + 3 * s.stddev_usage)::INTEGER
               ELSE u.usage_count END as usage_count_capped,
          CASE WHEN u.usage_count > (s.mean_usage + 3 * s.stddev_usage) 
               THEN 'OUTLIER_CAPPED' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_FEATURE_USAGE u
   CROSS JOIN usage_stats s;
   ```

### 8. **BILLING_EVENTS Table Data Quality Checks**

#### 8.1 **Negative Amount Validation**
   - **Rationale**: Negative amounts should only occur for refunds with proper event type classification
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   SELECT event_id, amount, event_type
   FROM BRONZE.BZ_BILLING_EVENTS 
   WHERE amount < 0 AND event_type != 'Refund';
   ```
   - **Remediation SQL**:
   ```sql
   SELECT event_id,
          amount,
          CASE WHEN amount < 0 AND event_type != 'Refund' 
               THEN 'Refund' 
               ELSE event_type END as event_type_corrected,
          CASE WHEN amount < 0 AND event_type != 'Refund' 
               THEN 'EVENT_TYPE_CORRECTED_FOR_NEGATIVE_AMOUNT' ELSE 'VALID' END as data_quality_flag
   FROM BRONZE.BZ_BILLING_EVENTS;
   ```

#### 8.2 **Excessively Large Amount Validation**
   - **Rationale**: Unusually large amounts may indicate data entry errors requiring review
   - **Severity**: `WARN`
   - **SQL Check**:
   ```sql
   WITH amount_stats AS (
       SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY amount) as p99_amount
       FROM BRONZE.BZ_BILLING_EVENTS 
       WHERE amount > 0
   )
   SELECT b.event_id, b.amount, s.p99_amount
   FROM BRONZE.BZ_BILLING_EVENTS b
   CROSS JOIN amount_stats s
   WHERE b.amount > s.p99_amount * 10;
   ```
   - **Remediation SQL**:
   ```sql
   WITH amount_stats AS (
       SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY amount) as p99_amount
       FROM BRONZE.BZ_BILLING_EVENTS 
       WHERE amount > 0
   )
   SELECT b.event_id,
          b.amount,
          CASE WHEN b.amount > s.p99_amount * 10 
               THEN 'LARGE_AMOUNT_REVIEW_REQUIRED' 
               ELSE 'VALID' END as amount_validation_flag
   FROM BRONZE.BZ_BILLING_EVENTS b
   CROSS JOIN amount_stats s;
   ```

### 9. **Cross-Table Referential Integrity Checks**

#### 9.1 **Orphaned Meeting Participants Check**
   - **Rationale**: Participants must reference valid meetings for data consistency
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT p.participant_id, p.meeting_id
   FROM BRONZE.BZ_PARTICIPANTS p
   LEFT JOIN BRONZE.BZ_MEETINGS m ON p.meeting_id = m.meeting_id
   WHERE m.meeting_id IS NULL;
   ```
   - **Remediation SQL**:
   ```sql
   SELECT p.*,
          CASE WHEN m.meeting_id IS NULL 
               THEN 'ORPHANED_PARTICIPANT' 
               ELSE 'VALID_REFERENCE' END as referential_integrity_status
   FROM BRONZE.BZ_PARTICIPANTS p
   LEFT JOIN BRONZE.BZ_MEETINGS m ON p.meeting_id = m.meeting_id;
   ```

#### 9.2 **Invalid User References Check**
   - **Rationale**: All user references across tables must point to valid user records
   - **Severity**: `BLOCK`
   - **SQL Check**:
   ```sql
   SELECT 'MEETINGS' as source_table, m.meeting_id as record_id, m.host_id as user_id
   FROM BRONZE.BZ_MEETINGS m
   LEFT JOIN BRONZE.BZ_USERS u ON m.host_id = u.user_id
   WHERE u.user_id IS NULL AND m.host_id IS NOT NULL
   UNION ALL
   SELECT 'SUPPORT_TICKETS', s.ticket_id, s.user_id
   FROM BRONZE.BZ_SUPPORT_TICKETS s
   LEFT JOIN BRONZE.BZ_USERS u ON s.user_id = u.user_id
   WHERE u.user_id IS NULL AND s.user_id IS NOT NULL;
   ```

### 10. **Data Quality Scoring and Monitoring**

#### 10.1 **Comprehensive Data Quality Score Calculation**
   - **Rationale**: Provides quantitative assessment of data quality for monitoring and improvement
   - **SQL Implementation**:
   ```sql
   WITH quality_metrics AS (
       SELECT 'USERS' as table_name,
              COUNT(*) as total_records,
              COUNT(CASE WHEN email IS NULL OR NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 1 END) as email_issues,
              COUNT(CASE WHEN plan_type NOT IN ('Free','Pro','Business','Enterprise') THEN 1 END) as plan_type_issues,
              COUNT(CASE WHEN user_id IS NULL THEN 1 END) as id_issues
       FROM BRONZE.BZ_USERS
       UNION ALL
       SELECT 'MEETINGS',
              COUNT(*),
              COUNT(CASE WHEN end_time < start_time THEN 1 END),
              COUNT(CASE WHEN duration_minutes < 0 THEN 1 END),
              COUNT(CASE WHEN meeting_id IS NULL THEN 1 END)
       FROM BRONZE.BZ_MEETINGS
   )
   SELECT table_name,
          total_records,
          (email_issues + plan_type_issues + id_issues) as total_issues,
          CASE WHEN total_records > 0 
               THEN 1.0 - ((email_issues + plan_type_issues + id_issues)::FLOAT / total_records)
               ELSE 1.0 END as data_quality_score
   FROM quality_metrics;
   ```

### 11. **Automated Remediation Framework**

#### 11.1 **Data Quality Rule Engine**
   - **Rationale**: Systematic approach to applying data quality rules with consistent severity handling
   - **Implementation Framework**:
   ```sql
   -- Create data quality rules table
   CREATE TABLE IF NOT EXISTS SILVER.DQ_RULES (
       rule_id VARCHAR(50),
       table_name VARCHAR(50),
       rule_description VARCHAR(500),
       severity VARCHAR(10), -- BLOCK, WARN, FIX
       check_sql TEXT,
       remediation_sql TEXT,
       is_active BOOLEAN DEFAULT TRUE
   );
   
   -- Create data quality results table
   CREATE TABLE IF NOT EXISTS SILVER.DQ_RESULTS (
       execution_id VARCHAR(50),
       rule_id VARCHAR(50),
       execution_timestamp TIMESTAMP_NTZ,
       records_checked INTEGER,
       issues_found INTEGER,
       remediation_applied BOOLEAN,
       status VARCHAR(20)
   );
   ```

### 12. **Performance Optimization for Data Quality Checks**

#### 12.1 **Incremental Data Quality Validation**
   - **Rationale**: Optimize performance by checking only new or modified records
   - **SQL Pattern**:
   ```sql
   -- Example for incremental validation
   SELECT COUNT(*) as new_email_issues
   FROM BRONZE.BZ_USERS 
   WHERE load_timestamp >= DATEADD('hour', -1, CURRENT_TIMESTAMP())
   AND (email IS NULL OR NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));
   ```

## Implementation Guidelines:

### 1. **Severity-Based Processing**
   - **BLOCK**: Records with BLOCK-level issues should not proceed to Silver layer
   - **WARN**: Records proceed to Silver layer but are flagged for review
   - **FIX**: Records are automatically corrected during Silver layer processing

### 2. **Automated Remediation Pipeline**
   - Implement automated correction for FIX-level issues
   - Create quarantine tables for BLOCK-level issues
   - Generate alerts for WARN-level issues requiring manual review

### 3. **Data Quality Monitoring Dashboard**
   - Real-time data quality score tracking
   - Trend analysis for data quality metrics
   - Automated alerting for quality degradation

### 4. **Continuous Improvement Process**
   - Regular review of data quality rules effectiveness
   - Feedback loop from business users on data quality impact
   - Automated rule optimization based on historical patterns

### 5. **Performance Considerations**
   - Index optimization for frequently checked columns
   - Parallel processing for large-scale data quality validation
   - Incremental validation for real-time data processing

### 6. **Documentation and Audit Trail**
   - Complete audit trail of all data quality corrections
   - Business impact assessment for each data quality rule
   - Regular reporting on data quality improvements and trends