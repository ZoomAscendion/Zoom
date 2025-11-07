_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data quality recommendations for Zoom Platform Analytics System Silver layer
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Quality Recommendations
## Zoom Platform Analytics System

## 1. **SI_USERS Table Data Quality Checks**

### 1.1 **Null Value Checks**
   - **Rationale**: Ensure critical user identification fields are populated
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as null_user_ids 
   FROM SILVER.SI_USERS 
   WHERE USER_ID IS NULL;
   
   SELECT COUNT(*) as null_emails 
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NULL;
   ```

### 1.2 **Email Format Validation**
   - **Rationale**: Ensure email addresses follow valid format patterns for communication and analytics
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_emails 
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NOT NULL 
   AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
   ```

### 1.3 **Plan Type Standardization Check**
   - **Rationale**: Ensure plan types conform to business rule constraints (Free, Basic, Pro, Enterprise)
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_plan_types 
   FROM SILVER.SI_USERS 
   WHERE PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') 
   OR PLAN_TYPE IS NULL;
   ```

### 1.4 **User ID Uniqueness Check**
   - **Rationale**: Ensure each user has a unique identifier as per business constraints
   - **SQL Example**: 
   ```sql
   SELECT USER_ID, COUNT(*) as duplicate_count 
   FROM SILVER.SI_USERS 
   WHERE USER_ID IS NOT NULL
   GROUP BY USER_ID 
   HAVING COUNT(*) > 1;
   ```

### 1.5 **Data Quality Score Validation**
   - **Rationale**: Ensure data quality scores are within valid range (0-100)
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_dq_scores 
   FROM SILVER.SI_USERS 
   WHERE DATA_QUALITY_SCORE < 0 OR DATA_QUALITY_SCORE > 100;
   ```

## 2. **SI_MEETINGS Table Data Quality Checks**

### 2.1 **Meeting Duration Consistency Check**
   - **Rationale**: Ensure calculated duration matches the difference between start and end times
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as duration_mismatch 
   FROM SILVER.SI_MEETINGS 
   WHERE ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1;
   ```

### 2.2 **Meeting Time Logic Validation**
   - **Rationale**: Ensure end time is after start time as per business logic constraints
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_time_logic 
   FROM SILVER.SI_MEETINGS 
   WHERE END_TIME <= START_TIME;
   ```

### 2.3 **Host ID Referential Integrity**
   - **Rationale**: Ensure all meeting hosts exist in the users table
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as orphaned_meetings 
   FROM SILVER.SI_MEETINGS m 
   LEFT JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID 
   WHERE u.USER_ID IS NULL AND m.HOST_ID IS NOT NULL;
   ```

### 2.4 **Meeting Duration Range Check**
   - **Rationale**: Validate meeting durations are within reasonable business ranges (0-1440 minutes)
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_duration 
   FROM SILVER.SI_MEETINGS 
   WHERE DURATION_MINUTES < 0 OR DURATION_MINUTES > 1440;
   ```

### 2.5 **Meeting Classification Validation**
   - **Rationale**: Support business rule for meeting classification based on duration
   - **SQL Example**: 
   ```sql
   SELECT 
     CASE 
       WHEN DURATION_MINUTES < 5 THEN 'Brief'
       ELSE 'Standard'
     END as meeting_type,
     COUNT(*) as count
   FROM SILVER.SI_MEETINGS 
   GROUP BY meeting_type;
   ```

## 3. **SI_PARTICIPANTS Table Data Quality Checks**

### 3.1 **Participant Session Time Validation**
   - **Rationale**: Ensure leave time is after join time as per business constraints
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_session_times 
   FROM SILVER.SI_PARTICIPANTS 
   WHERE LEAVE_TIME <= JOIN_TIME;
   ```

### 3.2 **Meeting Boundary Validation**
   - **Rationale**: Ensure participant join/leave times are within meeting duration
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as boundary_violations 
   FROM SILVER.SI_PARTICIPANTS p 
   JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID 
   WHERE p.JOIN_TIME < m.START_TIME 
   OR p.LEAVE_TIME > m.END_TIME;
   ```

### 3.3 **Participant-Meeting Referential Integrity**
   - **Rationale**: Ensure all participants reference valid meetings
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as orphaned_participants 
   FROM SILVER.SI_PARTICIPANTS p 
   LEFT JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID 
   WHERE m.MEETING_ID IS NULL;
   ```

### 3.4 **Participant-User Referential Integrity**
   - **Rationale**: Ensure all participants reference valid users
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_participant_users 
   FROM SILVER.SI_PARTICIPANTS p 
   LEFT JOIN SILVER.SI_USERS u ON p.USER_ID = u.USER_ID 
   WHERE u.USER_ID IS NULL AND p.USER_ID IS NOT NULL;
   ```

### 3.5 **Unique Participant Per Meeting Check**
   - **Rationale**: Ensure combination of meeting_id and user_id is unique
   - **SQL Example**: 
   ```sql
   SELECT MEETING_ID, USER_ID, COUNT(*) as duplicate_count 
   FROM SILVER.SI_PARTICIPANTS 
   GROUP BY MEETING_ID, USER_ID 
   HAVING COUNT(*) > 1;
   ```

## 4. **SI_FEATURE_USAGE Table Data Quality Checks**

### 4.1 **Feature Name Standardization**
   - **Rationale**: Ensure feature names follow standardized naming conventions
   - **SQL Example**: 
   ```sql
   SELECT FEATURE_NAME, COUNT(*) as usage_count 
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE LENGTH(FEATURE_NAME) > 100 OR FEATURE_NAME IS NULL
   GROUP BY FEATURE_NAME;
   ```

### 4.2 **Usage Count Validation**
   - **Rationale**: Ensure usage counts are non-negative integers as per constraints
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_usage_counts 
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_COUNT < 0 OR USAGE_COUNT IS NULL;
   ```

### 4.3 **Feature-Meeting Referential Integrity**
   - **Rationale**: Ensure all feature usage references valid meetings
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as orphaned_feature_usage 
   FROM SILVER.SI_FEATURE_USAGE f 
   LEFT JOIN SILVER.SI_MEETINGS m ON f.MEETING_ID = m.MEETING_ID 
   WHERE m.MEETING_ID IS NULL;
   ```

### 4.4 **Usage Date Consistency**
   - **Rationale**: Ensure usage dates align with meeting dates
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as date_mismatches 
   FROM SILVER.SI_FEATURE_USAGE f 
   JOIN SILVER.SI_MEETINGS m ON f.MEETING_ID = m.MEETING_ID 
   WHERE DATE(f.USAGE_DATE) != DATE(m.START_TIME);
   ```

### 4.5 **Feature Adoption Rate Calculation**
   - **Rationale**: Support business rule for feature adoption metrics
   - **SQL Example**: 
   ```sql
   SELECT 
     FEATURE_NAME,
     COUNT(DISTINCT f.MEETING_ID) as meetings_with_feature,
     (SELECT COUNT(DISTINCT MEETING_ID) FROM SILVER.SI_MEETINGS) as total_meetings,
     ROUND((COUNT(DISTINCT f.MEETING_ID) * 100.0 / (SELECT COUNT(DISTINCT MEETING_ID) FROM SILVER.SI_MEETINGS)), 2) as adoption_rate_percent
   FROM SILVER.SI_FEATURE_USAGE f
   GROUP BY FEATURE_NAME;
   ```

## 5. **SI_SUPPORT_TICKETS Table Data Quality Checks**

### 5.1 **Ticket Status Validation**
   - **Rationale**: Ensure resolution status follows predefined values (Open, In Progress, Resolved, Closed)
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_statuses 
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') 
   OR RESOLUTION_STATUS IS NULL;
   ```

### 5.2 **Ticket-User Referential Integrity**
   - **Rationale**: Ensure all tickets reference valid users
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as orphaned_tickets 
   FROM SILVER.SI_SUPPORT_TICKETS t 
   LEFT JOIN SILVER.SI_USERS u ON t.USER_ID = u.USER_ID 
   WHERE u.USER_ID IS NULL;
   ```

### 5.3 **Ticket ID Uniqueness**
   - **Rationale**: Ensure each ticket has a unique identifier
   - **SQL Example**: 
   ```sql
   SELECT TICKET_ID, COUNT(*) as duplicate_count 
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE TICKET_ID IS NOT NULL
   GROUP BY TICKET_ID 
   HAVING COUNT(*) > 1;
   ```

### 5.4 **Open Date Validation**
   - **Rationale**: Ensure open dates are valid and not in the future
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as future_open_dates 
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE OPEN_DATE > CURRENT_DATE();
   ```

### 5.5 **Ticket Volume Per User Analysis**
   - **Rationale**: Support business rule for ticket volume metrics per 1000 users
   - **SQL Example**: 
   ```sql
   SELECT 
     COUNT(*) as total_tickets,
     (SELECT COUNT(DISTINCT USER_ID) FROM SILVER.SI_USERS) as total_users,
     ROUND((COUNT(*) * 1000.0 / (SELECT COUNT(DISTINCT USER_ID) FROM SILVER.SI_USERS)), 2) as tickets_per_1000_users
   FROM SILVER.SI_SUPPORT_TICKETS;
   ```

## 6. **SI_BILLING_EVENTS Table Data Quality Checks**

### 6.1 **Amount Validation**
   - **Rationale**: Ensure billing amounts are positive numbers with appropriate precision
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_amounts 
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT <= 0 OR AMOUNT IS NULL;
   ```

### 6.2 **Event Date Validation**
   - **Rationale**: Ensure event dates are valid timestamps and not in the future
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as future_event_dates 
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE EVENT_DATE > CURRENT_DATE();
   ```

### 6.3 **Billing-User Referential Integrity**
   - **Rationale**: Ensure all billing events reference valid users
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as orphaned_billing_events 
   FROM SILVER.SI_BILLING_EVENTS b 
   LEFT JOIN SILVER.SI_USERS u ON b.USER_ID = u.USER_ID 
   WHERE u.USER_ID IS NULL;
   ```

### 6.4 **Event Type Standardization**
   - **Rationale**: Ensure event types follow standardized billing categories
   - **SQL Example**: 
   ```sql
   SELECT EVENT_TYPE, COUNT(*) as event_count 
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE EVENT_TYPE IS NULL OR LENGTH(TRIM(EVENT_TYPE)) = 0
   GROUP BY EVENT_TYPE;
   ```

### 6.5 **Monthly Recurring Revenue (MRR) Calculation**
   - **Rationale**: Support business rule for MRR calculation excluding one-time payments
   - **SQL Example**: 
   ```sql
   SELECT 
     DATE_TRUNC('month', EVENT_DATE) as month,
     SUM(CASE WHEN EVENT_TYPE LIKE '%subscription%' THEN AMOUNT ELSE 0 END) as mrr,
     SUM(CASE WHEN EVENT_TYPE LIKE '%refund%' THEN -AMOUNT ELSE 0 END) as refunds
   FROM SILVER.SI_BILLING_EVENTS 
   GROUP BY DATE_TRUNC('month', EVENT_DATE)
   ORDER BY month;
   ```

## 7. **SI_LICENSES Table Data Quality Checks**

### 7.1 **License Date Logic Validation**
   - **Rationale**: Ensure start date is before end date as per business constraints
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_date_logic 
   FROM SILVER.SI_LICENSES 
   WHERE START_DATE >= END_DATE;
   ```

### 7.2 **License-User Referential Integrity**
   - **Rationale**: Ensure all licenses are assigned to valid users
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as orphaned_licenses 
   FROM SILVER.SI_LICENSES l 
   LEFT JOIN SILVER.SI_USERS u ON l.ASSIGNED_TO_USER_ID = u.USER_ID 
   WHERE u.USER_ID IS NULL;
   ```

### 7.3 **Active License Validation**
   - **Rationale**: Ensure active licenses have end dates in the future
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as expired_active_licenses 
   FROM SILVER.SI_LICENSES 
   WHERE END_DATE < CURRENT_DATE();
   ```

### 7.4 **License Type Standardization**
   - **Rationale**: Ensure license types follow predefined categories
   - **SQL Example**: 
   ```sql
   SELECT LICENSE_TYPE, COUNT(*) as license_count 
   FROM SILVER.SI_LICENSES 
   WHERE LICENSE_TYPE IS NULL OR LENGTH(TRIM(LICENSE_TYPE)) = 0
   GROUP BY LICENSE_TYPE;
   ```

### 7.5 **License Utilization Rate Calculation**
   - **Rationale**: Support business rule for license utilization metrics
   - **SQL Example**: 
   ```sql
   SELECT 
     LICENSE_TYPE,
     COUNT(*) as total_licenses,
     COUNT(CASE WHEN END_DATE > CURRENT_DATE() THEN 1 END) as active_licenses,
     ROUND((COUNT(CASE WHEN END_DATE > CURRENT_DATE() THEN 1 END) * 100.0 / COUNT(*)), 2) as utilization_rate_percent
   FROM SILVER.SI_LICENSES 
   GROUP BY LICENSE_TYPE;
   ```

## 8. **Cross-Table Data Quality Checks**

### 8.1 **User Activity Consistency**
   - **Rationale**: Ensure users with meetings also have corresponding participant records
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as meetings_without_host_participation 
   FROM SILVER.SI_MEETINGS m 
   LEFT JOIN SILVER.SI_PARTICIPANTS p ON m.MEETING_ID = p.MEETING_ID AND m.HOST_ID = p.USER_ID 
   WHERE p.USER_ID IS NULL;
   ```

### 8.2 **Feature Usage Alignment**
   - **Rationale**: Ensure feature usage records align with actual meeting participants
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as feature_usage_without_participants 
   FROM SILVER.SI_FEATURE_USAGE f 
   LEFT JOIN SILVER.SI_PARTICIPANTS p ON f.MEETING_ID = p.MEETING_ID 
   WHERE p.MEETING_ID IS NULL;
   ```

### 8.3 **Billing-License Consistency**
   - **Rationale**: Ensure users with billing events have corresponding license records
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as billing_without_licenses 
   FROM SILVER.SI_BILLING_EVENTS b 
   LEFT JOIN SILVER.SI_LICENSES l ON b.USER_ID = l.ASSIGNED_TO_USER_ID 
   WHERE l.ASSIGNED_TO_USER_ID IS NULL;
   ```

## 9. **Metadata Quality Checks**

### 9.1 **Load Timestamp Validation**
   - **Rationale**: Ensure all records have valid load timestamps for audit purposes
   - **SQL Example**: 
   ```sql
   SELECT 'SI_USERS' as table_name, COUNT(*) as null_load_timestamps 
   FROM SILVER.SI_USERS WHERE LOAD_TIMESTAMP IS NULL
   UNION ALL
   SELECT 'SI_MEETINGS', COUNT(*) FROM SILVER.SI_MEETINGS WHERE LOAD_TIMESTAMP IS NULL
   UNION ALL
   SELECT 'SI_PARTICIPANTS', COUNT(*) FROM SILVER.SI_PARTICIPANTS WHERE LOAD_TIMESTAMP IS NULL;
   ```

### 9.2 **Source System Validation**
   - **Rationale**: Ensure all records have valid source system identification
   - **SQL Example**: 
   ```sql
   SELECT SOURCE_SYSTEM, COUNT(*) as record_count 
   FROM SILVER.SI_USERS 
   WHERE SOURCE_SYSTEM IS NULL OR LENGTH(TRIM(SOURCE_SYSTEM)) = 0
   GROUP BY SOURCE_SYSTEM;
   ```

### 9.3 **Validation Status Check**
   - **Rationale**: Ensure validation status is properly set for all records
   - **SQL Example**: 
   ```sql
   SELECT VALIDATION_STATUS, COUNT(*) as record_count 
   FROM SILVER.SI_USERS 
   WHERE VALIDATION_STATUS NOT IN ('PASSED', 'FAILED', 'WARNING') OR VALIDATION_STATUS IS NULL
   GROUP BY VALIDATION_STATUS;
   ```

## 10. **Business Rule Validation Checks**

### 10.1 **Daily Active Users (DAU) Calculation**
   - **Rationale**: Support business rule for DAU definition (users who hosted at least one meeting in 24 hours)
   - **SQL Example**: 
   ```sql
   SELECT 
     DATE(START_TIME) as activity_date,
     COUNT(DISTINCT HOST_ID) as daily_active_users
   FROM SILVER.SI_MEETINGS 
   WHERE START_TIME >= CURRENT_DATE() - INTERVAL '30 days'
   GROUP BY DATE(START_TIME)
   ORDER BY activity_date;
   ```

### 10.2 **Meeting Classification Business Rule**
   - **Rationale**: Validate meeting classification based on duration and attendee count
   - **SQL Example**: 
   ```sql
   SELECT 
     m.MEETING_ID,
     m.DURATION_MINUTES,
     COUNT(p.PARTICIPANT_ID) as attendee_count,
     CASE 
       WHEN m.DURATION_MINUTES < 5 THEN 'Brief'
       WHEN COUNT(p.PARTICIPANT_ID) >= 2 THEN 'Collaborative'
       ELSE 'Standard'
     END as meeting_classification
   FROM SILVER.SI_MEETINGS m
   LEFT JOIN SILVER.SI_PARTICIPANTS p ON m.MEETING_ID = p.MEETING_ID
   GROUP BY m.MEETING_ID, m.DURATION_MINUTES;
   ```

### 10.3 **Churn Rate Calculation Validation**
   - **Rationale**: Support business rule for monthly churn rate calculation
   - **SQL Example**: 
   ```sql
   SELECT 
     DATE_TRUNC('month', END_DATE) as churn_month,
     COUNT(*) as churned_users,
     (SELECT COUNT(DISTINCT USER_ID) FROM SILVER.SI_USERS) as total_users,
     ROUND((COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT USER_ID) FROM SILVER.SI_USERS)), 2) as churn_rate_percent
   FROM SILVER.SI_LICENSES 
   WHERE END_DATE < CURRENT_DATE() 
   AND END_DATE >= DATE_TRUNC('month', CURRENT_DATE()) - INTERVAL '12 months'
   GROUP BY DATE_TRUNC('month', END_DATE)
   ORDER BY churn_month;
   ```

## 11. **Performance and Optimization Checks**

### 11.1 **Data Freshness Validation**
   - **Rationale**: Ensure data is being loaded within acceptable time windows
   - **SQL Example**: 
   ```sql
   SELECT 
     'SI_USERS' as table_name,
     MAX(LOAD_TIMESTAMP) as latest_load,
     DATEDIFF('hour', MAX(LOAD_TIMESTAMP), CURRENT_TIMESTAMP()) as hours_since_last_load
   FROM SILVER.SI_USERS
   UNION ALL
   SELECT 
     'SI_MEETINGS',
     MAX(LOAD_TIMESTAMP),
     DATEDIFF('hour', MAX(LOAD_TIMESTAMP), CURRENT_TIMESTAMP())
   FROM SILVER.SI_MEETINGS;
   ```

### 11.2 **Record Count Validation**
   - **Rationale**: Monitor record counts for unexpected changes or data loss
   - **SQL Example**: 
   ```sql
   SELECT 
     'SI_USERS' as table_name,
     COUNT(*) as current_count,
     DATE(MAX(LOAD_TIMESTAMP)) as last_load_date
   FROM SILVER.SI_USERS
   UNION ALL
   SELECT 
     'SI_MEETINGS',
     COUNT(*),
     DATE(MAX(LOAD_TIMESTAMP))
   FROM SILVER.SI_MEETINGS;
   ```

### 11.3 **Data Quality Score Distribution**
   - **Rationale**: Monitor overall data quality trends across all tables
   - **SQL Example**: 
   ```sql
   SELECT 
     'SI_USERS' as table_name,
     AVG(DATA_QUALITY_SCORE) as avg_dq_score,
     MIN(DATA_QUALITY_SCORE) as min_dq_score,
     MAX(DATA_QUALITY_SCORE) as max_dq_score,
     COUNT(CASE WHEN DATA_QUALITY_SCORE < 70 THEN 1 END) as low_quality_records
   FROM SILVER.SI_USERS
   WHERE DATA_QUALITY_SCORE IS NOT NULL;
   ```

## 12. **Recommended Implementation Strategy**

### 12.1 **Priority Levels**
1. **Critical (P1)**: Null checks, referential integrity, business logic constraints
2. **High (P2)**: Data format validation, range checks, uniqueness constraints
3. **Medium (P3)**: Business rule calculations, cross-table consistency
4. **Low (P4)**: Performance monitoring, data quality scoring

### 12.2 **Automation Recommendations**
- Implement automated daily execution of P1 and P2 checks
- Set up alerts for critical data quality failures
- Create dashboards for monitoring data quality trends
- Establish data quality SLAs with business stakeholders

### 12.3 **Error Handling Strategy**
- Route failed records to SI_DATA_QUALITY_ERRORS table
- Implement retry mechanisms for transient failures
- Create escalation procedures for persistent quality issues
- Maintain audit trail in SI_PIPELINE_EXECUTION_LOG table

---

**Note**: These data quality checks are designed to ensure the integrity, accuracy, and reliability of the Zoom Platform Analytics System Silver layer data, supporting robust analytics and business intelligence capabilities while maintaining compliance with established business rules and constraints.