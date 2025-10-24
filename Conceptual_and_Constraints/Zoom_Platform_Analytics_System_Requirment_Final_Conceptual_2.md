_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System with enhanced meeting participation tracking
## *Version*: 2
## *Updated on*: 
## *Changes*: Added Meeting Participants entity, enhanced Meetings entity with additional attributes, and included Average Participation Rate KPI
## *Reason*: User requested to add participant tracking capabilities and meeting duration analysis
_____________________________________________

# Conceptual Data Model for Zoom Platform Analytics System

## 1. Domain Overview

The Zoom Platform Analytics System is designed to provide comprehensive insights into meeting activities, user engagement, and platform utilization. The system captures data related to meetings, participants, user activities, and performance metrics to enable detailed analytics and reporting for organizational decision-making.

## 2. List of Entity Names with Descriptions

1. **Users** - Represents individuals who use the Zoom platform, including hosts and attendees
2. **Meetings** - Represents scheduled or instant meetings conducted on the Zoom platform with enhanced duration tracking
3. **Meeting Participants** - Represents individuals who join meetings with detailed participation tracking
4. **Recordings** - Represents recorded meeting sessions and their metadata
5. **Webinars** - Represents webinar sessions conducted on the platform
6. **Chat Messages** - Represents messages exchanged during meetings or webinars
7. **Screen Shares** - Represents screen sharing activities during meetings
8. **Breakout Rooms** - Represents breakout room sessions within meetings
9. **Polls** - Represents polls conducted during meetings or webinars
10. **Reports** - Represents various analytical reports generated from the system

## 3. List of Attributes for Each Entity

### 3.1 Users
- **User Name** - Full name of the user
- **Email Address** - Primary email address for the user account
- **Department** - Organizational department the user belongs to
- **Role** - User role within the organization (Admin, Host, Participant)
- **Account Type** - Type of Zoom account (Basic, Pro, Business)
- **License Type** - Specific license assigned to the user
- **Registration Date** - Date when the user account was created
- **Last Login Date** - Most recent login timestamp
- **Status** - Current account status (Active, Inactive, Suspended)
- **Time Zone** - User's configured time zone

### 3.2 Meetings
- **Meeting Title** - Name or title of the meeting
- **Meeting Topic** - Specific topic or agenda of the meeting
- **Host Name** - Name of the meeting host
- **Start Time** - Scheduled or actual start time of the meeting
- **End Time** - Scheduled or actual end time of the meeting
- **Scheduled Duration** - Originally planned duration of the meeting
- **Actual Duration** - Real duration the meeting lasted
- **Meeting Type** - Type of meeting (Scheduled, Instant, Recurring)
- **Participant Count** - Total number of participants who joined
- **Maximum Concurrent Participants** - Peak number of simultaneous participants
- **Recording Status** - Whether the meeting was recorded
- **Password Protected** - Whether the meeting required a password
- **Waiting Room Enabled** - Whether waiting room feature was used
- **Meeting Status** - Current status (Scheduled, In Progress, Completed, Cancelled)

### 3.3 Meeting Participants
- **Participant Name** - Full name of the meeting participant
- **Email Address** - Email address of the participant
- **Join Time** - Timestamp when participant joined the meeting
- **Leave Time** - Timestamp when participant left the meeting
- **Participation Duration** - Total time the participant spent in the meeting
- **Connection Type** - How participant connected (Computer Audio, Phone, VoIP)
- **Device Type** - Type of device used (Desktop, Mobile, Tablet)
- **Location** - Geographic location of the participant
- **Network Quality** - Quality of network connection during participation
- **Camera Status** - Whether participant had camera on/off
- **Microphone Status** - Whether participant had microphone on/off
- **Screen Share Activity** - Whether participant shared screen
- **Chat Participation** - Whether participant used chat feature

### 3.4 Recordings
- **Recording Name** - Title or name of the recording
- **File Size** - Size of the recording file
- **Duration** - Length of the recording
- **Recording Type** - Type of recording (Cloud, Local)
- **File Format** - Format of the recording file (MP4, M4A)
- **Creation Date** - Date when recording was created
- **Download Count** - Number of times recording was downloaded
- **View Count** - Number of times recording was viewed
- **Storage Location** - Where the recording is stored
- **Sharing Status** - Whether recording is shared publicly or privately

### 3.5 Webinars
- **Webinar Title** - Name or title of the webinar
- **Host Name** - Name of the webinar host
- **Start Time** - Scheduled start time of the webinar
- **End Time** - Scheduled end time of the webinar
- **Registration Required** - Whether registration was required
- **Attendee Count** - Number of attendees who joined
- **Registration Count** - Number of people who registered
- **Q&A Session** - Whether Q&A session was conducted
- **Poll Count** - Number of polls conducted during webinar
- **Recording Available** - Whether webinar was recorded

### 3.6 Chat Messages
- **Message Content** - Text content of the chat message
- **Sender Name** - Name of the person who sent the message
- **Timestamp** - When the message was sent
- **Message Type** - Type of message (Public, Private, File)
- **Recipient** - Who received the message (if private)
- **File Attachment** - Whether message included file attachment

### 3.7 Screen Shares
- **Presenter Name** - Name of person sharing screen
- **Start Time** - When screen sharing started
- **End Time** - When screen sharing ended
- **Duration** - Total duration of screen sharing
- **Application Shared** - Specific application or screen shared
- **Share Type** - Type of sharing (Full Screen, Application, Whiteboard)

### 3.8 Breakout Rooms
- **Room Name** - Name or identifier of the breakout room
- **Participant Count** - Number of participants in the room
- **Start Time** - When breakout room session started
- **End Time** - When breakout room session ended
- **Duration** - Total duration of breakout room session
- **Host Visits** - Number of times host visited the room

### 3.9 Polls
- **Poll Question** - The question asked in the poll
- **Poll Type** - Type of poll (Multiple Choice, Single Answer)
- **Response Count** - Number of responses received
- **Start Time** - When poll was launched
- **End Time** - When poll was closed
- **Results Shared** - Whether results were shared with participants

### 3.10 Reports
- **Report Name** - Name or title of the report
- **Report Type** - Type of report (Usage, Participant, Meeting)
- **Generation Date** - When the report was generated
- **Date Range** - Time period covered by the report
- **Generated By** - Who generated the report
- **Export Format** - Format of exported report (PDF, CSV, Excel)

## 4. KPI List

1. **Total Meeting Count** - Total number of meetings conducted in a given period
2. **Average Meeting Duration** - Average length of meetings
3. **Total Participant Count** - Total number of unique participants across all meetings
4. **Average Participants per Meeting** - Average number of participants in meetings
5. **Average Participation Rate** - Percentage of invited participants who actually joined meetings
6. **Meeting Utilization Rate** - Percentage of scheduled meeting time actually used
7. **Recording Usage Rate** - Percentage of meetings that were recorded
8. **Screen Sharing Frequency** - Average number of screen shares per meeting
9. **Chat Message Volume** - Total number of chat messages sent during meetings
10. **Webinar Attendance Rate** - Percentage of registered attendees who joined webinars
11. **User Adoption Rate** - Percentage of licensed users actively using the platform
12. **Peak Concurrent Users** - Maximum number of simultaneous users on the platform
13. **Average Connection Quality** - Average network quality score across all participants
14. **Mobile Usage Rate** - Percentage of participants joining via mobile devices
15. **Breakout Room Utilization** - Frequency and duration of breakout room usage

## 5. Conceptual Data Model Diagram in Tabular Form

| Source Entity | Target Entity | Relationship Key Field | Relationship Type |
|---------------|---------------|------------------------|-------------------|
| Users | Meetings | User Email Address | One-to-Many (One user can host multiple meetings) |
| Meetings | Meeting Participants | Meeting Title + Start Time | One-to-Many (One meeting has multiple participants) |
| Users | Meeting Participants | User Email Address | One-to-Many (One user can participate in multiple meetings) |
| Meetings | Recordings | Meeting Title + Start Time | One-to-Many (One meeting can have multiple recordings) |
| Users | Webinars | User Email Address | One-to-Many (One user can host multiple webinars) |
| Meetings | Chat Messages | Meeting Title + Start Time | One-to-Many (One meeting has multiple chat messages) |
| Meeting Participants | Chat Messages | Participant Name + Email Address | One-to-Many (One participant can send multiple messages) |
| Meetings | Screen Shares | Meeting Title + Start Time | One-to-Many (One meeting can have multiple screen shares) |
| Meeting Participants | Screen Shares | Participant Name + Email Address | One-to-Many (One participant can share screen multiple times) |
| Meetings | Breakout Rooms | Meeting Title + Start Time | One-to-Many (One meeting can have multiple breakout rooms) |
| Breakout Rooms | Meeting Participants | Room Name + Meeting Reference | Many-to-Many (Participants can join multiple breakout rooms) |
| Meetings | Polls | Meeting Title + Start Time | One-to-Many (One meeting can have multiple polls) |
| Webinars | Polls | Webinar Title + Start Time | One-to-Many (One webinar can have multiple polls) |
| Users | Reports | User Email Address | One-to-Many (One user can generate multiple reports) |

## 6. Common Data Elements in Report Requirements

1. **Date and Time Fields** - Used across all entities for temporal analysis and reporting
2. **User Identification** - Email Address and User Name appear in multiple entities for user tracking
3. **Meeting Identification** - Meeting Title and Start Time used to uniquely identify meetings across entities
4. **Duration Measurements** - Various duration fields for time-based analytics
5. **Participant Information** - Participant details shared between Meeting Participants and other entities
6. **Status Indicators** - Various status fields for tracking entity states
7. **Count Metrics** - Participant counts, message counts, and other quantitative measures
8. **Device and Connection Information** - Technical details about how users connect and participate
9. **Content Metadata** - Information about recordings, shared content, and communications
10. **Geographic and Network Data** - Location and connection quality information for performance analysis
11. **Engagement Metrics** - Camera status, microphone usage, chat participation for engagement analysis
12. **Administrative Fields** - Host information, permissions, and organizational data