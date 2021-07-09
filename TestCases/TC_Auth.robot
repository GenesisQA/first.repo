*** Settings ***
Library     RequestsLibrary
Library     Collections
Library     JSONLibrary
Library     OperatingSystem


*** Variables ***
${base_url}     https://api.stg-genesis.lionparcel.com
${bearerToken}      "aaa"
${username}     ca
${name}     ca
${email}    ca@thelionparcel.com
${reponse1}     1

*** Keywords ***
Test1 Webservice
    Set Global Variable    ${bearerToken    }

*** Test Cases ***

PostFailedLogin
    [Tags]    Failed Login
    Create Session    httpAuth    ${base_url}   verify=true
    &{data}=    Create Dictionary    email=ca@thelionparcel.com    password=Genesis123
    ${resp}=    POST On Session    httpAuth    /horde/v1/auth/login    json=${data}
    ${jsondata}=    Convert To String    ${resp.json()}    ${resp.content}
    Should Not Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.status_code}     422
   
PostSuccessLogin
    [Tags]    Success Login
    Create Session    httpAuth    ${base_url}   verify=true
    &{data}=    Create Dictionary    email=ca@thelionparcel.com    password=Genesis123
    ${resp}=    POST On Session    httpAuth    /horde/v1/auth/login    json=${data}
    ${jsondata}=    Convert To String    ${resp.json()}    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${jsondata['data']['type']}    Bearer
    Should Not Be Equal As Strings  ${jsondata['data']['token']}    "" 
    ${bearerToken}=     Set Variable     ${jsondata['data']['token']}
    Set Global Variable      ${bearerToken}

GetProfile
    [Tags]    Get Profile
    Create Session      httpGetProfile      ${base_url}     verify=true
    ${header}=      Create Dictionary     Authorization=Bearer ${bearerToken}
    ${resp}=    GET On Session    httpGetProfile       'url=/horde/v1/account/profile?is_location=true'   headers=${header}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${jsondata}=    Convert To String    ${resp.json()}    ${resp.content}
    Should Be Equal As Strings      ${jsondata['data']['username']}     ${username}
    ${lengthPermission}=    Get length    ${jsondata['data']['role_permission']}
    Should be true  ${lengthPermission} > 0
    Should be Equal As Strings          ${jsondata['data']['email']}    ${email}