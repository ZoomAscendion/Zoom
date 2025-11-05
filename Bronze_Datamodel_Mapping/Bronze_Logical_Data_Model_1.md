_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Logical Data Model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# 1) PII Classification

| Column Name       | Table Name       | PII Classification | Reason                                                                                  |
|-------------------|------------------|--------------------|-----------------------------------------------------------------------------------------|
| USER_NAME         | Bz_Users         | PII                | Identifies an individual user by name                                                  |
| EMAIL             | Bz_Users         | PII                | Email address is personally identifiable information                                   |
| COMPANY           | Bz_Users         | Potential PII       | Company name may indirectly identify user or organization                              |
| ASSIGNED_TO_USER_ID| Bz_Licenses      | PII (Indirect)     | Links license to a user, indirectly identifying the user                               |
| HOST_ID           | Bz_Meetings      | PII (Indirect)     | Links meeting host to a user                                                           |
| USER_ID           | Bz_Billing_Events, Bz_Support_Tickets, Bz_Participants | PII (Indirect) | Foreign key references user, indirectly identifying the individual                      |
| PARTICIPANT_ID    | Bz_Participants  | Not PII            | Identifier for participant record, no direct personal info                             |
| TICKET_ID         | Bz_Support_Tickets| Not PII            | Identifier for support ticket                                                          |
| LICENSE_ID        | Bz_Licenses      | Not PII            | License record identifier                                                              |
| MEETING_ID        | Bz_Meetings      | Not PII            | Meeting session identifier                                                             |
| EVENT_ID          | Bz_Billing_Events| Not PII            | Billing event identifier                                                               |
| USAGE_ID          | Bz_Feature_Usage | Not PII            | Feature usage record identifier                                                        |

# 2) Bronze Layer Logical Model

## Table: Bz_Users
| Column Name     | Data Type | Description                                  |
|-----------------|-----------|----------------------------------------------|
| USER_NAME       | STRING    | Name of the user on the Zoom platform        |
| EMAIL           | STRING    | Email address of the user                     |
| COMPANY         | STRING    | Company or organization the user belongs to  |
| PLAN_TYPE       | STRING    | Subscription plan type (free, paid, etc.)    |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when the record was loaded          |
| UPDATE_TIMESTAMP| TIMESTAMP | Timestamp when the record was last updated    |
| SOURCE_SYSTEM   | STRING    | Source system identifier                       |

## Table: Bz_Meetings
| Column Name     | Data Type | Description                                  |
|-----------------|-----------|----------------------------------------------|
| MEETING_TOPIC   | STRING    | Topic or title of the meeting                 |
| START_TIME      | TIMESTAMP | Meeting start time                            |
| END_TIME        | TIMESTAMP | Meeting end time                              |
| DURATION_MINUTES| INTEGER   | Duration of the meeting in minutes            |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when the record was loaded          |
| UPDATE_TIMESTAMP| TIMESTAMP | Timestamp when the record was last updated    |
| SOURCE_SYSTEM   | STRING    | Source system identifier                       |

## Table: Bz_Participants
| Column Name     | Data Type | Description                                  |
|-----------------|-----------|----------------------------------------------|
| MEETING_ID      | STRING    | Identifier of the meeting the participant joined |
| USER_ID         | STRING    | Identifier of the user participating          |
| JOIN_TIME       | TIMESTAMP | Time participant joined the meeting           |
| LEAVE_TIME      | TIMESTAMP | Time participant left the meeting             |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when the record was loaded          |
| UPDATE_TIMESTAMP| TIMESTAMP | Timestamp when the record was last updated    |
| SOURCE_SYSTEM   | STRING    | Source system identifier                       |

## Table: Bz_Feature_Usage
| Column Name     | Data Type | Description                                  |
|-----------------|-----------|----------------------------------------------|
| MEETING_ID      | STRING    | Identifier of the meeting where feature was used |
| FEATURE_NAME    | STRING    | Name of the Zoom platform feature used       |
| USAGE_COUNT     | INTEGER   | Number of times the feature was used          |
| USAGE_DATE      | DATE      | Date when the feature was used                 |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when the record was loaded          |
| UPDATE_TIMESTAMP| TIMESTAMP | Timestamp when the record was last updated    |
| SOURCE_SYSTEM   | STRING    | Source system identifier                       |

## Table: Bz_Support_Tickets
| Column Name     | Data Type | Description                                  |
|-----------------|-----------|----------------------------------------------|
| USER_ID         | STRING    | Identifier of the user who raised the ticket |
| TICKET_TYPE     | STRING    | Type/category of the support ticket           |
| RESOLUTION_STATUS| STRING   | Status of ticket resolution (open, closed, etc.) |
| OPEN_DATE       | DATE      | Date when the ticket was opened                |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when the record was loaded          |
| UPDATE_TIMESTAMP| TIMESTAMP | Timestamp when the record was last updated    |
| SOURCE_SYSTEM   | STRING    | Source system identifier                       |

## Table: Bz_Billing_Events
| Column Name     | Data Type | Description                                  |
|-----------------|-----------|----------------------------------------------|
| USER_ID         | STRING    | Identifier of the user associated with billing event |
| EVENT_TYPE      | STRING    | Type of billing event (payment, refund, etc.) |
| AMOUNT          | DECIMAL   | Amount involved in the billing event          |
| EVENT_DATE      | DATE      | Date of the billing event                       |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when the record was loaded          |
| UPDATE_TIMESTAMP| TIMESTAMP | Timestamp when the record was last updated    |
| SOURCE_SYSTEM   | STRING    | Source system identifier                       |

## Table: Bz_Licenses
| Column Name     | Data Type | Description                                  |
|-----------------|-----------|----------------------------------------------|
| LICENSE_TYPE    | STRING    | Type of software license                       |
| ASSIGNED_TO_USER_ID | STRING | Identifier of the user assigned the license   |
| START_DATE      | DATE      | License start date                             |
| END_DATE        | DATE      | License end date                               |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when the record was loaded          |
| UPDATE_TIMESTAMP| TIMESTAMP | Timestamp when the record was last updated    |
| SOURCE_SYSTEM   | STRING    | Source system identifier                       |

# 3) Audit Table Design

## Table: Bz_Audit_Log
| Column Name     | Data Type | Description                                  |
|-----------------|-----------|----------------------------------------------|
| RECORD_ID       | STRING    | Unique identifier for the audit record       |
| SOURCE_TABLE    | STRING    | Name of the source table being processed     |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when the record was loaded          |
| PROCESSED_BY    | STRING    | Identifier of the process or user processing the data |
| PROCESSING_TIME | INTEGER   | Time taken to process the record (in seconds)|
| STATUS          | STRING    | Processing status (e.g., SUCCESS, FAILED)     |

# 4) Conceptual Data Model Diagram

```
+----------------+          +----------------+          +----------------+
|   Bz_Users     |          |  Bz_Meetings   |          | Bz_Licenses    |
|----------------|          |----------------|          |----------------|
| USER_NAME      |<---------| HOST_ID        |          | LICENSE_TYPE   |
| EMAIL          |          | MEETING_TOPIC  |          | ASSIGNED_TO_USER_ID (links to Bz_Users) |
| COMPANY        |          | START_TIME     |          | START_DATE     |
| PLAN_TYPE      |          | END_TIME       |          | END_DATE       |
+----------------+          +----------------+          +----------------+
       ^                           ^                           ^
       |                           |                           |
       |                           |                           |
       |                           |                           |
+----------------+          +----------------+          +----------------+
| Bz_Participants|          | Bz_Feature_Usage|         | Bz_Support_Tickets|
|----------------|          |----------------|          |------------------|
| USER_ID        |----------| MEETING_ID     |          | USER_ID          |
| MEETING_ID     |----------| FEATURE_NAME   |          | TICKET_TYPE      |
| JOIN_TIME      |          | USAGE_COUNT    |          | RESOLUTION_STATUS|
| LEAVE_TIME     |          | USAGE_DATE     |          | OPEN_DATE        |
+----------------+          +----------------+          +------------------+
       |
       |
+----------------+
| Bz_Billing_Events|
|------------------|
| USER_ID         |
| EVENT_TYPE      |
| AMOUNT          |
| EVENT_DATE      |
+-----------------+

Legend:
- Arrows indicate logical relationships (foreign key references removed in Bronze layer but conceptually linked)
- All tables prefixed with 'Bz_' indicating Bronze layer
```

---

This Bronze Logical Data Model mirrors the raw schema structure exactly, removes primary and foreign keys as requested, prefixes all tables with 'Bz_', includes metadata columns, classifies PII fields with reasons, and provides a comprehensive audit table design. The conceptual data model diagram visually represents the relationships between the main entities in block format for business understanding.

This model provides a robust foundation for the Bronze layer in the Medallion architecture, ensuring data integrity, traceability, and compliance with data governance standards.