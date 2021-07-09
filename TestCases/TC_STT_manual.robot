*** Settings ***
# rest API
Library     RequestsLibrary
Library     Collections
Library     JSONLibrary
Library     OperatingSystem


*** Variables ***
${base_url}         https://api.stg-genesis.lionparcel.com
${bearerToken}      aa
${email}            ca@thelionparcel.com
${APP_JSON}         application/json
${FILE_NAME}        create_stt_manual.json
${URI_LOGIN}        /horde/v1/auth/login
${ACTOR_ID}         1
${ACTOR_TYPE}       partner


*** Test Cases ***
   
PostSuccessLogin
    [Documentation]     Step for set header and body data
    #Prepare Request
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/auth/client.json
    Set Test Variable   ${JSON_SCHEMA}      ${json}

    ${resp}=    POST    ${base_url}/horde/v1/auth/login    json=${JSON_SCHEMA}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${jsondata['data']['type']}    Bearer
    Should Not Be Equal As Strings  ${jsondata['data']['token']}    ""

    ${bearerToken}=     Set Variable     ${jsondata['data']['token']}
    Set Global Variable      ${bearerToken} 

GetProfile
    [Documentation]     keterangan documentation
    [Tags]    Get Profile
    
    ${header}=      Create Dictionary     Authorization=Bearer ${bearerToken}
    ${resp}=    GET     ${base_url}/horde/v1/account/profile    headers=${header}
    
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}

    ${ACTOR_ID}=    Set Variable    ${jsondata['data']['account_type_detail']['id']}
    ${ACTOR_TYPE}=    Set Variable    ${jsondata['data']['account_type']}
    
    Set Global Variable      ${ACTOR_ID}
    Set Global Variable      ${ACTOR_TYPE} 

#create stt manual should be not sub console 
CreateSttManual
    [Documentation]     log to console  Hello world...
    
    [Tags]    Success Login
    Create Session    httpAuth    ${base_url}   verify=true
    
    #Prepare Request
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/${FILE_NAME}
    Set Test Variable   ${JSON_SCHEMA}      ${json}
    ${value}    Update Value to Json    ${JSON_SCHEMA}      $.account_type      ${ACTOR_TYPE}
    ${value}    Update Value to Json    ${JSON_SCHEMA}      $.account_ref_id    ${ACTOR_ID}

    #Send Response
    ${header}=      Create Dictionary     Authorization=Bearer ${bearerToken}
    ${resp}=    POST        ${base_url}/hydra/v1/stt_manual    json=${JSON_SCHEMA}     headers=${header}

    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}

    Should Be Equal As Strings    ${resp.status_code}    201