# https://lionparcel.atlassian.net/browse/CS-1847
# CS-1847 [BE][CARGO] Create PATCH detail cargo endpoint

*** Settings ***
Resource    TC_Auth.robot
# rest API
Library     RequestsLibrary
Library     Collections
Library     JSONLibrary
Library     OperatingSystem


*** Variables ***
${base_url}         https://api.stg-genesis.lionparcel.com

*** Test Cases ***
Bearer Token Call 
    TC_Auth.Test1 Webservice

Preparation 1 create token pos and console
    [Documentation]     Token Generator
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/auth/fposbgr1.json
    Set Test Variable   ${JSON_SCHEMA}      ${json}
    ${resp}=    POST    ${base_url}/horde/v1/auth/login    json=${JSON_SCHEMA}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    ${Tokenfposbgr1}=     Set Variable     ${jsondata['data']['token']}
    Set Global Variable      ${Tokenfposbgr1}
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/auth/fconbgr.json
    Set Test Variable   ${JSON_SCHEMA}      ${json}
    ${resp}=    POST    ${base_url}/horde/v1/auth/login    json=${JSON_SCHEMA}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    ${Tokenfconbgr}=     Set Variable     ${jsondata['data']['token']}
    Set Global Variable      ${Tokenfconbgr}

Preparation 2 create_booking_manual_1_pcs
    [Documentation]     Booking 1 stt yang 1 koli for cargo
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/create_booking_manual_1_pcs.json
    Set Test Variable   ${JSON_SCHEMA}      ${json}
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfposbgr1}
    ${resp}=    POST    ${base_url}/hydra/v1/stt/manual    json=${JSON_SCHEMA}      headers=${header}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    ${stt_no1koli}=     Set Variable     ${jsondata['data']['stt'][0]['stt_no']}
    #log to console      ${stt_no1koli}
    Set Global Variable      ${stt_no1koli}

Preparation 3 create_cargo_1_stt
    [Documentation]     Create cargo
    ${cargo_no}=        Catenate        SEPARATOR=        Car     ${stt_no1koli}
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/create_cargo_1_stt.json
    ${bodyrequest}  Update value to json       ${json}      cargo_no    ${cargo_no}
    ${bodyrequest}  Update value to json       ${json}      departure_date    2021-06-28 08:00:01
    ${bodyrequest}  Update value to json       ${json}      arrival_date    2021-06-28 10:00:01
    ${bodyrequest}  Update value to json       ${json}      $.bag_or_stt[0].stt_no    ${stt_no1koli}

    Set Test Variable   ${JSON_SCHEMA}      ${bodyrequest}
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfconbgr}

    ${resp}=    POST    ${base_url}/hydra/v1/cargo    json=${JSON_SCHEMA}      headers=${header}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}

    Set Test Variable       ${jsondata}      ${value}
    #log to console          ${jsondata}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Not Be Equal As Strings  ${jsondata['data']['total_stt_success']}    "0"

    ${cargo_no}=     Set Variable     ${jsondata['data']['cargo_no']}
    Set Global Variable      ${cargo_no}

Detail Cargo total piece harusnya baru 1 pieces
    [Documentation]     total piece harusnya baru 1 pieces
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfconbgr}
    #${url}=     Catenate        /hydra/v1/cargo/detail-cargo-stt?cargo_no=      ${cargo_no}
    ${resp}=    GET    ${base_url}/hydra/v1/cargo/detail-cargo-stt    params=cargo_no=${cargo_no}          headers=${header}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    
    Set Test Variable       ${jsondata}      ${value}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Numbers  ${jsondata['data']['total_piece']}    1

    #log to console      ${jsondata}

Create Bag for add to cargo
    [Documentation]     create 3 stt, create sti, create bag
    #create stt 1
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/create_booking_manual_1_pcs.json
    Set Test Variable   ${JSON_SCHEMA}      ${json}
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfposbgr1}
    ${resp}=    POST    ${base_url}/hydra/v1/stt/manual    json=${JSON_SCHEMA}      headers=${header}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    ${stt_bag1}=     Set Variable     ${jsondata['data']['stt'][0]['stt_no']}
    Set Global Variable      ${stt_bag1}

    #create stt 2
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/create_booking_manual_1_pcs.json
    Set Test Variable   ${JSON_SCHEMA}      ${json}
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfposbgr1}
    ${resp}=    POST    ${base_url}/hydra/v1/stt/manual    json=${JSON_SCHEMA}      headers=${header}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    ${stt_bag2}=     Set Variable     ${jsondata['data']['stt'][0]['stt_no']}
    Set Global Variable      ${stt_bag2}

    #create stt 3
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/create_booking_manual_1_pcs.json
    Set Test Variable   ${JSON_SCHEMA}      ${json}
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfposbgr1}
    ${resp}=    POST    ${base_url}/hydra/v1/stt/manual    json=${JSON_SCHEMA}      headers=${header}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    ${stt_bag3}=     Set Variable     ${jsondata['data']['stt'][0]['stt_no']}
    Set Global Variable      ${stt_bag3}

    #create sti
    ${json}=     Load JSON From File     ${CURDIR}/../SchemaObject/create_sti.json
    ${list_stt}=        create list     ${stt_bag1}     ${stt_bag2}     ${stt_bag3}
    Set Global Variable      ${list_stt}
    ${bodyrequest}  Update value to json       ${json}      stt_no    ${list_stt}
    Set Test Variable   ${JSON_SCHEMA}      ${bodyrequest}
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfconbgr}
    ${resp}=    POST    ${base_url}/hydra/v1/sti/generate    json=${JSON_SCHEMA}      headers=${header}
    
    #create bagging
    ${json}=     Load JSON From File     ${CURDIR}/../SchemaObject/create_bagging_3_stt.json
    ${bodyrequest}  Update value to json       ${json}      bag_stt    ${list_stt}
    Set Test Variable   ${JSON_SCHEMA}      ${bodyrequest}
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfconbgr}
    ${resp}=    POST    ${base_url}/hydra/v1/bag    json=${JSON_SCHEMA}      headers=${header}
    
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    log to console          ${jsondata}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Not Be Equal As Strings  ${jsondata['data']['bag_code']}    ""
    Should Be Equal As Strings    ${jsondata['data']['total_stt_success']}    3

    ${bag_code}=     Set Variable     ${jsondata['data']['bag_code']}
    Set Global Variable      ${bag_code}

Create STT for add to cargo
    [Documentation]     1 STT dengan 14 pieces = 14 pieces/koli
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/create_booking_manual_14_pcs.json
    Set Test Variable   ${JSON_SCHEMA}      ${json}
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfposbgr1}
    ${resp}=    POST    ${base_url}/hydra/v1/stt/manual    json=${JSON_SCHEMA}      headers=${header}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}
    Set Test Variable       ${jsondata}      ${value}
    ${stt_no14koli}=     Set Variable     ${jsondata['data']['stt'][0]['stt_no']}
    Set Global Variable      ${stt_no14koli}


Edit Cargo Add Bag and STT
    [Documentation]     add bag and stt
    ${json}     Load JSON From File     ${CURDIR}/../SchemaObject/edit_cargo.json
    ${bodyrequest}  Update value to json       ${json}      cargo_no    ${cargo_no}
    ${bodyrequest}  Update value to json       ${json}      $.bag_or_stt[0].bag_no    ${bag_code}
    ${bodyrequest}  Update value to json       ${json}      $.bag_or_stt[0].stt_no    ${stt_bag1}
    ${bodyrequest}  Update value to json       ${json}      $.bag_or_stt[1].bag_no    ${bag_code}
    ${bodyrequest}  Update value to json       ${json}      $.bag_or_stt[1].stt_no    ${stt_bag2}
    ${bodyrequest}  Update value to json       ${json}      $.bag_or_stt[2].bag_no    ${bag_code}
    ${bodyrequest}  Update value to json       ${json}      $.bag_or_stt[2].stt_no    ${stt_bag3}
    ${bodyrequest}  Update value to json       ${json}      $.bag_or_stt[3].stt_no    ${stt_no14koli}

    Set Test Variable   ${JSON_SCHEMA}      ${bodyrequest}
    ${header}=      Create Dictionary     Authorization=Bearer ${Tokenfconbgr}

    ${resp}=    PUT    ${base_url}/hydra/v1/cargo    json=${JSON_SCHEMA}      headers=${header}
    ${data}     Convert To String       ${resp.json()}
    ${value}    Evaluate    ${data}

    Set Test Variable       ${jsondata}      ${value}
    log to console          ${jsondata}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Not Be Equal As Strings  ${jsondata['data']['total_stt_success']}    "0"