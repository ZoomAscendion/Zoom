_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Updated Conceptual Data Model for Zoom Platform Analytics System with Meeting Recordings functionality
## *Version*: 2
## *Changes*: Added Meeting Recordings entity with related attributes and KPIs
## *Reason*: Enhanced the data model to include recording functionality and storage analytics
## *Updated on*: 
_____________________________________________

# Conceptual Data Model for Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System is designed to capture, analyze, and report on various aspects of video conferencing activities, user engagement, and platform utilization. This system encompasses meeting management, participant tracking, usage analytics, performance monitoring, and recording management to provide comprehensive insights into organizational communication patterns and platform effectiveness.

## 2. List of Entity Names with Descriptions

1. **User** - Represents individuals who use the Zoom platform for meetings and communications
2. **Meeting** - Represents scheduled or instant video conference sessions
3. **Participant** - Represents individuals who join meetings as attendees
4. **Meeting Recordings** - Represents recorded meeting sessions with associated metadata
5. **Device** - Represents hardware/software platforms used to access Zoom services
6. **Account** - Represents organizational accounts that manage users and meetings
7. **Room** - Represents physical or virtual meeting spaces
8. **Chat Message** - Represents text communications during meetings
9. **Screen Share** - Represents screen sharing activities during meetings
10. **Webinar** - Represents large-scale presentation events

## 3. List of Attributes for Each Entity with Descriptions

### User Entity
- **User Name** - Full name of the user
- **Email Address** - Primary email identifier for the user
- **Department** - Organizational department the user belongs to
- **Role** - User's role within the organization
- **License Type** - Type of Zoom license assigned to the user
- **Registration Date** - Date when the user account was created
- **Last Login Date** - Most recent date the user accessed the platform
- **Time Zone** - User's geographical time zone
- **Status** - Current account status (active, inactive, suspended)

### Meeting Entity
- **Meeting Title** - Name or subject of the meeting
- **Meeting Type** - Category of meeting (scheduled, instant, recurring)
- **Start Time** - Scheduled or actual meeting start time
- **End Time** - Scheduled or actual meeting end time
- **Duration** - Total length of the meeting in minutes
- **Meeting Topic** - Brief description of meeting purpose
- **Password Protected** - Indicates if meeting requires password entry
- **Waiting Room Enabled** - Indicates if waiting room feature is active
- **Meeting Status** - Current state of the meeting (scheduled, in-progress, completed, cancelled)

### Participant Entity
- **Join Time** - Time when participant entered the meeting
- **Leave Time** - Time when participant exited the meeting
- **Participation Duration** - Total time spent in the meeting
- **Audio Status** - Indicates if participant used audio (muted/unmuted)
- **Video Status** - Indicates if participant used video (on/off)
- **Connection Quality** - Network connection stability rating
- **Participant Type** - Role in meeting (host, co-host, attendee)
- **Device Used** - Type of device used to join the meeting

### Meeting Recordings Entity
- **Recording Duration** - Total length of the recorded content in minutes
- **File Size** - Storage space occupied by the recording file
- **Storage Location** - Physical or cloud location where recording is stored
- **Recording Type** - Format of recording (audio only, video, screen share)
- **Transcription Status** - Indicates if automatic transcription is available
- **Recording Start Time** - Time when recording began
- **Recording End Time** - Time when recording stopped
- **Access Permissions** - Who can view or download the recording
- **Download Count** - Number of times recording has been downloaded

### Device Entity
- **Device Type** - Category of device (desktop, mobile, tablet, room system)
- **Operating System** - Software platform running on the device
- **Browser Type** - Web browser used for web-based access
- **App Version** - Version of Zoom application installed
- **Hardware Specifications** - Technical capabilities of the device
- **Network Type** - Connection method (WiFi, ethernet, cellular)

### Account Entity
- **Account Name** - Organization or company name
- **Account Type** - Category of account (basic, pro, business, enterprise)
- **Subscription Start Date** - When the account subscription began
- **License Count** - Number of user licenses allocated
- **Storage Quota** - Maximum storage space allocated for recordings
- **Admin Contact** - Primary administrator contact information

### Room Entity
- **Room Name** - Identifier for the meeting space
- **Room Capacity** - Maximum number of participants the room can accommodate
- **Location** - Physical address or virtual space identifier
- **Equipment Available** - Audio/video equipment present in the room
- **Booking Status** - Current reservation state of the room

### Chat Message Entity
- **Message Content** - Text content of the chat message
- **Timestamp** - Time when message was sent
- **Message Type** - Category of message (public, private, file share)
- **Character Count** - Length of the message text

### Screen Share Entity
- **Share Start Time** - When screen sharing began
- **Share End Time** - When screen sharing ended
- **Share Duration** - Total time screen was shared
- **Content Type** - Type of content shared (application, desktop, document)

### Webinar Entity
- **Webinar Title** - Name of the webinar event
- **Registration Required** - Indicates if attendees must register
- **Maximum Attendees** - Capacity limit for the webinar
- **Actual Attendees** - Number of people who actually attended
- **Q&A Enabled** - Indicates if question and answer feature is active
- **Poll Count** - Number of polls conducted during webinar

## 4. KPI List

1. **Total Meeting Hours** - Sum of all meeting durations across the platform
2. **Average Meeting Duration** - Mean length of meetings conducted
3. **User Adoption Rate** - Percentage of licensed users actively using the platform
4. **Meeting Attendance Rate** - Percentage of invited participants who join meetings
5. **Audio Quality Score** - Average rating of audio connection quality
6. **Video Quality Score** - Average rating of video connection quality
7. **Platform Uptime** - Percentage of time the platform is available and functional
8. **Peak Concurrent Users** - Maximum number of simultaneous users on the platform
9. **Total Recording Storage Used** - Amount of storage space consumed by meeting recordings
10. **Average Recording Duration** - Mean length of recorded meeting sessions
11. **Recording Adoption Rate** - Percentage of meetings that are recorded
12. **Storage Utilization Rate** - Percentage of allocated storage space currently in use
13. **Recording Access Frequency** - Average number of times recordings are viewed or downloaded
14. **Transcription Accuracy Rate** - Percentage of recordings with successful automatic transcription

## 5. Conceptual Data Model Diagram in Tabular Form

| Primary Entity | Related Entity | Relationship Key Field | Relationship Type |
|----------------|----------------|----------------------|-------------------|
| Account | User | Account Number | One-to-Many |
| User | Meeting | User Email | One-to-Many (as Host) |
| Meeting | Participant | Meeting Number | One-to-Many |
| Meeting | Meeting Recordings | Meeting Number | One-to-Many |
| User | Participant | User Email | One-to-Many |
| Participant | Device | Device Identifier | Many-to-One |
| Meeting | Room | Room Number | Many-to-One |
| Meeting | Chat Message | Meeting Number | One-to-Many |
| Meeting | Screen Share | Meeting Number | One-to-Many |
| User | Webinar | User Email | One-to-Many (as Host) |
| Webinar | Participant | Webinar Number | One-to-Many |
| Account | Room | Account Number | One-to-Many |
| Meeting Recordings | User | User Email | Many-to-One (Owner) |

## 6. Common Data Elements in Report Requirements

1. **User Email** - Appears across User, Participant, and Meeting entities for user identification
2. **Meeting Number** - Common identifier linking Meeting, Participant, Chat Message, Screen Share, and Meeting Recordings
3. **Timestamp Fields** - Various time-related attributes (Start Time, End Time, Join Time, Leave Time) used across multiple entities
4. **Duration Fields** - Time duration measurements found in Meeting, Participant, Screen Share, and Meeting Recordings entities
5. **Account Number** - Organizational identifier present in Account, User, and Room entities
6. **Device Identifier** - Technical specification data shared between Device and Participant entities
7. **Status Fields** - State indicators (Meeting Status, User Status, Booking Status) across various entities
8. **Quality Metrics** - Performance measurements (Connection Quality, Audio Quality, Video Quality) spanning multiple entities
9. **Content Type Fields** - Classification attributes for different types of shared content and recordings
10. **Permission and Access Fields** - Security and access control attributes present in multiple entities for governance and compliance reporting