_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer Data Quality Recommendations for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Quality Recommendations
## Zoom Platform Analytics System

## Recommended Data Quality Checks:

### 1. **User Data Completeness and Validity Checks**

#### 1.1 **User ID Null Check**
   - **Rationale**: USER_ID is the primary identifier and must be present for all user records to ensure proper data lineage and referential integrity
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as null_user_ids
   FROM BRONZE.BZ_USERS 
   WHERE USER_ID IS NULL OR TRIM(USER_ID) = '';
   ```

#### 1.2 **Email Format Validation**
   - **Rationale**: Email addresses must follow standard format for communication and user identification purposes
   - **SQL Example**: 
   ```sql
   SELECT USER_ID, EMAIL
   FROM BRONZE.BZ_USERS 
   WHERE EMAIL IS NOT NULL 
     AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$');
   ```

#### 1.3 **Plan Type Validation**
   - **Rationale**: Plan_Type must be from predefined list (Free, Basic, Pro, Business, Enterprise) as per business rules
   - **SQL Example**: 
   ```sql
   SELECT USER_ID, PLAN_TYPE
   FROM BRONZE.BZ_USERS 
   WHERE PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Business', 'Enterprise')
      OR PLAN_TYPE IS NULL;
   ```

#### 1.4 **User Name Completeness Check**
   - **Rationale**: User names are required for proper user identification and reporting
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as missing_user_names
   FROM BRONZE.BZ_USERS 
   WHERE USER_NAME IS NULL OR TRIM(USER_NAME) = '';
   ```

### 2. **Meeting Data Integrity Checks**

#### 2.1 **Meeting ID Uniqueness Check**
   - **Rationale**: Each meeting must have a unique identifier to prevent data duplication and ensure accurate analytics
   - **SQL Example**: 
   ```sql
   SELECT MEETING_ID, COUNT(*) as duplicate_count
   FROM BRONZE.BZ_MEETINGS 
   GROUP BY MEETING_ID 
   HAVING COUNT(*) > 1;
   ```

#### 2.2 **Meeting Duration Validation**
   - **Rationale**: Duration_Minutes must be non-negative and should align with calculated time difference between start and end times
   - **SQL Example**: 
   ```sql
   SELECT MEETING_ID, DURATION_MINUTES, START_TIME, END_TIME
   FROM BRONZE.BZ_MEETINGS 
   WHERE DURATION_MINUTES < 0 
      OR DURATION_MINUTES IS NULL
      OR (END_TIME IS NOT NULL AND START_TIME IS NOT NULL 
          AND ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1);
   ```

#### 2.3 **Meeting Time Chronological Check**
   - **Rationale**: Start_Time must be before End_Time to ensure logical temporal consistency
   - **SQL Example**: 
   ```sql
   SELECT MEETING_ID, START_TIME, END_TIME
   FROM BRONZE.BZ_MEETINGS 
   WHERE START_TIME IS NOT NULL 
     AND END_TIME IS NOT NULL 
     AND START_TIME >= END_TIME;
   ```

#### 2.4 **Host ID Referential Integrity Check**
   - **Rationale**: Host_ID must exist in Users table to maintain referential integrity
   - **SQL Example**: 
   ```sql
   SELECT m.MEETING_ID, m.HOST_ID
   FROM BRONZE.BZ_MEETINGS m
   LEFT JOIN BRONZE.BZ_USERS u ON m.HOST_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND m.HOST_ID IS NOT NULL;
   ```

### 3. **Participant Data Validation Checks**

#### 3.1 **Participant Meeting Referential Integrity**
   - **Rationale**: All participants must be associated with valid meetings
   - **SQL Example**: 
   ```sql
   SELECT p.PARTICIPANT_ID, p.MEETING_ID
   FROM BRONZE.BZ_PARTICIPANTS p
   LEFT JOIN BRONZE.BZ_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL AND p.MEETING_ID IS NOT NULL;
   ```

#### 3.2 **Participant User Referential Integrity**
   - **Rationale**: All participants must be valid users in the system
   - **SQL Example**: 
   ```sql
   SELECT p.PARTICIPANT_ID, p.USER_ID
   FROM BRONZE.BZ_PARTICIPANTS p
   LEFT JOIN BRONZE.BZ_USERS u ON p.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND p.USER_ID IS NOT NULL;
   ```

#### 3.3 **Participant Time Validation**
   - **Rationale**: Join_Time should be before Leave_Time and both should fall within meeting duration
   - **SQL Example**: 
   ```sql
   SELECT p.PARTICIPANT_ID, p.JOIN_TIME, p.LEAVE_TIME, m.START_TIME, m.END_TIME
   FROM BRONZE.BZ_PARTICIPANTS p
   JOIN BRONZE.BZ_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
   WHERE (p.JOIN_TIME IS NOT NULL AND p.LEAVE_TIME IS NOT NULL AND p.JOIN_TIME >= p.LEAVE_TIME)
      OR (p.JOIN_TIME < m.START_TIME)
      OR (p.LEAVE_TIME > m.END_TIME);
   ```

### 4. **Feature Usage Data Quality Checks**

#### 4.1 **Feature Usage Meeting Referential Integrity**
   - **Rationale**: Feature usage must be linked to valid meetings
   - **SQL Example**: 
   ```sql
   SELECT f.USAGE_ID, f.MEETING_ID
   FROM BRONZE.BZ_FEATURE_USAGE f
   LEFT JOIN BRONZE.BZ_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL AND f.MEETING_ID IS NOT NULL;
   ```

#### 4.2 **Usage Count Validation**
   - **Rationale**: Usage_Count must be non-negative integer as per business constraints
   - **SQL Example**: 
   ```sql
   SELECT USAGE_ID, USAGE_COUNT
   FROM BRONZE.BZ_FEATURE_USAGE 
   WHERE USAGE_COUNT < 0 OR USAGE_COUNT IS NULL;
   ```

#### 4.3 **Feature Name Completeness Check**
   - **Rationale**: Feature names are required for accurate feature adoption analysis
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as missing_feature_names
   FROM BRONZE.BZ_FEATURE_USAGE 
   WHERE FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '';
   ```

### 5. **Support Ticket Data Quality Checks**

#### 5.1 **Support Ticket User Referential Integrity**
   - **Rationale**: All support tickets must be linked to valid users
   - **SQL Example**: 
   ```sql
   SELECT s.TICKET_ID, s.USER_ID
   FROM BRONZE.BZ_SUPPORT_TICKETS s
   LEFT JOIN BRONZE.BZ_USERS u ON s.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND s.USER_ID IS NOT NULL;
   ```

#### 5.2 **Resolution Status Validation**
   - **Rationale**: Resolution_Status must be from predefined list (Open, In Progress, Resolved, Closed)
   - **SQL Example**: 
   ```sql
   SELECT TICKET_ID, RESOLUTION_STATUS
   FROM BRONZE.BZ_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed')
      OR RESOLUTION_STATUS IS NULL;
   ```

#### 5.3 **Ticket Type Validation**
   - **Rationale**: Ticket types must follow predefined taxonomy for proper categorization
   - **SQL Example**: 
   ```sql
   SELECT TICKET_ID, TICKET_TYPE
   FROM BRONZE.BZ_SUPPORT_TICKETS 
   WHERE TICKET_TYPE IS NULL OR TRIM(TICKET_TYPE) = '';
   ```

### 6. **Billing Events Data Quality Checks**

#### 6.1 **Billing Event User Referential Integrity**
   - **Rationale**: All billing events must be associated with valid users
   - **SQL Example**: 
   ```sql
   SELECT b.EVENT_ID, b.USER_ID
   FROM BRONZE.BZ_BILLING_EVENTS b
   LEFT JOIN BRONZE.BZ_USERS u ON b.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND b.USER_ID IS NOT NULL;
   ```

#### 6.2 **Amount Validation**
   - **Rationale**: Amount must be a positive decimal number for valid financial transactions
   - **SQL Example**: 
   ```sql
   SELECT EVENT_ID, AMOUNT
   FROM BRONZE.BZ_BILLING_EVENTS 
   WHERE AMOUNT <= 0 OR AMOUNT IS NULL;
   ```

#### 6.3 **Event Type Validation**
   - **Rationale**: Event_Type must be from predefined billing event categories
   - **SQL Example**: 
   ```sql
   SELECT EVENT_ID, EVENT_TYPE
   FROM BRONZE.BZ_BILLING_EVENTS 
   WHERE EVENT_TYPE IS NULL OR TRIM(EVENT_TYPE) = '';
   ```

#### 6.4 **Event Date Range Validation**
   - **Rationale**: Event dates should be within reasonable business range and not in future
   - **SQL Example**: 
   ```sql
   SELECT EVENT_ID, EVENT_DATE
   FROM BRONZE.BZ_BILLING_EVENTS 
   WHERE EVENT_DATE > CURRENT_DATE() 
      OR EVENT_DATE < '2020-01-01'
      OR EVENT_DATE IS NULL;
   ```

### 7. **License Data Quality Checks**

#### 7.1 **License User Referential Integrity**
   - **Rationale**: All licenses must be assigned to valid users
   - **SQL Example**: 
   ```sql
   SELECT l.LICENSE_ID, l.ASSIGNED_TO_USER_ID
   FROM BRONZE.BZ_LICENSES l
   LEFT JOIN BRONZE.BZ_USERS u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND l.ASSIGNED_TO_USER_ID IS NOT NULL;
   ```

#### 7.2 **License Date Validation**
   - **Rationale**: Start_Date must be before End_Date for logical license validity period
   - **SQL Example**: 
   ```sql
   SELECT LICENSE_ID, START_DATE, END_DATE
   FROM BRONZE.BZ_LICENSES 
   WHERE START_DATE IS NOT NULL 
     AND END_DATE IS NOT NULL 
     AND START_DATE >= END_DATE;
   ```

#### 7.3 **License Type Validation**
   - **Rationale**: License_Type must match predefined license categories
   - **SQL Example**: 
   ```sql
   SELECT LICENSE_ID, LICENSE_TYPE
   FROM BRONZE.BZ_LICENSES 
   WHERE LICENSE_TYPE IS NULL OR TRIM(LICENSE_TYPE) = '';
   ```

### 8. **Cross-Table Business Logic Checks**

#### 8.1 **User Plan and License Consistency**
   - **Rationale**: User Plan_Type should be consistent with assigned License_Type
   - **SQL Example**: 
   ```sql
   SELECT u.USER_ID, u.PLAN_TYPE, l.LICENSE_TYPE
   FROM BRONZE.BZ_USERS u
   JOIN BRONZE.BZ_LICENSES l ON u.USER_ID = l.ASSIGNED_TO_USER_ID
   WHERE u.PLAN_TYPE != l.LICENSE_TYPE
     AND l.END_DATE >= CURRENT_DATE();
   ```

#### 8.2 **Active User Definition Validation**
   - **Rationale**: Users marked as active should have hosted at least one meeting as per business rules
   - **SQL Example**: 
   ```sql
   SELECT u.USER_ID, u.USER_NAME
   FROM BRONZE.BZ_USERS u
   LEFT JOIN BRONZE.BZ_MEETINGS m ON u.USER_ID = m.HOST_ID
   WHERE m.HOST_ID IS NULL;
   ```

### 9. **Data Freshness and Completeness Checks**

#### 9.1 **Data Load Timestamp Validation**
   - **Rationale**: All records should have valid load timestamps for audit purposes
   - **SQL Example**: 
   ```sql
   SELECT 'BZ_USERS' as table_name, COUNT(*) as records_without_load_timestamp
   FROM BRONZE.BZ_USERS WHERE LOAD_TIMESTAMP IS NULL
   UNION ALL
   SELECT 'BZ_MEETINGS', COUNT(*) FROM BRONZE.BZ_MEETINGS WHERE LOAD_TIMESTAMP IS NULL
   UNION ALL
   SELECT 'BZ_PARTICIPANTS', COUNT(*) FROM BRONZE.BZ_PARTICIPANTS WHERE LOAD_TIMESTAMP IS NULL;
   ```

#### 9.2 **Source System Validation**
   - **Rationale**: All records should have source system information for data lineage
   - **SQL Example**: 
   ```sql
   SELECT 'BZ_USERS' as table_name, COUNT(*) as records_without_source
   FROM BRONZE.BZ_USERS WHERE SOURCE_SYSTEM IS NULL OR TRIM(SOURCE_SYSTEM) = ''
   UNION ALL
   SELECT 'BZ_MEETINGS', COUNT(*) FROM BRONZE.BZ_MEETINGS WHERE SOURCE_SYSTEM IS NULL OR TRIM(SOURCE_SYSTEM) = '';
   ```

### 10. **Anomaly Detection Checks**

#### 10.1 **Unusual Meeting Duration Detection**
   - **Rationale**: Identify meetings with unusually long or short durations that may indicate data quality issues
   - **SQL Example**: 
   ```sql
   SELECT MEETING_ID, DURATION_MINUTES
   FROM BRONZE.BZ_MEETINGS 
   WHERE DURATION_MINUTES > 1440 -- More than 24 hours
      OR DURATION_MINUTES < 1; -- Less than 1 minute
   ```

#### 10.2 **Excessive Feature Usage Detection**
   - **Rationale**: Identify abnormally high usage counts that may indicate data corruption
   - **SQL Example**: 
   ```sql
   SELECT USAGE_ID, FEATURE_NAME, USAGE_COUNT
   FROM BRONZE.BZ_FEATURE_USAGE 
   WHERE USAGE_COUNT > 1000; -- Threshold for investigation
   ```

#### 10.3 **Future Date Detection**
   - **Rationale**: Identify records with future dates that may indicate system clock issues
   - **SQL Example**: 
   ```sql
   SELECT 'BZ_MEETINGS' as table_name, MEETING_ID as record_id, START_TIME as future_date
   FROM BRONZE.BZ_MEETINGS WHERE START_TIME > CURRENT_TIMESTAMP()
   UNION ALL
   SELECT 'BZ_SUPPORT_TICKETS', TICKET_ID, OPEN_DATE FROM BRONZE.BZ_SUPPORT_TICKETS WHERE OPEN_DATE > CURRENT_DATE();
   ```

### 11. **Data Quality Scoring Framework**

#### 11.1 **Overall Data Quality Score Calculation**
   - **Rationale**: Provide a comprehensive data quality score for monitoring and improvement
   - **SQL Example**: 
   ```sql
   WITH quality_metrics AS (
     SELECT 
       'BZ_USERS' as table_name,
       COUNT(*) as total_records,
       SUM(CASE WHEN USER_ID IS NULL THEN 1 ELSE 0 END) as null_ids,
       SUM(CASE WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 1 ELSE 0 END) as invalid_emails
     FROM BRONZE.BZ_USERS
   )
   SELECT 
     table_name,
     total_records,
     ROUND(((total_records - null_ids - invalid_emails) * 100.0 / total_records), 2) as quality_score_percentage
   FROM quality_metrics;
   ```

### 12. **Recommended Implementation Strategy**

#### 12.1 **Priority Levels**
1. **Critical (P1)**: Referential integrity, null key fields, data type violations
2. **High (P2)**: Business rule violations, format validations
3. **Medium (P3)**: Completeness checks, consistency validations
4. **Low (P4)**: Anomaly detection, optimization recommendations

#### 12.2 **Automation Recommendations**
- Implement automated daily data quality checks
- Set up alerts for critical data quality failures
- Create data quality dashboards for monitoring trends
- Establish data quality SLAs and reporting mechanisms

#### 12.3 **Error Handling Strategy**
- Quarantine records that fail critical validations
- Implement data correction workflows
- Maintain audit trail of all data quality issues and resolutions
- Regular review and update of data quality rules based on business changes