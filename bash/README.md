# covid-vaccine-informer
Will send a mail when vaccine is available

## Docker build
Sample build script

``` docker build --build-arg SENDER_EMAIL=<email-from-which-you-will-send-mail>  --build-arg SENDER_EMAIL_PASSWORD=<password-of-email-from-which-you-will-send-mail> -t vaccine-informer . ```

## Docker run
Sample script to run the docker
1) To get ID for all states

```docker run -t vaccine-informer get_states```

2) To get ID for all the Districts

```docker run -t vaccine-informer get_districts <state-id>```

3) Search for vaccine slot

```docker run -t vaccine-informer search_slots <district-id> <email-to-get-notification>```


Email for sending mails will only work with gmail

## Caution 
1) Make a new email which can be used to send the mail. As for this to work you would have to enable Allow less secure app from here https://myaccount.google.com/lesssecureapps.
2) Email to which it can send no changes is required
3) I would suggest not to push the docker to public docker hub repos as the email sender password can be easily accessed
