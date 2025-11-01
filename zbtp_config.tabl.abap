*&---------------------------------------------------------------------*
*& Table ZBTP_CONFIG - BTP Integration Monitor Configuration
*&---------------------------------------------------------------------*
*& This table stores configuration parameters for BTP Integration
*& Suite monitoring including connection details, OAuth2 credentials,
*& email settings, and alert thresholds.
*&---------------------------------------------------------------------*

" Table Definition for ZBTP_CONFIG
" Fields:
" CLIENT - Client (Key field)
" CONFIG_ID - Configuration ID (Key field) 
" BTP_URL - BTP Integration Suite Base URL
" OAUTH_CLIENT - OAuth2 Client ID
" OAUTH_SECRET - OAuth2 Client Secret (encrypted)
" TOKEN_URL - OAuth2 Token Endpoint URL
" TIMEOUT - HTTP Request Timeout (seconds)
" EMAIL_ENABLED - Enable Email Alerts
" SMTP_SERVER - SMTP Server for Email
" SMTP_PORT - SMTP Port
" EMAIL_FROM - From Email Address
" EMAIL_TO - To Email Address(es)
" ALERT_THRESHOLD - Alert Threshold (minutes)
" CREATED_BY - Created By User
" CREATED_ON - Created On Date
" CHANGED_BY - Changed By User  
" CHANGED_ON - Changed On Date

" This would be created in SE11 as a transparent table with the following structure:
" 
" Field Name       Data Element    Key  Description
" CLIENT           MANDT          X    Client
" CONFIG_ID        CHAR20         X    Configuration ID
" BTP_URL          CHAR255             BTP Base URL
" OAUTH_CLIENT     CHAR100             OAuth2 Client ID
" OAUTH_SECRET     CHAR255             OAuth2 Client Secret
" TOKEN_URL        CHAR255             OAuth2 Token URL
" TIMEOUT          INT4                Timeout in seconds
" EMAIL_ENABLED    CHAR1               Email alerts enabled (X/space)
" SMTP_SERVER      CHAR100             SMTP Server
" SMTP_PORT        CHAR10              SMTP Port
" EMAIL_FROM       CHAR100             From email address
" EMAIL_TO         CHAR255             To email addresses
" ALERT_THRESHOLD  INT4                Alert threshold minutes
" CREATED_BY       SYUNAME             Created by user
" CREATED_ON       SYDATUM             Created on date
" CHANGED_BY       SYUNAME             Changed by user
" CHANGED_ON       SYDATUM             Changed on date

" Technical Settings:
" - Data Class: APPL1 (Master data)
" - Size Category: 0 (small table)
" - Buffering: Not allowed (security sensitive data)

" Indexes:
" Primary Index: CLIENT + CONFIG_ID