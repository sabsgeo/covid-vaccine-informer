# Vaccine informer

This python script will send telegram notification if there is a vaccine slot available

## Build steps

1. Clone code
2. Make public telegram channel 
3. Make a telegram bot by visting the channel @BotFather and typing ```/start```
4. Save securty the api key for the telegram bot which is used for API communication
5. Make yourself and telegram bot admin of the telegram channel so that the bot can post the messages
6. Get the channel ID by forwarding a message from the channel to @JsonDumpBot
7. Build the docker with ```docker build -t vaccine-python .```

## Run the docker

```
docker run BOT_KEY="<bot-key>" -e CHAT_ID="<chat-id>" -e DIST_ID="<district-id>" -t vaccine-python:latest 
```
