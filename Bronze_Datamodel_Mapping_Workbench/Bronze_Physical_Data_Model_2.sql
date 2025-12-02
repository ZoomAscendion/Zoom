_____________________________________________
## *Author*: AAVA
## *Created on*: 2025-12-01  
## *Description*: Bronze layer physical data model DDL scripts for Zoom Platform Analytics System
## *Version*: 2
## *Changes*: Enhanced with Snowflake best practices, improved data types, added clustering recommendations, and optimized table structures
## *Reason*: Applied Snowflake optimization best practices for better performance and storage efficiency
## *Updated on*: 2025-12-02
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Zoom Platform Analytics System - Enhanced Version
-- Compatible with Snowflake SQL - Optimized for Performance
-- =====================================================

-- =====================================================
-- 1. BRONZE LAYER TABLE CREATION - ENHANCED
-- =====================================================

-- 1.1 Bronze Users Table - Enhanced with better data types
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    USER_ID STRING,
    USER_NAME VARCHAR(255),  -- Specified length for better performance
    EMAIL VARCHAR(320),      -- Standard email length limit
    COMPANY VARCHAR(255),
    PLAN_TYPE VARCHAR(50),   -- Constrained length for plan types
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.2 Bronze Meetings Table - Enhanced with optimized data types
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    MEETING_ID STRING,
    HOST_ID STRING,
    MEETING_TOPIC VARCHAR(500),  -- Reasonable limit for meeting topics
    START_TIME TIMESTAMP_NTZ,
    END_TIME TIMESTAMP_NTZ,      -- Changed from STRING to proper timestamp
    DURATION_MINUTES NUMBER(10,2), -- Changed from STRING to numeric for calculations
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.3 Bronze Participants Table - Enhanced structure
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    PARTICIPANT_ID STRING,
    MEETING_ID STRING,
    USER_ID STRING,
    JOIN_TIME TIMESTAMP_NTZ,     -- Changed from STRING to proper timestamp
    LEAVE_TIME TIMESTAMP_NTZ,
    PARTICIPATION_DURATION_MINUTES NUMBER(10,2), -- Added calculated field
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.4 Bronze Feature Usage Table - Enhanced with better constraints
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    USAGE_ID STRING,
    MEETING_ID STRING,
    USER_ID STRING,              -- Added user reference for better analytics
    FEATURE_NAME VARCHAR(200),   -- Specified length for feature names
    USAGE_COUNT NUMBER(38,0),
    USAGE_DATE DATE,
    USAGE_TIMESTAMP TIMESTAMP_NTZ, -- Added for more precise tracking
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.5 Bronze Support Tickets Table - Enhanced with status tracking
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    TICKET_ID STRING,
    USER_ID STRING,
    TICKET_TYPE VARCHAR(100),    -- Specified length for ticket types
    RESOLUTION_STATUS VARCHAR(50), -- Constrained status values
    PRIORITY_LEVEL VARCHAR(20),  -- Added priority tracking
    OPEN_DATE DATE,
    CLOSE_DATE DATE,             -- Added close date tracking
    RESOLUTION_TIME_HOURS NUMBER(10,2), -- Added resolution time metric
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.6 Bronze Billing Events Table - Enhanced with financial precision
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    EVENT_ID STRING,
    USER_ID STRING,
    EVENT_TYPE VARCHAR(100),     -- Specified length for event types
    AMOUNT NUMBER(15,2),         -- Changed from STRING to proper decimal for financial data
    CURRENCY_CODE VARCHAR(3),    -- Added currency tracking
    EVENT_DATE DATE,
    EVENT_TIMESTAMP TIMESTAMP_NTZ, -- Added for precise timing
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_SYSTEM VARCHAR(100)
);

-- 1.7 Bronze Licenses Table - Enhanced with license management
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    LICENSE_ID STRING,
    LICENSE_TYPE VARCHAR(100),   -- Specified length for license types
    ASSIGNED_TO_USER_ID STRING,
    START_DATE DATE,
    END_DATE DATE,               -- Changed from STRING to proper date
    LICENSE_STATUS VARCHAR(20),  -- Added status tracking (ACTIVE, EXPIRED, SUSPENDED)
    USAGE_COUNT NUMBER(38,0),    -- Added usage tracking
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATE_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_SYSTEM VARCHAR(100)
);

-- =====================================================
-- 2. ENHANCED AUDIT TABLE CREATION
-- =====================================================

-- 2.1 Bronze Audit Log Table - Enhanced with better tracking
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    RECORD_ID NUMBER AUTOINCREMENT,
    SOURCE_TABLE VARCHAR(100),
    OPERATION_TYPE VARCHAR(20),  -- Added operation type (INSERT, UPDATE, DELETE)
    RECORDS_AFFECTED NUMBER(38,0), -- Added count of affected records
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    PROCESSED_BY VARCHAR(100),
    PROCESSING_TIME NUMBER(10,3), -- Changed to decimal for sub-second precision
    STATUS VARCHAR(20),          -- SUCCESS, FAILED, IN_PROGRESS, PARTIAL
    ERROR_MESSAGE VARCHAR(1000), -- Added error message field
    BATCH_ID STRING              -- Added batch tracking
);

-- =====================================================
-- 3. CLUSTERING RECOMMENDATIONS FOR PERFORMANCE
-- =====================================================

-- Note: Clustering should be applied based on query patterns
-- Uncomment and modify based on actual usage patterns:

-- ALTER TABLE Bronze.bz_meetings CLUSTER BY (START_TIME, HOST_ID);
-- ALTER TABLE Bronze.bz_participants CLUSTER BY (MEETING_ID, JOIN_TIME);
-- ALTER TABLE Bronze.bz_feature_usage CLUSTER BY (USAGE_DATE, FEATURE_NAME);
-- ALTER TABLE Bronze.bz_support_tickets CLUSTER BY (OPEN_DATE, TICKET_TYPE);
-- ALTER TABLE Bronze.bz_billing_events CLUSTER BY (EVENT_DATE, USER_ID);
-- ALTER TABLE Bronze.bz_licenses CLUSTER BY (START_DATE, LICENSE_TYPE);
-- ALTER TABLE Bronze.bz_users CLUSTER BY (PLAN_TYPE, COMPANY);

-- =====================================================
-- 4. ENHANCED TABLE COMMENTS FOR DOCUMENTATION
-- =====================================================

-- 4.1 Add comprehensive table comments
COMMENT ON TABLE Bronze.bz_users IS 'Bronze layer table storing raw user profile information, subscription details, and account metadata with enhanced data type optimization';
COMMENT ON TABLE Bronze.bz_meetings IS 'Bronze layer table containing raw meeting information, timing data, and metadata with improved timestamp handling';
COMMENT ON TABLE Bronze.bz_participants IS 'Bronze layer table tracking raw meeting participant data, engagement metrics, and participation duration';
COMMENT ON TABLE Bronze.bz_feature_usage IS 'Bronze layer table recording raw feature usage data during meetings with enhanced user tracking';
COMMENT ON TABLE Bronze.bz_support_tickets IS 'Bronze layer table managing raw customer support ticket information with priority and resolution tracking';
COMMENT ON TABLE Bronze.bz_billing_events IS 'Bronze layer table tracking raw billing and financial transaction data with proper decimal precision and currency support';
COMMENT ON TABLE Bronze.bz_licenses IS 'Bronze layer table storing raw license assignment, management data, and usage tracking with enhanced status monitoring';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Enhanced audit table for comprehensive tracking of all Bronze layer data processing activities with error handling and batch tracking';

-- =====================================================
-- 5. ENHANCED COLUMN COMMENTS FOR DOCUMENTATION
-- =====================================================

-- 5.1 Users Table Column Comments - Enhanced
COMMENT ON COLUMN Bronze.bz_users.USER_ID IS 'Unique identifier for each user account - primary business key';
COMMENT ON COLUMN Bronze.bz_users.USER_NAME IS 'Display name of the user for identification purposes - optimized VARCHAR(255)';
COMMENT ON COLUMN Bronze.bz_users.EMAIL IS 'User email address for communication and authentication - RFC compliant length VARCHAR(320)';
COMMENT ON COLUMN Bronze.bz_users.COMPANY IS 'Company or organization associated with the user - optimized VARCHAR(255)';
COMMENT ON COLUMN Bronze.bz_users.PLAN_TYPE IS 'Subscription plan type (Basic, Pro, Business, Enterprise) - constrained VARCHAR(50)';
COMMENT ON COLUMN Bronze.bz_users.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer - auto-populated with default';
COMMENT ON COLUMN Bronze.bz_users.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated - auto-populated with default';
COMMENT ON COLUMN Bronze.bz_users.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking - optimized VARCHAR(100)';

-- 5.2 Meetings Table Column Comments - Enhanced
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_ID IS 'Unique identifier for each meeting - primary business key';
COMMENT ON COLUMN Bronze.bz_meetings.HOST_ID IS 'User ID of the meeting host - foreign key reference';
COMMENT ON COLUMN Bronze.bz_meetings.MEETING_TOPIC IS 'Topic or title of the meeting - optimized VARCHAR(500)';
COMMENT ON COLUMN Bronze.bz_meetings.START_TIME IS 'Timestamp when the meeting started - precise TIMESTAMP_NTZ';
COMMENT ON COLUMN Bronze.bz_meetings.END_TIME IS 'Timestamp when the meeting ended - enhanced from STRING to TIMESTAMP_NTZ';
COMMENT ON COLUMN Bronze.bz_meetings.DURATION_MINUTES IS 'Duration of the meeting in minutes - enhanced from STRING to NUMBER(10,2) for calculations';
COMMENT ON COLUMN Bronze.bz_meetings.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer - auto-populated';
COMMENT ON COLUMN Bronze.bz_meetings.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated - auto-populated';
COMMENT ON COLUMN Bronze.bz_meetings.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 5.3 Participants Table Column Comments - Enhanced
COMMENT ON COLUMN Bronze.bz_participants.PARTICIPANT_ID IS 'Unique identifier for each participant session';
COMMENT ON COLUMN Bronze.bz_participants.MEETING_ID IS 'Identifier linking to the meeting - foreign key reference';
COMMENT ON COLUMN Bronze.bz_participants.USER_ID IS 'Identifier of the user who participated - foreign key reference';
COMMENT ON COLUMN Bronze.bz_participants.JOIN_TIME IS 'Timestamp when participant joined the meeting - enhanced from STRING to TIMESTAMP_NTZ';
COMMENT ON COLUMN Bronze.bz_participants.LEAVE_TIME IS 'Timestamp when participant left the meeting';
COMMENT ON COLUMN Bronze.bz_participants.PARTICIPATION_DURATION_MINUTES IS 'Calculated participation duration in minutes - new field for analytics';
COMMENT ON COLUMN Bronze.bz_participants.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_participants.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_participants.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 5.4 Feature Usage Table Column Comments - Enhanced
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_ID IS 'Unique identifier for each feature usage record';
COMMENT ON COLUMN Bronze.bz_feature_usage.MEETING_ID IS 'Identifier linking to the meeting where feature was used';
COMMENT ON COLUMN Bronze.bz_feature_usage.USER_ID IS 'Identifier of the user who used the feature - new field for user-level analytics';
COMMENT ON COLUMN Bronze.bz_feature_usage.FEATURE_NAME IS 'Name of the feature that was used - optimized VARCHAR(200)';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_COUNT IS 'Number of times the feature was used in the session';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_DATE IS 'Date when the feature usage occurred';
COMMENT ON COLUMN Bronze.bz_feature_usage.USAGE_TIMESTAMP IS 'Precise timestamp of feature usage - new field for detailed tracking';
COMMENT ON COLUMN Bronze.bz_feature_usage.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_feature_usage.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_feature_usage.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 5.5 Support Tickets Table Column Comments - Enhanced
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_ID IS 'Unique identifier for each support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.USER_ID IS 'Identifier of the user who created the support ticket';
COMMENT ON COLUMN Bronze.bz_support_tickets.TICKET_TYPE IS 'Category of the support ticket - optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_support_tickets.RESOLUTION_STATUS IS 'Current status of the ticket resolution - constrained VARCHAR(50)';
COMMENT ON COLUMN Bronze.bz_support_tickets.PRIORITY_LEVEL IS 'Priority level of the ticket (LOW, MEDIUM, HIGH, CRITICAL) - new field';
COMMENT ON COLUMN Bronze.bz_support_tickets.OPEN_DATE IS 'Date when the support ticket was opened';
COMMENT ON COLUMN Bronze.bz_support_tickets.CLOSE_DATE IS 'Date when the support ticket was closed - new field for resolution tracking';
COMMENT ON COLUMN Bronze.bz_support_tickets.RESOLUTION_TIME_HOURS IS 'Time taken to resolve the ticket in hours - new calculated field';
COMMENT ON COLUMN Bronze.bz_support_tickets.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_support_tickets.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_support_tickets.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 5.6 Billing Events Table Column Comments - Enhanced
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_ID IS 'Unique identifier for each billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.USER_ID IS 'Identifier linking to the user who generated the billing event';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_TYPE IS 'Type of billing event (subscription, usage, refund, etc.) - optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_billing_events.AMOUNT IS 'Monetary amount associated with the billing event - enhanced from STRING to NUMBER(15,2) for financial precision';
COMMENT ON COLUMN Bronze.bz_billing_events.CURRENCY_CODE IS 'ISO 4217 currency code (USD, EUR, etc.) - new field for multi-currency support';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_DATE IS 'Date when the billing event occurred';
COMMENT ON COLUMN Bronze.bz_billing_events.EVENT_TIMESTAMP IS 'Precise timestamp of the billing event - new field for detailed tracking';
COMMENT ON COLUMN Bronze.bz_billing_events.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_billing_events.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_billing_events.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 5.7 Licenses Table Column Comments - Enhanced
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_ID IS 'Unique identifier for each license';
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_TYPE IS 'Type of license (Basic, Pro, Business, Enterprise) - optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_licenses.ASSIGNED_TO_USER_ID IS 'User ID to whom the license is assigned';
COMMENT ON COLUMN Bronze.bz_licenses.START_DATE IS 'Date when the license becomes active';
COMMENT ON COLUMN Bronze.bz_licenses.END_DATE IS 'Date when the license expires - enhanced from STRING to DATE';
COMMENT ON COLUMN Bronze.bz_licenses.LICENSE_STATUS IS 'Current status of the license (ACTIVE, EXPIRED, SUSPENDED, REVOKED) - new field';
COMMENT ON COLUMN Bronze.bz_licenses.USAGE_COUNT IS 'Number of times the license has been used - new field for usage tracking';
COMMENT ON COLUMN Bronze.bz_licenses.LOAD_TIMESTAMP IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_licenses.UPDATE_TIMESTAMP IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_licenses.SOURCE_SYSTEM IS 'Source system identifier for data lineage tracking';

-- 5.8 Enhanced Audit Log Table Column Comments
COMMENT ON COLUMN Bronze.bz_audit_log.RECORD_ID IS 'Auto-incrementing unique identifier for each audit record';
COMMENT ON COLUMN Bronze.bz_audit_log.SOURCE_TABLE IS 'Name of the source table being processed - optimized VARCHAR(100)';
COMMENT ON COLUMN Bronze.bz_audit_log.OPERATION_TYPE IS 'Type of operation performed (INSERT, UPDATE, DELETE, MERGE) - new field';
COMMENT ON COLUMN Bronze.bz_audit_log.RECORDS_AFFECTED IS 'Number of records affected by the operation - new field for impact tracking';
COMMENT ON COLUMN Bronze.bz_audit_log.LOAD_TIMESTAMP IS 'Timestamp when the data processing operation was initiated - auto-populated';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSED_BY IS 'Identifier of the system, user, or process that performed the operation';
COMMENT ON COLUMN Bronze.bz_audit_log.PROCESSING_TIME IS 'Duration of the processing operation in seconds - enhanced to NUMBER(10,3) for sub-second precision';
COMMENT ON COLUMN Bronze.bz_audit_log.STATUS IS 'Status of the processing operation (SUCCESS, FAILED, IN_PROGRESS, PARTIAL)';
COMMENT ON COLUMN Bronze.bz_audit_log.ERROR_MESSAGE IS 'Detailed error message if operation failed - new field for troubleshooting';
COMMENT ON COLUMN Bronze.bz_audit_log.BATCH_ID IS 'Identifier for grouping related operations in a batch - new field for batch tracking';

-- =====================================================
-- 6. PERFORMANCE OPTIMIZATION VIEWS (OPTIONAL)
-- =====================================================

-- 6.1 Create view for active users (example of Bronze layer optimization)
CREATE OR REPLACE VIEW Bronze.vw_active_users AS
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    SOURCE_SYSTEM
FROM Bronze.bz_users
WHERE PLAN_TYPE IS NOT NULL
  AND EMAIL IS NOT NULL;

-- 6.2 Create view for recent meetings (example of time-based filtering)
CREATE OR REPLACE VIEW Bronze.vw_recent_meetings AS
SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    SOURCE_SYSTEM
FROM Bronze.bz_meetings
WHERE START_TIME >= DATEADD(day, -30, CURRENT_TIMESTAMP());

-- =====================================================
-- 7. ENHANCED BRONZE LAYER DESIGN NOTES
-- =====================================================

/*
ENHANCED BRONZE LAYER DESIGN PRINCIPLES (VERSION 2):

1. OPTIMIZED DATA TYPES:
   - Replaced generic STRING with specific VARCHAR lengths for better performance
   - Changed financial amounts from STRING to NUMBER(15,2) for proper calculations
   - Enhanced timestamp fields from STRING to TIMESTAMP_NTZ for date arithmetic
   - Added precision to numeric fields for sub-second timing

2. ENHANCED METADATA TRACKING:
   - Added DEFAULT CURRENT_TIMESTAMP() for automatic timestamp population
   - Introduced additional tracking fields (currency, priority, status)
   - Enhanced audit table with operation type and error tracking
   - Added batch processing support

3. PERFORMANCE OPTIMIZATIONS:
   - Specified VARCHAR lengths based on expected data ranges
   - Added clustering recommendations for large tables
   - Included performance-oriented views for common queries
   - Optimized data types for Snowflake's columnar storage

4. ENHANCED ANALYTICS SUPPORT:
   - Added calculated fields (participation_duration, resolution_time)
   - Introduced user-level tracking in feature usage
   - Enhanced status tracking across all entities
   - Added currency support for multi-region deployments

5. IMPROVED DATA GOVERNANCE:
   - Enhanced audit trail with detailed error tracking
   - Added batch processing identification
   - Improved documentation with detailed column comments
   - Better support for data lineage and compliance

6. SNOWFLAKE BEST PRACTICES APPLIED:
   - Used appropriate Snowflake data types (TIMESTAMP_NTZ, NUMBER, VARCHAR)
   - Avoided unsupported features (constraints, foreign keys)
   - Optimized for micro-partitioned storage
   - Included clustering recommendations for query performance
   - Added default values for automatic metadata population

7. SCALABILITY ENHANCEMENTS:
   - Optimized data types for storage efficiency
   - Added performance views for common access patterns
   - Enhanced indexing strategy through clustering recommendations
   - Improved batch processing support

8. COMPLIANCE AND SECURITY READINESS:
   - Enhanced PII field identification through better data types
   - Improved audit capabilities for regulatory compliance
   - Better error tracking for data quality monitoring
   - Enhanced data lineage through improved metadata

UPGRADE NOTES FROM VERSION 1:
- Enhanced 15+ data type optimizations
- Added 8 new fields for better analytics
- Improved audit table with 4 additional tracking fields
- Added clustering recommendations for all tables
- Enhanced documentation with 50+ detailed column comments
- Added 2 performance optimization views
- Improved Snowflake compatibility and best practices adherence
*/

-- =====================================================
-- END OF ENHANCED BRONZE LAYER PHYSICAL DATA MODEL V2
-- =====================================================