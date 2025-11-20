_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive Bronze layer data mapping for Zoom Platform Analytics System with enhanced metadata and validation rules
## *Version*: 2 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping for Zoom Platform Analytics System

## Overview
This document defines the comprehensive data mapping between the source RAW layer and the Bronze layer in the Medallion architecture for the Zoom Platform Analytics System. The Bronze layer preserves the original structure of raw data with minimal transformation, ensuring complete data lineage, audit capabilities, and foundation for downstream analytics supporting platform usage, service reliability, and revenue reporting.

## Data Mapping Tables

### 1. USERS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_USERS | USER_ID | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | BRZ_USERS | USER_NAME | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | BRZ_USERS | EMAIL | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | BRZ_USERS | COMPANY | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | BRZ_USERS | PLAN_TYPE | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | BRZ_USERS | LOAD_TIMESTAMP | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_USERS | UPDATE_TIMESTAMP | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_USERS | SOURCE_SYSTEM | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |

### 2. MEETINGS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_MEETINGS | MEETING_ID | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | HOST_ID | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | MEETING_TOPIC | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | START_TIME | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | END_TIME | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | DURATION_MINUTES | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | LOAD_TIMESTAMP | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | UPDATE_TIMESTAMP | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_MEETINGS | SOURCE_SYSTEM | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

### 3. PARTICIPANTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_PARTICIPANTS | PARTICIPANT_ID | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | MEETING_ID | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | USER_ID | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | JOIN_TIME | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | LEAVE_TIME | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | LOAD_TIMESTAMP | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | UPDATE_TIMESTAMP | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_PARTICIPANTS | SOURCE_SYSTEM | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

### 4. FEATURE_USAGE Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_FEATURE_USAGE | USAGE_ID | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | MEETING_ID | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | FEATURE_NAME | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | USAGE_COUNT | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | USAGE_DATE | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | LOAD_TIMESTAMP | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_FEATURE_USAGE | SOURCE_SYSTEM | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

### 5. SUPPORT_TICKETS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_SUPPORT_TICKETS | TICKET_ID | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | USER_ID | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | TICKET_TYPE | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | OPEN_DATE | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

### 6. BILLING_EVENTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_BILLING_EVENTS | EVENT_ID | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | USER_ID | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | EVENT_TYPE | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | AMOUNT | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | EVENT_DATE | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | LOAD_TIMESTAMP | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_BILLING_EVENTS | SOURCE_SYSTEM | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

### 7. LICENSES Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BRZ_LICENSES | LICENSE_ID | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | BRZ_LICENSES | LICENSE_TYPE | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | BRZ_LICENSES | ASSIGNED_TO_USER_ID | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | BRZ_LICENSES | START_DATE | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | BRZ_LICENSES | END_DATE | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | BRZ_LICENSES | LOAD_TIMESTAMP | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_LICENSES | UPDATE_TIMESTAMP | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BRZ_LICENSES | SOURCE_SYSTEM | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

## Data Ingestion Details

### Snowflake Data Type Compatibility
All data types from the source RAW layer are preserved in the Bronze layer with Snowflake optimization:

| Source Data Type | Bronze Data Type | Purpose | Constraints |
|------------------|------------------|---------|-------------|
| VARCHAR(16777216) | VARCHAR(16777216) | Text fields, IDs, names | Preserves original length |
| NUMBER(38,0) | NUMBER(38,0) | Integer values, counts | Maintains precision |
| DATE | DATE | Date fields | Standard date format |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ(9) | Timestamp fields | Nanosecond precision |

### Enhanced Metadata Management

#### Standard Metadata Fields
- **LOAD_TIMESTAMP**: Tracks when each record was initially loaded into Bronze layer
- **UPDATE_TIMESTAMP**: Tracks the last modification time for each record
- **SOURCE_SYSTEM**: Identifies the originating system for complete data lineage

#### Data Quality Metadata (Future Enhancement)
- **DATA_QUALITY_SCORE**: Numeric score indicating data completeness and validity
- **VALIDATION_STATUS**: Status of data validation checks (PASSED/FAILED/WARNING)
- **ERROR_DETAILS**: JSON field containing validation error details

### Comprehensive Initial Data Validation Rules

#### 1. Primary Key Validation
- **Rule**: Ensure all primary key fields are not null and unique within each table
- **Tables**: All tables (USER_ID, MEETING_ID, PARTICIPANT_ID, etc.)
- **Action**: Reject records with null or duplicate primary keys

#### 2. Foreign Key Validation
- **Rule**: Validate referential integrity between related tables
- **Relationships**:
  - MEETINGS.HOST_ID → USERS.USER_ID
  - PARTICIPANTS.MEETING_ID → MEETINGS.MEETING_ID
  - PARTICIPANTS.USER_ID → USERS.USER_ID
  - FEATURE_USAGE.MEETING_ID → MEETINGS.MEETING_ID
  - SUPPORT_TICKETS.USER_ID → USERS.USER_ID
  - BILLING_EVENTS.USER_ID → USERS.USER_ID
  - LICENSES.ASSIGNED_TO_USER_ID → USERS.USER_ID
- **Action**: Flag orphaned records for investigation

#### 3. Data Type and Format Validation
- **Rule**: Ensure all fields conform to their defined data types and formats
- **Validations**:
  - Email format validation for USERS.EMAIL
  - Date range validation for all date fields
  - Numeric validation for USAGE_COUNT and AMOUNT fields
  - Timestamp sequence validation (START_TIME < END_TIME)

#### 4. Business Logic Validation
- **Rule**: Apply minimal business logic validation without transformation
- **Validations**:
  - DURATION_MINUTES should be positive
  - JOIN_TIME should be <= LEAVE_TIME
  - START_DATE should be <= END_DATE for licenses
  - AMOUNT should be numeric for billing events

#### 5. Completeness Validation
- **Rule**: Check for required field completeness
- **Required Fields**: All NOT NULL constraints from source schema
- **Action**: Flag incomplete records with severity levels

### Data Ingestion Process Flow

#### Stage 1: Extract and Load
1. **Extract**: Pull data from source systems into RAW layer staging area
2. **Initial Load**: Transfer data from RAW to Bronze layer with 1-to-1 field mapping
3. **Batch Processing**: Process data in configurable batch sizes for performance

#### Stage 2: Validation and Quality Checks
1. **Schema Validation**: Verify data structure matches expected Bronze schema
2. **Data Quality Checks**: Apply all validation rules defined above
3. **Error Handling**: Route invalid records to quarantine tables for investigation
4. **Quality Scoring**: Assign data quality scores based on validation results

#### Stage 3: Audit and Monitoring
1. **Audit Logging**: Log all ingestion activities with detailed metadata
2. **Performance Monitoring**: Track ingestion performance metrics
3. **Data Lineage**: Maintain complete lineage from source to Bronze layer
4. **Alerting**: Generate alerts for data quality issues or ingestion failures

### Error Handling and Data Quality Management

#### Quarantine Strategy
- **Quarantine Tables**: Create corresponding quarantine tables for each Bronze table
- **Error Classification**: Categorize errors by severity (CRITICAL, WARNING, INFO)
- **Retry Logic**: Implement retry mechanisms for transient failures
- **Manual Review**: Provide interface for manual review of quarantined records

#### Data Quality Metrics
- **Completeness**: Percentage of non-null values for required fields
- **Validity**: Percentage of records passing validation rules
- **Consistency**: Percentage of records with consistent cross-field relationships
- **Timeliness**: Measure of data freshness and ingestion latency

## Snowflake Implementation Specifications

### Database and Schema Structure
- **Database**: DB_POC_ZOOM
- **Schema**: BRONZE
- **Naming Convention**: BRZ_ prefix for all Bronze layer tables

### Performance Optimization
- **Clustering Keys**: Apply clustering on frequently queried fields:
  - BRZ_USERS: USER_ID, PLAN_TYPE
  - BRZ_MEETINGS: MEETING_ID, HOST_ID, START_TIME
  - BRZ_PARTICIPANTS: MEETING_ID, USER_ID
  - BRZ_FEATURE_USAGE: MEETING_ID, USAGE_DATE
  - BRZ_SUPPORT_TICKETS: USER_ID, OPEN_DATE
  - BRZ_BILLING_EVENTS: USER_ID, EVENT_DATE
  - BRZ_LICENSES: ASSIGNED_TO_USER_ID, START_DATE

### Data Governance Features
- **Time Travel**: Enable 7-day time travel for data recovery
- **Secure Views**: Create secure views for controlled data access
- **Row-Level Security**: Implement RLS for multi-tenant data isolation
- **Data Classification**: Apply data classification tags for sensitive fields

### Change Data Capture
- **Streams**: Configure Snowflake streams on Bronze tables for CDC to Silver layer
- **Tasks**: Implement automated tasks for incremental data processing
- **Monitoring**: Set up stream monitoring and alerting

## Supporting Analytics Use Cases

### Platform Usage & Adoption Analytics
- **Daily/Weekly/Monthly Active Users**: Supported by BRZ_USERS and BRZ_MEETINGS
- **Meeting Analytics**: Enabled by BRZ_MEETINGS and BRZ_PARTICIPANTS
- **Feature Adoption**: Tracked through BRZ_FEATURE_USAGE

### Service Reliability & Support Analytics
- **Support Ticket Analysis**: Enabled by BRZ_SUPPORT_TICKETS
- **User Experience Metrics**: Cross-referenced with BRZ_USERS and BRZ_MEETINGS

### Revenue & License Management Analytics
- **Revenue Tracking**: Supported by BRZ_BILLING_EVENTS
- **License Utilization**: Analyzed through BRZ_LICENSES
- **Customer Lifecycle**: Cross-table analysis capabilities

## Data Lineage and Traceability

### Source to Bronze Lineage
- **Complete Mapping**: Every Bronze field traces back to specific source field
- **Transformation Documentation**: All 1-to-1 mappings clearly documented
- **Audit Trail**: Full audit trail from source extraction to Bronze loading

### Metadata Catalog Integration
- **Data Dictionary**: Maintain comprehensive data dictionary
- **Business Glossary**: Link technical fields to business terminology
- **Impact Analysis**: Enable impact analysis for schema changes

## Assumptions and Implementation Notes

### Key Assumptions
1. **Data Volume**: Designed to handle high-volume data ingestion
2. **Data Freshness**: Near real-time ingestion requirements
3. **Data Retention**: Long-term retention for historical analysis
4. **Scalability**: Architecture supports horizontal scaling

### Implementation Considerations
1. **Incremental Loading**: Implement based on UPDATE_TIMESTAMP
2. **Parallel Processing**: Enable parallel ingestion for large datasets
3. **Resource Management**: Configure appropriate warehouse sizing
4. **Cost Optimization**: Implement data lifecycle management policies

### Future Enhancements
1. **Machine Learning Integration**: Prepare for ML-based data quality scoring
2. **Real-time Streaming**: Consider Kafka integration for real-time ingestion
3. **Advanced Analytics**: Enable support for advanced analytics workloads
4. **Data Mesh Architecture**: Prepare for potential data mesh implementation

## Conclusion

This comprehensive Bronze layer data mapping provides a robust foundation for the Zoom Platform Analytics System, ensuring data integrity, traceability, and scalability while supporting diverse analytics use cases across platform usage, service reliability, and revenue management domains.