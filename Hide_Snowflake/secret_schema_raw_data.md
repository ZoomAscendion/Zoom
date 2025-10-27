# Snowflake Schema Documentation - UTILITY Schema

## Database: DB_POC_ZOOM
## Schema: UTILITY
## Generated: 2025-01-27

---

## Raw Schema and Data Extraction Results

### Complete Schema Information:

```json
{
  "SECRET4BRONZE": {
    "type": "TABLE",
    "columns": [
      {
        "name": "APP_NAME",
        "type": "VARCHAR(100)"
      },
      {
        "name": "CONFIG_KEY",
        "type": "VARCHAR(100)"
      },
      {
        "name": "CONFIG_VALUE",
        "type": "VARCHAR(5000)"
      },
      {
        "name": "DESCRIPTION",
        "type": "VARCHAR(500)"
      },
      {
        "name": "IS_SENSITIVE",
        "type": "BOOLEAN"
      },
      {
        "name": "CREATED_AT",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATED_AT",
        "type": "TIMESTAMP_NTZ(9)"
      }
    ],
    "sample_data": [
      {
        "APP_NAME": "DBTJOB",
        "CONFIG_KEY": "Job_ID",
        "CONFIG_VALUE": "70471823521011",
        "DESCRIPTION": "DBT Cloud Job ID for Bronze Layer",
        "IS_SENSITIVE": false,
        "CREATED_AT": "2025-10-23 09:14:36.564000",
        "UPDATED_AT": "2025-10-23 09:14:36.564000"
      }
    ]
  },
  "SECRET4GOLD": {
    "type": "TABLE",
    "columns": [
      {
        "name": "APP_NAME",
        "type": "VARCHAR(100)"
      },
      {
        "name": "CONFIG_KEY",
        "type": "VARCHAR(100)"
      },
      {
        "name": "CONFIG_VALUE",
        "type": "VARCHAR(5000)"
      },
      {
        "name": "DESCRIPTION",
        "type": "VARCHAR(500)"
      },
      {
        "name": "IS_SENSITIVE",
        "type": "BOOLEAN"
      },
      {
        "name": "CREATED_AT",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATED_AT",
        "type": "TIMESTAMP_NTZ(9)"
      }
    ],
    "sample_data": [
      {
        "APP_NAME": "DBTJOB",
        "CONFIG_KEY": "Job_ID",
        "CONFIG_VALUE": "70471823521015",
        "DESCRIPTION": "DBT Cloud Job ID for Gold Layer",
        "IS_SENSITIVE": false,
        "CREATED_AT": "2025-10-23 09:25:36.699000",
        "UPDATED_AT": "2025-10-23 09:25:36.699000"
      }
    ]
  },
  "SECRET4SILVER": {
    "type": "TABLE",
    "columns": [
      {
        "name": "APP_NAME",
        "type": "VARCHAR(100)"
      },
      {
        "name": "CONFIG_KEY",
        "type": "VARCHAR(100)"
      },
      {
        "name": "CONFIG_VALUE",
        "type": "VARCHAR(5000)"
      },
      {
        "name": "DESCRIPTION",
        "type": "VARCHAR(500)"
      },
      {
        "name": "IS_SENSITIVE",
        "type": "BOOLEAN"
      },
      {
        "name": "CREATED_AT",
        "type": "TIMESTAMP_NTZ(9)"
      },
      {
        "name": "UPDATED_AT",
        "type": "TIMESTAMP_NTZ(9)"
      }
    ],
    "sample_data": [
      {
        "APP_NAME": "DBTJOB",
        "CONFIG_KEY": "Job_ID",
        "CONFIG_VALUE": "70471823521014",
        "DESCRIPTION": "DBT Cloud Job ID for Silver Layer",
        "IS_SENSITIVE": false,
        "CREATED_AT": "2025-10-23 09:18:09.665000",
        "UPDATED_AT": "2025-10-23 09:18:09.665000"
      }
    ]
  }
}
```

### SECRETS_STORE Table - Complete Data Structure:

**Table Type:** TABLE

**Columns:**
- APP_NAME: VARCHAR(100)
- CONFIG_KEY: VARCHAR(100) 
- CONFIG_VALUE: VARCHAR(5000)
- DESCRIPTION: VARCHAR(500)
- IS_SENSITIVE: BOOLEAN
- CREATED_AT: TIMESTAMP_NTZ(9)
- UPDATED_AT: TIMESTAMP_NTZ(9)

**Sample Records Count:** 27 records

**Applications Configured:**
- DBT (5 configurations)
- GITHUB (3 configurations) 
- SNOWFLAKE (7 configurations)
- DBTJOB (3 configurations)
- TABLEAU (9 configurations)

**Configuration Types Found:**
- API Keys and Tokens
- Database Connection Parameters
- Repository Information
- Job IDs
- Server URLs
- Authentication Credentials

---

## Schema Summary

Total Tables: 4
- SECRET4BRONZE: 1 record
- SECRET4GOLD: 1 record  
- SECRET4SILVER: 1 record
- SECRETS_STORE: 27 records

All tables share identical schema structure for configuration management.

**Note:** This extraction contains sensitive configuration data including API keys, passwords, and access tokens as stored in the source Snowflake database.
