#!/bin/bash
if [[ "$1" == "--help" ]]
then
    echo "get_states: Go get the list of states"
    echo "get_districts <state_id>: Get the list of District"
    echo "search_slots <disrtict_id> <mail-for-notification>: Gets notified when vaccine slot is there"
    exit 0
fi

if [[ "$1" == "get_states" ]]
then
    STATES=$(curl --silent 'https://cdn-api.co-vin.in/api/v2/admin/location/states'   -H 'authority: cdn-api.co-vin.in'   -H 'sec-ch-ua: "Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"'   -H 'accept: application/json, text/plain, */*'   -H 'dnt: 1'   -H 'sec-ch-ua-mobile: ?0'   -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Safari/537.36'   -H 'origin: https://selfregistration.cowin.gov.in'   -H 'sec-fetch-site: cross-site'   -H 'sec-fetch-mode: cors'   -H 'sec-fetch-dest: empty'   -H 'referer: https://selfregistration.cowin.gov.in/'   -H 'accept-language: en-US,en;q=0.9,ms;q=0.8'   -H 'if-none-match: W/"426-BK5ycccSz2k0MWY/+ZQo/L8JOcg"'   --compressed)
    for row in $(echo "${STATES}" | jq -r '.states[] | @base64'); do
        _states() {
            echo ${row} | base64 --decode | jq -r ${1}
        }
        STATE_ID=$(_states '.state_id')
        STATE_NAME=$(_states '.state_name')
        echo "${STATE_ID}) ${STATE_NAME}"
    done
    exit 0
fi

if [[ "$1" == "get_districts" ]]
then
    if [[ "$2" == "" ]]
    then
        echo "Error: Pass State ID as get_districts <state_id>"
        exit 0
    fi
    DISTRICTS=$(curl --silent "https://cdn-api.co-vin.in/api/v2/admin/location/districts/$2"   -H 'authority: cdn-api.co-vin.in'   -H 'sec-ch-ua: "Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"'   -H 'accept: application/json, text/plain, */*'   -H 'dnt: 1'   -H 'sec-ch-ua-mobile: ?0'   -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Safari/537.36'   -H 'origin: https://selfregistration.cowin.gov.in'   -H 'sec-fetch-site: cross-site'   -H 'sec-fetch-mode: cors'   -H 'sec-fetch-dest: empty'   -H 'referer: https://selfregistration.cowin.gov.in/'   -H 'accept-language: en-US,en;q=0.9,ms;q=0.8'   -H 'if-none-match: W/"426-BK5ycccSz2k0MWY/+ZQo/L8JOcg"'   --compressed)
    for row in $(echo "${DISTRICTS}" | jq -r '.districts[] | @base64'); do
        _states() {
            echo ${row} | base64 --decode | jq -r ${1}
        }
        DISTRICT_ID=$(_states '.district_id')
        DISTRICT_NAME=$(_states '.district_name')
        echo "${DISTRICT_ID}) ${DISTRICT_NAME}"
    done
    exit 0
fi


if [[ "$1" == "search_slots" ]]
then 
    if [[ "$2" == "" ]]
    then
        echo "Error: Pass District ID as search_slots <disrtict_id> <mail-for-notification>"
        exit 0
    else
        DIST_ID=$2
        echo "Looking for District $DIST_ID"
        
    fi

    if [[ "$3" == "" ]]
    then
        echo "Error: Pass reciever email as search_slots <disrtict_id> <mail-for-notification>"
        exit 0
    else
        RECIEVER_EMAIL=$3
        echo "You will get notified at $RECIEVER_EMAIL"
    fi

    FINAL_STR=""
    while [ "$FINAL_STR" == "" ]
    do

        DIST=${DIST_ID}
        DAY=$(date +%d)
        MON=$(date +%m)
        OUT=$(curl --silent "https://cdn-api.co-vin.in/api/v2/appointment/sessions/calendarByDistrict?district_id=$DIST&date=$DAY-$MON-2021"   -H 'authority: cdn-api.co-vin.in'   -H 'sec-ch-ua: "Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"'   -H 'accept: application/json, text/plain, */*'   -H 'dnt: 1'   -H 'sec-ch-ua-mobile: ?0'   -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Safari/537.36'   -H 'origin: https://selfregistration.cowin.gov.in'   -H 'sec-fetch-site: cross-site'   -H 'sec-fetch-mode: cors'   -H 'sec-fetch-dest: empty'   -H 'referer: https://selfregistration.cowin.gov.in/'   -H 'accept-language: en-US,en;q=0.9,ms;q=0.8'   -H 'if-none-match: W/"426-BK5ycccSz2k0MWY/+ZQo/L8JOcg"'   --compressed)
        
        FINAL_STR=""
        for row in $(echo "${OUT}" | jq -r '.centers[] | @base64'); do
            _jq() {
            echo ${row} | base64 --decode | jq -r ${1}
            }
            SESSION=$(_jq '.sessions')
            for row1 in $(echo "${SESSION}" | jq -r '.[] | @base64'); do
                _jq1() {
                    echo ${row1} | base64 --decode | jq -r ${1}
                }
                HAVE=$(_jq1 '.available_capacity')
                if [[ "$HAVE" != "0" ]]
                then
                        NAME=$(_jq '.name') 
                        PINCODE=$(_jq '.pincode')
                        DATE=$(_jq1 '.date')
                        FINAL_STR="${FINAL_STR}\n${NAME} ${PINCODE} ${DATE}"
                fi
            done
        done

        if [[ $FINAL_STR != "" ]]
        then
            echo -e "$FINAL_STR"
            echo "To: $RECIEVER_EMAIL" > vaccine.txt
            echo "From: $SENDER_EMAIL" >> vaccine.txt
            echo "Subject: Vaccine available" >> vaccine.txt
            echo -e "$FINAL_STR" >> vaccine.txt
            ssmtp "$RECIEVER_EMAIL" < vaccine.txt
        else
            echo "Not there"
        fi
        sleep 1m
    done
    exit 0
fi

echo "get_states: Get the list of states"
echo "get_districts <state_id>: Get the list of District"
echo "search_slots <disrtict_id> <mail-for-notification>: Gets notified when vaccine slot is there"
exit 0
