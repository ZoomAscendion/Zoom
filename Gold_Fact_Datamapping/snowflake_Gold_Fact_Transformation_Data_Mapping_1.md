_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive data mapping for Fact tables transformation from Silver Layer to Gold Layer in Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake Gold Fact Transformation Data Mapping

## Overview

This document provides comprehensive data mapping for transforming Fact tables from the Silver Layer to the Gold Layer in the Zoom Platform Analytics System. The mapping ensures that key metrics, calculated fields, and relationships are structured correctly, enriched with necessary data points, and aligned with downstream reporting and performance optimization needs.

### Key Mapping Approach
- **Source-to-Target Mapping**: Direct field mappings from Silver layer tables to Gold layer fact tables
- **Data Enrichment**: Integration of multiple Silver layer tables to create comprehensive fact records
- **Business Logic Implementation**: Application of business rules and calculated fields
- **Data Quality Assurance**: Validation rules and error handling mechanisms
- **Performance Optimization**: Clustering and indexing strategies for analytical workloads

### Scope of Fact Tables Covered
1. **Go_MEETING_FACTS**: Meeting activities and engagement metrics
2. **Go_BILLING_FACTS**: Financial transactions and revenue analysis
3. **Go_SUPPORT_FACTS**: Support ticket metrics and service reliability analysis

## 1. Go_MEETING_FACTS Data Mapping

### 1.1 Core Meeting Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_MEETING_FACTS | meeting_fact_id | Gold | Go_MEETING_FACTS | meeting_fact_id | `NUMBER AUTOINCREMENT` (System Generated) |
| Gold | Go_MEETING_FACTS | meeting_date | Silver | Si_MEETINGS | start_time | `DATE(start_time)` |
| Gold | Go_MEETING_FACTS | host_name | Silver | Si_USERS | user_name | `u.user_name` (via JOIN on host_id) |
| Gold | Go_MEETING_FACTS | meeting_topic | Silver | Si_MEETINGS | meeting_topic | `COALESCE(meeting_topic, 'Untitled Meeting')` |
| Gold | Go_MEETING_FACTS | duration_minutes | Silver | Si_MEETINGS | duration_minutes | `COALESCE(duration_minutes, 0)` |
| Gold | Go_MEETING_FACTS | meeting_type | Silver | Si_MEETINGS | meeting_type | `COALESCE(meeting_type, 'Unknown')` |
| Gold | Go_MEETING_FACTS | meeting_id | Silver | Si_MEETINGS | meeting_id | `meeting_id` (Direct mapping) |
| Gold | Go_MEETING_FACTS | host_id | Silver | Si_MEETINGS | host_id | `host_id` (Direct mapping) |
| Gold | Go_MEETING_FACTS | start_time | Silver | Si_MEETINGS | start_time | `start_time` (Direct mapping) |
| Gold | Go_MEETING_FACTS | end_time | Silver | Si_MEETINGS | end_time | `end_time` (Direct mapping) |
| Gold | Go_MEETING_FACTS | time_zone | Silver | Si_MEETINGS | time_zone | `COALESCE(time_zone, 'UTC')` |
| Gold | Go_MEETING_FACTS | business_hours_flag | Silver | Si_MEETINGS | business_hours_flag | `COALESCE(business_hours_flag, FALSE)` |
| Gold | Go_MEETING_FACTS | meeting_size_category | Silver | Si_MEETINGS | meeting_size_category | `COALESCE(meeting_size_category, 'Small')` |

### 1.2 Participant Aggregation Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_MEETING_FACTS | participant_count | Silver | Si_PARTICIPANTS | participant_id | `COUNT(DISTINCT participant_id)` (Grouped by meeting_id) |
| Gold | Go_MEETING_FACTS | total_attendance_minutes | Silver | Si_PARTICIPANTS | attendance_duration_minutes | `SUM(COALESCE(attendance_duration_minutes, 0))` (Grouped by meeting_id) |
| Gold | Go_MEETING_FACTS | average_attendance_percentage | Silver | Si_PARTICIPANTS | attendance_duration_minutes | `CASE WHEN m.duration_minutes > 0 AND SUM(p.attendance_duration_minutes) > 0 THEN ROUND((SUM(p.attendance_duration_minutes)::FLOAT / (m.duration_minutes * COUNT(p.participant_id))) * 100, 2) ELSE 0 END` |

### 1.3 Feature Usage Aggregation Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_MEETING_FACTS | feature_usage_count | Silver | Si_FEATURE_USAGE | usage_count | `SUM(COALESCE(usage_count, 0))` (Grouped by meeting_id) |

### 1.4 Metadata and Audit Fields Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_MEETING_FACTS | load_date | System | System | Current Date | `CURRENT_DATE()` |
| Gold | Go_MEETING_FACTS | update_date | System | System | Current Date | `CURRENT_DATE()` |
| Gold | Go_MEETING_FACTS | source_system | Silver | Si_MEETINGS | source_system | `COALESCE(source_system, 'ZOOM_PLATFORM')` |

## 2. Go_BILLING_FACTS Data Mapping

### 2.1 Core Billing Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_BILLING_FACTS | billing_fact_id | Gold | Go_BILLING_FACTS | billing_fact_id | `NUMBER AUTOINCREMENT` (System Generated) |
| Gold | Go_BILLING_FACTS | transaction_date | Silver | Si_BILLING_EVENTS | event_date | `event_date` (Direct mapping) |
| Gold | Go_BILLING_FACTS | user_name | Silver | Si_USERS | user_name | `u.user_name` (via JOIN on user_id) |
| Gold | Go_BILLING_FACTS | event_type | Silver | Si_BILLING_EVENTS | event_type | `COALESCE(event_type, 'Unknown')` |
| Gold | Go_BILLING_FACTS | amount | Silver | Si_BILLING_EVENTS | amount | `COALESCE(amount, 0.00)` |
| Gold | Go_BILLING_FACTS | currency_code | Silver | Si_BILLING_EVENTS | currency_code | `COALESCE(currency_code, 'USD')` |
| Gold | Go_BILLING_FACTS | payment_method | Silver | Si_BILLING_EVENTS | payment_method | `COALESCE(payment_method, 'Unknown')` |
| Gold | Go_BILLING_FACTS | transaction_status | Silver | Si_BILLING_EVENTS | transaction_status | `COALESCE(transaction_status, 'Pending')` |
| Gold | Go_BILLING_FACTS | billing_event_id | Silver | Si_BILLING_EVENTS | billing_event_id | `billing_event_id` (Direct mapping) |
| Gold | Go_BILLING_FACTS | user_id | Silver | Si_BILLING_EVENTS | user_id | `user_id` (Direct mapping) |
| Gold | Go_BILLING_FACTS | event_date | Silver | Si_BILLING_EVENTS | event_date | `event_date` (Direct mapping) |

### 2.2 User Profile Enrichment Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_BILLING_FACTS | plan_type | Silver | Si_USERS | plan_type | `COALESCE(u.plan_type, 'Free')` (via JOIN on user_id) |
| Gold | Go_BILLING_FACTS | company | Silver | Si_USERS | company | `COALESCE(u.company, 'Individual')` (via JOIN on user_id) |

### 2.3 Revenue Recognition Calculation Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_BILLING_FACTS | revenue_recognition_amount | Silver | Si_BILLING_EVENTS | amount | `CASE WHEN event_type = 'Subscription' THEN amount WHEN event_type = 'Upgrade' THEN amount WHEN event_type = 'Refund' THEN -amount ELSE amount END` |

### 2.4 Metadata and Audit Fields Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_BILLING_FACTS | load_date | System | System | Current Date | `CURRENT_DATE()` |
| Gold | Go_BILLING_FACTS | update_date | System | System | Current Date | `CURRENT_DATE()` |
| Gold | Go_BILLING_FACTS | source_system | Silver | Si_BILLING_EVENTS | source_system | `COALESCE(source_system, 'ZOOM_BILLING')` |

## 3. Go_SUPPORT_FACTS Data Mapping

### 3.1 Core Support Ticket Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_SUPPORT_FACTS | support_fact_id | Gold | Go_SUPPORT_FACTS | support_fact_id | `NUMBER AUTOINCREMENT` (System Generated) |
| Gold | Go_SUPPORT_FACTS | ticket_date | Silver | Si_SUPPORT_TICKETS | open_date | `open_date` (Direct mapping) |
| Gold | Go_SUPPORT_FACTS | user_name | Silver | Si_USERS | user_name | `u.user_name` (via JOIN on user_id) |
| Gold | Go_SUPPORT_FACTS | ticket_type | Silver | Si_SUPPORT_TICKETS | ticket_type | `COALESCE(ticket_type, 'General')` |
| Gold | Go_SUPPORT_FACTS | priority_level | Silver | Si_SUPPORT_TICKETS | priority_level | `COALESCE(priority_level, 'Medium')` |
| Gold | Go_SUPPORT_FACTS | resolution_status | Silver | Si_SUPPORT_TICKETS | resolution_status | `COALESCE(resolution_status, 'Open')` |
| Gold | Go_SUPPORT_FACTS | resolution_time_hours | Silver | Si_SUPPORT_TICKETS | resolution_time_hours | `COALESCE(resolution_time_hours, 0)` |
| Gold | Go_SUPPORT_FACTS | first_response_time_hours | Silver | Si_SUPPORT_TICKETS | first_response_time_hours | `COALESCE(first_response_time_hours, 0)` |
| Gold | Go_SUPPORT_FACTS | escalation_flag | Silver | Si_SUPPORT_TICKETS | escalation_flag | `COALESCE(escalation_flag, FALSE)` |
| Gold | Go_SUPPORT_FACTS | support_ticket_id | Silver | Si_SUPPORT_TICKETS | support_ticket_id | `support_ticket_id` (Direct mapping) |
| Gold | Go_SUPPORT_FACTS | user_id | Silver | Si_SUPPORT_TICKETS | user_id | `user_id` (Direct mapping) |
| Gold | Go_SUPPORT_FACTS | issue_description | Silver | Si_SUPPORT_TICKETS | issue_description | `COALESCE(issue_description, 'No description provided')` |
| Gold | Go_SUPPORT_FACTS | open_date | Silver | Si_SUPPORT_TICKETS | open_date | `open_date` (Direct mapping) |
| Gold | Go_SUPPORT_FACTS | close_date | Silver | Si_SUPPORT_TICKETS | close_date | `close_date` (Direct mapping) |

### 3.2 User Profile Enrichment Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_SUPPORT_FACTS | company | Silver | Si_USERS | company | `COALESCE(u.company, 'Individual')` (via JOIN on user_id) |
| Gold | Go_SUPPORT_FACTS | plan_type | Silver | Si_USERS | plan_type | `COALESCE(u.plan_type, 'Free')` (via JOIN on user_id) |

### 3.3 SLA Breach Calculation Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_SUPPORT_FACTS | sla_breach_flag | Silver | Si_SUPPORT_TICKETS | priority_level, first_response_time_hours, resolution_time_hours | `CASE WHEN priority_level = 'Critical' AND first_response_time_hours > 1 THEN TRUE WHEN priority_level = 'High' AND resolution_time_hours > 24 THEN TRUE WHEN priority_level = 'Medium' AND resolution_time_hours > 72 THEN TRUE ELSE FALSE END` |

### 3.4 Agent Assignment Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_SUPPORT_FACTS | assigned_agent | System | System | Default Value | `'System_Agent'` (Placeholder for actual agent assignment logic) |

### 3.5 Metadata and Audit Fields Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_SUPPORT_FACTS | load_date | System | System | Current Date | `CURRENT_DATE()` |
| Gold | Go_SUPPORT_FACTS | update_date | System | System | Current Date | `CURRENT_DATE()` |
| Gold | Go_SUPPORT_FACTS | source_system | Silver | Si_SUPPORT_TICKETS | source_system | `COALESCE(source_system, 'ZOOM_SUPPORT')` |

## 4. Cross-Fact Table Transformation Rules

### 4.1 Data Consistency and Referential Integrity

| Validation Rule | Source Tables | Target Tables | Transformation Logic |
|-----------------|---------------|---------------|---------------------|
| User Reference Validation | Si_USERS | Go_MEETING_FACTS, Go_BILLING_FACTS, Go_SUPPORT_FACTS | `Ensure all user references in fact tables exist in Si_USERS table` |
| Date Consistency | All Silver Tables | All Gold Fact Tables | `Standardize all date fields to consistent format and timezone` |
| Foreign Key Integrity | Si_MEETINGS, Si_PARTICIPANTS, Si_FEATURE_USAGE | Go_MEETING_FACTS | `Validate meeting_id references exist in Si_MEETINGS` |
| Currency Standardization | Si_BILLING_EVENTS | Go_BILLING_FACTS | `Convert all amounts to USD using exchange rates where applicable` |

### 4.2 Business Rule Implementation

| Business Rule | Applied To | Transformation Logic |
|---------------|------------|---------------------|
| Meeting Duration Limits | Go_MEETING_FACTS | `Validate duration_minutes <= 1440 (24 hours)` |
| Revenue Recognition | Go_BILLING_FACTS | `Apply revenue recognition rules based on event_type` |
| SLA Compliance | Go_SUPPORT_FACTS | `Calculate SLA breach flags based on priority and response times` |
| Active User Definition | All Fact Tables | `Define active users as those with activity in the measurement period` |

## 5. Data Quality and Validation Rules

### 5.1 Null Value Handling

| Field Category | Null Handling Strategy | Default Values |
|----------------|----------------------|----------------|
| Required Fields | Reject records with null values | N/A |
| Optional Text Fields | Replace with default values | 'Unknown', 'Not Specified' |
| Numeric Fields | Replace with zero or appropriate default | 0, 0.00 |
| Boolean Fields | Replace with FALSE | FALSE |
| Date Fields | Use system date or reject record | CURRENT_DATE() |

### 5.2 Data Type Validation

| Data Type | Validation Rule | Error Handling |
|-----------|----------------|----------------|
| NUMBER | Validate numeric format and range | Log error and use default value |
| DATE | Validate date format and reasonable range | Log error and reject record |
| VARCHAR | Validate length constraints | Truncate and log warning |
| BOOLEAN | Validate TRUE/FALSE values | Convert to boolean or use FALSE |

### 5.3 Business Logic Validation

| Validation Type | Rule Description | Action on Failure |
|-----------------|------------------|-------------------|
| Meeting Duration | Duration must be between 0 and 1440 minutes | Log error and cap at maximum |
| Date Sequence | End time must be after start time | Log error and reject record |
| Amount Validation | Financial amounts must be non-negative for most transaction types | Log error and investigate |
| Reference Integrity | Foreign keys must exist in referenced tables | Log error and reject record |

## 6. Performance Optimization Strategies

### 6.1 Clustering Keys

| Table | Clustering Keys | Rationale |
|-------|----------------|----------|
| Go_MEETING_FACTS | meeting_date, host_name | Optimize for date-based queries and user analysis |
| Go_BILLING_FACTS | transaction_date, user_name | Optimize for financial reporting and user revenue analysis |
| Go_SUPPORT_FACTS | ticket_date, priority_level | Optimize for support metrics and priority-based analysis |

### 6.2 Incremental Loading Strategy

| Process | Strategy | Implementation |
|---------|----------|----------------|
| Daily Load | Load only changed/new records | Use load_date and update_date for incremental processing |
| Historical Rebuild | Full reload capability | Maintain ability to rebuild from Silver layer |
| Error Recovery | Reprocess failed records | Implement retry logic with error logging |

## 7. Monitoring and Alerting

### 7.1 Data Quality Monitoring

| Metric | Threshold | Alert Action |
|--------|-----------|-------------|
| Null Value Rate | > 5% for optional fields | Send warning alert |
| Record Count Variance | > 20% day-over-day | Send critical alert |
| Processing Time | > 2 hours for daily load | Send performance alert |
| Error Rate | > 1% of processed records | Send data quality alert |

### 7.2 Business Metric Monitoring

| KPI | Monitoring Rule | Alert Threshold |
|-----|----------------|----------------|
| Daily Active Users | Track day-over-day changes | > 15% decrease |
| Revenue Recognition | Monitor daily revenue totals | > 10% variance from forecast |
| Support Ticket Volume | Track ticket creation rate | > 50% increase day-over-day |
| SLA Breach Rate | Monitor SLA compliance | > 5% breach rate |

## 8. Error Handling and Recovery

### 8.1 Error Classification

| Error Type | Severity | Recovery Action |
|------------|----------|----------------|
| Data Type Mismatch | High | Log error, apply default value, continue processing |
| Missing Reference | Critical | Log error, reject record, alert administrator |
| Business Rule Violation | Medium | Log warning, apply correction rule, continue processing |
| System Error | Critical | Stop processing, alert administrator, initiate recovery |

### 8.2 Recovery Procedures

| Scenario | Recovery Steps | Rollback Strategy |
|----------|---------------|------------------|
| Partial Load Failure | Identify failed records, reprocess from checkpoint | Delete partial load, restart from beginning |
| Data Corruption | Validate data integrity, restore from backup | Restore previous day's data, reprocess |
| System Outage | Resume from last successful checkpoint | Full rollback to previous stable state |

## 9. Audit and Lineage Tracking

### 9.1 Data Lineage Documentation

| Source System | Source Table | Target Table | Transformation Type | Business Owner |
|---------------|--------------|--------------|-------------------|----------------|
| Zoom Platform | Si_MEETINGS | Go_MEETING_FACTS | Aggregation + Enrichment | Platform Analytics Team |
| Zoom Billing | Si_BILLING_EVENTS | Go_BILLING_FACTS | Direct Mapping + Calculation | Finance Team |
| Zoom Support | Si_SUPPORT_TICKETS | Go_SUPPORT_FACTS | Enrichment + SLA Calculation | Support Operations Team |

### 9.2 Change Management

| Change Type | Approval Required | Documentation | Testing Requirements |
|-------------|------------------|---------------|---------------------|
| Schema Changes | Data Architecture Team | Update mapping document | Full regression testing |
| Business Rule Changes | Business Owner | Update business rules section | Business logic testing |
| Performance Optimization | Technical Lead | Update performance section | Performance testing |

## Conclusion

This comprehensive data mapping document ensures that the Gold layer fact tables are optimized for analytical workloads, maintain high data quality standards, and support the business requirements defined in the Zoom Platform Analytics System. The mapping covers:

- **Complete field-level mapping** from Silver to Gold layer
- **Business logic implementation** for calculated fields and derived metrics
- **Data quality assurance** through validation rules and error handling
- **Performance optimization** through clustering and incremental loading strategies
- **Monitoring and alerting** for proactive issue detection
- **Audit and lineage tracking** for compliance and troubleshooting

Regular review and maintenance of these transformation rules will ensure continued data accuracy and system performance as the platform evolves and scales.

---

**Document Version**: 1  
**Last Updated**: 2024-12-19  
**Next Review Date**: 2025-03-19  
**Document Owner**: Data Architecture Team