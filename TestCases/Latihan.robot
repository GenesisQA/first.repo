*** Settings ***
# rest API
Library     RequestsLibrary
Library     Collections
Library     JSONLibrary
Library     OperatingSystem


*** Variables ***
${base_url}         https://api.stg-genesis.lionparcel.com
${email}            ca@thelionparcel.com
${APP_JSON}         application/json
${FILE_NAME}        create_stt_manual.json
${URI_LOGIN}        /horde/v1/auth/login
${ACTOR_ID}         1
${ACTOR_TYPE}       partner
${requestbody}      "{'password': 'Genesis123','email': 'ca@thelionparcel.com'}""

*** Test Cases ***
   
PostSuccessLogin
    [Documentation]     Step for set header and body data
    #Prepare Request
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/auth/client.json
    ${bodyrequest}  Update value to json       ${json}      password    Genesis123
    ${bodyrequest}  Update value to json       ${json}      email    ${email}
    Set Test Variable   ${JSON_SCHEMA}      ${bodyrequest}

    ${resp}=    POST    ${base_url}/horde/v1/auth/login    json=${JSON_SCHEMA}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${jsondata['data']['type']}    Bearer
    Should Not Be Equal As Strings  ${jsondata['data']['token']}    ""

    ${bearerToken}=     Set Variable     ${jsondata['data']['token']}
    Set Global Variable      ${bearerToken}
    log to console      ${bodyrequest}
    log to console      ${CURDIR}
    log to console      ${requestbody}

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
    ${role1}=    Set Variable    ${jsondata['data']['role_permission'][0]['name']}
    
    Set Global Variable      ${ACTOR_ID}
    Set Global Variable      ${ACTOR_TYPE}
    log to console           ${ACTOR_ID}
    log to console           ${ACTOR_TYPE}
    log to console           ${role1}

Cara modify isi array di request json
    ${stt1}=     set variable       123
    ${stt2}=     set variable       234
    ${json}=     Load JSON From File     ${CURDIR}/../SchemaObject/create_sti.json
    #${string}=  Convert json to string      ${json}
    ${bodyrequest}  Update value to json       ${json}      stt_no    ["${stt1}", "${stt2}", ""]
    #log to console      ${string}
    log to console      ${bodyrequest}