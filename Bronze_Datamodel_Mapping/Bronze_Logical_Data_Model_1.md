_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# 1. PII Classification with Reasons

| Column Name       | Table           | PII Classification | Reason                                                                                  |
|-------------------|-----------------|--------------------|-----------------------------------------------------------------------------------------|
| USER_NAME         | Bz_Users        | Yes                | Identifies an individual user directly                                                  |
| EMAIL             | Bz_Users        | Yes                | Personal email address, directly identifies an individual                               |
| COMPANY           | Bz_Users        | Potentially Yes     | May identify the organization user belongs to; considered sensitive in some contexts    |
| HOST_NAME         | Bz_Meetings     | Yes                | Identifies the host user of the meeting                                                 |
| PARTICIPANT_NAME  | Bz_Attendees    | Yes                | Identifies individual participants                                                      |
| ASSIGNED_AGENT    | Bz_SupportTickets| Yes                | Identifies the support agent handling the ticket                                       |
| ASSIGNED_USER_NAME| Bz_Licenses     | Yes                | Identifies the user assigned to the license                                            |

Other fields such as dates, counts, durations, event types, and statuses are not PII as they do not directly identify individuals.

# 2. Bronze Layer Logical Model

## Table: Bz_Users
**Description:** Contains user profile information for Zoom platform users.

| Column Name       | Data Type        | Business Description                          |
|-------------------|------------------|-----------------------------------------------|
| USER_NAME         | VARCHAR(255)     | User's full name or username                   |
| EMAIL             | VARCHAR(320)     | User's email address                           |
| PLAN_TYPE         | VARCHAR(50)      | Subscription plan type of the user             |
| COMPANY           | VARCHAR(255)     | Company or organization the user belongs to    |
| REGISTRATION_DATE | TIMESTAMP        | Date and time when the user registered         |
| load_timestamp    | TIMESTAMP        | Timestamp when the record was loaded into Bronze layer |
| update_timestamp  | TIMESTAMP        | Timestamp when the record was last updated     |
| source_system     | VARCHAR(100)     | Source system from which data was ingested     |

---

## Table: Bz_Meetings
**Description:** Contains details of meetings hosted on the Zoom platform.

| Column Name       | Data Type        | Business Description                          |
|-------------------|------------------|-----------------------------------------------|
| MEETING_TITLE     | VARCHAR(255)     | Title or topic of the meeting                  |
| DURATION_MINUTES  | INTEGER          | Duration of the meeting in minutes             |
| START_TIME        | TIMESTAMP        | Meeting start date and time                     |
| END_TIME          | TIMESTAMP        | Meeting end date and time                       |
| MEETING_TYPE      | VARCHAR(50)      | Type of meeting (e.g., scheduled, instant)     |
| HOST_NAME         | VARCHAR(255)     | Name of the meeting host                        |
| load_timestamp    | TIMESTAMP        | Timestamp when the record was loaded into Bronze layer |
| update_timestamp  | TIMESTAMP        | Timestamp when the record was last updated     |
| source_system     | VARCHAR(100)     | Source system from which data was ingested     |

---

## Table: Bz_Attendees
**Description:** Contains participant attendance details for meetings.

| Column Name       | Data Type        | Business Description                          |
|-------------------|------------------|-----------------------------------------------|
| PARTICIPANT_NAME  | VARCHAR(255)     | Name of the participant                        |
| JOIN_TIME         | TIMESTAMP        | Timestamp when participant joined the meeting |
| LEAVE_TIME        | TIMESTAMP        | Timestamp when participant left the meeting   |
| ATTENDANCE_DURATION| INTEGER         | Duration participant attended in minutes      |
| load_timestamp    | TIMESTAMP        | Timestamp when the record was loaded into Bronze layer |
| update_timestamp  | TIMESTAMP        | Timestamp when the record was last updated     |
| source_system     | VARCHAR(100)     | Source system from which data was ingested     |

---

## Table: Bz_FeatureUsage
**Description:** Tracks usage statistics of Zoom platform features.

| Column Name       | Data Type        | Business Description                          |
|-------------------|------------------|-----------------------------------------------|
| FEATURE_NAME      | VARCHAR(255)     | Name of the feature used                       |
| USAGE_COUNT       | INTEGER          | Number of times the feature was used           |
| USAGE_DURATION   | INTEGER          | Duration of feature usage in minutes           |
| USAGE_DATE       | DATE             | Date when the feature usage was recorded       |
| load_timestamp    | TIMESTAMP        | Timestamp when the record was loaded into Bronze layer |
| update_timestamp  | TIMESTAMP        | Timestamp when the record was last updated     |
| source_system     | VARCHAR(100)     | Source system from which data was ingested     |

---

## Table: Bz_SupportTickets
**Description:** Contains support ticket details raised by users.

| Column Name       | Data Type        | Business Description                          |
|-------------------|------------------|-----------------------------------------------|
| TICKET_TYPE       | VARCHAR(100)     | Type/category of the support ticket            |
| ISSUE_DESCRIPTION | VARCHAR(1000)    | Description of the issue reported               |
| PRIORITY_LEVEL    | VARCHAR(50)      | Priority level of the ticket (e.g., High, Low) |
| RESOLUTION_STATUS | VARCHAR(50)      | Current resolution status of the ticket         |
| OPEN_DATE         | TIMESTAMP        | Date and time when the ticket was opened        |
| CLOSE_DATE        | TIMESTAMP        | Date and time when the ticket was closed        |
| ASSIGNED_AGENT    | VARCHAR(255)     | Name of the agent assigned to the ticket        |
| load_timestamp    | TIMESTAMP        | Timestamp when the record was loaded into Bronze layer |
| update_timestamp  | TIMESTAMP        | Timestamp when the record was last updated     |
| source_system     | VARCHAR(100)     | Source system from which data was ingested     |

---

## Table: Bz_BillingEvents
**Description:** Contains billing event transactions for users.

| Column Name       | Data Type        | Business Description                          |
|-------------------|------------------|-----------------------------------------------|
| EVENT_TYPE        | VARCHAR(100)     | Type of billing event (e.g., payment, refund) |
| AMOUNT            | DECIMAL(18,2)    | Monetary amount involved in the event          |
| CURRENCY          | VARCHAR(10)      | Currency code of the amount (e.g., USD)        |
| TRANSACTION_DATE  | TIMESTAMP        | Date and time of the billing event              |
| PAYMENT_METHOD    | VARCHAR(100)     | Method of payment used (e.g., credit card)      |
| load_timestamp    | TIMESTAMP        | Timestamp when the record was loaded into Bronze layer |
| update_timestamp  | TIMESTAMP        | Timestamp when the record was last updated     |
| source_system     | VARCHAR(100)     | Source system from which data was ingested     |

---

## Table: Bz_Licenses
**Description:** Contains license information assigned to users.

| Column Name       | Data Type        | Business Description                          |
|-------------------|------------------|-----------------------------------------------|
| LICENSE_TYPE      | VARCHAR(100)     | Type of license (e.g., Pro, Business)          |
| START_DATE        | DATE             | License start date                              |
| END_DATE          | DATE             | License end date                                |
| LICENSE_STATUS    | VARCHAR(50)      | Current status of the license (e.g., Active)   |
| ASSIGNED_USER_NAME| VARCHAR(255)     | User name to whom the license is assigned      |
| load_timestamp    | TIMESTAMP        | Timestamp when the record was loaded into Bronze layer |
| update_timestamp  | TIMESTAMP        | Timestamp when the record was last updated     |
| source_system     | VARCHAR(100)     | Source system from which data was ingested     |

---

## Table: Bz_Webinars
**Description:** Contains webinar event details.

| Column Name       | Data Type        | Business Description                          |
|-------------------|------------------|-----------------------------------------------|
| WEBINAR_TOPIC     | VARCHAR(255)     | Topic or title of the webinar                   |
| START_TIME        | TIMESTAMP        | Webinar start date and time                      |
| END_TIME          | TIMESTAMP        | Webinar end date and time                        |
| REGISTRANTS       | INTEGER          | Number of registrants for the webinar           |
| load_timestamp    | TIMESTAMP        | Timestamp when the record was loaded into Bronze layer |
| update_timestamp  | TIMESTAMP        | Timestamp when the record was last updated     |
| source_system     | VARCHAR(100)     | Source system from which data was ingested     |

# 3. Audit Table Design

## Table: Bz_Audit
**Description:** Tracks data load and processing status for Bronze layer tables.

| Column Name       | Data Type        | Business Description                          |
|-------------------|------------------|-----------------------------------------------|
| RECORD_ID         | VARCHAR(36)      | Unique identifier for the audit record (UUID)|
| SOURCE_TABLE      | VARCHAR(100)     | Name of the source table being processed      |
| LOAD_TIMESTAMP    | TIMESTAMP        | Timestamp when the data was loaded             |
| PROCESSED_BY      | VARCHAR(100)     | Identifier of the process or user that processed the data |
| PROCESSING_TIME   | INTEGER          | Time taken to process the data in seconds     |
| STATUS            | VARCHAR(50)      | Status of the processing (e.g., Success, Failed) |

# 4. Conceptual Data Model Diagram (Block Format)

```
+----------------+       +----------------+       +----------------+
|    Bz_Users    |<----->|   Bz_Meetings  |<----->|  Bz_Attendees  |
|----------------|       |----------------|       |----------------|
| USER_NAME (PK) |       | MEETING_TITLE  |       | PARTICIPANT_NAME|
| EMAIL          |       | START_TIME     |       | JOIN_TIME      |
| PLAN_TYPE      |       | END_TIME       |       | LEAVE_TIME     |
| COMPANY        |       | DURATION_MIN   |       | ATTENDANCE_DUR |
| REGISTRATION_DT|       | MEETING_TYPE   |       +----------------+
+----------------+       | HOST_NAME      |
                         +----------------+

+----------------+       +----------------+       +----------------+
| Bz_FeatureUsage|       | Bz_SupportTickets|      | Bz_BillingEvents|
|----------------|       |----------------|       |----------------|
| FEATURE_NAME   |       | TICKET_TYPE    |       | EVENT_TYPE     |
| USAGE_COUNT    |       | ISSUE_DESC     |       | AMOUNT        |
| USAGE_DURATION |       | PRIORITY_LEVEL |       | CURRENCY      |
| USAGE_DATE     |       | RESOLUTION_STAT|       | TRANSACTION_DT|
+----------------+       | OPEN_DATE      |       | PAYMENT_METHOD|
                         | CLOSE_DATE     |       +----------------+
                         | ASSIGNED_AGENT |
                         +----------------+

+----------------+
|   Bz_Licenses  |
|----------------|
| LICENSE_TYPE   |
| START_DATE     |
| END_DATE       |
| LICENSE_STATUS |
| ASSIGNED_USER  |
+----------------+

+----------------+
|   Bz_Webinars  |
|----------------|
| WEBINAR_TOPIC  |
| START_TIME     |
| END_TIME       |
| REGISTRANTS    |
+----------------+

+----------------+
|    Bz_Audit    |
|----------------|
| RECORD_ID      |
| SOURCE_TABLE   |
| LOAD_TIMESTAMP |
| PROCESSED_BY   |
| PROCESSING_TIME|
| STATUS        |
+----------------+
```

**Relationships:**

- Bz_Users relates to Bz_Meetings via HOST_NAME (host user)
- Bz_Meetings relates to Bz_Attendees via meeting participation (no FK in Bronze, logical relationship)
- Bz_Users relates to Bz_Licenses via ASSIGNED_USER_NAME
- Bz_Users relates to Bz_SupportTickets via ASSIGNED_AGENT (support agent user)
- Bz_Users relates to Bz_BillingEvents logically by user context (not included in Bronze keys)
- Bz_Meetings and Bz_Webinars are separate event entities with similar time attributes

---

This completes the Bronze Layer Logical Data Model for the Zoom Platform Analytics System as per the requirements.