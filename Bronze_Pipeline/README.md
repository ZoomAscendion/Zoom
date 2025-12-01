# Bronze Layer Data Pipeline - Zoom Platform Analytics System

## Overview

This repository contains the production-ready DBT code for the Bronze layer transformation in the Medallion architecture for the Zoom Platform Analytics System. The Bronze layer serves as the raw data ingestion layer, preserving source data integrity while adding essential metadata for downstream processing.

## Architecture

### Medallion Architecture - Bronze Layer
- **Purpose**: Raw data storage with minimal transformation
- **Data Sources**: 7 RAW layer tables
- **Target**: 7 Bronze layer tables + 1 audit table
- **Platform**: Snowflake Data Cloud
- **Orchestration**: DBT (Data Build Tool)

## Project Structure

```
Bronze_Pipeline/
├── dbt_project.yml              # DBT project configuration
├── packages.yml                 # External package dependencies
├── README.md                   # This documentation
├── models/
│   └── bronze/
│       ├── schema.yml          # Sources and models configuration
│       ├── bz_data_audit.sql   # Audit trail model
│       ├── bz_users.sql        # Users Bronze model
│       ├── bz_meetings.sql     # Meetings Bronze model
│       ├── bz_participants.sql # Participants Bronze model
│       ├── bz_feature_usage.sql# Feature Usage Bronze model
│       ├── bz_support_tickets.sql # Support Tickets Bronze model
│       ├── bz_billing_events.sql  # Billing Events Bronze model
│       └── bz_licenses.sql     # Licenses Bronze model
└── tests/
    └── bronze_layer_unit_tests.sql # Comprehensive unit tests
```

## Data Models

### Bronze Layer Tables

| Table Name | Description | Primary Key | PII Fields |
|------------|-------------|-------------|------------|
| `bz_users` | User profile and subscription information | `user_id` | `user_name`, `email` |
| `bz_meetings` | Meeting information and session details | `meeting_id` | `meeting_topic` (potential) |
| `bz_participants` | Meeting participants and session details | `participant_id` | None |
| `bz_feature_usage` | Platform feature usage during meetings | `usage_id` | None |
| `bz_support_tickets` | Customer support requests and resolution | `ticket_id` | None |
| `bz_billing_events` | Financial transactions and billing activities | `event_id` | None |
| `bz_licenses` | License assignments and entitlements | `license_id` | None |
| `bz_data_audit` | Comprehensive audit trail for operations | `record_id` | None |

### Source Tables (RAW Layer)

| Source Table | Target Bronze Table | Mapping Type |
|--------------|--------------------|--------------|
| `USERS` | `BZ_USERS` | 1:1 |
| `MEETINGS` | `BZ_MEETINGS` | 1:1 |
| `PARTICIPANTS` | `BZ_PARTICIPANTS` | 1:1 |
| `FEATURE_USAGE` | `BZ_FEATURE_USAGE` | 1:1 |
| `SUPPORT_TICKETS` | `BZ_SUPPORT_TICKETS` | 1:1 |
| `BILLING_EVENTS` | `BZ_BILLING_EVENTS` | 1:1 |
| `LICENSES` | `BZ_LICENSES` | 1:1 |

## Key Features

### 🔄 Incremental Processing
- All models use incremental materialization
- Efficient processing based on `update_timestamp`
- Automatic deduplication using ROW_NUMBER() window functions

### 🔍 Data Quality Validation
- Primary key uniqueness enforcement
- Data type validation and consistency checks
- Business rule validation (e.g., time ranges, amounts)
- Comprehensive unit test suite with 15+ test cases

### 📊 Audit Trail
- Complete audit logging for all operations
- Pre/post hooks for performance monitoring
- Processing time tracking
- Status monitoring (SUCCESS, FAILED, WARNING)

### 🛡️ Error Handling
- Graceful handling of null values
- Invalid data filtering with quality flags
- Comprehensive logging of data issues
- Fallback values for missing metadata

### 🔐 PII Compliance
- Identification of PII fields in documentation
- Proper tagging for compliance monitoring
- Data classification metadata

## Installation & Setup

### Prerequisites
- DBT Core >= 1.0.0
- Snowflake account with appropriate permissions
- Access to source RAW schema

### 1. Install Dependencies
```bash
dbt deps
```

### 2. Configure Profile
Create/update your `profiles.yml`:
```yaml
zoom_bronze_pipeline:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: [your_account]
      user: [your_username]
      password: [your_password]
      role: [your_role]
      database: DB_POC_ZOOM
      warehouse: WH_POC_Z_DEV_XSMALL
      schema: bronze
      threads: 4
```

### 3. Test Connection
```bash
dbt debug
```

## Usage

### Full Refresh (Initial Load)
```bash
dbt run --full-refresh
```

### Incremental Run
```bash
dbt run
```

### Run Specific Model
```bash
dbt run --select bz_users
```

### Run Tests
```bash
dbt test
```

### Run Unit Tests
```bash
dbt test --select bronze_layer_unit_tests
```

### Generate Documentation
```bash
dbt docs generate
dbt docs serve
```

## Data Quality Tests

The pipeline includes comprehensive data quality validation:

### Primary Tests
1. **Uniqueness**: Primary key uniqueness across all tables
2. **Not Null**: Critical fields validation
3. **Referential Integrity**: Cross-table relationship validation
4. **Business Rules**: Domain-specific validation (e.g., time ranges)
5. **Data Freshness**: Ensuring data is within acceptable age limits

### Unit Tests
- 15+ comprehensive test cases
- Edge case validation
- Cross-table consistency checks
- Metadata completeness validation
- Format validation (e.g., email formats)

## Monitoring & Observability

### Audit Trail
- All operations logged in `bz_data_audit`
- Processing time tracking
- Success/failure status monitoring
- Data lineage information

### Performance Metrics
- Row count logging
- Processing duration tracking
- Data quality metrics
- Error rate monitoring

## Configuration

### Environment Variables
```yaml
vars:
  environment: 'dev'  # dev, staging, prod
  enable_audit_logging: true
  max_null_percentage: 0.05
  lookback_days: 7
```

### Model-Specific Configuration
Each model can be configured independently:
```yaml
models:
  zoom_bronze_pipeline:
    bronze:
      bz_users:
        +materialized: incremental
        +unique_key: user_id
        +tags: ["bronze", "users", "pii"]
```

## Best Practices

### 1. Data Ingestion
- Preserve raw data structure
- Add metadata for lineage tracking
- Implement proper error handling
- Use incremental processing for efficiency

### 2. Data Quality
- Validate primary keys
- Check business rules
- Monitor data freshness
- Log all quality issues

### 3. Performance
- Use appropriate warehouse sizing
- Implement proper clustering
- Monitor query performance
- Optimize incremental logic

### 4. Security
- Identify and tag PII fields
- Implement proper access controls
- Audit data access
- Follow compliance requirements

## Troubleshooting

### Common Issues

1. **Incremental Load Failures**
   - Check `update_timestamp` field availability
   - Verify source data freshness
   - Review audit logs for errors

2. **Data Quality Test Failures**
   - Review test results in detail
   - Check source data quality
   - Validate business rules

3. **Performance Issues**
   - Monitor warehouse utilization
   - Review query execution plans
   - Consider clustering optimization

### Debug Commands
```bash
# Check model compilation
dbt compile --select bz_users

# Run with debug logging
dbt --debug run --select bz_users

# Check test results
dbt test --store-failures
```

## Contributing

### Development Workflow
1. Create feature branch
2. Implement changes
3. Run tests locally
4. Submit pull request
5. Code review
6. Deploy to staging
7. Production deployment

### Code Standards
- Follow DBT best practices
- Include comprehensive tests
- Document all changes
- Maintain audit trail

## Support

For issues and questions:
- Review documentation
- Check audit logs
- Contact Data Engineering team
- Submit GitHub issues

## Version History

| Version | Date | Changes |
|---------|------|----------|
| 1.0.0 | 2024-11-11 | Initial Bronze layer implementation |

---

**Author**: AAVA Data Engineering Team  
**Created**: November 11, 2024  
**Last Updated**: November 11, 2024  
**License**: Internal Use Only