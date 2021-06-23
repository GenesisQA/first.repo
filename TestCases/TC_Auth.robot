*** Settings ***
Library     RequestsLibrary
Library     Collections
Library     OperatingSystem

*** Variables ***
${base_url}     https://api.stg-genesis.lionparcel.com
${headers}       Create Dictionary  Authorization=“Bearer abcde”
${bearerToken}      "aaa"
${username}     ca
${name}     ca
${email}    ca@thelionparcel.com

*** Test Cases ***

PostFailedLogin
    [Tags]    Failed Login
    Create Session    httpAuth    ${base_url}   verify=true
    &{data}=    Create Dictionary    email=caaa@thelionparcel.com    password=Genesis123
    ${resp}=    POST Request    httpAuth    /horde/v1/auth/login    json=${data}
    ${jsondata}=    To Json    ${resp.content}
    Should Not Be Equal As Strings    ${resp.status_code}    200
   
PostSuccessLogin
    [Tags]    Success Login
    Create Session    httpAuth    ${base_url}   verify=true
    &{data}=    Create Dictionary    email=ca@thelionparcel.com    password=Genesis123
    ${resp}=    POST Request    httpAuth    /horde/v1/auth/login    json=${data}
    ${jsondata}=    To Json    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${jsondata['data']['type']}    Bearer
    Should Not Be Equal As Strings  ${jsondata['data']['token']}    "" 
    ${bearerToken}=     Set Variable     ${jsondata['data']['token']}
    Set Global Variable      ${bearerToken} 

GetProfile
    [Tags]    Get Profile
    Create Session      httpGetProfile      ${base_url}     verify=true
    ${header}=      Create Dictionary     Authorization=Bearer ${bearerToken}
    ${resp}=    GET Request    httpGetProfile    /horde/v1/account/profile   headers=${header}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${jsondata}=    To Json    ${resp.content}
    Should Be Equal As Strings      ${jsondata['data']['username']}     ${username}
    ${cnt}=    Get length    ${jsondata['data']['role_permission']}
    Should be true  ${cnt} > 0
    Should be Equal As Strings          ${jsondata['data']['email']}    ${email}