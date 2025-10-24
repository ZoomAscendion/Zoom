_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Updated conceptual data model for Zoom Platform Analytics System with Meeting Participants entity
## *Version*: 2
## *Updated on*: 
## *Changes*: Added Meeting Participants entity with participant-level attributes and engagement metrics
## *Reason*: Enhanced participant tracking and engagement analysis capabilities
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System provides comprehensive analytics and reporting capabilities for video conferencing and collaboration activities. The system captures meeting data, participant interactions, usage patterns, and performance metrics to enable data-driven insights for organizational communication and collaboration effectiveness. This updated model includes enhanced participant-level tracking and engagement analysis.

## 2. List of Entity Names with Descriptions

1. **User** - Represents individuals who use the Zoom platform for meetings and collaboration
2. **Meeting** - Represents scheduled or instant video conference sessions on the Zoom platform
3. **Meeting Participants** - Represents individual participants within specific meetings with detailed engagement tracking
4. **Account** - Represents organizational accounts that manage users and meetings
5. **Device** - Represents hardware devices used to access Zoom meetings
6. **Recording** - Represents recorded meeting sessions and their metadata
7. **Chat Message** - Represents text messages exchanged during meetings
8. **Screen Share Session** - Represents screen sharing activities during meetings
9. **Breakout Room** - Represents smaller meeting rooms created within main meetings
10. **Webinar** - Represents large-scale presentation sessions with attendees

## 3. List of Attributes for Each Entity with Descriptions

### User
1. **User Name** - Full name of the user
2. **Email Address** - Primary email address for user identification
3. **Department** - Organizational department or division
4. **Job Title** - Professional role or position
5. **License Type** - Type of Zoom license assigned to user
6. **Registration Date** - Date when user account was created
7. **Last Login Date** - Most recent platform access date
8. **Time Zone** - User's geographical time zone
9. **Status** - Current account status (active, inactive, suspended)

### Meeting
1. **Meeting Topic** - Subject or title of the meeting
2. **Start Time** - Scheduled or actual meeting start time
3. **End Time** - Actual meeting end time
4. **Duration** - Total meeting length in minutes
5. **Meeting Type** - Category (scheduled, instant, recurring, webinar)
6. **Host Name** - Name of the meeting organizer
7. **Participant Count** - Total number of attendees
8. **Recording Status** - Whether meeting was recorded
9. **Password Protected** - Security setting indicator
10. **Waiting Room Enabled** - Security feature status

### Meeting Participants
1. **Participant Name** - Full name of the meeting participant
2. **Join Time** - Timestamp when participant joined the meeting
3. **Leave Time** - Timestamp when participant left the meeting
4. **Duration in Meeting** - Total time spent in the meeting by participant
5. **Participant Role** - Role in meeting (host, co-host, attendee, panelist)
6. **Audio Status** - Microphone usage during meeting
7. **Video Status** - Camera usage during meeting
8. **Chat Activity Count** - Number of chat messages sent
9. **Screen Share Duration** - Time spent sharing screen
10. **Attention Score** - Engagement level indicator

### Account
1. **Account Name** - Organization or company name
2. **Account Type** - Subscription tier (basic, pro, business, enterprise)
3. **Subscription Start Date** - Account activation date
4. **License Count** - Number of licensed users
5. **Storage Quota** - Allocated cloud storage limit
6. **Admin Contact** - Primary administrator information
7. **Billing Address** - Account billing location
8. **Feature Set** - Available platform features

### Device
1. **Device Type** - Category (desktop, mobile, tablet, room system)
2. **Operating System** - Device OS and version
3. **Zoom Client Version** - Application version used
4. **Network Type** - Connection method (WiFi, ethernet, cellular)
5. **Audio Device** - Microphone and speaker information
6. **Video Device** - Camera specifications
7. **Performance Score** - Device performance rating

### Recording
1. **Recording Name** - Title or identifier for recorded content
2. **File Size** - Storage space consumed
3. **Recording Duration** - Length of recorded content
4. **File Format** - Video/audio file type
5. **Storage Location** - Cloud or local storage path
6. **Download Count** - Number of times accessed
7. **Sharing Status** - Access permissions and sharing settings
8. **Transcription Available** - Automatic transcription status

### Chat Message
1. **Message Content** - Text content of the message
2. **Sender Name** - Name of message author
3. **Timestamp** - When message was sent
4. **Message Type** - Category (public, private, file share)
5. **Recipient** - Target audience for private messages
6. **File Attachment** - Associated files or documents

### Screen Share Session
1. **Presenter Name** - Name of person sharing screen
2. **Start Time** - When screen sharing began
3. **End Time** - When screen sharing ended
4. **Duration** - Total screen sharing time
5. **Application Shared** - Specific app or desktop shared
6. **Viewer Count** - Number of participants viewing

### Breakout Room
1. **Room Name** - Identifier for breakout room
2. **Participant Count** - Number of attendees in room
3. **Start Time** - Room creation time
4. **End Time** - Room closure time
5. **Duration** - Total room active time
6. **Host Assignment** - Designated room facilitator

### Webinar
1. **Webinar Title** - Name or topic of webinar
2. **Registration Required** - Whether pre-registration needed
3. **Attendee Limit** - Maximum number of participants
4. **Actual Attendance** - Number of people who joined
5. **Registration Count** - Total registrations received
6. **Q&A Session** - Question and answer feature usage
7. **Poll Count** - Number of polls conducted
8. **Panelist Count** - Number of presenters

## 4. KPI List

1. **Total Meeting Count** - Number of meetings conducted in a period
2. **Average Meeting Duration** - Mean length of meetings
3. **Total Meeting Minutes** - Cumulative meeting time
4. **User Adoption Rate** - Percentage of licensed users actively using platform
5. **Meeting Attendance Rate** - Average participant attendance percentage
6. **Recording Usage Rate** - Percentage of meetings recorded
7. **Screen Share Utilization** - Frequency of screen sharing feature usage
8. **Chat Engagement Rate** - Average messages per meeting
9. **Device Performance Score** - Average technical performance rating
10. **Storage Utilization Rate** - Percentage of allocated storage used
11. **Average Meeting Duration per Participant** - Mean time individual participants spend in meetings
12. **Participant Engagement Rate** - Percentage of active participation (audio, video, chat, screen share)

## 5. Conceptual Data Model Diagram in Tabular Form

| Source Entity | Target Entity | Relationship Key Field | Relationship Type |
|---------------|---------------|----------------------|-------------------|
| Account | User | Account Name | One-to-Many |
| User | Meeting | Host Name | One-to-Many |
| Meeting | Meeting Participants | Meeting Topic + Start Time | One-to-Many |
| User | Meeting Participants | Participant Name | One-to-Many |
| Meeting | Recording | Meeting Topic + Start Time | One-to-Many |
| Meeting | Chat Message | Meeting Topic + Start Time | One-to-Many |
| User | Chat Message | Sender Name | One-to-Many |
| Meeting | Screen Share Session | Meeting Topic + Start Time | One-to-Many |
| Meeting Participants | Screen Share Session | Participant Name | One-to-Many |
| User | Device | User Name | One-to-Many |
| Meeting | Breakout Room | Meeting Topic + Start Time | One-to-Many |
| Meeting Participants | Breakout Room | Participant Name | Many-to-Many |
| Account | Webinar | Account Name | One-to-Many |
| User | Webinar | Host Name | One-to-Many |

## 6. Common Data Elements in Report Requirements

1. **Meeting Topic** - Used across meeting, recording, and participant reports
2. **User Name/Participant Name** - Common identifier across user and participant entities
3. **Start Time/End Time** - Temporal elements used in meeting, recording, and session tracking
4. **Duration** - Time-based metric used in meetings, recordings, and participant sessions
5. **Host Name** - Meeting organizer information used in multiple report types
6. **Participant Count** - Attendance metric used in meeting and engagement reports
7. **Account Name** - Organizational identifier used across multiple entities
8. **Device Type** - Technical specification used in performance and usage reports
9. **Recording Status** - Content availability indicator used in meeting and storage reports
10. **Chat Activity** - Engagement metric used in participant and meeting analysis
11. **Join Time/Leave Time** - Participant-specific temporal data for engagement analysis
12. **Participant Role** - Role-based data for access and engagement reporting
13. **Attention Score** - Engagement measurement for participant behavior analysis
14. **Audio/Video Status** - Technical engagement indicators for participant activity