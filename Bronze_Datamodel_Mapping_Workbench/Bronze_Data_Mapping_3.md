_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive Bronze layer data mapping for Zoom Platform Analytics System in Medallion architecture with enhanced metadata and validation rules
## *Version*: 3 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping for Zoom Platform Analytics System

## Overview
This document provides a comprehensive data mapping between the source RAW layer and the Bronze layer in the Medallion architecture implementation for Snowflake. The Bronze layer preserves the original structure of raw data while adding metadata for tracking and auditing purposes. This mapping ensures one-to-one field mapping with no transformations applied, maintaining data integrity for downstream Silver layer processing.

## Architecture Context

**Source Database**: DB_POC_ZOOM  
**Source Schema**: RAW  
**Target Database**: DB_POC_ZOOM  
**Target Schema**: BRONZE  
**Architecture Pattern**: Medallion (Bronze → Silver → Gold)  
**Data Processing**: ELT (Extract, Load, Transform)

## Detailed Data Mapping Tables

### 1. Users Data Mapping

**Source Table**: RAW.USERS → **Target Table**: BRONZE.BZ_USERS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_USERS | USER_ID | Source | USERS | USER_ID | 1-1 Mapping |
| Bronze | BZ_USERS | USER_NAME | Source | USERS | USER_NAME | 1-1 Mapping |
| Bronze | BZ_USERS | EMAIL | Source | USERS | EMAIL | 1-1 Mapping |
| Bronze | BZ_USERS | COMPANY | Source | USERS | COMPANY | 1-1 Mapping |
| Bronze | BZ_USERS | PLAN_TYPE | Source | USERS | PLAN_TYPE | 1-1 Mapping |
| Bronze | BZ_USERS | LOAD_TIMESTAMP | Source | USERS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_USERS | UPDATE_TIMESTAMP | Source | USERS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_USERS | SOURCE_SYSTEM | Source | USERS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types**: VARCHAR(16777216) for text fields, TIMESTAMP_NTZ(9) for timestamps  
**Domain Values**: PLAN_TYPE contains Basic, Pro, Business, Enterprise  
**PII Fields**: USER_NAME, EMAIL (require special handling for compliance)

### 2. Meetings Data Mapping

**Source Table**: RAW.MEETINGS → **Target Table**: BRONZE.BZ_MEETINGS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_MEETINGS | MEETING_ID | Source | MEETINGS | MEETING_ID | 1-1 Mapping |
| Bronze | BZ_MEETINGS | HOST_ID | Source | MEETINGS | HOST_ID | 1-1 Mapping |
| Bronze | BZ_MEETINGS | MEETING_TOPIC | Source | MEETINGS | MEETING_TOPIC | 1-1 Mapping |
| Bronze | BZ_MEETINGS | START_TIME | Source | MEETINGS | START_TIME | 1-1 Mapping |
| Bronze | BZ_MEETINGS | END_TIME | Source | MEETINGS | END_TIME | 1-1 Mapping |
| Bronze | BZ_MEETINGS | DURATION_MINUTES | Source | MEETINGS | DURATION_MINUTES | 1-1 Mapping |
| Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Source | MEETINGS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Source | MEETINGS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Source | MEETINGS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types**: VARCHAR(16777216) for text fields, TIMESTAMP_NTZ(9) for time fields, NUMBER(38,0) for DURATION_MINUTES  
**PII Fields**: MEETING_TOPIC (potential PII, requires careful handling)

### 3. Participants Data Mapping

**Source Table**: RAW.PARTICIPANTS → **Target Table**: BRONZE.BZ_PARTICIPANTS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Source | PARTICIPANTS | PARTICIPANT_ID | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | MEETING_ID | Source | PARTICIPANTS | MEETING_ID | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | USER_ID | Source | PARTICIPANTS | USER_ID | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | JOIN_TIME | Source | PARTICIPANTS | JOIN_TIME | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | LEAVE_TIME | Source | PARTICIPANTS | LEAVE_TIME | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Source | PARTICIPANTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Source | PARTICIPANTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Source | PARTICIPANTS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types**: VARCHAR(16777216) for ID fields, TIMESTAMP_NTZ(9) for all time-related fields  
**Relationships**: Links MEETINGS and USERS entities through foreign key references

### 4. Feature Usage Data Mapping

**Source Table**: RAW.FEATURE_USAGE → **Target Table**: BRONZE.BZ_FEATURE_USAGE

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_FEATURE_USAGE | USAGE_ID | Source | FEATURE_USAGE | USAGE_ID | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | MEETING_ID | Source | FEATURE_USAGE | MEETING_ID | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Source | FEATURE_USAGE | FEATURE_NAME | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | Source | FEATURE_USAGE | USAGE_COUNT | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Source | FEATURE_USAGE | USAGE_DATE | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Source | FEATURE_USAGE | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Source | FEATURE_USAGE | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Source | FEATURE_USAGE | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types**: VARCHAR(16777216) for text fields, NUMBER(38,0) for USAGE_COUNT, DATE for USAGE_DATE, TIMESTAMP_NTZ(9) for timestamps  
**Business Context**: Tracks platform feature adoption and usage patterns

### 5. Support Tickets Data Mapping

**Source Table**: RAW.SUPPORT_TICKETS → **Target Table**: BRONZE.BZ_SUPPORT_TICKETS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Source | SUPPORT_TICKETS | TICKET_ID | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | USER_ID | Source | SUPPORT_TICKETS | USER_ID | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Source | SUPPORT_TICKETS | TICKET_TYPE | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Source | SUPPORT_TICKETS | RESOLUTION_STATUS | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Source | SUPPORT_TICKETS | OPEN_DATE | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Source | SUPPORT_TICKETS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Source | SUPPORT_TICKETS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Source | SUPPORT_TICKETS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types**: VARCHAR(16777216) for text fields, DATE for OPEN_DATE, TIMESTAMP_NTZ(9) for timestamps  
**Domain Values**: RESOLUTION_STATUS contains Open, In Progress, Resolved, Closed  
**Business Context**: Supports customer service analytics and SLA monitoring

### 6. Billing Events Data Mapping

**Source Table**: RAW.BILLING_EVENTS → **Target Table**: BRONZE.BZ_BILLING_EVENTS

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_BILLING_EVENTS | EVENT_ID | Source | BILLING_EVENTS | EVENT_ID | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | USER_ID | Source | BILLING_EVENTS | USER_ID | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Source | BILLING_EVENTS | EVENT_TYPE | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | AMOUNT | Source | BILLING_EVENTS | AMOUNT | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Source | BILLING_EVENTS | EVENT_DATE | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Source | BILLING_EVENTS | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Source | BILLING_EVENTS | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Source | BILLING_EVENTS | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types**: VARCHAR(16777216) for text fields, NUMBER(10,2) for AMOUNT, DATE for EVENT_DATE, TIMESTAMP_NTZ(9) for timestamps  
**Business Context**: Critical for revenue analytics and financial reporting

### 7. Licenses Data Mapping

**Source Table**: RAW.LICENSES → **Target Table**: BRONZE.BZ_LICENSES

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Bronze | BZ_LICENSES | LICENSE_ID | Source | LICENSES | LICENSE_ID | 1-1 Mapping |
| Bronze | BZ_LICENSES | LICENSE_TYPE | Source | LICENSES | LICENSE_TYPE | 1-1 Mapping |
| Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Source | LICENSES | ASSIGNED_TO_USER_ID | 1-1 Mapping |
| Bronze | BZ_LICENSES | START_DATE | Source | LICENSES | START_DATE | 1-1 Mapping |
| Bronze | BZ_LICENSES | END_DATE | Source | LICENSES | END_DATE | 1-1 Mapping |
| Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Source | LICENSES | LOAD_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Source | LICENSES | UPDATE_TIMESTAMP | 1-1 Mapping |
| Bronze | BZ_LICENSES | SOURCE_SYSTEM | Source | LICENSES | SOURCE_SYSTEM | 1-1 Mapping |

**Data Types**: VARCHAR(16777216) for text fields, DATE for START_DATE and END_DATE, TIMESTAMP_NTZ(9) for timestamps  
**Business Context**: Supports license utilization analytics and compliance tracking

## Data Type Compatibility and Validation

### Snowflake Data Type Mapping

| Source Data Type | Bronze Data Type | Snowflake Compatible | Precision/Scale | Storage Optimization |
|------------------|------------------|---------------------|-----------------|---------------------|
| VARCHAR(16777216) | VARCHAR(16777216) | ✓ | Max length | Automatic compression |
| NUMBER(38,0) | NUMBER(38,0) | ✓ | Integer precision | Optimized for integers |
| NUMBER(10,2) | NUMBER(10,2) | ✓ | Decimal precision | Currency-optimized |
| DATE | DATE | ✓ | Date only | 4-byte storage |
| TIMESTAMP_NTZ(9) | TIMESTAMP_NTZ(9) | ✓ | Nanosecond precision | 8-byte + precision |

### Initial Data Validation Rules (Bronze Layer)

1. **Completeness Checks**:
   - Primary key fields (IDs) must not be NULL
   - Required timestamp fields must be populated
   - Source system field must be populated

2. **Format Validation**:
   - Email fields follow basic email format (validated in Silver)
   - Date fields are valid dates
   - Numeric fields contain valid numbers

3. **Referential Awareness** (not enforced):
   - USER_ID references exist in conceptual model
   - MEETING_ID references are tracked for lineage
   - Foreign key relationships documented but not enforced

## Bronze Layer Design Principles

### 1. Raw Data Preservation
- **No Transformation**: Data stored exactly as received from source
- **Schema Flexibility**: No constraints to accommodate source changes
- **Historical Preservation**: All versions maintained through Snowflake time travel
- **Error Tolerance**: Invalid data stored with flags for downstream handling

### 2. Metadata Management
- **Load Tracking**: LOAD_TIMESTAMP captures initial ingestion time
- **Change Tracking**: UPDATE_TIMESTAMP tracks last modification
- **Source Lineage**: SOURCE_SYSTEM identifies data origin
- **Audit Trail**: Complete audit capability through metadata

### 3. Snowflake Optimization
- **Micro-partitioning**: Automatic partitioning by Snowflake
- **Compression**: Automatic compression for storage efficiency
- **Clustering**: Optional clustering on frequently queried columns
- **Time Travel**: 90-day time travel for data recovery

### 4. Security and Compliance
- **PII Identification**: All PII fields documented and tagged
- **Access Control**: Role-based access through Snowflake RBAC
- **Data Classification**: Sensitive data clearly identified
- **Audit Logging**: All access and modifications logged

## Data Ingestion Process

### 1. Extract Phase
- Source data extracted from RAW layer tables
- Data quality assessment performed
- Volume and completeness validated

### 2. Load Phase
- Data loaded into Bronze tables with BZ_ prefix
- Metadata fields populated during load
- Load statistics captured for monitoring

### 3. Validation Phase
- Basic format validation performed
- Completeness checks executed
- Quality metrics calculated and stored

### 4. Audit Phase
- All operations logged in BZ_DATA_AUDIT table
- Performance metrics captured
- Error handling and alerting triggered

## Performance and Scalability Considerations

### Storage Optimization
- **Automatic Compression**: Snowflake handles compression automatically
- **Columnar Storage**: Optimized for analytical queries
- **Micro-partitioning**: Automatic partitioning for query performance

### Query Performance
- **Clustering Keys**: Can be applied on frequently filtered columns
- **Result Caching**: Automatic result caching for repeated queries
- **Materialized Views**: Can be created for frequently accessed aggregations

### Scalability Features
- **Auto-scaling**: Snowflake warehouses scale automatically
- **Concurrent Processing**: Multiple pipelines can load simultaneously
- **Zero-copy Cloning**: Efficient data sharing and testing

## Monitoring and Data Quality

### Key Metrics
1. **Load Performance**: Records per second, load duration
2. **Data Quality**: Completeness, validity, consistency scores
3. **Volume Trends**: Daily/weekly/monthly volume patterns
4. **Error Rates**: Failed loads, data quality issues

### Alerting Thresholds
- Load failures or delays beyond SLA
- Data quality scores below acceptable thresholds
- Volume anomalies (too high/low compared to historical patterns)
- Source system connectivity issues

## Business Context and KPI Support

### Platform Usage Analytics
- **Daily/Weekly/Monthly Active Users**: Supported through USERS and MEETINGS mapping
- **Meeting Duration Analysis**: Enabled through MEETINGS.DURATION_MINUTES
- **Feature Adoption**: Tracked through FEATURE_USAGE mapping

### Service Reliability Metrics
- **Support Ticket Analysis**: Enabled through SUPPORT_TICKETS mapping
- **Resolution Time Tracking**: Supported through ticket status and dates
- **User Experience Metrics**: Cross-referenced through user and meeting data

### Revenue Analytics
- **Monthly Recurring Revenue**: Calculated from BILLING_EVENTS
- **License Utilization**: Tracked through LICENSES mapping
- **Customer Lifetime Value**: Supported through user and billing integration

## Data Governance Framework

### Data Lineage
- **Source Tracking**: SOURCE_SYSTEM field maintains origin information
- **Processing History**: Timestamps track data movement through pipeline
- **Impact Analysis**: Downstream dependencies clearly documented

### Data Quality Management
- **Quality Dimensions**: Completeness, accuracy, consistency, timeliness
- **Quality Rules**: Defined but not enforced in Bronze layer
- **Quality Metrics**: Calculated and stored for trend analysis

### Compliance and Privacy
- **PII Handling**: All PII fields identified and documented
- **Data Retention**: Policies defined for each data category
- **Access Controls**: Role-based access implemented
- **Audit Requirements**: Complete audit trail maintained

## Integration with Silver Layer

### Data Preparation
- Bronze layer provides clean, structured input for Silver transformations
- All source data available for comprehensive business rule application
- Metadata enables intelligent processing decisions

### Transformation Readiness
- **Data Types**: Optimized for Snowflake transformation functions
- **Relationships**: Foreign key relationships documented for joins
- **Business Rules**: Ready for application in Silver layer
- **Quality Flags**: Enable conditional processing in transformations

## Key Assumptions and Dependencies

### Technical Assumptions
- Source systems maintain consistent data structure
- Snowflake warehouse capacity adequate for processing volumes
- Network connectivity stable for data transfer
- Source system metadata fields populated correctly

### Business Assumptions
- Data quality issues addressed in Silver layer
- Business rules applied downstream, not in Bronze
- Historical data preservation required for compliance
- Real-time processing not required at Bronze layer

### Dependencies
- Source RAW layer tables available and accessible
- Snowflake Bronze schema created and configured
- Appropriate roles and permissions established
- Monitoring and alerting infrastructure in place

---

**Document Validation**: This mapping has been validated against:
- Source RAW layer schema documentation
- Bronze layer physical data model DDL
- Conceptual data model requirements
- Snowflake best practices and optimization guidelines

**Implementation Status**: Ready for Bronze layer implementation with comprehensive data pipeline development.

**outputURL**: https://github.com/ZoomAscendion/Zoom/tree/Agent_Output/Bronze_Datamodel_Mapping_Workbench  
**pipelineID**: 8289