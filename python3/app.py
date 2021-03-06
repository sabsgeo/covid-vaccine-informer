import requests
import datetime
import time
import os
import sys

FUNCTION_TO_RUN = sys.argv[1]
if FUNCTION_TO_RUN == "get_states":
    headers = {
        'authority': 'cdn-api.co-vin.in',
        'sec-ch-ua': '"Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"',
        'accept': 'application/json, text/plain, */*',
        'dnt': '1',
        'sec-ch-ua-mobile': '?0',
        'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Safari/537.36',
        'origin': 'https://selfregistration.cowin.gov.in',
        'sec-fetch-site': 'cross-site',
        'sec-fetch-mode': 'cors',
        'sec-fetch-dest': 'empty',
        'referer': 'https://selfregistration.cowin.gov.in/',
        'accept-language': 'en-US,en;q=0.9,ms;q=0.8',
        'if-none-match': 'W/"426-BK5ycccSz2k0MWY/+ZQo/L8JOcg"',
    }

    response = requests.get('https://cdn-api.co-vin.in/api/v2/admin/location/states', headers=headers)
    if(response.status_code == 200):
        for states in response.json().get('states'):
            print(str(states.get('state_id')) + ") " + states.get('state_name'))
    else:
        print("Error in getting states please try again")

elif FUNCTION_TO_RUN == "get_districts":
    try:
        STATE_ID = sys.argv[2]
    except:
        print("To get district ID's: get_districts <state-id>")
    
    if not(STATE_ID):
        print("Error: STATE_ID is required to run this script")
        sys.exit(1)
    headers = {
        'authority': 'cdn-api.co-vin.in',
        'sec-ch-ua': '"Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"',
        'accept': 'application/json, text/plain, */*',
        'dnt': '1',
        'sec-ch-ua-mobile': '?0',
        'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Safari/537.36',
        'origin': 'https://selfregistration.cowin.gov.in',
        'sec-fetch-site': 'cross-site',
        'sec-fetch-mode': 'cors',
        'sec-fetch-dest': 'empty',
        'referer': 'https://selfregistration.cowin.gov.in/',
        'accept-language': 'en-US,en;q=0.9,ms;q=0.8',
        'if-none-match': 'W/"426-BK5ycccSz2k0MWY/+ZQo/L8JOcg"',
    }
    
    response = requests.get('https://cdn-api.co-vin.in/api/v2/admin/location/districts/' + str(STATE_ID), headers=headers)
    if(response.status_code == 200):
        for dists in response.json().get("districts"):
            print(str(dists.get('district_id')) + ") " + dists.get('district_name'))
    else:
        print("Error in getting the districts")

elif FUNCTION_TO_RUN == "search_slots":
    try:
        BOT_KEY = sys.argv[2]
        CHAT_ID = sys.argv[3]
        DIST_ID = sys.argv[4]
    except:
        print("To get search slots: search_slots <bot-key> <chat-id> <district-id>")
        sys.exit(1)
    print(BOT_KEY)
    print(CHAT_ID)
    print(DIST_ID)

    if not(BOT_KEY and CHAT_ID and DIST_ID):
        print("Error: BOT_KEY,CHAT_ID and DIST_ID in this order is required to run this script")
        sys.exit(1)

    num_act_centers = 0
    prev_mes = []
    prev_mess_ids = []
    while True:
        try:
            bot_key = BOT_KEY
            chat_id = CHAT_ID
            text = ""

            final_message = []
            #get current time
            d = datetime.datetime.now()
            needed_date = d.strftime("%d")+ "-" + d.strftime("%m") + "-2021"
            checking_time = 60

            headers = {
                'authority': 'cdn-api.co-vin.in',
                'accept': 'application/json, text/plain, */*',
                'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36',
                'sec-gpc': '1',
                'origin': 'https://selfregistration.cowin.gov.in',
                'sec-fetch-site': 'cross-site',
                'sec-fetch-mode': 'cors',
                'sec-fetch-dest': 'empty',
                'referer': 'https://selfregistration.cowin.gov.in/',
                'accept-language': 'en-GB,en-US;q=0.9,en;q=0.8',
                'if-none-match': 'W/"e359-70w8tCMwXVdrozIE9/HX2mZ3sqg"',
            }

            params = (
                ('district_id', DIST_ID),
                ('date', needed_date),
            )
            response = requests.get('https://cdn-api.co-vin.in/api/v2/appointment/sessions/calendarByDistrict', headers=headers, params=params)
            if (response.status_code == 200):
                if ("Miss" in response.headers.get("X-Cache")):
                    for eachjab in response.json().get('centers'):
                        for session in eachjab.get('sessions'):
                            if (session.get('available_capacity_dose1') != 0 or session.get('available_capacity_dose2') != 0):
                                text_mess = ", ".join((eachjab.get('name'),session.get('date'),str(eachjab.get('pincode')),eachjab.get('fee_type'), session.get('vaccine'), str(session.get('available_capacity_dose1')),str(session.get('available_capacity_dose2'))))
                                if (len(text) + len(text_mess) > 4000):
                                    final_message.append(text)
                                    text = ""
                                text += text_mess
                                text += "\n"
                else:
                    print("Cache shown")
            else:
                print("Error in request")

            #Adding the other sets if messages
            if text:
                final_message.append(text)
            
            if (len(final_message) == 0):
                for del_id in prev_mess_ids:
                    delete_message_url = f'https://api.telegram.org/bot{bot_key}/deleteMessage?chat_id={chat_id}&message_id={del_id}'
                    del_res = requests.post(delete_message_url)
                    if (del_res.status_code == 200):
                        prev_mess_ids.remove(del_id)
                        print("Prev Message Deleted")
                    else:
                        print("Error in deleting")

            if prev_mes != final_message:
                for mes in final_message:
                    send_message_url = f'https://api.telegram.org/bot{bot_key}/sendMessage?chat_id={chat_id}&text={mes}&parse_mode=markdown'
                    res = requests.post(send_message_url)
                    if (res.status_code == 200):
                        print("Notification Send.")
                        now_id = res.json().get('result').get('message_id')
                        prev_mess_ids.append(now_id)
                        for del_id in prev_mess_ids:
                            if (del_id is not now_id):
                                delete_message_url = f'https://api.telegram.org/bot{bot_key}/deleteMessage?chat_id={chat_id}&message_id={del_id}'
                                del_res = requests.post(delete_message_url)
                                if (del_res.status_code == 200):
                                    prev_mess_ids.remove(del_id)
                                    print("Prev Message Deleted")
                                else:
                                    print("Error in deleting")
                    else:
                        print("Error in sending message")
            prev_mes = final_message
            print("Checking again in " + str(checking_time) + " sec")
            time.sleep(checking_time)
        except:
            pass
else:
    print("Use the tool as follows:")
    print("To get state ID's: get_states")
    print("To get district ID's: get_districts <state-id>")
    print("To search slots: search_slots <bot-key> <chat-id> <district-id>")
