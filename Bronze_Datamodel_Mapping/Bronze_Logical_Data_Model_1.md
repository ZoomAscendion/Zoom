# Bronze Logical Data Model for Zoom Platform Analytics System

---

## Metadata
- **Author**: AAVA
- **Created on**: 
- **Description**: Bronze layer logical data model for Zoom Platform Analytics System based on raw schema structure and conceptual data model.
- **Version**: 1
- **Updated on**: 

---

## 1. PII Classification
| Column Name | Reason for PII Classification |
|-------------|-------------------------------|
| USER_NAME | Identifies individual user by name |
| EMAIL | Personal email address of user |
| COMPANY | Company name can be sensitive business info |
| HOST_ID | Refers to user hosting meetings (PII indirectly) |
| ASSIGNED_TO_USER_ID | Refers to user assigned licenses (PII indirectly) |
| USER_ID | Unique user identifier (PII) |

---

## 2. Bronze Layer Logical Model

### 2.1 Bz_BILLING_EVENTS
**Description**: Captures all billing and financial transaction events.
| Column Name | Description | Data Type |
|-------------|-------------|-----------|
| EVENT_TYPE | Type of billing event (Subscription