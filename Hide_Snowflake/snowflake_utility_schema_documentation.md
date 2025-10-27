# Snowflake Schema Documentation - UTILITY Schema

## Database: DB_POC_ZOOM
## Schema: UTILITY
## Generated: 2025-01-27

---

## Table: SECRET4BRONZE

**Type:** TABLE

### Schema Definition

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| APP_NAME | VARCHAR(100) | Application name identifier |
| CONFIG_KEY | VARCHAR(100) | Configuration key identifier |
| CONFIG_VALUE | VARCHAR(5000) | Configuration value content |
| DESCRIPTION | VARCHAR(500) | Description of the configuration |
| IS_SENSITIVE | BOOLEAN | Flag indicating if data is sensitive |
| CREATED_AT | TIMESTAMP_NTZ(9) | Record creation timestamp |
| UPDATED_AT | TIMESTAMP_NTZ(9) | Record last update timestamp |

### Sample Data

| APP_NAME | CONFIG_KEY | CONFIG_VALUE | DESCRIPTION | IS_SENSITIVE | CREATED_AT | UPDATED_AT |
|----------|------------|--------------|-------------|--------------|------------|------------|
| DBTJOB | Job_ID | 70471823521011 | DBT Cloud Job ID for Bronze Layer | false | 2025-10-23 09:14:36.564000 | 2025-10-23 09:14:36.564000 |

---

## Table: SECRET4GOLD

**Type:** TABLE

### Schema Definition

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| APP_NAME | VARCHAR(100) | Application name identifier |
| CONFIG_KEY | VARCHAR(100) | Configuration key identifier |
| CONFIG_VALUE | VARCHAR(5000) | Configuration value content |
| DESCRIPTION | VARCHAR(500) | Description of the configuration |
| IS_SENSITIVE | BOOLEAN | Flag indicating if data is sensitive |
| CREATED_AT | TIMESTAMP_NTZ(9) | Record creation timestamp |
| UPDATED_AT | TIMESTAMP_NTZ(9) | Record last update timestamp |

### Sample Data

| APP_NAME | CONFIG_KEY | CONFIG_VALUE | DESCRIPTION | IS_SENSITIVE | CREATED_AT | UPDATED_AT |
|----------|------------|--------------|-------------|--------------|------------|------------|
| DBTJOB | Job_ID | 70471823521015 | DBT Cloud Job ID for Gold Layer | false | 2025-10-23 09:25:36.699000 | 2025-10-23 09:25:36.699000 |

---

## Table: SECRET4SILVER

**Type:** TABLE

### Schema Definition

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| APP_NAME | VARCHAR(100) | Application name identifier |
| CONFIG_KEY | VARCHAR(100) | Configuration key identifier |
| CONFIG_VALUE | VARCHAR(5000) | Configuration value content |
| DESCRIPTION | VARCHAR(500) | Description of the configuration |
| IS_SENSITIVE | BOOLEAN | Flag indicating if data is sensitive |
| CREATED_AT | TIMESTAMP_NTZ(9) | Record creation timestamp |
| UPDATED_AT | TIMESTAMP_NTZ(9) | Record last update timestamp |

### Sample Data

| APP_NAME | CONFIG_KEY | CONFIG_VALUE | DESCRIPTION | IS_SENSITIVE | CREATED_AT | UPDATED_AT |
|----------|------------|--------------|-------------|--------------|------------|------------|
| DBTJOB | Job_ID | 70471823521014 | DBT Cloud Job ID for Silver Layer | false | 2025-10-23 09:18:09.665000 | 2025-10-23 09:18:09.665000 |

---

## Table: SECRETS_STORE

**Type:** TABLE

### Schema Definition

| Column Name | Data Type | Business Description |
|-------------|-----------|---------------------|
| APP_NAME | VARCHAR(100) | Application name identifier |
| CONFIG_KEY | VARCHAR(100) | Configuration key identifier |
| CONFIG_VALUE | VARCHAR(5000) | Configuration value content |
| DESCRIPTION | VARCHAR(500) | Description of the configuration |
| IS_SENSITIVE | BOOLEAN | Flag indicating if data is sensitive |
| CREATED_AT | TIMESTAMP_NTZ(9) | Record creation timestamp |
| UPDATED_AT | TIMESTAMP_NTZ(9) | Record last update timestamp |

### Complete Data Records (26 total records)

**DBT Application Configurations:**
- Git_Branch: main (GitHub Branch Name) - SENSITIVE
- DBT_Base_URL: https://ph377.us1.dbt.com/ (DBT Cloud Base URL) - SENSITIVE  
- DBT_API_key: [API_KEY_VALUE] (DBT Cloud API Key) - SENSITIVE
- DBT_Account_ID: 70471823503589 (DBT Cloud Account ID) - SENSITIVE
- DBT_Project_name: Zoom (DBT Cloud Project Name) - SENSITIVE
- repo_owner: ZoomAscendion (GitHub repository owner for DBT project)
- repo: Zoom (GitHub repository name for DBT project)

**GitHub Application Configurations:**
- repo: ZoomAscendion/Zoom (GitHub Repository Name)
- branch: Agent_Output (Git Branch for deployment)
- token: [GITHUB_TOKEN_VALUE] (GitHub Personal Access Token) - HIGHLY SENSITIVE

**Snowflake Application Configurations:**
- user: THEJASHWANI (Snowflake Username) - SENSITIVE
- password: [PASSWORD_VALUE] (Snowflake Password) - HIGHLY SENSITIVE
- account: NWZLYVS-MU54263 (Snowflake Account Identifier)
- warehouse: COMPUTE_WH (Snowflake Warehouse Name)
- database: ZOOM (Snowflake Database Name)
- schema: GOLD (Snowflake Schema Name)
- role: ACCOUNTADMIN (Snowflake Role Name)

**DBT Job Configurations:**
- bronze_job_id: 70471823521011 (DBT Cloud Job ID for Bronze Layer)
- silver_job_id: 70471823521014 (DBT Cloud Job ID for Silver Layer)
- gold_job_id: 70471823521015 (DBT Cloud Job ID for Gold Layer)

**Tableau Application Configurations:**
- tableau_server: https://prod-in-a.online.tableau.com/ (Tableau Server URL)
- site_content_url: suryaprakash-f6d19a0377 (Tableau Site Content URL)
- pat_name: zoom (Tableau Personal Access Token Name)
- pat_secret: [TABLEAU_TOKEN_VALUE] (Tableau Personal Access Token Secret) - SENSITIVE
- api_version: 3.20 (Tableau API Version)
- github_workbook_url: https://raw.githubusercontent.com/suryarebal45/zoom_mapping/refs/heads/main/tableau/agent/ (GitHub Workbook URL for Tableau)
- target_project_name: zoom (Target Tableau Project Name)

---

## Summary

**Total Tables:** 4
- SECRET4BRONZE (1 record)
- SECRET4GOLD (1 record)
- SECRET4SILVER (1 record)
- SECRETS_STORE (26 records)

**Schema Pattern:** All tables follow the same schema structure with columns for application configuration management, including sensitive data handling capabilities.

**Data Categories:**
- DBT Cloud configurations
- GitHub repository settings
- Snowflake connection parameters
- Tableau server configurations
- Job IDs for different data layers (Bronze, Silver, Gold)

**Security Note:** This schema contains sensitive information including API keys, passwords, and access tokens that should be handled with appropriate security measures.

**Timestamp Range:** Records span from 2025-10-23 to 2025-10-26, indicating recent configuration updates across all applications.