# Bronze Layer Logical Data Model for Zoom Platform Analytics System

---

## Metadata
- **Author:** AAVA
- **Version:** 1
- **Date:** 2024-06-15
- **Schema:** bronze_schema

---

## 1. PII Classification
| Column Name       | Table Name          | Reason for PII Classification                         |
|-------------------|---------------------|-------------------------------------------------------|
| USER_NAME         | Bz_USERS            | Identifies individual user by name                    |
| EMAIL             | Bz_USERS            | Email address is personal contact information          |
| COMPANY           | Bz_USERS            | Company name may identify employer or affiliation      |
| HOST_NAME         | Bz_MEETINGS         | Identifies meeting host person                          |
| PARTICIPANT_NAME   | Bz_PARTICIPANTS     | Identifies meeting participant                          |
| ASSIGNED_AGENT    | Bz_SUPPORT_TICKETS   | Identifies support agent handling ticket                |
| ASSIGNED_USER_NAME | Bz_LICENSES          | Identifies user assigned license                        |

---

## 2. Bronze Layer Logical Data Model

### Table: Bz_BILLING_EVENTS
| Column Name    | Data Type | Description                                      |
|----------------|-----------|--------------------------------------------------|
| EVENT_TYPE     | STRING    | Type of billing event (e.g., payment, refund)    |
| AMOUNT        | NUMBER    | Monetary amount involved in the event             |
| CURRENCY      | STRING    | Currency code of the amount (e.g., USD)           |
| TRANSACTION_DATE | TIMESTAMP | Date and time of the billing transaction          |
| LOAD_TIMESTAMP | TIMESTAMP | Timestamp when data was loaded into Bronze layer  |
| UPDATE_TIMESTAMP | TIMESTAMP | Timestamp when data was last updated               |
| SOURCE_SYSTEM  | STRING    | Source system from which data originated           |

### Table: Bz_FEATURE_USAGE
| Column Name    | Data Type | Description                                      |
|----------------|-----------|--------------------------------------------------|
| MEETING_ID     | STRING    | Identifier of the meeting where feature was used  |
| FEATURE_NAME   | STRING    | Name of the feature used                           |
| USAGE_COUNT   | INTEGER   | Number of times the feature was used               |
| USAGE_DURATION | INTEGER   | Duration in seconds the feature was used          |
| USAGE_DATE    | DATE      | Date when the feature usage occurred               |
| LOAD_TIMESTAMP | TIMESTAMP | Timestamp when data was loaded into Bronze layer  |
| UPDATE_TIMESTAMP | TIMESTAMP | Timestamp when data was last updated               |
| SOURCE_SYSTEM  | STRING    | Source system from which data originated           |

### Table: Bz_LICENSES
| Column Name       | Data Type | Description                                      |
|-------------------|-----------|--------------------------------------------------|
| LICENSE_TYPE      | STRING    | Type of license assigned                          |
| START_DATE        | DATE      | License start date                                |
| END_DATE          | DATE      | License end date                                  |
| LICENSE_STATUS    | STRING    | Current status of the license (active, expired)  |
| LOAD_TIMESTAMP    | TIMESTAMP | Timestamp when data was loaded into Bronze layer  |
| UPDATE_TIMESTAMP  | TIMESTAMP | Timestamp when data was last updated               |
| SOURCE_SYSTEM     | STRING    | Source system from which data originated           |

### Table: Bz_MEETINGS
| Column Name      | Data Type | Description                                      |
|------------------|-----------|--------------------------------------------------|
| MEETING_TOPIC    | STRING    | Title or topic of the meeting                     |
| DURATION_MINUTES | INTEGER   | Duration of the meeting in minutes                |
| START_TIME       | TIMESTAMP | Meeting start time                                |
| END_TIME         | TIMESTAMP | Meeting end time                                  |
| MEETING_TYPE     | STRING    | Type of meeting (e.g., webinar, team meeting)    |
| HOST_NAME        | STRING    | Name of the meeting host                           |
| LOAD_TIMESTAMP   | TIMESTAMP | Timestamp when data was loaded into Bronze layer  |
| UPDATE_TIMESTAMP | TIMESTAMP | Timestamp when data was last updated               |
| SOURCE_SYSTEM    | STRING    | Source system from which data originated           |

### Table: Bz_PARTICIPANTS
| Column Name      | Data Type | Description                                      |
|------------------|-----------|--------------------------------------------------|
| PARTICIPANT_NAME | STRING    | Name of the participant                           |
| JOIN_TIME       | TIMESTAMP | Time participant joined the meeting               |
| LEAVE_TIME      | TIMESTAMP | Time participant left the meeting                 |
| ATTENDANCE_DURATION | INTEGER | Duration participant attended in seconds          |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when data was loaded into Bronze layer  |
| UPDATE_TIMESTAMP | TIMESTAMP | Timestamp when data was last updated               |
| SOURCE_SYSTEM   | STRING    | Source system from which data originated           |

### Table: Bz_SUPPORT_TICKETS
| Column Name       | Data Type | Description                                      |
|-------------------|-----------|--------------------------------------------------|
| TICKET_TYPE       | STRING    | Type/category of support ticket                   |
| ISSUE_DESCRIPTION | STRING    | Description of the issue reported                  |
| PRIORITY_LEVEL    | STRING    | Priority level of the ticket (e.g., high, low)    |
| RESOLUTION_STATUS | STRING    | Current resolution status of the ticket            |
| OPEN_DATE         | DATE      | Date when the ticket was opened                    |
| CLOSE_DATE        | DATE      | Date when the ticket was closed                    |
| ASSIGNED_AGENT    | STRING    | Name of the agent assigned to the ticket           |
| LOAD_TIMESTAMP    | TIMESTAMP | Timestamp when data was loaded into Bronze layer  |
| UPDATE_TIMESTAMP  | TIMESTAMP | Timestamp when data was last updated               |
| SOURCE_SYSTEM     | STRING    | Source system from which data originated           |

### Table: Bz_USERS
| Column Name      | Data Type | Description                                      |
|------------------|-----------|--------------------------------------------------|
| USER_NAME        | STRING    | Name of the user                                 |
| EMAIL            | STRING    | Email address of the user                        |
| COMPANY          | STRING    | Company the user belongs to                      |
| PLAN_TYPE        | STRING    | Subscription plan type of the user               |
| REGISTRATION_DATE | DATE     | Date when the user registered                     |
| LOAD_TIMESTAMP   | TIMESTAMP | Timestamp when data was loaded into Bronze layer  |
| UPDATE_TIMESTAMP | TIMESTAMP | Timestamp when data was last updated               |
| SOURCE_SYSTEM    | STRING    | Source system from which data originated           |

### Table: Bz_WEBINARS
| Column Name      | Data Type | Description                                      |
|------------------|-----------|--------------------------------------------------|
| WEBINAR_TOPIC    | STRING    | Topic of the webinar                             |
| START_TIME       | TIMESTAMP | Webinar start time                               |
| END_TIME         | TIMESTAMP | Webinar end time                                 |
| REGISTRANTS      | INTEGER   | Number of registrants for the webinar            |
| HOST_NAME        | STRING    | Name of the webinar host                          |
| LOAD_TIMESTAMP   | TIMESTAMP | Timestamp when data was loaded into Bronze layer  |
| UPDATE_TIMESTAMP | TIMESTAMP | Timestamp when data was last updated               |
| SOURCE_SYSTEM    | STRING    | Source system from which data originated           |

---

## 3. Audit Table Design

### Table: Bz_AUDIT
| Column Name     | Data Type | Description                                      |
|-----------------|-----------|--------------------------------------------------|
| RECORD_ID       | STRING    | Unique identifier for the audit record           |
| SOURCE_TABLE    | STRING    | Name of the source table being audited           |
| LOAD_TIMESTAMP  | TIMESTAMP | Timestamp when the record was loaded             |
| PROCESSED_BY    | STRING    | Identifier of the process or user who processed  |
| PROCESSING_TIME | INTEGER   | Time taken to process the record in seconds      |
| STATUS         | STRING    | Status of the processing (e.g., success, failed) |

---

## 4. Conceptual Data Model Diagram (Block Format)

```
[Users] <--> [Meetings] <--> [Participants]
   |             |               |
   |             |               |
   v             v               v
[Licenses]   [Feature Usage]   [Support Tickets]

[Billing Events]

[Webinars] <--> [Users]
```

- Users linked to Meetings via Host and Participants via User
- Meetings linked to Feature Usage
- Users linked to Support Tickets
- Users linked to Billing Events
- Users linked to Licenses
- Webinars linked to Users via Host

---

*End of Bronze Layer Logical Data Model Document*