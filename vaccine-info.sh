echo "You will get notified at $RECIEVER_EMAIL"
echo "Looking for District $DIST_ID"
echo ""
if [[ "$DIST_ID" == "" ]]
then
    echo "Error: Pass District ID in environment like -e DIST_ID=<district-id>"
    exit 0
fi

if [[ "$RECIEVER_EMAIL" == "" ]]
then
    echo "Error: Pass reciever email in environment like -e RECIEVER_EMAIL=<reciever-email>"
    exit 0
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
                    NAME=$(_jq1 '.name') 
                    PINCODE=$(_jq1 '.pincode')
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
    sleep 2m
done

