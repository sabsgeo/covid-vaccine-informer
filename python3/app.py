import requests
import datetime
import time
import os
import sys

BOT_KEY = os.environ.get('BOT_KEY')
CHAT_ID = os.environ.get('CHAT_ID')
if not(BOT_KEY and CHAT_ID):
    print("Error: BOT_KEY and CHAT_ID environment variables are required to run this script")
    sys.exit(1)


num_act_centers = 0
prev_mes = []
while True:
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
        ('district_id', '297'),
        ('date', needed_date),
    )
    response = requests.get('https://cdn-api.co-vin.in/api/v2/appointment/sessions/calendarByDistrict', headers=headers, params=params)
    if (response.status_code == 200):
        if ("Miss" in response.headers.get("X-Cache")):
            for eachjab in response.json().get('centers'):
                for session in eachjab.get('sessions'):
                    if (session.get('available_capacity_dose1') != 0 or session.get('available_capacity_dose2') != 0):
                        text_mess = ",".join((eachjab.get('name'),session.get('date'),str(eachjab.get('pincode')),eachjab.get('fee_type'), session.get('vaccine'), str(session.get('available_capacity_dose1')),str(session.get('available_capacity_dose2'))))
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
    
    if prev_mes != final_message:
        for mes in final_message:
            send_message_url = f'https://api.telegram.org/bot{bot_key}/sendMessage?chat_id={chat_id}&text={mes}&parse_mode=markdown'
            res = requests.post(send_message_url)
            if (res.status_code == 200):
                print("Notification Send.")        
    prev_mes = final_message
    print("Checking again in " + str(checking_time) + " sec")
    time.sleep(checking_time)
