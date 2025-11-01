*&---------------------------------------------------------------------*
*& Table ZBTP_ALERT_HISTORY - BTP Alert History Tracking
*&---------------------------------------------------------------------*
*& This table stores the history of alerts sent by the BTP Integration
*& Monitor to track alert frequency and prevent duplicate notifications.
*&---------------------------------------------------------------------*

" Table Definition for ZBTP_ALERT_HISTORY
" Fields:
" CLIENT - Client (Key field)
" ALERT_ID - Unique Alert ID (Key field)
" FLOW_ID - Integration Flow ID
" FLOW_NAME - Integration Flow Name
" ALERT_TYPE - Type of Alert (STATUS_CHANGE, CONNECTIVITY_ERROR, etc.)
" SEVERITY - Alert Severity (ERROR, WARNING, INFO)
" ALERT_MESSAGE - Alert Message Text
" SENT_TIMESTAMP - When Alert was Sent
" EMAIL_SENT - Whether Email was Sent Successfully
" RECIPIENTS - Email Recipients
" CREATED_BY - Created By User
" CREATED_ON - Created On Date

" This would be created in SE11 as a transparent table with the following structure:
" 
" Field Name       Data Element    Key  Description
" CLIENT           MANDT          X    Client
" ALERT_ID         CHAR32         X    Unique Alert ID
" FLOW_ID          CHAR100             Integration Flow ID
" FLOW_NAME        CHAR255             Integration Flow Name
" ALERT_TYPE       CHAR30              Alert Type
" SEVERITY         CHAR10              Alert Severity
" ALERT_MESSAGE    CHAR500             Alert Message
" SENT_TIMESTAMP   TIMESTAMPL          Alert Sent Timestamp
" EMAIL_SENT       CHAR1               Email Sent Flag
" RECIPIENTS       CHAR500             Email Recipients
" CREATED_BY       SYUNAME             Created By User
" CREATED_ON       SYDATUM             Created On Date

" Technical Settings:
" - Data Class: APPL1 (Transaction data)
" - Size Category: 2 (medium table)
" - Buffering: Not allowed (real-time data)

" Indexes:
" Primary Index: CLIENT + ALERT_ID
" Secondary Index 1: CLIENT + FLOW_ID + SENT_TIMESTAMP
" Secondary Index 2: CLIENT + ALERT_TYPE + SENT_TIMESTAMP
" Secondary Index 3: CLIENT + SEVERITY + SENT_TIMESTAMP