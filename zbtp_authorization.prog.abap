*&---------------------------------------------------------------------*
*& Include ZBTP_AUTHORIZATION - Authorization Framework
*&---------------------------------------------------------------------*
*& Authorization objects and role definitions for BTP Integration Monitor
*& 
*& This include defines the authorization framework including:
*& - Custom authorization objects (created in SU21)
*& - Authorization check functions
*& - Role templates and recommendations
*&---------------------------------------------------------------------*

" Authorization Object Definitions (to be created in SU21)
" ========================================================

" ZBTP_MON - BTP Integration Monitor Main Authorization
" Fields:
" - ACTVT (Activity): 01=Display, 02=Change, 03=Create, 06=Delete, 16=Execute
" - CONFIG (Configuration): Configuration ID from ZBTP_CONFIG
" - MONTYPE (Monitor Type): FLOW=Flow Monitoring, CONN=Connectivity, EMAIL=Email Test

" ZBTP_CONF - BTP Configuration Management Authorization  
" Fields:
" - ACTVT (Activity): 01=Display, 02=Change, 03=Create, 06=Delete
" - CONFIG (Configuration): Configuration ID from ZBTP_CONFIG

" ZBTP_JOB - BTP Job Management Authorization
" Fields:
" - ACTVT (Activity): 01=Display, 02=Change, 03=Create, 06=Delete, 16=Execute
" - JOBTYPE (Job Type): SCHED=Schedule, MON=Monitor, DEL=Delete

" Authorization Check Functions
" =============================

*&---------------------------------------------------------------------*
*& Form CHECK_MONITOR_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM check_monitor_authorization USING iv_activity TYPE c
                                       iv_config_id TYPE string
                                       iv_monitor_type TYPE string
                                 CHANGING cv_authorized TYPE abap_bool.
  
  " Check authorization for monitoring activities
  
  " Note: In real implementation, this would use the custom authorization object
  " AUTHORITY-CHECK OBJECT 'ZBTP_MON'
  "   ID 'ACTVT' FIELD iv_activity
  "   ID 'CONFIG' FIELD iv_config_id  
  "   ID 'MONTYPE' FIELD iv_monitor_type.
  
  " For demonstration, perform basic checks
  cv_authorized = abap_true.
  
  " Check if user has general monitoring authorization
  " This could be enhanced with more sophisticated logic
  IF sy-uname = 'ANONYMOUS' OR sy-uname IS INITIAL.
    cv_authorized = abap_false.
    MESSAGE 'Anonymous users not authorized for BTP monitoring' TYPE 'E'.
    RETURN.
  ENDIF.
  
  " Log authorization check
  DATA(lo_logger) = NEW zcl_btp_logger( |AUTH_CHECK_{ sy-datum }_{ sy-uzeit }| ).
  lo_logger->log_info( 
    iv_message = 'Authorization check performed'
    iv_details = |User: { sy-uname }, Activity: { iv_activity }, Config: { iv_config_id }, Type: { iv_monitor_type }| ).
  
  " In production, log authorization failures for security auditing
  IF cv_authorized = abap_false.
    lo_logger->log_warning( 
      iv_message = 'Authorization check failed'
      iv_details = |User { sy-uname } denied access to { iv_monitor_type } monitoring for config { iv_config_id }| ).
  ENDIF.
  
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CHECK_CONFIG_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM check_config_authorization USING iv_activity TYPE c
                                      iv_config_id TYPE string
                                CHANGING cv_authorized TYPE abap_bool.
  
  " Check authorization for configuration management
  
  " AUTHORITY-CHECK OBJECT 'ZBTP_CONF'
  "   ID 'ACTVT' FIELD iv_activity
  "   ID 'CONFIG' FIELD iv_config_id.
  
  cv_authorized = abap_true.
  
  " Enhanced authorization logic for configuration management
  CASE iv_activity.
    WHEN '01'. " Display
      " Most users can display configurations
      cv_authorized = abap_true.
      
    WHEN '02' OR '03' OR '06'. " Change, Create, Delete
      " Only authorized administrators can modify configurations
      " This would typically check for specific roles or authorization objects
      IF sy-uname CO 'ADMIN*' OR sy-uname = 'DEVELOPER'.
        cv_authorized = abap_true.
      ELSE.
        cv_authorized = abap_false.
        MESSAGE |User { sy-uname } not authorized for configuration { SWITCH string( iv_activity WHEN '02' THEN 'modification' WHEN '03' THEN 'creation' WHEN '06' THEN 'deletion' ) }| TYPE 'E'.
      ENDIF.
      
    WHEN OTHERS.
      cv_authorized = abap_false.
      MESSAGE |Invalid activity { iv_activity } for configuration authorization| TYPE 'E'.
  ENDCASE.
  
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CHECK_JOB_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM check_job_authorization USING iv_activity TYPE c
                                   iv_job_type TYPE string
                             CHANGING cv_authorized TYPE abap_bool.
  
  " Check authorization for job management
  
  " AUTHORITY-CHECK OBJECT 'ZBTP_JOB'
  "   ID 'ACTVT' FIELD iv_activity
  "   ID 'JOBTYPE' FIELD iv_job_type.
  
  cv_authorized = abap_true.
  
  " Job management requires elevated privileges
  CASE iv_job_type.
    WHEN 'SCHED'. " Schedule jobs
      " Only job schedulers can create/modify scheduled jobs
      cv_authorized = abap_true. " Simplified for demo
      
    WHEN 'MON'. " Monitor jobs
      " Most users can monitor job status
      cv_authorized = abap_true.
      
    WHEN 'DEL'. " Delete jobs
      " Only administrators can delete jobs
      IF iv_activity = '06'. " Delete activity
        cv_authorized = abap_true. " Simplified for demo
      ENDIF.
      
    WHEN OTHERS.
      cv_authorized = abap_false.
  ENDCASE.
  
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CHECK_SENSITIVE_DATA_ACCESS
*&---------------------------------------------------------------------*
FORM check_sensitive_data_access USING iv_data_type TYPE string
                                 CHANGING cv_authorized TYPE abap_bool.
  
  " Check authorization for accessing sensitive data (credentials, etc.)
  
  cv_authorized = abap_false. " Default deny
  
  CASE iv_data_type.
    WHEN 'OAUTH_CREDENTIALS'.
      " Only system users and authorized administrators can access OAuth credentials
      IF sy-uname = 'SYSTEM' OR sy-batch = abap_true.
        cv_authorized = abap_true.
      ELSE.
        " Interactive users need special authorization
        " This would check for specific authorization objects
        cv_authorized = abap_false.
        MESSAGE 'Interactive access to OAuth credentials not permitted' TYPE 'E'.
      ENDIF.
      
    WHEN 'EMAIL_CONFIG'.
      " Email configuration access is less restricted
      cv_authorized = abap_true.
      
    WHEN 'LOG_DATA'.
      " Log data access based on user role
      cv_authorized = abap_true.
      
    WHEN OTHERS.
      cv_authorized = abap_false.
      MESSAGE |Unknown sensitive data type: { iv_data_type }| TYPE 'E'.
  ENDCASE.
  
ENDFORM.

" Role Templates and Recommendations
" ==================================

*&---------------------------------------------------------------------*
*& Form DISPLAY_ROLE_RECOMMENDATIONS
*&---------------------------------------------------------------------*
FORM display_role_recommendations.
  
  " Display role templates for BTP Integration Monitor
  
  WRITE: / 'BTP Integration Monitor - Role Templates',
         / '==========================================', /.
  
  WRITE: / '1. BTP_MONITOR_ADMIN - Full Administrative Access',
         / '   - All BTP monitoring functions',
         / '   - Configuration management (create/change/delete)',
         / '   - Job scheduling and management',
         / '   - Access to sensitive data',
         / '   Authorization Objects:',
         / '     ZBTP_MON: ACTVT=*, CONFIG=*, MONTYPE=*',
         / '     ZBTP_CONF: ACTVT=*, CONFIG=*',
         / '     ZBTP_JOB: ACTVT=*, JOBTYPE=*', /.
  
  WRITE: / '2. BTP_MONITOR_OPERATOR - Operational Monitoring',
         / '   - Execute monitoring and connectivity tests',
         / '   - View configurations (read-only)',
         / '   - Monitor job status',
         / '   Authorization Objects:',
         / '     ZBTP_MON: ACTVT=01,16, CONFIG=*, MONTYPE=*',
         / '     ZBTP_CONF: ACTVT=01, CONFIG=*',
         / '     ZBTP_JOB: ACTVT=01, JOBTYPE=MON', /.
  
  WRITE: / '3. BTP_MONITOR_VIEWER - Read-Only Access',
         / '   - View monitoring results and logs',
         / '   - Display configurations',
         / '   - No execution or modification rights',
         / '   Authorization Objects:',
         / '     ZBTP_MON: ACTVT=01, CONFIG=*, MONTYPE=*',
         / '     ZBTP_CONF: ACTVT=01, CONFIG=*', /.
  
  WRITE: / '4. BTP_MONITOR_CONFIG - Configuration Management',
         / '   - Manage BTP configurations',
         / '   - No monitoring execution rights',
         / '   - Suitable for setup and maintenance',
         / '   Authorization Objects:',
         / '     ZBTP_CONF: ACTVT=*, CONFIG=*',
         / '     ZBTP_MON: ACTVT=01, CONFIG=*, MONTYPE=*', /.
  
  WRITE: / 'Additional Considerations:',
         / '- Background job users need ZBTP_MON with ACTVT=16',
         / '- Service users should have minimal required permissions',
         / '- Consider using derived roles for specific configurations',
         / '- Regular review of user assignments recommended', /.
  
ENDFORM.

*&---------------------------------------------------------------------*
*& Form VALIDATE_USER_AUTHORIZATIONS
*&---------------------------------------------------------------------*
FORM validate_user_authorizations USING iv_username TYPE syuname
                                 CHANGING ct_missing_auths TYPE string_table.
  
  " Validate user has required authorizations for BTP monitoring
  
  DATA: lv_authorized TYPE abap_bool,
        lv_auth_issue TYPE string.
  
  CLEAR ct_missing_auths.
  
  " Check basic monitoring authorization
  PERFORM check_monitor_authorization USING '16' 'DEFAULT' 'FLOW' CHANGING lv_authorized.
  IF lv_authorized = abap_false.
    lv_auth_issue = 'Missing ZBTP_MON authorization for flow monitoring execution'.
    APPEND lv_auth_issue TO ct_missing_auths.
  ENDIF.
  
  " Check configuration display authorization
  PERFORM check_config_authorization USING '01' 'DEFAULT' CHANGING lv_authorized.
  IF lv_authorized = abap_false.
    lv_auth_issue = 'Missing ZBTP_CONF authorization for configuration display'.
    APPEND lv_auth_issue TO ct_missing_auths.
  ENDIF.
  
  " Check job monitoring authorization
  PERFORM check_job_authorization USING '01' 'MON' CHANGING lv_authorized.
  IF lv_authorized = abap_false.
    lv_auth_issue = 'Missing ZBTP_JOB authorization for job monitoring'.
    APPEND lv_auth_issue TO ct_missing_auths.
  ENDIF.
  
  " Report results
  IF lines( ct_missing_auths ) = 0.
    WRITE: / |User { iv_username } has sufficient authorizations for BTP monitoring|.
  ELSE.
    WRITE: / |User { iv_username } missing { lines( ct_missing_auths ) } authorization(s):|.
    LOOP AT ct_missing_auths INTO lv_auth_issue.
      WRITE: / '  -', lv_auth_issue.
    ENDLOOP.
  ENDIF.
  
ENDFORM.

" Security Audit Functions
" ========================

*&---------------------------------------------------------------------*
*& Form LOG_SECURITY_EVENT
*&---------------------------------------------------------------------*
FORM log_security_event USING iv_event_type TYPE string
                               iv_user TYPE syuname
                               iv_details TYPE string.
  
  " Log security-related events for auditing
  
  DATA(lo_logger) = NEW zcl_btp_logger( |SEC_AUDIT_{ sy-datum }_{ sy-uzeit }| ).
  
  CASE iv_event_type.
    WHEN 'AUTH_SUCCESS'.
      lo_logger->log_info( 
        iv_message = |Authorization granted: { iv_user }|
        iv_details = iv_details ).
        
    WHEN 'AUTH_FAILURE'.
      lo_logger->log_warning( 
        iv_message = |Authorization denied: { iv_user }|
        iv_details = iv_details ).
        
    WHEN 'CREDENTIAL_ACCESS'.
      lo_logger->log_info( 
        iv_message = |Credential access: { iv_user }|
        iv_details = iv_details ).
        
    WHEN 'CONFIG_CHANGE'.
      lo_logger->log_info( 
        iv_message = |Configuration modified: { iv_user }|
        iv_details = iv_details ).
        
    WHEN 'SECURITY_VIOLATION'.
      lo_logger->log_error( 
        iv_message = |Security violation: { iv_user }|
        iv_details = iv_details ).
        
    WHEN OTHERS.
      lo_logger->log_info( 
        iv_message = |Security event { iv_event_type }: { iv_user }|
        iv_details = iv_details ).
  ENDCASE.
  
  " Save security log immediately
  TRY.
      lo_logger->save_log( ).
    CATCH zcx_btp_config_error.
      " Security logging failure is critical
      MESSAGE 'Security audit logging failed - contact system administrator' TYPE 'E'.
  ENDTRY.
  
ENDFORM.