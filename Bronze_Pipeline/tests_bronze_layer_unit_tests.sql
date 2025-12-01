-- =====================================================
-- BRONZE LAYER COMPREHENSIVE UNIT TESTS
-- =====================================================
-- Purpose: Validate data transformations, business rules, and edge cases
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.0
-- =====================================================

-- =====================================================
-- TEST 1: BZ_USERS - Primary Key Uniqueness
-- =====================================================
-- Test that user_id is unique across all records
SELECT 'bz_users_unique_user_id' AS test_name,
       COUNT(*) AS total_records,
       COUNT(DISTINCT user_id) AS unique_user_ids,
       CASE 
           WHEN COUNT(*) = COUNT(DISTINCT user_id) THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_users') }}
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 2: BZ_USERS - Email Format Validation
-- =====================================================
-- Test that email addresses follow proper format
SELECT 'bz_users_email_format' AS test_name,
       COUNT(*) AS invalid_emails,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_users') }}
WHERE email IS NOT NULL 
  AND email NOT RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 3: BZ_USERS - Plan Type Validation
-- =====================================================
-- Test that plan_type contains only valid values
SELECT 'bz_users_plan_type_validation' AS test_name,
       COUNT(*) AS invalid_plan_types,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_users') }}
WHERE plan_type IS NOT NULL 
  AND plan_type NOT IN ('Basic', 'Pro', 'Business', 'Enterprise')
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 4: BZ_MEETINGS - Meeting Duration Validation
-- =====================================================
-- Test that meeting duration is consistent with start/end times
SELECT 'bz_meetings_duration_consistency' AS test_name,
       COUNT(*) AS inconsistent_durations,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_meetings') }}
WHERE start_time IS NOT NULL 
  AND end_time IS NOT NULL 
  AND duration_minutes IS NOT NULL
  AND ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 5: BZ_MEETINGS - Time Range Validation
-- =====================================================
-- Test that start_time is before end_time
SELECT 'bz_meetings_time_range_validation' AS test_name,
       COUNT(*) AS invalid_time_ranges,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_meetings') }}
WHERE start_time IS NOT NULL 
  AND end_time IS NOT NULL 
  AND start_time >= end_time
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 6: BZ_PARTICIPANTS - Join/Leave Time Validation
-- =====================================================
-- Test that join_time is before leave_time
SELECT 'bz_participants_time_validation' AS test_name,
       COUNT(*) AS invalid_participant_times,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_participants') }}
WHERE join_time IS NOT NULL 
  AND leave_time IS NOT NULL 
  AND join_time >= leave_time
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 7: BZ_FEATURE_USAGE - Usage Count Validation
-- =====================================================
-- Test that usage_count is non-negative
SELECT 'bz_feature_usage_count_validation' AS test_name,
       COUNT(*) AS negative_usage_counts,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_feature_usage') }}
WHERE usage_count IS NOT NULL 
  AND usage_count < 0
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 8: BZ_FEATURE_USAGE - Future Date Validation
-- =====================================================
-- Test that usage_date is not in the future
SELECT 'bz_feature_usage_future_date' AS test_name,
       COUNT(*) AS future_dates,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_feature_usage') }}
WHERE usage_date IS NOT NULL 
  AND usage_date > CURRENT_DATE()
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 9: BZ_BILLING_EVENTS - Amount Validation
-- =====================================================
-- Test that negative amounts are only for specific event types
SELECT 'bz_billing_events_amount_validation' AS test_name,
       COUNT(*) AS invalid_negative_amounts,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_billing_events') }}
WHERE amount IS NOT NULL 
  AND amount < 0 
  AND event_type NOT IN ('REFUND', 'CREDIT', 'ADJUSTMENT')
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 10: BZ_LICENSES - Date Range Validation
-- =====================================================
-- Test that start_date is before end_date for licenses
SELECT 'bz_licenses_date_range_validation' AS test_name,
       COUNT(*) AS invalid_license_dates,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_licenses') }}
WHERE start_date IS NOT NULL 
  AND end_date IS NOT NULL 
  AND start_date > end_date
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 11: Cross-Table Referential Integrity
-- =====================================================
-- Test that meeting hosts exist in users table
SELECT 'referential_integrity_meeting_hosts' AS test_name,
       COUNT(*) AS orphaned_meetings,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_meetings') }} m
LEFT JOIN {{ ref('bz_users') }} u ON m.host_id = u.user_id
WHERE m.host_id IS NOT NULL 
  AND u.user_id IS NULL
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 12: Data Freshness Validation
-- =====================================================
-- Test that data is not older than expected threshold
SELECT 'data_freshness_validation' AS test_name,
       COUNT(*) AS stale_records,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM (
    SELECT load_timestamp FROM {{ ref('bz_users') }}
    UNION ALL
    SELECT load_timestamp FROM {{ ref('bz_meetings') }}
    UNION ALL
    SELECT load_timestamp FROM {{ ref('bz_participants') }}
    UNION ALL
    SELECT load_timestamp FROM {{ ref('bz_feature_usage') }}
    UNION ALL
    SELECT load_timestamp FROM {{ ref('bz_support_tickets') }}
    UNION ALL
    SELECT load_timestamp FROM {{ ref('bz_billing_events') }}
    UNION ALL
    SELECT load_timestamp FROM {{ ref('bz_licenses') }}
) all_records
WHERE load_timestamp < DATEADD('day', -30, CURRENT_TIMESTAMP())
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 13: Audit Trail Completeness
-- =====================================================
-- Test that audit records exist for all table operations
SELECT 'audit_trail_completeness' AS test_name,
       7 - COUNT(DISTINCT source_table) AS missing_audit_tables,
       0 AS expected_count,
       CASE 
           WHEN COUNT(DISTINCT source_table) = 7 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM {{ ref('bz_data_audit') }}
WHERE source_table IN (
    'BZ_USERS', 'BZ_MEETINGS', 'BZ_PARTICIPANTS', 
    'BZ_FEATURE_USAGE', 'BZ_SUPPORT_TICKETS', 
    'BZ_BILLING_EVENTS', 'BZ_LICENSES'
)
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 14: Metadata Completeness
-- =====================================================
-- Test that required metadata fields are populated
SELECT 'metadata_completeness_validation' AS test_name,
       COUNT(*) AS missing_metadata,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM (
    SELECT user_id, load_timestamp, update_timestamp, source_system FROM {{ ref('bz_users') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL OR source_system IS NULL
    UNION ALL
    SELECT meeting_id, load_timestamp, update_timestamp, source_system FROM {{ ref('bz_meetings') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL OR source_system IS NULL
    UNION ALL
    SELECT participant_id, load_timestamp, update_timestamp, source_system FROM {{ ref('bz_participants') }}
    WHERE load_timestamp IS NULL OR update_timestamp IS NULL OR source_system IS NULL
) metadata_check
HAVING test_result = 'FAIL'

UNION ALL

-- =====================================================
-- TEST 15: Edge Case - Empty String Validation
-- =====================================================
-- Test that critical fields don't contain empty strings
SELECT 'empty_string_validation' AS test_name,
       COUNT(*) AS empty_string_records,
       0 AS expected_count,
       CASE 
           WHEN COUNT(*) = 0 THEN 'PASS'
           ELSE 'FAIL'
       END AS test_result
FROM (
    SELECT user_id FROM {{ ref('bz_users') }} WHERE TRIM(user_id) = ''
    UNION ALL
    SELECT meeting_id FROM {{ ref('bz_meetings') }} WHERE TRIM(meeting_id) = ''
    UNION ALL
    SELECT participant_id FROM {{ ref('bz_participants') }} WHERE TRIM(participant_id) = ''
) empty_check
HAVING test_result = 'FAIL'

ORDER BY test_name;