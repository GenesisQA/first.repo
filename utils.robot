*** Settings ***
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections

*** Variable ***
${URL}           https://api.stg-genesis.lionparcel.com


*** Keywords ***
Create Genesis Session
    [Documentation]
    Create Session      api          ${URL} 
    Set Suite Variable   ${SESSION}   api
    
Set header with Content-Type ${content_type}
    [Documentation]
    ${key_value}    Create Dictionary       Content-Type=${content_type}
    Set Test Variable   ${STANDAR_HEADER}   ${key_value}

Load ${file_name} API JSON schema
    [Documentation]
    ${json}     Load JSON From File     ${CURDIR}/SchemaObject/${file_name}
    Set Test Variable   ${JSON_SCHEMA}      ${json}

Get Response Object
    [Documentation]
    ${data}     Convert To String       ${RESPONSE.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${OBJECT}      ${value}

Status code should be ${expected_code} in header
    [Documentation]
    ${actual_code}      Convert To String    ${RESPONSE.status_code}
    Should Be Equal     ${actual_code}      ${expected_code}