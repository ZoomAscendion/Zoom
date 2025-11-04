_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive Silver Layer Data Mapping for Zoom Platform Analytics System
## *Version*: 2 
## *Changes*: Made Silver Audit Log independent - removed dependency on Bronze audit records
## *Reason*: Silver audit table should be independent and not refer to Bronze layer data
## *Updated on*: 
_____________________________________________

# Silver Layer Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer for the Zoom Platform Analytics System following the Medallion architecture. The mapping incorporates necessary data cleansing, validations, and business rules at the attribute level to ensure data quality, consistency, and usability across the organization.

The Silver Layer serves as the cleansed and conformed layer, transforming raw Bronze data into standardized, validated, and enriched datasets ready for analytical consumption. All transformations are designed to be compatible with Snowflake SQL and follow established data quality standards.

**Version 2 Update**: The Silver audit table (SI_PIPELINE_AUDIT) has been made independent and no longer references Bronze audit records, ensuring proper separation of concerns between layers.

## 2. Data Mapping for the Silver Layer

### 2.1 SILVER.SI_USERS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_USERS | USER_ID | Bronze | BZ_USERS | USER_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_USERS | USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null, Length > 0 | TRIM and UPPER case standardization |
| Silver | SI_USERS | EMAIL | Bronze | BZ_USERS | EMAIL | Not null, Valid email format | LOWER case and email format validation |
| Silver | SI_USERS | COMPANY | Bronze | BZ_USERS | COMPANY | Length validation | TRIM and proper case formatting |
| Silver | SI_USERS | PLAN_TYPE | Bronze | BZ_USERS | PLAN_TYPE | Must be in (Free, Basic, Pro, Enterprise) | Standardize to enumerated values |
| Silver | SI_USERS | REGISTRATION_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null, Not future date | Extract date from load timestamp |
| Silver | SI_USERS | LAST_LOGIN_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Valid date, Not future date | Extract date from update timestamp |
| Silver | SI_USERS | ACCOUNT_STATUS | Bronze | BZ_USERS | PLAN_TYPE | Must be in (Active, Inactive, Suspended) | Derive from plan type and activity |
| Silver | SI_USERS | LOAD_TIMESTAMP | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_USERS | UPDATE_TIMESTAMP | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_USERS | SOURCE_SYSTEM | Bronze | BZ_USERS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_USERS | DATA_QUALITY_SCORE | Bronze | BZ_USERS | Multiple fields | Range 0.00-1.00 | Calculate based on completeness and validity |
| Silver | SI_USERS | LOAD_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_USERS | UPDATE_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.2 SILVER.SI_MEETINGS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_MEETINGS | MEETING_ID | Bronze | BZ_MEETINGS | MEETING_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_MEETINGS | HOST_ID | Bronze | BZ_MEETINGS | HOST_ID | Not null, Foreign key to SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_MEETINGS | MEETING_TOPIC | Bronze | BZ_MEETINGS | MEETING_TOPIC | Length validation | TRIM and standardize formatting |
| Silver | SI_MEETINGS | MEETING_TYPE | Bronze | BZ_MEETINGS | DURATION_MINUTES | Must be in (Scheduled, Instant, Webinar, Personal) | Derive from duration and other attributes |
| Silver | SI_MEETINGS | START_TIME | Bronze | BZ_MEETINGS | START_TIME | Not null, Valid timestamp | Direct mapping with timestamp validation |
| Silver | SI_MEETINGS | END_TIME | Bronze | BZ_MEETINGS | END_TIME | Not null, Must be >= START_TIME | Direct mapping with logical validation |
| Silver | SI_MEETINGS | DURATION_MINUTES | Bronze | BZ_MEETINGS | DURATION_MINUTES | Must be >= 1 and <= 1440 | Validate and recalculate if needed |
| Silver | SI_MEETINGS | HOST_NAME | Bronze | BZ_USERS | USER_NAME | Not null | Join with BZ_USERS on HOST_ID |
| Silver | SI_MEETINGS | MEETING_STATUS | Bronze | BZ_MEETINGS | END_TIME | Must be in (Scheduled, In Progress, Completed, Cancelled) | Derive from timestamps and current time |
| Silver | SI_MEETINGS | RECORDING_STATUS | Bronze | BZ_MEETINGS | MEETING_TOPIC | Must be in (Yes, No) | Derive from meeting attributes |
| Silver | SI_MEETINGS | PARTICIPANT_COUNT | Bronze | BZ_PARTICIPANTS | MEETING_ID | Must be >= 0 | Count participants per meeting |
| Silver | SI_MEETINGS | LOAD_TIMESTAMP | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_MEETINGS | UPDATE_TIMESTAMP | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_MEETINGS | SOURCE_SYSTEM | Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_MEETINGS | DATA_QUALITY_SCORE | Bronze | BZ_MEETINGS | Multiple fields | Range 0.00-1.00 | Calculate based on completeness and validity |
| Silver | SI_MEETINGS | LOAD_DATE | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_MEETINGS | UPDATE_DATE | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.3 SILVER.SI_PARTICIPANTS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PARTICIPANTS | PARTICIPANT_ID | Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_PARTICIPANTS | MEETING_ID | Bronze | BZ_PARTICIPANTS | MEETING_ID | Not null, Foreign key to SI_MEETINGS | Direct mapping with referential integrity check |
| Silver | SI_PARTICIPANTS | USER_ID | Bronze | BZ_PARTICIPANTS | USER_ID | Not null, Foreign key to SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_PARTICIPANTS | JOIN_TIME | Bronze | BZ_PARTICIPANTS | JOIN_TIME | Not null, Valid timestamp | Direct mapping with timestamp validation |
| Silver | SI_PARTICIPANTS | LEAVE_TIME | Bronze | BZ_PARTICIPANTS | LEAVE_TIME | Valid timestamp, Must be >= JOIN_TIME | Direct mapping with logical validation |
| Silver | SI_PARTICIPANTS | ATTENDANCE_DURATION | Bronze | BZ_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | Must be >= 0 | Calculate DATEDIFF in minutes |
| Silver | SI_PARTICIPANTS | PARTICIPANT_ROLE | Bronze | BZ_PARTICIPANTS | USER_ID | Must be in (Host, Co-host, Participant, Observer) | Derive from user and meeting relationship |
| Silver | SI_PARTICIPANTS | CONNECTION_QUALITY | Bronze | BZ_PARTICIPANTS | ATTENDANCE_DURATION | Must be in (Excellent, Good, Fair, Poor) | Derive from attendance patterns |
| Silver | SI_PARTICIPANTS | LOAD_TIMESTAMP | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_PARTICIPANTS | UPDATE_TIMESTAMP | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_PARTICIPANTS | SOURCE_SYSTEM | Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_PARTICIPANTS | DATA_QUALITY_SCORE | Bronze | BZ_PARTICIPANTS | Multiple fields | Range 0.00-1.00 | Calculate based on completeness and validity |
| Silver | SI_PARTICIPANTS | LOAD_DATE | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_PARTICIPANTS | UPDATE_DATE | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.4 SILVER.SI_FEATURE_USAGE Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_FEATURE_USAGE | USAGE_ID | Bronze | BZ_FEATURE_USAGE | USAGE_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_FEATURE_USAGE | MEETING_ID | Bronze | BZ_FEATURE_USAGE | MEETING_ID | Not null, Foreign key to SI_MEETINGS | Direct mapping with referential integrity check |
| Silver | SI_FEATURE_USAGE | FEATURE_NAME | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Not null, Length > 0 | TRIM and standardize feature names |
| Silver | SI_FEATURE_USAGE | USAGE_COUNT | Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | Must be >= 0 | Direct mapping with non-negative validation |
| Silver | SI_FEATURE_USAGE | USAGE_DURATION | Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | Must be >= 0 | Derive from usage count and meeting duration |
| Silver | SI_FEATURE_USAGE | FEATURE_CATEGORY | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Must be in (Audio, Video, Collaboration, Security) | Categorize based on feature name mapping |
| Silver | SI_FEATURE_USAGE | USAGE_DATE | Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Not null, Valid date | Direct mapping with date validation |
| Silver | SI_FEATURE_USAGE | LOAD_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_FEATURE_USAGE | UPDATE_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_FEATURE_USAGE | DATA_QUALITY_SCORE | Bronze | BZ_FEATURE_USAGE | Multiple fields | Range 0.00-1.00 | Calculate based on completeness and validity |
| Silver | SI_FEATURE_USAGE | LOAD_DATE | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_FEATURE_USAGE | UPDATE_DATE | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.5 SILVER.SI_SUPPORT_TICKETS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_SUPPORT_TICKETS | TICKET_ID | Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_SUPPORT_TICKETS | USER_ID | Bronze | BZ_SUPPORT_TICKETS | USER_ID | Not null, Foreign key to SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Must be in (Technical, Billing, Feature Request, Bug Report) | Standardize to enumerated values |
| Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Must be in (Low, Medium, High, Critical) | Derive priority from ticket type and urgency |
| Silver | SI_SUPPORT_TICKETS | OPEN_DATE | Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Not null, Not future date | Direct mapping with date validation |
| Silver | SI_SUPPORT_TICKETS | CLOSE_DATE | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Valid date, Must be >= OPEN_DATE | Derive from resolution status and timestamps |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Must be in (Open, In Progress, Resolved, Closed) | Standardize to enumerated values |
| Silver | SI_SUPPORT_TICKETS | ISSUE_DESCRIPTION | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Length validation | Derive standardized description from ticket type |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_NOTES | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Length validation | Generate notes based on resolution status |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_TIME_HOURS | Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Must be >= 0 | Calculate business hours between open and close |
| Silver | SI_SUPPORT_TICKETS | LOAD_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_SUPPORT_TICKETS | DATA_QUALITY_SCORE | Bronze | BZ_SUPPORT_TICKETS | Multiple fields | Range 0.00-1.00 | Calculate based on completeness and validity |
| Silver | SI_SUPPORT_TICKETS | LOAD_DATE | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_SUPPORT_TICKETS | UPDATE_DATE | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.6 SILVER.SI_BILLING_EVENTS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_BILLING_EVENTS | EVENT_ID | Bronze | BZ_BILLING_EVENTS | EVENT_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_BILLING_EVENTS | USER_ID | Bronze | BZ_BILLING_EVENTS | USER_ID | Not null, Foreign key to SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_BILLING_EVENTS | EVENT_TYPE | Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Must be in (Subscription, Upgrade, Downgrade, Refund) | Standardize to enumerated values |
| Silver | SI_BILLING_EVENTS | TRANSACTION_AMOUNT | Bronze | BZ_BILLING_EVENTS | AMOUNT | Must be > 0 | Direct mapping with positive amount validation |
| Silver | SI_BILLING_EVENTS | TRANSACTION_DATE | Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Not null, Not future date | Direct mapping with date validation |
| Silver | SI_BILLING_EVENTS | PAYMENT_METHOD | Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Must be in (Credit Card, Bank Transfer, PayPal) | Derive from event type and amount patterns |
| Silver | SI_BILLING_EVENTS | CURRENCY_CODE | Bronze | BZ_BILLING_EVENTS | AMOUNT | Must be valid 3-char ISO code | Default to 'USD' with validation |
| Silver | SI_BILLING_EVENTS | INVOICE_NUMBER | Bronze | BZ_BILLING_EVENTS | EVENT_ID | Not null, Unique | Generate from event ID with prefix |
| Silver | SI_BILLING_EVENTS | TRANSACTION_STATUS | Bronze | BZ_BILLING_EVENTS | AMOUNT | Must be in (Completed, Pending, Failed, Refunded) | Derive from amount and event type |
| Silver | SI_BILLING_EVENTS | LOAD_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_BILLING_EVENTS | UPDATE_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_BILLING_EVENTS | SOURCE_SYSTEM | Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_BILLING_EVENTS | DATA_QUALITY_SCORE | Bronze | BZ_BILLING_EVENTS | Multiple fields | Range 0.00-1.00 | Calculate based on completeness and validity |
| Silver | SI_BILLING_EVENTS | LOAD_DATE | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_BILLING_EVENTS | UPDATE_DATE | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.7 SILVER.SI_LICENSES Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_LICENSES | LICENSE_ID | Bronze | BZ_LICENSES | LICENSE_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_LICENSES | ASSIGNED_TO_USER_ID | Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Not null, Foreign key to SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_LICENSES | LICENSE_TYPE | Bronze | BZ_LICENSES | LICENSE_TYPE | Must be in (Basic, Pro, Enterprise, Add-on) | Standardize to enumerated values |
| Silver | SI_LICENSES | START_DATE | Bronze | BZ_LICENSES | START_DATE | Not null, Valid date | Direct mapping with date validation |
| Silver | SI_LICENSES | END_DATE | Bronze | BZ_LICENSES | END_DATE | Not null, Must be >= START_DATE | Direct mapping with logical validation |
| Silver | SI_LICENSES | LICENSE_STATUS | Bronze | BZ_LICENSES | END_DATE | Must be in (Active, Expired, Suspended) | Derive from current date vs end date |
| Silver | SI_LICENSES | ASSIGNED_USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null | Join with BZ_USERS on ASSIGNED_TO_USER_ID |
| Silver | SI_LICENSES | LICENSE_COST | Bronze | BZ_LICENSES | LICENSE_TYPE | Must be >= 0 | Derive cost from license type mapping |
| Silver | SI_LICENSES | RENEWAL_STATUS | Bronze | BZ_LICENSES | END_DATE | Must be in (Yes, No) | Derive from end date proximity |
| Silver | SI_LICENSES | UTILIZATION_PERCENTAGE | Bronze | BZ_LICENSES | LICENSE_TYPE | Range 0-100 | Calculate from usage patterns |
| Silver | SI_LICENSES | LOAD_TIMESTAMP | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_LICENSES | UPDATE_TIMESTAMP | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_LICENSES | SOURCE_SYSTEM | Bronze | BZ_LICENSES | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_LICENSES | DATA_QUALITY_SCORE | Bronze | BZ_LICENSES | Multiple fields | Range 0.00-1.00 | Calculate based on completeness and validity |
| Silver | SI_LICENSES | LOAD_DATE | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_LICENSES | UPDATE_DATE | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

### 2.8 SILVER.SI_WEBINARS Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_WEBINARS | WEBINAR_ID | Bronze | BZ_WEBINARS | WEBINAR_ID | Not null, Unique | Direct mapping with validation |
| Silver | SI_WEBINARS | HOST_ID | Bronze | BZ_WEBINARS | HOST_ID | Not null, Foreign key to SI_USERS | Direct mapping with referential integrity check |
| Silver | SI_WEBINARS | WEBINAR_TOPIC | Bronze | BZ_WEBINARS | WEBINAR_TOPIC | Length validation | TRIM and standardize formatting |
| Silver | SI_WEBINARS | START_TIME | Bronze | BZ_WEBINARS | START_TIME | Not null, Valid timestamp | Direct mapping with timestamp validation |
| Silver | SI_WEBINARS | END_TIME | Bronze | BZ_WEBINARS | END_TIME | Not null, Must be >= START_TIME | Direct mapping with logical validation |
| Silver | SI_WEBINARS | DURATION_MINUTES | Bronze | BZ_WEBINARS | START_TIME, END_TIME | Must be >= 1 | Calculate DATEDIFF in minutes |
| Silver | SI_WEBINARS | REGISTRANTS | Bronze | BZ_WEBINARS | REGISTRANTS | Must be >= 0 | Direct mapping with non-negative validation |
| Silver | SI_WEBINARS | ATTENDEES | Bronze | BZ_WEBINARS | REGISTRANTS | Must be >= 0 and <= REGISTRANTS | Derive from registrants with attendance rate |
| Silver | SI_WEBINARS | ATTENDANCE_RATE | Bronze | BZ_WEBINARS | REGISTRANTS | Range 0-100 | Calculate (ATTENDEES/REGISTRANTS) * 100 |
| Silver | SI_WEBINARS | LOAD_TIMESTAMP | Bronze | BZ_WEBINARS | LOAD_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_WEBINARS | UPDATE_TIMESTAMP | Bronze | BZ_WEBINARS | UPDATE_TIMESTAMP | Not null | Direct mapping |
| Silver | SI_WEBINARS | SOURCE_SYSTEM | Bronze | BZ_WEBINARS | SOURCE_SYSTEM | Not null | Direct mapping |
| Silver | SI_WEBINARS | DATA_QUALITY_SCORE | Bronze | BZ_WEBINARS | Multiple fields | Range 0.00-1.00 | Calculate based on completeness and validity |
| Silver | SI_WEBINARS | LOAD_DATE | Bronze | BZ_WEBINARS | LOAD_TIMESTAMP | Not null | Extract date from load timestamp |
| Silver | SI_WEBINARS | UPDATE_DATE | Bronze | BZ_WEBINARS | UPDATE_TIMESTAMP | Not null | Extract date from update timestamp |

## 3. Data Quality and Validation Rules Summary

### 3.1 Critical Validation Rules

1. **Referential Integrity Checks**
   - All foreign key relationships must be validated
   - HOST_ID in meetings must exist in users table
   - USER_ID in all dependent tables must exist in users table
   - MEETING_ID in participants and feature usage must exist in meetings table

2. **Data Type and Format Validations**
   - Email addresses must follow valid format patterns
   - Timestamps must be valid and logical (end >= start)
   - Numeric fields must be within acceptable ranges
   - Enumerated values must match predefined lists

3. **Business Logic Validations**
   - Meeting duration must be calculated correctly
   - Attendance duration cannot exceed meeting duration
   - Registration dates cannot be in the future
   - License end dates must be after start dates

### 3.2 Data Quality Score Calculation

The DATA_QUALITY_SCORE is calculated based on:
- **Completeness** (40%): Percentage of non-null required fields
- **Validity** (30%): Percentage of fields passing format validation
- **Consistency** (20%): Percentage of fields passing business rule validation
- **Accuracy** (10%): Percentage of fields passing referential integrity checks

### 3.3 Error Handling and Logging

1. **Error Classification**
   - **Critical**: Data that prevents processing (missing primary keys)
   - **High**: Data that affects business logic (invalid dates)
   - **Medium**: Data that affects reporting (missing optional fields)
   - **Low**: Data that affects presentation (formatting issues)

2. **Error Resolution Process**
   - Critical errors: Reject record and log to error table
   - High errors: Apply default values and log warning
   - Medium errors: Apply business rules and continue
   - Low errors: Apply formatting rules and continue


## 4. Implementation Recommendations

### 4.1 ETL Pipeline Design

1. **Incremental Processing**
   - Use UPDATE_TIMESTAMP for incremental loads
   - Implement change data capture for real-time updates
   - Maintain independent audit trail for all Silver transformations

2. **Performance Optimization**
   - Create appropriate clustering keys on large tables
   - Implement partitioning strategies for time-based data
   - Use Snowflake's automatic clustering for optimal performance

3. **Data Quality Monitoring**
   - Implement automated data quality checks
   - Set up alerts for critical data quality issues
   - Create dashboards for Silver layer data quality metrics

### 4.2 Snowflake-Specific Considerations

1. **Data Types**
   - Use STRING instead of VARCHAR for flexibility
   - Use TIMESTAMP_NTZ for timezone-neutral timestamps
   - Use NUMBER for all numeric fields with appropriate precision

2. **Performance Features**
   - Leverage Snowflake's automatic optimization
   - Use COPY INTO for bulk data loading
   - Implement proper clustering strategies

3. **Security and Governance**
   - Implement row-level security for sensitive data
   - Use Snowflake's data classification features
   - Maintain proper access controls and independent audit trails

This comprehensive data mapping provides the foundation for a robust Silver Layer implementation that ensures data quality, consistency, and usability across the Zoom Platform Analytics System, with independent audit capabilities that maintain proper architectural separation.
