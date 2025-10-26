_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver Layer Data Mapping for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Mapping for Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer in the Medallion architecture for the Zoom Platform Analytics System. The Silver Layer incorporates data cleansing, standardization, validation rules, and business logic transformations to ensure high-quality, analytics-ready data.

**Key Considerations:**
- Data quality validations based on business constraints
- Standardization of data formats and types
- Implementation of business rules for derived attributes
- Error handling and data lineage tracking
- Snowflake-compatible transformations

## 2. Data Mapping for the Silver Layer

### 2.1 Billing Events Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_BILLING_EVENTS | billing_event_id | Bronze | bz_billing_events | - | Not Null, Unique | Generate UUID using CONCAT(user_id, event_date, event_type) |
| Silver | Si_BILLING_EVENTS | user_id | Bronze | bz_billing_events | user_id | Not Null, Valid Format | Direct mapping with validation against Users table |
| Silver | Si_BILLING_EVENTS | event_type | Bronze | bz_billing_events | event_type | Not Null, Valid Values | Standardize to ['Payment', 'Refund', 'Subscription', 'Upgrade', 'Downgrade'] |
| Silver | Si_BILLING_EVENTS | amount | Bronze | bz_billing_events | amount | Not Null, Positive, Decimal(12,2) | Round to 2 decimal places, validate > 0 |
| Silver | Si_BILLING_EVENTS | event_date | Bronze | bz_billing_events | event_date | Not Null, Valid Date | Convert to DATE format, validate not future dated |
| Silver | Si_BILLING_EVENTS | currency_code | Bronze | bz_billing_events | - | Not Null, Valid Format | Default to 'USD', validate against ISO currency codes |
| Silver | Si_BILLING_EVENTS | payment_method | Bronze | bz_billing_events | - | Valid Values | Derive from event_type or default to 'Unknown' |
| Silver | Si_BILLING_EVENTS | transaction_status | Bronze | bz_billing_events | - | Valid Values | Default to 'Completed' for existing records |
| Silver | Si_BILLING_EVENTS | load_date | Bronze | bz_billing_events | - | Not Null | CURRENT_DATE() |
| Silver | Si_BILLING_EVENTS | update_date | Bronze | bz_billing_events | - | Not Null | CURRENT_DATE() |
| Silver | Si_BILLING_EVENTS | source_system | Bronze | bz_billing_events | source_system | Not Null | Direct mapping |
| Silver | Si_BILLING_EVENTS | load_timestamp | Bronze | bz_billing_events | load_timestamp | Not Null | Direct mapping |
| Silver | Si_BILLING_EVENTS | update_timestamp | Bronze | bz_billing_events | update_timestamp | Not Null | Direct mapping |
| Silver | Si_BILLING_EVENTS | data_quality_score | Bronze | bz_billing_events | - | Range 0.00-1.00 | Calculate based on completeness and validity checks |

### 2.2 Feature Usage Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_FEATURE_USAGE | feature_usage_id | Bronze | bz_feature_usage | - | Not Null, Unique | Generate UUID using CONCAT(meeting_id, feature_name, usage_date) |
| Silver | Si_FEATURE_USAGE | meeting_id | Bronze | bz_feature_usage | meeting_id | Not Null, Valid Format | Direct mapping with validation against Meetings table |
| Silver | Si_FEATURE_USAGE | feature_name | Bronze | bz_feature_usage | feature_name | Not Null, Standardized | Standardize feature names to consistent format |
| Silver | Si_FEATURE_USAGE | usage_count | Bronze | bz_feature_usage | usage_count | Not Null, Non-negative | Validate >= 0, default to 0 if null |
| Silver | Si_FEATURE_USAGE | usage_date | Bronze | bz_feature_usage | usage_date | Not Null, Valid Date | Convert to DATE format, validate within reasonable range |
| Silver | Si_FEATURE_USAGE | usage_duration_minutes | Bronze | bz_feature_usage | - | Non-negative | Calculate or default to 0 |
| Silver | Si_FEATURE_USAGE | feature_category | Bronze | bz_feature_usage | - | Valid Values | Categorize features into ['Audio', 'Video', 'Screen Share', 'Chat', 'Recording', 'Other'] |
| Silver | Si_FEATURE_USAGE | usage_pattern | Bronze | bz_feature_usage | - | Valid Values | Derive pattern based on usage_count ['Low', 'Medium', 'High'] |
| Silver | Si_FEATURE_USAGE | load_date | Bronze | bz_feature_usage | - | Not Null | CURRENT_DATE() |
| Silver | Si_FEATURE_USAGE | update_date | Bronze | bz_feature_usage | - | Not Null | CURRENT_DATE() |
| Silver | Si_FEATURE_USAGE | source_system | Bronze | bz_feature_usage | source_system | Not Null | Direct mapping |
| Silver | Si_FEATURE_USAGE | load_timestamp | Bronze | bz_feature_usage | load_timestamp | Not Null | Direct mapping |
| Silver | Si_FEATURE_USAGE | update_timestamp | Bronze | bz_feature_usage | update_timestamp | Not Null | Direct mapping |
| Silver | Si_FEATURE_USAGE | data_quality_score | Bronze | bz_feature_usage | - | Range 0.00-1.00 | Calculate based on completeness and validity checks |

### 2.3 Licenses Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_LICENSES | license_id | Bronze | bz_licenses | - | Not Null, Unique | Generate UUID using CONCAT(license_type, assigned_to_user_id, start_date) |
| Silver | Si_LICENSES | license_type | Bronze | bz_licenses | license_type | Not Null, Valid Values | Validate against ['Basic', 'Pro', 'Enterprise', 'Add-on'] |
| Silver | Si_LICENSES | assigned_to_user_id | Bronze | bz_licenses | assigned_to_user_id | Not Null, Valid Format | Direct mapping with validation against Users table |
| Silver | Si_LICENSES | start_date | Bronze | bz_licenses | start_date | Not Null, Valid Date | Convert to DATE format, validate logical sequence |
| Silver | Si_LICENSES | end_date | Bronze | bz_licenses | end_date | Valid Date, >= start_date | Convert to DATE format, validate end_date >= start_date |
| Silver | Si_LICENSES | license_status | Bronze | bz_licenses | - | Valid Values | Derive status based on dates ['Active', 'Expired', 'Suspended'] |
| Silver | Si_LICENSES | license_duration_days | Bronze | bz_licenses | - | Non-negative | Calculate DATEDIFF(day, start_date, end_date) |
| Silver | Si_LICENSES | renewal_flag | Bronze | bz_licenses | - | Boolean | Determine if license is renewal based on user history |
| Silver | Si_LICENSES | load_date | Bronze | bz_licenses | - | Not Null | CURRENT_DATE() |
| Silver | Si_LICENSES | update_date | Bronze | bz_licenses | - | Not Null | CURRENT_DATE() |
| Silver | Si_LICENSES | source_system | Bronze | bz_licenses | source_system | Not Null | Direct mapping |
| Silver | Si_LICENSES | load_timestamp | Bronze | bz_licenses | load_timestamp | Not Null | Direct mapping |
| Silver | Si_LICENSES | update_timestamp | Bronze | bz_licenses | update_timestamp | Not Null | Direct mapping |
| Silver | Si_LICENSES | data_quality_score | Bronze | bz_licenses | - | Range 0.00-1.00 | Calculate based on completeness and validity checks |

### 2.4 Meetings Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_MEETINGS | meeting_id | Bronze | bz_meetings | - | Not Null, Unique | Generate UUID using CONCAT(host_id, start_time, meeting_topic) |
| Silver | Si_MEETINGS | host_id | Bronze | bz_meetings | host_id | Not Null, Valid Format | Direct mapping with validation against Users table |
| Silver | Si_MEETINGS | meeting_topic | Bronze | bz_meetings | meeting_topic | Not Null, Max Length | Trim whitespace, validate length <= 255 characters |
| Silver | Si_MEETINGS | start_time | Bronze | bz_meetings | start_time | Not Null, Valid Timestamp | Convert to TIMESTAMP_NTZ(9) format |
| Silver | Si_MEETINGS | end_time | Bronze | bz_meetings | end_time | Valid Timestamp, >= start_time | Convert to TIMESTAMP_NTZ(9), validate end_time >= start_time |
| Silver | Si_MEETINGS | duration_minutes | Bronze | bz_meetings | duration_minutes | Non-negative, Max 1440 | Validate 0 <= duration <= 1440 (24 hours) |
| Silver | Si_MEETINGS | meeting_type | Bronze | bz_meetings | - | Valid Values | Derive type ['Scheduled', 'Instant', 'Recurring', 'Webinar'] |
| Silver | Si_MEETINGS | time_zone | Bronze | bz_meetings | - | Valid Format | Extract from start_time or default to 'UTC' |
| Silver | Si_MEETINGS | meeting_size_category | Bronze | bz_meetings | - | Valid Values | Derive from participant count ['Small', 'Medium', 'Large'] |
| Silver | Si_MEETINGS | business_hours_flag | Bronze | bz_meetings | - | Boolean | Determine if meeting occurred during business hours |
| Silver | Si_MEETINGS | load_date | Bronze | bz_meetings | - | Not Null | CURRENT_DATE() |
| Silver | Si_MEETINGS | update_date | Bronze | bz_meetings | - | Not Null | CURRENT_DATE() |
| Silver | Si_MEETINGS | source_system | Bronze | bz_meetings | source_system | Not Null | Direct mapping |
| Silver | Si_MEETINGS | load_timestamp | Bronze | bz_meetings | load_timestamp | Not Null | Direct mapping |
| Silver | Si_MEETINGS | update_timestamp | Bronze | bz_meetings | update_timestamp | Not Null | Direct mapping |
| Silver | Si_MEETINGS | data_quality_score | Bronze | bz_meetings | - | Range 0.00-1.00 | Calculate based on completeness and validity checks |

### 2.5 Participants Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_PARTICIPANTS | participant_id | Bronze | bz_participants | - | Not Null, Unique | Generate UUID using CONCAT(meeting_id, user_id, join_time) |
| Silver | Si_PARTICIPANTS | meeting_id | Bronze | bz_participants | meeting_id | Not Null, Valid Format | Direct mapping with validation against Meetings table |
| Silver | Si_PARTICIPANTS | user_id | Bronze | bz_participants | user_id | Not Null, Valid Format | Direct mapping with validation against Users table |
| Silver | Si_PARTICIPANTS | join_time | Bronze | bz_participants | join_time | Not Null, Valid Timestamp | Convert to TIMESTAMP_NTZ(9) format |
| Silver | Si_PARTICIPANTS | leave_time | Bronze | bz_participants | leave_time | Valid Timestamp, >= join_time | Convert to TIMESTAMP_NTZ(9), validate leave_time >= join_time |
| Silver | Si_PARTICIPANTS | attendance_duration_minutes | Bronze | bz_participants | - | Non-negative | Calculate DATEDIFF(minute, join_time, leave_time) |
| Silver | Si_PARTICIPANTS | attendance_percentage | Bronze | bz_participants | - | Range 0.00-100.00 | Calculate (attendance_duration / meeting_duration) * 100 |
| Silver | Si_PARTICIPANTS | late_join_flag | Bronze | bz_participants | - | Boolean | Determine if joined > 5 minutes after meeting start |
| Silver | Si_PARTICIPANTS | early_leave_flag | Bronze | bz_participants | - | Boolean | Determine if left > 5 minutes before meeting end |
| Silver | Si_PARTICIPANTS | engagement_score | Bronze | bz_participants | - | Range 0.00-1.00 | Calculate based on attendance percentage and participation |
| Silver | Si_PARTICIPANTS | load_date | Bronze | bz_participants | - | Not Null | CURRENT_DATE() |
| Silver | Si_PARTICIPANTS | update_date | Bronze | bz_participants | - | Not Null | CURRENT_DATE() |
| Silver | Si_PARTICIPANTS | source_system | Bronze | bz_participants | source_system | Not Null | Direct mapping |
| Silver | Si_PARTICIPANTS | load_timestamp | Bronze | bz_participants | load_timestamp | Not Null | Direct mapping |
| Silver | Si_PARTICIPANTS | update_timestamp | Bronze | bz_participants | update_timestamp | Not Null | Direct mapping |
| Silver | Si_PARTICIPANTS | data_quality_score | Bronze | bz_participants | - | Range 0.00-1.00 | Calculate based on completeness and validity checks |

### 2.6 Support Tickets Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_SUPPORT_TICKETS | support_ticket_id | Bronze | bz_support_tickets | - | Not Null, Unique | Generate UUID using CONCAT(user_id, ticket_type, open_date) |
| Silver | Si_SUPPORT_TICKETS | user_id | Bronze | bz_support_tickets | user_id | Not Null, Valid Format | Direct mapping with validation against Users table |
| Silver | Si_SUPPORT_TICKETS | ticket_type | Bronze | bz_support_tickets | ticket_type | Not Null, Valid Values | Validate against ['Technical', 'Billing', 'Feature Request', 'General'] |
| Silver | Si_SUPPORT_TICKETS | issue_description | Bronze | bz_support_tickets | - | Max Length | Default to 'No description provided', validate length <= 1000 |
| Silver | Si_SUPPORT_TICKETS | priority_level | Bronze | bz_support_tickets | - | Valid Values | Derive priority ['Low', 'Medium', 'High', 'Critical'] based on ticket_type |
| Silver | Si_SUPPORT_TICKETS | resolution_status | Bronze | bz_support_tickets | resolution_status | Not Null, Valid Values | Validate against ['Open', 'In Progress', 'Resolved', 'Closed'] |
| Silver | Si_SUPPORT_TICKETS | open_date | Bronze | bz_support_tickets | open_date | Not Null, Valid Date | Convert to DATE format, validate not future dated |
| Silver | Si_SUPPORT_TICKETS | close_date | Bronze | bz_support_tickets | - | Valid Date, >= open_date | Derive from resolution_status, validate close_date >= open_date |
| Silver | Si_SUPPORT_TICKETS | resolution_time_hours | Bronze | bz_support_tickets | - | Non-negative | Calculate business hours between open_date and close_date |
| Silver | Si_SUPPORT_TICKETS | first_response_time_hours | Bronze | bz_support_tickets | - | Non-negative | Default to 0 or calculate from available data |
| Silver | Si_SUPPORT_TICKETS | escalation_flag | Bronze | bz_support_tickets | - | Boolean | Determine based on priority_level and resolution_time |
| Silver | Si_SUPPORT_TICKETS | sla_breach_flag | Bronze | bz_support_tickets | - | Boolean | Determine based on priority_level and resolution_time_hours |
| Silver | Si_SUPPORT_TICKETS | load_date | Bronze | bz_support_tickets | - | Not Null | CURRENT_DATE() |
| Silver | Si_SUPPORT_TICKETS | update_date | Bronze | bz_support_tickets | - | Not Null | CURRENT_DATE() |
| Silver | Si_SUPPORT_TICKETS | source_system | Bronze | bz_support_tickets | source_system | Not Null | Direct mapping |
| Silver | Si_SUPPORT_TICKETS | load_timestamp | Bronze | bz_support_tickets | load_timestamp | Not Null | Direct mapping |
| Silver | Si_SUPPORT_TICKETS | update_timestamp | Bronze | bz_support_tickets | update_timestamp | Not Null | Direct mapping |
| Silver | Si_SUPPORT_TICKETS | data_quality_score | Bronze | bz_support_tickets | - | Range 0.00-1.00 | Calculate based on completeness and validity checks |

### 2.7 Users Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_USERS | user_id | Bronze | bz_users | - | Not Null, Unique | Generate UUID using CONCAT(email, user_name) |
| Silver | Si_USERS | user_name | Bronze | bz_users | user_name | Not Null, Max Length | Trim whitespace, validate length <= 100 characters |
| Silver | Si_USERS | email | Bronze | bz_users | email | Not Null, Valid Email Format | Validate email format using regex, convert to lowercase |
| Silver | Si_USERS | email_domain | Bronze | bz_users | email | Valid Format | Extract domain from email address |
| Silver | Si_USERS | company | Bronze | bz_users | company | Max Length | Trim whitespace, validate length <= 200 characters |
| Silver | Si_USERS | plan_type | Bronze | bz_users | plan_type | Not Null, Valid Values | Validate against ['Free', 'Basic', 'Pro', 'Enterprise'] |
| Silver | Si_USERS | registration_date | Bronze | bz_users | - | Valid Date | Derive from load_timestamp or default to earliest known date |
| Silver | Si_USERS | account_age_days | Bronze | bz_users | - | Non-negative | Calculate DATEDIFF(day, registration_date, CURRENT_DATE()) |
| Silver | Si_USERS | user_segment | Bronze | bz_users | - | Valid Values | Derive segment based on plan_type and usage patterns |
| Silver | Si_USERS | geographic_region | Bronze | bz_users | - | Valid Values | Derive from email_domain or default to 'Unknown' |
| Silver | Si_USERS | load_date | Bronze | bz_users | - | Not Null | CURRENT_DATE() |
| Silver | Si_USERS | update_date | Bronze | bz_users | - | Not Null | CURRENT_DATE() |
| Silver | Si_USERS | source_system | Bronze | bz_users | source_system | Not Null | Direct mapping |
| Silver | Si_USERS | load_timestamp | Bronze | bz_users | load_timestamp | Not Null | Direct mapping |
| Silver | Si_USERS | update_timestamp | Bronze | bz_users | update_timestamp | Not Null | Direct mapping |
| Silver | Si_USERS | data_quality_score | Bronze | bz_users | - | Range 0.00-1.00 | Calculate based on completeness and validity checks |

### 2.8 Webinars Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_WEBINARS | webinar_id | Bronze | bz_webinars | - | Not Null, Unique | Generate UUID using CONCAT(host_id, start_time, webinar_topic) |
| Silver | Si_WEBINARS | host_id | Bronze | bz_webinars | host_id | Not Null, Valid Format | Direct mapping with validation against Users table |
| Silver | Si_WEBINARS | webinar_topic | Bronze | bz_webinars | webinar_topic | Not Null, Max Length | Trim whitespace, validate length <= 255 characters |
| Silver | Si_WEBINARS | start_time | Bronze | bz_webinars | start_time | Not Null, Valid Timestamp | Convert to TIMESTAMP_NTZ(9) format |
| Silver | Si_WEBINARS | end_time | Bronze | bz_webinars | end_time | Valid Timestamp, >= start_time | Convert to TIMESTAMP_NTZ(9), validate end_time >= start_time |
| Silver | Si_WEBINARS | duration_minutes | Bronze | bz_webinars | - | Non-negative | Calculate DATEDIFF(minute, start_time, end_time) |
| Silver | Si_WEBINARS | registrants | Bronze | bz_webinars | registrants | Non-negative | Validate >= 0, default to 0 if null |
| Silver | Si_WEBINARS | actual_attendees | Bronze | bz_webinars | - | Non-negative, <= registrants | Derive from participant data or default to registrants |
| Silver | Si_WEBINARS | attendance_rate | Bronze | bz_webinars | - | Range 0.00-100.00 | Calculate (actual_attendees / registrants) * 100 |
| Silver | Si_WEBINARS | webinar_category | Bronze | bz_webinars | - | Valid Values | Derive category based on topic or default to 'General' |
| Silver | Si_WEBINARS | load_date | Bronze | bz_webinars | - | Not Null | CURRENT_DATE() |
| Silver | Si_WEBINARS | update_date | Bronze | bz_webinars | - | Not Null | CURRENT_DATE() |
| Silver | Si_WEBINARS | source_system | Bronze | bz_webinars | source_system | Not Null | Direct mapping |
| Silver | Si_WEBINARS | load_timestamp | Bronze | bz_webinars | load_timestamp | Not Null | Direct mapping |
| Silver | Si_WEBINARS | update_timestamp | Bronze | bz_webinars | update_timestamp | Not Null | Direct mapping |
| Silver | Si_WEBINARS | data_quality_score | Bronze | bz_webinars | - | Range 0.00-1.00 | Calculate based on completeness and validity checks |

### 2.9 Error Data Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_DATA_QUALITY_ERRORS | error_id | Bronze | - | - | Not Null, Unique | Generate UUID for each error record |
| Silver | Si_DATA_QUALITY_ERRORS | source_table | Bronze | All Tables | - | Not Null | Capture source table name where error occurred |
| Silver | Si_DATA_QUALITY_ERRORS | error_type | Bronze | - | - | Not Null, Valid Values | Categorize error types ['Validation', 'Format', 'Referential', 'Business Rule'] |
| Silver | Si_DATA_QUALITY_ERRORS | error_description | Bronze | - | - | Not Null, Max Length | Detailed description of the error |
| Silver | Si_DATA_QUALITY_ERRORS | affected_column | Bronze | - | - | Not Null | Column name where error was detected |
| Silver | Si_DATA_QUALITY_ERRORS | error_value | Bronze | - | - | Max Length | Actual value that caused the error |
| Silver | Si_DATA_QUALITY_ERRORS | error_severity | Bronze | - | - | Valid Values | Classify severity ['Low', 'Medium', 'High', 'Critical'] |
| Silver | Si_DATA_QUALITY_ERRORS | error_date | Bronze | - | - | Not Null | Date when error was detected |
| Silver | Si_DATA_QUALITY_ERRORS | error_timestamp | Bronze | - | - | Not Null | Timestamp when error was detected |
| Silver | Si_DATA_QUALITY_ERRORS | resolution_status | Bronze | - | - | Valid Values | Status ['Open', 'In Progress', 'Resolved'] |
| Silver | Si_DATA_QUALITY_ERRORS | resolution_action | Bronze | - | - | Max Length | Action taken to resolve the error |
| Silver | Si_DATA_QUALITY_ERRORS | load_timestamp | Bronze | - | - | Not Null | CURRENT_TIMESTAMP() |

### 2.10 Audit Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | Si_PIPELINE_AUDIT | execution_id | Bronze | bz_audit_log | - | Not Null, Unique | Generate UUID for each pipeline execution |
| Silver | Si_PIPELINE_AUDIT | pipeline_name | Bronze | - | - | Not Null | Name of the ETL pipeline being executed |
| Silver | Si_PIPELINE_AUDIT | start_time | Bronze | - | - | Not Null | Pipeline execution start timestamp |
| Silver | Si_PIPELINE_AUDIT | end_time | Bronze | - | - | >= start_time | Pipeline execution end timestamp |
| Silver | Si_PIPELINE_AUDIT | status | Bronze | bz_audit_log | status | Not Null, Valid Values | Execution status ['Success', 'Failed', 'Warning'] |
| Silver | Si_PIPELINE_AUDIT | error_message | Bronze | - | - | Max Length | Error details if pipeline failed |
| Silver | Si_PIPELINE_AUDIT | audit_id | Bronze | bz_audit_log | record_id | Not Null | Reference to Bronze audit record |
| Silver | Si_PIPELINE_AUDIT | execution_start_time | Bronze | - | - | Not Null | Detailed execution start time |
| Silver | Si_PIPELINE_AUDIT | execution_end_time | Bronze | - | - | >= execution_start_time | Detailed execution end time |
| Silver | Si_PIPELINE_AUDIT | execution_duration_seconds | Bronze | - | - | Non-negative | Calculate duration in seconds |
| Silver | Si_PIPELINE_AUDIT | source_table | Bronze | bz_audit_log | source_table | Not Null | Source table being processed |
| Silver | Si_PIPELINE_AUDIT | target_table | Bronze | - | - | Not Null | Target Silver table |
| Silver | Si_PIPELINE_AUDIT | records_processed | Bronze | - | - | Non-negative | Total records processed |
| Silver | Si_PIPELINE_AUDIT | records_success | Bronze | - | - | Non-negative, <= records_processed | Successfully processed records |
| Silver | Si_PIPELINE_AUDIT | records_failed | Bronze | - | - | Non-negative, <= records_processed | Failed records |
| Silver | Si_PIPELINE_AUDIT | records_rejected | Bronze | - | - | Non-negative, <= records_processed | Rejected records due to quality issues |
| Silver | Si_PIPELINE_AUDIT | execution_status | Bronze | bz_audit_log | status | Not Null, Valid Values | Overall execution status |
| Silver | Si_PIPELINE_AUDIT | processed_by | Bronze | bz_audit_log | processed_by | Not Null | System or user who executed the pipeline |
| Silver | Si_PIPELINE_AUDIT | load_timestamp | Bronze | bz_audit_log | load_timestamp | Not Null | Direct mapping |

## 3. Data Quality and Validation Rules

### 3.1 Primary Validation Rules

1. **Not Null Validations**: All primary keys and critical business fields must not be null
2. **Unique Constraints**: Generated IDs must be unique across the table
3. **Referential Integrity**: Foreign key relationships must be validated
4. **Data Type Validations**: All fields must conform to specified data types
5. **Range Validations**: Numeric fields must be within acceptable ranges
6. **Format Validations**: Email addresses, dates, and timestamps must follow correct formats
7. **Business Rule Validations**: Custom business logic validations as per requirements

### 3.2 Data Quality Score Calculation

The data_quality_score is calculated based on:
- **Completeness**: Percentage of non-null values in required fields
- **Validity**: Percentage of values that pass format and range validations
- **Consistency**: Percentage of values that maintain referential integrity
- **Accuracy**: Percentage of values that pass business rule validations

**Formula**: `(Completeness + Validity + Consistency + Accuracy) / 4`

### 3.3 Error Handling Mechanisms

1. **Data Quality Errors Table**: Capture all validation failures with detailed error information
2. **Rejection Handling**: Invalid records are logged but not loaded to Silver tables
3. **Alerting**: Critical data quality issues trigger immediate alerts
4. **Monitoring**: Continuous monitoring of data quality scores and error rates
5. **Remediation**: Automated and manual processes for error resolution

## 4. Business Rules Implementation

### 4.1 Derived Attributes

1. **Meeting Classification**: Categorize meetings based on duration and participant count
2. **User Segmentation**: Segment users based on plan type and usage patterns
3. **Engagement Scoring**: Calculate participant engagement based on attendance patterns
4. **License Utilization**: Track license usage and renewal patterns
5. **Support Metrics**: Calculate resolution times and SLA compliance

### 4.2 Standardization Rules

1. **Date/Time Standardization**: All timestamps converted to TIMESTAMP_NTZ(9) format
2. **String Standardization**: Trim whitespace, standardize case where appropriate
3. **Categorical Standardization**: Map source values to standardized categories
4. **Numeric Standardization**: Round to appropriate decimal places
5. **Boolean Standardization**: Convert various representations to TRUE/FALSE

## 5. Performance Optimization

### 5.1 Clustering Strategy

- **Time-based Clustering**: Tables clustered by date/timestamp fields for time-series queries
- **Entity-based Clustering**: Tables clustered by primary entity IDs for join optimization
- **Composite Clustering**: Multi-column clustering for complex query patterns

### 5.2 Indexing Recommendations

- Primary keys automatically indexed
- Foreign key columns indexed for join performance
- Frequently filtered columns indexed
- Composite indexes for multi-column filters

## 6. Data Lineage and Traceability

### 6.1 Source-to-Target Mapping

- Complete mapping from Bronze to Silver documented
- Transformation logic captured for each field
- Business rules applied documented
- Data quality checks applied documented

### 6.2 Audit Trail

- Pipeline execution history maintained
- Data processing statistics captured
- Error and exception handling logged
- Performance metrics tracked

## 7. Recommendations

### 7.1 Implementation Recommendations

1. **Incremental Processing**: Implement CDC (Change Data Capture) for efficient processing
2. **Parallel Processing**: Process independent tables in parallel for better performance
3. **Error Recovery**: Implement robust error recovery and retry mechanisms
4. **Monitoring**: Set up comprehensive monitoring and alerting for data quality
5. **Documentation**: Maintain detailed documentation of all transformations and business rules

### 7.2 Data Governance Recommendations

1. **Data Quality Standards**: Establish and enforce data quality standards
2. **Change Management**: Implement proper change management for schema evolution
3. **Access Control**: Implement role-based access control for Silver layer data
4. **Data Retention**: Define and implement data retention policies
5. **Compliance**: Ensure compliance with data privacy and security regulations

---

**Note**: This mapping document serves as the foundation for implementing the Silver Layer ETL processes in the Zoom Platform Analytics System. All transformations and validations are designed to be compatible with Snowflake SQL and follow best practices for data engineering in a Medallion architecture.