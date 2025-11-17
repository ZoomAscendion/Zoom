_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer Data Quality Recommendations for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Quality Recommendations for Zoom Platform Analytics System

## Recommended Data Quality Checks:

### 1. SI_USERS Table Data Quality Checks

#### 1.1 User ID Validation Check
   - **Rationale**: USER_ID is the primary identifier and must be unique and non-null to ensure data integrity
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as duplicate_user_ids
   FROM SILVER.SI_USERS 
   WHERE USER_ID IS NULL 
      OR USER_ID IN (
          SELECT USER_ID 
          FROM SILVER.SI_USERS 
          GROUP BY USER_ID 
          HAVING COUNT(*) > 1
      );
   ```

#### 1.2 Email Format Validation Check
   - **Rationale**: Email addresses must follow standard format patterns for communication and user identification
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_emails
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NOT NULL 
     AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
   ```

#### 1.3 Plan Type Standardization Check
   - **Rationale**: Plan types must be from predefined values as per business rules to ensure consistent categorization
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_plan_types
   FROM SILVER.SI_USERS 
   WHERE PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') 
      OR PLAN_TYPE IS NULL;
   ```

#### 1.4 Data Quality Score Range Check
   - **Rationale**: Data quality scores must be within valid range (0-100) to maintain scoring consistency
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_quality_scores
   FROM SILVER.SI_USERS 
   WHERE DATA_QUALITY_SCORE < 0 
      OR DATA_QUALITY_SCORE > 100 
      OR DATA_QUALITY_SCORE IS NULL;
   ```

### 2. SI_MEETINGS Table Data Quality Checks

#### 2.1 Meeting ID Uniqueness Check
   - **Rationale**: Each meeting must have a unique identifier to prevent data duplication and ensure accurate tracking
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as duplicate_meeting_ids
   FROM SILVER.SI_MEETINGS 
   WHERE MEETING_ID IS NULL 
      OR MEETING_ID IN (
          SELECT MEETING_ID 
          FROM SILVER.SI_MEETINGS 
          GROUP BY MEETING_ID 
          HAVING COUNT(*) > 1
      );
   ```

#### 2.2 Meeting Duration Consistency Check
   - **Rationale**: Duration must match the calculated difference between start and end times as per business rules
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as inconsistent_durations
   FROM SILVER.SI_MEETINGS 
   WHERE ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1
      OR DURATION_MINUTES < 0;
   ```

#### 2.3 Meeting Time Sequence Check
   - **Rationale**: End time must be after start time to ensure logical meeting flow
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_time_sequences
   FROM SILVER.SI_MEETINGS 
   WHERE END_TIME <= START_TIME 
      OR START_TIME IS NULL 
      OR END_TIME IS NULL;
   ```

#### 2.4 Host ID Referential Integrity Check
   - **Rationale**: Host ID must reference a valid user to maintain data relationships
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_host_references
   FROM SILVER.SI_MEETINGS m
   LEFT JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND m.HOST_ID IS NOT NULL;
   ```

### 3. SI_PARTICIPANTS Table Data Quality Checks

#### 3.1 Participant Session Time Validation Check
   - **Rationale**: Join time must be before leave time and within meeting duration as per business constraints
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_participant_times
   FROM SILVER.SI_PARTICIPANTS p
   JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
   WHERE p.LEAVE_TIME <= p.JOIN_TIME 
      OR p.JOIN_TIME < m.START_TIME 
      OR p.LEAVE_TIME > m.END_TIME;
   ```

#### 3.2 Meeting and User Reference Check
   - **Rationale**: Both meeting and user references must be valid to ensure data integrity
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_references
   FROM SILVER.SI_PARTICIPANTS p
   LEFT JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
   LEFT JOIN SILVER.SI_USERS u ON p.USER_ID = u.USER_ID
   WHERE m.MEETING_ID IS NULL OR u.USER_ID IS NULL;
   ```

#### 3.3 Participant Uniqueness Check
   - **Rationale**: Combination of meeting and user should be unique per session to prevent duplicate participation records
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as duplicate_participants
   FROM (
       SELECT MEETING_ID, USER_ID, COUNT(*) as cnt
       FROM SILVER.SI_PARTICIPANTS 
       GROUP BY MEETING_ID, USER_ID
       HAVING COUNT(*) > 1
   );
   ```

### 4. SI_FEATURE_USAGE Table Data Quality Checks

#### 4.1 Feature Name Standardization Check
   - **Rationale**: Feature names must follow standardized naming conventions for consistent reporting
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_feature_names
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE FEATURE_NAME IS NULL 
      OR LENGTH(FEATURE_NAME) > 100 
      OR TRIM(FEATURE_NAME) = '';
   ```

#### 4.2 Usage Count Validation Check
   - **Rationale**: Usage count must be non-negative integers as per business rules
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_usage_counts
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_COUNT < 0 
      OR USAGE_COUNT IS NULL;
   ```

#### 4.3 Meeting Reference Integrity Check
   - **Rationale**: Feature usage must be associated with valid meetings
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_meeting_references
   FROM SILVER.SI_FEATURE_USAGE f
   LEFT JOIN SILVER.SI_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL;
   ```

### 5. SI_SUPPORT_TICKETS Table Data Quality Checks

#### 5.1 Ticket Status Validation Check
   - **Rationale**: Resolution status must be from predefined values as per business constraints
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_ticket_status
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') 
      OR RESOLUTION_STATUS IS NULL;
   ```

#### 5.2 User Reference Integrity Check
   - **Rationale**: Support tickets must be associated with valid users
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_user_references
   FROM SILVER.SI_SUPPORT_TICKETS s
   LEFT JOIN SILVER.SI_USERS u ON s.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL;
   ```

#### 5.3 Ticket ID Uniqueness Check
   - **Rationale**: Each support ticket must have a unique identifier
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as duplicate_ticket_ids
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE TICKET_ID IS NULL 
      OR TICKET_ID IN (
          SELECT TICKET_ID 
          FROM SILVER.SI_SUPPORT_TICKETS 
          GROUP BY TICKET_ID 
          HAVING COUNT(*) > 1
      );
   ```

### 6. SI_BILLING_EVENTS Table Data Quality Checks

#### 6.1 Amount Validation Check
   - **Rationale**: Billing amounts must be positive numbers with appropriate precision as per business rules
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_amounts
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE AMOUNT <= 0 
      OR AMOUNT IS NULL 
      OR AMOUNT > 999999.99;
   ```

#### 6.2 Event Type Standardization Check
   - **Rationale**: Event types must follow standardized billing categories
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_event_types
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE EVENT_TYPE IS NULL 
      OR TRIM(EVENT_TYPE) = '' 
      OR LENGTH(EVENT_TYPE) > 100;
   ```

#### 6.3 User Reference Integrity Check
   - **Rationale**: Billing events must be associated with valid users
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_user_references
   FROM SILVER.SI_BILLING_EVENTS b
   LEFT JOIN SILVER.SI_USERS u ON b.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL;
   ```

### 7. SI_LICENSES Table Data Quality Checks

#### 7.1 License Date Sequence Check
   - **Rationale**: License start date must be before end date as per business constraints
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_license_dates
   FROM SILVER.SI_LICENSES 
   WHERE END_DATE <= START_DATE 
      OR START_DATE IS NULL 
      OR END_DATE IS NULL;
   ```

#### 7.2 License Type Validation Check
   - **Rationale**: License types must be from predefined categories
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_license_types
   FROM SILVER.SI_LICENSES 
   WHERE LICENSE_TYPE IS NULL 
      OR TRIM(LICENSE_TYPE) = '';
   ```

#### 7.3 User Assignment Integrity Check
   - **Rationale**: Licenses must be assigned to valid users
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_user_assignments
   FROM SILVER.SI_LICENSES l
   LEFT JOIN SILVER.SI_USERS u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL;
   ```

### 8. Cross-Table Data Quality Checks

#### 8.1 Active License Validation Check
   - **Rationale**: Users with active licenses should not have multiple active licenses of the same type
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as duplicate_active_licenses
   FROM (
       SELECT ASSIGNED_TO_USER_ID, LICENSE_TYPE, COUNT(*) as cnt
       FROM SILVER.SI_LICENSES 
       WHERE CURRENT_DATE BETWEEN START_DATE AND END_DATE
       GROUP BY ASSIGNED_TO_USER_ID, LICENSE_TYPE
       HAVING COUNT(*) > 1
   );
   ```

#### 8.2 Meeting Classification Validation Check
   - **Rationale**: Meetings should be properly classified based on business rules (Brief < 5 minutes, Collaborative >= 2 attendees)
   - **SQL Example**: 
   ```sql
   SELECT 
       COUNT(CASE WHEN DURATION_MINUTES < 5 THEN 1 END) as brief_meetings,
       COUNT(CASE WHEN participant_count >= 2 THEN 1 END) as collaborative_meetings
   FROM SILVER.SI_MEETINGS m
   LEFT JOIN (
       SELECT MEETING_ID, COUNT(*) as participant_count
       FROM SILVER.SI_PARTICIPANTS 
       GROUP BY MEETING_ID
   ) p ON m.MEETING_ID = p.MEETING_ID;
   ```

#### 8.3 Data Freshness Check
   - **Rationale**: Data should be loaded within acceptable time frames to ensure timeliness
   - **SQL Example**: 
   ```sql
   SELECT 
       'SI_USERS' as table_name,
       COUNT(*) as stale_records
   FROM SILVER.SI_USERS 
   WHERE DATEDIFF('hour', LOAD_TIMESTAMP, CURRENT_TIMESTAMP) > 24
   UNION ALL
   SELECT 
       'SI_MEETINGS' as table_name,
       COUNT(*) as stale_records
   FROM SILVER.SI_MEETINGS 
   WHERE DATEDIFF('hour', LOAD_TIMESTAMP, CURRENT_TIMESTAMP) > 24;
   ```

### 9. Metadata Quality Checks

#### 9.1 Validation Status Consistency Check
   - **Rationale**: Validation status must be from predefined values (PASSED, FAILED, WARNING)
   - **SQL Example**: 
   ```sql
   SELECT 
       'SI_USERS' as table_name,
       COUNT(*) as invalid_validation_status
   FROM SILVER.SI_USERS 
   WHERE VALIDATION_STATUS NOT IN ('PASSED', 'FAILED', 'WARNING')
   UNION ALL
   SELECT 
       'SI_MEETINGS' as table_name,
       COUNT(*) as invalid_validation_status
   FROM SILVER.SI_MEETINGS 
   WHERE VALIDATION_STATUS NOT IN ('PASSED', 'FAILED', 'WARNING');
   ```

#### 9.2 Source System Tracking Check
   - **Rationale**: All records must have valid source system information for data lineage
   - **SQL Example**: 
   ```sql
   SELECT 
       'SI_USERS' as table_name,
       COUNT(*) as missing_source_system
   FROM SILVER.SI_USERS 
   WHERE SOURCE_SYSTEM IS NULL OR TRIM(SOURCE_SYSTEM) = ''
   UNION ALL
   SELECT 
       'SI_MEETINGS' as table_name,
       COUNT(*) as missing_source_system
   FROM SILVER.SI_MEETINGS 
   WHERE SOURCE_SYSTEM IS NULL OR TRIM(SOURCE_SYSTEM) = '';
   ```

### 10. Business Rule Compliance Checks

#### 10.1 Monthly Recurring Revenue (MRR) Validation Check
   - **Rationale**: MRR calculations should only include subscription-based revenue as per business rules
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as invalid_mrr_events
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE EVENT_TYPE LIKE '%subscription%' 
     AND (AMOUNT <= 0 OR AMOUNT IS NULL);
   ```

#### 10.2 Feature Adoption Rate Validation Check
   - **Rationale**: Feature adoption rates should be calculated correctly within 30 days of feature release
   - **SQL Example**: 
   ```sql
   SELECT 
       FEATURE_NAME,
       COUNT(DISTINCT f.MEETING_ID) as meetings_with_feature,
       COUNT(DISTINCT m.MEETING_ID) as total_meetings,
       ROUND((COUNT(DISTINCT f.MEETING_ID) * 100.0 / COUNT(DISTINCT m.MEETING_ID)), 2) as adoption_rate
   FROM SILVER.SI_FEATURE_USAGE f
   RIGHT JOIN SILVER.SI_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
   WHERE m.START_TIME >= DATEADD('day', -30, CURRENT_DATE)
   GROUP BY FEATURE_NAME;
   ```

#### 10.3 Support Ticket Resolution Time Compliance Check
   - **Rationale**: Resolution times should meet business SLA targets based on priority levels
   - **SQL Example**: 
   ```sql
   SELECT COUNT(*) as sla_violations
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS = 'Resolved'
     AND (
         (TICKET_TYPE = 'Critical' AND DATEDIFF('hour', OPEN_DATE, CURRENT_DATE) > 4) OR
         (TICKET_TYPE = 'High' AND DATEDIFF('hour', OPEN_DATE, CURRENT_DATE) > 24) OR
         (TICKET_TYPE = 'Medium' AND DATEDIFF('hour', OPEN_DATE, CURRENT_DATE) > 72) OR
         (TICKET_TYPE = 'Low' AND DATEDIFF('day', OPEN_DATE, CURRENT_DATE) > 7)
     );
   ```

## Summary

These data quality checks ensure:
1. **Data Integrity**: Unique identifiers, referential integrity, and proper data relationships
2. **Data Accuracy**: Format validation, range checks, and business rule compliance
3. **Data Completeness**: Non-null validations for critical fields
4. **Data Consistency**: Standardized values and cross-table validation
5. **Data Timeliness**: Freshness checks and processing time validation
6. **Business Rule Compliance**: Adherence to Zoom Platform Analytics business requirements

Implementing these checks will significantly improve the reliability and trustworthiness of the Silver layer data, enabling accurate analytics and reporting for the Zoom Platform Analytics System.