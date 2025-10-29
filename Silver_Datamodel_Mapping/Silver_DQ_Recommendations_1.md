_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data quality recommendations for Zoom Platform Analytics System Silver layer
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Quality Recommendations
## Zoom Platform Analytics System

## 1. **User Data Quality Checks (SILVER.SI_USERS)**

### 1.1 **User ID Validation Check**
   - **Rationale**: USER_ID is the primary identifier and must be unique and non-null to ensure data integrity and proper referential relationships
   - **SQL Example**:
   ```sql
   -- Check for null or empty USER_ID
   SELECT COUNT(*) as null_user_ids
   FROM SILVER.SI_USERS 
   WHERE USER_ID IS NULL OR TRIM(USER_ID) = '';
   
   -- Check for duplicate USER_ID
   SELECT USER_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_USERS 
   GROUP BY USER_ID 
   HAVING COUNT(*) > 1;
   ```

### 1.2 **Email Format Validation Check**
   - **Rationale**: Email addresses must follow valid format patterns for communication and user identification, as specified in business rules
   - **SQL Example**:
   ```sql
   -- Validate email format using regex pattern
   SELECT COUNT(*) as invalid_emails
   FROM SILVER.SI_USERS 
   WHERE EMAIL IS NOT NULL 
   AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
   ```

### 1.3 **Plan Type Enumeration Check**
   - **Rationale**: PLAN_TYPE must be from predefined list (Free, Basic, Pro, Enterprise) as per business constraints
   - **SQL Example**:
   ```sql
   -- Check for invalid plan types
   SELECT PLAN_TYPE, COUNT(*) as invalid_count
   FROM SILVER.SI_USERS 
   WHERE PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise')
   GROUP BY PLAN_TYPE;
   ```

### 1.4 **Account Status Validation Check**
   - **Rationale**: Account status must be from valid enumerated values to ensure consistent user lifecycle tracking
   - **SQL Example**:
   ```sql
   -- Validate account status values
   SELECT ACCOUNT_STATUS, COUNT(*) as invalid_status_count
   FROM SILVER.SI_USERS 
   WHERE ACCOUNT_STATUS NOT IN ('Active', 'Inactive', 'Suspended')
   GROUP BY ACCOUNT_STATUS;
   ```

### 1.5 **Registration Date Logic Check**
   - **Rationale**: Registration date cannot be in the future and should be reasonable (not before platform launch)
   - **SQL Example**:
   ```sql
   -- Check for future registration dates
   SELECT COUNT(*) as future_registrations
   FROM SILVER.SI_USERS 
   WHERE REGISTRATION_DATE > CURRENT_DATE();
   
   -- Check for unreasonably old registration dates
   SELECT COUNT(*) as old_registrations
   FROM SILVER.SI_USERS 
   WHERE REGISTRATION_DATE < '2011-01-01'; -- Zoom founded in 2011
   ```

## 2. **Meeting Data Quality Checks (SILVER.SI_MEETINGS)**

### 2.1 **Meeting ID Uniqueness Check**
   - **Rationale**: MEETING_ID must be unique and non-null as it's the primary identifier for meeting records
   - **SQL Example**:
   ```sql
   -- Check for duplicate meeting IDs
   SELECT MEETING_ID, COUNT(*) as duplicate_count
   FROM SILVER.SI_MEETINGS 
   GROUP BY MEETING_ID 
   HAVING COUNT(*) > 1;
   ```

### 2.2 **Meeting Duration Validation Check**
   - **Rationale**: Duration must be non-negative, minimum 1 minute for analytics inclusion, maximum 24 hours (1440 minutes) as per business rules
   - **SQL Example**:
   ```sql
   -- Check for invalid duration values
   SELECT COUNT(*) as invalid_durations
   FROM SILVER.SI_MEETINGS 
   WHERE DURATION_MINUTES < 0 OR DURATION_MINUTES > 1440;
   
   -- Check for meetings under minimum threshold
   SELECT COUNT(*) as short_meetings
   FROM SILVER.SI_MEETINGS 
   WHERE DURATION_MINUTES < 1;
   ```

### 2.3 **Meeting Time Logic Check**
   - **Rationale**: END_TIME must be greater than or equal to START_TIME, and calculated duration should match stored duration
   - **SQL Example**:
   ```sql
   -- Check for invalid time relationships
   SELECT COUNT(*) as invalid_time_logic
   FROM SILVER.SI_MEETINGS 
   WHERE END_TIME < START_TIME;
   
   -- Validate calculated vs stored duration
   SELECT COUNT(*) as duration_mismatch
   FROM SILVER.SI_MEETINGS 
   WHERE ABS(DATEDIFF('minute', START_TIME, END_TIME) - DURATION_MINUTES) > 1;
   ```

### 2.4 **Host ID Referential Integrity Check**
   - **Rationale**: HOST_ID must reference valid users in SI_USERS table to maintain referential integrity
   - **SQL Example**:
   ```sql
   -- Check for orphaned host references
   SELECT COUNT(*) as orphaned_hosts
   FROM SILVER.SI_MEETINGS m
   LEFT JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND m.HOST_ID IS NOT NULL;
   ```

### 2.5 **Meeting Type Enumeration Check**
   - **Rationale**: MEETING_TYPE must be from predefined list (Scheduled, Instant, Webinar, Personal) as per business constraints
   - **SQL Example**:
   ```sql
   -- Check for invalid meeting types
   SELECT MEETING_TYPE, COUNT(*) as invalid_count
   FROM SILVER.SI_MEETINGS 
   WHERE MEETING_TYPE NOT IN ('Scheduled', 'Instant', 'Webinar', 'Personal')
   GROUP BY MEETING_TYPE;
   ```

## 3. **Participant Data Quality Checks (SILVER.SI_PARTICIPANTS)**

### 3.1 **Participant Referential Integrity Check**
   - **Rationale**: MEETING_ID and USER_ID must reference valid records in their respective tables
   - **SQL Example**:
   ```sql
   -- Check for invalid meeting references
   SELECT COUNT(*) as invalid_meeting_refs
   FROM SILVER.SI_PARTICIPANTS p
   LEFT JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL;
   
   -- Check for invalid user references
   SELECT COUNT(*) as invalid_user_refs
   FROM SILVER.SI_PARTICIPANTS p
   LEFT JOIN SILVER.SI_USERS u ON p.USER_ID = u.USER_ID
   WHERE u.USER_ID IS NULL AND p.USER_ID IS NOT NULL;
   ```

### 3.2 **Attendance Duration Logic Check**
   - **Rationale**: LEAVE_TIME must be greater than or equal to JOIN_TIME, and attendance duration should be calculated correctly
   - **SQL Example**:
   ```sql
   -- Check for invalid attendance time logic
   SELECT COUNT(*) as invalid_attendance_logic
   FROM SILVER.SI_PARTICIPANTS 
   WHERE LEAVE_TIME < JOIN_TIME;
   
   -- Validate calculated attendance duration
   SELECT COUNT(*) as duration_calculation_errors
   FROM SILVER.SI_PARTICIPANTS 
   WHERE ABS(DATEDIFF('minute', JOIN_TIME, LEAVE_TIME) - ATTENDANCE_DURATION) > 1;
   ```

### 3.3 **Participant Role Validation Check**
   - **Rationale**: PARTICIPANT_ROLE must be from valid enumerated values (Host, Co-host, Participant, Observer)
   - **SQL Example**:
   ```sql
   -- Check for invalid participant roles
   SELECT PARTICIPANT_ROLE, COUNT(*) as invalid_count
   FROM SILVER.SI_PARTICIPANTS 
   WHERE PARTICIPANT_ROLE NOT IN ('Host', 'Co-host', 'Participant', 'Observer')
   GROUP BY PARTICIPANT_ROLE;
   ```

## 4. **Feature Usage Data Quality Checks (SILVER.SI_FEATURE_USAGE)**

### 4.1 **Usage Count Validation Check**
   - **Rationale**: USAGE_COUNT must be non-negative integer as per business constraints
   - **SQL Example**:
   ```sql
   -- Check for negative usage counts
   SELECT COUNT(*) as negative_usage_counts
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE USAGE_COUNT < 0;
   ```

### 4.2 **Feature Category Validation Check**
   - **Rationale**: FEATURE_CATEGORY must be from predefined classifications (Audio, Video, Collaboration, Security)
   - **SQL Example**:
   ```sql
   -- Check for invalid feature categories
   SELECT FEATURE_CATEGORY, COUNT(*) as invalid_count
   FROM SILVER.SI_FEATURE_USAGE 
   WHERE FEATURE_CATEGORY NOT IN ('Audio', 'Video', 'Collaboration', 'Security')
   GROUP BY FEATURE_CATEGORY;
   ```

### 4.3 **Meeting Reference Integrity Check**
   - **Rationale**: MEETING_ID must reference valid meetings to ensure feature usage is properly attributed
   - **SQL Example**:
   ```sql
   -- Check for orphaned feature usage records
   SELECT COUNT(*) as orphaned_feature_usage
   FROM SILVER.SI_FEATURE_USAGE f
   LEFT JOIN SILVER.SI_MEETINGS m ON f.MEETING_ID = m.MEETING_ID
   WHERE m.MEETING_ID IS NULL;
   ```

## 5. **Support Ticket Data Quality Checks (SILVER.SI_SUPPORT_TICKETS)**

### 5.1 **Ticket Type Enumeration Check**
   - **Rationale**: TICKET_TYPE must be from predefined list (Technical, Billing, Feature Request, Bug Report) as per business constraints
   - **SQL Example**:
   ```sql
   -- Check for invalid ticket types
   SELECT TICKET_TYPE, COUNT(*) as invalid_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE TICKET_TYPE NOT IN ('Technical', 'Billing', 'Feature Request', 'Bug Report')
   GROUP BY TICKET_TYPE;
   ```

### 5.2 **Priority Level Validation Check**
   - **Rationale**: PRIORITY_LEVEL must be from predefined list (Low, Medium, High, Critical) for proper SLA management
   - **SQL Example**:
   ```sql
   -- Check for invalid priority levels
   SELECT PRIORITY_LEVEL, COUNT(*) as invalid_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE PRIORITY_LEVEL NOT IN ('Low', 'Medium', 'High', 'Critical')
   GROUP BY PRIORITY_LEVEL;
   ```

### 5.3 **Resolution Status Validation Check**
   - **Rationale**: RESOLUTION_STATUS must be from predefined list (Open, In Progress, Resolved, Closed) for proper tracking
   - **SQL Example**:
   ```sql
   -- Check for invalid resolution status
   SELECT RESOLUTION_STATUS, COUNT(*) as invalid_count
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed')
   GROUP BY RESOLUTION_STATUS;
   ```

### 5.4 **Date Logic Validation Check**
   - **Rationale**: CLOSE_DATE must be greater than or equal to OPEN_DATE, and OPEN_DATE cannot be future date
   - **SQL Example**:
   ```sql
   -- Check for invalid date logic
   SELECT COUNT(*) as invalid_date_logic
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE CLOSE_DATE < OPEN_DATE;
   
   -- Check for future open dates
   SELECT COUNT(*) as future_open_dates
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE OPEN_DATE > CURRENT_DATE();
   ```

### 5.5 **Resolution Time Calculation Check**
   - **Rationale**: Resolution time should be calculated correctly in business hours as per business rules
   - **SQL Example**:
   ```sql
   -- Validate resolution time calculation (simplified check)
   SELECT COUNT(*) as invalid_resolution_times
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_TIME_HOURS < 0 
   OR (CLOSE_DATE IS NOT NULL AND RESOLUTION_TIME_HOURS IS NULL);
   ```

## 6. **Billing Event Data Quality Checks (SILVER.SI_BILLING_EVENTS)**

### 6.1 **Transaction Amount Validation Check**
   - **Rationale**: TRANSACTION_AMOUNT must be positive for most event types, except refunds which can be negative
   - **SQL Example**:
   ```sql
   -- Check for invalid transaction amounts
   SELECT COUNT(*) as invalid_amounts
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE (EVENT_TYPE != 'Refund' AND TRANSACTION_AMOUNT <= 0)
   OR (EVENT_TYPE = 'Refund' AND TRANSACTION_AMOUNT >= 0);
   ```

### 6.2 **Event Type Enumeration Check**
   - **Rationale**: EVENT_TYPE must be from predefined list (Subscription, Upgrade, Downgrade, Refund) as per business constraints
   - **SQL Example**:
   ```sql
   -- Check for invalid event types
   SELECT EVENT_TYPE, COUNT(*) as invalid_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE EVENT_TYPE NOT IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund')
   GROUP BY EVENT_TYPE;
   ```

### 6.3 **Currency Code Validation Check**
   - **Rationale**: CURRENCY_CODE must be valid 3-character ISO currency codes as per business constraints
   - **SQL Example**:
   ```sql
   -- Check for invalid currency codes (basic validation)
   SELECT CURRENCY_CODE, COUNT(*) as invalid_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE LENGTH(CURRENCY_CODE) != 3 OR CURRENCY_CODE IS NULL
   GROUP BY CURRENCY_CODE;
   ```

### 6.4 **Transaction Status Validation Check**
   - **Rationale**: TRANSACTION_STATUS must be from valid enumerated values (Completed, Pending, Failed, Refunded)
   - **SQL Example**:
   ```sql
   -- Check for invalid transaction status
   SELECT TRANSACTION_STATUS, COUNT(*) as invalid_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE TRANSACTION_STATUS NOT IN ('Completed', 'Pending', 'Failed', 'Refunded')
   GROUP BY TRANSACTION_STATUS;
   ```

### 6.5 **Invoice Number Uniqueness Check**
   - **Rationale**: INVOICE_NUMBER must be unique across billing events to prevent duplicate billing
   - **SQL Example**:
   ```sql
   -- Check for duplicate invoice numbers
   SELECT INVOICE_NUMBER, COUNT(*) as duplicate_count
   FROM SILVER.SI_BILLING_EVENTS 
   WHERE INVOICE_NUMBER IS NOT NULL
   GROUP BY INVOICE_NUMBER 
   HAVING COUNT(*) > 1;
   ```

## 7. **License Data Quality Checks (SILVER.SI_LICENSES)**

### 7.1 **License Type Enumeration Check**
   - **Rationale**: LICENSE_TYPE must be from predefined list (Basic, Pro, Enterprise, Add-on) as per business constraints
   - **SQL Example**:
   ```sql
   -- Check for invalid license types
   SELECT LICENSE_TYPE, COUNT(*) as invalid_count
   FROM SILVER.SI_LICENSES 
   WHERE LICENSE_TYPE NOT IN ('Basic', 'Pro', 'Enterprise', 'Add-on')
   GROUP BY LICENSE_TYPE;
   ```

### 7.2 **License Date Logic Check**
   - **Rationale**: START_DATE must be before END_DATE, and dates must be reasonable
   - **SQL Example**:
   ```sql
   -- Check for invalid date logic
   SELECT COUNT(*) as invalid_date_logic
   FROM SILVER.SI_LICENSES 
   WHERE START_DATE >= END_DATE;
   ```

### 7.3 **License Status Validation Check**
   - **Rationale**: LICENSE_STATUS must be from valid enumerated values (Active, Expired, Suspended)
   - **SQL Example**:
   ```sql
   -- Check for invalid license status
   SELECT LICENSE_STATUS, COUNT(*) as invalid_count
   FROM SILVER.SI_LICENSES 
   WHERE LICENSE_STATUS NOT IN ('Active', 'Expired', 'Suspended')
   GROUP BY LICENSE_STATUS;
   ```

### 7.4 **License Cost Validation Check**
   - **Rationale**: LICENSE_COST must be non-negative for valid business transactions
   - **SQL Example**:
   ```sql
   -- Check for negative license costs
   SELECT COUNT(*) as negative_costs
   FROM SILVER.SI_LICENSES 
   WHERE LICENSE_COST < 0;
   ```

### 7.5 **Utilization Percentage Range Check**
   - **Rationale**: UTILIZATION_PERCENTAGE must be between 0 and 100
   - **SQL Example**:
   ```sql
   -- Check for invalid utilization percentages
   SELECT COUNT(*) as invalid_utilization
   FROM SILVER.SI_LICENSES 
   WHERE UTILIZATION_PERCENTAGE < 0 OR UTILIZATION_PERCENTAGE > 100;
   ```

## 8. **Webinar Data Quality Checks (SILVER.SI_WEBINARS)**

### 8.1 **Webinar Duration Logic Check**
   - **Rationale**: END_TIME must be greater than START_TIME, and duration should be calculated correctly
   - **SQL Example**:
   ```sql
   -- Check for invalid webinar time logic
   SELECT COUNT(*) as invalid_time_logic
   FROM SILVER.SI_WEBINARS 
   WHERE END_TIME <= START_TIME;
   
   -- Validate calculated duration
   SELECT COUNT(*) as duration_mismatch
   FROM SILVER.SI_WEBINARS 
   WHERE ABS(DATEDIFF('minute', START_TIME, END_TIME) - DURATION_MINUTES) > 1;
   ```

### 8.2 **Attendance Rate Logic Check**
   - **Rationale**: ATTENDEES cannot exceed REGISTRANTS, and attendance rate should be calculated correctly
   - **SQL Example**:
   ```sql
   -- Check for invalid attendance logic
   SELECT COUNT(*) as invalid_attendance
   FROM SILVER.SI_WEBINARS 
   WHERE ATTENDEES > REGISTRANTS;
   
   -- Validate attendance rate calculation
   SELECT COUNT(*) as rate_calculation_errors
   FROM SILVER.SI_WEBINARS 
   WHERE REGISTRANTS > 0 
   AND ABS((ATTENDEES::FLOAT / REGISTRANTS * 100) - ATTENDANCE_RATE) > 0.01;
   ```

### 8.3 **Registrant and Attendee Count Validation**
   - **Rationale**: Both counts must be non-negative integers
   - **SQL Example**:
   ```sql
   -- Check for negative counts
   SELECT COUNT(*) as negative_counts
   FROM SILVER.SI_WEBINARS 
   WHERE REGISTRANTS < 0 OR ATTENDEES < 0;
   ```

## 9. **Cross-Table Data Quality Checks**

### 9.1 **User Activity Consistency Check**
   - **Rationale**: Users with meeting or support activity should exist in the users table
   - **SQL Example**:
   ```sql
   -- Check for users in meetings but not in users table
   SELECT COUNT(DISTINCT m.HOST_ID) as missing_hosts
   FROM SILVER.SI_MEETINGS m
   LEFT JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID
   WHERE u.USER_ID IS NULL;
   ```

### 9.2 **Revenue and License Correlation Check**
   - **Rationale**: Billing events should correlate with license assignments for the same users
   - **SQL Example**:
   ```sql
   -- Check for billing events without corresponding licenses
   SELECT COUNT(*) as billing_without_license
   FROM SILVER.SI_BILLING_EVENTS b
   LEFT JOIN SILVER.SI_LICENSES l ON b.USER_ID = l.ASSIGNED_TO_USER_ID
   WHERE l.ASSIGNED_TO_USER_ID IS NULL 
   AND b.EVENT_TYPE IN ('Subscription', 'Upgrade');
   ```

### 9.3 **Meeting Participant Consistency Check**
   - **Rationale**: Meeting participant count should match actual participant records
   - **SQL Example**:
   ```sql
   -- Compare meeting participant count with actual participants
   SELECT m.MEETING_ID, m.PARTICIPANT_COUNT, COUNT(p.PARTICIPANT_ID) as actual_count
   FROM SILVER.SI_MEETINGS m
   LEFT JOIN SILVER.SI_PARTICIPANTS p ON m.MEETING_ID = p.MEETING_ID
   GROUP BY m.MEETING_ID, m.PARTICIPANT_COUNT
   HAVING m.PARTICIPANT_COUNT != COUNT(p.PARTICIPANT_ID);
   ```

## 10. **Data Quality Score Validation**

### 10.1 **Data Quality Score Range Check**
   - **Rationale**: DATA_QUALITY_SCORE must be between 0.00 and 1.00 across all tables
   - **SQL Example**:
   ```sql
   -- Check data quality scores across all tables
   SELECT 'SI_USERS' as table_name, COUNT(*) as invalid_scores
   FROM SILVER.SI_USERS 
   WHERE DATA_QUALITY_SCORE < 0 OR DATA_QUALITY_SCORE > 1
   UNION ALL
   SELECT 'SI_MEETINGS', COUNT(*)
   FROM SILVER.SI_MEETINGS 
   WHERE DATA_QUALITY_SCORE < 0 OR DATA_QUALITY_SCORE > 1;
   -- Add similar checks for other tables
   ```

## 11. **Metadata Quality Checks**

### 11.1 **Load Timestamp Validation**
   - **Rationale**: LOAD_TIMESTAMP should not be null and should be reasonable (not future dates)
   - **SQL Example**:
   ```sql
   -- Check for null or future load timestamps
   SELECT COUNT(*) as invalid_load_timestamps
   FROM SILVER.SI_USERS 
   WHERE LOAD_TIMESTAMP IS NULL OR LOAD_TIMESTAMP > CURRENT_TIMESTAMP();
   ```

### 11.2 **Source System Validation**
   - **Rationale**: SOURCE_SYSTEM should not be null and should be from expected values
   - **SQL Example**:
   ```sql
   -- Check for null or unexpected source systems
   SELECT SOURCE_SYSTEM, COUNT(*) as record_count
   FROM SILVER.SI_USERS 
   WHERE SOURCE_SYSTEM IS NULL OR TRIM(SOURCE_SYSTEM) = ''
   GROUP BY SOURCE_SYSTEM;
   ```

## 12. **Business Rule Validation Checks**

### 12.1 **Active User Definition Validation**
   - **Rationale**: Ensure active user calculations follow business rules (hosted or attended at least one meeting)
   - **SQL Example**:
   ```sql
   -- Validate daily active users
   SELECT COUNT(DISTINCT u.USER_ID) as dau_count
   FROM SILVER.SI_USERS u
   INNER JOIN (
       SELECT DISTINCT HOST_ID as USER_ID FROM SILVER.SI_MEETINGS 
       WHERE DATE(START_TIME) = CURRENT_DATE() - 1
       UNION
       SELECT DISTINCT USER_ID FROM SILVER.SI_PARTICIPANTS 
       WHERE DATE(JOIN_TIME) = CURRENT_DATE() - 1
   ) active ON u.USER_ID = active.USER_ID;
   ```

### 12.2 **SLA Compliance Check**
   - **Rationale**: Validate that support tickets meet SLA requirements based on priority levels
   - **SQL Example**:
   ```sql
   -- Check SLA compliance
   SELECT 
       PRIORITY_LEVEL,
       COUNT(*) as total_tickets,
       SUM(CASE 
           WHEN PRIORITY_LEVEL = 'Critical' AND RESOLUTION_TIME_HOURS > 4 THEN 1
           WHEN PRIORITY_LEVEL = 'High' AND RESOLUTION_TIME_HOURS > 24 THEN 1
           WHEN PRIORITY_LEVEL = 'Medium' AND RESOLUTION_TIME_HOURS > 72 THEN 1
           WHEN PRIORITY_LEVEL = 'Low' AND RESOLUTION_TIME_HOURS > 168 THEN 1
           ELSE 0
       END) as sla_violations
   FROM SILVER.SI_SUPPORT_TICKETS 
   WHERE RESOLUTION_STATUS = 'Resolved'
   GROUP BY PRIORITY_LEVEL;
   ```

## 13. **Comprehensive Data Quality Summary Check**

### 13.1 **Overall Data Quality Assessment**
   - **Rationale**: Provide a comprehensive view of data quality across all Silver layer tables
   - **SQL Example**:
   ```sql
   -- Comprehensive data quality summary
   WITH quality_summary AS (
       SELECT 
           'SI_USERS' as table_name,
           COUNT(*) as total_records,
           AVG(DATA_QUALITY_SCORE) as avg_quality_score,
           SUM(CASE WHEN DATA_QUALITY_SCORE < 0.8 THEN 1 ELSE 0 END) as low_quality_records
       FROM SILVER.SI_USERS
       UNION ALL
       SELECT 
           'SI_MEETINGS',
           COUNT(*),
           AVG(DATA_QUALITY_SCORE),
           SUM(CASE WHEN DATA_QUALITY_SCORE < 0.8 THEN 1 ELSE 0 END)
       FROM SILVER.SI_MEETINGS
       -- Add similar queries for other tables
   )
   SELECT 
       table_name,
       total_records,
       ROUND(avg_quality_score, 3) as avg_quality_score,
       low_quality_records,
       ROUND((low_quality_records::FLOAT / total_records * 100), 2) as low_quality_percentage
   FROM quality_summary
   ORDER BY avg_quality_score DESC;
   ```

---

**Note**: These data quality checks should be implemented as part of the Silver layer ETL pipeline and executed regularly to ensure data integrity and compliance with business rules. Failed checks should trigger alerts and be logged in the SI_DATA_QUALITY_ERRORS table for tracking and resolution.