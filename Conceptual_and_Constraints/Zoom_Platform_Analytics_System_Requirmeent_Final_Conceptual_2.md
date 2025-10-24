_____________________________________________
## *Author*: AAVA
## *Created on*: 
## *Description*: Conceptual data model for Zoom Platform Analytics System with Meeting Participants entity
## *Version*: 2
## *Updated on*: 
## *Changes*: Added Meeting Participants entity with detailed attributes, updated Meetings entity relationship, added new KPI for Average Meeting Duration per Participant, updated conceptual data model diagram
## *Reason*: Enhancement request to include participant-level analytics and tracking capabilities
_____________________________________________

# Zoom Platform Analytics System - Conceptual Data Model

## 1. Domain Overview

The Zoom Platform Analytics System focuses on comprehensive meeting analytics and participant tracking within the video conferencing domain. This system captures detailed information about meetings, participants, user activities, and performance metrics to provide insights into meeting effectiveness, participant engagement, and platform utilization.

## 2. List of Entity Names with Descriptions

1. **Users** - Represents individuals who have access to the Zoom platform and can host or join meetings
2. **Meetings** - Represents scheduled or instant meeting sessions conducted on the Zoom platform
3. **Meeting Participants** - Represents individuals who join specific meetings with detailed participation tracking
4. **Accounts** - Represents organizational accounts that manage multiple users and meetings
5. **Webinars** - Represents large-scale presentation events with host-audience interaction
6. **Recordings** - Represents recorded meeting or webinar sessions stored on the platform
7. **Chat Messages** - Represents text communications sent during meetings or webinars
8. **Breakout Rooms** - Represents smaller sub-meeting spaces within main meetings

## 3. List of Attributes for Each Entity with Descriptions

### **Users**
- **User Name** - Full name of the user registered on the platform
- **Email Address** - Primary email address used for user identification and communication
- **User Type** - Classification of user role (Basic, Pro, Business, Enterprise)
- **Department** - Organizational department or team the user belongs to
- **Location** - Geographic location or office location of the user
- **Registration Date** - Date when the user account was created
- **Last Login Date** - Most recent date the user accessed the platform
- **Status** - Current account status (Active, Inactive, Suspended)

### **Meetings**
- **Meeting Topic** - Subject or title of the meeting
- **Meeting Type** - Classification of meeting (Scheduled, Instant, Recurring, Personal)
- **Start Time** - Scheduled or actual start time of the meeting
- **End Time** - Scheduled or actual end time of the meeting
- **Duration** - Total length of the meeting in minutes
- **Host Name** - Name of the user who organized and hosted the meeting
- **Meeting Password** - Security password required to join the meeting
- **Waiting Room Enabled** - Indicator if waiting room feature was activated
- **Recording Enabled** - Indicator if the meeting was set to be recorded
- **Participant Count** - Total number of participants who joined the meeting
- **Meeting Status** - Current state of the meeting (Scheduled, In Progress, Completed, Cancelled)

### **Meeting Participants**
- **Participant Name** - Full name of the individual who joined the meeting
- **Email Address** - Email address of the participant
- **Join Time** - Timestamp when the participant entered the meeting
- **Leave Time** - Timestamp when the participant left the meeting
- **Duration in Meeting** - Total time the participant spent in the meeting
- **Participant Role** - Role of the participant (Host, Co-host, Attendee, Panelist)
- **Device Type** - Type of device used to join the meeting (Desktop, Mobile, Tablet, Phone)
- **Connection Quality** - Quality rating of the participant's network connection

### **Accounts**
- **Account Name** - Name of the organizational account
- **Account Type** - Subscription level of the account (Basic, Pro, Business, Enterprise)
- **License Count** - Number of user licenses allocated to the account
- **Billing Contact** - Primary contact person for billing and account management
- **Creation Date** - Date when the account was established
- **Subscription Status** - Current subscription state (Active, Trial, Expired, Suspended)

### **Webinars**
- **Webinar Title** - Title or subject of the webinar event
- **Webinar Type** - Classification of webinar (Live, Simulated Live, On-demand)
- **Scheduled Start Time** - Planned start time for the webinar
- **Actual Start Time** - Real start time when the webinar began
- **Duration** - Total length of the webinar in minutes
- **Host Name** - Name of the primary webinar host
- **Registration Required** - Indicator if attendees must register in advance
- **Maximum Attendees** - Maximum number of participants allowed
- **Actual Attendees** - Actual number of participants who joined

### **Recordings**
- **Recording Name** - Title or identifier for the recorded session
- **File Size** - Size of the recording file in megabytes
- **Recording Type** - Format type of the recording (Cloud, Local, Audio Only, Video)
- **Recording Date** - Date when the recording was created
- **Storage Location** - Where the recording is stored (Cloud, Local Device)
- **Access Permission** - Who can access the recording (Public, Private, Password Protected)
- **Download Count** - Number of times the recording has been downloaded

### **Chat Messages**
- **Message Content** - Text content of the chat message
- **Sender Name** - Name of the person who sent the message
- **Message Timestamp** - Date and time when the message was sent
- **Message Type** - Classification of message (Public, Private, File Share)
- **Recipient Name** - Name of the intended recipient for private messages

### **Breakout Rooms**
- **Room Name** - Identifier or name assigned to the breakout room
- **Room Number** - Numerical identifier for the breakout room
- **Participant Count** - Number of participants assigned to the room
- **Start Time** - Time when the breakout room session began
- **End Time** - Time when the breakout room session ended
- **Duration** - Total length of the breakout room session

## 4. KPI List

1. **Total Meeting Count** - Total number of meetings conducted within a specified time period
2. **Average Meeting Duration** - Mean duration of all meetings in minutes
3. **Total Participant Count** - Sum of all participants across all meetings
4. **Average Participants per Meeting** - Mean number of participants per meeting session
5. **Meeting Completion Rate** - Percentage of scheduled meetings that were actually conducted
6. **User Adoption Rate** - Percentage of registered users who actively participate in meetings
7. **Recording Utilization Rate** - Percentage of meetings that were recorded
8. **Average Connection Quality Score** - Mean quality rating across all participant connections
9. **Peak Concurrent Meetings** - Maximum number of simultaneous meetings at any given time
10. **Webinar Attendance Rate** - Percentage of registered attendees who actually joined webinars
11. **Average Meeting Duration per Participant** - Mean time each participant spends in meetings

## 5. Conceptual Data Model Diagram in Tabular Form

| **Primary Entity** | **Related Entity** | **Relationship Key Field** | **Relationship Type** |
|-------------------|-------------------|---------------------------|----------------------|
| Accounts | Users | Account Name | One-to-Many |
| Users | Meetings | Host Name | One-to-Many |
| Meetings | Meeting Participants | Meeting Topic | One-to-Many |
| Meetings | Recordings | Meeting Topic | One-to-Many |
| Meetings | Chat Messages | Meeting Topic | One-to-Many |
| Meetings | Breakout Rooms | Meeting Topic | One-to-Many |
| Users | Webinars | Host Name | One-to-Many |
| Webinars | Recordings | Webinar Title | One-to-Many |
| Webinars | Chat Messages | Webinar Title | One-to-Many |
| Meeting Participants | Chat Messages | Participant Name | One-to-Many |
| Breakout Rooms | Meeting Participants | Room Name | One-to-Many |

## 6. Common Data Elements in Report Requirements

1. **Meeting Topic** - Referenced across meeting analytics, participant tracking, and recording reports
2. **Participant Name** - Used in participant analysis, attendance tracking, and engagement reports
3. **Start Time/End Time** - Common temporal elements across all meeting and webinar reports
4. **Duration** - Key metric appearing in meeting summaries, participant analysis, and performance reports
5. **Host Name** - Referenced in host performance reports, meeting organization analysis, and user activity reports
6. **Email Address** - Common identifier used across user management, participant tracking, and communication reports
7. **Account Name** - Referenced in organizational reports, billing analysis, and usage summaries
8. **Recording Name** - Used in content management reports, storage analysis, and access tracking
9. **Device Type** - Common element in technical performance reports and user experience analysis
10. **Connection Quality** - Referenced in technical performance reports and participant experience analysis
11. **Participant Role** - Used in meeting dynamics analysis and participant engagement reports
12. **Join Time/Leave Time** - Key temporal elements for participant behavior analysis and attendance tracking