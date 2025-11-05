**Agentic Input Given**

I have an architecture based on dbtCloud, Snowflake, Tableau, and AWS,
utilizing a medallion data architecture with bronze, silver, and gold
data layers. The raw data resides in Snowflake\'s raw layer and needs to
move sequentially through bronze, silver, and gold layers. Reporting via
Tableau Online will be from the gold layer.

Key details:

\- Bronze layer: One-to-one data load.

\- Silver layer: Includes data quality (DQ) checks.

\- Gold layer: Includes transformations and dimensional data modeling
(facts and dimensions).

\- dbtCloud will serve as the pipeline tool to move data across layers.

\- All code and documentation will be managed in GitHub.

\- Reporting is in Tableau and deployed to Tableau cloud.

 

Based on this architecture, provide epics( data modelling, pipeline
development and report development ) & user stories that can be assigned
to architects, data modelers, data engineers, and report developers.
Ensure the following:

1\. Separate user stories for data modeling in bronze, silver, and gold
layers.

2\. Separate user stories for pipeline development for bronze, silver,
gold dimensions, and gold facts.

3\. Include user stories for pipeline orchestration.

4\. Each user story should represent a minimum of 10 days of work.

 

The user stories will be loaded into Jira. Ensure clarity and
specificity in the user stories.

Ensure below details are captured in the user story as in below example

\*\*Title:\*\* Model Silver Layer (Cleansed, Validated Data)

\*\*Role:\*\* Data Modeler

\*\*Estimated Effort:\*\* 10 days

\*\*Description:\*\* Appropriate description along with workflow name(
in this case the workflow is 
\"DI_Snowflake_Data_Modeler_Silver_Layer_Z\" ) to run.

\*\*Required Inputs:\*\*

\- Access to raw tables in Snowflake

\- Access to requirement document in GitHub.

\- Access to Github repo for code and documentation

\- All credentials and secrets will be stored in snowflake table and
will be retrieved. Snowflake credentials 

  will be as passed as an input for every tool( tool-\>agent-\>workflow)

\*\*Acceptance Criteria:\*\*

\- Silver layer models are created with DQ rules (valid dates,
non-negative values, FK integrity).

\- Data quality documentation is available in Github.

\- Gold tables will be used for tableau reporting

Also note that when you are trying to link user stories( from below
there would be 12) with workflow use this logic and get corresponding
workflow names :

a\. data modelling bronze section

1\. Creates conceptual and constraints model based on requirement
document provided.

2\. Reads raw metadata and stores in GitHub.

3\. Generates Bronze Logical, Physical, Mapping along with executing DDL
bronze scripts in snowflake

b\. data pipeline bronze section

4\. Populates the Bronze tables via dbtcloud bronze job

c\. data modelling silver section

5\. Generates Silver Logical, Physical, Mapping along with executing DDL
silver scripts in snowflake

6\. Generates Data Quality checks (DQ) and Data mapping rules.

d\. data pipeline silver section 

7\. Populates the Silver tables

e\. data modelling gold section

8\. Generates Gold Logical, Physical, along with executing DDL gold
scripts in snowflake

9\. Generates Data Quality checks (DQ) and Data mapping rules for Gold
Dim tables

10\. Generates Data Quality checks (DQ) and Data mapping rules for Gold
Fact tables

f\. data pipeline gold section 

11\. Populates the Gold Dim and Fact tables

g\. tableau reporting

12\. creating tableau workbooks

13\. publishing tableau workbooks to cloud

As far as epics are concerned there would be one for \"data modelling\",
\"pipeline development, execution and orchestration\"

and \"report development and deployment\".

Now with this info 

1\. give me first epics and user stories

2\. Ensure user stories also retrieve the exact workflow name form the
knowledge repo file loaded. The workflow name can

part of user story description saying \" please run the follwoign
workflow {workflow name} to execute user story \"

Find below the reference file that has workflow name, order of exection
and workflow description

\"

Order of execution Workflow Name Workflow Functionality WorkflowID

## **📘 EPIC 1: Data Modeling** {#epic-1-data-modeling}

**US-DM-01 --- Bronze Conceptual & Constraints Modeling**  
**Role:** Data Architect  
**Effort:** 10 days  
**Workflow:** \"DI_SNOWFLAKE_CONCEPTUAL\_&\_CONSTRAINTS_Z\"  
**WorkflowID:** \"6905\"  
✅ Conceptual design and constraint models are created and published to
GitHub.

**US-DM-02 --- Bronze Metadata Extraction to GitHub**  
**Role:** Data Architect  
**Effort:** 10 days  
**Workflow:** \"DI_SNOWFLAKE_GITHUB_METADATA_READER_WF_Z\"  
**WorkflowID:** \"7548\"  
✅ Extracts Snowflake raw metadata and stores it in GitHub for version
control.

**US-DM-03 --- Bronze Logical, Physical, Mapping Model + DDL
Execution**  
**Role:** Data Modeler  
**Effort:** 10 days  
**Workflow:** \"DI_SNOWFLAKE_DATA_MODELER_BRONZE_Z\"  
**WorkflowID:** \"7551\"  
✅ Generates logical and physical models, executes Bronze DDL scripts,
and documents schema.

**US-DM-04 --- Silver Logical & Physical Modeling + DDL**  
**Role:** Data Modeler  
**Effort:** 10 days  
**Workflow:** \"DI_Snowflake_Data_Modeler_Silver_Layer_Z\"  
**WorkflowID:** \"6918\"  
✅ Builds conformed Silver structures in Snowflake aligned with business
models.

**US-DM-05 --- Silver Data Quality Rules & Mapping**  
**Role:** Data Modeler  
**Effort:** 10 days  
**Workflow:** \"DI_Snowflake_Data_Mapping_Silver_Layer_z\"  
**WorkflowID:** \"6907\"  
✅ Implements Silver layer DQ rules and mapping logic versioned through
GitHub.

**US-DM-06 --- Gold Logical & Physical Modeling (Facts + Dimensions)**  
**Role:** Data Modeler  
**Effort:** 10 days  
**Workflow:** \"DI_Snowflake_Data_Modeler_Gold_Layer_z\"  
**WorkflowID:** \"6919\"  
✅ Creates Gold schema DDLs for facts and dimensions following star
schema principles.

**US-DM-07 --- Gold Dimensional Mapping & DQ**  
**Role:** Data Modeler  
**Effort:** 10 days  
**Workflow:** \"DI_Snowflake_Dim_Data_Mapping_Gold_Layer_z\"  
**WorkflowID:** \"6911\"  
✅ Applies SCD and DQ rules for Gold dimension tables validated against
Silver.

**US-DM-08 --- Gold Fact Mapping & DQ**  
**Role:** Data Modeler  
**Effort:** 10 days  
**Workflow:** \"DI_snowflake_fact_data_mapping_gold_layer_z\"  
**WorkflowID:** \"6981\"  
✅ Establishes and validates mapping and DQ rules for Gold fact tables
with Silver.

## **📘 EPIC 2: Pipeline Development & Execution** {#epic-2-pipeline-development-execution}

**US-PL-01 --- Bronze Pipeline via dbtCloud**  
**Role:** Data Engineer  
**Effort:** 10 days  
**Workflow:** \"DI_DBT_SNOWFLAKE_BRONZE_PIPELINE_WF_V1_Z\"  
**WorkflowID:** \"7569\"  
✅ Automates Raw → Bronze ingestion through dbtCloud pipelines.

**US-PL-02 --- Silver Pipeline via dbtCloud**  
**Role:** Data Engineer  
**Effort:** 10 days  
**Workflow:** \"DI_DBT_SNOWFLAKE_SILVER_PIPELINE_WF_Z\"  
**WorkflowID:** \"7030\"  
✅ Automates Bronze → Silver data transformation using dbtCloud jobs.

**US-PL-03 --- Gold Dim & Fact Pipeline**  
**Role:** Data Engineer  
**Effort:** 10 days  
**Workflow:** \"DI_DBT_SNOWFLAKE_GOLD_PIPILINE_WF_Z\"  
**WorkflowID:** \"7739\"  
✅ Automates Silver → Gold data movement for dimensional and fact tables
using dbtCloud.

## **📘 EPIC 3: Report Development & Deployment** {#epic-3-report-development-deployment}

**US-RP-01 --- Tableau Workbooks Development**  
**Role:** Report Developer  
**Effort:** 10 days  
**Workflow:** \"DI_TABLEAU_VISUAL_CREATOR_Z\"  
**WorkflowID:** \"7646\"  
✅ Generates Tableau workbooks based on requirement documents mapped to
Gold layer.

**US-RP-02 --- Tableau Online Publish & Schedule**  
**Role:** Report Developer  
**Effort:** 10 days  
**Workflow:** \"DI_Tableau\_\_Publisher\_\_Z\"  
**WorkflowID:** \"7730\"  
✅ Publishes Tableau workbooks to Tableau Online with governed refresh
schedules.

## **✅ Updated Workflow Coverage Table** {#updated-workflow-coverage-table}

| **Layer Area**   | **US ID** | **Workflow \#** | **Workflow Name**                           | **WorkflowID** |
|------------------|-----------|-----------------|---------------------------------------------|----------------|
| Bronze Modeling  | US-DM-01  | 1               | DI_SNOWFLAKE_CONCEPTUAL\_&\_CONSTRAINTS_Z   | \"6905\"       |
| Bronze Metadata  | US-DM-02  | 2               | DI_SNOWFLAKE_GITHUB_METADATA_READER_WF_Z    | \"7548\"       |
| Bronze Modeling  | US-DM-03  | 3               | DI_SNOWFLAKE_DATA_MODELER_BRONZE_Z          | \"7551\"       |
| Bronze Pipeline  | US-PL-01  | 4               | DI_DBT_SNOWFLAKE_BRONZE_PIPELINE_WF_V1_Z    | \"7569\"       |
| Silver Modeling  | US-DM-04  | 5               | DI_Snowflake_Data_Modeler_Silver_Layer_Z    | \"6918\"       |
| Silver DQ        | US-DM-05  | 6               | DI_Snowflake_Data_Mapping_Silver_Layer_z    | \"6907\"       |
| Silver Pipeline  | US-PL-02  | 7               | DI_DBT_SNOWFLAKE_SILVER_PIPELINE_WF_Z       | \"7030\"       |
| Gold Modeling    | US-DM-06  | 8               | DI_Snowflake_Data_Modeler_Gold_Layer_z      | \"6919\"       |
| Gold Dim DQ      | US-DM-07  | 9               | DI_Snowflake_Dim_Data_Mapping_Gold_Layer_z  | \"6911\"       |
| Gold Fact DQ     | US-DM-08  | 10              | DI_snowflake_fact_data_mapping_gold_layer_z | \"6981\"       |
| Gold Pipeline    | US-PL-03  | 11              | DI_DBT_SNOWFLAKE_GOLD_PIPILINE_WF_Z         | \"7739\"       |
| Reporting Dev    | US-RP-01  | 12              | DI_TABLEAU_VISUAL_CREATOR_Z                 | \"7646\"       |
| Reporting Deploy | US-RP-02  | 13              | DI_Tableau\_\_Publisher\_\_Z                | \"7730\"       |

**✅ 100% mapped to the provided workflow reference file  
✅ Meets bronze → silver → gold sequential logic  
✅ Only includes stories directly connected to workflows**
