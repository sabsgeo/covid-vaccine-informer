# covid-vaccine-informer
Will send a mail when vaccine is available

## Docker build
Sample build script

``` docker build --build-arg SENDER_EMAIL=<email-from-which-you-will-send-mail>  --build-arg SENDER_EMAIL_PASSWORD=<password-of-email-from-which-you-will-send-mail> -t vaccine-informer . ```

Sample script to run the script 

```docker run -e DIST_ID=<district-id> -e RECIEVER_EMAIL=<email-on-which-you-want-to-send-notification> -t vaccine-informer```

## Caution 
1) Make a new email which can be used to send the mail. As for this to work you would have to enable Allow less secure app from here https://myaccount.google.com/lesssecureapps.
2) Email to which it can send no changes is required
