# Vaccine informer

This python script will send telegram notification if there is a vaccine slot available

## Build steps

1. Clone code
2. Make public telegram channel 
3. Make a telegram bot by visting the channel @BotFather and typing ```/start```
4. Save the api key for the telegram bot which will be used for API communication
5. Make yourself and telegram bot admin of the public telegram channel that you created so that the bot can post the messages
6. Get the channel ID by forwarding a message from the channel to @JsonDumpBot
7. Build the docker with 

```docker build -t vaccine-python .```


## Run the docker
1. Get the list of states and their ID's

```
docker run -t vaccine-python:latest get_states
```

3. Get the list of districts for a given state

```
docker run -t vaccine-python:latest get_districts <state-id>
```

5. Search for slots and get notified in telegram

```
docker run -t vaccine-python:latest search_slots <bot-key> <chat-id> <district-id>
```
